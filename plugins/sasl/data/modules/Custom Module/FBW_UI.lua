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
-- File: FBW_UI.lua
-- Short description: Fly-by-wire UI file
-------------------------------------------------------------------------------

--inclue subcomponents
include('FBW_subcomponents/UI_subcomponents/UI_resources.lua')
include('FBW_subcomponents/UI_subcomponents/envelop_module.lua')
include('FBW_subcomponents/UI_subcomponents/flaps_module.lua')
include('FBW_subcomponents/UI_subcomponents/flight_control_module.lua')
include('FBW_subcomponents/UI_subcomponents/speed_limit_module.lua')
include('FBW_subcomponents/UI_subcomponents/input_output_module.lua')

size = {1000, 600}

Slats_flaps_module = {
    slats_cl = LIGHT_BLUE,
    flaps_cl = LIGHT_BLUE,
    HYD_G_slats_cl = LIGHT_BLUE,
    HYD_G_flaps_cl = LIGHT_BLUE,
    HYD_B_cl = LIGHT_BLUE,
    HYD_Y_cl = LIGHT_BLUE,
    SFCC1_cl = LIGHT_BLUE,
    SFCC2_cl = LIGHT_BLUE,
    slats_half_spd = false,
    flaps_half_spd = false
}

Limit_speeds_module = {
    left_speeds_names = {"VMAX", "S SPD", "F SPD", "VLS", "A.PROT", "A.MAX"},
    right_speeds_names = {"VMAX", "S SPD", "F SPD", "VLS", "A.PROT", "A.MAX"},
    left_values = {Capt_VMAX, S_speed, F_speed, VLS, Capt_Valpha_prot, Capt_Valpha_MAX},
    right_values = {Capt_VMAX, S_speed, F_speed, VLS, Capt_Valpha_prot, Capt_Valpha_MAX},
    left_colors = {RED, GREEN, GREEN, ORANGE, ORANGE, RED},
    right_colors = {RED, GREEN, GREEN, ORANGE, ORANGE, RED},
    capt_ias_color = {1,1,1},
    fo_ias_color = {1,1,1},
    capt_ias_y_pos = 0,
    fo_ias_y_pos = 0
}

--local module positions
local UI_scroll_y_pos_command = size[2]
local UI_scroll_y_pos = size[2]

function onMouseDown(component, x, y, button, parentX, parentY)
    if button == MB_LEFT then
        Mouse_detect_control_info_and_setting_110x18(5 + 480 + 5 + 180 + 5 + 180 + 5, UI_scroll_y_pos - 5 -160 - 5 - 180, x, y)
    end
end

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    --scrolling target speed
    UI_scroll_y_pos_command = Math_clamp( UI_scroll_y_pos_command - value * 40, size[2], 1000)
end

function update()
    if SSS_FBW_UI:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideFBWUI, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideFBWUI, MENU_UNCHECKED)
    end

    UI_scroll_y_pos = Set_anim_value(UI_scroll_y_pos, UI_scroll_y_pos_command, size[2], 1000, 8)

    Update_slats_flaps_module_480x180(Slats_flaps_module)
    Update_limit_speeds_module_480x160(5 + 480 + 5, UI_scroll_y_pos - 5 - 160, Limit_speeds_module)
end

function draw()
    --draw all background
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)

    Draw_flight_control_module_480x160(5, UI_scroll_y_pos - 5 - 160)
    Draw_slats_flaps_module_480x180(5, UI_scroll_y_pos - 5 - 160 - 5 - 180, Slats_flaps_module)
    Draw_envelop_module_480x240(5, UI_scroll_y_pos - 5 - 160 - 5 - 180 - 5 - 240)
    Draw_limit_speeds_module_480x160(5 + 480 + 5, UI_scroll_y_pos - 5 - 160, Limit_speeds_module)
    Draw_input_module_180x180(5 + 480 + 5, UI_scroll_y_pos - 5 -160 - 5 - 180)
    Draw_FBW_output_180x180(5 + 480 + 5 + 180 + 5, UI_scroll_y_pos - 5 -160 - 5 - 180)
    Draw_control_info_and_setting_110x180(5 + 480 + 5 + 180 + 5 + 180 + 5, UI_scroll_y_pos - 5 -160 - 5 - 180)
end
