--inclue subcomponents
include('FBW_subcomponents/UI_subcomponents/UI_resources.lua')
include('FBW_subcomponents/UI_subcomponents/envelop_module.lua')
include('FBW_subcomponents/UI_subcomponents/flaps_module.lua')
include('FBW_subcomponents/UI_subcomponents/flight_control_module.lua')
include('FBW_subcomponents/UI_subcomponents/speed_limit_module.lua')
include('FBW_subcomponents/UI_subcomponents/PID_graph_module.lua')

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
    Update_pid_graph_module_960x340(5, UI_scroll_y_pos - 5 - 160 - 5 - 180 - 5 - 240 - 5 - 340)
end

function draw()
    --draw all background
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)

    Draw_flight_control_module_480x160(5, UI_scroll_y_pos - 5 - 160)
    Draw_slats_flaps_module_480x180(5, UI_scroll_y_pos - 5 - 160 - 5 - 180, Slats_flaps_module)
    Draw_envelop_module_480x240(5, UI_scroll_y_pos - 5 - 160 - 5 - 180 - 5 - 240)
    Draw_limit_speeds_module_480x160(5 + 480 + 5, UI_scroll_y_pos - 5 - 160, Limit_speeds_module)
    Draw_pid_graph_module_960x340(5, UI_scroll_y_pos - 5 - 160 - 5 - 180 - 5 - 240 - 5 - 340)
end