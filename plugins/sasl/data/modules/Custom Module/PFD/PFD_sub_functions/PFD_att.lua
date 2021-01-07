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
    SASL_rotated_center_img_xcenter_aligned(PFD_normal_pitch_scale, ATT_x_center, ATT_y_center, 2870, 779, 90 - get_roll(PFD_table.Screen_ID), get_pitch(PFD_table.Screen_ID) * 10, -779/2, ECAM_WHITE)
    SASL_rotated_center_img_xcenter_aligned(PFD_static_sky, ATT_x_center, ATT_y_center, 1575, 779, 90 - get_roll(PFD_table.Screen_ID), 0, -779/2, ECAM_WHITE)
    SASL_rotated_center_img_xcenter_aligned(
        PFD_ground,
        ATT_x_center,
        ATT_y_center,
        2870,
        779,
        90 - get_roll(PFD_table.Screen_ID),
        Math_clamp_higher(Math_rescale_no_lim(0, -187 + get_pitch(PFD_table.Screen_ID) * 10, 120, 0 + get_pitch(PFD_table.Screen_ID) * 10, get(PFD_table.RA_ALT)), 0),
        -779/2,
        ECAM_WHITE
    )
    --terminate masked drawing
    sasl.gl.drawMaskEnd ()

    --wings
    SASL_draw_img_xcenter_aligned(PFD_pitch_wings, ATT_x_center, size[2]/2-43, 402, 47, {1,1,1})

    --sidesitck position indicator
    if PFD_table.PFD_aircraft_in_air_timer <= 0.5 then
        SASL_draw_img_center_aligned(PFD_sidestick_box,   ATT_x_center, ATT_y_center, 329, 269, {1,1,1})
        SASL_draw_img_center_aligned(PFD_sidestick_cross, ATT_x_center + Math_rescale(-1, -164, 1, 164, get(Roll)), ATT_y_center + Math_rescale(-1, -134, 1, 134, get(Pitch)), 61, 63, {1,1,1})
    end

    sasl.gl.drawRectangle(ATT_x_center-5, ATT_y_center-5, 10, 10, ECAM_BLACK)

    --draw things between the yellow quare and the black bgd here (FD bars...)

    --yellow box
    SASL_draw_img_center_aligned(PFD_pitch_yellow_box, ATT_x_center, ATT_y_center, 18, 18, ECAM_WHITE)

    SASL_draw_img_xcenter_aligned(PFD_bank_angle, size[1]/2-56, size[2]/2+158, 366, 95, {1,1,1})
end