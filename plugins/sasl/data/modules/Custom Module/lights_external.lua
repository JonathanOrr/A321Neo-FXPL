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
-- File: lights_external.lua
-- Short description: Management of the external lights
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------

local three_positions_switches = {
    { dr_pos= Lights_strobe_lever, dr_status= Lights_strobe, cmd_up = LIGHTS_cmd_strobe_up, cmd_dn = LIGHTS_cmd_strobe_dn},
    { dr_pos= Lights_land_L_lever, dr_status= Lights_land_L, cmd_up = LIGHTS_cmd_land_L_up, cmd_dn = LIGHTS_cmd_land_L_dn},
    { dr_pos= Lights_land_R_lever, dr_status= Lights_land_R, cmd_up = LIGHTS_cmd_land_R_up, cmd_dn = LIGHTS_cmd_land_R_dn},
    { dr_pos= Lights_nose_lever,   dr_status= Lights_nose,   cmd_up = LIGHTS_cmd_nose_up,   cmd_dn = LIGHTS_cmd_nose_dn},
    { dr_pos= Lights_navlogo_lever,dr_status= Lights_navlogo,cmd_up = LIGHTS_cmd_navlogo_up,cmd_dn = LIGHTS_cmd_navlogo_dn},

    { dr_pos= Lights_beacon_lever,      dr_status= Lights_beacon,   cmd_toggle = LIGHTS_cmd_beacon_toggle},
    { dr_pos= Lights_wing_lever,        dr_status= Lights_wing,   cmd_toggle = LIGHTS_cmd_wing_toggle},
    { dr_pos= Lights_rwy_turnoff_lever, dr_status= Lights_rwy_turnoff,   cmd_toggle = LIGHTS_cmd_rwy_turnoff_toggle},
}

local dr_land_light_sw    = globalPropertyfa("sim/cockpit2/switches/landing_lights_switch")
local dr_taxi_light_sw    = globalPropertyi("sim/cockpit2/switches/taxi_light_on")
local dr_generic_light_sw = globalPropertyfa("sim/cockpit2/switches/generic_lights_switch")

-------------------------------------------------------------------------------
-- Initialization and command handlers
-------------------------------------------------------------------------------

local function cmd_handler_3_pos(phase, direction, switch)
    if phase == SASL_COMMAND_BEGIN then
        set(switch.dr_status, Math_clamp(get(switch.dr_status) + direction, 0, 2))
    end
end

local function cmd_handler_2_pos(phase, switch)
    if phase == SASL_COMMAND_BEGIN then
        set(switch.dr_status, 1 - get(switch.dr_status))
    end
end

local function init_cmd_handlers()
    for i,x in ipairs(three_positions_switches) do
        if x.cmd_up then
            sasl.registerCommandHandler (x.cmd_up, 0, function(phase) cmd_handler_3_pos(phase, 1, x) end)
            sasl.registerCommandHandler (x.cmd_dn, 0, function(phase) cmd_handler_3_pos(phase, -1, x) end)
        else
            sasl.registerCommandHandler (x.cmd_toggle, 0, function(phase) cmd_handler_2_pos(phase, x) end)
        end
    end
end

init_cmd_handlers()

-------------------------------------------------------------------------------
-- Update functions 
-------------------------------------------------------------------------------

local function update_xp_datarefs_white_lights()

    local TAKEOFF_LIGHT  = 1
    local RWY_TURN_OFF_L = 2
    local RWY_TURN_OFF_R = 3
    local WING_L = 4
    local WING_R = 5
    local LOGO_L = 6
    local LOGO_R = 7

    -- Landing lights
    set(dr_land_light_sw, get(Lights_land_L) * get(AC_bus_1_pwrd), 1)
    set(dr_land_light_sw, get(Lights_land_R) * get(AC_bus_2_pwrd), 2)

    -- Taxi & Take-off lights
    if get(Front_gear_deployment) < 0.99 then
        set(dr_taxi_light_sw, 0)
        set(dr_generic_light_sw, 0, TAKEOFF_LIGHT)
    else
        set(dr_taxi_light_sw, (get(Lights_nose) > 0 and 1 or 0) * get(AC_bus_1_pwrd) * get(DC_bus_2_pwrd))
        set(dr_generic_light_sw, (get(Lights_nose) == 2 and 1 or 0) * get(AC_bus_2_pwrd) * get(DC_bus_2_pwrd), TAKEOFF_LIGHT)
    end

    -- Runway TURNOFF lights
    set(dr_generic_light_sw, get(Lights_rwy_turnoff) * get(AC_bus_1_pwrd) * get(DC_bus_2_pwrd), RWY_TURN_OFF_L)
    set(dr_generic_light_sw, get(Lights_rwy_turnoff) * get(AC_bus_2_pwrd) * get(DC_bus_2_pwrd), RWY_TURN_OFF_R)

    -- WING lights
    set(dr_generic_light_sw, get(Lights_wing) * get(AC_bus_1_pwrd) * get(DC_bus_2_pwrd), WING_L)
    set(dr_generic_light_sw, get(Lights_wing) * get(AC_bus_2_pwrd) * get(DC_bus_2_pwrd), WING_R)

    -- Logo lights
    set(dr_generic_light_sw, (get(Lights_navlogo) > 0 and 1 or 0) * get(AC_bus_1_pwrd) * get(DC_bus_2_pwrd), LOGO_L)
    set(dr_generic_light_sw, (get(Lights_navlogo) > 0 and 1 or 0) * get(AC_bus_2_pwrd) * get(DC_bus_2_pwrd), LOGO_R)
end

local function update_switch_position()

    for i,x in ipairs(three_positions_switches) do
        if x.cmd_up then
            set(x.dr_pos, Set_linear_anim_value_nostop(get(x.dr_pos), get(x.dr_status), 0, 2, TOGGLE_SWITCH_ANIMATION_SPEED))
        else
            set(x.dr_pos, Set_linear_anim_value_nostop(get(x.dr_pos), get(x.dr_status), 0, 1, TOGGLE_SWITCH_ANIMATION_SPEED))
        end
    end
end

function update()
    update_switch_position()
    update_xp_datarefs_white_lights()
end
