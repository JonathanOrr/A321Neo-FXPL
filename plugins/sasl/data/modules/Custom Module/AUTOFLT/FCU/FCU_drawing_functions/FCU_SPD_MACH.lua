local function draw_top_text()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 525, CENTER_Y + 20, "SPD",  28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 460, CENTER_Y + 20, "MACH", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
end

local function draw_spd_mach_value()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    Draw_green_LED_num_and_letter(CENTER_X - 475, CENTER_Y - 36, "888", 3, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
end

local function draw_managed_dot()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawCircle(CENTER_X - 400, CENTER_Y - 10, 10, true, LED_TEXT_CL)
end


function FCU_draw_SPD_MACH()
    draw_top_text()
    draw_spd_mach_value()
    draw_managed_dot()
end