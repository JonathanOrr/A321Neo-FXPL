function Draw_LAW_MODE_module_480x240(x_pos, y_pos)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 240) / 2

    sasl.gl.drawRectangle(CENTER_X - 240, CENTER_Y - 120, 480, 240, DARK_GREY)

    local fbw_vertical_modes_names = {
        "GROUND",
        "ROTATION",
        "FLIGHT",
        "FLARE",
        "GROUND",
    }

    local fbw_vertical_modes = {
        get(FBW_vertical_ground_mode_ratio),
        get(FBW_vertical_rotation_mode_ratio),
        get(FBW_vertical_flight_mode_ratio),
        get(FBW_vertical_flare_mode_ratio),
        get(FBW_vertical_ground_mode_ratio),
    }

    for i = 1, 5 do
        sasl.gl.drawRectangle(CENTER_X - 235 + (90 + 5) * (i - 1), CENTER_Y + 69, 90, 26, LIGHT_GREY)
        sasl.gl.drawRectangle(CENTER_X - 235 + (90 + 5) * (i - 1), CENTER_Y + 69, 90, 26 * fbw_vertical_modes[i], LIGHT_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 235 + (90 + 5) * (i - 1) + 45, CENTER_Y + 69 + 7, fbw_vertical_modes_names[i], 18, false, false, TEXT_ALIGN_CENTER, WHITE)
    end

    local fbw_lateral_modes_names = {
        "GROUND",
        "FLIGHT",
        "GROUND",
    }

    local fbw_lateral_modes = {
        get(FBW_lateral_ground_mode_ratio),
        get(FBW_lateral_flight_mode_ratio),
        get(FBW_lateral_ground_mode_ratio),
    }

    for i = 1, 3 do
        sasl.gl.drawRectangle(CENTER_X - 235 + (153.5 + 5) * (i - 1), CENTER_Y + 18, 153.5, 26, LIGHT_GREY)
        sasl.gl.drawRectangle(CENTER_X - 235 + (153.5 + 5) * (i - 1), CENTER_Y + 18, 153.5, 26 * fbw_lateral_modes[i], LIGHT_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 235 + (153.5 + 5) * (i - 1) + (153.5) / 2, CENTER_Y + 18 + 7, fbw_lateral_modes_names[i], 18, false, false, TEXT_ALIGN_CENTER, WHITE)
    end

    local fbw_total_laws_names = {
        {"MECH", true},
        {"ABNORMAL", true},
        {"DIRECT", true},
        {"ALT", true},
        {"ALT PROT", true},
        {"NORMAL", true},
    }

    local fbw_lateral_laws_names = {
        {"MECH", false},
        {"ABNORMAL", true},
        {"DIRECT", true},
        {"ALT", false},
        {"ALT PROT", false},
        {"NORMAL", true},
    }

    local fbw_vertical_laws_names = {
        {"MECH", false},
        {"ABNORMAL", true},
        {"DIRECT", true},
        {"ALT", true},
        {"ALT PROT", true},
        {"NORMAL", true},
    }

    local fbw_yaw_laws_names = {
        {"MECH", true},
        {"ABNORMAL", true},
        {"DIRECT", true},
        {"ALT", true},
        {"ALT PROT", false},
        {"NORMAL", true},
    }

    for i = 1, 6 do
        sasl.gl.drawRectangle(CENTER_X - 235 + (74 + 5) * (i - 1), CENTER_Y - 27, 74, 26, (get(FBW_total_control_law) + 3) == i and LIGHT_BLUE or LIGHT_GREY)
        sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 235 + (74 + 5) * (i - 1) + 74/2, CENTER_Y - 27 + 8, fbw_total_laws_names[i][1], 14, false, false, TEXT_ALIGN_CENTER, WHITE)
    end

    for i = 1, 6 do
        if fbw_vertical_laws_names[i][2] then
            sasl.gl.drawRectangle(CENTER_X - 235 + (74 + 5) * (i - 1), CENTER_Y - 57, 74, 26, (get(FBW_vertical_law) + 3) == i and LIGHT_BLUE or LIGHT_GREY)
            sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 235 + (74 + 5) * (i - 1) + 74/2, CENTER_Y - 57 + 8, fbw_vertical_laws_names[i][1], 14, false, false, TEXT_ALIGN_CENTER, WHITE)
        end
    end

    for i = 1, 6 do
        if fbw_lateral_laws_names[i][2] then
            sasl.gl.drawRectangle(CENTER_X - 235 + (74 + 5) * (i - 1), CENTER_Y - 87, 74, 26, (get(FBW_lateral_law) + 3) == i and LIGHT_BLUE or LIGHT_GREY)
            sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 235 + (74 + 5) * (i - 1) + 74/2, CENTER_Y - 87 + 8, fbw_lateral_laws_names[i][1], 14, false, false, TEXT_ALIGN_CENTER, WHITE)
        end
    end

    for i = 1, 6 do
        if fbw_yaw_laws_names[i][2] then
            sasl.gl.drawRectangle(CENTER_X - 235 + (74 + 5) * (i - 1), CENTER_Y - 117, 74, 26, (get(FBW_yaw_law) + 3) == i and LIGHT_BLUE or LIGHT_GREY)
            sasl.gl.drawText(Font_AirbusDUL, CENTER_X - 235 + (74 + 5) * (i - 1) + 74/2, CENTER_Y - 117 + 8, fbw_yaw_laws_names[i][1], 14, false, false, TEXT_ALIGN_CENTER, WHITE)
        end
    end

    sasl.gl.drawText(Font_AirbusDUL, CENTER_X, CENTER_Y + 120 - 18, "VERTICAL MODES", 14, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X, CENTER_Y + 120 - 18 - 26 - 20 - 5, "LATERAL MODES", 14, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X, CENTER_Y + 120 - 26 - 20 - 20 - 50, "CONTROL LAW: TOTAL -> LAT -> VERT -> YAW", 14, false, false, TEXT_ALIGN_CENTER, WHITE)
end