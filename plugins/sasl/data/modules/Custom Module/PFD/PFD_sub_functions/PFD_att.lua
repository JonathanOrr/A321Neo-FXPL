--239 radius
--206px width

local function draw_trim_flag(PFD_table)
    local ATT_x_center = size[1]/2-55
    local ATT_y_center = size[2]/2-7

    if PFD_table.PFD_aircraft_in_air_timer < 3 then
        return
    end

    local ALL_SPLR_FAIL = not FCTL.SPLR.STAT.L[1].controlled and
                          not FCTL.SPLR.STAT.L[2].controlled and
                          not FCTL.SPLR.STAT.L[3].controlled and
                          not FCTL.SPLR.STAT.L[4].controlled and
                          not FCTL.SPLR.STAT.L[5].controlled and
                          not FCTL.SPLR.STAT.R[1].controlled and
                          not FCTL.SPLR.STAT.R[2].controlled and
                          not FCTL.SPLR.STAT.R[3].controlled and
                          not FCTL.SPLR.STAT.R[4].controlled and
                          not FCTL.SPLR.STAT.R[5].controlled

    if (ALL_SPLR_FAIL and not FCTL.AIL.STAT.L.controlled and not FCTL.AIL.STAT.R.controlled) or
       (not FCTL.ELEV.STAT.L.controlled and not FCTL.ELEV.STAT.R.controlled) then
        sasl.gl.drawText(Font_ECAMfont, ATT_x_center, ATT_y_center + 275, "MAN PITCH TRIM ONLY", 34, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        return
    end

    if get(FBW_total_control_law) == FBW_DIRECT_LAW or get(FBW_ABN_LAW_TRIM_INHIB) == 1 then
        sasl.gl.drawText(Font_ECAMfont, ATT_x_center, ATT_y_center + 275, "USE MAN PITCH TRIM", 34, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        return
    end
end

local function draw_stall_flag()
    local ATT_x_center = size[1]/2-55
    local ATT_y_center = size[2]/2-7

    if get(GPWS_mode_stall) == 0 then return end

    sasl.gl.drawText(Font_ECAMfont, ATT_x_center, ATT_y_center + 70, "STALL    STALL", 38, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
end

local function draw_windshear_flag()
    local ATT_x_center = size[1]/2-55
    local ATT_y_center = size[2]/2-7

    if get(GPWS_mode_windshear_PFD) == 0 then return end

    sasl.gl.drawText(Font_ECAMfont, ATT_x_center, ATT_y_center + 35, "WINDSHEAR", 38, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
end

local function draw_SI_trapezoid(PFD_table)
    local ATT_x_center = size[1]/2-55
    local ATT_y_center = size[2]/2-7

    if not adirs_is_gloads_ok(PFD_table.Screen_ID) then
        --draw SI flag
        local SI_flag_x = Get_rotated_point_x_CC_pos(ATT_x_center, (math.abs(adirs_get_roll(PFD_table.Screen_ID)) >= 60 and math.abs(adirs_get_roll(PFD_table.Screen_ID)) <= 120) and (206 / math.cos(math.rad(90 - math.abs(adirs_get_roll(PFD_table.Screen_ID)))) - 50) or 188, -adirs_get_roll(PFD_table.Screen_ID))
        local SI_flag_y = Get_rotated_point_y_CC_pos(ATT_y_center, (math.abs(adirs_get_roll(PFD_table.Screen_ID)) >= 60 and math.abs(adirs_get_roll(PFD_table.Screen_ID)) <= 120) and (206 / math.cos(math.rad(90 - math.abs(adirs_get_roll(PFD_table.Screen_ID)))) - 50) or 188, -adirs_get_roll(PFD_table.Screen_ID))
        sasl.gl.drawText(Font_ECAMfont, SI_flag_x, SI_flag_y, "SI", 30, true, false, TEXT_ALIGN_CENTER, ECAM_RED)

        return
    end

    --trapizoid color--
    local beta_color = ECAM_YELLOW
    if get(Flaps_internal_config) > 0 and get(Flaps_internal_config) < 5 and
       ((ENG.dyn[1].n1 > 80 or ENG.dyn[2].n1 > 80) or (get(Cockpit_throttle_lever_L) >= THR_MCT_START or get(Cockpit_throttle_lever_R) >= THR_MCT_START)) and
       math.abs(ENG.dyn[1].n1 - ENG.dyn[2].n1) > 35 then
        beta_color = ECAM_BLUE
    end

    SASL_rotated_center_img_center_aligned(
        PFD_bank_angle_beta_angle,
        ATT_x_center,
        ATT_y_center-0.5,
        65,
        17,
        -adirs_get_roll(PFD_table.Screen_ID),
        Math_rescale_no_lim(0, 0, 0.2, -53, Math_clamp(get(Total_lateral_g_load), -0.3, 0.3)),
        (math.abs(adirs_get_roll(PFD_table.Screen_ID)) >= 60 and math.abs(adirs_get_roll(PFD_table.Screen_ID)) <= 120) and (206 / math.cos(math.rad(90 - math.abs(adirs_get_roll(PFD_table.Screen_ID)))) - 37) or 201,
        beta_color
    )
end

function PFD_draw_att(PFD_table)
    local ATT_x_center = size[1]/2-55
    local ATT_y_center = size[2]/2-7

    draw_trim_flag(PFD_table)--this flag can show no matter what

    if adirs_is_att_ok(PFD_table.Screen_ID) == false then
        if PFD_table.ATT_blink_now == true then
            sasl.gl.drawText(Font_ECAMfont, ATT_x_center, size[2]/2-20, "ATT", 42, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end

        return
    end

    --draw the mask
    sasl.gl.drawMaskStart ()
    sasl.gl.drawTexture(PFD_pitch_scale_mask, 0, 0, 900, 900, {1,1,1})
    --draw under the mask
    sasl.gl.drawUnderMask(true)
    if get(FBW_total_control_law) == FBW_NORMAL_LAW then
        SASL_rotated_center_img_xcenter_aligned(PFD_normal_pitch_scale, ATT_x_center, ATT_y_center, 2870, 779, 90 - adirs_get_roll(PFD_table.Screen_ID), adirs_get_pitch(PFD_table.Screen_ID) * 10, -779/2, ECAM_WHITE)
    else
        SASL_rotated_center_img_xcenter_aligned(PFD_abnormal_pitch_scale, ATT_x_center, ATT_y_center, 2870, 779, 90 - adirs_get_roll(PFD_table.Screen_ID), adirs_get_pitch(PFD_table.Screen_ID) * 10, -779/2, ECAM_WHITE)        
    end

    --tailstrike arrow(TOGO GA and GS < 50)
    if get(All_on_ground) == 0 and RA_sys.single_RA_user(PFD_table.RA_sensor) < 400 and get(EWD_flight_phase) == PHASE_FINAL then
        SASL_rotated_center_img_center_aligned(
            PFD_tailstrike_arrow,
            ATT_x_center,
            ATT_y_center,
            72,
            43,
            -adirs_get_roll(PFD_table.Screen_ID),
            0,
            9.7 * 10 + 21.5 - adirs_get_pitch(PFD_table.Screen_ID) * 10,
            ECAM_ORANGE
        )
    end

    SASL_rotated_center_img_xcenter_aligned(
        PFD_ground,
        ATT_x_center,
        ATT_y_center,
        2870,
        779,
        90 - adirs_get_roll(PFD_table.Screen_ID),
        Math_clamp(Math_rescale_no_lim(0, -187 + adirs_get_pitch(PFD_table.Screen_ID) * 10, 120, 0 + adirs_get_pitch(PFD_table.Screen_ID) * 10, RA_sys.single_RA_user(PFD_table.RA_sensor)), -366, 0),
        -779/2,
        ECAM_WHITE
    )

    SASL_rotated_center_img_center_aligned(
        PFD_att_hdg_tape,
        ATT_x_center,
        ATT_y_center,
        3429,
        20,
        -adirs_get_roll(PFD_table.Screen_ID),
        1519 + Math_rescale_no_lim(0, 0, 10, -85, adirs_get_hdg(PFD_table.Screen_ID)),
        -adirs_get_pitch(PFD_table.Screen_ID) * 10 - 4,
        ECAM_WHITE
    )

    if adirs_is_track_ok(PFD_table.Screen_ID) and adirs_is_aoa_ok(PFD_table.Screen_ID) then
        SASL_draw_img_center_aligned(
            PFD_att_bird,
            Get_rotated_point_x_pos_offset(ATT_x_center, - math.cos(math.rad(adirs_get_roll(PFD_table.Screen_ID))) * get(PFD_table.AoA) * 10, -adirs_get_roll(PFD_table.Screen_ID), Math_rescale_no_lim(0, 0, 10, 85, (adirs_get_track(PFD_table.Screen_ID) - adirs_get_hdg(PFD_table.Screen_ID)))),
            Get_rotated_point_y_pos_offset(ATT_y_center, - math.cos(math.rad(adirs_get_roll(PFD_table.Screen_ID))) * get(PFD_table.AoA) * 10, -adirs_get_roll(PFD_table.Screen_ID), Math_rescale_no_lim(0, 0, 10, 85, (adirs_get_track(PFD_table.Screen_ID) - adirs_get_hdg(PFD_table.Screen_ID)))),
            83,
            43,
            ECAM_GREEN
        )
    else
        sasl.gl.drawText(Font_ECAMfont, ATT_x_center-77, ATT_y_center-36, "FPV", 35, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end

    SASL_rotated_center_img_xcenter_aligned(
        PFD_static_sky,
        ATT_x_center,
        ATT_y_center,
        1575,
        779,
        90 - adirs_get_roll(PFD_table.Screen_ID),
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
        -adirs_get_roll(PFD_table.Screen_ID),
        0,
        (math.abs(adirs_get_roll(PFD_table.Screen_ID)) >= 60 and math.abs(adirs_get_roll(PFD_table.Screen_ID)) <= 120) and (206 / math.cos(math.rad(90 - math.abs(adirs_get_roll(PFD_table.Screen_ID)))) - 14) or 224,
        ECAM_YELLOW
    )

    draw_SI_trapezoid(PFD_table)

    --RA ALT (TODO LACKING DH logic waiting for MCDU)
    local RA_color = RA_sys.single_RA_user(PFD_table.RA_sensor) > 400 and ECAM_GREEN or ECAM_ORANGE
        if RA_sys.single_RA_user(PFD_table.RA_sensor) <= 2500 then
        if RA_sys.single_RA_user(PFD_table.RA_sensor) > 50 then
            SASL_drawText_rotated(Font_ECAMfont, 0, -225, ATT_x_center, ATT_y_center,  -adirs_get_roll(PFD_table.Screen_ID), math.floor(RA_sys.single_RA_user(PFD_table.RA_sensor) - RA_sys.single_RA_user(PFD_table.RA_sensor) % 10), 42, false, false, TEXT_ALIGN_CENTER, RA_color)
        elseif RA_sys.single_RA_user(PFD_table.RA_sensor) >= 10 then
            SASL_drawText_rotated(Font_ECAMfont, 0, -225, ATT_x_center, ATT_y_center, -adirs_get_roll(PFD_table.Screen_ID), math.floor(RA_sys.single_RA_user(PFD_table.RA_sensor) - RA_sys.single_RA_user(PFD_table.RA_sensor) % 5), 42, false, false, TEXT_ALIGN_CENTER, RA_color)
        else
            SASL_drawText_rotated(Font_ECAMfont, 0, -225, ATT_x_center, ATT_y_center, -adirs_get_roll(PFD_table.Screen_ID), math.floor(RA_sys.single_RA_user(PFD_table.RA_sensor)), 42, false, false, TEXT_ALIGN_CENTER, RA_color)
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
        sasl.gl.drawText(Font_Airbus_panel, Get_rotated_point_x_pos(ATT_x_center, 230, 157), Get_rotated_point_y_pos(ATT_y_center-10, 230, 157), "x", 34, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_Airbus_panel, Get_rotated_point_x_pos(ATT_x_center, 230, 23), Get_rotated_point_y_pos(ATT_y_center-10, 230, 23), "x", 34, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    --wings
    SASL_draw_img_xcenter_aligned(PFD_pitch_wings, ATT_x_center, size[2]/2-43, 402, 47, {1,1,1})

    --sidesitck position indicator
    if PFD_table.PFD_aircraft_in_air_timer <= 0.5 and get(EWD_flight_phase) >= PHASE_1ST_ENG_ON then
        local total_roll = get(CAPT_SSTICK_X) + get(FO_SSTICK_X)
        local total_pitch = get(CAPT_SSTICK_Y) + get(FO_SSTICK_Y)

        SASL_draw_img_center_aligned(PFD_sidestick_box,   ATT_x_center, ATT_y_center, 329, 269, {1,1,1})
        SASL_draw_img_center_aligned(PFD_sidestick_cross, ATT_x_center + Math_rescale(-1, -164, 1, 164, total_roll), ATT_y_center + Math_rescale(-1, -134, 1, 134, total_pitch), 61, 63, {1,1,1})
    end

    sasl.gl.drawRectangle(ATT_x_center-5, ATT_y_center-5, 10, 10, ECAM_BLACK)

    --draw things between the yellow quare and the black bgd here (FD bars...)

    --yellow box
    SASL_draw_img_center_aligned(PFD_pitch_yellow_box, ATT_x_center, ATT_y_center, 18, 18, ECAM_WHITE)

    SASL_draw_img_xcenter_aligned(PFD_bank_angle, size[1]/2-56, size[2]/2+158, 366, 95, {1,1,1,1})

    draw_stall_flag()
    draw_windshear_flag()
end
