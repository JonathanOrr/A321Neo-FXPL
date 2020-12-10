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

function draw_fctl_page()
    sasl.gl.drawTexture(ECAM_FCTL_bgd_img, 0, 0, 900, 900, {1,1,1})
    sasl.gl.drawTexture(ECAM_FCTL_grey_lines_img, 0, 0, 900, 900, ECAM_LINE_GREY)

    --draw flight computers--
    --ELACs--
    sasl.gl.drawText(Font_AirbusDUL, 298, 599, "ELAC", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 348, 599, "1", 30, false, false, TEXT_ALIGN_CENTER, get(ELAC_1_status) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 242, 584, 128, 52, get(ELAC_1_status) == 1 and ECAM_LINE_GREY or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, 386, 576, "2", 30, false, false, TEXT_ALIGN_CENTER, get(ELAC_2_status) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 279, 561, 128, 52, get(ELAC_2_status) == 1 and ECAM_LINE_GREY or ECAM_ORANGE)
    --SECs--
    sasl.gl.drawText(Font_AirbusDUL, 522, 599, "SEC", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 573, 599, "1", 30, false, false, TEXT_ALIGN_CENTER, get(SEC_1_status) == 1 and ECAM_GREEN or ECAM_ORANGE )
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 467, 584, 128, 52, get(SEC_1_status) == 1 and ECAM_LINE_GREY or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, 611, 576, "2", 30, false, false, TEXT_ALIGN_CENTER, get(SEC_2_status) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 504, 561, 128, 52, get(SEC_2_status) == 1 and ECAM_LINE_GREY or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, 649, 553, "3", 30, false, false, TEXT_ALIGN_CENTER, get(SEC_3_status) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawTexture(ECAM_FCTL_computer_backets_img, 541, 538, 128, 52, get(SEC_3_status) == 1 and ECAM_LINE_GREY or ECAM_ORANGE)

    --track indication--
    local num_of_spoilers = 5
    local spoiler_track_length = 22

    local l_spoilers_avail_dataref = {
        L_spoiler_1_avail,
        L_spoiler_2_avail,
        L_spoiler_3_avail,
        L_spoiler_4_avail,
        L_spoiler_5_avail,
    }

    local r_spoilers_avail_dataref = {
        R_spoiler_1_avail,
        R_spoiler_2_avail,
        R_spoiler_3_avail,
        R_spoiler_4_avail,
        R_spoiler_5_avail,
    }

    local l_spoiler_dataref = {
        Left_spoiler_1,
        Left_spoiler_2,
        Left_spoiler_3,
        Left_spoiler_4,
        Left_spoiler_5,
    }

    local r_spoiler_dataref = {
        Right_spoiler_1,
        Right_spoiler_2,
        Right_spoiler_3,
        Right_spoiler_4,
        Right_spoiler_5,
    }

    local spoiler_track_x_y = {
        {44, 767},
        {100, 758},
        {156, 749},
        {212, 739},
        {269, 730},
    }

    local spoiler_arrow_x_y = {
        {55, 778},
        {111, 769},
        {167, 760},
        {223, 750},
        {280, 741},
    }

    local spoiler_num_x_y = {
        {54, 772},
        {111, 763},
        {167, 754},
        {223, 744},
        {280, 735},
    }

    for i = 1, num_of_spoilers do
        if get(l_spoiler_dataref[i]) > 2.5 then
            SASL_draw_img_center_aligned(ECAM_FCTL_spoiler_arrow_img, size[1]/2 - spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2], 28, 50, get(l_spoilers_avail_dataref[i]) == 1 and ECAM_GREEN or ECAM_ORANGE)
        else
            if get(l_spoilers_avail_dataref[i]) == 0 then
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - spoiler_num_x_y[i][1], spoiler_num_x_y[i][2], i, 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
            end
        end
        if get(r_spoiler_dataref[i]) > 2.5 then
            SASL_draw_img_center_aligned(ECAM_FCTL_spoiler_arrow_img, size[1]/2 + spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2], 28, 50, get(r_spoilers_avail_dataref[i]) == 1 and ECAM_GREEN or ECAM_ORANGE)
        else
            if get(r_spoilers_avail_dataref[i]) == 0 then
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + spoiler_num_x_y[i][1], spoiler_num_x_y[i][2], i, 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
            end
        end

        sasl.gl.drawWideLine(size[1]/2 - spoiler_track_x_y[i][1], spoiler_track_x_y[i][2], size[1]/2 - spoiler_track_x_y[i][1] - spoiler_track_length, spoiler_track_x_y[i][2], 2.5, get(l_spoilers_avail_dataref[i]) == 1 and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2 + spoiler_track_x_y[i][1], spoiler_track_x_y[i][2], size[1]/2 + spoiler_track_x_y[i][1] + spoiler_track_length, spoiler_track_x_y[i][2], 2.5, get(r_spoilers_avail_dataref[i]) == 1 and ECAM_GREEN or ECAM_ORANGE)
    end

    sasl.gl.drawWideLine(size[1]/2 - 308, 485, size[1]/2 - 308, 663, 2.5, get(L_aileron_avail) == 1 and ECAM_WHITE or ECAM_ORANGE)
    sasl.gl.drawWideLine(size[1]/2 + 308, 485, size[1]/2 + 308, 663, 2.5, get(R_aileron_avail) == 1 and ECAM_WHITE or ECAM_ORANGE)
    sasl.gl.drawWideLine(size[1]/2 - 190, 244, size[1]/2 - 190, 414, 2.5, get(L_elevator_avail) == 1 and ECAM_WHITE or ECAM_ORANGE)
    sasl.gl.drawWideLine(size[1]/2 + 190, 244, size[1]/2 + 190, 414, 2.5, get(R_elevator_avail) == 1 and ECAM_WHITE or ECAM_ORANGE)
    sasl.gl.drawTexture(ECAM_FCTL_rudder_track_img, 382, 164, 139, 21, get(Rudder_avail) == 1 and ECAM_WHITE or ECAM_ORANGE)

    --surface index animations--
    local aileron_anim = {
        {-25, 648},
        {0, 558},
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
    sasl.gl.drawTexture(ECAM_FCTL_left_arrows_img,  139, Table_interpolate(aileron_anim, get(Left_aileron)),  26, 30, get(L_aileron_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawTexture(ECAM_FCTL_right_arrows_img, 736, Table_interpolate(aileron_anim, get(Right_aileron)), 26, 30, get(R_aileron_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    --elevators--
    sasl.gl.drawTexture(ECAM_FCTL_left_arrows_img,  258, Table_interpolate(elevator_anim, get(Elevators_hstab_1)), 26, 30, get(L_elevator_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawTexture(ECAM_FCTL_right_arrows_img, 617, Table_interpolate(elevator_anim, get(Elevators_hstab_2)), 26, 30, get(R_elevator_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    --rudder
    SASL_rotated_center_img_xcenter_aligned( ECAM_FCTL_rudder_img,           size[1]/2+1, size[2]/2 - 135, 43, 155, Table_interpolate(rudder_anim, get(Rudder)), 0, -155, get(Rudder_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    SASL_rotated_center_img_xcenter_aligned( ECAM_FCTL_left_rudder_lim_img,  size[1]/2+1, size[2]/2 - 150, 43, 155, Table_interpolate(rudder_lim_anim, -get(Rudder_travel_lim)),  4, -160, get(Rudder_lim_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    SASL_rotated_center_img_xcenter_aligned( ECAM_FCTL_right_rudder_lim_img, size[1]/2+1, size[2]/2 - 150, 43, 155, Table_interpolate(rudder_lim_anim, get(Rudder_travel_lim)), -4, -160, get(Rudder_lim_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    SASL_rotated_center_img_xcenter_aligned( ECAM_FCTL_rudder_trim_img,      size[1]/2+1, size[2]/2 - 150, 43, 155, Table_interpolate(rudder_lim_anim, get(Rudder_trim_angle)),  0, -160, get(Rudder_trim_avail) == 1 and ECAM_BLUE or ECAM_ORANGE)

    local is_G_ok = get(Hydraulic_G_press) >= 1450
    local is_B_ok = get(Hydraulic_B_press) >= 1450
    local is_Y_ok = get(Hydraulic_Y_press) >= 1450

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

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+233, size[2]/2-189, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+263, size[2]/2-189, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

    -- pitch trim
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+98, size[2]/2-8, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+125, size[2]/2-8, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

    -- ailerons
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-263, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-233, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+233, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+263, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-28, size[2]/2-8, "PITCH TRIM", 31, false, false, TEXT_ALIGN_CENTER, get(FAILURE_FCTL_THS_MECH) == 0 and ECAM_WHITE or ECAM_ORANGE)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-50, string.format("%.1f", tostring(math.abs(get(Elev_trim_degrees)))), 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    if get(Elev_trim_degrees) >= 0 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "UP", 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "DN", 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    end
end
