position = {1717, 1405, 160, 61}
size = {160, 61}

local LED_cl = {235/255, 200/255, 135/255}

function draw()
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 + 10, size[2] / 2 - 25, math.floor(math.abs(get(Elec_bat_2_V))), 2, 74, TEXT_ALIGN_RIGHT, 0.2, 1, 1)
    sasl.gl.drawText(Font_7_digits, size[1] / 2 + 16, size[2] / 2 - 25, ".", 74, false, false, TEXT_ALIGN_CENTER, LED_cl)
    Draw_green_LED_num_and_letter(size[1] / 2 + 40, size[2] / 2 - 25, Math_extract_decimal(get(Elec_bat_2_V), 1, true), 1, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
end
