-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: ECAM_fctl.lua 
-- Short description: ECAM file for the F/CTL page 
-------------------------------------------------------------------------------
local PARAM_DELAY = 0.125

local params = {
    L_aileron = 0,
    R_aileron = 0,
    L_elevator = 0,
    R_elevator = 0,
    rudder = 0,
    last_update = 0
}

function ecam_update_fctl_page()
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.L_aileron   = get(L_aileron)
        params.R_aileron   = get(R_aileron)
        params.L_elevator  = get(L_elevator)
        params.R_elevator  = get(R_elevator)
        params.rudder      = get(Rudder_total)
        params.last_update = get(TIME)
    end
end

function draw_fctl_page()
    local is_G_ok = get(Hydraulic_G_press) >= 1450
    local is_B_ok = get(Hydraulic_B_press) >= 1450
    local is_Y_ok = get(Hydraulic_Y_press) >= 1450
    local is_FCDC_1_ok = get(FCDC_1_status) == 1
    local is_FCDC_2_ok = get(FCDC_2_status) == 1

    sasl.gl.drawTexture(ECAM_FCTL_bgd_img, 0, 0, 900, 900, {1,1,1})
    sasl.gl.drawTexture(ECAM_FCTL_grey_lines_img, 0, 0, 900, 900, ECAM_LINE_GREY)

    --draw flight computers--
    --ELACs--
    local ELAC_txt = {
        (is_FCDC_1_ok or is_FCDC_2_ok) and "1" or "X",
        (is_FCDC_1_ok or is_FCDC_2_ok) and "2" or "X",
    }
    local ELAC_txt_cl = {
        get(ELAC_1_status) == 1 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
        get(ELAC_2_status) == 1 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
    }
    local ELAC_box_cl = {
        get(ELAC_1_status) == 0 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
        get(ELAC_2_status) == 0 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
    }
    sasl.gl.drawText(Font_AirbusDUL, 298, 599, "ELAC", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 348, 599, ELAC_txt[1], 30, false, false, TEXT_ALIGN_CENTER, ELAC_txt_cl[1])
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 242, 584, 128, 52, ELAC_box_cl[1])
    sasl.gl.drawText(Font_AirbusDUL, 386, 576, ELAC_txt[2], 30, false, false, TEXT_ALIGN_CENTER, ELAC_txt_cl[2])
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 279, 561, 128, 52, ELAC_box_cl[2])
    --SECs--
    local SEC_txt = {
        (is_FCDC_1_ok or is_FCDC_2_ok) and "1" or "X",
        (is_FCDC_1_ok or is_FCDC_2_ok) and "2" or "X",
        (is_FCDC_1_ok or is_FCDC_2_ok) and "3" or "X",
    }
    local SEC_txt_cl = {
        get(SEC_1_status) == 1 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
        get(SEC_2_status) == 1 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
        get(SEC_3_status) == 1 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
    }
    local SEC_box_cl = {
        get(SEC_1_status) == 0 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
        get(SEC_2_status) == 0 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
        get(SEC_3_status) == 0 and (is_FCDC_1_ok or is_FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
    }
    sasl.gl.drawText(Font_AirbusDUL, 522, 599, "SEC", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 573, 599, SEC_txt[1], 30, false, false, TEXT_ALIGN_CENTER, SEC_txt_cl[1])
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 467, 584, 128, 52, SEC_box_cl[1])
    sasl.gl.drawText(Font_AirbusDUL, 611, 576, SEC_txt[2], 30, false, false, TEXT_ALIGN_CENTER, SEC_txt_cl[2])
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 504, 561, 128, 52, SEC_box_cl[2])
    sasl.gl.drawText(Font_AirbusDUL, 649, 553, SEC_txt[3], 30, false, false, TEXT_ALIGN_CENTER, SEC_txt_cl[3])
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 541, 538, 128, 52, SEC_box_cl[3])

    --LAF--
    if get(FBW_LAF_DATA_AVAIL) == 1 then
        if get(FBW_LAF_DEGRADED_AIL) == 1 or get(FBW_LAF_DEGRADED_SPLR_4) == 1 or get(FBW_LAF_DEGRADED_SPLR_5) == 1 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2+215, "LAF DEGRADED", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end
    end

    --track indication--
    local num_of_spoilers = 5
    local spoiler_track_length = 22

    local l_spoilers_avail = {
        FBW.fctl.SPLR.STAT.L[1].controlled,
        FBW.fctl.SPLR.STAT.L[2].controlled,
        FBW.fctl.SPLR.STAT.L[3].controlled,
        FBW.fctl.SPLR.STAT.L[4].controlled,
        FBW.fctl.SPLR.STAT.L[5].controlled,
    }
    local r_spoilers_avail = {
        FBW.fctl.SPLR.STAT.R[1].controlled,
        FBW.fctl.SPLR.STAT.R[2].controlled,
        FBW.fctl.SPLR.STAT.R[3].controlled,
        FBW.fctl.SPLR.STAT.R[4].controlled,
        FBW.fctl.SPLR.STAT.R[5].controlled,
    }
    local l_spoilers_data_avail = {
        FBW.fctl.SPLR.STAT.L[1].data_avail,
        FBW.fctl.SPLR.STAT.L[2].data_avail,
        FBW.fctl.SPLR.STAT.L[3].data_avail,
        FBW.fctl.SPLR.STAT.L[4].data_avail,
        FBW.fctl.SPLR.STAT.L[5].data_avail,
    }
    local r_spoilers_data_avail = {
        FBW.fctl.SPLR.STAT.R[1].data_avail,
        FBW.fctl.SPLR.STAT.R[2].data_avail,
        FBW.fctl.SPLR.STAT.R[3].data_avail,
        FBW.fctl.SPLR.STAT.R[4].data_avail,
        FBW.fctl.SPLR.STAT.R[5].data_avail,
    }

    local l_spoiler_dataref = {
        L_SPLR_1,
        L_SPLR_2,
        L_SPLR_3,
        L_SPLR_4,
        L_SPLR_5,
    }

    local r_spoiler_dataref = {
        R_SPLR_1,
        R_SPLR_2,
        R_SPLR_3,
        R_SPLR_4,
        R_SPLR_5,
    }

    local spoiler_track_x_y = {
        {44, 767},
        {100, 758},
        {156, 749},
        {212, 739},
        {269, 730},
    }

    local spoiler_arrow_x_y = {
        {55, 767},
        {111, 758},
        {167, 749},
        {223, 739},
        {280, 730},
    }

    local spoiler_num_x_y = {
        {54, 772},
        {111, 763},
        {167, 754},
        {223, 744},
        {280, 735},
    }

    for i = 1, num_of_spoilers do
        if l_spoilers_data_avail[i] then
            if get(l_spoiler_dataref[i]) > 2.5 then
                SASL_draw_img_xcenter_aligned(ECAM_FCTL_spoiler_arrow_img, size[1]/2 - spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2], 28, 50, l_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
            else
                if not l_spoilers_avail[i] then
                    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - spoiler_num_x_y[i][1], spoiler_num_x_y[i][2], i, 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
                end
            end
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - spoiler_num_x_y[i][1], spoiler_num_x_y[i][2], "X", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end
        if r_spoilers_data_avail[i] then
            if get(r_spoiler_dataref[i]) > 2.5 then
                SASL_draw_img_xcenter_aligned(ECAM_FCTL_spoiler_arrow_img, size[1]/2 + spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2], 28, 50, r_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
            else
                if not r_spoilers_avail[i] then
                    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + spoiler_num_x_y[i][1], spoiler_num_x_y[i][2], i, 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
                end
            end
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + spoiler_num_x_y[i][1], spoiler_num_x_y[i][2], "X", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end

        if l_spoilers_data_avail[i] then
            sasl.gl.drawWideLine(size[1]/2 - spoiler_track_x_y[i][1], spoiler_track_x_y[i][2], size[1]/2 - spoiler_track_x_y[i][1] - spoiler_track_length, spoiler_track_x_y[i][2], 2.5, l_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
        end
        if r_spoilers_data_avail[i] then
            sasl.gl.drawWideLine(size[1]/2 + spoiler_track_x_y[i][1], spoiler_track_x_y[i][2], size[1]/2 + spoiler_track_x_y[i][1] + spoiler_track_length, spoiler_track_x_y[i][2], 2.5, r_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
        end
    end

    sasl.gl.drawWideLine(size[1]/2 - 308, 485, size[1]/2 - 308, 663, 2.5, ECAM_WHITE)
    sasl.gl.drawWideLine(size[1]/2 + 308, 485, size[1]/2 + 308, 663, 2.5, ECAM_WHITE)
    sasl.gl.drawWideLine(size[1]/2 - 190, 244, size[1]/2 - 190, 414, 2.5, ECAM_WHITE)
    sasl.gl.drawWideLine(size[1]/2 + 190, 244, size[1]/2 + 190, 414, 2.5, ECAM_WHITE)
    sasl.gl.drawTexture(ECAM_FCTL_rudder_track_img, 382, 164, 139, 21, ECAM_WHITE)

    --surface index animations--
    local aileron_anim = {
        {-25, 648},
        {0, 558},
        {10, 541},
        {25, 468},
    }
    local elevator_anim = {
        {-30, 392},
        {0, 291},
        {17, 235},
    }
    local rudder_anim = {
        {-30, 28},
        {-25, 20},
        {0, 0},
        {25, -20},
        {30, -28},
    }
    local rudder_lim_anim = {
        {-30, 31},
        {-25, 23},
        {0, 0},
        {25, -23},
        {30, -31},
    }

    --ailerons--
    if FBW.fctl.AIL.STAT.L.data_avail then
        sasl.gl.drawTexture(ECAM_FCTL_left_arrows_img,  139, Table_interpolate(aileron_anim, params.L_aileron), 26, 30, FBW.fctl.AIL.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, 165, 564, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if FBW.fctl.AIL.STAT.R.data_avail then
        sasl.gl.drawTexture(ECAM_FCTL_right_arrows_img, 736, Table_interpolate(aileron_anim, params.R_aileron), 26, 30, FBW.fctl.AIL.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, 736, 564, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    --elevators--
    if FBW.fctl.ELEV.STAT.L.data_avail then
        sasl.gl.drawTexture(ECAM_FCTL_left_arrows_img,  258, Table_interpolate(elevator_anim, params.L_elevator), 26, 30, FBW.fctl.ELEV.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, 284, 297, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if FBW.fctl.ELEV.STAT.R.data_avail then
        sasl.gl.drawTexture(ECAM_FCTL_right_arrows_img, 617, Table_interpolate(elevator_anim, params.R_elevator), 26, 30, FBW.fctl.ELEV.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, 617, 297, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    --rudder
    if FBW.fctl.surfaces.rud.rud.data_avail then
        SASL_rotated_center_img_xcenter_aligned(ECAM_FCTL_rudder_img, size[1]/2+1, size[2]/2 - 135, 43, 155, Table_interpolate(rudder_anim, params.rudder), 0, -155, FBW.fctl.surfaces.rud.rud.mechanical and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2-250, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if FBW.fctl.surfaces.rud.lim.data_avail then
        SASL_rotated_center_img_xcenter_aligned(ECAM_FCTL_left_rudder_lim_img,  size[1]/2+1, size[2]/2 - 150, 43, 155, Table_interpolate(rudder_lim_anim, -get(Rudder_travel_lim)),  4, -160, FBW.fctl.surfaces.rud.lim.controlled and ECAM_GREEN or ECAM_ORANGE)
        SASL_rotated_center_img_xcenter_aligned(ECAM_FCTL_right_rudder_lim_img, size[1]/2+1, size[2]/2 - 150, 43, 155, Table_interpolate(rudder_lim_anim,  get(Rudder_travel_lim)), -4, -160, FBW.fctl.surfaces.rud.lim.controlled and ECAM_GREEN or ECAM_ORANGE)
    end
    if FBW.fctl.surfaces.rud.trim.data_avail then
        SASL_rotated_center_img_xcenter_aligned(ECAM_FCTL_rudder_trim_img, size[1]/2+1, size[2]/2 - 150, 43, 155, Table_interpolate(rudder_lim_anim, Math_clamp(get(Rudder_trim_target_angle), -get(Rudder_travel_lim), get(Rudder_travel_lim))), 0, -160, FBW.fctl.surfaces.rud.trim.controlled and ECAM_BLUE or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2-320, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    -- rudder
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-26, size[2]/2-164, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2-164, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+29, size[2]/2-164, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

    -- spdbrk
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-26, size[2]/2+405, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2+405, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+29, size[2]/2+405, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

    -- elevators
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-263, size[2]/2-189, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-233, size[2]/2-189, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)

    if is_FCDC_1_ok or is_FCDC_2_ok then
        sasl.gl.drawWideLine(size[1]/2 - 276, size[2]/2 - 194, size[1]/2 - 249, size[2]/2 - 194, 2, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 250, size[2]/2 - 193, size[1]/2 - 250, size[2]/2 - 164, 2, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 276, size[2]/2 - 163, size[1]/2 - 249, size[2]/2 - 163, 2, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)

        sasl.gl.drawWideLine(size[1]/2 - 247, size[2]/2 - 194, size[1]/2 - 220, size[2]/2 - 194, 2, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 221, size[2]/2 - 193, size[1]/2 - 221, size[2]/2 - 164, 2, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 247, size[2]/2 - 163, size[1]/2 - 220, size[2]/2 - 163, 2, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    end

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+233, size[2]/2-189, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+263, size[2]/2-189, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

    if is_FCDC_1_ok or is_FCDC_2_ok then
        sasl.gl.drawWideLine(size[1]/2 + 221, size[2]/2 - 194, size[1]/2 + 248, size[2]/2 - 194, 2, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 247, size[2]/2 - 193, size[1]/2 + 247, size[2]/2 - 164, 2, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 221, size[2]/2 - 163, size[1]/2 + 248, size[2]/2 - 163, 2, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)

        sasl.gl.drawWideLine(size[1]/2 + 250, size[2]/2 - 194, size[1]/2 + 277, size[2]/2 - 194, 2, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 276, size[2]/2 - 193, size[1]/2 + 276, size[2]/2 - 164, 2, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 250, size[2]/2 - 163, size[1]/2 + 277, size[2]/2 - 163, 2, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    end

    -- pitch trim
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+98, size[2]/2-8, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+125, size[2]/2-8, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

    -- ailerons
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-263, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-233, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)

    if is_FCDC_1_ok or is_FCDC_2_ok then
        sasl.gl.drawWideLine(size[1]/2 - 276, size[2]/2 + 41, size[1]/2 - 249, size[2]/2 + 41, 2, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 250, size[2]/2 + 42, size[1]/2 - 250, size[2]/2 + 71, 2, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 276, size[2]/2 + 72, size[1]/2 - 249, size[2]/2 + 72, 2, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)

        sasl.gl.drawWideLine(size[1]/2 - 247, size[2]/2 + 41, size[1]/2 - 220, size[2]/2 + 41, 2, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 221, size[2]/2 + 42, size[1]/2 - 221, size[2]/2 + 71, 2, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 - 247, size[2]/2 + 72, size[1]/2 - 220, size[2]/2 + 72, 2, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    end

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+233, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+263, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

    if is_FCDC_1_ok or is_FCDC_2_ok then
        sasl.gl.drawWideLine(size[1]/2 + 221, size[2]/2 + 41, size[1]/2 + 248, size[2]/2 + 41, 2, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 247, size[2]/2 + 42, size[1]/2 + 247, size[2]/2 + 71, 2, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 221, size[2]/2 + 72, size[1]/2 + 248, size[2]/2 + 72, 2, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)

        sasl.gl.drawWideLine(size[1]/2 + 250, size[2]/2 + 41, size[1]/2 + 277, size[2]/2 + 41, 2, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 276, size[2]/2 + 42, size[1]/2 + 276, size[2]/2 + 71, 2, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + 250, size[2]/2 + 72, size[1]/2 + 277, size[2]/2 + 72, 2, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    end

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-28, size[2]/2-8, "PITCH TRIM", 31, false, false, TEXT_ALIGN_CENTER, get(FAILURE_FCTL_THS_MECH) == 0 and ECAM_WHITE or ECAM_ORANGE)

    if FBW.fctl.THS.STAT.data_avail then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-50, string.format("%.1f", tostring(math.abs(get(THS_DEF)))), 30, false, false, TEXT_ALIGN_CENTER, FBW.fctl.THS.STAT.controlled and ECAM_GREEN or ECAM_ORANGE)
        if get(THS_DEF) >= 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "UP", 30, false, false, TEXT_ALIGN_CENTER, FBW.fctl.THS.STAT.controlled and ECAM_GREEN or ECAM_ORANGE)
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "DN", 30, false, false, TEXT_ALIGN_CENTER, FBW.fctl.THS.STAT.controlled and ECAM_GREEN or ECAM_ORANGE)
        end
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-50, "X.X", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end
