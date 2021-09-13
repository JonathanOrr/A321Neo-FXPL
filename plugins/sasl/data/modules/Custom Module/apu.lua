-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: apu.lua 
-- Short description: APU-related part (see also fuel, electrical and bleed)
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- APU management file
----------------------------------------------------------------------------------------------------

-- TODO EGT margin display and calculation with two phases
-- TODO AVAIL indication calculation acc. real logic
-- TODO EGT indication in 5° steps
-- TODO stop ignition at 55% N
-- TODO conditional fuel pump load
-- TODO AVAIL goes off when master is switched off, even in cooling state

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

local FLAP_OPEN_TIME_SEC = 27    -- https://www.youtube.com/watch?v=qKbQVewLua8 , but is the motor started immediately?
local FLAP_CLOSE_N = 7.5         -- flap does not close immediately on master switch off but based on N
local APU_START_WAIT_TIME = 5    -- ECB initialisation takes some time, delay from master switch on until start button indication goes on
local APU_TEST_TIME = 20         -- duration of test cycle triggered from maintenance panel
local APU_COOLING_TRESHOLD = 600 -- time after which use of bleed does not lead to cooling, just a guess right now
-- APU (FSM) states according APS3200 training material (TODO implement FSM TBD)
local STATE_OFF = 0
local STATE_POWER_UP = 1
local STATE_WATCH = 2
local STATE_START_PREP = 3
local STATE_STARTING = 4
local STATE_RUN = 4
local STATE_COOLDOWN = 5 -- cooldown phase in case of usage of bleed some time before
local STATE_SHUTDOWN = 6


----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local last_update_time = 0 --
local current_time = 0     -- time when entering update (local var, since time is requested in several places)
local apu_state = 0        -- prep for future FSM based logic, e.g. to interrupt normal spool-up sequence in case of failure

local master_switch_status  = false    -- master switch is a toggle push button, actual status controlled by logic
local master_switch_disabled_time = 0  -- startup and shutdown sequence is driven by some timers for some situations
local master_switch_enabled_time = 0   -- controls flap open state
local master_is_on_time = 0

local start_requested = false
local spoolup_started_time = 0 -- actual time of startup begin
local n95_time = 0 -- time reaching 95% N (avail max 2 sec later)
local avail_time = 0 -- time reaching avail state (hide APU SD page 10 sec later, switch EGT margin calc )
local cooling_end_time = 0;

local test_in_progress = false
local test_start_time = 0
local test_is_ok       = false

local random_egt_apu = 0
local random_egt_apu_last_update = 0
----------------------------------------------------------------------------------------------------
-- Init
----------------------------------------------------------------------------------------------------
function onAirportLoaded()
    set(Apu_bleed_xplane, 0)  -- initially we want to have APU bleed switch off in any case
    set(APU_EGT, get(OTA))
end
----------------------------------------------------------------------------------------------------
-- Command handlers
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler ( APU_cmd_master, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if master_switch_status then
            -- shutdown requested
            -- APU master switch is a toggle, so here the status is the one before switching to target state
            if master_switch_disabled_time ~= 0 then
                -- TODO didn't get the logic behind this - when do we have to clear disabled time when switching off the APU?
                master_switch_disabled_time = 0
            else
                master_switch_disabled_time = get(TIME)
            end
        else
            master_is_on_time = get(TIME) -- start when power up phase begins
            master_switch_status = true
            if master_switch_disabled_time == 0 then
                master_switch_enabled_time = get(TIME)  -- keep time of first time switching on the master
            end
        end
    end
end)

sasl.registerCommandHandler ( APU_cmd_start, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if master_switch_status then
            start_requested = true -- actual start depends on some condition like flap open etc
        end
    end
    return 1
end)

sasl.registerCommandHandler ( MNTN_APU_test, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        test_in_progress = not test_in_progress
    end
    return 1
end)

sasl.registerCommandHandler ( MNTN_APU_reset, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        test_in_progress = false
        test_is_ok = false
    end
    return 1
end)

----------------------------------------------------------------------------------------------------
-- Various functions
----------------------------------------------------------------------------------------------------

function update_egt()

    -- somw random fluctuation is nice
    if get(TIME) - random_egt_apu_last_update > 2 then
        random_egt_apu = math.random() * 6 - 3 -- random +/- 3 degrees
        random_egt_apu_last_update = get(TIME)
    end

    local apu_n1 = get(Apu_N1)
    -- TODO we have to use our own APU N1 implementation, currently XP logic is used
    -- TODO use a refined approach for EGT rise (somewhat "flat" behaviour right now)
    -- TODO since during start there is a EGT drop in certain N1 range, how to handle warm starts prior to cooldown?
    if master_switch_status and get(FAILURE_ENG_APU_FAIL) == 0 then
        if apu_n1 < 1 then
            Set_dataref_linear_anim(APU_EGT, get(OTA), -50, 1000, 1)
        elseif apu_n1 <= 33.5 then
            -- rise to 900 in first segment
            local target_egt = Math_rescale(0, get(OTA), 33.5, 805+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        elseif apu_n1 <= 38 then
            -- drop to 800
            local target_egt = Math_rescale(33.5, 805, 38,  790+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        elseif apu_n1 <= 47 then
            -- finally we want to rise up to 845
            local target_egt = Math_rescale(38, 790, 47, 845+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        elseif apu_n1 > 47 then
            -- finally we want to drop to about 400 degrees
            local target_egt = Math_rescale(47, 845, 100, 420+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        end
    else
        -- APU is switched off, just slowly drop EGT to OAT
        Set_dataref_linear_anim(APU_EGT, get(OTA), -50, 1000, 3)
    end
end

local function single_battery_condition_fault()
    return master_switch_status and ((ELEC_sys.batteries[1].is_connected_to_dc_bus and not ELEC_sys.batteries[2].is_connected_to_dc_bus)
        or (not ELEC_sys.batteries[1].is_connected_to_dc_bus and ELEC_sys.batteries[2].is_connected_to_dc_bus))
end

local function update_button_datarefs()

    local is_faulty = get(FAILURE_ENG_APU_FAIL) == 1 or get(DC_bat_bus_pwrd) == 0 or single_battery_condition_fault()

    set(Apu_master_button_state,(master_switch_status and 1 or 0))

    -- beware: master switch on is based on the status and a possible unfinished shutdown request
    pb_set(PB.ovhd.apu_master, master_switch_status and master_switch_disabled_time == 0, is_faulty)
    pb_set(PB.ovhd.apu_start, start_requested and (get(TIME) - master_is_on_time > APU_START_WAIT_TIME) , get(Apu_avail) == 1)

end

local function update_apu_flap()
    local elec_ok = get(DC_bat_bus_pwrd) == 1
    local apu_n1 = get(Apu_N1)
    if master_switch_status and elec_ok then
        if get(TIME) - master_switch_enabled_time > FLAP_OPEN_TIME_SEC then
            set(APU_flap, 1)
        elseif get(APU_flap) == 1 and apu_n1 < FLAP_CLOSE_N then
            -- in case we had a shutdown but re-enable master the flap may be not yet closed...
            -- flap open delay not yet reached, keep it closed TODO what kind of power consumption is added here?
            ELEC_sys.add_power_consumption(ELEC_BUS_DC_BAT_BUS, 1, 2)   -- Guess
            set(APU_flap, 0)
        end
        Set_dataref_linear_anim(APU_flap_open_pos, 1, 0, 1, 1/FLAP_OPEN_TIME_SEC)
    else
        if elec_ok then
            -- Cannot move if not powered
            Set_dataref_linear_anim(APU_flap_open_pos, 0, 0, 1, 1/FLAP_OPEN_TIME_SEC)
            if get(APU_flap_open_pos) > 0 then
                ELEC_sys.add_power_consumption(ELEC_BUS_DC_BAT_BUS, 1, 2)   -- Guess
            end
        end
        -- APU flap closes only below a certain N1, see https://www.youtube.com/watch?v=Ye8y90KD1JA
        if apu_n1 <= FLAP_CLOSE_N then set(APU_flap, 0) end
    end
end

-- XP APU starter pos will trigger spin-up and shutdown of APU_N
-- TODO as long as we use the XP N value we have to keep this logic
local function update_XP_APU_start_PB()
    if master_switch_status and get(FAILURE_ENG_APU_FAIL) == 0 and not test_in_progress and get(Fire_pb_APU_status) == 0 then 

        if start_requested and get(APU_flap) == 1 and get(Apu_avail) == 0 and get(DC_bat_bus_pwrd) == 1
                and get(Apu_fuel_source) > 0 and not single_battery_condition_fault() then
            set(Apu_start_position, 2)  -- ON
        elseif get(Apu_avail) == 1 and get(Apu_fuel_source) > 0  then
            set(Apu_start_position, 1)  -- AVAIL
            start_requested = false
        elseif get(Apu_avail) == 0 and master_switch_disabled_time == 0 then
            -- shutdown only, if cooling phase ended...
            set(Apu_start_position, 0)  -- OFF
        end
    else
        set(Apu_start_position, 0)
        start_requested = false
    end
end

-- update APU Generator state for ECAM SD APU page
local function update_gen_state()
    if not master_switch_status or get(FAILURE_ENG_APU_FAIL) == 1 then
        set(Ecam_apu_gen_state, 0) -- APU unavailable
    else
        if ELEC_sys.generators[3].switch_status == false then
            set(Ecam_apu_gen_state, 1) -- off
        elseif ELEC_sys.generators[3].curr_voltage > 105 and ELEC_sys.generators[3].curr_hz > 385 then
            set(Ecam_apu_gen_state, 2) -- online
        else
            set(Ecam_apu_gen_state, 3) -- failed due to freq or voltage problem
        end
    end
end

local function update_off_status()
    local apu_bleed_off_time = get(APU_bleed_off_time)
    local shutdown_possible = false;
    local since_bleedoff = get(TIME) - apu_bleed_off_time
    local bleed_switch = get(APU_bleed_switch_pos)
    if master_switch_disabled_time ~= 0 then
        -- master switch turned off some time before

        if bleed_switch == 0 and apu_bleed_off_time == 0  then -- bleed has never been used
            shutdown_possible = true
        elseif  cooling_end_time ~= 0 then
            if get(TIME) > cooling_end_time then
                shutdown_possible = true
            end
        elseif bleed_switch == 0 and (get(TIME) - apu_bleed_off_time) > APU_COOLING_TRESHOLD then -- bleed used long time ago, no cooling
            shutdown_possible = true
        else -- bleed on or used inside cooling relevant period
            -- 60 sec cooling if bleed has been switched off some time ago up to 120 sec if bleed was on when switching off
            local cooling_time = Math_rescale(0,120,APU_COOLING_TRESHOLD-0.1,60,master_switch_disabled_time-apu_bleed_off_time)
            cooling_time = bleed_switch == 1 and 120 or cooling_time -- if bleed is running use max cooling time TODO could be also influenced by duration of bleed usage?
            cooling_end_time = master_switch_disabled_time + cooling_time
        end

        if shutdown_possible then
            -- in case APU bleed has been used actual shutdown will be delayed in a cooling phase
            master_switch_status = false
            master_switch_disabled_time = 0
            cooling_end_time = 0
            set(APU_bleed_off_time,0)
            n95_time = 0
        end
    end

    -- Emergency shutdown
    if get(FAILURE_FIRE_APU) == 1 then
        -- TODO handle auto shutdown on ground
        master_switch_status = false
    end

end

-- handle state of maintenance panel PB if APU test is triggered
local function update_maintenance_panel()
    if test_in_progress and master_switch_status then
        if test_start_time == 0 then
            test_start_time = get(TIME)
        end
        if get(TIME) - test_start_time > APU_TEST_TIME then
            test_is_ok = true
        end
    else
        test_start_time = 0
    end
    pb_set(PB.ovhd.mntn_apu_test, test_in_progress, test_is_ok)
end


----------------------------------------------------------------------------------------------------
-- update()
----------------------------------------------------------------------------------------------------
function update()
    -- TODO do not update in every frame?

    perf_measure_start("apu:update()")
    current_time = get(TIME)


    --apu availability
    if master_switch_disabled_time ~= 0 then
        set(Apu_avail, 0)
    else
        local apu_n = get(Apu_N1)
        if apu_n > 95 then
            if n95_time == 0 then n95_time = current_time end
            if master_switch_status and (apu_n >= 99 or current_time - n95_time >= 2) then set(Apu_avail, 1) end
        elseif apu_n < 100  then -- TODO seems to be no longer required
            set(Apu_avail, 0)
        end
    end

    update_off_status()
    update_egt()
    update_button_datarefs()
    update_apu_flap()
    update_XP_APU_start_PB()
    update_gen_state()
    update_maintenance_panel()
    last_update_time = get(TIME)
    perf_measure_stop("apu:update()")
end
