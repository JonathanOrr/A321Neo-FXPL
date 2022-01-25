local function draw_vs_fpa_mode_indication()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 0 then
        sasl.gl.drawText(Font_ECAMfont, CENTER_X + 15, CENTER_Y - 10, "V/S", 28, false, false, TEXT_ALIGN_LEFT, LED_TEXT_CL)
    end

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 1 then
        sasl.gl.drawText(Font_ECAMfont, CENTER_X + 15, CENTER_Y - 35, "FPA", 28, false, false, TEXT_ALIGN_LEFT, LED_TEXT_CL)
    end
end

local function draw_top_text()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 0 then
        sasl.gl.drawText(Font_ECAMfont, CENTER_X + 465, CENTER_Y + 20, "V/S", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    end

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 1 then
        sasl.gl.drawText(Font_ECAMfont, CENTER_X + 525, CENTER_Y + 20, "FPA", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    end
end

local function draw_vs_fpa_value()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    local vs_fpa_value = Fwd_string_fill(tostring(math.abs(get(AUTOFLT_FCU_VS)) / 100), "0", 2)
    vs_fpa_value = get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 1 and Fwd_string_fill(tostring(Round(math.abs(get(AUTOFLT_FCU_FPA)) * 10)), "0", 2) or vs_fpa_value
    vs_fpa_value = get(Cockpit_annnunciators_test) == 1 and "88" or vs_fpa_value
    local vs_fpa_sign = get(AUTOFLT_FCU_VS) >= 0 and "+" or "-"
    vs_fpa_sign = get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 1 and (get(AUTOFLT_FCU_FPA) >= 0 and "+" or "-") or vs_fpa_sign
    vs_fpa_sign = get(Cockpit_annnunciators_test) == 1 and "+" or vs_fpa_sign

    Draw_green_LED_num_and_letter(CENTER_X + 430, CENTER_Y - 36, vs_fpa_value, 2, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 1 then
        sasl.gl.drawText(Font_7_digits, CENTER_X + 430, CENTER_Y - 36, ".", 58, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    end

    if get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 0 then
        Draw_green_LED_num_and_letter(CENTER_X + 500, CENTER_Y - 36, "", 2, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
        sasl.gl.drawText(Font_7segment_led, CENTER_X + 500, CENTER_Y - 36, "oo", 58, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    end

    Draw_green_LED_num_and_letter(CENTER_X + 380, CENTER_Y - 36, vs_fpa_sign, 1, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)
end

function FCU_draw_VS_FPA()
    draw_top_text()
    draw_vs_fpa_value()
    draw_vs_fpa_mode_indication()
end