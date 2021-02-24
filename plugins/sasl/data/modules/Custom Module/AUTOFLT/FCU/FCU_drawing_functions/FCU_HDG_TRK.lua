local function draw_hdg_track_mode_indication()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 15, CENTER_Y - 10, "HDG", 28, false, false, TEXT_ALIGN_RIGHT, LED_TEXT_CL)
end

local function draw_top_text()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 290, CENTER_Y + 20, "HDG", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 235, CENTER_Y + 20, "TRK", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 180, CENTER_Y + 20, "LAT", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
end

local function draw_hdg_trk_value()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    Draw_green_LED_num_and_letter(CENTER_X - 255, CENTER_Y - 36, "888", 3, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
end

local function draw_managed_dot()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    sasl.gl.drawCircle(CENTER_X - 180, CENTER_Y -10, 10, true, LED_TEXT_CL)
end

function FCU_draw_HDG_TRK()
    draw_top_text()
    draw_hdg_trk_value()
    draw_managed_dot()
    draw_hdg_track_mode_indication()
end