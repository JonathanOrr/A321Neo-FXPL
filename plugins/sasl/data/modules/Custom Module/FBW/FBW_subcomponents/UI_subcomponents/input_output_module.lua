function Mouse_detect_control_info_and_setting_110x18(x_pos, y_pos, mouse_x, mouse_y)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 110) / 2
    local CENTER_Y = (2 * y_pos + 180) / 2

    if CENTER_X - 50 <= mouse_x and mouse_x <= CENTER_X + 50 and CENTER_Y + 55 <= mouse_y and mouse_y <= CENTER_Y + 85 then
        set(Project_square_input, 1 - get(Project_square_input))
    end
end

function Draw_input_module_180x180(x_pos, y_pos)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 180) / 2
    local CENTER_Y = (2 * y_pos + 180) / 2

    --input variables
    local input_quadrant = 1
    if get(Total_input_pitch) > 0 and get(Total_input_roll) > 0 then
        input_quadrant = 1
    elseif get(Total_input_pitch) > 0 and get(Total_input_roll) < 0 then
        input_quadrant = 2
    elseif get(Total_input_pitch) < 0 and get(Total_input_roll) < 0 then
        input_quadrant = 3
    elseif get(Total_input_pitch) < 0 and get(Total_input_roll) > 0 then
        input_quadrant = 4
    end

    local input_radius = Math_clamp_higher(math.sqrt(get(Total_input_pitch)^2 + get(Total_input_roll)^2), 1)
    local input_angle_rad = math.atan(get(Total_input_pitch) / get(Total_input_roll))
    local input_angle_deg = math.deg(math.atan(get(Total_input_pitch) / get(Total_input_roll)))
    local input_gradient = math.tan(input_angle_rad)
    local augmented_roll = 0
    local augmented_pitch = 0

    --draw static background
    sasl.gl.drawRectangle(x_pos, y_pos, 180, 180, DARK_GREY)
    sasl.gl.drawRectangle(CENTER_X - 85, CENTER_Y - 85, 170, 170, LIGHT_GREY)

    --draw input augmentation
    if get(Project_square_input) == 1 then
        sasl.gl.drawCircle(CENTER_X, CENTER_Y, input_radius * 85, false, LIGHT_BLUE)
        sasl.gl.drawFrame(CENTER_X - input_radius * 85, CENTER_Y - input_radius * 85, input_radius * 85 * 2, input_radius * 85 * 2, WHITE)

        if input_quadrant == 1 then
            if input_angle_deg <= 45 then
                augmented_roll = input_radius
                augmented_pitch = input_gradient * input_radius
            else--swap gradient axis
                augmented_roll = input_radius / input_gradient
                augmented_pitch = input_radius
            end
        elseif input_quadrant == 2 then
            if input_angle_deg >= -45 then
                augmented_roll =  - input_radius
                augmented_pitch = - input_gradient * input_radius
            else--swap gradient axis
                augmented_roll = - input_radius / -input_gradient
                augmented_pitch = input_radius
            end
        elseif input_quadrant == 3 then
            if input_angle_deg <= 45 then
                augmented_roll = - input_radius
                augmented_pitch =  - input_gradient * input_radius
            else--swap gradient axis
                augmented_roll =  - input_radius / input_gradient
                augmented_pitch =  - input_radius
            end
        elseif input_quadrant == 4 then
            if input_angle_deg >= -45 then
                augmented_roll = input_radius
                augmented_pitch = input_gradient * input_radius
            else
                augmented_roll = input_radius / -input_gradient
                augmented_pitch = - input_radius
            end
        end

        sasl.gl.drawLine(CENTER_X, CENTER_Y, CENTER_X + augmented_roll * 85, CENTER_Y - augmented_pitch * 85, WHITE)
        sasl.gl.drawCircle(CENTER_X + augmented_roll * 85, CENTER_Y - augmented_pitch * 85, 5, true, WHITE)
    end

    --draw raw human input
    sasl.gl.drawCircle(CENTER_X + 85 * get(Total_input_roll), CENTER_Y - 85 * get(Total_input_pitch), 5, true, LIGHT_BLUE)

end

function Draw_FBW_output_180x180(x_pos, y_pos)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 180) / 2
    local CENTER_Y = (2 * y_pos + 180) / 2

    --draw static background
    sasl.gl.drawRectangle(x_pos, y_pos, 180, 180, DARK_GREY)
    sasl.gl.drawRectangle(CENTER_X - 85, CENTER_Y - 85, 170, 170, LIGHT_GREY)

    --draw FBW output
    sasl.gl.drawCircle(CENTER_X + 85 * get(FBW_roll_output), CENTER_Y - 85 * get(FBW_pitch_output), 5, true, GREEN)
end

function Draw_control_info_and_setting_110x180(x_pos, y_pos)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 110) / 2
    local CENTER_Y = (2 * y_pos + 180) / 2

    local lvl_flt_load_constant = math.cos(math.rad(get(Flightmodel_pitch))) / math.cos(math.rad(Math_clamp(get(Flightmodel_roll), -33, 33)))

    --draw static background
    sasl.gl.drawRectangle(x_pos, y_pos, 110, 180, DARK_GREY)
    sasl.gl.drawRectangle(CENTER_X - 50, CENTER_Y + 55, 100, 30, get(Project_square_input) == 1 and LIGHT_BLUE or LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 50, CENTER_Y + 20, 100, 30, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 50, CENTER_Y - 15, 100, 30, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 50, CENTER_Y - 50, 100, 30, LIGHT_GREY)
    sasl.gl.drawRectangle(CENTER_X - 50, CENTER_Y - 85, 100, 30, LIGHT_GREY)

    -- Check: https://aviation.stackexchange.com/questions/46018/what-are-the-mechanical-deflection-angles-for-airbus-side-stick-controllers
    --for sidestick deflections
    --draw deflection angles
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 55 + 10, "SQUARE INPUT", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y + 20 + 10, "ROLL", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 15 + 17, string.format("%.1f", tostring(get(Total_input_roll) * 20)) .. "°", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 15 + 3, string.format("%.1f", tostring(get(Total_input_roll) * 15)) .. "°/S", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 50 + 10, "PITCH", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85 + 17, string.format("%.1f", tostring(get(Total_input_pitch) * 16)) .. "°", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    if get(Flaps_internal_config) == 0 then
        if get(Total_input_pitch) >= 0 then
            sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85 + 3, string.format("%.1f", tostring(Math_rescale(0, lvl_flt_load_constant, 1, 2.5, get(Total_input_pitch)))) .. "G", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
        else
            sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85 + 3, string.format("%.1f", tostring(Math_rescale(-1, -1, 0, lvl_flt_load_constant, get(Total_input_pitch)))) .. "G", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
        end
    else
        if get(Total_input_pitch) >= 0 then
            sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85 + 3, string.format("%.1f", tostring(Math_rescale(0, lvl_flt_load_constant, 1, 2, get(Total_input_pitch)))) .. "G", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
        else
            sasl.gl.drawText(B612_MONO_bold, CENTER_X, CENTER_Y - 85 + 3, string.format("%.1f", tostring(Math_rescale(0, -1, 0, lvl_flt_load_constant, get(Total_input_pitch)))) .. "G", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
        end
    end
end