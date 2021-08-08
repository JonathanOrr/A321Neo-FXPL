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
-- File: ECAM_wheel.lua 
-- Short description: ECAM file for the WHEEL page 
-------------------------------------------------------------------------------



--colors
local ll_brake_temp_color = {1.0, 1.0, 1.0}
local l_brake_temp_color = {1.0, 1.0, 1.0}
local r_brake_temp_color = {1.0, 1.0, 1.0}
local rr_brake_temp_color = {1.0, 1.0, 1.0}
local ll_tire_psi_color = {1.0, 1.0, 1.0}
local l_tire_psi_color = {1.0, 1.0, 1.0}
local r_tire_psi_color = {1.0, 1.0, 1.0}
local rr_tire_psi_color = {1.0, 1.0, 1.0}
local nl_tire_psi_color = {1.0, 1.0, 1.0}
local nr_tire_psi_color = {1.0, 1.0, 1.0}

local left_bleed_color = ECAM_ORANGE
local right_bleed_color = ECAM_ORANGE
local left_eng_avail_cl = ECAM_ORANGE
local right_eng_avail_cl = ECAM_ORANGE


local function draw_brakes_and_tires()
    --brakes temps--
    local LL_temp = math.floor(get(LL_brakes_temp)) - math.floor(get(LL_brakes_temp)) % 5
    local L_temp  = math.floor(get(L_brakes_temp)) - math.floor(get(L_brakes_temp)) % 5
    local R_temp  = math.floor(get(R_brakes_temp)) - math.floor(get(R_brakes_temp)) % 5
    local RR_temp = math.floor(get(RR_brakes_temp)) - math.floor(get(RR_brakes_temp)) % 5

   
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360+26, size[2]/2-75, LL_temp, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200+26, size[2]/2-75, L_temp,  30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200+26, size[2]/2-75, R_temp,  30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360+26, size[2]/2-75, RR_temp, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    
    --tire press
    if get(Wheel_status_TPIU) == 1 then
        local LL_psi = math.floor(get(LL_tire_psi)) - math.floor(get(LL_tire_psi)) % 5
        local L_psi  = math.floor(get(L_tire_psi)) - math.floor(get(L_tire_psi)) % 5
        local R_psi  = math.floor(get(R_tire_psi)) - math.floor(get(R_tire_psi)) % 5
        local RR_psi = math.floor(get(RR_tire_psi)) - math.floor(get(RR_tire_psi)) % 5

        local NL_psi  = math.floor(get(NL_tire_psi)) - math.floor(get(NL_tire_psi)) % 5
        local NR_psi = math.floor(get(NR_tire_psi)) - math.floor(get(NR_tire_psi)) % 5

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360+26, size[2]/2-165, LL_psi, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200+26, size[2]/2-165, L_psi, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200+26, size[2]/2-165, R_psi, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360+26, size[2]/2-165, RR_psi, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+80+26, size[2]/2+175, NL_psi, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-80+26, size[2]/2+175, NR_psi, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-165, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200, size[2]/2-165, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-165, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360, size[2]/2-165, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
        
    --brakes indications
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-280, size[2]/2-75, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-280, size[2]/2-120, "REL", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-280, size[2]/2-165, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+280, size[2]/2-75, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+280, size[2]/2-120, "REL", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+280, size[2]/2-165, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-120, "1", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200, size[2]/2-120, "2", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-120, "3", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360, size[2]/2-120, "4", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+175, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)


    --upper arcs
    if LL_temp > L_temp and LL_temp > R_temp and LL_temp > RR_temp and ll_brake_temp_color ~= ECAM_ORANGE then
        ll_brake_temp_color = ECAM_GREEN
    end
    if L_temp > LL_temp and L_temp > R_temp and L_temp > RR_temp and l_brake_temp_color ~= ECAM_ORANGE then
        l_brake_temp_color = ECAM_GREEN
    end
    if R_temp > LL_temp and R_temp > L_temp and R_temp > RR_temp and r_brake_temp_color ~= ECAM_ORANGE then
        r_brake_temp_color = ECAM_GREEN
    end
    if RR_temp > LL_temp and RR_temp > R_temp and RR_temp >L_temp and rr_brake_temp_color ~= ECAM_ORANGE then
        rr_brake_temp_color = ECAM_GREEN
    end


    sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 60, 60, ll_brake_temp_color)
    sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 60, 60, l_brake_temp_color)
    sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 60, 60, r_brake_temp_color)
    sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 60, 60, rr_brake_temp_color)
    
    --lower arcs
    if get(Wheel_status_TPIU) == 1 then
        
        sasl.gl.drawArc(size[1]/2 - 75, size[2]/2 + 230, 76, 80, 240, 60, nl_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 75, size[2]/2 + 230, 76, 80, 240, 60, nr_tire_psi_color)
    
        sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 240, 60, ll_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 240, 60, l_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 240, 60, r_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 240, 60, rr_tire_psi_color)
    end
end

local function draw_nsw_steering()
    -- TODO Fix behavior switch NS Steer
    if get(Nosewheel_Steering_working) == 0 then
        local is_Y_ok = get(Hydraulic_Y_press) >= 1450
        local color = is_Y_ok and ECAM_GREEN or ECAM_ORANGE
        sasl.gl.drawTexture(ECAM_WHEEL_hyd_boxes_img, size[1]/2-152, size[2]/2+96, 25, 29, {1, 1, 1})
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-140, size[2]/2+100, "Y", 30, false, false, TEXT_ALIGN_CENTER, color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+100, "N/W STEERING", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_brake_modes()

    if get(Brakes_mode) == 3 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-50, size[2]/2+30, "ANTI SKID", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        if get(FAILURE_GEAR_BSCU1) == 1 then
            sasl.gl.drawTexture(ECAM_WHEEL_hyd_boxes_img, size[1]/2+65, size[2]/2+26, 25, 29, {1, 1, 1})
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+79, size[2]/2+30, "1", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end
        if get(FAILURE_GEAR_BSCU2) == 1 then
            sasl.gl.drawTexture(ECAM_WHEEL_hyd_boxes_img, size[1]/2+100, size[2]/2+26, 25, 29, {1, 1, 1})
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+113, size[2]/2+30, "2", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end
    end

    local altn_brk_display_cond = get(Wheel_status_ABCU) == 0 or get(Hydraulic_Y_press) <= 1450

    if (get(Brakes_mode) == 2 or get(Brakes_mode) == 3) or get(FAILURE_GEAR_AUTOBRAKES) == 1 or (get(Wheel_status_BSCU_1) == 0 and get(Wheel_status_BSCU_2) == 0) or altn_brk_display_cond then
        local hyd_color = get(Hydraulic_G_press) >= 1450 and ECAM_GREEN or ECAM_ORANGE
        local norm_brake_color = get(Brakes_mode) == 1 and ECAM_GREEN or ECAM_ORANGE
        sasl.gl.drawTexture(ECAM_WHEEL_hyd_boxes_img, size[1]/2-124, size[2]/2-34, 25, 29, {1, 1, 1})
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-111, size[2]/2-29, "G", 30, false, false, TEXT_ALIGN_CENTER, hyd_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-30, "NORM BRK", 36, false, false, TEXT_ALIGN_CENTER, norm_brake_color)
    end

    if altn_brk_display_cond or get(Brakes_mode) == 2 or get(Brakes_mode) == 3 or get(FAILURE_GEAR_AUTOBRAKES) == 1 then
        local hyd_color = get(Hydraulic_Y_press) >= 1450 and ECAM_GREEN or ECAM_ORANGE
        local altn_brake_color = altn_brk_display_cond and ECAM_ORANGE or ECAM_GREEN
        sasl.gl.drawTexture(ECAM_WHEEL_hyd_boxes_img, size[1]/2-124, size[2]/2-103, 25, 29, {1, 1, 1})
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-111, size[2]/2-98, "Y", 30, false, false, TEXT_ALIGN_CENTER, hyd_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-100, "ALTN BRK", 36, false, false, TEXT_ALIGN_CENTER, altn_brake_color)

        if get(Hydraulic_Y_press) >= 1450 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+12, size[2]/2-140, "ACCU PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            sasl.gl.drawWideLine(size[1]/2-110, size[2]/2-103, size[1]/2-110, size[2]/2-130, 2, ECAM_GREEN)
            sasl.gl.drawWideLine(size[1]/2-110, size[2]/2-130, size[1]/2-100, size[2]/2-130, 2, ECAM_GREEN)
            sasl.gl.drawWidePolyLine( {size[1]/2-100, size[2]/2-120, size[1]/2-100, size[2]/2-140, size[1]/2-90, size[2]/2-130, size[1]/2-100, size[2]/2-120 }, 2, ECAM_GREEN)
        elseif get(Brakes_accumulator) > 0.5 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+30, size[2]/2-140, "ACCU ONLY", 32, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            sasl.gl.drawWideLine(size[1]/2-60, size[2]/2-130, size[1]/2-75, size[2]/2-130, 2, ECAM_GREEN)
            sasl.gl.drawWideLine(size[1]/2-75, size[2]/2-130, size[1]/2-75, size[2]/2-120, 2, ECAM_GREEN)
            sasl.gl.drawWidePolyLine( {size[1]/2-67, size[2]/2-120, size[1]/2-83, size[2]/2-120, size[1]/2-75, size[2]/2-108, size[1]/2-67, size[2]/2-120 }, 2, ECAM_GREEN)
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+12, size[2]/2-140, "ACCU PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end

    end


    if get(FAILURE_GEAR_AUTOBRAKES) == 1 or get(Brakes_mode) > 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-220, "AUTO BRK", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    elseif get(Wheel_autobrake_status) ~= 0 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-220, "AUTO BRK", 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)        
        local text = get(Wheel_autobrake_status) == 1 and "LO" or (get(Wheel_autobrake_status) == 2 and "MED" or "MAX")
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-260, text, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

end

local function draw_single_release_indicator(x)
    sasl.gl.drawWideLine(size[1]/2+x, size[2]/2-105, size[1]/2+x+20, size[2]/2-105, 2, ECAM_GREEN)
    sasl.gl.drawWideLine(size[1]/2+x, size[2]/2-112, size[1]/2+x+20, size[2]/2-112, 2, ECAM_GREEN)
    sasl.gl.drawWideLine(size[1]/2+x, size[2]/2-119, size[1]/2+x+20, size[2]/2-119, 2, ECAM_GREEN)
end

local function draw_release_indicators()

    if get(Ecam_wheel_release_L) == 1 then
        draw_single_release_indicator(-391)
        draw_single_release_indicator(-351)
        draw_single_release_indicator(-231)
        draw_single_release_indicator(-191)
    end
    
    if get(Ecam_wheel_release_R) == 1 then
        draw_single_release_indicator(371)
        draw_single_release_indicator(331)
        draw_single_release_indicator(211)
        draw_single_release_indicator(171)
    end
end

local function draw_wheel_page_spoilers()
    --track indication--
    local num_of_spoilers = 5
    local spoiler_track_length = 22

    local l_spoilers_avail = {
        FBW.fctl.surfaces.splr.L[1].controlled,
        FBW.fctl.surfaces.splr.L[2].controlled,
        FBW.fctl.surfaces.splr.L[3].controlled,
        FBW.fctl.surfaces.splr.L[4].controlled,
        FBW.fctl.surfaces.splr.L[5].controlled,
    }
    local r_spoilers_avail = {
        FBW.fctl.surfaces.splr.R[1].controlled,
        FBW.fctl.surfaces.splr.R[2].controlled,
        FBW.fctl.surfaces.splr.R[3].controlled,
        FBW.fctl.surfaces.splr.R[4].controlled,
        FBW.fctl.surfaces.splr.R[5].controlled,
    }
    local l_spoilers_data_avail = {
        FBW.fctl.surfaces.splr.L[1].data_avail,
        FBW.fctl.surfaces.splr.L[2].data_avail,
        FBW.fctl.surfaces.splr.L[3].data_avail,
        FBW.fctl.surfaces.splr.L[4].data_avail,
        FBW.fctl.surfaces.splr.L[5].data_avail,
    }
    local r_spoilers_data_avail = {
        FBW.fctl.surfaces.splr.R[1].data_avail,
        FBW.fctl.surfaces.splr.R[2].data_avail,
        FBW.fctl.surfaces.splr.R[3].data_avail,
        FBW.fctl.surfaces.splr.R[4].data_avail,
        FBW.fctl.surfaces.splr.R[5].data_avail,
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
        {44,  819},
        {100, 810},
        {156, 801},
        {212, 791},
        {269, 782},
    }

    local spoiler_arrow_x_y = {
        {55, 819},
        {111, 810},
        {167, 801},
        {223, 791},
        {280, 782},
    }

    local spoiler_num_x_y = {
        {54,  824},
        {111, 815},
        {167, 806},
        {223, 796},
        {280, 787},
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
end

local function draw_gears_and_gear_doors()
    if get(Front_gear_deployment) > 0.1 then
        SASL_draw_img_xcenter_aligned(ECAM_WHEEL_gears_img, size[1]/2, size[2]/2+210, 77, 49, get(Front_gear_deployment) >= 0.95 and ECAM_GREEN or ECAM_RED)
    end
    if get(Left_gear_deployment) > 0.1 then
        SASL_draw_img_xcenter_aligned(ECAM_WHEEL_gears_img, size[1]/2-285, size[2]/2+60, 77, 49, get(Left_gear_deployment) >= 0.95 and ECAM_GREEN or ECAM_RED)
    end
    if get(Right_gear_deployment) > 0.1 then
        SASL_draw_img_xcenter_aligned(ECAM_WHEEL_gears_img, size[1]/2+285, size[2]/2+60, 77, 49, get(Right_gear_deployment) >= 0.95 and ECAM_GREEN or ECAM_RED)
    end

    SASL_drawSegmentedImg(ECAM_WHEEL_l_nose_gear_door_img, size[1]/2-83, size[2]/2+200, 130, 70, 2, (get(Front_gear_deployment) < 0.05 or get(Front_gear_deployment) >= 0.95) and 2 or 1)
    SASL_drawSegmentedImg(ECAM_WHEEL_r_nose_gear_door_img, size[1]/2+18, size[2]/2+200, 130, 70, 2, (get(Front_gear_deployment) < 0.05 or get(Front_gear_deployment) >= 0.95) and 1 or 2)

    local l_gear_door_anim_table = {
        {0, 3},
        {0.25, 1},
        {0.8, 2},
        {1, 3},
    }
    local r_gear_door_anim_table = {
        {0, 3},
        {0.25, 1},
        {0.8, 2},
        {1, 3},
    }

    SASL_drawSegmentedImg(ECAM_WHEEL_l_main_gear_door_img, size[1]/2-359, size[2]/2-37, 480, 159, 3, Table_interpolate(l_gear_door_anim_table, get(Left_gear_deployment)))
    SASL_drawSegmentedImg(ECAM_WHEEL_r_main_gear_door_img, size[1]/2+199, size[2]/2-37, 480, 159, 3, Table_interpolate(r_gear_door_anim_table, get(Right_gear_deployment)))
end

local function draw_wheel_bgd()
    sasl.gl.drawWideLine(49, 900-333, 77, 900-333, 4,ECAM_WHITE)
    sasl.gl.drawWideLine(250, 900-333, 278, 900-333, 4,ECAM_WHITE)
    sasl.gl.drawWideLine(338, 900-185, 365, 900-185, 4,ECAM_WHITE)

    sasl.gl.drawWideLine(900-49, 900-333, 900-77, 900-333, 4,ECAM_WHITE)
    sasl.gl.drawWideLine(900-250, 900-333, 900-278, 900-333, 4,ECAM_WHITE)
    sasl.gl.drawWideLine(900-338, 900-185, 900-365, 900-185, 4,ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 89, 900-172, "WHEEL", 44, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(22, 900-191, 158, 900-191, 4, ECAM_WHITE)
end

function draw_wheel_page()
    draw_wheel_bgd()
    draw_gears_and_gear_doors()
    draw_wheel_page_spoilers()
    draw_brakes_and_tires()
    draw_release_indicators()
    draw_nsw_steering()
    draw_brake_modes()
end

function ecam_update_wheel_page()


    --wheels indications--
    ll_brake_temp_color = get(LL_brakes_temp) > 300 and ECAM_ORANGE or ECAM_WHITE
    l_brake_temp_color  = get(L_brakes_temp)  > 300 and ECAM_ORANGE or ECAM_WHITE
    r_brake_temp_color  = get(R_brakes_temp)  > 300 and ECAM_ORANGE or ECAM_WHITE
    rr_brake_temp_color = get(RR_brakes_temp) > 300 and ECAM_ORANGE or ECAM_WHITE

    ll_tire_psi_color = (get(LL_tire_psi) > 240 or get(LL_tire_psi) < 180) and ECAM_ORANGE or ECAM_WHITE
    l_tire_psi_color  = (get(L_tire_psi) > 240  or get(L_tire_psi) < 180) and ECAM_ORANGE or ECAM_WHITE
    r_tire_psi_color  = (get(R_tire_psi) > 240  or get(R_tire_psi) < 180) and ECAM_ORANGE or ECAM_WHITE
    rr_tire_psi_color = (get(RR_tire_psi) > 240 or get(RR_tire_psi) < 180) and ECAM_ORANGE or ECAM_WHITE

    nl_tire_psi_color = (get(NL_tire_psi) > 210 or get(NL_tire_psi) < 160) and ECAM_ORANGE or ECAM_WHITE
    nr_tire_psi_color = (get(NR_tire_psi) > 210 or get(NR_tire_psi) < 160) and ECAM_ORANGE or ECAM_WHITE


end

