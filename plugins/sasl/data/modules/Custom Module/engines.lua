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
-- File: engines.lua
-- Short description: Main engine file - mostly start procedure
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Engine parameters computation and ignition phase file
----------------------------------------------------------------------------------------------------

-- Engine start procedure: how it works?
--
-- The following conditions switch the status of the engine to "avail" (in the x-plane dataref):
-- - sim/cockpit2/engine/actuators/igniter_on = 1
-- - sim/cockpit/engine/starter_duration = 100
-- - sim/flightmodel/engine/ENGNN1 > 5
-- DO NOT USE sim/cockpit2/engine/actuators/ignition_key, it will start the engine using the X-Plane
-- procedure (and we don't want that)

-- Our procedure is divided in 3 phases:
-- - Phase 1:  N2 from 0 to 10: cranking the engine using perform_crank_procedure()
-- - Phase 2:  N2 from 10 to 34.2: it manually controls the N2 according to the
--             perform_starting_procedure_follow_n2(eng), and the array ENG.data.startup.n2
-- - Phase 3:  N1 from 0ish to 18.3: it manually controls the N1 according to the
--             perform_starting_procedure_follow_n1(eng), and the array ENG.data.startup.n1



----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('engines/n1_modes.lua')
include('engines/leap1a.lua')
include('engines/pw1133g.lua')

local MAX_EGT_OFFSET = 10  -- This is the maximum offset between one engine and the other in terms of EGT
local ENG_N1_CRANK    = 10  -- N1 used for cranking and cooling
local ENG_N1_CRANK_FF = 15  -- FF in case of wet cranking
local ENG_N1_CRANK_EGT= 95  -- Target EGT for cranking
local ENG_N1_LL_IDLE  = 18.3 -- Value to determine if parameters control should be given to X-Plane 
local N1_INC_AI_ENG   = 1    -- Increase of minimum N1 if at least one ENG Anti-ice is activated
local N1_INC_AI_WING  = 1.5  -- Increase of minimum N1 if at least one WING Anti-ice is activated
local MAGIC_NUMBER = 100     -- This is a magic number, which value is necessary to start the engine (see later)

local current_engine_id = 0  -- Just to check which is the current engine

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

-- Since random parameters are quite stable, we update the pool of randomness every 2 seconds
local random_pool_1 = 0
local random_pool_2 = 0
local random_pool_3 = 0
local random_pool_update = 0

local egt_eng_1_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values
local egt_eng_2_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values

local eng_manual_switch = {false,false}   -- Is engine manual start enabled?
local dual_cooling_switch = false

local eng_N1_off  = {0,0}   -- N1 for startup procedure
local eng_N2_off  = {0,0}   -- N2 for startup procedure
local eng_FF_off  = {0,0}   -- FF for startup procedure
local eng_EGT_off = {get(OTA),get(OTA)}   -- EGT for startup procedure

local slow_start_time_requested = false
local igniter_eng = {0,0}
local windmill_min_speed = {250 + math.random()*30, 250 + math.random()*30}

-- Engine startup cooling stuffs
local time_last_shutdown = {-1,-1}    -- The last time point you shutdown the engines (-1 or 0 = invalid data)
local cooling_left_time  = {0, 0}
local cooling_has_cooled = {false, false}

local already_back_to_norm = false -- This is used to check continuous ignition

local last_time_toga = {0,0} -- Time point where thrust levers are set to TOGA

local already_started_eng = {false, false}

----------------------------------------------------------------------------------------------------
-- Various datarefs
----------------------------------------------------------------------------------------------------

local eng_ignition_switch = globalPropertyia("sim/cockpit2/engine/actuators/ignition_key")
local eng_igniters        = globalPropertyia("sim/cockpit2/engine/actuators/igniter_on")
local starter_duration    = globalPropertyfa("sim/cockpit/engine/starter_duration")

local eng_mixture         = globalPropertyfa("sim/cockpit2/engine/actuators/mixture_ratio")
local eng_N1_enforce      = globalPropertyfa("sim/flightmodel/engine/ENGN_N1_")
local eng_N2_enforce      = globalPropertyfa("sim/flightmodel/engine/ENGN_N2_")

local xp_avail_1 = globalProperty("sim/flightmodel/engine/ENGN_running[0]")
local xp_avail_2 = globalProperty("sim/flightmodel/engine/ENGN_running[1]")

local config_max_thrust = globalProperty("sim/aircraft/engine/acf_tmax")     -- [kN]
local config_face_size = globalProperty("sim/aircraft/engine/acf_face_jet")  -- [m^2]

local eng_FF_kgs          = globalPropertyfa("sim/cockpit2/engine/indicators/fuel_flow_kg_sec")

----------------------------------------------------------------------------------------------------
-- Functions - Commands
----------------------------------------------------------------------------------------------------
function engines_auto_slow_start(phase)
    -- When the user press Flight -> Start engines to running
    if phase == SASL_COMMAND_BEGIN then
        slow_start_time_requested = true -- Please check the function update_auto_start()
        sasl.commandOnce(FUEL_cmd_internal_qs)
    end
    return 0
end

function engines_auto_quick_start(phase)
    if phase == SASL_COMMAND_BEGIN then
        sasl.commandOnce(FUEL_cmd_internal_qs)
    
        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
        set(Engine_mode_knob, 0)
    end
    return 1
end

function onAirportLoaded()
    -- When the aircraft is loaded in flight, let's switch on all the pumps
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        engines_auto_quick_start(SASL_COMMAND_BEGIN)
    else
        set(Engine_1_master_switch, 0)
        set(Engine_2_master_switch, 0)
        set(Engine_mode_knob, 0)
    end
end

function engines_mode_up(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Engine_mode_knob, get(Engine_mode_knob) + 1)
    end
    return 1
end

function engines_mode_down(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Engine_mode_knob, get(Engine_mode_knob) - 1)
    end
    return 1
end

-- to support TCA quadrant switch we need to explicitly set the mode
function engines_mode(phase,mode)
    if phase == SASL_COMMAND_BEGIN then
        set(Engine_mode_knob, mode)
    end
    return 1
end

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ENG_cmd_manual_start_1,  0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_manual_switch[1] = not eng_manual_switch[1] end end )
sasl.registerCommandHandler (ENG_cmd_manual_start_2,  0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_manual_switch[2] = not eng_manual_switch[2] end end )
sasl.registerCommandHandler (ENG_cmd_dual_cooling,    0, function(phase) if phase == SASL_COMMAND_BEGIN then dual_cooling_switch = not dual_cooling_switch end end )

sasl.registerCommandHandler (ENG_cmd_master_toggle_1, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Engine_1_master_switch, 1-get(Engine_1_master_switch)) end end )
sasl.registerCommandHandler (ENG_cmd_master_toggle_2, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Engine_2_master_switch, 1-get(Engine_2_master_switch)) end end )
-- Airbus TCA support
sasl.registerCommandHandler (ENG_cmd_master_on_1, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Engine_1_master_switch, 1) end end )
sasl.registerCommandHandler (ENG_cmd_master_off_1, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Engine_1_master_switch, 0) end end )
sasl.registerCommandHandler (ENG_cmd_master_on_2, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Engine_2_master_switch, 1) end end )
sasl.registerCommandHandler (ENG_cmd_master_off_2, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Engine_2_master_switch, 0) end end )

sasl.registerCommandHandler (ENG_cmd_mode_up,            0, function(phase) engines_mode_up(phase) end)
sasl.registerCommandHandler (ENG_cmd_mode_down,          0, function(phase) engines_mode_down(phase) end)
-- Airbus TCA support
sasl.registerCommandHandler (ENG_cmd_mode_ignite,        0, function(phase) engines_mode(phase,1) end)
sasl.registerCommandHandler (ENG_cmd_mode_norm,          0, function(phase) engines_mode(phase,0) end)
sasl.registerCommandHandler (ENG_cmd_mode_crank,         0, function(phase) engines_mode(phase,-1) end)
sasl.registerCommandHandler (sasl.findCommand("sim/operation/auto_start"),  1, engines_auto_slow_start )
sasl.registerCommandHandler (sasl.findCommand("sim/operation/quick_start"), 1, engines_auto_quick_start )

----------------------------------------------------------------------------------------------------
-- Functions - Engine parameters
----------------------------------------------------------------------------------------------------

-- Compute the cooling time required given the time interval the engine is off (check Discord image)
local function cooling_time(time_since_last_shutdown)
    if time_since_last_shutdown <= 0 then
        return 0
    end
    
    local time_cool = 0
    
    if time_since_last_shutdown <= 60 * 60 then
        -- Less than 1 hour
        time_cool = Math_rescale(0,0,60*60,90, time_since_last_shutdown)
    elseif time_since_last_shutdown <= 2 * 60 * 60 then
        -- Less than 2 hour
        time_cool = Math_rescale(60*60,90,2*60*90, 0, time_since_last_shutdown)
    else
        return 0
    end

    return Math_clamp(time_cool, 10, 90)
end

local function min_n1(altitude)
    return 5.577955*math.log(0.03338352*altitude+23.66644)+1.724586
end


local function update_n1_minimum()
    local curr_altitude = get(Elevation_m) * 3.28084
    local comp_min_n1 = min_n1(curr_altitude) 
                      + ((AI_sys.comp[ANTIICE_ENG_1].valve_status
                          or AI_sys.comp[ANTIICE_ENG_2].valve_status) and N1_INC_AI_ENG or 0)
    
    set(Eng_N1_idle, comp_min_n1)

    local always_a_minimum = ENG_N1_LL_IDLE + 0.2

    -- Update ENG1 N1 minimum
    local curr_n1 = get(Eng_1_N1)    
    if curr_n1 < always_a_minimum and get(Engine_1_avail) == 1 then
        set(eng_N1_enforce, always_a_minimum, 1)
    end

    -- Update ENG2 N1 minimum
    curr_n1 = get(Eng_2_N1)
    if curr_n1 < always_a_minimum and get(Engine_2_avail) == 1 then
        set(eng_N1_enforce, always_a_minimum, 2)
    end
end

local function update_n2()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > 5 and get(Engine_1_master_switch) == 1  then
        Set_dataref_linear_anim(Eng_1_N2, ENG.data.n1_to_n2_fun(eng_1_n1), 0, 130, 10)
    else
        Set_dataref_linear_anim(Eng_1_N2, eng_N2_off[1], 0, 130, 10)
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > 5 and get(Engine_2_master_switch) == 1  then
        Set_dataref_linear_anim(Eng_2_N2, ENG.data.n1_to_n2_fun(eng_2_n1), 0, 130, 10)
    else
        Set_dataref_linear_anim(Eng_2_N2, eng_N2_off[2], 0, 130, 10)
    end

end


local function update_egt()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > ENG_N1_LL_IDLE then
        local computed_egt = ENG.data.n1_to_egt_fun(eng_1_n1, get(OTA))
        computed_egt = computed_egt * (1 + get(FAILURE_ENG_STALL, 1) * get(eng_1_n1)/90 * math.random())
        computed_egt = computed_egt + egt_eng_1_offset + random_pool_1*2 -- Let's add a bit of randomness
        Set_dataref_linear_anim(Eng_1_EGT_c, computed_egt, -50, 1500, 70)
    else
        set(Eng_1_EGT_c, eng_EGT_off[1])
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > ENG_N1_LL_IDLE then
        local computed_egt = ENG.data.n1_to_egt_fun(eng_2_n1, get(OTA))
        computed_egt = computed_egt * (1 + get(FAILURE_ENG_STALL, 2) * get(eng_1_n1)/90 * math.random())
        computed_egt = computed_egt + egt_eng_2_offset + random_pool_2*2 -- Let's add a bit of randomness
        Set_dataref_linear_anim(Eng_2_EGT_c, computed_egt, -50, 1500, 70)
    else
        set(Eng_2_EGT_c, eng_EGT_off[2])
    end

end

local function update_ff()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > ENG_N1_LL_IDLE then
        set(Eng_1_FF_kgs, get(eng_FF_kgs,1))
    else
        set(Eng_1_FF_kgs,eng_FF_off[1])
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > ENG_N1_LL_IDLE then
        set(Eng_2_FF_kgs, get(eng_FF_kgs,2))
    else
        set(Eng_2_FF_kgs,eng_FF_off[2])
    end
 
end

local function update_avail()

    
    local eng_has_fuel = get(Fuel_tank_selector_eng_1) > 0

    -- ENG 1
    if get(Eng_1_N1) > ENG_N1_LL_IDLE and get(Engine_1_master_switch) == 1 and eng_has_fuel and get(xp_avail_1) == 1 and get(FAILURE_ENG_1_FAILURE) == 0 then
        if get(Engine_1_avail) == 0 then
            set(EWD_engine_avail_ind_start, get(TIME), 1)
            set(Engine_1_avail, 1)
        end
    else
        set(Engine_1_avail, 0)    
        set(EWD_engine_avail_ind_start, 0, 1)
    end

    local eng_has_fuel = get(Fuel_tank_selector_eng_2) > 0
    
    -- ENG 2
    if get(Eng_2_N1) > ENG_N1_LL_IDLE and get(Engine_2_master_switch) == 1 and eng_has_fuel and get(xp_avail_2) == 1 and get(FAILURE_ENG_2_FAILURE) == 0 then
        if get(Engine_2_avail) == 0 then
            set(EWD_engine_avail_ind_start, get(TIME), 2)
            set(Engine_2_avail, 1)
        end
    else
        set(Engine_2_avail, 0)    
        set(EWD_engine_avail_ind_start, 0, 2)
    end

    
end

----------------------------------------------------------------------------------------------------
-- Functions - Secondary parameters
----------------------------------------------------------------------------------------------------
set(Eng_1_OIL_temp, get(OTA))
set(Eng_2_OIL_temp, get(OTA))

local function update_oil_stuffs()

    -- ENG 1 - PRESS
    if get(Engine_1_avail) == 1 then
        local n2_value = get(Eng_1_N2)
        local press = Math_rescale(60, ENG.data.oil.pressure_min_idle+1, ENG.data.max_n2-10, ENG.data.oil.pressure_max_mct, n2_value)
        
        if get(FAILURE_ENG_LEAK_OIL, 1) == 1 then   -- OIL is leaking from engine T_T
            Set_dataref_linear_anim(Eng_1_OIL_press, 0, 0, 500, 0.75 - 0.25 * press / ENG.data.oil.pressure_max_mct )
        else
            Set_dataref_linear_anim(Eng_1_OIL_press, press, 0, 500, 28 + random_pool_3 * 4)
        end
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_1_N2))
        local press = Math_rescale(10, 0, 70, ENG.data.oil.pressure_max_toga, n2_value)
        Set_dataref_linear_anim(Eng_1_OIL_press, press, 0, 500, 28 + random_pool_1 * 4)
    end

    -- ENG 1 - TEMP
    if get(Engine_1_avail) == 1 then
        local n2_value = get(Eng_1_N2)
        local temp = Math_rescale(60, 65, ENG.data.max_n2, ENG.data.oil.temp_max_mct, n2_value) + random_pool_2 * 5 + get(FAILURE_ENG_OIL_HI_TEMP, 1) * 70
        Set_dataref_linear_anim(Eng_1_OIL_temp, temp, -50, 250, 2)
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_1_N2))
        local temp = Math_rescale(10, get(OTA), 70, 75, n2_value)
        Set_dataref_linear_anim(Eng_1_OIL_temp, temp, -50, 250, 2)
    end
    
    -- ENG 2 - PRESS
    if get(Engine_2_avail) == 1 then
        local n2_value = get(Eng_2_N2)
        local press = Math_rescale(60, ENG.data.oil.pressure_min_idle+1, ENG.data.max_n2-10, ENG.data.oil.pressure_max_mct, n2_value)
        if get(FAILURE_ENG_LEAK_OIL, 2) == 1 then   -- OIL is leaking from engine T_T
            Set_dataref_linear_anim(Eng_2_OIL_press, 0, 0, 500, 0.75 - 0.25 * press / ENG.data.oil.pressure_max_mct )
        else
            Set_dataref_linear_anim(Eng_2_OIL_press, press, 0, 500, 28 + random_pool_2 * 4)
        end
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_2_N2))
        local press = Math_rescale(10, 0, 70, ENG.data.oil.pressure_max_toga, n2_value)
        Set_dataref_linear_anim(Eng_2_OIL_press, press, 0, 500, 28 + random_pool_3 * 4)
    end

    -- ENG 2 - TEMP
    if get(Engine_2_avail) == 1 then
        local n2_value = get(Eng_2_N2)
        local temp = Math_rescale(60, 65, ENG.data.max_n2, ENG.data.oil.temp_max_mct, n2_value) + random_pool_1 * 5 + get(FAILURE_ENG_OIL_HI_TEMP, 2) * 70
        Set_dataref_linear_anim(Eng_2_OIL_temp, temp, -50, 250, 1)
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_2_N2))
        local temp = Math_rescale(10, get(OTA), 70, 75, n2_value)
        Set_dataref_linear_anim(Eng_2_OIL_temp, temp, -50, 250, 1)
    end


end

function update_vibrations()
    local n1_value = get(Eng_1_N1)
    local vib_n1 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n1_nominal/4, n1_value) 
    if get(Engine_1_avail) == 1 then vib_n1 = vib_n1 + 0.1*random_pool_3 end
    set(Eng_1_VIB_N1, vib_n1)

    local n2_value = get(Eng_1_N2)
    local vib_n2 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n2_nominal/4, n2_value)
    if get(Engine_1_avail) == 1 then vib_n2 = vib_n2 + 0.1*random_pool_2 end
    set(Eng_1_VIB_N2, vib_n2)

    local n1_value = get(Eng_2_N1)
    local vib_n1 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n1_nominal/4, n1_value)
    if get(Engine_2_avail) == 1 then vib_n1 = vib_n1 + 0.1*random_pool_1 end
    set(Eng_2_VIB_N1, vib_n1)

    local n2_value = get(Eng_2_N2)
    local vib_n2 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n2_nominal/4, n2_value)
    if get(Engine_2_avail) == 1 then vib_n2 = vib_n2 + 0.1*random_pool_3 end
    set(Eng_2_VIB_N2, vib_n2)


end 

----------------------------------------------------------------------------------------------------
-- Functions - Ignition stuffs
----------------------------------------------------------------------------------------------------

local function perform_crank_procedure(eng, wet_cranking)
    -- This is PHASE 1
    
    if (eng==1 and get(Engine_1_avail) == 1) or (eng==2 and get(Engine_2_avail) == 1) then
        -- Just for precaution, crank has no sense if the engine is already running
        -- In chase, just don't do anything
        return
    end
    
    -- Crank doesn't do anything special. Just warm up and run the N2 turbine

    set(eng_mixture, 0, eng) -- No mixture for dry cranking

    -- Set N2 for cranking
    eng_N2_off[eng] = Set_linear_anim_value(eng_N2_off[eng], ENG_N1_CRANK, 0, ENG.data.max_n2, 0.25)
    set(eng_N2_enforce, eng_N2_off[eng], eng)
    
    -- Set EGT for cranking
    eng_EGT_off[eng] = Set_linear_anim_value(eng_EGT_off[eng], ENG_N1_CRANK_EGT, -50, 1500, 2)

    set(Eng_is_spooling_up, 1, eng) -- Need for bleed air computation, see packs.lua
    
    if wet_cranking then
        -- Wet cranking requested, let's spill a bit of fuel
        -- This is not actually consuming fuel but well, it's a minimum amount
        eng_FF_off[eng] = ENG_N1_CRANK_FF/3600
    else
        -- Dry cranking
        eng_FF_off[eng] = 0
    end
    
end

local function perform_starting_procedure_follow_n2(eng)
    -- This is PHASE 2

    set(eng_mixture, 0, eng) -- No mixture in this phase
    if igniter_eng[eng] == 0 and not eng_manual_switch[eng] then
        igniter_eng[eng] = math.random() > 0.5 and 1 or 2  -- For ECAM visualization only, no practical effect
    elseif eng_manual_switch[eng] then
        igniter_eng[eng] = 3  -- Manual start uses both igniters
    end

    set(Eng_is_spooling_up, 1, eng) -- Need for bleed air computation, see packs.lua
    
    for i=1,(#ENG.data.startup.n2-1) do
        -- For each phase... 

        if eng_N2_off[eng] < ENG.data.startup.n2[i+1].n2_start then
            -- We have found the correct phase
            
            -- Let's set the fuel flow
            eng_FF_off[eng] = ENG.data.startup.n2[i].fuel_flow  / 3600
            
            local eng_has_fuel = (eng==1 and get(Fuel_tank_selector_eng_1)>0) or (eng==2 and get(Fuel_tank_selector_eng_2)>0)
            
            -- If we are on manua start, the master switch  may not be on. In this case case let's check
            -- it before injecting fuel
            local eng_manual_start_continue = ((eng == 1 and get(Engine_1_master_switch) == 1) or (eng == 2 and get(Engine_2_master_switch) == 1))

            if eng_FF_off[eng] == 0 or (eng_has_fuel and eng_manual_start_continue)  then

                -- We continue the starting procedure if: the FF is still 0, so we are spinning up with bleed
                -- OR the FF > 0 and there is fuel and the engine master switch has been moved to ON

                -- Let's compute the new N2
                eng_N2_off[eng] = eng_N2_off[eng] + ENG.data.startup.n2[i].n2_increase_per_sec * get(DELTA_TIME)
                set(eng_N2_enforce, eng_N2_off[eng], eng)
                    
                -- And let's compute the EGT
                perc = (eng_N2_off[eng] - ENG.data.startup.n2[i].n2_start) / (ENG.data.startup.n2[i+1].n2_start - ENG.data.startup.n2[i].n2_start)
                eng_EGT_off[eng] = Math_lerp(ENG.data.startup.n2[i].egt, ENG.data.startup.n2[i+1].egt, perc)
            else
                eng_FF_off[eng] = 0
            end
            break -- Don't need to check the other phases
        end

    end
end

local function perform_starting_procedure_follow_n1(eng)
    -- This is PHASE 3
    set(eng_mixture, 1, eng)  -- Mixture in this phase
    set(eng_igniters, 1, eng) -- and igniters as well


    for i=1,(#ENG.data.startup.n1-1) do
        -- For each phase...
        
        -- Get the current N1, but it can't be zero 
        local curr_N1 = math.max(math.max(eng_N1_off[eng],2), eng == 1 and get(Eng_1_N1) or get(Eng_2_N1))
        
        if curr_N1 < ENG.data.startup.n1[i+1].n1_set then
            -- We have found the correct phase

            -- Let's set the fuel flow
            eng_FF_off[eng] = ENG.data.startup.n1[i].fuel_flow  / 3600
            
            local eng_has_fuel = (eng==1 and get(Fuel_tank_selector_eng_1)>0) or (eng==2 and get(Fuel_tank_selector_eng_2)>0)
            
            if eng_FF_off[eng] == 0 or eng_has_fuel then
            
                -- Let's compute the new N2
                local new_N1 = curr_N1 + ENG.data.startup.n1[i].n1_increase_per_sec * get(DELTA_TIME)
                eng_N1_off[eng] = new_N1
                set(eng_N1_enforce, new_N1, eng)

                
                -- Let's compute the EGT
                perc = (curr_N1 - ENG.data.startup.n1[i].n1_set) / (ENG.data.startup.n1[i+1].n1_set - ENG.data.startup.n1[i].n1_set)
                eng_EGT_off[eng] = Math_lerp(ENG.data.startup.n1[i].egt, ENG.data.startup.n1[i+1].egt, perc)
            else
                eng_FF_off[eng] = 0
            end
            break -- Don't need to check the other phases
        end
    end
    
    if eng_N1_off[eng] > 12 then
        -- When N1 is more than 12 we can shutdown the igniters. This is necessary, otherwise the
        -- engine will go over the minimum idle
        set(eng_igniters, 0, eng)
        igniter_eng[eng] = 0
    end
end

local function perform_starting_procedure(eng, inflight_restart)
    if eng_N2_off[eng] < 9.5 and not inflight_restart then
        -- Phase 1: Ok let's start by cranking the engine to start rotation
        perform_crank_procedure(eng, false)
        return
    end
    
    if inflight_restart and eng_N2_off[eng] < ENG.data.startup.n2[#ENG.data.startup.n2].n2_start then
        -- v is different, let's skip the first phase
        eng_N2_off[eng] = ENG.data.startup.n2[#ENG.data.startup.n2].n2_start
        eng_N1_off[eng] = eng == 1 and get(Eng_1_N1) or get(Eng_2_N1)
    end
    
    -- If the N2 is larger than 10, then we can start the real startup procedure
    if eng_N2_off[eng] < ENG.data.startup.n2[#ENG.data.startup.n2].n2_start and not inflight_restart then  -- 1st phase, but not inflight_restart

        -- Oh yes, this is a funny thing. You need to set this dataref to 100 to cheat X-Plane
        -- to convince it that the engine has been ignited (but it's not! We don't want X-Plane to
        -- control the ignition with the ignition_key).
        set(starter_duration, MAGIC_NUMBER, eng)

        -- Phase 2: Controlling the N2  
        perform_starting_procedure_follow_n2(eng)
        
    elseif eng_N1_off[eng] < ENG.data.startup.n1[#ENG.data.startup.n1].n1_set and get(FAILURE_ENG_HUNG_START, eng) == 0 then
        -- Phase 3: Controlling the N1
        perform_starting_procedure_follow_n1(eng)
    else
        -- Yeeeh engine ready
    end
    
end


local function update_starter_datarefs()
    --setting integer dataref range
    set(Engine_mode_knob,Math_clamp(get(Engine_mode_knob), -1, 1))
    set(Engine_1_master_switch,Math_clamp(get(Engine_1_master_switch), 0, 1))
    set(Engine_2_master_switch,Math_clamp(get(Engine_2_master_switch), 0, 1))
    
    set(Ecam_eng_igniter_eng_1, igniter_eng[1])
    set(Ecam_eng_igniter_eng_2, igniter_eng[2])
    
    set(Eng_is_spooling_up, 0, 1) -- Need for bleed air computation, see packs.lua
    set(Eng_is_spooling_up, 0, 2) -- Need for bleed air computation, see packs.lua
 
end

-- Returns true if the FADEC has electrical power
local function fadec_has_elec_power(eng)

    if FIRE_sys.eng[eng].block_position then
        return false -- The fire pushbutton kills the power supply
    end

    if get(DC_ess_bus_pwrd) == 1 then
        return true
    end
    
    if eng == 1 and ((get(Gen_1_pwr) == 1) or get(DC_bat_bus_pwrd) == 1) then
        return true
    end
    
    if eng == 2 and ((get(Gen_2_pwr) == 1) or get(DC_bus_2_pwrd) == 1) then
        return true
    end
end


local function needs_coling(eng)
    if not ENG.data.has_cooling then return false end

    if time_last_shutdown[eng] <= 0 then return false end
    
    if cooling_left_time[eng] == -1 and not cooling_has_cooled[eng] then
        time_req = cooling_time(get(TIME) - time_last_shutdown[eng])
        if time_req == 0 then
            return false
        end
        cooling_left_time[eng] = time_req
        return true
    end    
    return not cooling_has_cooled[eng]
end

local function perform_cooling(eng)
    if cooling_left_time[eng] == 0 then
        cooling_has_cooled[eng] = true
        return
    end
    
    perform_crank_procedure(eng, false)
    
    if (eng_N2_off[eng] > 9.8) then
        cooling_left_time[eng] = math.max(0, cooling_left_time[eng] - get(DELTA_TIME))
    end
    set(EWD_engine_cooling_time, cooling_left_time[eng], eng)
    
end


local function update_startup()

    -- An array we need later to see if the engine requires cooldown (=shutdown) or not
    local require_cooldown = {true, true}

    local windmill_condition_1 = get(IAS) > windmill_min_speed[1]
    local windmill_condition_2 = get(IAS) > windmill_min_speed[2]
    
    -- When the pilot moves very fast master switch ON -> OFF -> ON
    local fast_restart_1 = get(Eng_1_N1) > 25
    local fast_restart_2 = get(Eng_2_N1) > 25

    local eng_1_air_cond = (get(L_bleed_press) > 10 or windmill_condition_1 or fast_restart_1)
    local eng_2_air_cond = (get(R_bleed_press) > 10 or windmill_condition_2 or fast_restart_2)
    local does_engine_1_can_start_or_crank = get(Engine_1_avail) == 0 and eng_1_air_cond and get(Eng_1_FADEC_powered) == 1 and math.abs(get(Cockpit_throttle_lever_L)) < 0.05
    local does_engine_2_can_start_or_crank = get(Engine_2_avail) == 0 and eng_2_air_cond and get(Eng_2_FADEC_powered) == 1 and math.abs(get(Cockpit_throttle_lever_R)) < 0.05

    if get(FAILURE_ENG_FADEC_CH1, 1) == 1 and get(FAILURE_ENG_FADEC_CH2, 1) == 1 then
        does_engine_1_can_start_or_crank = false -- No fadec? No start
    end

    if get(FAILURE_ENG_FADEC_CH1, 2) == 1 and get(FAILURE_ENG_FADEC_CH2, 2) == 1 then
        does_engine_2_can_start_or_crank = false -- No fadec? No start
    end


    set(EWD_engine_cooling, 0, 1)
    set(EWD_engine_cooling, 0, 2)

    -- CASE 1: IGNITION
    if get(Engine_mode_knob) == 1 then

        -- ENG 1
        if (eng_manual_switch[1] or get(Engine_1_master_switch) == 1) and does_engine_1_can_start_or_crank then
        
            -- Is cooling required before ignition?
            if get(Any_wheel_on_ground) == 1 and needs_coling(1) then
                set(EWD_engine_cooling, 1, 1)
                perform_cooling(1)

                -- Dual cooling
                if dual_cooling_switch and needs_coling(2) and get(Engine_2_master_switch) == 0 then
                    perform_cooling(2)
                    require_cooldown[2] = false
                    set(EWD_engine_cooling, 1, 2)
                end
            else
                perform_starting_procedure(1, get(All_on_ground) == 0)
            end
            require_cooldown[1] = false
        end

        -- ENG 2
        if (eng_manual_switch[2] or get(Engine_2_master_switch) == 1) and does_engine_2_can_start_or_crank then

            -- Is cooling required before ignition?
            if get(Any_wheel_on_ground) == 1 and needs_coling(2) then
                set(EWD_engine_cooling, 1, 2)
                perform_cooling(2)
                
                -- Dual cooling
                if dual_cooling_switch and needs_coling(1) and get(Engine_1_master_switch) == 0 then
                    set(EWD_engine_cooling, 1, 1)
                    perform_cooling(1)
                    require_cooldown[1] = false
                end
            else
                perform_starting_procedure(2, get(All_on_ground) == 0)
            end
            require_cooldown[2] = false
        end
        
        if get(Any_wheel_on_ground) == 0 then
            -- If you are in flight, keep the igniters on for in-flight restart
            set(eng_igniters, 1, 1)
            set(eng_igniters, 1, 2)
        end
        
    -- CASE 2: CRANK
    elseif get(Engine_mode_knob) == -1 then -- Crank
        if eng_manual_switch[1] and does_engine_1_can_start_or_crank then
            perform_crank_procedure(1, get(Engine_1_master_switch) == 1)
            require_cooldown[1] = false
        end
        if eng_manual_switch[2] and does_engine_2_can_start_or_crank then
            perform_crank_procedure(2, get(Engine_2_master_switch) == 1)
            require_cooldown[2] = false
        end
    -- CASE 3: Master Switch protection
    else
        if get(Engine_1_avail) == 0 and fast_restart_1 and get(Engine_1_master_switch) then
            perform_starting_procedure(1, get(All_on_ground) == 0)
            require_cooldown[1] = false
        end
        if get(Engine_2_avail) == 0 and fast_restart_2 and get(Engine_2_master_switch) then
            perform_starting_procedure(2, get(All_on_ground) == 0)
            require_cooldown[2] = false
        end
    end
    
    -- CASE 3: No ignition, no crank, engine is off of shutting down
    if get(Engine_1_avail) == 0  and require_cooldown[1] then    -- Turn off the engine
        -- Set N2 to zero
        local n2_target = get(IAS) > 50 and 10 + get(IAS)/10 + random_pool_1*2 or 0 -- In in-flight it rotates
        eng_N2_off[1] = Set_linear_anim_value(eng_N2_off[1], n2_target, 0, ENG.data.max_n2, 1)
        set(eng_N2_enforce, eng_N2_off[1], 1)
        
        -- Set EGT and FF to zero
        eng_EGT_off[1] = Set_linear_anim_value(eng_EGT_off[1], get(OTA), -50, 1500, eng_EGT_off[1] > 100 and 10 or 3)
        eng_FF_off[1] = 0
        eng_N1_off[1] = Set_linear_anim_value(eng_N1_off[1], 0, 0, ENG.data.max_n2, 2)
        set(eng_igniters, 0, 1)
        igniter_eng[1] = 0
    end
    if get(Engine_2_avail) == 0 and require_cooldown[2] then    -- Turn off the engine
        -- Set N2 to zero
        local n2_target = get(IAS) > 50 and 10 + get(IAS)/10 + random_pool_3*2 or 0 -- In in-flight it rotates
        eng_N2_off[2] = Set_linear_anim_value(eng_N2_off[2], n2_target or 0 , 0, ENG.data.max_n2, 1)
        set(eng_N2_enforce, eng_N2_off[2], 2)
        
        -- Set EGT and FF to zero
        eng_EGT_off[2] = Set_linear_anim_value(eng_EGT_off[2], get(OTA), -50, 1500, eng_EGT_off[2] > 100 and 10 or 3)
        eng_FF_off[2] = 0
        eng_N1_off[2] = Set_linear_anim_value(eng_N1_off[2], 0, 0, ENG.data.max_n2, 2)
        set(eng_igniters, 0, 2)
        igniter_eng[2] = 0
    end

end

local function update_auto_start()
    if not slow_start_time_requested then
        return  -- auto start not requested
    end
 
    -- Turn on the batteries immediately and start the APU   
    ELEC_sys.batteries[1].switch_status = true
    ELEC_sys.batteries[2].switch_status = true

    set(eng_ignition_switch, 0, 1) 
    set(eng_ignition_switch, 0, 2) 

    if get(Apu_master_button_state) == 0 then
        sasl.commandOnce(APU_cmd_master)
    end
    if get(Apu_avail) == 0 and get(Apu_start_position) == 0 then
        sasl.commandOnce(APU_cmd_start)
    end
    if get(Apu_avail) == 1 then
        if get(Apu_bleed_xplane) == 0 then
            sasl.commandOnce(Toggle_apu_bleed)
        end

        set(Engine_mode_knob,1)
        set(Engine_2_master_switch, 1)
    end

    if get(Engine_2_avail) == 1 then
        set(Engine_1_master_switch, 1)
    end

    if get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1 then
        set(Engine_mode_knob, 0)
        slow_start_time_requested = false
    end

end

local function update_buttons_datarefs()
    pb_set(PB.ovhd.eng_man_start_1, eng_manual_switch[1])
    pb_set(PB.ovhd.eng_man_start_2, eng_manual_switch[2])
    pb_set(PB.ovhd.eng_dual_cooling, dual_cooling_switch)

    Set_dataref_linear_anim_nostop(Engine_1_master_switch_anim, get(Engine_1_master_switch), 0, 1, 10)
    Set_dataref_linear_anim_nostop(Engine_2_master_switch_anim, get(Engine_2_master_switch), 0, 1, 10)

    set(Eng_Dual_Cooling, dual_cooling_switch and 1 or 0)
end

local function update_time_since_shutdown()
    if get(Eng_1_EGT_c) < 100 then
        if time_last_shutdown[1] == 0 then
            time_last_shutdown[1] = get(TIME)
        end
    else
        cooling_has_cooled[1] = false
        cooling_left_time[1] = -1
        time_last_shutdown[1] = 0
    end 

    if get(Eng_2_EGT_c) < 100 then
        if time_last_shutdown[2] == 0 then
            time_last_shutdown[2] = get(TIME)
        end
    else
        cooling_has_cooled[2] = false
        cooling_left_time[2] = -1
        time_last_shutdown[2] = 0
    end 


end

local function update_continuous_ignition()
    -- Continuous ignition occurs in two cases:
    -- - Engine flameout
    -- - Manually move the mode selection to IGN but after start!

    local cond_1 = (get(Engine_1_master_switch) == 1 and get(Eng_is_failed, 1) == 1)
                or (get(Engine_2_master_switch) == 1 and get(Eng_is_failed, 2) == 1)
    
    local cond_2 = get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1 and get(Engine_mode_knob) == 1 and already_back_to_norm

    if get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1 and get(Engine_mode_knob) == 0 then
        already_back_to_norm = true
    elseif get(Engine_1_avail) == 0 or get(Engine_2_avail) == 0 then
        already_back_to_norm = false
    end
    
    set(Eng_Continuous_Ignition, (cond_1 or cond_2) and 1 or 0)
end

local function update_oil_qty()
    -- each engine consumes ~0.1 oil quantity each running hour
    local curr_oil = get(Eng_1_OIL_qty)
    curr_oil = curr_oil - ENG.data.oil.qty_consumption / 60 / 60 * get(DELTA_TIME) * get(Engine_1_avail)
    set(Eng_1_OIL_qty, curr_oil)

    local curr_oil = get(Eng_2_OIL_qty)
    curr_oil = curr_oil - ENG.data.oil.qty_consumption / 60 / 60 * get(DELTA_TIME) * get(Engine_2_avail)
    set(Eng_2_OIL_qty, curr_oil)

end

local function update_n1_mode_and_limits_per_engine(thr_pos, engine)

    local ai_wing_oper = get(AI_wing_L_operating) + get(AI_wing_R_operating) > 0
    local ai_eng_oper  = AI_sys.comp[ANTIICE_ENG_1].valve_status == true or AI_sys.comp[ANTIICE_ENG_2].valve_status == true 
    local pack_oper    = get(Pack_L) + get(Pack_R) > 0

    local reverse_forced_idle = get(Either_Aft_on_ground) == 0 or get(FAILURE_ENG_REV_FAULT, engine) == 1
    local emergency_force_idle = get(FAILURE_ENG_REV_UNLOCK, engine) == 1
    
    if emergency_force_idle then    -- If reverser unlock (failure), then the engine is auto put to idle
        set(Eng_N1_mode, 4, engine) -- IDLE
        return
    end

    if thr_pos > THR_TOGA_THRESHOLD + 0.001 or get(ATHR_is_overriding) == 1 then -- TOGA Region
    
        if thr_pos >= 0.99 and last_time_toga[engine] == 0 then
            -- This is needed for soft GA
            last_time_toga[engine] = get(TIME)
        end
        set(Eng_N1_mode, 1, engine) -- TOGA
    elseif thr_pos > THR_MCT_THRESHOLD + 0.001 then
    
        if get(Eng_N1_flex_temp) ~= 0 and get(EWD_flight_phase) >= PHASE_1ST_ENG_TO_PWR and get(EWD_flight_phase) <= PHASE_LIFTOFF then
            set(Eng_N1_mode, 6, engine) -- FLEX
    
        -- If the pilot moves the throttle from MCT to TOGA, and then from TOGA to SOFT GA in less
        -- than 3 seconds, then SOFT GA is enabled until it's back to TOGA or CLB
        -- Also, both engines must be available
        -- Further details here: https://safetyfirst.airbus.com/introduction-to-the-soft-go-around-function/
        elseif (get(Eng_N1_mode, engine) == 7 or get(TIME) - last_time_toga[engine] < 3) and get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1 then
            set(Eng_N1_mode, 7, engine) -- SOFT GA
            
            -- In this case we replace the MCT value
            set(Eng_N1_max_detent_mct, eng_N1_limit_ga_soft(get(OTA), get(TAT), get(Capt_Baro_Alt), pack_oper, ai_eng_oper, ai_wing_oper))
        else    -- otherwise is a normal MCT
            set(Eng_N1_mode, 2, engine) -- MCT
        end
        last_time_toga[engine] = 0
    elseif thr_pos >= THR_CLB_THRESHOLD then
        set(Eng_N1_mode, 3, engine) -- CLB
        last_time_toga[engine] = 0

        if get(All_on_ground) == 0 then
            set(Eng_N1_flex_temp, 0) -- Reset FLEX temp to avoid G/A triggering of FLEX or other situations
        end

    elseif thr_pos > -THR_CLB_THRESHOLD or reverse_forced_idle then   -- Reverse protection
        set(Eng_N1_mode, 4, engine) -- IDLE
        last_time_toga[engine] = 0
    elseif thr_pos <= -THR_CLB_THRESHOLD then
        set(Eng_N1_mode, 5, engine) -- MREV
        last_time_toga[engine] = 0
    end
    
end

local function update_n1_mode_and_limits()
    local ai_wing_oper = get(AI_wing_L_operating) + get(AI_wing_R_operating) > 0
    local ai_eng_oper  = AI_sys.comp[ANTIICE_ENG_1].valve_status == true or AI_sys.comp[ANTIICE_ENG_2].valve_status == true 
    local pack_oper    = get(Pack_L) + get(Pack_R) > 0

    -- The mode is selected by the highest throttle

    -- We have to compute all the values for each detent even if we are not in that mode, this is
    -- because in AT_PID_functions we have to compute the previous detent value to make the 
    -- throttle position monotonic and linearly increasing
    set(Eng_N1_max_detent_toga, eng_N1_limit_takeoff(get(OTA), get(TAT), get(Capt_Baro_Alt), pack_oper, ai_eng_oper, ai_wing_oper))
    set(Eng_N1_max_detent_mct, eng_N1_limit_mct(get(OTA), get(TAT), get(Capt_Baro_Alt), pack_oper, ai_eng_oper, ai_wing_oper))
    set(Eng_N1_max_detent_clb, eng_N1_limit_clb(get(OTA), get(TAT), get(Capt_Baro_Alt), pack_oper, ai_eng_oper, ai_wing_oper))
    set(Eng_N1_max_detent_flex, eng_N1_limit_flex(get(Eng_N1_flex_temp), get(OTA), get(Capt_Baro_Alt), pack_oper, ai_eng_oper, ai_wing_oper))
    

    update_n1_mode_and_limits_per_engine(get(Cockpit_throttle_lever_L), 1)
    update_n1_mode_and_limits_per_engine(get(Cockpit_throttle_lever_R), 2)
end

local function update_fadec_status()
    set(Eng_1_FADEC_powered, fadec_has_elec_power(1) and 1 or 0)
    set(Eng_2_FADEC_powered, fadec_has_elec_power(2) and 1 or 0)
end

local function update_spooling()
    set(Eng_spool_time, Math_rescale(19, 6, 101, 1.5, (get(Eng_1_N1)+get(Eng_2_N1))/2))
end

local function update_engine_type()
    if current_engine_id ~= get(Engine_option) then
        current_engine_id = get(Engine_option)
        if current_engine_id == 1 then
            configure_leap_1a()
        elseif current_engine_id == 2 then
            configure_pw1133g()
        else
            assert(false) -- Unknown engine?!
        end
        assert(ENG.data)    -- The engine should be correctly loaded now
        ENG.data_is_loaded = true

        set(Eng_1_OIL_qty, ENG.data.oil.qty_max*3/4 + ENG.data.oil.qty_max/4 * math.random())
        set(Eng_2_OIL_qty, ENG.data.oil.qty_max*3/4 + ENG.data.oil.qty_max/4 * math.random())

        
    end
    
end

local function update_failing_eng(x)
    local eng_ms    = (x == 1 and get(Engine_1_master_switch) or get(Engine_2_master_switch)) == 1
    local n2_below  = (x == 1 and get(Eng_1_N2) or get(Eng_2_N2)) < 62
    local not_avail = (x == 1 and get(Engine_1_avail) or get(Engine_2_avail)) == 0
    local eng_st    = already_started_eng[x]
    local no_fire_pb= (x == 1 and get(Fire_pb_ENG1_status) or get(Fire_pb_ENG2_status)) == 0

    if eng_ms and n2_below and eng_st and no_fire_pb and not_avail then
        set(Eng_is_failed, 1, x)
    end
    
    if not n2_below then
        already_started_eng[x] = true
        set(Eng_is_failed, 0, x)
    end

end
local function update_failing()
    
    if get(EWD_flight_phase) == 1 or get(EWD_flight_phase) == 10 then
        already_started_eng = {false, false}
    end
    
    update_failing_eng(1)
    update_failing_eng(2)
end

function update()
    perf_measure_start("engines:update()")
    
    update_engine_type()
    
    update_starter_datarefs()
    update_buttons_datarefs()
    
    update_avail()

    update_fadec_status()

    if get(FLIGHT_TIME) > 0.5 then
        -- This condition is needed because otherwise the startup overrides the values set by the
        -- engines_auto_quick_start() function when the simulation is started in flight. So, let's
        -- wait 500ms before allowing the startup sequence to work (I don't think you are so fast to
        -- turn the ignition knob and the master switch 500ms after the simulation is started ;-)
        update_startup()
    end


    update_n1_minimum()
    update_n2()
    update_spooling()
    update_egt()
    update_ff()
    update_oil_stuffs()
    update_vibrations()
    
    update_auto_start()
    update_time_since_shutdown()
    update_continuous_ignition()

    update_oil_qty()
    update_n1_mode_and_limits()
    update_failing()
    
    if get(TIME) - random_pool_update > 2 then
        random_pool_update = get(TIME)
        random_pool_1 = math.random()
        random_pool_2 = math.random()
        random_pool_3 = math.random()
    end
    
    perf_measure_stop("engines:update()")
end

-- The following code is used to check if SASL has been restarted with engines running
if get(Startup_running) == 1 and get(TIME) > 1 then
    engines_auto_quick_start(SASL_COMMAND_BEGIN)
end

