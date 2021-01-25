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
-- File: anti_ice.lua 
-- Short description: ANTI-ICE systems
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- ANTI-ICE system
----------------------------------------------------------------------------------------------------

-- TODO: Reduce the N1 upper limit when ENG A.I. activated

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

local ENG_1  = 1
local ENG_2  = 2
local WINGS  = 3
local PROBES = 4

local DR_COMMON_ROOT = "sim/cockpit2/ice/"
local FLASH_TIME = 0.5 -- Flash FAULT in the pushbuttons

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local ai_sys_commanded_status = { -- The system is commanded on or off (not affected by electrical and failures)
    [ENG_1]  = false,
    [ENG_2]  = false,
    [WINGS]  = false,
    [PROBES] = false
}

local ai_btn_status = { -- switch position status
    [ENG_1]  = false,
    [ENG_2]  = false,
    [WINGS]  = false,
    [PROBES] = false
}

local ai_time_flash = {0,0,0,0} -- Used to timing the flash of fault
local wait_for_ice_detected = 0

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (AI_cmd_probe_window_heat, 0, function(phase) ai_toggle_button(phase, PROBES) end )
sasl.registerCommandHandler (AI_cmd_eng_1,             0, function(phase) ai_toggle_button(phase, ENG_1)  end )
sasl.registerCommandHandler (AI_cmd_eng_2,             0, function(phase) ai_toggle_button(phase, ENG_2)  end )
sasl.registerCommandHandler (AI_cmd_wings,             0, function(phase) ai_toggle_button(phase, WINGS)  end )

function ai_toggle_button(phase, what)
    if phase == SASL_COMMAND_BEGIN then
        ai_btn_status[what] = not ai_btn_status[what]
    end
end

----------------------------------------------------------------------------------------------------
-- X-Plane datarefs
----------------------------------------------------------------------------------------------------
-- We do not need to put these datarefs inside dynamic_datarefs.lua, because they are used to
-- interact with X-Plane system. Any other system should interact via our custom datarefs.

local AI_XP_auto_ignite  = globalPropertyi(DR_COMMON_ROOT .. "ice_auto_ignite_on")
local AI_XP_ice_detector = globalPropertyi(DR_COMMON_ROOT .. "ice_detect_on")
local AI_XP_ice_detected = globalPropertyi("sim/cockpit2/annunciators/ice", 0, false, true, false) -- 0: non detected, 1: detected
-- AI_ice_detected

ai_xp_components = {
   [ANTIICE_ENG_1]  = {dr_name="cowling_thermal_anti_ice_per_engine[0]", valve_elec=DC_bus_1_pwrd,
                       valve_status=false, valve_elec_fail_status=true, failure=FAILURE_AI_Eng1_valve_stuck,
                       parent=ENG_1},
   [ANTIICE_ENG_2]  = {dr_name="cowling_thermal_anti_ice_per_engine[1]", valve_elec=DC_bus_2_pwrd,
                       valve_status=false, valve_elec_fail_status=true, failure=FAILURE_AI_Eng2_valve_stuck,
                       parent=ENG_2},
   [ANTIICE_WING_L] = {dr_name="ice_surface_hot_bleed_air_left_on", valve_elec=DC_shed_ess_pwrd,
                       valve_status=false, valve_elec_fail_status=false, failure=FAILURE_AI_Wing_L_valve_stuck,
                       parent=WINGS},
   [ANTIICE_WING_R] = {dr_name="ice_surface_hot_bleed_air_right_on", valve_elec=DC_shed_ess_pwrd,
                       valve_status=false, valve_elec_fail_status=false, failure=FAILURE_AI_Wing_R_valve_stuck,
                       parent=WINGS},
   
   -- Widshield amps from here: https://www.astronics.com/docs/default-source/aes-docs/windshieldheatwhitepaper.pdf?sfvrsn=2b2aa158_4
   [ANTIICE_WINDOW_HEAT_L] = {dr_name="ice_window_heat_on", source_elec=AC_bus_1_pwrd,
                              elec_load_source=ELEC_BUS_AC_1, elec_amps_ground=10.5, elec_amps_flight=30.5, status=false,
                              failure=FAILURE_AI_Window_Heat_L, parent=PROBES},
   [ANTIICE_WINDOW_HEAT_R] = {dr_name=nil, source_elec=AC_bus_2_pwrd,
                              elec_load_source=ELEC_BUS_AC_2, elec_amps_ground=10.5, elec_amps_flight=30.5, status=false,
                              failure=FAILURE_AI_Window_Heat_R, parent=PROBES},
                              
   -- Following amps are good estimation (~230W in flight)
   [ANTIICE_PITOT_CAPT] = {dr_name="ice_pitot_heat_on_pilot", source_elec=AC_ess_bus_pwrd,
                              elec_load_source=ELEC_BUS_AC_ESS, elec_amps_ground=1, elec_amps_flight=2, status=false,
                              failure=FAILURE_AI_PITOT_CAPT, parent=PROBES},
   [ANTIICE_PITOT_FO]   = {dr_name="ice_pitot_heat_on_copilot", source_elec=AC_bus_2_pwrd,
                              elec_load_source=ELEC_BUS_AC_2, elec_amps_ground=1, elec_amps_flight=2, status=false,
                              failure=FAILURE_AI_PITOT_FO, parent=PROBES},
   [ANTIICE_PITOT_STDBY]= {dr_name=nil, source_elec=AC_bus_1_pwrd,
                              elec_load_source=ELEC_BUS_AC_1, elec_amps_ground=1, elec_amps_flight=2, status=false,
                              failure=FAILURE_AI_PITOT_STDBY, parent=PROBES},
                              
   -- Following amps are very rough estimation
   [ANTIICE_STATIC_CAPT]= {dr_name="ice_static_heat_on_pilot", source_elec=DC_bus_1_pwrd,
                              elec_load_source=ELEC_BUS_DC_1, elec_amps_ground=1, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_SP_CAPT, parent=PROBES},
   [ANTIICE_STATIC_FO]  = {dr_name="ice_static_heat_on_copilot", source_elec=DC_bus_2_pwrd,
                              elec_load_source=ELEC_BUS_DC_2, elec_amps_ground=1, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_SP_FO, parent=PROBES},
   [ANTIICE_STATIC_CAPT]= {dr_name=nil, source_elec=DC_bus_1_pwrd,
                              elec_load_source=ELEC_BUS_DC_1, elec_amps_ground=1, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_SP_STDBY, parent=PROBES},

   -- Following amps are very rough estimation
   [ANTIICE_AOA_CAPT] = {dr_name="ice_AOA_heat_on", source_elec=AC_ess_shed_pwrd,
                              elec_load_source=ELEC_BUS_AC_ESS_SHED, elec_amps_ground=1, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_PITOT_CAPT, parent=PROBES},
   [ANTIICE_AOA_FO]   = {dr_name="ice_AOA_heat_on_copilot", source_elec=AC_bus_2_pwrd,
                              elec_load_source=ELEC_BUS_AC_2, elec_amps_ground=1, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_PITOT_FO, parent=PROBES},
   [ANTIICE_AOA_STDBY]= {dr_name=nil, source_elec=AC_bus_1_pwrd,
                              elec_load_source=ELEC_BUS_AC_1, elec_amps_ground=1, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_PITOT_STDBY, parent=PROBES},
   -- Following amps are very rough estimation
   [ANTIICE_TAT_CAPT] = {dr_name=nil, source_elec=AC_bus_1_pwrd,
                              elec_load_source=ELEC_BUS_AC_1, elec_amps_ground=0, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_TAT_CAPT, parent=PROBES},
   [ANTIICE_TAT_FO]   = {dr_name=nil, source_elec=AC_bus_2_pwrd,
                              elec_load_source=ELEC_BUS_AC_2, elec_amps_ground=0, elec_amps_flight=1, status=false,
                              failure=FAILURE_AI_TAT_FO, parent=PROBES},


}

AI_sys.comp = ai_xp_components
AI_sys.switches = ai_btn_status
----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

local function update_xp_datarefs_single_bleed(c)

    assert(c.valve_elec ~= nil)
    
    if get(c.failure) == 0 then
        -- Let's switch the valve position if we can
        if get(c.valve_elec) == 1 then
            -- We need electrical power to move the valve
            c.valve_status = ai_sys_commanded_status[c.parent]
        else
            c.valve_status = c.valve_elec_fail_status   -- Valves have default failover state if not elec powered
        end
    end -- no else here, if stucked it maintains the previous position
    
    -- And update the x-plane dataref according to valve position and failure
    if c.valve_status then
        set(c.dr, 1)
    else
        set(c.dr, 0)
    end
end

local function update_xp_datarefs_single_elec(c)
    
    assert(c.source_elec ~= nil)
    
    -- The anti-ice system is on if:
    -- - There is electrical source
    -- - There is no failure
    -- - Th system is commanded ON
    local is_on = get(c.source_elec) == 1 and get(c.failure) == 0 and ai_sys_commanded_status[c.parent] 
    

    if c.dr_name ~= nil then
        if is_on then
            set(c.dr, 1)
        else
            set(c.dr, 0)
        end
    end
    
    if is_on then
        if get(Any_wheel_on_ground) == 1 then
            ELEC_sys.add_power_consumption(c.elec_load_source, c.elec_amps_ground, c.elec_amps_ground)
        else
            ELEC_sys.add_power_consumption(c.elec_load_source, c.elec_amps_flight, c.elec_amps_flight)
        end
    end
end

local function update_xp_datarefs_single(component)

    if component.dr == nil and component.dr_name ~= nil then
        component.dr = globalProperty(DR_COMMON_ROOT .. component.dr_name)
        assert(component.dr ~= nil)
    end
    
    if component.valve_elec ~= nil then
        -- Valve (bleed) component
        update_xp_datarefs_single_bleed(component)
    else
        update_xp_datarefs_single_elec(component)
    end

end

local function update_xp_datarefs()
    set(AI_XP_auto_ignite, 0)   -- We manually change N1, we don't want x-plane to do that
    set(AI_XP_ice_detector, (get(AC_bus_1_pwrd) + get(AC_bus_2_pwrd) > 0) and 1 or 0)
    
    
    for i,x in ipairs(ai_xp_components) do
        update_xp_datarefs_single(x)
    end    
end

local function get_engine_light_value(x) 
    if ai_btn_status[x] then
        if ai_time_flash[x] == 0 then
            ai_time_flash[x] = get(TIME)
        end
    else
        ai_time_flash[x] = 0
    end
    local is_transit = get(TIME) - ai_time_flash[x] <= FLASH_TIME
    local is_faulty = ai_xp_components[x].valve_status ~= ai_btn_status[x] or is_transit
    return (ai_btn_status[x] and 1 or 0) + (is_faulty and 10 or 0)

end

local function get_wings_light_value() 
    if ai_btn_status[WINGS] then
        if ai_time_flash[WINGS] == 0 then
            ai_time_flash[WINGS] = get(TIME)
        end
    else
        ai_time_flash[WINGS] = 0
    end
    local is_transit = get(TIME) - ai_time_flash[WINGS] <= FLASH_TIME
    local is_actually_faulty = ai_btn_status[WINGS] and (get(AI_wing_R_operating) == 0 or get(AI_wing_L_operating) == 0)
    local is_faulty = is_actually_faulty or is_transit 
    return (ai_btn_status[WINGS] and 1 or 0) + (is_faulty and 10 or 0)

end

local function update_light_datarefs()

    pb_set(PB.ovhd.antiice_wings, get_wings_light_value() % 2 == 1, get_wings_light_value() >= 10)
    pb_set(PB.ovhd.antiice_eng_1, get_engine_light_value(ENG_1) % 2 == 1, get_engine_light_value(ENG_1) >= 10)
    pb_set(PB.ovhd.antiice_eng_2, get_engine_light_value(ENG_2) % 2 == 1, get_engine_light_value(ENG_2) >= 10)
    pb_set(PB.ovhd.antiice_probes, ai_btn_status[PROBES], false)
    
end

local function update_logic()
    ai_sys_commanded_status[ENG_1] = ai_btn_status[ENG_1]
    ai_sys_commanded_status[ENG_2] = ai_btn_status[ENG_2]
    
    ai_sys_commanded_status[WINGS] = ai_btn_status[WINGS] 
        
    if get(Any_wheel_on_ground) == 1 then
        ai_sys_commanded_status[PROBES] = ai_btn_status[PROBES] or get(Engine_1_avail) == 1 or get(Engine_2_avail) == 1
    else
        ai_sys_commanded_status[PROBES] = true -- Always on in flight
    end

    -- This is to update the "NO ICE DETECT" message of the EWD: the message is displayed if no
    -- ice is detected for a continuous period of 190 seconds and ENG1 or ENG2 or WING is pressed.    
    local at_least_one_sys_on = ai_btn_status[ENG_1] or ai_btn_status[ENG_2] or ai_btn_status[WINGS]
    if get(AI_XP_ice_detected) == 0 and at_least_one_sys_on then
        if wait_for_ice_detected == 0 then
            wait_for_ice_detected = get(TIME)
        end
        set(No_ice_detected, (get(TIME) - wait_for_ice_detected > 190 and 1 or 0))
    else
        wait_for_ice_detected = 0
    end

    local AI_wing_L_is_ok =  get(L_bleed_press) > 5 and ai_xp_components[ANTIICE_WING_L].valve_status
    set(AI_wing_L_operating, AI_wing_L_is_ok and 1 or 0)
    local AI_wing_R_is_ok =  get(R_bleed_press) > 5 and ai_xp_components[ANTIICE_WING_R].valve_status
    set(AI_wing_R_operating, AI_wing_R_is_ok and 1 or 0)
    
end

function update()

    perf_measure_start("anti_ice:update()")

    update_logic()
    update_xp_datarefs()
    update_light_datarefs()
    
    perf_measure_stop("anti_ice:update()")

end
