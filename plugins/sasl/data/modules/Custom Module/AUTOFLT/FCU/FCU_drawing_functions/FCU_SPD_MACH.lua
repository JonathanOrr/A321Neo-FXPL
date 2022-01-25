local function draw_top_text()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_SPD_or_MACH) == 0 then
        sasl.gl.drawText(Font_ECAMfont, CENTER_X - 525, CENTER_Y + 20, "SPD",  28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    end

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_SPD_or_MACH) == 1 then
        sasl.gl.drawText(Font_ECAMfont, CENTER_X - 460, CENTER_Y + 20, "MACH", 28, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    end
end

local function draw_spd_mach_value()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    local spd_mach_value = Fwd_string_fill(tostring(get(AUTOFLT_FCU_SPD)), "0", 3)
    spd_mach_value = get(AUTOFLT_FCU_SPD_or_MACH) == 1 and Fwd_string_fill(tostring(Round(get(AUTOFLT_FCU_MACH) * 100)), "0", 3) or spd_mach_value
    spd_mach_value = get(Cockpit_annnunciators_test) == 1 and "888" or spd_mach_value

    Draw_green_LED_num_and_letter(CENTER_X - 475, CENTER_Y - 36, spd_mach_value, 3, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1)

    if get(Cockpit_annnunciators_test) == 1 or get(AUTOFLT_FCU_SPD_or_MACH) == 1 then
        sasl.gl.drawText(Font_7_digits, CENTER_X - 492, CENTER_Y - 36, ".", 58, false, false, TEXT_ALIGN_CENTER, LED_TEXT_CL)
    end
end

local function draw_managed_dot()
    local CENTER_X = size[1] / 2
    local CENTER_Y = size[2] / 2

    if get(Cockpit_annnunciators_test) == 1 then
        sasl.gl.drawCircle(CENTER_X - 400, CENTER_Y - 10, 10, true, LED_TEXT_CL)
    end
end


function FCU_draw_SPD_MACH()
    draw_top_text()
    draw_spd_mach_value()
    draw_managed_dot()
end