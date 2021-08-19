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
-- File: ECAM_press.lua 
-- Short description: ECAM file for the PRESS page 
-------------------------------------------------------------------------------

size = {900, 900}

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)

local params = {
    delta_psi      = 0,
    cabin_vs       = 0,
    cabin_alt      = 0,
    overflow_valve = 0,
    last_update    = 0
}

local function draw_valve_inlet(pos, failed)

    local length = 58

    if math.floor(pos) == 0 then
        sasl.gl.drawWideLine(size[1]/2-179, size[2]/2-214, size[1]/2-179-length, size[2]/2-214, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    elseif math.ceil(pos) == 10 then
        sasl.gl.drawWideLine(size[1]/2-173, size[2]/2-219, size[1]/2-173, size[2]/2-219-length, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    else
        sasl.gl.drawWideLine(size[1]/2-176, size[2]/2-217, size[1]/2-176-length*math.sin(3.14/4), size[2]/2-217-length*math.sin(3.14/4), 3, ECAM_ORANGE)
    end

end

local function draw_valve_outlet(pos, failed)

    local length = 58

    if math.floor(pos) == 0 then
        sasl.gl.drawWideLine(size[1]/2-33, size[2]/2-214, size[1]/2-33+length, size[2]/2-214, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    elseif math.ceil(pos) == 5 then
        sasl.gl.drawWideLine(size[1]/2-35, size[2]/2-219, size[1]/2-35+length*math.sin(3.14/4), size[2]/2-219-length*math.sin(3.14/4), 3, failed and ECAM_ORANGE or ECAM_GREEN)
    elseif math.ceil(pos) == 10 then
        sasl.gl.drawWideLine(size[1]/2-38, size[2]/2-219, size[1]/2-38, size[2]/2-219-length, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    else
        sasl.gl.drawWideLine(size[1]/2-35, size[2]/2-219, size[1]/2-35+length*math.sin(3.14/4), size[2]/2-219-length*math.sin(3.14/4), 3, ECAM_ORANGE)
    end

end

local function get_color_green_blinking()
    if math.floor(get(TIME)) % 2 == 0 then
        return ECAM_GREEN
    else
        return ECAM_HIGH_GREEN
    end
end

local function draw_press_info()
    --pressure info
    local color_psi = ECAM_GREEN
    if params.delta_psi < -0.4 or params.delta_psi > 8.5 then
        color_psi = ECAM_ORANGE
    elseif params.delta_psi > 1.5 and get(EWD_flight_phase) == PHASE_FINAL then
        color_psi = get_color_green_blinking()
    end

    local color_vs = ECAM_GREEN
    if params.cabin_vs > 1750 then
        color_vs = get_color_green_blinking()
    end

    local color_alt = ECAM_GREEN
    if params.cabin_alt > 9950 then
        color_alt = ECAM_RED
    elseif params.cabin_alt > 8800 then
        color_alt = get_color_green_blinking()
    end

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-170, size[2]/2+150, Round_fill(params.delta_psi, 1), 40, false, false, TEXT_ALIGN_RIGHT, color_psi)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+140, size[2]/2+177, math.floor(params.cabin_vs-(params.cabin_vs%50)), 40, false, false, TEXT_ALIGN_RIGHT, color_vs)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-50, size[2]/2+150, math.floor(params.cabin_alt-(params.cabin_alt%50)),40, false, false, TEXT_ALIGN_RIGHT, color_alt)
end

local function draw_pack_indications()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-304, 140, "PACK 1", 36, false, false, TEXT_ALIGN_CENTER, (get(Pack_L) == 0 and get(Engine_1_avail) == 1) and ECAM_ORANGE or ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+330, 140, "PACK 2", 36, false, false, TEXT_ALIGN_CENTER, (get(Pack_L) == 0 and get(Engine_1_avail) == 1) and ECAM_ORANGE or ECAM_WHITE)
end

local function draw_valves_text()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-205, 270, "INLET", 34, false, false, TEXT_ALIGN_CENTER, get(FAILURE_AVIONICS_INLET) == 1 and ECAM_ORANGE or ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-10, 270, "OUTLET", 34, false, false, TEXT_ALIGN_CENTER, get(FAILURE_AVIONICS_OUTLET) == 1 and ECAM_ORANGE or ECAM_WHITE)

    local faulty_blower_or_extract = get(FAILURE_AIRCOND_VENT_BLOWER) == 1 or get(FAILURE_AIRCOND_VENT_EXTRACT) == 1 or get(Fire_cargo_fwd_smoke_detected) == 1
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-115, 330, "VENT", 34, false, false, TEXT_ALIGN_CENTER, faulty_blower_or_extract and ECAM_ORANGE or ECAM_WHITE)

    if get(FAILURE_AIRCOND_VENT_BLOWER) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-240, 330, "BLOWER", 34, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_AIRCOND_VENT_EXTRACT) == 1 or get(Fire_cargo_fwd_smoke_detected) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+20, 330, "EXTRACT", 34, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_ldg_elev()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-100, size[2]-50, "LDG ELEV", 34, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    if get(Press_ldg_elev_knob_pos) >= -2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+80, size[2]-50, "MAN", 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+80, size[2]-50, "AUTO", 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end

    if get(Press_mode_sel_is_man) == 0 then    -- Hide when MODE SEL NOT AUTO
        local selected = get(Press_ldg_elev_knob_pos) >= -2 and get(Press_ldg_elev_knob_pos)*1000 or 0 -- TODO ADD COMPUTED FROM MCDU HERE
        selected = selected - selected%50
        sasl.gl.drawText(Font_AirbusDUL, size[1]-130, size[2]-50, "FT", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]-150, size[2]-50, selected, 34, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end
end

local function draw_sys_on()

    if get(Press_mode_sel_is_man) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+160, 380, "MAN", 34, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end
    if get(Press_sys_in_use) == 1 or get(FAILURE_PRESS_SYS_1) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-100, 450, "SYS 1", 34, false, false, TEXT_ALIGN_CENTER, get(FAILURE_PRESS_SYS_1) == 1 and ECAM_ORANGE or ECAM_GREEN)
    end
    if get(Press_sys_in_use) == 2 or get(FAILURE_PRESS_SYS_2) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+100, 450, "SYS 2", 34, false, false, TEXT_ALIGN_CENTER, get(FAILURE_PRESS_SYS_2) == 1 and ECAM_ORANGE or ECAM_GREEN)
    end
end

local function draw_safety_valve()
    local is_open = get(Press_safety_valve_pos) == 1

    sasl.gl.drawText(Font_AirbusDUL, size[1]-175, size[2]/2-15, "SAFETY", 34, false, false, TEXT_ALIGN_LEFT, is_open and ECAM_ORANGE or ECAM_WHITE)

    local length=58
    if is_open then
        sasl.gl.drawWideLine(size[1]-84, size[2]/2-30, size[1]-84+length, size[2]/2-30, 3, ECAM_ORANGE)
    else
        sasl.gl.drawWideLine(size[1]-89, size[2]/2-36, size[1]-89, size[2]/2-36-length, 3, ECAM_WHITE)
    end
end

local function draw_press_textures_and_needle()
    --delta P
    SASL_rotated_center_img_ycenter_aligned(ECAM_PRESS_needle_img, size[1]/2-272, size[2]/2+190, 84, 4, Math_rescale(-1, -50, 9, 130, params.delta_psi), -84, 0, (params.delta_psi < -0.4 or params.delta_psi > 8.5) and ECAM_ORANGE or ECAM_GREEN)
    --cabin V/S
    SASL_rotated_center_img_ycenter_aligned(ECAM_PRESS_needle_img, size[1]/2+7, size[2]/2+190, 84, 4, Math_rescale_no_lim(-2000, -90, 2000, 90, Math_clamp(params.cabin_vs, -2100, 2100)), -84, 0, ECAM_GREEN)
    --cabin ALT
    SASL_rotated_center_img_ycenter_aligned(ECAM_PRESS_needle_img, size[1]/2+279, size[2]/2+190, 84, 4, Math_rescale_no_lim(0, -50, 10000, 120, Math_clamp(params.cabin_alt, -500, 10500)), -84, 0, params.cabin_alt > 9550 and ECAM_RED or ECAM_GREEN)

    --outflow valve
    SASL_rotated_center_img_xcenter_aligned(ECAM_PRESS_outflow_needle_img, size[1]/2+245, size[2]/2-197, 12, 101, Math_rescale(0, -90, 1, 0, params.overflow_valve), 0, 0, (params.overflow_valve > 0.95 and get(All_on_ground) == 0) and ECAM_ORANGE or ECAM_GREEN)

    --L pack
    SASL_draw_img_xcenter_aligned(ECAM_PRESS_pack_triangle_img, size[1]/2-315, size[2]/2-263, 27, 20, (get(Pack_L) == 0 and get(Engine_1_avail) == 1) and ECAM_ORANGE or ECAM_GREEN)
    --R pack
    SASL_draw_img_xcenter_aligned(ECAM_PRESS_pack_triangle_img, size[1]/2+315, size[2]/2-263, 27, 20, (get(Pack_R) == 0 and get(Engine_2_avail) == 1) and ECAM_ORANGE or ECAM_GREEN)
end

local function draw_the_big_grey_box()
    sasl.gl.drawWideLine(214, 237, 214, 253, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(214, 253, 114, 253, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(114, 253, 114, 499, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(114, 499, 793, 499, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(793, 499, 793, 472, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(793, 420, 804, 420, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(808, 357, 794, 357, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(794, 253, 794, 357, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(794, 253, 701, 253, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(590, 253, 474, 253, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(474, 253, 474, 238, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(411, 243, 411, 253, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(411, 253, 276, 253, 3, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(276, 253, 276, 243, 3, ECAM_LINE_GREY)
end

local function draw_press_bgd()
    draw_the_big_grey_box()
    sasl.gl.drawArc (size[1]/2-272, size[2]/2+190, 74, 77 , 48 , 11 , ECAM_RED)
    sasl.gl.drawArc (size[1]/2-272, size[2]/2+190, 74, 77 , 59 , 167 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2-272, size[2]/2+190, 74, 77 , 220 , 11 , ECAM_RED)

    sasl.gl.drawArc (size[1]/2-272, size[2]/2+190, 65, 75 , 137 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2-272, size[2]/2+190, 65, 75 , 66 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2-272, size[2]/2+190, 65, 75 , 210 , 3 , ECAM_WHITE)

    sasl.gl.drawArc (size[1]/2+7, size[2]/2+190, 74, 77 , 77 , 204 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2+7, size[2]/2+190, 65, 75 , 89 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2+7, size[2]/2+190, 65, 75 , 134 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2+7, size[2]/2+190, 65, 75 , 179 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2+7, size[2]/2+190, 65, 75 , 223 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2+7, size[2]/2+190, 65, 75 , 268 , 3 , ECAM_WHITE)

    sasl.gl.drawArc (size[1]/2+279, size[2]/2+190, 74, 77 , 40 , 19 , ECAM_RED)
    sasl.gl.drawArc (size[1]/2+279, size[2]/2+190, 74, 77 , 59 , 185 , ECAM_WHITE)

    sasl.gl.drawArc (size[1]/2+279, size[2]/2+190, 65, 75 , 137 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2+279, size[2]/2+190, 65, 75 , 66 , 3 , ECAM_WHITE)
    sasl.gl.drawArc (size[1]/2+279, size[2]/2+190, 65, 75 , 210 , 3 , ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 138, 861, "CAB PRESS", 44, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(264, 840, 18, 840, 4, ECAM_WHITE)

    drawTextCentered(Font_ECAMfont, 180, 778, " P", 33, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawEmptyTriangle( 158, 770 , 175, 770, (158+175)/2, 791, 3 ,ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 450, 778, "V/S", 33, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 725, 778, "CAB ALT", 33, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 180, 748, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 450, 748, "FT/MIN", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 725, 748, "FT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    drawTextCentered(Font_ECAMfont, 131, 615, "0", 21, false, false, TEXT_ALIGN_CENTER,  ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 196, 690, "8", 21, false, false, TEXT_ALIGN_CENTER,  ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 456, 587, "2", 21, false, false, TEXT_ALIGN_CENTER,  ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 399, 639, "0", 21, false, false, TEXT_ALIGN_CENTER,  ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 456, 694, "2", 21, false, false, TEXT_ALIGN_CENTER,  ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 695, 600, "0", 21, false, false, TEXT_ALIGN_CENTER,  ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 754, 679, "10", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawArc (695, 253, 101, 104 , 90 , 72 , ECAM_WHITE)
    sasl.gl.drawArc (695, 253, 104, 114 , 112 , 2 , ECAM_WHITE)
    sasl.gl.drawArc (695, 253, 104, 114 , 133 , 2 , ECAM_WHITE)
    sasl.gl.drawArc (695, 253, 104, 114 , 157 , 2 , ECAM_WHITE)

    sasl.gl.drawArc (695, 253, 4, 6 , 0 , 360 , ECAM_WHITE)
    sasl.gl.drawArc (810, 419, 4, 6 , 0 , 360 , ECAM_WHITE)
    sasl.gl.drawArc (411, 238, 4, 6 , 0 , 360 , ECAM_WHITE)
    sasl.gl.drawArc (276, 235, 4, 6 , 0 , 360 , ECAM_WHITE)
end

function draw_press_page()
    draw_press_bgd()
    draw_press_info()
    draw_valves_text()
    draw_valve_inlet(get(Ventilation_avio_inlet_valve), get(FAILURE_AVIONICS_INLET) == 1)
    draw_valve_outlet(get(Ventilation_avio_outlet_valve), get(FAILURE_AVIONICS_OUTLET) == 1)
    draw_safety_valve()

    draw_pack_indications()
    draw_ldg_elev()
    draw_press_textures_and_needle()
    draw_sys_on()
end

local function update_params()
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.delta_psi      = get(Cabin_delta_psi)
        params.cabin_vs       = get(Cabin_vs)
        params.cabin_alt      = get(Cabin_alt_ft)
        params.overflow_valve = get(Out_flow_valve_ratio)
        params.last_update    = get(TIME)
    end
end

function ecam_update_press_page()
    update_params()
end
