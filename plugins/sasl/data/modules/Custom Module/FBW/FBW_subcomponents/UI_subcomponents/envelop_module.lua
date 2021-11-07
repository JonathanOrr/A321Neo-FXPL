--fbw constraints
Upper_g_lim = 2.5
Lower_g_lim = -1

function Draw_envelop_module_480x240(x_pos, y_pos)
    local vsw_aprot_alphas = {
        8.5,
        13,
        13,
        12,
        12,
        11.5
    }

    local alpha_max_alphas = {
        10,
        16,
        16,
        16,
        15,
        15
    }

    --updates FBW G constraints
    if get(Flaps_internal_config) > 1 then
        Upper_g_lim = Set_anim_value(Upper_g_lim, 2, -1, 2.5, 1)
        Lower_g_lim = Set_anim_value(Lower_g_lim, 0, -1, 2.5, 1)
    else
        Upper_g_lim = Set_anim_value(Upper_g_lim, 2.5, -1, 2.5, 1)
        Lower_g_lim = Set_anim_value(Lower_g_lim, -1, -1, 2.5, 1)
    end

    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 240) / 2

    --draw the background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 240, DARK_GREY)

    --draw roll control ring
    --bank angle indications
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, -67, 134, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 113, 134, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, -get(Flightmodel_roll), RED)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 180, -get(Flightmodel_roll), RED)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, Math_clamp(-get(Flightmodel_roll), -125, 125), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 180, Math_clamp(-get(Flightmodel_roll), -125, 125), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 0, Math_clamp(-get(Flightmodel_roll), -67, 67), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 103, 110, 180, Math_clamp(-get(Flightmodel_roll), -67, 67), LIGHT_BLUE)
    --roll rate indications
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, -15, 30, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 165, 30, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 0, -get(Flightmodel_p_deg), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 180, -get(Flightmodel_p_deg), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 0, Math_clamp(-get(Flightmodel_p_deg), -15, 15), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 94, 101, 180, Math_clamp(-get(Flightmodel_p_deg), -15, 15), LIGHT_BLUE)
    --side slip indications
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 85, 92, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 85, 92, -get(Flightmodel_roll) + 90 + 7.5, -15, WHITE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 85, 92, -get(Flightmodel_roll) + 90, get(Beta), ORANGE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 85, 92, -get(Flightmodel_roll) + 90, Math_clamp(get(Beta), -15, 15), LIGHT_BLUE)
    --aircraft image
    sasl.gl.drawRotatedTextureCenter (Aircraft_behind_img, get(Flightmodel_roll), CENTER_X - 120, CENTER_Y, CENTER_X - 120 - (160 / 2), CENTER_Y - (53 /2) + 6, 160, 53, {1,1,1})
    --text indications
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 45, 83, 60, 60, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y + 65, "SIDESLIP", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y + 50, string.format("%.1f", tostring(get(Beta))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X - 120, CENTER_Y, 20, 83, 270- 40, 80, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 35, "ROLL", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 50, string.format("%.2f", tostring(get(Flightmodel_roll))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 65, "ROLL RATE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X - 120, CENTER_Y - 80, string.format("%.0f", tostring(get(Flightmodel_p_deg))) .. "°/S", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)


    --draw G load control ring
    --pitch indications
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, -15, 45, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 165, 45, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, get(Flightmodel_pitch), RED)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 180, get(Flightmodel_pitch), RED)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, Math_clamp(get(Flightmodel_pitch), -30, 50), ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 180, Math_clamp(get(Flightmodel_pitch), -30, 50), ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 0, Math_clamp(get(Flightmodel_pitch), -15, 30), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 103, 110, 180, Math_clamp(get(Flightmodel_pitch), -15, 30), LIGHT_BLUE)
    --g load indications
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, (Lower_g_lim) * 10, (Upper_g_lim -Lower_g_lim) * 10, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 180 + (Lower_g_lim ) * 10, (Upper_g_lim -Lower_g_lim) * 10, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 0, get(Total_vertical_g_load) * 10, ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 180, get(Total_vertical_g_load) * 10, ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 0, Math_clamp(get(Total_vertical_g_load) * 10, Lower_g_lim * 10, Upper_g_lim * 10), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 94, 101, 180, Math_clamp(get(Total_vertical_g_load) * 10, Lower_g_lim * 10, Upper_g_lim * 10), LIGHT_BLUE)
    --alpha indication
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, 0, 360, LIGHT_GREY)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch) + 15, - vsw_aprot_alphas[get(Flaps_internal_config) + 1] - 15, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch) + 15 + 180, - vsw_aprot_alphas[get(Flaps_internal_config) + 1] - 15, WHITE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch), - get(Alpha), RED)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch) + 180, - get(Alpha), RED)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch), - Math_clamp(get(Alpha), -15, alpha_max_alphas[get(Flaps_internal_config) + 1]), ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch) + 180, - Math_clamp(get(Alpha), -15, alpha_max_alphas[get(Flaps_internal_config) + 1]), ORANGE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch), - Math_clamp(get(Alpha), -15, vsw_aprot_alphas[get(Flaps_internal_config) + 1]), LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 85, 92, get(Flightmodel_pitch) + 180, - Math_clamp(get(Alpha), -15, vsw_aprot_alphas[get(Flaps_internal_config) + 1]), LIGHT_BLUE)
    --aircraft image
    sasl.gl.drawRotatedTextureCenter (Aircraft_side_img, -get(Flightmodel_pitch), CENTER_X + 120, CENTER_Y, CENTER_X + 120 - (160 / 2), CENTER_Y - (53 /2) + 12, 160, 53, {1,1,1})
    --text indications
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 45, 83, 60, 60, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y + 65, "ALPHA", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y + 50, string.format("%.1f", tostring(get(Alpha))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawArc(CENTER_X + 120, CENTER_Y, 20, 83, 270 - 40, 80, {LIGHT_GREY[1], LIGHT_GREY[2], LIGHT_GREY[3], 0.6})
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 35, "PITCH", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 50, string.format("%.2f", tostring(get(Flightmodel_pitch))) .. "°", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 65, "G LOAD", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold, CENTER_X + 120, CENTER_Y - 80, string.format("%.1f", tostring(get(Total_vertical_g_load))) .. "G", 12, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)
end