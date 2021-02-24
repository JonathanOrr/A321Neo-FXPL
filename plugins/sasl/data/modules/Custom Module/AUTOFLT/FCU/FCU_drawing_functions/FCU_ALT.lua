local function draw_top_text()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawText(Font_AirbusDUL, CENTER_X + 235, CENTER_Y + 20, "ALT", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)

    sasl.gl.drawWideLine(CENTER_X + 265, CENTER_Y + 28, CENTER_X + 305, CENTER_Y + 28, 4, LED_TEXT_CL)
    sasl.gl.drawWideLine(CENTER_X + 405, CENTER_Y + 28, CENTER_X + 435, CENTER_Y + 28, 4, LED_TEXT_CL)
    sasl.gl.drawWideLine(CENTER_X + 267, CENTER_Y + 30, CENTER_X + 267, CENTER_Y + 20, 4, LED_TEXT_CL)
    sasl.gl.drawWideLine(CENTER_X + 433, CENTER_Y + 30, CENTER_X + 433, CENTER_Y + 20, 4, LED_TEXT_CL)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X + 355, CENTER_Y + 20, "LVL/CH", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
end

local function draw_alt_value()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    Draw_green_LED_num_and_letter(CENTER_X + 235, CENTER_Y - 36, "88888", 5, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
end

local function draw_managed_dot()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawCircle(CENTER_X + 342, CENTER_Y - 10, 10, true, LED_TEXT_CL)
end


function FCU_draw_ALT()
    draw_top_text()
    draw_alt_value()
    draw_managed_dot()
end