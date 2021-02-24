local function draw_vs_fpa_mode_indication()
    sasl.gl.drawText(Font_AirbusDUL, size[1] / 2 + 15, size[2] / 2 - 10, "V/S", 28, false, false, TEXT_ALIGN_LEFT, LED_TEXT_CL)
end

local function draw_top_text()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawText(Font_AirbusDUL, CENTER_X + 465, CENTER_Y + 20, "V/S", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X + 525, CENTER_Y + 20, "FPA", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
end

local function draw_vs_fpa_value()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    Draw_green_LED_num_and_letter(CENTER_X + 430, CENTER_Y - 36, "88", 2, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    Draw_green_LED_num_and_letter(CENTER_X + 500, CENTER_Y - 36, "", 2, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    sasl.gl.drawText(Font_7segment_led, CENTER_X + 500, CENTER_Y - 36, "oo", 58, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    Draw_green_LED_num_and_letter(CENTER_X + 380, CENTER_Y - 36, "+", 1, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
end

function FCU_draw_VS_FPA()
    draw_top_text()
    draw_vs_fpa_value()
    draw_vs_fpa_mode_indication()
end