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
--             perform_starting_procedure_follow_n2(eng), and the array START_UP_PHASES_N2
-- - Phase 3:  N1 from 0ish to 18.3: it manually controls the N1 according to the
--             perform_starting_procedure_follow_n1(eng), and the array START_UP_PHASES_N1



----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

local MAX_EGT_OFFSET = 10  -- This is the maximum offset between one engine and the other in terms of EGT
local ENG_N1_CRANK    = 10  -- N1 used for cranking and cooling
local ENG_N1_CRANK_FF = 15  -- FF in case of wet cranking
local ENG_N1_CRANK_EGT= 95  -- Target EGT for cranking
local ENG_N1_LL_IDLE  = 18.3 -- Value to determine if parameters control should be given to X-Plane 
local N1_INC_AI_ENG   = 1    -- Increase of minimum N1 if at least one ENG Anti-ice is activated
local N1_INC_AI_WING  = 1.5  -- Increase of minimum N1 if at least one WING Anti-ice is activated
local MAGIC_NUMBER = 100     -- This is a magic number, which value is necessary to start the engine (see later)

local OIL_QTY_MAX = 17
local OIL_QTY_MIN = 2
local OIL_PRESS_START = 50  -- MAX On startup
local OIL_PRESS_CONT  = 30  -- MAX Continuous
local OIL_PRESS_MIN   = 17  -- MIN in idle
local OIL_CONSUMPTION_PER_HOUR = 0.1

local OIL_TEMP_MIN   = -25   -- MIN for start
local OIL_TEMP_TOGA  = 38    -- MIN for toga
local OIL_TEMP_MAX_CONT = 140-- MAX continuous
local OIL_TEMP_MAX_TRAN = 155-- MAX for 15 min

local VIB_LIMIT_MAX_N1 = 6
local VIB_LIMIT_MAX_N2 = 4.3

local START_UP_PHASES_N2 = {
    -- n2_start: start point after which the element is considered
    -- n2_increase_per_sec: N2 is increasing this value each second
    -- fuel_flow: the fuel flow to use in this phase (static)
    -- egt: the value for EGT at the beginning of this phase (it will increase towards the next value)
    {n2_start = 0,    n2_increase_per_sec = 0.26, fuel_flow = 0,   egt=0},
    {n2_start = 10,   n2_increase_per_sec = 1.5, fuel_flow = 0,    egt=97},
    {n2_start = 16.2, n2_increase_per_sec = 1.5, fuel_flow = 120,  egt=97},
    {n2_start = 16.7, n2_increase_per_sec = 1.8, fuel_flow = 180,  egt=97},
    {n2_start = 24,   n2_increase_per_sec = 1.25, fuel_flow = 100, egt=162},
    {n2_start = 26.8, n2_increase_per_sec = 1.25, fuel_flow = 100, egt=263},
    {n2_start = 31.8, n2_increase_per_sec = 0.44, fuel_flow = 120, egt=173},
    {n2_start = 34.2, n2_increase_per_sec = 0.60, fuel_flow = 140, egt=229}
}

local START_UP_PHASES_N1 = {
    {n1_set = 2,      n1_increase_per_sec = 1, fuel_flow = 140, egt=280},
    {n1_set = 5,      n1_increase_per_sec = 0.60, fuel_flow = 140, egt=290},
    {n1_set = 6.6,    n1_increase_per_sec = 0.60, fuel_flow = 160, egt=303},
    {n1_set = 7.3,    n1_increase_per_sec = 0.20, fuel_flow = 180, egt=357},
    {n1_set = 7.8,    n1_increase_per_sec = 0.20, fuel_flow = 220, egt=393},
    {n1_set = 12.2,   n1_increase_per_sec = 0.60, fuel_flow = 260, egt=573},
    {n1_set = 14.9,   n1_increase_per_sec = 0.60, fuel_flow = 280, egt=574},
    {n1_set = 15.4,   n1_increase_per_sec = 1.16, fuel_flow = 300, egt=580},
    {n1_set = 16.3,   n1_increase_per_sec = 1.08, fuel_flow = 320, egt=592},
    {n1_set = 17.1,   n1_increase_per_sec = 0.83, fuel_flow = 340, egt=602},
    {n1_set = 17.6,   n1_increase_per_sec = 0.79, fuel_flow = 360, egt=623},
    {n1_set = 18.3,   n1_increase_per_sec = 0.24, fuel_flow = 380, egt=637},
    {n1_set = 18.5,   n1_increase_per_sec = 0.24, fuel_flow = 380, egt=637},
}

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

local egt_eng_1_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values
local egt_eng_2_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values

local eng_manual_switch = {false,false}   -- Is engine manual start enabled?
local dual_cooling_switch = false

local eng_ignition_switch = globalPropertyia("sim/cockpit2/engine/actuators/ignition_key")
local eng_igniters        = globalPropertyia("sim/cockpit2/engine/actuators/igniter_on")
local starter_duration    = globalPropertyfa("sim/cockpit/engine/starter_duration")

local eng_mixture         = globalPropertyfa("sim/cockpit2/engine/actuators/mixture_ratio")
local eng_N1_enforce      = globalPropertyfa("sim/flightmodel/engine/ENGN_N1_")
local eng_N2_enforce      = globalPropertyfa("sim/flightmodel/engine/ENGN_N2_")

local eng_FF_kgs          = globalPropertyfa("sim/cockpit2/engine/indicators/fuel_flow_kg_sec")

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

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ENG_cmd_manual_start_1,     0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_manual_switch[1] = not eng_manual_switch[1] end end )
sasl.registerCommandHandler (ENG_cmd_manual_start_2,     0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_manual_switch[2] = not eng_manual_switch[2] end end )
sasl.registerCommandHandler (ENG_cmd_dual_cooling,        0, function(phase) if phase == SASL_COMMAND_BEGIN then dual_cooling_switch = not dual_cooling_switch end end )


sasl.registerCommandHandler (ENG_cmd_mode_up,            0, function(phase) engines_mode_up(phase) end)
sasl.registerCommandHandler (ENG_cmd_mode_down,          0, function(phase) engines_mode_down(phase) end)
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

local function n1_to_n2(n1)
    return 50 * math.log10(n1) + (n1+50)^3/220000 + 0.64
end

local function min_n1(altitude)
    return 5.577955*math.log(0.03338352*altitude+23.66644)+1.724586
end

local function n1_to_egt(n1, outside_temperature)
    return 1067.597 + (525.8561 - 1067.597)/(1 + (n1/76.42303)^4.611082) + (outside_temperature-6) *2
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
        Set_dataref_linear_anim(Eng_1_N2, n1_to_n2(eng_1_n1), 0, 130, 10)
    else
        Set_dataref_linear_anim(Eng_1_N2, eng_N2_off[1], 0, 130, 10)
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > 5 and get(Engine_2_master_switch) == 1  then
        Set_dataref_linear_anim(Eng_2_N2, n1_to_n2(eng_2_n1), 0, 130, 10)
    else
        Set_dataref_linear_anim(Eng_2_N2, eng_N2_off[2], 0, 130, 10)
    end

end


local function update_egt()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > ENG_N1_LL_IDLE then
        local computed_egt = n1_to_egt(eng_1_n1, get(OTA))
        computed_egt = computed_egt + egt_eng_1_offset + math.random()*2 -- Let's add a bit of randomness
        Set_dataref_linear_anim(Eng_1_EGT_c, computed_egt, -50, 1500, 70)
    else
        set(Eng_1_EGT_c, eng_EGT_off[1])
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > ENG_N1_LL_IDLE then
        local computed_egt = n1_to_egt(eng_2_n1, get(OTA))
        computed_egt = computed_egt + egt_eng_2_offset + math.random()*2 -- Let's add a bit of randomness
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

    -- ENG 1
    if get(Eng_1_N1) > ENG_N1_LL_IDLE and get(Engine_1_master_switch) == 1 then
        if get(Engine_1_avail) == 0 then
            set(EWD_engine_avail_ind_1_start, get(TIME))
            set(Engine_1_avail, 1)
        end
    else
        set(Engine_1_avail, 0)    
        set(EWD_engine_avail_ind_1_start, 0)
    end
    
    -- ENG 2
    if get(Eng_2_N1) > ENG_N1_LL_IDLE and get(Engine_2_master_switch) == 1 then
        if get(Engine_2_avail) == 0 then
            set(EWD_engine_avail_ind_2_start, get(TIME))
            set(Engine_2_avail, 1)
        end
    else
        set(Engine_2_avail, 0)    
        set(EWD_engine_avail_ind_2_start, 0)
    end

    
end

----------------------------------------------------------------------------------------------------
-- Functions - Secondary parameters
----------------------------------------------------------------------------------------------------
set(Eng_1_OIL_qty, OIL_QTY_MAX*3/4 + OIL_QTY_MAX/4 * math.random())
set(Eng_2_OIL_qty, OIL_QTY_MAX*3/4 + OIL_QTY_MAX/4 * math.random())
set(Eng_1_OIL_temp, get(OTA))
set(Eng_2_OIL_temp, get(OTA))

local function update_oil_stuffs()

    -- ENG 1 - PRESS
    if get(Engine_1_avail) == 1 then
        local n2_value = get(Eng_1_N2)
        local press = Math_rescale(60, OIL_PRESS_MIN+1, 120, OIL_PRESS_CONT, n2_value) + math.random()
        Set_dataref_linear_anim(Eng_1_OIL_press, press, 0, 100, 4)
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_1_N2))
        local press = Math_rescale(10, 0, 70, OIL_PRESS_START, n2_value)
        Set_dataref_linear_anim(Eng_1_OIL_press, press, 0, 100, 4)
    end

    -- ENG 1 - TEMP
    if get(Engine_1_avail) == 1 then
        local n2_value = get(Eng_1_N2)
        local temp = Math_rescale(60, 65, 120, OIL_TEMP_MAX_TRAN, n2_value) + math.random()
        Set_dataref_linear_anim(Eng_1_OIL_temp, temp, -50, 200, 1)
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_1_N2))
        local temp = Math_rescale(10, get(OTA), 70, 75, n2_value)
        Set_dataref_linear_anim(Eng_1_OIL_temp, temp, -50, 200, 1)
    end
    
    -- ENG 2 - PRESS
    if get(Engine_2_avail) == 1 then
        local n2_value = get(Eng_2_N2)
        local press = Math_rescale(60, OIL_PRESS_MIN+1, 120, OIL_PRESS_CONT, n2_value) + math.random()
        Set_dataref_linear_anim(Eng_2_OIL_press, press, 0, 100, 4)
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_2_N2))
        local press = Math_rescale(10, 0, 70, OIL_PRESS_START, n2_value)
        Set_dataref_linear_anim(Eng_2_OIL_press, press, 0, 100, 4)
    end

    -- ENG 2 - TEMP
    if get(Engine_2_avail) == 1 then
        local n2_value = get(Eng_2_N2)
        local temp = Math_rescale(60, 65, 120, OIL_TEMP_MAX_TRAN, n2_value) + math.random()
        Set_dataref_linear_anim(Eng_2_OIL_temp, temp, -50, 200, 1)
    else
        -- During startup
        local n2_value = math.max(10,get(Eng_2_N2))
        local temp = Math_rescale(10, get(OTA), 70, 75, n2_value)
        Set_dataref_linear_anim(Eng_2_OIL_temp, temp, -50, 200, 1)
    end


end

function update_vibrations()
    local n1_value = get(Eng_1_N1)
    local vib_n1 = Math_rescale(0, 0, 120, VIB_LIMIT_MAX_N1/4, n1_value) 
    if get(Engine_1_avail) == 1 then vib_n1 = vib_n1 + 0.1*math.random() end
    set(Eng_1_VIB_N1, vib_n1)

    local n2_value = get(Eng_1_N2)
    local vib_n2 = Math_rescale(0, 0, 120, VIB_LIMIT_MAX_N2/4, n2_value)
    if get(Engine_1_avail) == 1 then vib_n2 = vib_n2 + 0.1*math.random() end
    set(Eng_1_VIB_N2, vib_n2)

    local n1_value = get(Eng_2_N1)
    local vib_n1 = Math_rescale(0, 0, 120, VIB_LIMIT_MAX_N1/4, n1_value)
    if get(Engine_2_avail) == 1 then vib_n1 = vib_n1 + 0.1*math.random() end
    set(Eng_2_VIB_N1, vib_n1)

    local n2_value = get(Eng_2_N2)
    local vib_n2 = Math_rescale(0, 0, 120, VIB_LIMIT_MAX_N2/4, n2_value)
    if get(Engine_2_avail) == 1 then vib_n2 = vib_n2 + 0.1*math.random() end
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
    eng_N2_off[eng] = Set_linear_anim_value(eng_N2_off[eng], ENG_N1_CRANK, 0, 120, 0.25)
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
    
    for i=1,(#START_UP_PHASES_N2-1) do
        -- For each phase... 

        if eng_N2_off[eng] < START_UP_PHASES_N2[i+1].n2_start then
            -- We have found the correct phase
            
            -- Let's set the fuel flow
            eng_FF_off[eng] = START_UP_PHASES_N2[i].fuel_flow  / 3600
            
            local eng_has_fuel = (eng==1 and get(Fuel_tank_selector_eng_1)>0) or (eng==2 and get(Fuel_tank_selector_eng_2)>0)
            
            -- If we are on manua start, the master switch  may not be on. In this case case let's check
            -- it before injecting fuel
            local eng_manual_start_continue = ((eng == 1 and get(Engine_1_master_switch) == 1) or (eng == 2 and get(Engine_2_master_switch) == 1))

            if eng_FF_off[eng] == 0 or (eng_has_fuel and eng_manual_start_continue)  then

                -- We continue the starting procedure if: the FF is still 0, so we are spinning up with bleed
                -- OR the FF > 0 and there is fuel and the engine master switch has been moved to ON

                -- Let's compute the new N2
                eng_N2_off[eng] = eng_N2_off[eng] + START_UP_PHASES_N2[i].n2_increase_per_sec * get(DELTA_TIME)
                set(eng_N2_enforce, eng_N2_off[eng], eng)
                    
                -- And let's compute the EGT
                perc = (eng_N2_off[eng] - START_UP_PHASES_N2[i].n2_start) / (START_UP_PHASES_N2[i+1].n2_start - START_UP_PHASES_N2[i].n2_start)
                eng_EGT_off[eng] = Math_lerp(START_UP_PHASES_N2[i].egt, START_UP_PHASES_N2[i+1].egt, perc)
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


    for i=1,(#START_UP_PHASES_N1-1) do
        -- For each phase...
        
        -- Get the current N1, but it can't be zero 
        local curr_N1 = math.max(eng_N1_off[eng],2)
        
        if curr_N1 < START_UP_PHASES_N1[i+1].n1_set then
            -- We have found the correct phase

            -- Let's set the fuel flow
            eng_FF_off[eng] = START_UP_PHASES_N1[i].fuel_flow  / 3600
            
            local eng_has_fuel = (eng==1 and get(Fuel_tank_selector_eng_1)>0) or (eng==2 and get(Fuel_tank_selector_eng_2)>0)
            
            if eng_FF_off[eng] == 0 or eng_has_fuel then
            
                -- Let's compute the new N2
                local new_N1 = curr_N1 + START_UP_PHASES_N1[i].n1_increase_per_sec * get(DELTA_TIME)
                eng_N1_off[eng] = new_N1
                set(eng_N1_enforce, new_N1, eng)

                
                -- Let's compute the EGT
                perc = (curr_N1 - START_UP_PHASES_N1[i].n1_set) / (START_UP_PHASES_N1[i+1].n1_set - START_UP_PHASES_N1[i].n1_set)
                eng_EGT_off[eng] = Math_lerp(START_UP_PHASES_N1[i].egt, START_UP_PHASES_N1[i+1].egt, perc)
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

local function perform_starting_procedure(eng)
    if eng_N2_off[eng] < 9.5 then
        -- Phase 1: Ok let's start by cranking the engine to start rotation
        perform_crank_procedure(eng, false)
        return
    end
    
    -- If the N2 is larger than 10, then we can start the real startup procedure
    
    if eng_N2_off[eng] < START_UP_PHASES_N2[#START_UP_PHASES_N2].n2_start then  -- 1st phase

        -- Oh yes, this is a funny thing. You need to set this dataref to 100 to cheat X-Plane
        -- to convince it that the engine has been ignited (but it's not! We don't want X-Plane to
        -- control the ignition with the ignition_key).
        set(starter_duration, MAGIC_NUMBER, eng)

        -- Phase 2: Controlling the N2  
        perform_starting_procedure_follow_n2(eng)
        
    elseif eng_N1_off[eng] < START_UP_PHASES_N1[#START_UP_PHASES_N1].n1_set then
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

    local does_engine_1_can_start_or_crank = get(Engine_1_avail) == 0 and (get(L_bleed_press) > 10 or windmill_condition_1) and fadec_has_elec_power(1)
    local does_engine_2_can_start_or_crank = get(Engine_2_avail) == 0 and (get(R_bleed_press) > 10 or windmill_condition_2) and fadec_has_elec_power(2)

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
                perform_starting_procedure(1)
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
                perform_starting_procedure(2)
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
    end
    
    -- CASE 3: No ignition, no crank, engine is off of shutting down
    if get(Engine_1_avail) == 0  and require_cooldown[1] then    -- Turn off the engine
        -- Set N2 to zero
        eng_N2_off[1] = Set_linear_anim_value(eng_N2_off[1], 0, 0, 120, 1)
        set(eng_N2_enforce, eng_N2_off[1], 1)
        
        -- Set EGT and FF to zero
        eng_EGT_off[1] = Set_linear_anim_value(eng_EGT_off[1], get(OTA), -50, 1500, eng_EGT_off[1] > 100 and 10 or 3)
        eng_FF_off[1] = 0
        eng_N1_off[1] = Set_linear_anim_value(eng_N1_off[1], 0, 0, 120, 2)
        set(eng_igniters, 0, 1)
        igniter_eng[1] = 0
    end
    if get(Engine_2_avail) == 0 and require_cooldown[2] then    -- Turn off the engine
        -- Set N2 to zero
        eng_N2_off[2] = Set_linear_anim_value(eng_N2_off[2], 0, 0, 120, 1)
        set(eng_N2_enforce, eng_N2_off[2], 2)
        
        -- Set EGT and FF to zero
        eng_EGT_off[2] = Set_linear_anim_value(eng_EGT_off[2], get(OTA), -50, 1500, eng_EGT_off[2] > 100 and 10 or 3)
        eng_FF_off[2] = 0
        eng_N1_off[2] = Set_linear_anim_value(eng_N1_off[2], 0, 0, 120, 2)
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

    if get(Apu_master_button_state) % 2 == 0 then
        sasl.commandOnce(APU_cmd_master)
    end
    if get(Apu_avail) == 0 and get(Apu_start_button_state) % 2 == 0 then
        sasl.commandOnce(APU_cmd_start)
    end
    if get(Apu_avail) == 1 then
        if get(Apu_bleed_switch) == 0 then
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
    set(Engine_1_man_start, get(OVHR_elec_panel_pwrd) * (eng_manual_switch[1] and 1 or 0))
    set(Engine_2_man_start, get(OVHR_elec_panel_pwrd) * (eng_manual_switch[2] and 1 or 0))
    set(Engine_dual_cooling_light, get(OVHR_elec_panel_pwrd) * (dual_cooling_switch and 1 or 0))
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

    local cond_1 = (get(Engine_1_master_switch) == 1 and get(FAILURE_ENG_1_FAILURE) == 1)
                or (get(Engine_2_master_switch) == 1 and get(FAILURE_ENG_2_FAILURE) == 1)
    
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
    curr_oil = curr_oil - OIL_CONSUMPTION_PER_HOUR / 60 / 60 * get(DELTA_TIME) * get(Engine_1_avail)
    set(Eng_1_OIL_qty, curr_oil)

    local curr_oil = get(Eng_2_OIL_qty)
    curr_oil = curr_oil - OIL_CONSUMPTION_PER_HOUR / 60 / 60 * get(DELTA_TIME) * get(Engine_2_avail)
    set(Eng_2_OIL_qty, curr_oil)

end


function update()
    update_starter_datarefs()
    update_buttons_datarefs()
    
    update_avail()

    if get(FLIGHT_TIME) > 0.5 then
        -- This condition is needed because otherwise the startup overrides the values set by the
        -- engines_auto_quick_start() function when the simulation is started in flight. So, let's
        -- wait 500ms before allowing the startup sequence to work (I don't think you are so fast to
        -- turn the ignition knob and the master switch 500ms after the simulation is started ;-)
        update_startup()
    end


    update_n1_minimum()
    update_n2()
    update_egt()
    update_ff()
    update_oil_stuffs()
    update_vibrations()
    
    update_auto_start()
    update_time_since_shutdown()
    update_continuous_ignition()

    update_oil_qty()
end

-- The following code is used to check if SASL has been restarted with engines running
if get(Startup_running) == 1 and get(TIME) > 1 then
    engines_auto_quick_start(SASL_COMMAND_BEGIN)
end

