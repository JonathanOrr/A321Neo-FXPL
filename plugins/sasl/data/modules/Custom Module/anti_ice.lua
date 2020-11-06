----------------------------------------------------------------------------------------------------
-- ANTI-ICE system
----------------------------------------------------------------------------------------------------

-- TODO: Reduce the N1 upper limit when ENG A.I. activated

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

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

local AI_XP_window_heat   = globalPropertyi(DR_COMMON_ROOT .. "ice_window_heat_on")
local AI_XP_pitot_capt_heat = globalPropertyi(DR_COMMON_ROOT .. "ice_pitot_heat_on_pilot")
local AI_XP_pitot_fo_heat   = globalPropertyi(DR_COMMON_ROOT .. "ice_pitot_heat_on_copilot")
local AI_XP_AOA_capt_heat   = globalPropertyi(DR_COMMON_ROOT .. "ice_AOA_heat_on")
local AI_XP_AOA_fo_heat     = globalPropertyi(DR_COMMON_ROOT .. "ice_AOA_heat_on_copilot")
local AI_XP_static_port_capt_heat = globalPropertyi(DR_COMMON_ROOT .. "ice_static_heat_on_pilot")
local AI_XP_static_port_fo_heat   = globalPropertyi(DR_COMMON_ROOT .. "ice_static_heat_on_copilot")
	
local AI_XP_auto_ignite  = globalPropertyi(DR_COMMON_ROOT .. "ice_auto_ignite_on")
local AI_XP_ice_detector = globalPropertyi(DR_COMMON_ROOT .. "ice_detect_on")
local AI_XP_ice_detected = globalPropertyi("sim/cockpit2/annunciators/ice", 0, false, true, false) -- 0: non detected, 1: detected
-- AI_ice_detected

ai_xp_components = {
   [ANTIICE_ENG_1]  = {dr_name="cowling_thermal_anti_ice_per_engine[0]", valve_elec=DC_bus_1_pwrd, valve_status=false, valve_elec_fail_status=true, failure=FAILURE_AI_Eng1_valve_stuck, parent=ENG_1},
   [ANTIICE_ENG_2]  = {dr_name="cowling_thermal_anti_ice_per_engine[1]", valve_elec=DC_bus_2_pwrd, valve_status=false, valve_elec_fail_status=true, failure=FAILURE_AI_Eng2_valve_stuck, parent=ENG_2},
   [ANTIICE_WING_L] = {dr_name="ice_surface_hot_bleed_air_left_on", valve_elec=DC_shed_ess_pwrd, valve_status=false, valve_elec_fail_status=false, failure=FAILURE_AI_Wing_L_valve_stuck, parent=WINGS},
   [ANTIICE_WING_R] = {dr_name="ice_surface_hot_bleed_air_right_on", valve_elec=DC_shed_ess_pwrd, valve_status=false, valve_elec_fail_status=false, failure=FAILURE_AI_Wing_R_valve_stuck, parent=WINGS}

}

AI_sys.comp = ai_xp_components

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
    if get(c.source_elec) == 1 and get(c.failure) == 0 and ai_sys_commanded_status[c.parent] then
        set(c.dr, 1)
    else
        set(c.dr, 0)
    end
    
end

local function update_xp_datarefs_single(component)

    if component.dr == nil then
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

local function update_light_datarefs()

    set(AI_Eng_1_button_light, get_engine_light_value(ENG_1))
    set(AI_Eng_2_button_light, get_engine_light_value(ENG_2))
    
end

local function update_logic()
    ai_sys_commanded_status[ENG_1] = ai_btn_status[ENG_1]
    ai_sys_commanded_status[ENG_2] = ai_btn_status[ENG_2]
    

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


    
end

function update()
    update_logic()
    update_xp_datarefs()
    update_light_datarefs()

end
