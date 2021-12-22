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
    tlu = 0,
    rudder_trim = 0,
    last_update = 0
}

function ecam_update_fctl_page()
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.L_aileron   = get(L_aileron)
        params.R_aileron   = get(R_aileron)
        params.L_elevator  = get(L_elevator)
        params.R_elevator  = get(R_elevator)
        params.rudder      = get(Rudder_total) * 30/25
        params.tlu         = get(Rudder_travel_lim) * 30/25
        params.rudder_trim = Math_clamp(get(RUD_TRIM_TGT_ANGLE), -get(Rudder_travel_lim), get(Rudder_travel_lim)) * 30/25
        params.last_update = get(TIME)
    end
end

local function draw_title()
    sasl.gl.drawText(AirbusDUFont, 75, 860, "F/CTL", 41, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(8, 856, 138, 856, 3, ECAM_WHITE)
end

local function draw_hyd_rectangles()
    --SPOILERS--
    sasl.gl.drawRectangle (409, 857, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (437, 857, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (465, 857, 25, 30, {0.251,0.310, 0.373})

    --AILERONS--
    sasl.gl.drawRectangle (140, 526, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (168, 526, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (707, 526, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (735, 526, 25, 30, {0.251,0.310, 0.373})

    --ELEVATORS--
    sasl.gl.drawRectangle (162, 272, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (190, 272, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (685, 272, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (713, 272, 25, 30, {0.251,0.310, 0.373})

    --THS--
    sasl.gl.drawRectangle (535, 459, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (563, 459, 25, 30, {0.251,0.310, 0.373})

    --RUDDER--
    sasl.gl.drawRectangle (409, 326, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (437, 326, 25, 30, {0.251,0.310, 0.373})
    sasl.gl.drawRectangle (465, 326, 25, 30, {0.251,0.310, 0.373})
end

local function draw_flt_computer_brackets()
    --ailerons
    sasl.gl.drawWideLine(140, 528, 165, 528, 3, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(164, 526, 164, 556, 3, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(140, 555, 165, 555, 3, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)

    sasl.gl.drawWideLine(168, 528, 193, 528, 3, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(192, 526, 192, 556, 3, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(168, 555, 193, 555, 3, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)

    sasl.gl.drawWideLine(707, 528, 732, 528, 3, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(731, 526, 731, 556, 3, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(707, 555, 732, 555, 3, get(ELAC_1_status) == 1 and {0,0,0,0} or ECAM_ORANGE)

    sasl.gl.drawWideLine(735, 528, 760, 528, 3, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(759, 526, 759, 556, 3, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(735, 555, 760, 555, 3, get(ELAC_2_status) == 1 and {0,0,0,0} or ECAM_ORANGE)

    -- elevators
    sasl.gl.drawWideLine(162, 274, 187, 274, 3, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(186, 272, 186, 302, 3, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(162, 301, 187, 301, 3, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)

    sasl.gl.drawWideLine(190, 274, 215, 274, 3, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(214, 272, 214, 302, 3, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(190, 301, 215, 301, 3, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)

    sasl.gl.drawWideLine(685, 274, 710, 274, 3, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(709, 272, 709, 302, 3, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(685, 301, 710, 301, 3, (get(ELAC_2_status) == 1 or get(SEC_2_status) == 1) and {0,0,0,0} or ECAM_ORANGE)

    sasl.gl.drawWideLine(713, 274, 738, 274, 3, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(737, 272, 737, 302, 3, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawWideLine(713, 301, 738, 301, 3, (get(ELAC_1_status) == 1 or get(SEC_1_status) == 1) and {0,0,0,0} or ECAM_ORANGE)
end

local function draw_hyd_letters()
    --TODO: SADC status

    local G_ok = get(Hydraulic_G_press) >= 1450
    local B_ok = get(Hydraulic_B_press) >= 1450
    local Y_ok = get(Hydraulic_Y_press) >= 1450

    --SPOILERS--
    sasl.gl.drawText(AirbusDUFont, 423, 862, "G", 26, true, false, TEXT_ALIGN_CENTER, G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 451, 862, "B", 26, true, false, TEXT_ALIGN_CENTER, B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 479, 862, "Y", 26, true, false, TEXT_ALIGN_CENTER, Y_ok and ECAM_GREEN or ECAM_ORANGE)

    --AILERONS--
    sasl.gl.drawText(AirbusDUFont, 154, 531, "B", 26, true, false, TEXT_ALIGN_CENTER, B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 182, 531, "G", 26, true, false, TEXT_ALIGN_CENTER, G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 721, 531, "G", 26, true, false, TEXT_ALIGN_CENTER, G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 749, 531, "B", 26, true, false, TEXT_ALIGN_CENTER, B_ok and ECAM_GREEN or ECAM_ORANGE)

    --ELEVATORS--
    sasl.gl.drawText(AirbusDUFont, 176, 277, "B", 26, true, false, TEXT_ALIGN_CENTER, B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 204, 277, "G", 26, true, false, TEXT_ALIGN_CENTER, G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 699, 277, "Y", 26, true, false, TEXT_ALIGN_CENTER, Y_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 727, 277, "B", 26, true, false, TEXT_ALIGN_CENTER, B_ok and ECAM_GREEN or ECAM_ORANGE)

    --THS--
    sasl.gl.drawText(AirbusDUFont, 549, 464, "G", 26, true, false, TEXT_ALIGN_CENTER, G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 577, 464, "Y", 26, true, false, TEXT_ALIGN_CENTER, Y_ok and ECAM_GREEN or ECAM_ORANGE)

    --RUDDER--
    sasl.gl.drawText(AirbusDUFont, 423, 331, "G", 26, true, false, TEXT_ALIGN_CENTER, G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 451, 331, "B", 26, true, false, TEXT_ALIGN_CENTER, B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 479, 331, "Y", 26, true, false, TEXT_ALIGN_CENTER, Y_ok and ECAM_GREEN or ECAM_ORANGE)
end

local function draw_spoilers()
    sasl.gl.drawWideLine(203, 736, 203, 744, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(201, 736, 359, 753, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(358, 753, 358, 761, 3, ECAM_LINE_GREY)

    sasl.gl.drawWideLine(698, 736, 698, 744, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(699, 736, 541, 753, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(543, 753, 543, 761, 3, ECAM_LINE_GREY)

    sasl.gl.drawWideLine(145, 814, 145, 822, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(143, 822, 356, 858, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(356, 850, 356, 859, 3, ECAM_LINE_GREY)

    sasl.gl.drawWideLine(756, 814, 756, 822, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(757, 822, 544, 858, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(545, 850, 545, 859, 3, ECAM_LINE_GREY)

    sasl.gl.drawText(AirbusDUFont, 450, 738, "SPD BRK", 29, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    local num_of_spoilers = 5
    local spoiler_track_length = 22

    local l_spoilers_avail = {
        FCTL.SPLR.STAT.L[1].controlled,
        FCTL.SPLR.STAT.L[2].controlled,
        FCTL.SPLR.STAT.L[3].controlled,
        FCTL.SPLR.STAT.L[4].controlled,
        FCTL.SPLR.STAT.L[5].controlled,
    }
    local r_spoilers_avail = {
        FCTL.SPLR.STAT.R[1].controlled,
        FCTL.SPLR.STAT.R[2].controlled,
        FCTL.SPLR.STAT.R[3].controlled,
        FCTL.SPLR.STAT.R[4].controlled,
        FCTL.SPLR.STAT.R[5].controlled,
    }
    local l_spoilers_data_avail = {
        FCTL.SPLR.STAT.L[1].data_avail,
        FCTL.SPLR.STAT.L[2].data_avail,
        FCTL.SPLR.STAT.L[3].data_avail,
        FCTL.SPLR.STAT.L[4].data_avail,
        FCTL.SPLR.STAT.L[5].data_avail,
    }
    local r_spoilers_data_avail = {
        FCTL.SPLR.STAT.R[1].data_avail,
        FCTL.SPLR.STAT.R[2].data_avail,
        FCTL.SPLR.STAT.R[3].data_avail,
        FCTL.SPLR.STAT.R[4].data_avail,
        FCTL.SPLR.STAT.R[5].data_avail,
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
        {43, 783},
        {100, 775},
        {157, 767},
        {214, 759},
        {271, 751},
    }

    local spoiler_arrow_x_y = {
        {54, 783},
        {111, 775},
        {168, 767},
        {225, 759},
        {282, 751},
    }

    local spoiler_num_x_y = {
        {54, 787},
        {111, 779},
        {168, 771},
        {225, 763},
        {282, 755},
    }

    for i = 1, num_of_spoilers do
        if l_spoilers_data_avail[i] then
            if get(l_spoiler_dataref[i]) > 2.5 then
                if l_spoilers_avail[i] then
                    sasl.gl.drawWideLine(size[1]/2 - spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2], size[1]/2 - spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2]+33, 3, ECAM_GREEN)
                end
                sasl.gl.drawWideLine(size[1]/2 - spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2]+54, size[1]/2 - spoiler_arrow_x_y[i][1]-10, spoiler_arrow_x_y[i][2]+30, 3, l_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
                sasl.gl.drawWideLine(size[1]/2 - spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2]+54, size[1]/2 - spoiler_arrow_x_y[i][1]+10, spoiler_arrow_x_y[i][2]+30, 3, l_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
                sasl.gl.drawWideLine(size[1]/2 - spoiler_arrow_x_y[i][1]-10, spoiler_arrow_x_y[i][2]+32, size[1]/2 - spoiler_arrow_x_y[i][1]+10, spoiler_arrow_x_y[i][2]+32, 3, l_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
            end

            if not l_spoilers_avail[i] then
                sasl.gl.drawText(AirbusDUFont, size[1]/2 - spoiler_num_x_y[i][1] + 2, spoiler_num_x_y[i][2], i, 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
            end
        else
            sasl.gl.drawText(AirbusDUFont, size[1]/2 - spoiler_num_x_y[i][1] + 2, spoiler_num_x_y[i][2], "X", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end
        if r_spoilers_data_avail[i] then
            if get(r_spoiler_dataref[i]) > 2.5 then
                if r_spoilers_avail[i] then
                    sasl.gl.drawWideLine(size[1]/2 + spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2], size[1]/2 + spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2]+33, 3, ECAM_GREEN)
                end
                sasl.gl.drawWideLine(size[1]/2 + spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2]+54, size[1]/2 + spoiler_arrow_x_y[i][1]-10, spoiler_arrow_x_y[i][2]+30, 3, r_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
                sasl.gl.drawWideLine(size[1]/2 + spoiler_arrow_x_y[i][1], spoiler_arrow_x_y[i][2]+54, size[1]/2 + spoiler_arrow_x_y[i][1]+10, spoiler_arrow_x_y[i][2]+30, 3, r_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
                sasl.gl.drawWideLine(size[1]/2 + spoiler_arrow_x_y[i][1]-10, spoiler_arrow_x_y[i][2]+32, size[1]/2 + spoiler_arrow_x_y[i][1]+10, spoiler_arrow_x_y[i][2]+32, 3, r_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
            end

            if not r_spoilers_avail[i] then
                sasl.gl.drawText(AirbusDUFont, size[1]/2 + spoiler_num_x_y[i][1] + 2, spoiler_num_x_y[i][2], i, 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
            end
        else
            sasl.gl.drawText(AirbusDUFont, size[1]/2 + spoiler_num_x_y[i][1] + 2, spoiler_num_x_y[i][2], "X", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end

        if l_spoilers_data_avail[i] then
            sasl.gl.drawWideLine(size[1]/2 - spoiler_track_x_y[i][1], spoiler_track_x_y[i][2], size[1]/2 - spoiler_track_x_y[i][1] - spoiler_track_length, spoiler_track_x_y[i][2], 3, l_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
        end
        if r_spoilers_data_avail[i] then
            sasl.gl.drawWideLine(size[1]/2 + spoiler_track_x_y[i][1], spoiler_track_x_y[i][2], size[1]/2 + spoiler_track_x_y[i][1] + spoiler_track_length, spoiler_track_x_y[i][2], 3, r_spoilers_avail[i] and ECAM_GREEN or ECAM_ORANGE)
        end
    end
end

local function draw_aileron_index()
    local aileron_anim = {
        {-27, 686},
        {0,   602},
        {27,  518},
    }

    --L AIL--
    sasl.gl.drawText(AirbusDUFont, 45, 669, "L",   33, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(AirbusDUFont, 45, 637, "AIL", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawWideLine(108, 516, 108, 688, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(99, 687, 109, 687, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(99, 644, 109, 644, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(101, 642, 101, 688, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(99, 606, 109, 606, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(99, 599, 109, 599, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(99, 575, 109, 575, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(99, 568, 109, 568, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(101, 566, 101, 576, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(99, 530, 109, 530, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(99, 518, 109, 518, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(101, 516, 101, 531, 3, ECAM_WHITE)

    if FCTL.AIL.STAT.L.data_avail then
        sasl.gl.drawWideLine(106,    Table_interpolate(aileron_anim, params.L_aileron),    106+20, Table_interpolate(aileron_anim, params.L_aileron)+10, 3, FCTL.AIL.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(106,    Table_interpolate(aileron_anim, params.L_aileron),    106+20, Table_interpolate(aileron_anim, params.L_aileron)-10, 3, FCTL.AIL.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(106+20, Table_interpolate(aileron_anim, params.L_aileron)-11, 106+20, Table_interpolate(aileron_anim, params.L_aileron)+11, 3, FCTL.AIL.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(AirbusDUFont, 132, 591, "XX", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    --R AIL--
    sasl.gl.drawText(AirbusDUFont, 855, 669, "R",   33, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(AirbusDUFont, 855, 637, "AIL", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawWideLine(793, 516, 793, 688, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(801, 687, 791, 687, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(801, 644, 791, 644, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(800, 642, 800, 688, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(801, 606, 791, 606, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(801, 599, 791, 599, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(801, 575, 791, 575, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(801, 568, 791, 568, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(800, 566, 800, 576, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(801, 530, 791, 530, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(801, 518, 791, 518, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(800, 516, 800, 531, 3, ECAM_WHITE)

    if FCTL.AIL.STAT.R.data_avail then
        sasl.gl.drawWideLine(794,    Table_interpolate(aileron_anim, params.R_aileron),    794-20, Table_interpolate(aileron_anim, params.R_aileron)+10, 3, FCTL.AIL.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(794,    Table_interpolate(aileron_anim, params.R_aileron),    794-20, Table_interpolate(aileron_anim, params.R_aileron)-10, 3, FCTL.AIL.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(795-20, Table_interpolate(aileron_anim, params.R_aileron)-11, 795-20, Table_interpolate(aileron_anim, params.R_aileron)+11, 3, FCTL.AIL.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(AirbusDUFont, 772, 591, "XX", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_elevator_index()
    local elevator_anim = {
        {-32, 429},
        {0,   319},
        {19,  260},
    }

    --L ELEV--
    sasl.gl.drawText(AirbusDUFont, 184, 407, "L",    33, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(AirbusDUFont, 184, 376, "ELEV", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawWideLine(252, 258, 252, 431, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(243, 430, 253, 430, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(243, 416, 253, 416, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(245, 414, 245, 431, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(243, 323, 253, 323, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(243, 316, 253, 316, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(245, 314, 245, 324, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(243, 274, 253, 274, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(243, 260, 253, 260, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(245, 258, 245, 275, 3, ECAM_WHITE)

    if FCTL.ELEV.STAT.L.data_avail then
        sasl.gl.drawWideLine(250,    Table_interpolate(elevator_anim, params.L_elevator),    250+20, Table_interpolate(elevator_anim, params.L_elevator)+10, 3, FCTL.ELEV.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(250,    Table_interpolate(elevator_anim, params.L_elevator),    250+20, Table_interpolate(elevator_anim, params.L_elevator)-10, 3, FCTL.ELEV.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(250+20, Table_interpolate(elevator_anim, params.L_elevator)-11, 250+20, Table_interpolate(elevator_anim, params.L_elevator)+11, 3, FCTL.ELEV.STAT.L.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(AirbusDUFont, 276, 308, "XX", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    --R ELEV--
    sasl.gl.drawText(AirbusDUFont, 716, 407, "R",    33, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(AirbusDUFont, 716, 376, "ELEV", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawWideLine(649, 258, 649, 431, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(657, 430, 647, 430, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(657, 416, 647, 416, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(656, 414, 656, 431, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(657, 323, 647, 323, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(657, 316, 647, 316, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(656, 314, 656, 324, 3, ECAM_WHITE)

    sasl.gl.drawWideLine(657, 274, 647, 274, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(657, 260, 647, 260, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(656, 258, 656, 275, 3, ECAM_WHITE)

    if FCTL.ELEV.STAT.R.data_avail then
        sasl.gl.drawWideLine(650,    Table_interpolate(elevator_anim, params.R_elevator),    650-20, Table_interpolate(elevator_anim, params.R_elevator)+10, 3, FCTL.ELEV.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(650,    Table_interpolate(elevator_anim, params.R_elevator),    650-20, Table_interpolate(elevator_anim, params.R_elevator)-10, 3, FCTL.ELEV.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawWideLine(651-20, Table_interpolate(elevator_anim, params.R_elevator)-11, 651-20, Table_interpolate(elevator_anim, params.R_elevator)+11, 3, FCTL.ELEV.STAT.R.controlled and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(AirbusDUFont, 628, 308, "XX", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_pitch_trim()
    sasl.gl.drawWideLine(316, 402, 360, 425, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(317, 371, 317, 402, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(317, 372, 400, 382, 3, ECAM_LINE_GREY)

    sasl.gl.drawWideLine(584, 402, 540, 425, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(583, 371, 583, 402, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(583, 372, 500, 382, 3, ECAM_LINE_GREY)

    sasl.gl.drawText(AirbusDUFont, 417, 465, "PITCH TRIM", 29, true, false, TEXT_ALIGN_CENTER, get(FAILURE_FCTL_THS_MECH) == 0 and ECAM_WHITE or ECAM_ORANGE)

    sasl.gl.drawText(AirbusDUFont, 415, 430, FCTL.THS.STAT.data_avail and math.floor(math.abs(get(THS_DEF))) or "X",      34, true, false,  TEXT_ALIGN_RIGHT, (FCTL.THS.STAT.controlled and FCTL.THS.STAT.data_avail) and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 420, 430, ".",                                                                             34, true, false, TEXT_ALIGN_CENTER, (FCTL.THS.STAT.controlled and FCTL.THS.STAT.data_avail) and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 442, 430, FCTL.THS.STAT.data_avail and math.floor(math.abs(get(THS_DEF))%1*10) or "X", 25, true, false, TEXT_ALIGN_CENTER, (FCTL.THS.STAT.controlled and FCTL.THS.STAT.data_avail) and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(AirbusDUFont, 465, 430, "°",                                                                             34, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(AirbusDUFont, 501, 430, FCTL.THS.STAT.data_avail and (get(THS_DEF) >= 0 and "UP" or "DN") or "",     25, true, false, TEXT_ALIGN_CENTER, (FCTL.THS.STAT.controlled and FCTL.THS.STAT.data_avail) and ECAM_GREEN or ECAM_ORANGE)
end

local function draw_rudder()
    sasl.gl.drawText(AirbusDUFont, 448, 372, "RUD", 29, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawArc(450, 350, 150, 153, 240, 60, ECAM_WHITE)

    SASL_draw_needle_adv(450, 350, 150, 160, 240, 3, ECAM_WHITE)
    SASL_draw_needle_adv(450, 350, 150, 160, 244, 3, ECAM_WHITE)
    sasl.gl.drawArc(450, 350, 157, 160, 240, 4, ECAM_WHITE)

    SASL_draw_needle_adv(450, 350, 150, 160, 296, 3, ECAM_WHITE)
    SASL_draw_needle_adv(450, 350, 150, 160, 300, 3, ECAM_WHITE)
    sasl.gl.drawArc(450, 350, 157, 160, 296, 4, ECAM_WHITE)

    if FCTL.RUD.STAT.data_avail then
        --RUDDER LIM--
        SASL_draw_needle_adv(450, 350, 150, 178, 270 - params.tlu, 3, FCTL.RUD.STAT.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawArc(450, 350, 175, 178, 270 - params.tlu, 2, FCTL.RUD.STAT.controlled and ECAM_GREEN or ECAM_ORANGE)
        SASL_draw_needle_adv(450, 350, 150, 178, 270 + params.tlu, 3, FCTL.RUD.STAT.controlled and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawArc(450, 350, 175, 178, 270 + params.tlu - 2, 2, FCTL.RUD.STAT.controlled and ECAM_GREEN or ECAM_ORANGE)

        --RUDDER SURFACE--
        sasl.gl.drawArc(
            Get_rotated_point_x_CC_pos(450, 84, 180 - params.rudder),
            Get_rotated_point_y_CC_pos(350, 84, 180 - params.rudder),
            9,
            12,
            params.rudder,
            180,
            FCTL.RUD.STAT.controlled and ECAM_GREEN or ECAM_ORANGE
        )
        sasl.gl.drawWideLine(
            Get_rotated_point_x_pos_offset(450, 84, 180 - params.rudder, 11),
            Get_rotated_point_y_pos_offset(350, 84, 180 - params.rudder, 11),
            Get_rotated_point_x_CC_pos(450, 150, 180 - params.rudder),
            Get_rotated_point_y_CC_pos(350, 150, 180 - params.rudder),
            3,
            FCTL.RUD.STAT.controlled and ECAM_GREEN or ECAM_ORANGE
        )
        sasl.gl.drawWideLine(
            Get_rotated_point_x_pos_offset(450, 84, 180 - params.rudder, -11),
            Get_rotated_point_y_pos_offset(350, 84, 180 - params.rudder, -11),
            Get_rotated_point_x_CC_pos(450, 150, 180 - params.rudder),
            Get_rotated_point_y_CC_pos(350, 150, 180 - params.rudder),
            3,
            FCTL.RUD.STAT.controlled and ECAM_GREEN or ECAM_ORANGE
        )

        if FCTL.RUD.STAT.bkup_ctl then
            sasl.gl.drawText(AirbusDUFont, 450, size[2]/2-154, "NORM CTL", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end
    else
        sasl.gl.drawText(AirbusDUFont, 452, size[2]/2-220, "XX", 28, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    --RUDDER TRIM--
    if FCTL.RUDTRIM.STAT.data_avail then
        SASL_draw_needle_adv(450, 350, 159, 179, 270 + params.rudder_trim, 4, FCTL.RUDTRIM.STAT.controlled and ECAM_BLUE or ECAM_ORANGE)
    end

    --TRIM OR LIMIT XX
    if not FCTL.RUDTRIM.STAT.data_avail or not FCTL.RUD.STAT.data_avail then
        sasl.gl.drawText(AirbusDUFont, 452, size[2]/2-285, "XX", 28, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    SASL_draw_needle_adv(450, 350, 153, 161, 269, 3, ECAM_WHITE)
    SASL_draw_needle_adv(450, 350, 153, 161, 271, 3, ECAM_WHITE)
    sasl.gl.drawArc(450, 350, 158, 161, 269, 2, ECAM_WHITE)
end

local function draw_flt_computers()
    local FCDC_1_ok = get(FCDC_1_status) == 1
    local FCDC_2_ok = get(FCDC_2_status) == 1

    local ELAC_txt = {
        (FCDC_1_ok or FCDC_2_ok) and "1" or "X",
        (FCDC_1_ok or FCDC_2_ok) and "2" or "X",
    }
    local ELAC_txt_cl = {
        get(ELAC_1_status) == 1 and (FCDC_1_ok or FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
        get(ELAC_2_status) == 1 and (FCDC_1_ok or FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
    }
    local ELAC_box_cl = {
        get(ELAC_1_status) == 0 and (FCDC_1_ok or FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
        get(ELAC_2_status) == 0 and (FCDC_1_ok or FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
    }

    sasl.gl.drawText(AirbusDUFont, 292, 632, "ELAC", 25, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(AirbusDUFont, 349, 631, ELAC_txt[1], 28, true, false, TEXT_ALIGN_CENTER, ELAC_txt_cl[1])
    sasl.gl.drawWideLine(353, 661, 365, 661, 3, ELAC_box_cl[1])
    sasl.gl.drawWideLine(364, 621, 364, 662, 3, ELAC_box_cl[1])
    sasl.gl.drawWideLine(253, 623, 365, 623, 3, ELAC_box_cl[1])

    sasl.gl.drawText(AirbusDUFont, 384, 610, ELAC_txt[2], 28, true, false, TEXT_ALIGN_CENTER, ELAC_txt_cl[2])
    sasl.gl.drawWideLine(388, 640, 400, 640, 3, ELAC_box_cl[2])
    sasl.gl.drawWideLine(399, 600, 399, 641, 3, ELAC_box_cl[2])
    sasl.gl.drawWideLine(288, 602, 400, 602, 3, ELAC_box_cl[2])

    --SECs--
    local SEC_txt = {
        (FCDC_1_ok or FCDC_2_ok) and "1" or "X",
        (FCDC_1_ok or FCDC_2_ok) and "2" or "X",
    }
    local SEC_txt_cl = {
        get(SEC_1_status) == 1 and (FCDC_1_ok or FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
        get(SEC_2_status) == 1 and (FCDC_1_ok or FCDC_2_ok) and ECAM_GREEN or ECAM_ORANGE,
    }
    local SEC_box_cl = {
        get(SEC_1_status) == 0 and (FCDC_1_ok or FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
        get(SEC_2_status) == 0 and (FCDC_1_ok or FCDC_2_ok) and ECAM_ORANGE or ECAM_LINE_GREY,
    }

    sasl.gl.drawText(AirbusDUFont, 501, 632, "SEC",  25, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(AirbusDUFont, 557, 631, SEC_txt[1], 28, true, false, TEXT_ALIGN_CENTER, SEC_txt_cl[1])
    sasl.gl.drawWideLine(561, 661, 573, 661, 3, SEC_box_cl[1])
    sasl.gl.drawWideLine(572, 621, 572, 662, 3, SEC_box_cl[1])
    sasl.gl.drawWideLine(461, 623, 573, 623, 3, SEC_box_cl[1])

    sasl.gl.drawText(AirbusDUFont, 592, 610, SEC_txt[2], 28, true, false, TEXT_ALIGN_CENTER, SEC_txt_cl[2])
    sasl.gl.drawWideLine(596, 640, 608, 640, 3, SEC_box_cl[2])
    sasl.gl.drawWideLine(607, 600, 607, 641, 3, SEC_box_cl[2])
    sasl.gl.drawWideLine(496, 602, 608, 602, 3, SEC_box_cl[2])
end

local function draw_laf_msg()
    if get(FBW_LAF_DATA_AVAIL) == 1 then
        if (get(FBW_LAF_DEGRADED_AIL) + get(FBW_LAF_DEGRADED_SPLR_4) + get(FBW_LAF_DEGRADED_SPLR_5)) > 0 then
            sasl.gl.drawText(AirbusDUFont, 450, 690, "LAF DEGRADED", 29, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end
    end
end

function draw_fctl_page()
    draw_title()

    draw_hyd_rectangles()
    draw_flt_computer_brackets()
    draw_hyd_letters()

    draw_spoilers()

    draw_aileron_index()

    draw_elevator_index()

    draw_pitch_trim()

    draw_rudder()

    draw_flt_computers()
    draw_laf_msg()
end