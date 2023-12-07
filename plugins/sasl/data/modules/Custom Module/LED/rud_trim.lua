position = {1914, 1405, 147, 57}
size = {147, 57}

local LED_font = sasl.gl.loadFont("fonts/digital-7.mono.ttf")
local LED_text_cl = {235/255, 200/255, 135/255}

function draw()
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 - 55, size[2] / 2 - 24, get(RUD_TRIM_ANGLE) >= 0 and "R" or "L",            1, 68, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 + 30, size[2] / 2 - 24, math.floor(math.abs(get(RUD_TRIM_ANGLE))),          2, 68, TEXT_ALIGN_RIGHT, 0.2, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 + 55, size[2] / 2 - 24, Math_extract_decimal(get(RUD_TRIM_ANGLE), 1, true), 1, 68, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    sasl.gl.drawText(LED_font, size[1] / 2 + 35, size[2] / 2 - 24, ".", 68, false, false, TEXT_ALIGN_CENTER, {LED_text_cl[1], LED_text_cl[2], LED_text_cl[3], 1})
end