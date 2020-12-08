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

include('constants.lua')


--colors
local left_brake_temp_color = {1.0, 1.0, 1.0}
local right_brake_temp_color = {1.0, 1.0, 1.0}
local left_tire_psi_color = {1.0, 1.0, 1.0}
local right_tire_psi_color = {1.0, 1.0, 1.0}

local left_bleed_color = ECAM_ORANGE
local right_bleed_color = ECAM_ORANGE
local left_eng_avail_cl = ECAM_ORANGE
local right_eng_avail_cl = ECAM_ORANGE


local function draw_brakes_and_tires()
    --brakes temps--
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-75, math.floor(get(Left_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200, size[2]/2-75, math.floor(get(Left_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-75, math.floor(get(Right_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360, size[2]/2-75, math.floor(get(Right_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    
    --tire press
    if get(Wheel_status_TPIU) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-165, math.floor(get(Left_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200, size[2]/2-165, math.floor(get(Left_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-165, math.floor(get(Right_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360, size[2]/2-165, math.floor(get(Right_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+80, size[2]/2+175, math.floor(get(Nose_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-80, size[2]/2+175, math.floor(get(Nose_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

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
    sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 60, 60, left_brake_temp_color)
    sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 60, 60, left_brake_temp_color)
    sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 60, 60, right_brake_temp_color)
    sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 60, 60, right_brake_temp_color)
    
    --lower arcs
    if get(Wheel_status_TPIU) == 1 then
        sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 240, 60, left_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 240, 60, left_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 240, 60, right_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 240, 60, right_tire_psi_color)
    end
end

local function draw_nsw_steering()
    -- TODO Fix behavior switch NS Steer
    if get(Nosewheel_Steering_working) == 0 then
        local is_Y_ok = get(Hydraulic_Y_press) >= 1450
        local color = is_Y_ok and ECAM_GREEN or ECAM_ORANGE
        Sasl_DrawWideFrame(size[1]/2-152, size[2]/2+96, 25, 29, 2, 0, color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-140, size[2]/2+100, "Y", 32, false, false, TEXT_ALIGN_CENTER, color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+100, "N/W STEERING", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_brake_modes()

    if get(Brakes_mode) == 3 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-50, size[2]/2+30, "ANTI SKID", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        if get(FAILURE_GEAR_BSCU1) == 1 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+80, size[2]/2+30, "1", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
            Sasl_DrawWideFrame(size[1]/2+65, size[2]/2+26, 28, 31, 2, 0, ECAM_ORANGE)
        end
        if get(FAILURE_GEAR_BSCU2) == 1 then        
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+115, size[2]/2+30, "2", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
            Sasl_DrawWideFrame(size[1]/2+100, size[2]/2+26, 28, 31, 2, 0, ECAM_ORANGE)
        end
    end

    local altn_brk_display_cond = get(Wheel_status_ABCU) == 0 or get(Hydraulic_Y_press) <= 1450

    if (get(Brakes_mode) == 2 or get(Brakes_mode) == 3) or get(FAILURE_GEAR_AUTOBRAKES) == 1 or (get(Wheel_status_BSCU_1) == 0 and get(Wheel_status_BSCU_2) == 0) or altn_brk_display_cond then
        local hyd_color = get(Hydraulic_G_press) >= 1450 and ECAM_GREEN or ECAM_ORANGE
        local norm_brake_color = get(Brakes_mode) == 1 and ECAM_GREEN or ECAM_ORANGE
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-110, size[2]/2-30, "G", 36, false, false, TEXT_ALIGN_CENTER, hyd_color)
        Sasl_DrawWideFrame(size[1]/2-124, size[2]/2-34, 28, 31, 2, 0, hyd_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-30, "NORM BRK", 36, false, false, TEXT_ALIGN_CENTER, norm_brake_color)
    end
    
    if altn_brk_display_cond or get(Brakes_mode) == 2 or get(Brakes_mode) == 3 or get(FAILURE_GEAR_AUTOBRAKES) == 1 then
        local hyd_color = get(Hydraulic_Y_press) >= 1450 and ECAM_GREEN or ECAM_ORANGE
        local altn_brake_color = altn_brk_display_cond and ECAM_ORANGE or ECAM_GREEN 
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-110, size[2]/2-100, "Y", 36, false, false, TEXT_ALIGN_CENTER, hyd_color)
        Sasl_DrawWideFrame(size[1]/2-124, size[2]/2-103, 28, 31, 2, 0, hyd_color)
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

function draw_wheel_page()
    draw_brakes_and_tires()
    draw_release_indicators()
    draw_nsw_steering()
    draw_brake_modes()
end


function ecam_update_wheel_page()


    --wheels indications--
    if get(Left_brakes_temp) > 400 then
		left_brake_temp_color = ECAM_ORANGE
	else
		left_brake_temp_color = ECAM_WHITE
	end

	if get(Right_brakes_temp) > 400 then
		right_brake_temp_color = ECAM_ORANGE
	else
		right_brake_temp_color = ECAM_WHITE
	end

	if get(Left_tire_psi) > 280 then
		left_tire_psi_color = ECAM_ORANGE
	else
		left_tire_psi_color = ECAM_WHITE
	end

	if get(Right_tire_psi) > 280 then
		right_tire_psi_color = ECAM_ORANGE
	else
		right_tire_psi_color = ECAM_WHITE
	end
	
end

