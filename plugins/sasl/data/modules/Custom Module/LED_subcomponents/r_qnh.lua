position = {2343, 1539, 178, 85}
size = {178, 85}

local LED_font = sasl.gl.loadFont("fonts/digital-7.mono.ttf")
local LED_cl = {235/255, 200/255, 135/255}

function draw()
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, 1)
    sasl.gl.drawText(Font_AirbusDUL, size[1] / 2 + 58, size[2] / 2 + 22, "QNH", 24, false, false, TEXT_ALIGN_CENTER, LED_cl)
    Draw_green_LED_num_and_letter(size[1]/2 - 3, size[2]/2 - 34, "29", 2, 74, TEXT_ALIGN_RIGHT, 0.2, 1, 1)
    sasl.gl.drawText(LED_font, size[1] / 2, size[2] / 2 - 34, ".", 74, false, false, TEXT_ALIGN_CENTER, LED_cl)
    Draw_green_LED_num_and_letter(size[1]/2 + 36, size[2]/2 - 34, "92", 2, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
end