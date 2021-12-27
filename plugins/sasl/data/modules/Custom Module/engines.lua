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
include('engines/model/xp_interface.lua')

-- engine states, simple ones right now for debugging, introduced for more flexible abnormals later
-- TODO TBD use string values? --> NO! Use integers = faster
local FSM_SHUTDOWN = 1
local FSM_START_COOLING = 2
local FSM_START_PHASE_CRANK = 3
local FSM_START_PHASE_N2 = 4
local FSM_START_PHASE_N1 = 5

-- configurable initial cooling support for first startup
local COOLING_IDLE = 0
local COOLING_RUN = 1
local COOLING_DONE = 3
local initial_cooling_phase = {COOLING_IDLE,COOLING_IDLE}
local COOLING_N2_START = 7.2  -- N2 at which cooling timer countdown starts to run

local MAX_EGT_OFFSET = 10  -- This is the maximum offset between one engine and the other in terms of EGT
local ENG_N2_CRANK_MARGIN = 9.5  -- N2 below which cranking is assumed in startup
local ENG_N2_LOW_CRANK = 10  -- N2 used for cranking and cooling
local ENG_N2_FULL_CRANK = 32 -- N2 used for full cranking on hot / hung start
local ENG_N1_CRANK_FF = 15  -- FF in case of wet cranking
local ENG_N1_CRANK_EGT= 95  -- Target EGT for cranking
local ENG_N1_LL_IDLE  = 18.3 -- above this value some params like FF will be provided by X-Plane
local N1_INC_AI_ENG   = 1    -- Increase of minimum N1 if at least one ENG Anti-ice is activated
local N1_INC_AI_WING  = 0.8  -- Increase of minimum N1 if per activated WING Anti-ice TBC

local current_engine_id = 0  -- Just to check which is the current engine

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

-- Since random parameters are quite stable, we update the pool of randomness every 2 seconds
local random_pool_1 = 0
local random_pool_2 = 0
local random_pool_3 = 0
local random_pool_update = 0

-- higher frequency random pool
local random_pool_hf = 0
local random_pool_hf_update = 0

local egt_eng_1_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values
local egt_eng_2_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values

local eng_manual_switch = {false,false}   -- Is engine manual start enabled?
local dual_cooling_switch = false

local eng_N1_off  = {0,0}   -- N1 for startup procedure, off means here: engine not yet available TODO rename to starting?
local eng_N2_off  = {0,0}   -- N2 for startup procedure
local eng_FF_off  = {0,0}   -- FF for startup procedure
local EGT_MAGIC = -999
local eng_EGT_off = {EGT_MAGIC,EGT_MAGIC}  -- used during startup and shutdown, initialized with magic number for auto start support

local slow_start_time_requested = false
local igniter_eng = {0,0}
local starter_valve_eng = {0,0}
local windmill_min_speed = {250 + math.random()*30, 250 + math.random()*30}

-- Engine startup cooling stuffs
local COOLING_REQUIRED_MAGIC = -1
local time_last_shutdown = {-1,-1}    -- The last time point you shutdown the engines (-1 or 0 = invalid data)
local cooling_left_time  = {0, 0}
local cooling_has_cooled = {false, false}

local already_back_to_norm = false -- This is used to check continuous ignition

local time_current_startup = { -1, -1}  -- time current engine start attempt has been made, resetted on shutdown
local last_time_toga = {0,0} -- Time point where thrust levers are set to TOGA

local already_started_eng = {false, false}

local oil_gulp_timer = {0,0}  -- for timer based oil gulping implementation
local initial_oil_qty = {0,0} -- initial oil qty on engine start
local used_oil_qty = {0,0}    -- oil qty used during last engine run to update initial_oil_qty

----------------------------------------------------------------------------------------------------
-- Engine dynamics state
----------------------------------------------------------------------------------------------------

local function engine_create_state()
    return  {   n1=0,                   -- N1   [%] -- Use ENG.data.fan_n1_rpm_max to get RPM
                n2=0,                   -- N2   [%]
                nfan=0,                 -- NFAN [%] -- Use ENG.data.fan_n1_rpm_max to get RPM (use N1 really!)
                egt=0,                  -- EGT  [°C]
                ff=0,                   -- Fuel flow [kg/s] (not /hour!) 
                oil_qty=0,              -- Oil qty [oil units (see fcom)]
                oil_press=0,            -- Oil Pressure [psi]
                oil_temp=get(OTA),      -- Oil Temperature [°C]
                vib_n1=0,               -- Vibration of N1 stage [see fcom]
                vib_n2=0,               -- Vibration of N1 stage [see fcom]
                is_fadec_pwrd=false,    -- Is FADEC on?    
                n1_idle=0,              -- Value for N1 idle [%]
                n1_mode=0,              -- Current N1 mode for displaying AND N1 computation 
                                        -- 0: not visible, 1: TOGA, 2:MCT, 3:CLB, 4: IDLE, 5: MREV, 6: FLEX, 7: SOFT GA
                firewall_valve=1,       -- Status of the firewall valve
                                        -- 0 open, 1 - closed, 2 : transit - firewall valve
                cranking=false,         -- Is engine cranking?
                starter_valve=false,    -- Is the bleed starting valve open?
                start_fsm_state=0,      -- Status of the FSM for the startup procedure (see above FSM_* constants)
                is_failed=false,        -- Is engine in failed condition?
                is_avail=false          -- Is up and running?
            }
end

ENG.dyn = {
    engine_create_state(),
    engine_create_state()
}

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
        -- in case we had a previous A/C load with manual startup there might be a value in this vars which lead to jump in EGT cooldown
        -- so we have to init it here again after auto startup has been performed
        eng_EGT_off[1] = EGT_MAGIC
        eng_EGT_off[2] = EGT_MAGIC

        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
        set(Engine_mode_knob, 0)
        -- since oil temp changes slowly in autostart we need to set a initial temp
        ENG.dyn[1].oil_temp = 60
        ENG.dyn[2].oil_temp = 60

        local always_a_minimum = ENG_N1_LL_IDLE + 0.2 -- regardless altitude and anti-ice N1 of running engine can never be lower
        if not ENG.data then
            update_engine_type()
        end
        eng_model_enforce_n1(1, always_a_minimum)
        eng_model_enforce_n1(2, always_a_minimum)
    
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
    -- TODO engine type based cooling time requirements
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
        -- more than 2 hours cooling does not require any cooling on startup 
        return 0
    end

    return Math_clamp(time_cool, 0, 90) -- limit from direct start to 90 seconds cooling max  TODO engine type specific values
end

local function min_n1(altitude)
    return 5.577955*math.log(0.03338352*altitude+23.66644)+1.724586
end

local function update_n1_minimum()
    -- WARNING! Mininmum N1 affects the controllers and the engine model, pay attention!

    local curr_altitude = get(Elevation_m) * 3.28084
    local comp_min_n1 = min_n1(curr_altitude) 
                      + ((AI_sys.comp[ANTIICE_ENG_1].valve_status
                          or AI_sys.comp[ANTIICE_ENG_2].valve_status) and N1_INC_AI_ENG or 0)
    comp_min_n1 = comp_min_n1 + (AI_sys.comp[ANTIICE_WING_L].valve_status and N1_INC_AI_WING or 0) + (AI_sys.comp[ANTIICE_WING_R].valve_status and N1_INC_AI_WING or 0)

    local curr_n1_idle_base = get(Eng_N1_idle)
    local curr_n1_idle_L = get(Eng_N1_bleed_corrected_idle,1)
    local curr_n1_idle_R = get(Eng_N1_bleed_corrected_idle,2)

    -- read-out takes place in autothrust pid logic get_N1_target (AT_PID_functions)
    set(Eng_N1_idle, curr_n1_idle_base)-- TODO speed of animation? depend of delta?

    -- TODO pack configuration has to be considered for N1 as well in combination of engine bleed availability and x-bleed
    if (get(ENG_1_bleed_switch) == 0 or get(ENG_2_bleed_switch) == 0)
            and get(Pack_L)==1 and get(Pack_R) == 1
            and get(X_bleed_valve) == 1 then
        comp_min_n1 = comp_min_n1 + 9.3
        if get(ENG_1_bleed_switch) == 0 then
            -- animation is used to avoid blue circle jump in EWD when switching bleed config
            set(Eng_N1_bleed_corrected_idle,Set_linear_anim_value(curr_n1_idle_R,comp_min_n1,0,100,1.5),2) -- demand increase is on opposite engine
            set(Eng_N1_bleed_corrected_idle,Set_linear_anim_value(curr_n1_idle_L,comp_min_n1-1.9,0,100,1),1) -- imbalance prevention
        else
            set(Eng_N1_bleed_corrected_idle,Set_linear_anim_value(curr_n1_idle_R,comp_min_n1-1.9,0,100,1),2) -- demand increase is on opposite engine
            set(Eng_N1_bleed_corrected_idle,Set_linear_anim_value(curr_n1_idle_L,comp_min_n1,0,100,1.5),1) -- imbalance prevention
        end
    else
        -- both engines bleeding TODO imbalance is possible here under various circumstances as well, TODO animation
        set(Eng_N1_bleed_corrected_idle,comp_min_n1,1)
        set(Eng_N1_bleed_corrected_idle,comp_min_n1,2)
    end

    local always_a_minimum = ENG_N1_LL_IDLE + 0.2 -- regardless altitude and anti-ice N1 of running engine can never be lower

    -- Update ENG1 N1 minimum
    local curr_n1 = ENG.dyn[1].n1
    if curr_n1 < always_a_minimum and ENG.dyn[1].is_avail then
        eng_model_enforce_n1(1, always_a_minimum)
    end

    -- Update ENG2 N1 minimum
    curr_n1 = ENG.dyn[2].n1
    if curr_n1 < always_a_minimum and ENG.dyn[2].is_avail then
        eng_model_enforce_n1(2, always_a_minimum)
    end
end

local function update_n2()
    local eng_1_n1 = ENG.dyn[1].n1
    if eng_1_n1 > 5 and get(Engine_1_master_switch) == 1  then
        ENG.dyn[1].n2 = Set_linear_anim_value(ENG.dyn[1].n2, eng_model_get_N2(1), 0, 130, 10)
    else
        ENG.dyn[1].n2 = Set_linear_anim_value(ENG.dyn[1].n2, eng_N2_off[1], 0, 130, 10)
    end

    local eng_2_n1 = ENG.dyn[2].n1
    if eng_2_n1 > 5 and get(Engine_2_master_switch) == 1  then
        ENG.dyn[2].n2 = Set_linear_anim_value(ENG.dyn[2].n2, eng_model_get_N2(2), 0, 130, 10)
    else
        ENG.dyn[2].n2 = Set_linear_anim_value(ENG.dyn[2].n2, eng_N2_off[2], 0, 130, 10)
    end

end

local function update_nfan()
    ENG.dyn[1].nfan = eng_model_get_NFAN(1)
    ENG.dyn[2].nfan = eng_model_get_NFAN(2)
end


local function update_egt()
    local eng_1_n1 = ENG.dyn[1].n1
    if eng_1_n1 > ENG_N1_LL_IDLE then
        -- engine avail, also in the first phase of shutdown, since N1 then is about 1% above IDLE constant
        local computed_egt = ENG.data.n1_to_egt_fun(eng_1_n1, get(OTA))
        computed_egt = computed_egt * (1 + get(FAILURE_ENG_STALL, 1) * get(eng_1_n1)/90 * math.random())
        computed_egt = computed_egt + egt_eng_1_offset + random_pool_1*2 -- Let's add a bit of randomness
        ENG.dyn[1].egt = Set_linear_anim_value(ENG.dyn[1].egt, computed_egt, -50, 1500, 70)
    else
        -- engine off, starting or shutting down
        -- TODO switching to this else branch lead to small jump to higher EGT value (about 30-40 °C) if no auto-start
        -- last eng_EGT_off value seems to be from last row of startup.n1 table currently
        local current_egt = ENG.dyn[1].egt
        if eng_EGT_off[1] > current_egt and get(Engine_1_master_switch) == 0 then eng_EGT_off[1] = current_egt end  -- workaround to avoid jump up
        if current_egt == EGT_MAGIC then
            ENG.dyn[1].egt = get(OTA)
        else
            ENG.dyn[1].egt = eng_EGT_off[1]
        end
    end

    local eng_2_n1 = ENG.dyn[2].n1
    if eng_2_n1 > ENG_N1_LL_IDLE then
        local computed_egt = ENG.data.n1_to_egt_fun(eng_2_n1, get(OTA))
        computed_egt = computed_egt * (1 + get(FAILURE_ENG_STALL, 2) * get(eng_1_n1)/90 * math.random())
        computed_egt = computed_egt + egt_eng_2_offset + random_pool_2*2 -- Let's add a bit of randomness
        ENG.dyn[2].egt = Set_linear_anim_value(ENG.dyn[2].egt, computed_egt, -50, 1500, 70)
    else
        local current_egt = ENG.dyn[2].egt
        if eng_EGT_off[2] > current_egt and get(Engine_2_master_switch) == 0  then eng_EGT_off[2] = current_egt end -- workaround to avoid jump up
        if current_egt == EGT_MAGIC then
            ENG.dyn[2].egt = get(OTA) -- display OAT in case A/C has just been initialized
        else
            ENG.dyn[2].egt = eng_EGT_off[2]
        end
    end

end

local function update_ff()
    local eng_1_n1 = ENG.dyn[1].n1
    if eng_1_n1 > ENG_N1_LL_IDLE then
        -- when engines are avail, use fuel flow from X-Plane
        ENG.dyn[1].ff = eng_model_get_FF(1)
    else
        -- during startup use our fuel flow values
        ENG.dyn[1].ff = eng_FF_off[1]
    end

    local eng_2_n1 = ENG.dyn[2].n1
    if eng_2_n1 > ENG_N1_LL_IDLE then
        ENG.dyn[2].ff = eng_model_get_FF(2)
    else
        ENG.dyn[2].ff = eng_FF_off[2]
    end
 
end

local function update_avail()

    
    local eng_has_fuel = get(Fuel_tank_selector_eng_1) > 0

    -- ENG 1
    if ENG.dyn[1].n1 > ENG_N1_LL_IDLE and get(Engine_1_master_switch) == 1 and eng_has_fuel and get(FAILURE_ENG_1_FAILURE) == 0 then
        if not ENG.dyn[1].is_avail then
            set(EWD_engine_avail_ind_start, get(TIME), 1)
            ENG.dyn[1].is_avail = true
        end
    else
        ENG.dyn[1].is_avail = false
        set(EWD_engine_avail_ind_start, 0, 1)
    end

    local eng_has_fuel = get(Fuel_tank_selector_eng_2) > 0
    
    -- ENG 2
    if ENG.dyn[2].n1 > ENG_N1_LL_IDLE and get(Engine_2_master_switch) == 1 and eng_has_fuel and get(FAILURE_ENG_2_FAILURE) == 0 then
        if not ENG.dyn[2].is_avail then
            set(EWD_engine_avail_ind_start, get(TIME), 2)
            ENG.dyn[2].is_avail = true
        end
    else
        ENG.dyn[2].is_avail = false
        set(EWD_engine_avail_ind_start, 0, 2)
    end

    
end

----------------------------------------------------------------------------------------------------
-- Functions - Secondary parameters
----------------------------------------------------------------------------------------------------

local function update_oil_temp_and_press()

    -- ENG 1 - PRESS
    if ENG.dyn[1].is_avail then
        local n2_value = ENG.dyn[1].n2
        local press = Math_rescale(60, ENG.data.oil.pressure_min_idle+1, ENG.data.max_n2-10, ENG.data.oil.pressure_max_mct, n2_value)
        
        if get(FAILURE_ENG_LEAK_OIL, 1) == 1 then   -- OIL is leaking from engine T_T
            ENG.dyn[1].oil_press = Set_linear_anim_value(ENG.dyn[1].oil_press, 0, 0, 500, 0.75 - 0.25 * press / ENG.data.oil.pressure_max_mct )
        else
            ENG.dyn[1].oil_press = Set_linear_anim_value(ENG.dyn[1].oil_press, press, 0, 500, 28 + random_pool_3 * 4)
        end
    else
        -- During startup after cranking (N2 10) no pressure until >10, N2 IDLE is about 60 so where is this 70 from?
        local n2_value = math.max(10,ENG.dyn[1].n2)
        local press = Math_rescale(10, 0, 70, ENG.data.oil.pressure_max_toga, n2_value)
        ENG.dyn[1].oil_press = Set_linear_anim_value(ENG.dyn[1].oil_press, press, 0, 500, 28 + random_pool_1 * 4)
    end

    -- ENG 1 - TEMP
    -- TODO oil temp increase/decrease is much slower, exception possibly failure situation
    if ENG.dyn[1].is_avail then
        -- temperature depends mainly on N2. At 60% N2 normal temp acc CAE sim is sustained about 65°C at 15° OAT
        local n2_value = ENG.dyn[1].n2
        local temp = Math_rescale(60, 65, ENG.data.max_n2, ENG.data.oil.temp_max_mct, n2_value) + random_pool_2 * 5 + get(FAILURE_ENG_OIL_HI_TEMP, 1) * 70
        ENG.dyn[1].oil_temp = Set_linear_anim_value(ENG.dyn[1].oil_temp, temp, -50, 250, 0.18 + get(FAILURE_ENG_OIL_HI_TEMP, 1)*2)
    else
        -- During startup or shutdown
        local n2_value = math.max(10,ENG.dyn[1].n2)
        local temp = Math_rescale(10, get(OTA), 70, 75, n2_value)
        ENG.dyn[1].oil_temp = Set_linear_anim_value(ENG.dyn[1].oil_temp, temp, -50, 250, 0.18)
    end
    
    -- ENG 2 - PRESS
    if ENG.dyn[2].is_avail then
        local n2_value = ENG.dyn[2].n2
        local press = Math_rescale(60, ENG.data.oil.pressure_min_idle+1, ENG.data.max_n2-10, ENG.data.oil.pressure_max_mct, n2_value)
        if get(FAILURE_ENG_LEAK_OIL, 2) == 1 then   -- OIL is leaking from engine T_T
            ENG.dyn[2].oil_press = Set_linear_anim_value(ENG.dyn[2].oil_press, 0, 0, 500, 0.75 - 0.25 * press / ENG.data.oil.pressure_max_mct )
        else
            ENG.dyn[2].oil_press = Set_linear_anim_value(ENG.dyn[2].oil_press, press, 0, 500, 28 + random_pool_2 * 4)
        end
    else
        -- During startup or shutdown
        local n2_value = math.max(10,ENG.dyn[2].n2)
        local press = Math_rescale(10, 0, 70, ENG.data.oil.pressure_max_toga, n2_value)
        ENG.dyn[2].oil_press = Set_linear_anim_value(ENG.dyn[2].oil_press, press, 0, 500, 28 + random_pool_3 * 4)
    end

    -- ENG 2 - TEMP
    if ENG.dyn[2].is_avail then
        local n2_value = ENG.dyn[2].n2
        local temp = Math_rescale(60, 65, ENG.data.max_n2, ENG.data.oil.temp_max_mct, n2_value) + random_pool_1 * 5 + get(FAILURE_ENG_OIL_HI_TEMP, 2) * 70
        ENG.dyn[2].oil_temp = Set_linear_anim_value(ENG.dyn[2].oil_temp, temp, -50, 250, 0.18 + get(FAILURE_ENG_OIL_HI_TEMP, 2)*2)
    else
        -- During startup or shutdown
        local n2_value = math.max(10,ENG.dyn[2].n2)
        local temp = Math_rescale(10, get(OTA), 70, 75, n2_value)
        ENG.dyn[2].oil_temp = Set_linear_anim_value(ENG.dyn[2].oil_temp, temp, -50, 250, 0.18)
    end


end

function update_vibrations()
    local n1_value = ENG.dyn[1].n1
    local vib_n1 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n1_nominal/4, n1_value) 
    if ENG.dyn[1].is_avail then vib_n1 = vib_n1 + 0.1*random_pool_3 end
    ENG.dyn[1].vib_n1 = vib_n1

    local n2_value = ENG.dyn[1].n2
    local vib_n2 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n2_nominal/4, n2_value)
    if ENG.dyn[1].is_avail then vib_n2 = vib_n2 + 0.1*random_pool_2 end
    ENG.dyn[1].vib_n2 = vib_n2

    local n1_value = ENG.dyn[2].n1
    local vib_n1 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n1_nominal/4, n1_value)
    if ENG.dyn[2].is_avail then vib_n1 = vib_n1 + 0.1*random_pool_1 end
    ENG.dyn[2].vib_n1 = vib_n1

    local n2_value = ENG.dyn[2].n2
    local vib_n2 = Math_rescale(0, 0, ENG.data.max_n2, ENG.data.vibrations.max_n2_nominal/4, n2_value)
    if ENG.dyn[2].is_avail then vib_n2 = vib_n2 + 0.1*random_pool_3 end
    ENG.dyn[2].vib_n2 = vib_n2


end 

----------------------------------------------------------------------------------------------------
-- Functions - Ignition stuffs
----------------------------------------------------------------------------------------------------
-- TODO we need to differentiate between full and low crank (cooling)
local function perform_crank_procedure(eng, wet_cranking)
    -- This is PHASE 1 which will be called during startup as long N2 is below ENG_N2_CRANK_MARGIN
    set(Eng_fsm_state, FSM_START_PHASE_CRANK, eng)

    if (eng==1 and ENG.dyn[1].is_avail) or (eng==2 and ENG.dyn[2].is_avail) then
        -- Just for precaution, crank has no sense if the engine is already running
        -- In chase, just don't do anything
        return
    end
    
    -- Crank doesn't do anything special. Just warm up and run the N2 turbine

    -- Set N2 for cranking

    local starting_duration = get(TIME)- time_current_startup[eng]

    local target_n2
    if starting_duration < 3.82 then
        target_n2 = 0   -- polynomal will return negative values below that
    elseif starting_duration > 35 then
        target_n2 = ENG_N2_LOW_CRANK - random_pool_hf * 0.4
    else
        target_n2 = ENG.data.n2_spoolup_fun(starting_duration)  -- this is ok only for low cranking
    end
    eng_N2_off[eng] = Set_linear_anim_value(eng_N2_off[eng], target_n2, 0, ENG.data.max_n2, 70)
    
    -- Handle  EGT during cranking
    -- during initial startup we MUST use OAT as target EGT here, otherwise EGT will increase without FF
    -- when in a hot restart situation where EGT is still above OAT we decrease to OAT TODO what in high altitudes with big delta t?
    local oat = get(OTA)
    if  eng_EGT_off[eng] > oat then
        eng_EGT_off[eng] = Set_linear_anim_value(eng_EGT_off[eng], oat, -50, 1500, 2) -- TODO speed depends on delta t?
    end
    set(Eng_is_spooling_up, 1, eng) -- Need for bleed air computation, see packs.lua
    
    if wet_cranking then
        -- Wet cranking requested, let's spill a bit of fuel
        -- This is not actually consuming fuel but well, it's a minimum amount
        eng_FF_off[eng] = ENG_N1_CRANK_FF/3600
    else
        -- Dry cranking
        eng_FF_off[eng] = 0
    end
    starter_valve_eng[eng] = 1 -- during cranking the starter valve is open
end

local function perform_starting_procedure_follow_n2(eng)
    -- This is PHASE 2 after spool-up / cranking

    local oat = get(OTA)
    set(Eng_fsm_state, FSM_START_PHASE_N2, eng)

    if igniter_eng[eng] == 0 and not eng_manual_switch[eng] and eng_N2_off[eng] > ENG.data.startup.ign_on_n2 then
        igniter_eng[eng] = math.random() > 0.5 and 1 or 2  -- For ECAM visualization only, no practical effect
        starter_valve_eng[eng] = 1
    elseif eng_manual_switch[eng] then
        igniter_eng[eng] = 3  -- Manual start uses both igniters
        starter_valve_eng[eng] = 1 -- TODO is valve open on manual start?
    end

    set(Eng_is_spooling_up, 1, eng) -- Need for bleed air computation, see packs.lua, TODO bleed PSI seems to be to high currently
    
    for i=1,(#ENG.data.startup.n2-1) do
        -- For each phase... 

        if eng_N2_off[eng] < ENG.data.startup.n2[i+1].n2_start then
            -- We have found the correct phase
            
            -- Let's set the fuel flow
            eng_FF_off[eng] = ENG.data.startup.n2[i].fuel_flow  / 3600
            
            local eng_has_fuel = (eng==1 and get(Fuel_tank_selector_eng_1)>0) or (eng==2 and get(Fuel_tank_selector_eng_2)>0)
            
            -- If we are on manual start, the master switch  may not be on. In this case case let's check
            -- it before injecting fuel
            local eng_manual_start_continue = ((eng == 1 and get(Engine_1_master_switch) == 1) or (eng == 2 and get(Engine_2_master_switch) == 1))
            local fuelflow = eng_FF_off[eng]

            if fuelflow == 0 or (eng_has_fuel and eng_manual_start_continue)  then

                -- We continue the starting procedure if: the FF is still 0, so we are spinning up with bleed
                -- OR the FF > 0 and there is fuel and the engine master switch has been moved to ON

                -- Let's compute the new N2
                eng_N2_off[eng] = eng_N2_off[eng] + ENG.data.startup.n2[i].n2_increase_per_sec * get(DELTA_TIME)
                    
                -- And let's compute the EGT based on percent of progress in phase TODO separate engine type specific EGT, e.g. EGT drop as of PW SIL 013
                perc = (eng_N2_off[eng] - ENG.data.startup.n2[i].n2_start) / (ENG.data.startup.n2[i+1].n2_start - ENG.data.startup.n2[i].n2_start)
                if fuelflow > 0 then
                    -- increase EGT only if fuel is flowing
                    local egt =  Math_lerp(ENG.data.startup.n2[i].egt, ENG.data.startup.n2[i+1].egt, perc)
                    eng_EGT_off[eng] = egt > oat and egt or oat -- egt is never below OAT
                end

            else
                eng_FF_off[eng] = 0 -- no fuel available
            end
            break -- Don't need to check the other phases
        end

    end
end

local function perform_starting_procedure_follow_n1(eng)
    -- This is PHASE 3
    set(Eng_fsm_state, FSM_START_PHASE_N1,eng)

    for i=1,(#ENG.data.startup.n1-1) do
        -- For each phase...
        
        -- Get the current N1, but it can't be zero 
        local curr_N1 = math.max(math.max(eng_N1_off[eng],2), Eng.dyn[eng].n1)
        
        if curr_N1 < ENG.data.startup.n1[i+1].n1_set then
            -- We have found the correct row in phase table

            -- Let's set the fuel flow
            eng_FF_off[eng] = ENG.data.startup.n1[i].fuel_flow  / 3600
            
            local eng_has_fuel = (eng==1 and get(Fuel_tank_selector_eng_1)>0) or (eng==2 and get(Fuel_tank_selector_eng_2)>0)
            
            if eng_FF_off[eng] == 0 or eng_has_fuel then
            
                -- Let's compute the new N2
                local new_N1 = curr_N1 + ENG.data.startup.n1[i].n1_increase_per_sec * get(DELTA_TIME)
                eng_N1_off[eng] = new_N1
                eng_model_enforce_n1(eng, new_N1)
                
                -- Let's compute the EGT
                perc = (curr_N1 - ENG.data.startup.n1[i].n1_set) / (ENG.data.startup.n1[i+1].n1_set - ENG.data.startup.n1[i].n1_set)
                eng_EGT_off[eng] = Math_lerp(ENG.data.startup.n1[i].egt, ENG.data.startup.n1[i+1].egt, perc)
            else
                eng_FF_off[eng] = 0
            end
            break -- Don't need to check the other phases
        end
    end

    -- Caution: eng_N2_off[] is not updated in the follow_n1 phase N2 is calculated in update_n2 function
    local eng_N2 = eng == 1 and ENG.dyn[1].n2 or ENG.dyn[2].n2
    if igniter_eng[eng] > 0 and eng_N2 > ENG.data.startup.ign_off_n2 then
        igniter_eng[eng] = 0
    end

    if eng_N2 > ENG.data.startup.sav_close_n2 then  -- SAV close at a slightly different point in time than IGN off
        starter_valve_eng[eng] = 0
    end
end

local function perform_starting_procedure(eng, inflight_restart)
    -- Note: startup-procedure is only called when cooling has been already done or not required

    if eng_N2_off[eng] < ENG_N2_CRANK_MARGIN and not inflight_restart then
        -- Phase 1: Ok let's start by cranking the engine to start rotation
        perform_crank_procedure(eng, false)
        return
    end
    
    if inflight_restart and eng_N2_off[eng] < ENG.data.startup.n2[#ENG.data.startup.n2].n2_start then
        -- v is different, let's skip the first phase
        eng_N2_off[eng] = ENG.data.startup.n2[#ENG.data.startup.n2].n2_start
        eng_N1_off[eng] = Eng.dyn[eng].n1
    end
    
    -- If the N2 powered by bleed so far is larger than 10, then we can start the real startup procedure
    if eng_N2_off[eng] < ENG.data.startup.n2[#ENG.data.startup.n2].n2_start and not inflight_restart then  -- 1st phase, but not inflight_restart
        -- Phase 2: Controlling the N2  
        perform_starting_procedure_follow_n2(eng)
        
    elseif eng_N1_off[eng] < ENG.data.startup.n1[#ENG.data.startup.n1].n1_set and get(FAILURE_ENG_HUNG_START, eng) == 0 then
        -- Phase 3: Controlling the N1
        --   in a ENG_HUNG_START failure, N2 will stay at the last entry of N2 startup table with N1 following N2
        -- TODO more realistic ENG_HUNG_START: N2 will slowly increase and not stay constant, full cranking at ~30% N2, IGN off while cranking, auto restart attempt
        --   and then exceeding startup timeout will eventually trigger ECAM
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

    set(Eng_starter_valve_open, starter_valve_eng[1],1)
    set(Eng_starter_valve_open, starter_valve_eng[2],2)

    -- TODO for how long bleed air consumption will be influenced? Why is spooling up resetted here?
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


local function needs_cooling(eng)
    if not ENG.data.has_cooling then return false end
    -- TODO do we want a cooling period in that case based on some condition like power availability?

    if time_last_shutdown[eng] <= 0 then
        -- engine never started before

        if initial_cooling_phase[eng] == COOLING_RUN then -- in cooling phase
            return true
        elseif get(ENG_config_cooling_time) == 0  or initial_cooling_phase[eng] == COOLING_DONE then -- cooling done
            return false
        elseif get(ENG_config_cooling_time) ~= 0 and initial_cooling_phase[eng] == COOLING_IDLE then
            initial_cooling_phase[eng] = COOLING_RUN
            cooling_left_time[eng] = COOLING_REQUIRED_MAGIC -- force cooling
        else
        end
    end

    -- start cooling timer
    if cooling_left_time[eng] == COOLING_REQUIRED_MAGIC and not cooling_has_cooled[eng] then
        if initial_cooling_phase[eng] == COOLING_IDLE or initial_cooling_phase[eng] == COOLING_DONE then
            -- when engine has been shutdown before than use calculated time regardless configured initial cooling time
            time_req = cooling_time(get(TIME) - time_last_shutdown[eng])
        else
            time_req = get(ENG_config_cooling_time)
            -- initial_cooling_phase[eng] = false  -- should be set to false after cooldown
        end
        if time_req == 0 then
            return false
        end
        cooling_left_time[eng] = time_req -- initialize cooling timer
        return true
    end

    return not cooling_has_cooled[eng]  -- this is set after one cooling only ...
end

local function perform_cooling(eng)
    set(Eng_fsm_state,FSM_START_COOLING,eng)
    if cooling_left_time[eng] == 0 then
        cooling_has_cooled[eng] = true
        initial_cooling_phase[eng] = COOLING_DONE
        return
    end
    -- cooling is achieved by dry cranking driven by bleed air
    perform_crank_procedure(eng, false)
    -- cooling starts at certain N2 when spooling up
    if (eng_N2_off[eng] >= COOLING_N2_START) then
        -- This is the actual cooling timer countdown
        cooling_left_time[eng] = math.max(0, cooling_left_time[eng] - get(DELTA_TIME))
    end
    -- also update value displayed in EWD
    set(EWD_engine_cooling_time, cooling_left_time[eng], eng)

    -- TODO after timer is 0:00, COOLING without timer is displayed about 1-5 seconds in EWD (SW version dependent)
    
end


local function update_startup()

    if ENG.dyn[1].is_avail and ENG.dyn[2].is_avail then return end

    -- An array we need later to see if the engine requires cooldown (=shutdown) or not
    local require_cooldown = {true, true}

    local windmill_condition_1 = get(IAS) > windmill_min_speed[1]
    local windmill_condition_2 = get(IAS) > windmill_min_speed[2]
    
    -- When the pilot moves very fast master switch ON -> OFF -> ON
    local fast_restart_1 = ENG.dyn[1].n1 > 25
    local fast_restart_2 = Eng.dyn[2].n1 > 25

    local eng_1_air_cond = (get(L_bleed_press) > 10 or windmill_condition_1 or fast_restart_1)
    local eng_2_air_cond = (get(R_bleed_press) > 10 or windmill_condition_2 or fast_restart_2)
    local does_engine_1_can_start_or_crank = not ENG.dyn[1].is_avail and eng_1_air_cond and ENG.dyn[1].is_fadec_pwrd == 1 and math.abs(get(Cockpit_throttle_lever_L)) < 0.05
    local does_engine_2_can_start_or_crank = not ENG.dyn[2].is_avail and eng_2_air_cond and ENG.dyn[2].is_fadec_pwrd == 1 and math.abs(get(Cockpit_throttle_lever_R)) < 0.05

    if get(FAILURE_ENG_FADEC_CH1, 1) == 1 and get(FAILURE_ENG_FADEC_CH2, 1) == 1 then
        does_engine_1_can_start_or_crank = false -- No fadec? No start
    end

    if get(FAILURE_ENG_FADEC_CH1, 2) == 1 and get(FAILURE_ENG_FADEC_CH2, 2) == 1 then
        does_engine_2_can_start_or_crank = false -- No fadec? No start
    end

    -- don't show cooling indicators
    set(EWD_engine_cooling, 0, 1)
    set(EWD_engine_cooling, 0, 2)

    -- CASE 1: IGNITION
    if get(Engine_mode_knob) == 1 then

        -- ENG 1
        if (eng_manual_switch[1] or get(Engine_1_master_switch) == 1) and does_engine_1_can_start_or_crank then

            if time_current_startup[1] == -1 then
                time_current_startup[1] = get(TIME)
            end
            -- Is cooling required before ignition?
            if get(Any_wheel_on_ground) == 1 and needs_cooling(1) then
                set(EWD_engine_cooling, 1, 1) -- TODO adjust visibility of COOOLING in EWD...
                perform_cooling(1)

                -- Dual cooling - show EWD TIMER even if Master switch is off for that ENG
                if dual_cooling_switch and needs_cooling(2) and get(Engine_2_master_switch) == 0 then
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
            if time_current_startup[2] == -1 then
                time_current_startup[2] = get(TIME)
            end

            -- Is cooling required before ignition?
            if get(Any_wheel_on_ground) == 1 and needs_cooling(2) then
                set(EWD_engine_cooling, 1, 2)
                perform_cooling(2)

                -- Dual cooling - show EWD TIMER even if Master switch is off for that ENG
                if dual_cooling_switch and needs_cooling(1) and get(Engine_1_master_switch) == 0 then
                    set(EWD_engine_cooling, 1, 1)
                    perform_cooling(1)
                    require_cooldown[1] = false
                end
            else
                perform_starting_procedure(2, get(All_on_ground) == 0)
            end
            require_cooldown[2] = false
        end
        
    -- CASE 2: manually selected CRANK
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
        if not ENG.dyn[1].is_avail and fast_restart_1 and get(Engine_1_master_switch) then
            perform_starting_procedure(1, get(All_on_ground) == 0)
            require_cooldown[1] = false
        end
        if not ENG.dyn[2].is_avail and fast_restart_2 and get(Engine_2_master_switch) then
            perform_starting_procedure(2, get(All_on_ground) == 0)
            require_cooldown[2] = false
        end
    end
    
    -- CASE 3: No ignition, no crank, engine is off or shutting down
    if not ENG.dyn[1].is_avail  and require_cooldown[1] then    -- Turn off the engine TODO better use a state shutdown
        set(Eng_fsm_state,FSM_SHUTDOWN,1)
        -- Set N2 to zero
        local n2_target = get(IAS) > 50 and 10 + get(IAS)/10 + random_pool_1*2 or 0 -- In in-flight it rotates
        eng_N2_off[1] = Set_linear_anim_value(eng_N2_off[1], n2_target, 0, ENG.data.max_n2, 1)
        
        -- Set FF to zero, drop EGT and N1 TODO check drop behavior based on SIM videos
        if eng_EGT_off[1] == EGT_MAGIC then eng_EGT_off[1] = ENG.dyn[1].egt end -- otherwise in auto start case we will have a big jump since eng_EGT_off is not set before
        eng_EGT_off[1] = Set_linear_anim_value(eng_EGT_off[1], get(OTA), -50, 1500, eng_EGT_off[1] > 100 and 10 or 3)
        eng_FF_off[1] = 0
        eng_N1_off[1] = Set_linear_anim_value(eng_N1_off[1], 0, 0, ENG.data.max_n2, 2)
        igniter_eng[1] = 0
        starter_valve_eng[1] = 0
    end
    if not ENG.dyn[2].is_avail and require_cooldown[2] then    -- Turn off the engine
        set(Eng_fsm_state,FSM_SHUTDOWN,2)
        -- Set N2 to zero
        local n2_target = get(IAS) > 50 and 10 + get(IAS)/10 + random_pool_3*2 or 0 -- In in-flight it rotates
        eng_N2_off[2] = Set_linear_anim_value(eng_N2_off[2], n2_target or 0 , 0, ENG.data.max_n2, 1)
        
        -- Set EGT and FF to zero
        if eng_EGT_off[2] == EGT_MAGIC then eng_EGT_off[2] = ENG.dyn[2].egt end -- otherwise in auto start case we will have a jump since eng_EGT_off is not set before
        eng_EGT_off[2] = Set_linear_anim_value(eng_EGT_off[2], get(OTA), -50, 1500, eng_EGT_off[2] > 100 and 10 or 3)
        eng_FF_off[2] = 0
        eng_N1_off[2] = Set_linear_anim_value(eng_N1_off[2], 0, 0, ENG.data.max_n2, 2)
        igniter_eng[2] = 0
        starter_valve_eng[2] = 0
    end

end

local function update_auto_start()
    if not slow_start_time_requested then
        return  -- auto start not requested
    end
    -- in case we had a previous A/C load with manual startup there might be a value in this vars which lead to jump in EGT cooldown
    -- so we have to init it here again after auto startup has been performed
    eng_EGT_off[1] = EGT_MAGIC
    eng_EGT_off[2] = EGT_MAGIC

    -- Turn on the batteries immediately and start the APU   
    ELEC_sys.batteries[1].switch_status = true
    ELEC_sys.batteries[2].switch_status = true

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
       -- TODO make APU only autostart possible set(Engine_2_master_switch, 1)
        slow_start_time_requested = false
    end

    if ENG.dyn[2].is_avail then
        set(Engine_1_master_switch, 1)
    end

    if ENG.dyn[1].is_avail and ENG.dyn[2].is_avail then
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
    if ENG.dyn[1].egt < 100 then
        if time_last_shutdown[1] == 0 and get(Engine_1_master_switch) == 0 then
            -- only when really in shutdown process otherwise cooling may appear again during startup after cranking/cooling
            time_last_shutdown[1] = get(TIME)
            time_current_startup[1]  = -1
            initial_oil_qty[1] = initial_oil_qty[1] - used_oil_qty[1] -- we must take used qty into account for next start
        end
    else
        -- init cooling requirement
        cooling_has_cooled[1] = false
        cooling_left_time[1] = COOLING_REQUIRED_MAGIC -- mark with cooling is required flag
        time_last_shutdown[1] = 0
    end 

    if ENG.dyn[2].egt < 100  then
        if time_last_shutdown[2] == 0 and get(Engine_2_master_switch) == 0 then
            time_last_shutdown[2] = get(TIME)
            time_current_startup[2]  = -1
            initial_oil_qty[2] = initial_oil_qty[2] - used_oil_qty[2]
        end
    else
        cooling_has_cooled[2] = false
        cooling_left_time[2] = COOLING_REQUIRED_MAGIC
        time_last_shutdown[2] = 0
    end 


end

local function update_continuous_ignition()
    -- Continuous ignition occurs in two cases:
    -- - Engine flameout
    -- - Manually move the mode selection to IGN but after start!

    local cond_1 = (get(Engine_1_master_switch) == 1 and get(Eng_is_failed, 1) == 1)
                or (get(Engine_2_master_switch) == 1 and get(Eng_is_failed, 2) == 1)
    
    local cond_2 = ENG.dyn[1].is_avail and ENG.dyn[2].is_avail and get(Engine_mode_knob) == 1 and already_back_to_norm

    if ENG.dyn[1].is_avail and ENG.dyn[2].is_avail and get(Engine_mode_knob) == 0 then
        already_back_to_norm = true
    elseif not ENG.dyn[1].is_avail or not ENG.dyn[2].is_avail then
        already_back_to_norm = false
    end
    
    set(Eng_Continuous_Ignition, (cond_1 or cond_2) and 1 or 0)
end

local function update_oil_qty_startup(eng)

    local eng_n2
    local curr_oil
    local initial_qty

    eng_n2 = ENG.dyn[eng].n2
    curr_oil = ENG.dyn[eng].oil_qty
    initial_qty = initial_oil_qty[eng]

    if eng_n2 < 18 then
        oil_gulp_timer[eng] = 0  -- TODO reset in shutdown for performance
        return
    end

    if oil_gulp_timer[eng] == 0 then oil_gulp_timer[eng] = get(TIME) end

    -- implement oil gulping during startup, TODO TBD: max delta scaled based on start qty?
    -- start timer at N2 == 18 for normal startup
    local delta = get(TIME) - oil_gulp_timer[eng]
    if delta > 61.92 then
       -- qty stays stable
    elseif delta > 59.85 then
        curr_oil = initial_qty - (-3.8846153846153846 + 0.2403846153846154 * delta)
    elseif delta > 55.52 then
        curr_oil = initial_qty - (6.412568306010929 + 0.06830601092896176 * delta)
    elseif delta > 48.32 then
        curr_oil = initial_qty - (16.252380952380953 - 0.11904761904761904 * delta)
    elseif delta > 33.65 then
        curr_oil = initial_qty - (12.136856368563686 - 0.03387533875338753 * delta)
    elseif delta > 31.4 then
        curr_oil = initial_qty - (18.76851851851852 - 0.23148148148148148 * delta)
    elseif delta > 6.58 then
        curr_oil = initial_qty -( 2.399849559917311 - 2.362859879874882*delta + 0.5321735837021373*delta^2 - 0.0451135273801746*delta^3 +
                0.0020041578098679937*delta^4 - 0.00004525929443668085*delta^5  + 4.0534149582215e-7*delta^6)
    end

    ENG.dyn[eng].oil_qty = curr_oil

end

local function update_oil_qty()
    -- initial oil qty is set when initializing engine type
    if get(Eng_fsm_state, 1) >= FSM_START_PHASE_N2 and not ENG.dyn[1].is_avail then
        update_oil_qty_startup(1)
        return
    end

    if get(Eng_fsm_state, 2) >= FSM_START_PHASE_N2 and not ENG.dyn[2].is_avail then
        update_oil_qty_startup(2)
        return
    end


    if get(Eng_fsm_state, 1) == FSM_SHUTDOWN then
        ENG.dyn[1].oil_qty = Set_linear_anim_value(ENG.dyn[1].oil_qty, initial_oil_qty[1], 1,ENG.data.oil.qty_max , 0.1)
    else
        local curr_oil = ENG.dyn[1].oil_qty
        used_oil_qty[1] = used_oil_qty[1] + ENG.data.oil.qty_consumption / 60 / 60 * get(DELTA_TIME) * (ENG.dyn[1].is_avail and 1 or 0)
        curr_oil = curr_oil - ENG.data.oil.qty_consumption / 60 / 60 * get(DELTA_TIME) * (ENG.dyn[1].is_avail and 1 or 0)
        ENG.dyn[1].oil_qty = curr_oil
    end

    if get(Eng_fsm_state, 2) == FSM_SHUTDOWN then
        ENG.dyn[2].oil_qty = Set_linear_anim_value(ENG.dyn[2].oil_qty, initial_oil_qty[2], 1,ENG.data.oil.qty_max , 0.1)
    else
        local curr_oil = ENG.dyn[2].oil_qty
        used_oil_qty[2] = used_oil_qty[2] + ENG.data.oil.qty_consumption / 60 / 60 * get(DELTA_TIME) * (ENG.dyn[2].is_avail and 1 or 0)
        curr_oil = curr_oil - ENG.data.oil.qty_consumption / 60 / 60 * get(DELTA_TIME) * (ENG.dyn[2].is_avail and 1 or 0)
        ENG.dyn[2].oil_qty = curr_oil
    end

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
        elseif (get(Eng_N1_mode, engine) == 7 or get(TIME) - last_time_toga[engine] < 3) and ENG.dyn[1].is_avail and ENG.dyn[2].is_avail then
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
    ENG.dyn[1].is_fadec_pwrd = fadec_has_elec_power(1)
    ENG.dyn[2].is_fadec_pwrd = fadec_has_elec_power(2)
end


function update_engine_type()
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

        -- initial oil qty with some randomness
        ENG.dyn[1].oil_qty = ENG.data.oil.qty_max*3/4 + ENG.data.oil.qty_max/4 * math.random()
        ENG.dyn[2].oil_qty = ENG.data.oil.qty_max*3/4 + ENG.data.oil.qty_max/4 * math.random()
        initial_oil_qty[1] = ENG.dyn[1].oil_qty
        initial_oil_qty[2] = ENG.dyn[2].oil_qty
    end
    
end

local function update_failing_eng(x)
    local eng_ms    = (x == 1 and get(Engine_1_master_switch) or get(Engine_2_master_switch)) == 1
    local n2_below  = (x == 1 and ENG.dyn[1].n2 or ENG.dyn[2].n2) < 62
    local not_avail = not ENG.dyn[x].is_avail
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
    
    if get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF then
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
    update_nfan()
    update_egt()
    update_ff()
    update_oil_temp_and_press()
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

    if get(TIME) - random_pool_hf_update > 0.6 then
        random_pool_hf_update = get(TIME)
        random_pool_hf = math.random()
    end

    update_engine_model()

    perf_measure_stop("engines:update()")
end

-- The following code is used to check if SASL has been restarted with engines running
if get(Startup_running) == 1 and get(TIME) > 1 then
    engines_auto_quick_start(SASL_COMMAND_BEGIN)
end

