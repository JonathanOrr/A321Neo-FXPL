size = {1000, 600}

--colors
local RED = {1, 0, 0}
local ORANGE = {1, 0.55, 0.15}
local WHITE = {1.0, 1.0, 1.0}
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

--fbw constraints
local upper_g_lim = 2.5
local lower_g_lim = -1

--local module positions
local flight_control_section_y_pos = size[2] - 5 - 400

--sectional drawing functions
local function draw_flight_control_section_480x400(x_pos, y_pos)
    --draw the background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 400, DARK_GREY)
    sasl.gl.drawTexture(aircraft_behind_img, (2 * x_pos + 480) / 2 - 474/2, y_pos + 400 - 158, 474, 158, {1,1,1})

    --draw control surfaces indications
    --spoilers
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 65, y_pos + 400 - 158 + 50, (2 * x_pos + 480) / 2 - 65, y_pos + 400 - 158 + 50 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 95, y_pos + 400 - 158 + 52, (2 * x_pos + 480) / 2 - 95, y_pos + 400 - 158 + 52 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 115, y_pos + 400 - 158 + 54, (2 * x_pos + 480) / 2 - 115, y_pos + 400 - 158 + 54 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 135, y_pos + 400 - 158 + 56, (2 * x_pos + 480) / 2 - 135, y_pos + 400 - 158 + 56 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 155, y_pos + 400 - 158 + 58, (2 * x_pos + 480) / 2 - 155, y_pos + 400 - 158 + 58 + 50, 5, LIGHT_GREY)

    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 65, y_pos + 400 - 158 + 50, (2 * x_pos + 480) / 2 + 65, y_pos + 400 - 158 + 50 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 95, y_pos + 400 - 158 + 52, (2 * x_pos + 480) / 2 + 95, y_pos + 400 - 158 + 52 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 115, y_pos + 400 - 158 + 54, (2 * x_pos + 480) / 2 + 115, y_pos + 400 - 158 + 54 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 135, y_pos + 400 - 158 + 56, (2 * x_pos + 480) / 2 + 135, y_pos + 400 - 158 + 56 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 155, y_pos + 400 - 158 + 58, (2 * x_pos + 480) / 2 + 155, y_pos + 400 - 158 + 58 + 50, 5, LIGHT_GREY)

    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 65, y_pos + 400 - 158 + 50, (2 * x_pos + 480) / 2 - 65, y_pos + 400 - 158 + 50 + get(Left_inboard_spoilers), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 95, y_pos + 400 - 158 + 52, (2 * x_pos + 480) / 2 - 95, y_pos + 400 - 158 + 52 + get(Left_outboard_spoilers2), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 115, y_pos + 400 - 158 + 54, (2 * x_pos + 480) / 2 - 115, y_pos + 400 - 158 + 54 + get(Left_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 135, y_pos + 400 - 158 + 56, (2 * x_pos + 480) / 2 - 135, y_pos + 400 - 158 + 56 + get(Left_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 155, y_pos + 400 - 158 + 58, (2 * x_pos + 480) / 2 - 155, y_pos + 400 - 158 + 58 + get(Left_outboard_spoilers345), 5, LIGHT_BLUE)

    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 65, y_pos + 400 - 158 + 50, (2 * x_pos + 480) / 2 + 65, y_pos + 400 - 158 + 50 + get(Right_inboard_spoilers), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 95, y_pos + 400 - 158 + 52, (2 * x_pos + 480) / 2 + 95, y_pos + 400 - 158 + 52 + get(Right_outboard_spoilers2), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 115, y_pos + 400 - 158 + 54, (2 * x_pos + 480) / 2 + 115, y_pos + 400 - 158 + 54 + get(Right_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 135, y_pos + 400 - 158 + 56, (2 * x_pos + 480) / 2 + 135, y_pos + 400 - 158 + 56 + get(Right_outboard_spoilers345), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 155, y_pos + 400 - 158 + 58, (2 * x_pos + 480) / 2 + 155, y_pos + 400 - 158 + 58 + get(Right_outboard_spoilers345), 5, LIGHT_BLUE)

    --ailerons
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 185, y_pos + 400 - 158 + 30, (2 * x_pos + 480) / 2 - 185, y_pos + 400 - 158 + 30 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 185, y_pos + 400 - 158 + 30, (2 * x_pos + 480) / 2 + 185, y_pos + 400 - 158 + 30 + 50, 5, LIGHT_GREY)

    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 185, y_pos + 400 - 158 + 30 + 25, (2 * x_pos + 480) / 2 - 185, y_pos + 400 - 158 + 30 + 25 - get(Left_aileron), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 185, y_pos + 400 - 158 + 30 + 25, (2 * x_pos + 480) / 2 + 185, y_pos + 400 - 158 + 30 + 25 - get(Right_aileron), 5, LIGHT_BLUE)

    --elevators
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 45, y_pos + 400 - 158 + 49, (2 * x_pos + 480) / 2 - 45, y_pos + 400 - 158 + 49 + 47, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 45, y_pos + 400 - 158 + 49, (2 * x_pos + 480) / 2 + 45, y_pos + 400 - 158 + 49 + 47, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 45, y_pos + 400 - 158 + 49 + 17, (2 * x_pos + 480) / 2 - 45, y_pos + 400 - 158 + 49 + 17 - get(Elevators_hstab_1), 5, LIGHT_BLUE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + 45, y_pos + 400 - 158 + 49 + 17, (2 * x_pos + 480) / 2 + 45, y_pos + 400 - 158 + 49 + 17 - get(Elevators_hstab_1), 5, LIGHT_BLUE)

    --rudder
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 30, y_pos + 400 - 158 + 130, (2 * x_pos + 480) / 2 + 30, y_pos + 400 - 158 + 130, 5, LIGHT_GREY)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 - 30, y_pos + 400 - 158 + 130, (2 * x_pos + 480) / 2 - get(Yaw_lim), y_pos + 400 - 158 + 130, 5, ORANGE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2 + get(Yaw_lim), y_pos + 400 - 158 + 130, (2 * x_pos + 480) / 2 + 30, y_pos + 400 - 158 + 130, 5, ORANGE)
    sasl.gl.drawWideLine( (2 * x_pos + 480) / 2, y_pos + 400 - 158 + 130, (2 * x_pos + 480) / 2 + get(Rudder), y_pos + 400 - 158 + 130, 5, LIGHT_BLUE)


    --draw roll control ring
    --bank angle indications
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, -67, 134, WHITE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 113, 134, WHITE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, -get(Flightmodel_roll), RED)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 180, -get(Flightmodel_roll), RED)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, Math_clamp(-get(Flightmodel_roll), -125, 125), ORANGE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 180, Math_clamp(-get(Flightmodel_roll), -125, 125), ORANGE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, Math_clamp(-get(Flightmodel_roll), -67, 67), LIGHT_BLUE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 180, Math_clamp(-get(Flightmodel_roll), -67, 67), LIGHT_BLUE)
    --roll rate indications
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 94, 101, -15, 30, WHITE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 165, 30, WHITE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 0, -get(Roll_rate), ORANGE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 180, -get(Roll_rate), ORANGE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 0, Math_clamp(-get(Roll_rate), -15, 15), LIGHT_BLUE)
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 180, Math_clamp(-get(Roll_rate), -15, 15), LIGHT_BLUE)
    --aircraft image
    sasl.gl.drawRotatedTextureCenter (aircraft_behind_img, get(Flightmodel_roll), (2 * x_pos + 480)/ 4, y_pos + 125, (2 * x_pos + 480)/ 4 - (160 / 2), y_pos + 125 - (53 /2) + 6, 160, 53, {1,1,1})
    --text indications
    sasl.gl.drawArc((2 * x_pos + 480) / 4, y_pos + 125, 20, 92, 270- 40, 80, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, (2 * x_pos + 480) / 4, y_pos + 125 - 35, "ROLL", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, (2 * x_pos + 480) / 4, y_pos + 125 - 50, string.format("%.2f", tostring(get(Flightmodel_roll))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, (2 * x_pos + 480) / 4, y_pos + 125 - 65, "ROLL RATE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, (2 * x_pos + 480) / 4, y_pos + 125 - 80, string.format("%.1f", tostring(get(Roll_rate))) .. "°/S", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)


    --draw G load control ring
    --pitch indications
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, -15, 45, WHITE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 165, 45, WHITE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, get(Flightmodel_pitch), RED)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 180, get(Flightmodel_pitch), RED)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, Math_clamp(get(Flightmodel_pitch), -30, 50), ORANGE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 180, Math_clamp(get(Flightmodel_pitch), -30, 50), ORANGE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 0, Math_clamp(get(Flightmodel_pitch), -15, 30), LIGHT_BLUE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 103, 110, 180, Math_clamp(get(Flightmodel_pitch), -15, 30), LIGHT_BLUE)
    --g load indications
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 94, 101, (lower_g_lim) * 10, (upper_g_lim -lower_g_lim) * 10, WHITE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 180 + (lower_g_lim ) * 10, (upper_g_lim -lower_g_lim) * 10, WHITE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 0, get(Total_vertical_g_load) * 10, ORANGE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 180, get(Total_vertical_g_load) * 10, ORANGE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 0, Math_clamp(get(Total_vertical_g_load) * 10, lower_g_lim * 10, upper_g_lim * 10), LIGHT_BLUE)
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 94, 101, 180, Math_clamp(get(Total_vertical_g_load) * 10, lower_g_lim * 10, upper_g_lim * 10), LIGHT_BLUE)
    --aircraft image
    sasl.gl.drawRotatedTextureCenter (aircraft_side_img, -get(Flightmodel_pitch), 3 * (2 * x_pos + 480) / 4, y_pos + 125, 3 * (2 * x_pos + 480) / 4 - (160 / 2), y_pos + 125 - (53 /2) + 12, 160, 53, {1,1,1})
    --text indications
    sasl.gl.drawArc(3 * (2 * x_pos + 480) / 4, y_pos + 125, 20, 92, 270- 40, 80, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, 3 * (2 * x_pos + 480) / 4, y_pos + 125 - 35, "PITCH", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, 3 * (2 * x_pos + 480) / 4, y_pos + 125 - 50, string.format("%.2f", tostring(get(Flightmodel_pitch))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, 3 * (2 * x_pos + 480) / 4, y_pos + 125 - 65, "G LOAD", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, 3 * (2 * x_pos + 480) / 4, y_pos + 125 - 80, string.format("%.1f", tostring(get(Total_vertical_g_load))) .. "G", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)


    --sasl.gl.drawLine((2 * x_pos + 480) / 4, 0, (2 * x_pos + 480) / 4, size[2], LIGHT_BLUE)
    --sasl.gl.drawLine(0,  y_pos + 125, size[1],  y_pos + 125, LIGHT_BLUE)

    --sasl.gl.drawLine(3 * (2 * x_pos + 480) / 4, 0, 3 * (2 * x_pos + 480) / 4, size[2], LIGHT_BLUE)
    --sasl.gl.drawLine(0,  y_pos + 125, size[1],  y_pos + 125, LIGHT_BLUE)

end

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    --scrolling target speed
    flight_control_section_y_pos = Math_clamp( flight_control_section_y_pos + value, 5, size[2] - 5 - 400)
end

function update()
    if SSS_FBW_UI:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideFBWUI, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideFBWUI, MENU_UNCHECKED)
    end

    --updates FBW G constraints
    if get(Flaps_handle_ratio) > 0.1 then 
        upper_g_lim = Set_anim_value(upper_g_lim, 2, -1, 2.5, 1)
        lower_g_lim = Set_anim_value(lower_g_lim, 0, -1, 2.5, 1)
    else
        upper_g_lim = Set_anim_value(upper_g_lim, 2.5, -1, 2.5, 1)
        lower_g_lim = Set_anim_value(lower_g_lim, -1, -1, 2.5, 1)
    end

end

function draw()
    --draw all background
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)

    draw_flight_control_section_480x400(5, flight_control_section_y_pos)
end