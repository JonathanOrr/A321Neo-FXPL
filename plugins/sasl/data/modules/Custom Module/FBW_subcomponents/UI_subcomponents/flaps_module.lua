function Update_slats_flaps_module_480x180(variable_table)
    --SFCC status color changes
    if get(SFCC_1_status) == 1 then
        variable_table.SFCC1_cl = LIGHT_BLUE
    else
        variable_table.SFCC1_cl = ORANGE
    end
    if get(SFCC_2_status) == 1 then
        variable_table.SFCC2_cl = LIGHT_BLUE
    else
        variable_table.SFCC2_cl = ORANGE
    end
    if get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0 then
        variable_table.SFCC1_cl = RED
        variable_table.SFCC2_cl = RED
    end

    --HYD system color changes
    if get(Hydraulic_G_press) > 1450 then
        variable_table.HYD_G_slats_cl = LIGHT_BLUE
        variable_table.HYD_G_flaps_cl = LIGHT_BLUE
    else
        variable_table.HYD_G_slats_cl = ORANGE
        variable_table.HYD_G_flaps_cl = ORANGE
    end
    if get(Hydraulic_B_press) > 1450 then
        variable_table.HYD_B_cl = LIGHT_BLUE
    else
        variable_table.HYD_B_cl = ORANGE
    end
    if get(Hydraulic_Y_press) > 1450 then
        variable_table.HYD_Y_cl = LIGHT_BLUE
    else
        variable_table.HYD_Y_cl = ORANGE
    end

    --surfaces color and dual failure colors
    variable_table.slats_half_spd = false
    variable_table.flaps_half_spd = false
    --slats
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_B_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        variable_table.slats_cl = LIGHT_BLUE
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        variable_table.slats_cl = RED
        --dual HYD failure
        if get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450 then
            variable_table.HYD_G_slats_cl = RED
            variable_table.HYD_B_cl = RED
        end
    else
        variable_table.slats_cl = ORANGE
        variable_table.slats_half_spd = true
    end

    --flaps
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_Y_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        variable_table.flaps_cl = LIGHT_BLUE
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        variable_table.flaps_cl = RED
        --dual HYD failure
        if get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450 then
            variable_table.HYD_G_flaps_cl = RED
            variable_table.HYD_Y_cl = RED
        end
    else
        variable_table.flaps_cl = ORANGE
        variable_table.flaps_half_spd = true
    end
end

function Draw_slats_flaps_module_480x180(x_pos, y_pos, variable_table)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 180) / 2
    local handle_configs = {"CLEAN", "1", "2", "3", "FULL"}
    local internal_configs = {"CLEAN", "1", "1 + F", "2", "3", "FULL"}

    --draw the background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 180, DARK_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 70, "SLATS & FLAPS", 12, false, false, TEXT_ALIGN_CENTER, WHITE)

    --slats flaps computers
    sasl.gl.drawRectangle(CENTER_X - 88, CENTER_Y + 46, 56, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 32, CENTER_Y + 46, 56, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 60, CENTER_Y + 52, "SFCC 1", 12, false, false, TEXT_ALIGN_CENTER, variable_table.SFCC1_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 60, CENTER_Y + 52, "SFCC 2", 12, false, false, TEXT_ALIGN_CENTER, variable_table.SFCC2_cl)

    --slats flaps configurations
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 25, "HANDLE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 25 - 50, "CONFIG", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawRectangle(CENTER_X - 25, CENTER_Y - 15 + 4, 50, 30, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 25, CENTER_Y - 15 + 4 - 50, 50, 30, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y, handle_configs[get(Flaps_handle_position) + 1], 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y- 50, internal_configs[get(Flaps_internal_config) + 1], 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)

    --slats
    sasl.gl.drawWideLine(CENTER_X - 40, CENTER_Y + 30 + 27 * get(Slats) / 4, CENTER_X - 220, CENTER_Y + 27 * get(Slats) / 4, Math_clamp_lower(27 * get(Slats) / 2, 1), variable_table.slats_cl)
    sasl.gl.drawWideLine(CENTER_X + 40, CENTER_Y + 30 + 27 * get(Slats) / 4, CENTER_X + 220, CENTER_Y + 27 * get(Slats) / 4, Math_clamp_lower(27 * get(Slats) / 2, 1), variable_table.slats_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 45, CENTER_Y + 15, "B", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_B_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 45, CENTER_Y + 15, "G", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_G_slats_cl)
    if variable_table.slats_half_spd == true then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X - 180, CENTER_Y - 12, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X + 180, CENTER_Y - 12, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
    end

    --flaps
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 45, CENTER_Y - 30, "G", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_G_flaps_cl)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 45, CENTER_Y - 30, "Y", 12, false, false, TEXT_ALIGN_CENTER, variable_table.HYD_Y_cl)
    if variable_table.flaps_half_spd == true then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X - 95, CENTER_Y - 30, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X + 95, CENTER_Y - 30, "HALF SPEED", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
    end
    sasl.gl.drawWideLine(CENTER_X - 110, CENTER_Y - 35 - get(Left_inboard_flaps) / 4,   CENTER_X - 40,  CENTER_Y - 35 - get(Left_inboard_flaps) / 4,   Math_clamp_lower(get(Left_inboard_flaps)/2, 1),   variable_table.flaps_cl)
    sasl.gl.drawWideLine(CENTER_X + 110, CENTER_Y - 35 - get(Right_inboard_flaps) / 4,  CENTER_X + 40,  CENTER_Y - 35 - get(Right_inboard_flaps) / 4,  Math_clamp_lower(get(Right_inboard_flaps)/2, 1),  variable_table.flaps_cl)
    sasl.gl.drawWideLine(CENTER_X - 220, CENTER_Y - 45 - get(Left_outboard_flaps) / 4,  CENTER_X - 120, CENTER_Y - 35 - get(Left_outboard_flaps) / 4,  Math_clamp_lower(get(Left_outboard_flaps)/2, 1),  variable_table.flaps_cl)
    sasl.gl.drawWideLine(CENTER_X + 220, CENTER_Y - 45 - get(Right_outboard_flaps) / 4, CENTER_X + 120, CENTER_Y - 35 - get(Right_outboard_flaps) / 4, Math_clamp_lower(get(Right_outboard_flaps)/2, 1), variable_table.flaps_cl)

    --transits
    if get(Slats_in_transit) == 1 and get(Flaps_in_transit) == 1 then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 75, "SLATS + FLAPS", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85, "IN TRANSIT", 8, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    elseif get(Slats_in_transit) == 1 then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 75, "SLATS", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85, "IN TRANSIT", 8, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    elseif get(Flaps_in_transit) == 1 then
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 75, "FLAPS", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85, "IN TRANSIT", 8, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    end
end