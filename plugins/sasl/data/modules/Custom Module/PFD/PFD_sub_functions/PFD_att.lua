--239 radius
--206px width
function PFD_draw_att(PFD_table)
    local ATT_x_center = size[1]/2-55
    local ATT_y_center = size[2]/2-7

    if is_att_ok(PFD_table.Screen_ID) == false then
        if PFD_table.ATT_blink_now == true then
            sasl.gl.drawText(Font_AirbusDUL, ATT_x_center, ATT_y_center, "ATT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end

        return
    end

    --draw the mask
    sasl.gl.drawMaskStart ()
    sasl.gl.drawTexture(PFD_pitch_scale_mask, 0, 0, 900, 900, {1,1,1})
    --draw under the mask
    sasl.gl.drawUnderMask(true)
    if get(FBW_total_control_law) == FBW_NORMAL_LAW then
        SASL_rotated_center_img_xcenter_aligned(PFD_normal_pitch_scale, ATT_x_center, ATT_y_center, 2870, 779, 90 - get_roll(PFD_table.Screen_ID), get_pitch(PFD_table.Screen_ID) * 10, -779/2, ECAM_WHITE)
    else
        SASL_rotated_center_img_xcenter_aligned(PFD_abnormal_pitch_scale, ATT_x_center, ATT_y_center, 2870, 779, 90 - get_roll(PFD_table.Screen_ID), get_pitch(PFD_table.Screen_ID) * 10, -779/2, ECAM_WHITE)        
    end

    --tailstrike arrow(TOGO GA and GS < 50)
    if get(All_on_ground) == 0 and get(PFD_table.RA_ALT) < 400 then
        SASL_rotated_center_img_center_aligned(
            PFD_tailstrike_arrow,
            ATT_x_center,
            ATT_y_center,
            72,
            43,
            -get_roll(PFD_table.Screen_ID),
            0,
            9.7 * 10 + 21.5 - get_pitch(PFD_table.Screen_ID) * 10,
            ECAM_ORANGE
        )
    end

    SASL_rotated_center_img_center_aligned(
        PFD_att_hdg_tape,
        ATT_x_center,
        ATT_y_center,
        3429,
        16,
        -get_roll(PFD_table.Screen_ID),
        1519 + Math_rescale_no_lim(0, 0, 10, -85, get_hdg(PFD_table.Screen_ID)),
        -get_pitch(PFD_table.Screen_ID) * 10 - 4,
        ECAM_WHITE
    )

    SASL_rotated_center_img_xcenter_aligned(
        PFD_ground,
        ATT_x_center,
        ATT_y_center,
        2870,
        779,
        90 - get_roll(PFD_table.Screen_ID),
        Math_clamp(Math_rescale_no_lim(0, -187 + get_pitch(PFD_table.Screen_ID) * 10, 120, 0 + get_pitch(PFD_table.Screen_ID) * 10, get(PFD_table.RA_ALT)), -366, 0),
        -779/2,
        ECAM_WHITE
    )

    if is_track_ok(PFD_table.Screen_ID) and is_aoa_ok(PFD_table.Screen_ID) then
        SASL_draw_img_center_aligned(
            PFD_att_bird,
            Get_rotated_point_x_pos_offset(ATT_x_center, - math.cos(math.rad(get_roll(PFD_table.Screen_ID))) * get_aoa(PFD_table.Screen_ID) * 10, -get_roll(PFD_table.Screen_ID), Math_rescale_no_lim(0, 0, 10, 85, (get_track(PFD_table.Screen_ID) - get_hdg(PFD_table.Screen_ID)))),
            Get_rotated_point_y_pos_offset(ATT_y_center, - math.cos(math.rad(get_roll(PFD_table.Screen_ID))) * get_aoa(PFD_table.Screen_ID) * 10, -get_roll(PFD_table.Screen_ID), Math_rescale_no_lim(0, 0, 10, 85, (get_track(PFD_table.Screen_ID) - get_hdg(PFD_table.Screen_ID)))),
            83,
            43,
            ECAM_GREEN
        )
    else
        sasl.gl.drawText(Font_AirbusDUL, ATT_x_center-77, ATT_y_center-36, "FPV", 35, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end

    SASL_rotated_center_img_xcenter_aligned(
        PFD_static_sky,
        ATT_x_center,
        ATT_y_center,
        1575,
        779,
        90 - get_roll(PFD_table.Screen_ID),
        0,
        -779/2,
        ECAM_WHITE
    )

    --bank + beta indication
    SASL_rotated_center_img_center_aligned(
        PFD_bank_angle_indicator,
        ATT_x_center,
        ATT_y_center,
        37,
        26,
        -get_roll(PFD_table.Screen_ID),
        0,
        (math.abs(get_roll(PFD_table.Screen_ID)) >= 60 and math.abs(get_roll(PFD_table.Screen_ID)) <= 120) and (206 / math.cos(math.rad(90 - math.abs(get_roll(PFD_table.Screen_ID)))) - 14) or 224,
        PFD_YELLOW
    )
    SASL_rotated_center_img_center_aligned(
        PFD_bank_angle_beta_angle,
        ATT_x_center,
        ATT_y_center,
        65,
        17,
        -get_roll(PFD_table.Screen_ID),
        Math_rescale_no_lim(0, 0, 0.2, -53, Math_clamp(get(Total_lateral_g_load), -0.3, 0.3)),
        (math.abs(get_roll(PFD_table.Screen_ID)) >= 60 and math.abs(get_roll(PFD_table.Screen_ID)) <= 120) and (206 / math.cos(math.rad(90 - math.abs(get_roll(PFD_table.Screen_ID)))) - 37) or 201,
        PFD_YELLOW
    )

    --RA ALT (TODO LACKING DH logic waiting for MCDU)
    local RA_color = get(PFD_table.RA_ALT) > 400 and ECAM_GREEN or ECAM_ORANGE
        if get(PFD_table.RA_ALT) <= 2500 then
        if get(PFD_table.RA_ALT) > 50 then
            SASL_drawText_rotated(Font_AirbusDUL, 0, -225, ATT_x_center, ATT_y_center,  -get_roll(PFD_table.Screen_ID), math.floor(get(PFD_table.RA_ALT) - get(PFD_table.RA_ALT) % 10), 42, false, false, TEXT_ALIGN_CENTER, RA_color)
        elseif get(PFD_table.RA_ALT) >= 10 then
            SASL_drawText_rotated(Font_AirbusDUL, 0, -225, ATT_x_center, ATT_y_center, -get_roll(PFD_table.Screen_ID), math.floor(get(PFD_table.RA_ALT) - get(PFD_table.RA_ALT) % 5), 42, false, false, TEXT_ALIGN_CENTER, RA_color)
        else
            SASL_drawText_rotated(Font_AirbusDUL, 0, -225, ATT_x_center, ATT_y_center, -get_roll(PFD_table.Screen_ID), math.floor(get(PFD_table.RA_ALT)), 42, false, false, TEXT_ALIGN_CENTER, RA_color)
        end
    end
    --terminate masked drawing
    sasl.gl.drawMaskEnd ()

    --FBW law indication (TODO ALT LAW / DIRECT LAW)
    if get(FBW_total_control_law) == FBW_NORMAL_LAW then
        SASL_draw_needle_adv(ATT_x_center, ATT_y_center+4, 224, 238, 157, 2, ECAM_GREEN)
        SASL_draw_needle_adv(ATT_x_center, ATT_y_center-4, 224, 238, 157, 2, ECAM_GREEN)
        SASL_draw_needle_adv(ATT_x_center, ATT_y_center+4, 224, 238, 23, 2, ECAM_GREEN)
        SASL_draw_needle_adv(ATT_x_center, ATT_y_center-4, 224, 238, 23, 2, ECAM_GREEN)
    else
        sasl.gl.drawText(Airbus_panel_font, Get_rotated_point_x_pos(ATT_x_center, 230, 157), Get_rotated_point_y_pos(ATT_y_center-10, 230, 157), "X", 26, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Airbus_panel_font, Get_rotated_point_x_pos(ATT_x_center, 230, 23), Get_rotated_point_y_pos(ATT_y_center-10, 230, 23), "X", 26, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    --wings
    SASL_draw_img_xcenter_aligned(PFD_pitch_wings, ATT_x_center, size[2]/2-43, 402, 47, {1,1,1})

    --sidesitck position indicator
    if PFD_table.PFD_aircraft_in_air_timer <= 0.5 then
        SASL_draw_img_center_aligned(PFD_sidestick_box,   ATT_x_center, ATT_y_center, 329, 269, {1,1,1})
        SASL_draw_img_center_aligned(PFD_sidestick_cross, ATT_x_center + Math_rescale(-1, -164, 1, 164, get(Augmented_roll)), ATT_y_center + Math_rescale(-1, -134, 1, 134, get(Augmented_pitch)), 61, 63, {1,1,1})
    end

    sasl.gl.drawRectangle(ATT_x_center-5, ATT_y_center-5, 10, 10, ECAM_BLACK)

    --draw things between the yellow quare and the black bgd here (FD bars...)

    --yellow box
    SASL_draw_img_center_aligned(PFD_pitch_yellow_box, ATT_x_center, ATT_y_center, 18, 18, ECAM_WHITE)

    SASL_draw_img_xcenter_aligned(PFD_bank_angle, size[1]/2-56, size[2]/2+158, 366, 95, {1,1,1})
end