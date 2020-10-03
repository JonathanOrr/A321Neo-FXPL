size = {1000, 600}

--colors
local RED = {1, 0, 0}
local ORANGE = {1, 0.55, 0.15}
local WHITE = {1.0, 1.0, 1.0}
local GREEN = {0.20, 0.98, 0.20}
local LIGHT_BLUE = {0, 0.708, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

--fonts
local B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612_bold = sasl.gl.loadFont("fonts/B612-Bold.ttf")
local B612_MONO_regular = sasl.gl.loadFont("fonts/B612MONO-Regular.ttf")
local B612_MONO_bold = sasl.gl.loadFont("fonts/B612MONO-Bold.ttf")

--load textures
local aircraft_behind_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fbw_ui/ui_plane_behind.png")
local aircraft_side_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fbw_ui/ui_right side.png")

--local module positions
local UI_scroll_y_pos_command = size[2]
local UI_scroll_y_pos = size[2]

--component_internal_variables
Slats_flaps_section = {
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

Limit_speeds_section = {
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

--fbw constraints
local upper_g_lim = 2.5
local lower_g_lim = -1

--sectional drawing functions
local function draw_flight_control_section_480x160(x_pos, y_pos)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 160) / 2

    --draw the background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 160, DARK_GREY)
    sasl.gl.drawTexture(aircraft_behind_img, CENTER_X - 474/2, y_pos + 160 - 158, 474, 158, {1,1,1})

    --draw control surfaces indications
    --spoilers
    sasl.gl.drawWideLine(CENTER_X - 65,  y_pos + 160 - 158 + 50, CENTER_X - 65,  y_pos + 160 - 158 + 50 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 95,  y_pos + 160 - 158 + 52, CENTER_X - 95,  y_pos + 160 - 158 + 52 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 115, y_pos + 160 - 158 + 54, CENTER_X - 115, y_pos + 160 - 158 + 54 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 135, y_pos + 160 - 158 + 56, CENTER_X - 135, y_pos + 160 - 158 + 56 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 155, y_pos + 160 - 158 + 58, CENTER_X - 155, y_pos + 160 - 158 + 58 + 50, 5, LIGHT_GREY)

    sasl.gl.drawWideLine(CENTER_X + 65,  y_pos + 160 - 158 + 50, CENTER_X + 65,  y_pos + 160 - 158 + 50 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 95,  y_pos + 160 - 158 + 52, CENTER_X + 95,  y_pos + 160 - 158 + 52 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 115, y_pos + 160 - 158 + 54, CENTER_X + 115, y_pos + 160 - 158 + 54 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 135, y_pos + 160 - 158 + 56, CENTER_X + 135, y_pos + 160 - 158 + 56 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 155, y_pos + 160 - 158 + 58, CENTER_X + 155, y_pos + 160 - 158 + 58 + 50, 5, LIGHT_GREY)

    sasl.gl.drawWideLine(CENTER_X - 65,  y_pos + 160 - 158 + 50, CENTER_X - 65,  y_pos + 160 - 158 + 50 + get(Left_inboard_spoilers),     5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X - 95,  y_pos + 160 - 158 + 52, CENTER_X - 95,  y_pos + 160 - 158 + 52 + get(Left_outboard_spoilers2),   5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X - 115, y_pos + 160 - 158 + 54, CENTER_X - 115, y_pos + 160 - 158 + 54 + get(Left_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X - 135, y_pos + 160 - 158 + 56, CENTER_X - 135, y_pos + 160 - 158 + 56 + get(Left_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X - 155, y_pos + 160 - 158 + 58, CENTER_X - 155, y_pos + 160 - 158 + 58 + get(Left_outboard_spoilers345), 5, LIGHT_BLUE)

    sasl.gl.drawWideLine(CENTER_X + 65,  y_pos + 160 - 158 + 50, CENTER_X + 65,  y_pos + 160 - 158 + 50 + get(Right_inboard_spoilers),     5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X + 95,  y_pos + 160 - 158 + 52, CENTER_X + 95,  y_pos + 160 - 158 + 52 + get(Right_outboard_spoilers2),   5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X + 115, y_pos + 160 - 158 + 54, CENTER_X + 115, y_pos + 160 - 158 + 54 + get(Right_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X + 135, y_pos + 160 - 158 + 56, CENTER_X + 135, y_pos + 160 - 158 + 56 + get(Right_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X + 155, y_pos + 160 - 158 + 58, CENTER_X + 155, y_pos + 160 - 158 + 58 + get(Right_outboard_spoilers345), 5, LIGHT_BLUE)

    --ailerons
    sasl.gl.drawWideLine(CENTER_X - 185, y_pos + 160 - 158 + 30, CENTER_X - 185, y_pos + 160 - 158 + 30 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 185, y_pos + 160 - 158 + 30, CENTER_X + 185, y_pos + 160 - 158 + 30 + 50, 5, LIGHT_GREY)

    sasl.gl.drawWideLine(CENTER_X - 185, y_pos + 160 - 158 + 30 + 25, CENTER_X - 185, y_pos + 160 - 158 + 30 + 25 - get(Left_aileron), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X + 185, y_pos + 160 - 158 + 30 + 25, CENTER_X + 185, y_pos + 160 - 158 + 30 + 25 - get(Right_aileron), 5, LIGHT_BLUE)

    --elevators
    sasl.gl.drawWideLine(CENTER_X - 45, y_pos + 160 - 158 + 49, CENTER_X - 45, y_pos + 160 - 158 + 49 + 47, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 45, y_pos + 160 - 158 + 49, CENTER_X + 45, y_pos + 160 - 158 + 49 + 47, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 45, y_pos + 160 - 158 + 49 + 17, CENTER_X - 45, y_pos + 160 - 158 + 49 + 17 - get(Elevators_hstab_1), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine(CENTER_X + 45, y_pos + 160 - 158 + 49 + 17, CENTER_X + 45, y_pos + 160 - 158 + 49 + 17 - get(Elevators_hstab_1), 5, LIGHT_BLUE)

    --rudder
    sasl.gl.drawWideLine(CENTER_X, y_pos + 160 - 158 + 130, CENTER_X - get(Yaw_lim), y_pos + 160 - 158 + 130, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X, y_pos + 160 - 158 + 130, CENTER_X + get(Yaw_lim), y_pos + 160 - 158 + 130, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X, y_pos + 160 - 158 + 130, CENTER_X + get(Rudder), y_pos + 160 - 158 + 130, 5, LIGHT_BLUE)
end

local function draw_envelop_section_480x240(x_pos, y_pos)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 240) / 2

    --draw the background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 240, DARK_GREY)

    --draw roll control ring
    --bank angle indications
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, -67, 134, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 113, 134, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, -get(Flightmodel_roll), RED)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 180, -get(Flightmodel_roll), RED)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, Math_clamp(-get(Flightmodel_roll), -125, 125), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 180, Math_clamp(-get(Flightmodel_roll), -125, 125), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, Math_clamp(-get(Flightmodel_roll), -67, 67), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 180, Math_clamp(-get(Flightmodel_roll), -67, 67), LIGHT_BLUE)
    --roll rate indications
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, -15, 30, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 165, 30, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 0, -get(Roll_rate), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 180, -get(Roll_rate), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 0, Math_clamp(-get(Roll_rate), -15, 15), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 180, Math_clamp(-get(Roll_rate), -15, 15), LIGHT_BLUE)
    --aircraft image
    sasl.gl.drawRotatedTextureCenter (aircraft_behind_img, get(Flightmodel_roll), CENTER_X - 120, CENTER_Y, CENTER_X - 120 - (160 / 2), CENTER_Y - (53 /2) + 6, 160, 53, {1,1,1})
    --text indications
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 20, 92, 270- 40, 80, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 35, "ROLL", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 50, string.format("%.2f", tostring(get(Flightmodel_roll))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 65, "ROLL RATE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 80, string.format("%.1f", tostring(get(Roll_rate))) .. "°/S", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)

    --draw G load control ring
    --pitch indications
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, -15, 45, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 165, 45, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, get(Flightmodel_pitch), RED)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 180, get(Flightmodel_pitch), RED)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, Math_clamp(get(Flightmodel_pitch), -30, 50), ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 180, Math_clamp(get(Flightmodel_pitch), -30, 50), ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, Math_clamp(get(Flightmodel_pitch), -15, 30), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 180, Math_clamp(get(Flightmodel_pitch), -15, 30), LIGHT_BLUE)
    --g load indicat
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, (lower_g_lim) * 10, (upper_g_lim -lower_g_lim) * 10, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 180 + (lower_g_lim ) * 10, (upper_g_lim -lower_g_lim) * 10, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 0, get(Total_vertical_g_load) * 10, ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 180, get(Total_vertical_g_load) * 10, ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 0, Math_clamp(get(Total_vertical_g_load) * 10, lower_g_lim * 10, upper_g_lim * 10), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 180, Math_clamp(get(Total_vertical_g_load) * 10, lower_g_lim * 10, upper_g_lim * 10), LIGHT_BLUE)
    --aircraft image
    sasl.gl.drawRotatedTextureCenter (aircraft_side_img, -get(Flightmodel_pitch), CENTER_X + 120, CENTER_Y, CENTER_X + 120 - (160 / 2), CENTER_Y - (53 /2) + 12, 160, 53, {1,1,1})
    --text indications
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 20, 92, 270- 40, 80, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 35, "PITCH", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 50, string.format("%.2f", tostring(get(Flightmodel_pitch))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 65, "G LOAD", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 80, string.format("%.1f", tostring(get(Total_vertical_g_load))) .. "G", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
end

local function update_slats_flaps_section_480x180(variable_table)
    --SFCC status color changes
    if get(SFCC_1_status) == 1 then
        variable_table.SFCC1_cl = LIGHT_BLUE
    else
        variable_table.SFCC1_cl = ORANGE
    end
    if get(SFCC_2_status) == 1 then
        variable_table.SFCC2_cl = LIGHT_BLUE
    else
        variable_table.SFCC2_cl = ORANGE
    end
    if get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0 then
        variable_table.SFCC1_cl = RED
        variable_table.SFCC2_cl = RED
    end

    --HYD system color changes
    if get(Hydraulic_G_press) > 1450 then
        variable_table.HYD_G_slats_cl = LIGHT_BLUE
        variable_table.HYD_G_flaps_cl = LIGHT_BLUE
    else
        variable_table.HYD_G_slats_cl = ORANGE
        variable_table.HYD_G_flaps_cl = ORANGE
    end
    if get(Hydraulic_B_press) > 1450 then
        variable_table.HYD_B_cl = LIGHT_BLUE
    else
        variable_table.HYD_B_cl = ORANGE
    end
    if get(Hydraulic_Y_press) > 1450 then
        variable_table.HYD_Y_cl = LIGHT_BLUE
    else
        variable_table.HYD_Y_cl = ORANGE
    end

    --surfaces color and dual failure colors
    variable_table.slats_half_spd = false
    variable_table.flaps_half_spd = false
    --slats
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_B_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        variable_table.slats_cl = LIGHT_BLUE
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        variable_table.slats_cl = RED
        --dual HYD failure
        if get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450 then
            variable_table.HYD_G_slats_cl = RED
            variable_table.HYD_B_cl = RED
        end
    else
        variable_table.slats_cl = ORANGE
        variable_table.slats_half_spd = true
    end

    --flaps
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_Y_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        variable_table.flaps_cl = LIGHT_BLUE
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        variable_table.flaps_cl = RED
        --dual HYD failure
        if get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450 then
            variable_table.HYD_G_flaps_cl = RED
            variable_table.HYD_Y_cl = RED
        end
    else
        variable_table.flaps_cl = ORANGE
        variable_table.flaps_half_spd = true
    end
end

local function draw_slats_flaps_section_480x180(x_pos, y_pos, variable_table)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 180) / 2
    local handle_configs = {"CLEAN", "1", "2", "3", "FULL"}
    local internal_configs = {"CLEAN", "1", "1 + F", "2", "3", "FULL"}

    --draw the background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 180, DARK_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 70, "SLATS & FLAPS", 12, false, false, TEXT_ALIGN_CENTER, WHITE)

    --slats flaps computers
    sasl.gl.drawRectangle(CENTER_X - 88, CENTER_Y + 46, 56, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 32, CENTER_Y + 46, 56, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 60, CENTER_Y + 52, "SFCC 1", 12, false, false, TEXT_ALIGN_CENTER, variable_table.SFCC1_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 60, CENTER_Y + 52, "SFCC 2", 12, false, false, TEXT_ALIGN_CENTER, variable_table.SFCC2_cl)

    --slats flaps configurations
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 25, "HANDLE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 25 - 50, "CONFIG", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawRectangle(CENTER_X - 25, CENTER_Y - 15 + 4, 50, 30, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 25, CENTER_Y - 15 + 4 - 50, 50, 30, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y, handle_configs[get(Flaps_handle_position) + 1], 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y- 50, internal_configs[get(Flaps_internal_config) + 1], 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)

    --slats
    sasl.gl.drawWideLine(CENTER_X - 40, CENTER_Y + 30 + 27 * get(Slats) / 4, CENTER_X - 220, CENTER_Y + 27 * get(Slats) / 4, Math_clamp_lower(27 * get(Slats) / 2, 1), variable_table.slats_cl)
    sasl.gl.drawWideLine(CENTER_X + 40, CENTER_Y + 30 + 27 * get(Slats) / 4, CENTER_X + 220, CENTER_Y + 27 * get(Slats) / 4, Math_clamp_lower(27 * get(Slats) / 2, 1), variable_table.slats_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 45, CENTER_Y + 15, "B", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_B_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 45, CENTER_Y + 15, "G", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_G_slats_cl)
    if variable_table.slats_half_spd == true then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X - 180, CENTER_Y - 12, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X + 180, CENTER_Y - 12, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
    end

    --flaps
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 45, CENTER_Y - 30, "G", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_G_flaps_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 45, CENTER_Y - 30, "Y", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_Y_cl)
    if variable_table.flaps_half_spd == true then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X - 95, CENTER_Y - 30, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X + 95, CENTER_Y - 30, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
    end
    sasl.gl.drawWideLine(CENTER_X - 110, CENTER_Y - 35 - get(Left_inboard_flaps) / 4,   CENTER_X - 40,  CENTER_Y - 35 - get(Left_inboard_flaps) / 4,   Math_clamp_lower(get(Left_inboard_flaps)/2, 1),   variable_table.flaps_cl)
    sasl.gl.drawWideLine(CENTER_X + 110, CENTER_Y - 35 - get(Right_inboard_flaps) / 4,  CENTER_X + 40,  CENTER_Y - 35 - get(Right_inboard_flaps) / 4,  Math_clamp_lower(get(Right_inboard_flaps)/2, 1),  variable_table.flaps_cl)
    sasl.gl.drawWideLine(CENTER_X - 220, CENTER_Y - 45 - get(Left_outboard_flaps) / 4,  CENTER_X - 120, CENTER_Y - 35 - get(Left_outboard_flaps) / 4,  Math_clamp_lower(get(Left_outboard_flaps)/2, 1),  variable_table.flaps_cl)
    sasl.gl.drawWideLine(CENTER_X + 220, CENTER_Y - 45 - get(Right_outboard_flaps) / 4, CENTER_X + 120, CENTER_Y - 35 - get(Right_outboard_flaps) / 4, Math_clamp_lower(get(Right_outboard_flaps)/2, 1), variable_table.flaps_cl)

    --transits
    if get(Slats_in_transit) == 1 and get(Flaps_in_transit) == 1 then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 75, "SLATS + FLAPS", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85, "IN TRANSIT", 8, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    elseif get(Slats_in_transit) == 1 then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 75, "SLATS", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85, "IN TRANSIT", 8, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    elseif get(Flaps_in_transit) == 1 then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 75, "FLAPS", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85, "IN TRANSIT", 8, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    end
end

local function update_limit_speeds_section_480x160(x_pos, y_pos, variable_table)
    variable_table.left_speeds_names = {"VMAX", "S SPD", "F SPD", "VLS", "A.PROT", "A.MAX"}
    variable_table.right_speeds_names = {"VMAX", "S SPD", "F SPD", "VLS", "A.PROT", "A.MAX"}
    variable_table.left_values = {Capt_VMAX, S_speed, F_speed, VLS, Capt_Valpha_prot, Capt_Valpha_MAX}
    variable_table.right_values = {Capt_VMAX, S_speed, F_speed, VLS, Capt_Valpha_prot, Capt_Valpha_MAX}
    variable_table.left_colors = {RED, GREEN, GREEN, ORANGE, ORANGE, RED}
    variable_table.right_colors = {RED, GREEN, GREEN, ORANGE, ORANGE, RED}

    variable_table.capt_ias_color = {1,1,1}
    variable_table.fo_ias_color = {1,1,1}
    variable_table.capt_ias_y_pos = y_pos + 5 + 0 * (5 + 110/6)
    variable_table.fo_ias_y_pos = y_pos + 5 + 0 * (5 + 110/6)

    local boxes_y_pos = {
        y_pos + 5 + 5 * (5 + 110/6),
        y_pos + 5 + 4 * (5 + 110/6),
        y_pos + 5 + 3 * (5 + 110/6),
        y_pos + 5 + 2 * (5 + 110/6),
        y_pos + 5 + 1 * (5 + 110/6),
        y_pos + 5 + 0 * (5 + 110/6)
    }

    --sort capt speeds large to small
    local l_name_swapping_buffer = 0
    local l_value_swapping_buffer = 0
    local l_color_swapping_buffer = 0

    for i = 1, #variable_table.left_values do
        for j = i + 1, #variable_table.left_values do
            if get(variable_table.left_values[i]) < get(variable_table.left_values[j]) then
                --record into buffer pre-swap
                l_name_swapping_buffer = variable_table.left_speeds_names[i]
                l_value_swapping_buffer = variable_table.left_values[i]
                l_color_swapping_buffer = variable_table.left_colors[i]
                --swap the higher one to the current position
                variable_table.left_speeds_names[i] = variable_table.left_speeds_names[j]
                variable_table.left_values[i] = variable_table.left_values[j]
                variable_table.left_colors[i] = variable_table.left_colors[j]
                --put the lower one back in
                variable_table.left_speeds_names[j] = l_name_swapping_buffer
                variable_table.left_values[j] = l_value_swapping_buffer
                variable_table.left_colors[j] = l_color_swapping_buffer
            end
        end
    end

    --sort fo speeds large to small
    local r_name_swapping_buffer = 0
    local r_value_swapping_buffer = 0
    local r_color_swapping_buffer = 0

    for i = 1, #variable_table.right_values do
        for j = i + 1, #variable_table.right_values do
            if get(variable_table.right_values[i]) < get(variable_table.right_values[j]) then
                --record into buffer pre-swap
                r_name_swapping_buffer = variable_table.right_speeds_names[i]
                r_value_swapping_buffer = variable_table.right_values[i]
                r_color_swapping_buffer = variable_table.right_colors[i]
                --swap the higher one to the current position
                variable_table.right_speeds_names[i] = variable_table.right_speeds_names[j]
                variable_table.right_values[i] = variable_table.right_values[j]
                variable_table.right_colors[i] = variable_table.right_colors[j]
                --put the lower one back in
                variable_table.right_speeds_names[j] = r_name_swapping_buffer
                variable_table.right_values[j] = r_value_swapping_buffer
                variable_table.right_colors[j] = r_color_swapping_buffer
            end
        end
    end

    --capt ias indications
    if get(PFD_Capt_IAS) >= get(variable_table.left_values[1]) then
        variable_table.capt_ias_y_pos = boxes_y_pos[1]
        variable_table.capt_ias_color[1] = variable_table.left_colors[1][1]
        variable_table.capt_ias_color[2] = variable_table.left_colors[1][2]
        variable_table.capt_ias_color[3] = variable_table.left_colors[1][3]
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[1]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[2]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[1], boxes_y_pos[2], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[1][1], variable_table.left_colors[2][1], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[1][2], variable_table.left_colors[2][2], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[1][3], variable_table.left_colors[2][3], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[2]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[3]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[2], boxes_y_pos[3], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[2][1], variable_table.left_colors[3][1], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[2][2], variable_table.left_colors[3][2], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[2][3], variable_table.left_colors[3][3], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[3]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[4]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[3], boxes_y_pos[4], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[3][1], variable_table.left_colors[4][1], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[3][2], variable_table.left_colors[4][2], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[3][3], variable_table.left_colors[4][3], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[4]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[5]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[4], boxes_y_pos[5], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[4][1], variable_table.left_colors[5][1], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[4][2], variable_table.left_colors[5][2], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[4][3], variable_table.left_colors[5][3], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[5]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[6]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[5], boxes_y_pos[6], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[5][1], variable_table.left_colors[6][1], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[5][2], variable_table.left_colors[6][2], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[5][3], variable_table.left_colors[6][3], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[6])then
        variable_table.capt_ias_y_pos = boxes_y_pos[6]
        variable_table.capt_ias_color[1] = variable_table.left_colors[6][1]
        variable_table.capt_ias_color[2] = variable_table.left_colors[6][2]
        variable_table.capt_ias_color[3] = variable_table.left_colors[6][3]
    end

    --capt ias indications
    if get(PFD_Fo_IAS) >= get(variable_table.right_values[1]) then
        variable_table.fo_ias_y_pos = boxes_y_pos[1]
        variable_table.fo_ias_color[1] = variable_table.right_colors[1][1]
        variable_table.fo_ias_color[2] = variable_table.right_colors[1][2]
        variable_table.fo_ias_color[3] = variable_table.right_colors[1][3]
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[1]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[2]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[1], boxes_y_pos[2], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[1][1], variable_table.right_colors[2][1], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[1][2], variable_table.right_colors[2][2], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[1][3], variable_table.right_colors[2][3], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[2]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[3]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[2], boxes_y_pos[3], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[2][1], variable_table.right_colors[3][1], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[2][2], variable_table.right_colors[3][2], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[2][3], variable_table.right_colors[3][3], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[3]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[4]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[3], boxes_y_pos[4], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[3][1], variable_table.right_colors[4][1], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[3][2], variable_table.right_colors[4][2], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[3][3], variable_table.right_colors[4][3], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[4]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[5]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[4], boxes_y_pos[5], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[4][1], variable_table.right_colors[5][1], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[4][2], variable_table.right_colors[5][2], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[4][3], variable_table.right_colors[5][3], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[5]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[6]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[5], boxes_y_pos[6], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[5][1], variable_table.right_colors[6][1], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[5][2], variable_table.right_colors[6][2], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[5][3], variable_table.right_colors[6][3], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[6])then
        variable_table.fo_ias_y_pos = boxes_y_pos[6]
        variable_table.fo_ias_color[1] = variable_table.right_colors[6][1]
        variable_table.fo_ias_color[2] = variable_table.right_colors[6][2]
        variable_table.fo_ias_color[3] = variable_table.right_colors[6][3]
    end
end

local function draw_limit_speeds_section_480x160(x_pos, y_pos, variable_table)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 160) / 2

    local alpha_max_alphas = {
        11,
        16,
        16,
        17,
        16,
        16
    }

    --background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 160, DARK_GREY)

    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 180, CENTER_Y + 65, "CAPT SIDE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 180, CENTER_Y + 65, "FO SIDE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)

    --capt_indications
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 5 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 4 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 3 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 2 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 1 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 0 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 5 * (5 + 110/6), 5, 110/6, variable_table.left_colors[1])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 4 * (5 + 110/6), 5, 110/6, variable_table.left_colors[2])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 3 * (5 + 110/6), 5, 110/6, variable_table.left_colors[3])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 2 * (5 + 110/6), 5, 110/6, variable_table.left_colors[4])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 1 * (5 + 110/6), 5, 110/6, variable_table.left_colors[5])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 0 * (5 + 110/6), 5, 110/6, variable_table.left_colors[6])
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 5 * (5 + 110/6) + 5, variable_table.left_speeds_names[1], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 4 * (5 + 110/6) + 5, variable_table.left_speeds_names[2], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 3 * (5 + 110/6) + 5, variable_table.left_speeds_names[3], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 2 * (5 + 110/6) + 5, variable_table.left_speeds_names[4], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 1 * (5 + 110/6) + 5, variable_table.left_speeds_names[5], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 0 * (5 + 110/6) + 5, variable_table.left_speeds_names[6], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 5 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[1])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 4 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[2])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 3 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[3])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 2 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[4])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 1 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[5])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 0 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[6])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    --Capt pointer
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 110, variable_table.capt_ias_y_pos - 3, "←", 40, false, false, TEXT_ALIGN_CENTER, variable_table.capt_ias_color)
    sasl.gl.drawRectangle(CENTER_X - 90, variable_table.capt_ias_y_pos, 40, 110/6, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 70, variable_table.capt_ias_y_pos + 5, math.floor(get(PFD_Capt_IAS)), 12, false, false, TEXT_ALIGN_CENTER, variable_table.capt_ias_color)

    --fo_indications
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 5 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 4 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 3 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 2 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 1 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 0 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 5 * (5 + 110/6), 5, 110/6, variable_table.right_colors[1])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 4 * (5 + 110/6), 5, 110/6, variable_table.right_colors[2])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 3 * (5 + 110/6), 5, 110/6, variable_table.right_colors[3])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 2 * (5 + 110/6), 5, 110/6, variable_table.right_colors[4])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 1 * (5 + 110/6), 5, 110/6, variable_table.right_colors[5])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 0 * (5 + 110/6), 5, 110/6, variable_table.right_colors[6])
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 5 * (5 + 110/6) + 5, variable_table.right_speeds_names[1], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 4 * (5 + 110/6) + 5, variable_table.right_speeds_names[2], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 3 * (5 + 110/6) + 5, variable_table.right_speeds_names[3], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 2 * (5 + 110/6) + 5, variable_table.right_speeds_names[4], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 1 * (5 + 110/6) + 5, variable_table.right_speeds_names[5], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 0 * (5 + 110/6) + 5, variable_table.right_speeds_names[6], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 5 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[1])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 4 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[2])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 3 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[3])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 2 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[4])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 1 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[5])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 0 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[6])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    --fo pointer
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 110, variable_table.fo_ias_y_pos - 3, "→", 40, false, false, TEXT_ALIGN_CENTER, variable_table.fo_ias_color)
    sasl.gl.drawRectangle(CENTER_X + 50, variable_table.fo_ias_y_pos, 40, 110/6, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 70, variable_table.fo_ias_y_pos + 5, math.floor(get(PFD_Fo_IAS)), 12, false, false, TEXT_ALIGN_CENTER, variable_table.fo_ias_color)

    --stall indications
    if (get(Capt_IAS) <= get(Capt_Valpha_prot) and get(Capt_IAS) > get(Capt_Valpha_MAX)) or (get(Fo_IAS) <= get(Fo_Valpha_prot) and get(Fo_IAS) > get(Fo_Valpha_MAX)) then
        sasl.gl.drawRectangle(CENTER_X - 40, CENTER_Y-35, 80, 80, LIGHT_GREY)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+30, "A.FLOOR", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+10, "THST PROT", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-10, "INIT AT", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-30, math.floor(get(Capt_Vtoga_prot)) .. "KTS", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
    end

    if get(Capt_IAS) <= get(Capt_Valpha_MAX) or get(Fo_IAS) <= get(Fo_Valpha_MAX) then
        sasl.gl.drawRectangle(CENTER_X - 40, CENTER_Y-35, 80, 80, LIGHT_GREY)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+30, "A.MAX", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+10, "REACHED", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-10, "MAX AOA", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-30, alpha_max_alphas[get(Flaps_internal_config) + 1] .. "°", 12, false, false, TEXT_ALIGN_CENTER, RED)
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

    --updates FBW G constraints
    if get(Flaps_handle_ratio) > 0.1 then 
        upper_g_lim = Set_anim_value(upper_g_lim, 2, -1, 2.5, 1)
        lower_g_lim = Set_anim_value(lower_g_lim, 0, -1, 2.5, 1)
    else
        upper_g_lim = Set_anim_value(upper_g_lim, 2.5, -1, 2.5, 1)
        lower_g_lim = Set_anim_value(lower_g_lim, -1, -1, 2.5, 1)
    end

    update_slats_flaps_section_480x180(Slats_flaps_section)
    update_limit_speeds_section_480x160(5 + 480 + 5, UI_scroll_y_pos - 5 - 160, Limit_speeds_section)
end

function draw()
    --draw all background
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)

    draw_flight_control_section_480x160(5, UI_scroll_y_pos - 5 - 160)
    draw_slats_flaps_section_480x180(5, UI_scroll_y_pos - 5 - 160 - 5 - 180, Slats_flaps_section)
    draw_envelop_section_480x240(5, UI_scroll_y_pos - 5 - 160 - 5 - 180 - 5 - 240)
    draw_limit_speeds_section_480x160(5 + 480 + 5, UI_scroll_y_pos - 5 - 160, Limit_speeds_section)
end