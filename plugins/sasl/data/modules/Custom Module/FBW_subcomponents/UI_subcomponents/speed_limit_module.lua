function Update_limit_speeds_module_480x160(x_pos, y_pos, variable_table)
    variable_table.left_speeds_names = {"VMAX", "S SPD", "F SPD", "VLS", "A.PROT", "A.MAX"}
    variable_table.right_speeds_names = {"VMAX", "S SPD", "F SPD", "VLS", "A.PROT", "A.MAX"}
    variable_table.left_values = {Capt_VMAX, S_speed, F_speed, VLS, Capt_Vaprot_vsw, Capt_Valpha_MAX}
    variable_table.right_values = {Fo_VMAX, S_speed, F_speed, VLS, Fo_Vaprot_vsw, Fo_Valpha_MAX}
    variable_table.left_colors = {RED, GREEN, GREEN, ORANGE, ORANGE, RED}
    variable_table.right_colors = {RED, GREEN, GREEN, ORANGE, ORANGE, RED}

    variable_table.capt_ias_color = {1,1,1}
    variable_table.fo_ias_color = {1,1,1}
    variable_table.capt_ias_y_pos = y_pos + 5 + 0 * (5 + 110/6)
    variable_table.fo_ias_y_pos = y_pos + 5 + 0 * (5 + 110/6)

    local boxes_y_pos = {
        y_pos + 5 + 5 * (5 + 110/6),
        y_pos + 5 + 4 * (5 + 110/6),
        y_pos + 5 + 3 * (5 + 110/6),
        y_pos + 5 + 2 * (5 + 110/6),
        y_pos + 5 + 1 * (5 + 110/6),
        y_pos + 5 + 0 * (5 + 110/6)
    }

    --sort capt speeds large to small
    local l_name_swapping_buffer = 0
    local l_value_swapping_buffer = 0
    local l_color_swapping_buffer = 0

    for i = 1, #variable_table.left_values do
        for j = i + 1, #variable_table.left_values do
            if get(variable_table.left_values[i]) < get(variable_table.left_values[j]) then
                --record into buffer pre-swap
                l_name_swapping_buffer = variable_table.left_speeds_names[i]
                l_value_swapping_buffer = variable_table.left_values[i]
                l_color_swapping_buffer = variable_table.left_colors[i]
                --swap the higher one to the current position
                variable_table.left_speeds_names[i] = variable_table.left_speeds_names[j]
                variable_table.left_values[i] = variable_table.left_values[j]
                variable_table.left_colors[i] = variable_table.left_colors[j]
                --put the lower one back in
                variable_table.left_speeds_names[j] = l_name_swapping_buffer
                variable_table.left_values[j] = l_value_swapping_buffer
                variable_table.left_colors[j] = l_color_swapping_buffer
            end
        end
    end

    --sort fo speeds large to small
    local r_name_swapping_buffer = 0
    local r_value_swapping_buffer = 0
    local r_color_swapping_buffer = 0

    for i = 1, #variable_table.right_values do
        for j = i + 1, #variable_table.right_values do
            if get(variable_table.right_values[i]) < get(variable_table.right_values[j]) then
                --record into buffer pre-swap
                r_name_swapping_buffer = variable_table.right_speeds_names[i]
                r_value_swapping_buffer = variable_table.right_values[i]
                r_color_swapping_buffer = variable_table.right_colors[i]
                --swap the higher one to the current position
                variable_table.right_speeds_names[i] = variable_table.right_speeds_names[j]
                variable_table.right_values[i] = variable_table.right_values[j]
                variable_table.right_colors[i] = variable_table.right_colors[j]
                --put the lower one back in
                variable_table.right_speeds_names[j] = r_name_swapping_buffer
                variable_table.right_values[j] = r_value_swapping_buffer
                variable_table.right_colors[j] = r_color_swapping_buffer
            end
        end
    end

    --capt ias indications
    if get(PFD_Capt_IAS) >= get(variable_table.left_values[1]) then
        variable_table.capt_ias_y_pos = boxes_y_pos[1]
        variable_table.capt_ias_color[1] = variable_table.left_colors[1][1]
        variable_table.capt_ias_color[2] = variable_table.left_colors[1][2]
        variable_table.capt_ias_color[3] = variable_table.left_colors[1][3]
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[1]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[2]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[1], boxes_y_pos[2], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[1][1], variable_table.left_colors[2][1], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[1][2], variable_table.left_colors[2][2], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[1][3], variable_table.left_colors[2][3], (get(variable_table.left_values[1]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[1]) - get(variable_table.left_values[2])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[2]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[3]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[2], boxes_y_pos[3], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[2][1], variable_table.left_colors[3][1], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[2][2], variable_table.left_colors[3][2], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[2][3], variable_table.left_colors[3][3], (get(variable_table.left_values[2]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[2]) - get(variable_table.left_values[3])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[3]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[4]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[3], boxes_y_pos[4], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[3][1], variable_table.left_colors[4][1], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[3][2], variable_table.left_colors[4][2], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[3][3], variable_table.left_colors[4][3], (get(variable_table.left_values[3]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[3]) - get(variable_table.left_values[4])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[4]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[5]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[4], boxes_y_pos[5], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[4][1], variable_table.left_colors[5][1], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[4][2], variable_table.left_colors[5][2], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[4][3], variable_table.left_colors[5][3], (get(variable_table.left_values[4]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[4]) - get(variable_table.left_values[5])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[5]) and get(PFD_Capt_IAS) >= get(variable_table.left_values[6]) then
        --lerp the differnce between the difference values
        variable_table.capt_ias_y_pos = Math_lerp(boxes_y_pos[5], boxes_y_pos[6], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
        variable_table.capt_ias_color[1] = Math_lerp(variable_table.left_colors[5][1], variable_table.left_colors[6][1], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
        variable_table.capt_ias_color[2] = Math_lerp(variable_table.left_colors[5][2], variable_table.left_colors[6][2], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
        variable_table.capt_ias_color[3] = Math_lerp(variable_table.left_colors[5][3], variable_table.left_colors[6][3], (get(variable_table.left_values[5]) - get(PFD_Capt_IAS)) / (get(variable_table.left_values[5]) - get(variable_table.left_values[6])))
    elseif get(PFD_Capt_IAS) < get(variable_table.left_values[6])then
        variable_table.capt_ias_y_pos = boxes_y_pos[6]
        variable_table.capt_ias_color[1] = variable_table.left_colors[6][1]
        variable_table.capt_ias_color[2] = variable_table.left_colors[6][2]
        variable_table.capt_ias_color[3] = variable_table.left_colors[6][3]
    end

    --capt ias indications
    if get(PFD_Fo_IAS) >= get(variable_table.right_values[1]) then
        variable_table.fo_ias_y_pos = boxes_y_pos[1]
        variable_table.fo_ias_color[1] = variable_table.right_colors[1][1]
        variable_table.fo_ias_color[2] = variable_table.right_colors[1][2]
        variable_table.fo_ias_color[3] = variable_table.right_colors[1][3]
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[1]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[2]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[1], boxes_y_pos[2], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[1][1], variable_table.right_colors[2][1], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[1][2], variable_table.right_colors[2][2], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[1][3], variable_table.right_colors[2][3], (get(variable_table.right_values[1]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[1]) - get(variable_table.right_values[2])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[2]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[3]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[2], boxes_y_pos[3], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[2][1], variable_table.right_colors[3][1], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[2][2], variable_table.right_colors[3][2], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[2][3], variable_table.right_colors[3][3], (get(variable_table.right_values[2]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[2]) - get(variable_table.right_values[3])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[3]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[4]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[3], boxes_y_pos[4], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[3][1], variable_table.right_colors[4][1], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[3][2], variable_table.right_colors[4][2], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[3][3], variable_table.right_colors[4][3], (get(variable_table.right_values[3]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[3]) - get(variable_table.right_values[4])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[4]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[5]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[4], boxes_y_pos[5], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[4][1], variable_table.right_colors[5][1], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[4][2], variable_table.right_colors[5][2], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[4][3], variable_table.right_colors[5][3], (get(variable_table.right_values[4]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[4]) - get(variable_table.right_values[5])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[5]) and get(PFD_Fo_IAS) >= get(variable_table.right_values[6]) then
        --lerp the differnce between the difference values
        variable_table.fo_ias_y_pos = Math_lerp(boxes_y_pos[5], boxes_y_pos[6], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
        variable_table.fo_ias_color[1] = Math_lerp(variable_table.right_colors[5][1], variable_table.right_colors[6][1], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
        variable_table.fo_ias_color[2] = Math_lerp(variable_table.right_colors[5][2], variable_table.right_colors[6][2], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
        variable_table.fo_ias_color[3] = Math_lerp(variable_table.right_colors[5][3], variable_table.right_colors[6][3], (get(variable_table.right_values[5]) - get(PFD_Fo_IAS)) / (get(variable_table.right_values[5]) - get(variable_table.right_values[6])))
    elseif get(PFD_Fo_IAS) < get(variable_table.right_values[6])then
        variable_table.fo_ias_y_pos = boxes_y_pos[6]
        variable_table.fo_ias_color[1] = variable_table.right_colors[6][1]
        variable_table.fo_ias_color[2] = variable_table.right_colors[6][2]
        variable_table.fo_ias_color[3] = variable_table.right_colors[6][3]
    end
end

function Draw_limit_speeds_module_480x160(x_pos, y_pos, variable_table)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 160) / 2

    local alpha_max_alphas = {
        10.5,
        16.5,
        16.5,
        16.5,
        16.0,
        17.5
    }

    --background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 160, DARK_GREY)

    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 180, CENTER_Y + 65, "CAPT SIDE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 180, CENTER_Y + 65, "FO SIDE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)

    --capt_indications
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 5 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 4 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 3 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 2 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 1 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 0 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 5 * (5 + 110/6), 5, 110/6, variable_table.left_colors[1])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 4 * (5 + 110/6), 5, 110/6, variable_table.left_colors[2])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 3 * (5 + 110/6), 5, 110/6, variable_table.left_colors[3])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 2 * (5 + 110/6), 5, 110/6, variable_table.left_colors[4])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 1 * (5 + 110/6), 5, 110/6, variable_table.left_colors[5])
    sasl.gl.drawRectangle(CENTER_X - 230, y_pos + 5 + 0 * (5 + 110/6), 5, 110/6, variable_table.left_colors[6])
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 5 * (5 + 110/6) + 5, variable_table.left_speeds_names[1], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 4 * (5 + 110/6) + 5, variable_table.left_speeds_names[2], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 3 * (5 + 110/6) + 5, variable_table.left_speeds_names[3], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 2 * (5 + 110/6) + 5, variable_table.left_speeds_names[4], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 1 * (5 + 110/6) + 5, variable_table.left_speeds_names[5], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 220, y_pos + 5 + 0 * (5 + 110/6) + 5, variable_table.left_speeds_names[6], 12, false, false, TEXT_ALIGN_LEFT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 5 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[1])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 4 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[2])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 3 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[3])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 2 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[4])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 1 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[5])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 150, y_pos + 5 + 0 * (5 + 110/6) + 5, math.floor(get(variable_table.left_values[6])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    --Capt pointer
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 110, variable_table.capt_ias_y_pos - 3, "←", 40, false, false, TEXT_ALIGN_CENTER, variable_table.capt_ias_color)
    sasl.gl.drawRectangle(CENTER_X - 90, variable_table.capt_ias_y_pos, 40, 110/6, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 70, variable_table.capt_ias_y_pos + 5, math.floor(get(PFD_Capt_IAS)), 12, false, false, TEXT_ALIGN_CENTER, variable_table.capt_ias_color)

    --fo_indications
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 5 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 4 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 3 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 2 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 1 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 130, y_pos + 5 + 0 * (5 + 110/6), 100, 110/6, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 5 * (5 + 110/6), 5, 110/6, variable_table.right_colors[1])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 4 * (5 + 110/6), 5, 110/6, variable_table.right_colors[2])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 3 * (5 + 110/6), 5, 110/6, variable_table.right_colors[3])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 2 * (5 + 110/6), 5, 110/6, variable_table.right_colors[4])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 1 * (5 + 110/6), 5, 110/6, variable_table.right_colors[5])
    sasl.gl.drawRectangle(CENTER_X + 225, y_pos + 5 + 0 * (5 + 110/6), 5, 110/6, variable_table.right_colors[6])
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 5 * (5 + 110/6) + 5, variable_table.right_speeds_names[1], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 4 * (5 + 110/6) + 5, variable_table.right_speeds_names[2], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 3 * (5 + 110/6) + 5, variable_table.right_speeds_names[3], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 2 * (5 + 110/6) + 5, variable_table.right_speeds_names[4], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 1 * (5 + 110/6) + 5, variable_table.right_speeds_names[5], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 220, y_pos + 5 + 0 * (5 + 110/6) + 5, variable_table.right_speeds_names[6], 12, false, false, TEXT_ALIGN_RIGHT, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 5 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[1])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 4 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[2])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 3 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[3])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 2 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[4])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 1 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[5])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 150, y_pos + 5 + 0 * (5 + 110/6) + 5, math.floor(get(variable_table.right_values[6])), 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    --fo pointer
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 110, variable_table.fo_ias_y_pos - 3, "→", 40, false, false, TEXT_ALIGN_CENTER, variable_table.fo_ias_color)
    sasl.gl.drawRectangle(CENTER_X + 50, variable_table.fo_ias_y_pos, 40, 110/6, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 70, variable_table.fo_ias_y_pos + 5, math.floor(get(PFD_Fo_IAS)), 12, false, false, TEXT_ALIGN_CENTER, variable_table.fo_ias_color)

    --limit indications
    if get(Capt_IAS) > get(Capt_VMAX) or get(Fo_IAS) > get(Fo_VMAX) then
        sasl.gl.drawRectangle(CENTER_X - 40, CENTER_Y-35, 80, 80, LIGHT_GREY)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+30, "VMAX", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+10, "OVERSPEED", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-10, "FULL PROT", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-30, math.floor(get(Capt_VMAX_prot)) .. "KTS", 12, false, false, TEXT_ALIGN_CENTER, RED)
    end

    if (get(Capt_IAS) <= get(Capt_Vaprot_vsw) and get(Capt_IAS) > get(Capt_Valpha_MAX)) or (get(Fo_IAS) <= get(Fo_Vaprot_vsw) and get(Fo_IAS) > get(Fo_Valpha_MAX)) then
        sasl.gl.drawRectangle(CENTER_X - 40, CENTER_Y-35, 80, 80, LIGHT_GREY)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+30, "A.FLOOR", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+10, "COMING UP", 12, false, false, TEXT_ALIGN_CENTER, ORANGE)
    end

    if get(Capt_IAS) <= get(Capt_Valpha_MAX) or get(Fo_IAS) <= get(Fo_Valpha_MAX) then
        sasl.gl.drawRectangle(CENTER_X - 40, CENTER_Y-35, 80, 80, LIGHT_GREY)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+30, "A.MAX", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y+10, "REACHED", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-10, "MAX AOA", 12, false, false, TEXT_ALIGN_CENTER, RED)
        sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y-30, alpha_max_alphas[get(Flaps_internal_config) + 1] .. "°", 12, false, false, TEXT_ALIGN_CENTER, RED)
    end
end