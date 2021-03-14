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
-- File: graphics.lua
-- Short description: Miscellanea related to graphics
-------------------------------------------------------------------------------

include("libs/table.save.lua")

local function load_save_view()
    local saved_view = table.load(moduleDirectory .. "/Custom Module/saved_configs/saved_view")
    if saved_view == nil then
        saved_view = {
            -0.54000002145767,
            2.0099999904633,
            -17.85000038147,
            5.8500003814697,
        }
        table.save(saved_view, moduleDirectory .. "/Custom Module/saved_configs/saved_view")
    end

    set(Head_x,   saved_view[1])
    set(Head_y,   saved_view[2])
    set(Head_z,   saved_view[3])
    set(Head_the, saved_view[4])
end

function onAirportLoaded()
    load_save_view()
end

local guards = {
    {name = "IDG1"},             -- This creates a command and dataref with the same name, both `a321neo/cockpit/overhead/guards/IDG1`
    {name = "IDG2"},
    {name = "CARGO_DISCH_1"},
    {name = "CARGO_DISCH_2"},
    {name = "MASK_MAN_ON"},
    {name = "ELEC_RAT_MAN_ON"},
    {name = "EMER_GEN_TEST"},
    {name = "RAM_AIR"},
    {name = "DICTHING"},
    {name = "ENG_MAN_START_1"},
    {name = "ENG_MAN_START_2"},
    {name = "CALLS_EMER"},
    {name = "EVAC_COMMAND"},
    {name = "HYD_RAT_MAN_ON"},
    {name = "HYD_BLUE_PUMP"},
    {name = "HIGH_ALT_LANDING"},
    {name = "EMER"},
    {name = "MNTN_BLUE_PUMP"},
    {name = "MNTN_HYD_G"},
    {name = "MNTN_HYD_B"},
    {name = "MNTN_HYD_Y"},
    {name = "MNTN_FADEC_1"},
    {name = "MNTN_FADEC_2"},
    {name = "FIRE_APU"},
    {name = "FIRE_ENG1"},
    {name = "FIRE_ENG2"},
}

local integral_lights = {
    --- MIP & Pedestal
    {name = "mip_pedestal_integral", bus=ELEC_BUS_AC_1}, -- OK

    --- Overhead panel / Pedestal
    {name = "overhead_integral",     bus=ELEC_BUS_AC_1}, -- OK

    --- glareshield
    {name = "glareshield_integral",  bus=AC_bus_1_pwrd},
}

local flood_and_spill_lights = {
    --- Overhead panel / Pedestal
    {name = "flood_main",  color = {1, 1, 1}, size_m = 0.45, cone_r = 0.76, max_brightness = 6, is_knob = true,  bus=ELEC_BUS_DC_ESS},  -- OK
    {name = "flood_ped",   color = {1, 1, 1}, size_m = 2.5,  cone_r = 0.95, max_brightness = 2, is_knob = true,  bus=ELEC_BUS_DC_1},    -- OK
    {name = "dome",        color = {1, 1, 1}, size_m = 1,    cone_r = 0.95, max_brightness = 5, is_knob = false, bus=ELEC_BUS_DC_ESS,}, -- OK
    {name = "capt_reading",color = {1, 1, 1}, size_m = 2.5,  cone_r = 0.98, max_brightness = 4, is_knob = true,  bus=AC_bus_1_pwrd},
    {name = "fo_reading",  color = {1, 1, 1}, size_m = 2.5,  cone_r = 0.98, max_brightness = 4, is_knob = true,  bus=AC_bus_1_pwrd},

    -- CAPT/FO side
    {name = "capt_led_strip",     color = {1, 1, 1}, size_m = 1, cone_r = 0.95, max_brightness = 5, is_knob = true,  bus=AC_bus_1_pwrd},
    {name = "fo_led_strip",       color = {1, 1, 1}, size_m = 1, cone_r = 0.95, max_brightness = 5, is_knob = true,  bus=AC_bus_1_pwrd},
    {name = "capt_window",        color = {1, 1, 1}, size_m = 1, cone_r = 0.95, max_brightness = 5, is_knob = true,  bus=AC_bus_1_pwrd},
    {name = "fo_window",          color = {1, 1, 1}, size_m = 1, cone_r = 0.95, max_brightness = 5, is_knob = true,  bus=AC_bus_1_pwrd},
    {name = "capt_console_floor", color = {1, 1, 1}, size_m = 1, cone_r = 0.95, max_brightness = 5, is_knob = false, bus=ELEC_BUS_DC_1}, -- OK
    {name = "fo_console_floor",   color = {1, 1, 1}, size_m = 1, cone_r = 0.95, max_brightness = 5, is_knob = false, bus=ELEC_BUS_DC_2}, -- OK
}


local ann_lt_pos = 0

local cvr_gnd_ctl = false -- Status of the pushbutton on the RCDR panel, this has no actual effect
local signs_seat_belt = 0 -- 0,1,2
local signs_noped     = 0 -- 0,1,2

local capt_tray = false
local fo_tray   = false
local avionics_light_status  = false -- Status of the light for the avionics bay (it doesn't really work lol)
local service_int_ovr_status = false -- Status of the service interphone (it doesn't do actually anything)
local last_toilette_time = 0

local cockpit_door_level_pos = 0
local cockpit_door_level_pos_time_open = 0

----------------------------------------------------------------------------------------------------
-- Command function
----------------------------------------------------------------------------------------------------
function guard_click_handler(phase, object)
    if phase == SASL_COMMAND_BEGIN then
        set(object.state_dataref, 1 - get(object.state_dataref))
    end
end


function change_switch(phase, dr, direction)
     if phase == SASL_COMMAND_BEGIN then
        set(dr, Math_clamp(get(dr) + direction, -1, 1))
     end
end


sasl.registerCommandHandler (RCDR_cmd_GND_CTL, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then cvr_gnd_ctl = not cvr_gnd_ctl end end)
sasl.registerCommandHandler (MISC_cmd_seatbelts_up, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then signs_seat_belt = math.min(2, signs_seat_belt + 1) end end)
sasl.registerCommandHandler (MISC_cmd_seatbelts_dn, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then signs_seat_belt = math.max(0, signs_seat_belt - 1) end end)
sasl.registerCommandHandler (MISC_cmd_noped_up, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then signs_noped = math.min(2, signs_noped + 1)  end end)
sasl.registerCommandHandler (MISC_cmd_noped_dn, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then signs_noped = math.max(0, signs_noped - 1) end end)
sasl.registerCommandHandler (MNTN_AVIO_LIGHT, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then avionics_light_status = not avionics_light_status end end)
sasl.registerCommandHandler (MNTN_SVCE_INT, 0,    function(phase) if phase == SASL_COMMAND_BEGIN then service_int_ovr_status = not service_int_ovr_status end end)


----------------------------------------------------------------------------------------------------
-- Lights
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (Cockpit_ann_ovhd_cmd_up, 0,  function(phase)
    if phase == SASL_COMMAND_BEGIN then
        ann_lt_pos = math.min(ann_lt_pos + 1, 1)
    end
 end)
sasl.registerCommandHandler (Cockpit_ann_ovhd_cmd_dn, 0,  function(phase)
    if phase == SASL_COMMAND_BEGIN then
        ann_lt_pos = math.max(ann_lt_pos - 1, -1)
    end
 end)

function Switch_handler(phase, dataref, min, max, direction)
    if phase == SASL_COMMAND_BEGIN then
        local new_value = Math_clamp(get(dataref) + direction, min, max)
        set(dataref, new_value)
    end
end

-- EMER exit
sasl.registerCommandHandler (LIGHTS_cmd_emer_exit_up, 0,  function(phase) Switch_handler(phase, Lights_emer_exit, 0, 2, 1)  end)
sasl.registerCommandHandler (LIGHTS_cmd_emer_exit_dn, 0,  function(phase) Switch_handler(phase, Lights_emer_exit, 0, 2, -1)  end)

-- Trays
sasl.registerCommandHandler (Cockpit_Capt_tray_toggle, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then capt_tray = not capt_tray end end)
sasl.registerCommandHandler (Cockpit_Fo_tray_toggle, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then fo_tray = not fo_tray end end)

----------------------------------------------------------------------------------------------------
-- Cockpit door lever
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (CKPT_DOOR_cmd_unlock, 0,
function(phase)
    if phase == SASL_COMMAND_BEGIN then
        cockpit_door_level_pos = 1
        cockpit_door_level_pos_time_open = get(TIME)
    elseif phase == SASL_COMMAND_END then
        cockpit_door_level_pos = 0
    end 
end)

sasl.registerCommandHandler (CKPT_DOOR_cmd_lock, 0,
function(phase)
    if phase == SASL_COMMAND_BEGIN then
        cockpit_door_level_pos = -1
    elseif phase == SASL_COMMAND_END then
        cockpit_door_level_pos = 0
    end 
end)

----------------------------------------------------------------------------------------------------
-- Initialization function
----------------------------------------------------------------------------------------------------
local function create_drs(object)
    object.dataref = createGlobalPropertyf("a321neo/cockpit/overhead/guards/" .. object.name, 0, false, true, false)
    object.state_dataref = createGlobalPropertyi("a321neo/cockpit/overhead/guards/state/" .. object.name, 0, false, true, false)
    object.command = createCommand("a321neo/cockpit/overhead/guards/" .. object.name, "GUARD - " .. object.name .. " pushbutton")
    sasl.registerCommandHandler (object.command, 0,  function(phase) guard_click_handler(phase, object); return 1 end )
end

local function init_drs(array)
    for i,x in ipairs(guards) do
        create_drs(x)
    end
end

local function create_integral_datarefs()

    for i,x in ipairs(integral_lights) do
        x.dr_value = createGlobalPropertyf("a321neo/cockpit/lights/"  .. x.name .. "_value", 0, false, true, false)
        x.dr_pos  = createGlobalPropertyf("a321neo/cockpit/lights/"  .. x.name .. "_pos", 0, false, true, false)

        x.cmd_up   = createCommand("a321neo/cockpit/lights/" .. x.name .. "_knob_up", "Knob UP")
        x.cmd_down = createCommand("a321neo/cockpit/lights/" .. x.name .. "_knob_dn", "Knob DOWN")

        sasl.registerCommandHandler (x.cmd_up,   0, function(phase) Knob_handler_up_float(phase, x.dr_pos, 0, 1, 1) end)
        sasl.registerCommandHandler (x.cmd_down, 0, function(phase) Knob_handler_down_float(phase, x.dr_pos, 0, 1, 1) end)
    end

end

local function create_flood_and_spill_datarefs()

    for i,x in ipairs(flood_and_spill_lights) do
        x.dr_value = createGlobalPropertyf("a321neo/cockpit/lights/"  .. x.name .. "_value", 0, false, true, false)
        x.dr_pos  = createGlobalPropertyf("a321neo/cockpit/lights/"  .. x.name .. "_pos", 0, false, true, false)

        x.dr_array = createGlobalPropertyfa("a321neo/cockpit/lights/" .. x.name .. "_array", 9, false, true, false)

        x.cmd_up   = createCommand("a321neo/cockpit/lights/" .. x.name .. "_knob_up", "Knob UP")
        x.cmd_down = createCommand("a321neo/cockpit/lights/" .. x.name .. "_knob_dn", "Knob DOWN")
        if x.is_knob then
            sasl.registerCommandHandler (x.cmd_up,   0, function(phase) Knob_handler_up_float(phase, x.dr_pos, 0, 1, 1) end)
            sasl.registerCommandHandler (x.cmd_down, 0, function(phase) Knob_handler_down_float(phase, x.dr_pos, 0, 1, 1) end)
        else
            sasl.registerCommandHandler (x.cmd_up, 0,   function(phase) change_switch(phase, x.dr_pos, 1) end)
            sasl.registerCommandHandler (x.cmd_down, 0, function(phase) change_switch(phase, x.dr_pos, -1) end)
        end
    end

end


init_drs(guards)
create_integral_datarefs()
create_flood_and_spill_datarefs()

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------
local function update_guards()
    for i = 1, #guards do
        set(guards[i].dataref, Set_linear_anim_value_nostop(get(guards[i].dataref), get(guards[i].state_dataref), 0, 1, 3))
    end
end

local function update_integral_datarefs()

    for i,x in ipairs(integral_lights) do
        set(x.dr_value, get(x.dr_pos))
        -- set(x.dr_value, get(x.dr_pos) * get(elec_const_to_dr(x.bus))) -- TODO Electrical
    end
end

local function update_flood_and_spil_datarefs()

    for i,x in ipairs(flood_and_spill_lights) do
        if x.is_knob then
            set(x.dr_value, get(x.dr_pos))
        else
            set(x.dr_value, (get(x.dr_pos) + 1) / 2)
        end

        --feed the light array
        set(x.dr_array, get(x.dr_value) * get(x.max_brightness) * x.color[1], 1)
        set(x.dr_array, get(x.dr_value) * get(x.max_brightness) * x.color[2], 2)
        set(x.dr_array, get(x.dr_value) * get(x.max_brightness) * x.color[3], 3)
        set(x.dr_array, 1, 4)
        set(x.dr_array, x.size_m, 5)
        set(x.dr_array, x.cone_r, 6)
        set(x.dr_array, -1, 8)
        -- set(x.dr_value, get(x.dr_pos) * get(elec_const_to_dr(x.bus))) -- TODO Electrical
    end
end

local function anim_light_switches()
    -- OVH switches
    Set_dataref_linear_anim_nostop(Cockpit_ann_ovhd_switch, ann_lt_pos, -1, 1, 10)
    Set_dataref_linear_anim_nostop(Lights_emer_exit_lever, get(Lights_emer_exit), 0, 2, 10)

    set(Cockpit_annnunciators_test, get(Cockpit_ann_ovhd_switch) > 0.5 and 1 or 0)

    -- Pedestal
    Set_dataref_linear_anim_nostop(Engine_mode_knob_pos, get(Engine_mode_knob), -1, 1, 10)

    Set_dataref_linear_anim_nostop(Lights_seatbelts_lever, signs_seat_belt, 0, 2, 10)
    Set_dataref_linear_anim_nostop(Lights_noped_lever, signs_noped, 0, 2, 10)

end

local function update_lights()
    pb_set(PB.ovhd.signs_emer_exit_lt, get(Lights_emer_exit) == 0, false)
    pb_set(PB.ovhd.rcdr_gnd_ctl, cvr_gnd_ctl, false)
    pb_set(PB.ovhd.mntn_avio_light, avionics_light_status, false)
    pb_set(PB.ovhd.mntn_svce_int, service_int_ovr_status, false)
end

local function update_datarefs()
    if signs_seat_belt == 2
       or (signs_seat_belt == 1 and (get(Front_gear_deployment) > 0 or get(Flaps_handle_position) > 0))
       or (get(Cabin_alt_ft) > 11300) then
        set(Seatbelts, get(AC_bus_1_pwrd) + get(AC_bus_2_pwrd) >= 1 and 1 or 0)
    else
        set(Seatbelts, 0)
    end

    if signs_noped == 2
       or (signs_noped == 1 and (get(Front_gear_deployment) > 0 or get(Flaps_handle_position) > 0)) then
        set(NoSmoking, get(AC_bus_1_pwrd) + get(AC_bus_2_pwrd) >= 1 and 1 or 0)
    else
        set(NoSmoking, 0)
    end

end

local function update_trays()
    Set_dataref_linear_anim_nostop(Cockpit_Capt_tray_pos, capt_tray and 1 or 0, 0, 1, 0.75)
    Set_dataref_linear_anim_nostop(Cockpit_Fo_tray_pos, fo_tray and 1 or 0, 0, 1, 0.75)
end

local function update_doorlock()
    Set_dataref_linear_anim_nostop(Cockpit_door_lever_pos, cockpit_door_level_pos, -1, 1, 0.75)
    pb_set(PB.ped.ckpt_door_light, false, cockpit_door_level_pos == 1 and get(TIME) - cockpit_door_level_pos_time_open > 1 and get(TIME) - cockpit_door_level_pos_time_open < 5)
end

local function default_view(phase)
    if phase == SASL_COMMAND_BEGIN then
        load_save_view()
    end
    return 0--inhibites the x-plane original command
end

sasl.registerCommandHandler (Default_view, 0, default_view)

function update_toilette()
    if math.random() < 0.00005 then -- ~8% of probability every minute, 99% probability every hour
        last_toilette_time = get(TIME)
    end

    is_toilette_busy = last_toilette_time ~= 0 and get(TIME) - last_toilette_time < 60

    pb_set(PB.ovhd.misc_toilet, false, is_toilette_busy)
end

function update()
    perf_measure_start("graphics:update()")

    update_guards()
    update_lights()
    anim_light_switches()
    update_datarefs()
    update_integral_datarefs()
    update_flood_and_spil_datarefs()
    update_trays()
    update_doorlock()
    update_toilette()

    perf_measure_stop("graphics:update()")
end
