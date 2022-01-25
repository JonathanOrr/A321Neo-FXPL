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
-- File: wheel_debug.lua 
-- Short description: Wheel/Brakes debug window
-------------------------------------------------------------------------------

size = {500, 500}

local STEER_BOX_WIDTH=300
local STEER_BOX_HEIGHT=20



local function box_convert_coord(x)
    return size[1]/2 + (x * STEER_BOX_WIDTH / 2) / 75
end

local function draw_steering_box()
    
    Sasl_DrawWideFrame(size[1]/2-STEER_BOX_WIDTH/2, size[2]-70, STEER_BOX_WIDTH, STEER_BOX_HEIGHT, 1, 1, ECAM_WHITE)

    local pos_x_actual = box_convert_coord(get(Steer_ratio_actual))
    if pos_x_actual > 0 then
        sasl.gl.drawRectangle (size[1]/2, size[2]-70, pos_x_actual-size[1]/2, STEER_BOX_HEIGHT, UI_GREEN)    
    elseif pos_x_actual < 0 then
        sasl.gl.drawRectangle (pos_x_actual, size[2]-70, size[1]/2, STEER_BOX_HEIGHT, UI_GREEN)    
    else
        sasl.gl.drawWideLine (size[1]/2, size[2]-70, size[1]/2, size[2]-70+STEER_BOX_HEIGHT, 1 , UI_GREEN)
    end

    sasl.gl.drawText(Font_ECAMfont, box_convert_coord(get(Steer_ratio_setpoint)), size[2]-35, "SP", 15, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawWideLine (box_convert_coord(get(Steer_ratio_setpoint)), size[2]-38, box_convert_coord(get(Steer_ratio_setpoint)), size[2]-45, 1 , ECAM_BLUE)

    local pos_x_lim = box_convert_coord(get(Nosewheel_Steering_limit))

    sasl.gl.drawWideLine (pos_x_lim, size[2]-70, pos_x_lim, size[2]-70+STEER_BOX_HEIGHT+10, 2 , ECAM_ORANGE)
    sasl.gl.drawWideLine (size[1]-pos_x_lim, size[2]-70, size[1]-pos_x_lim, size[2]-70+STEER_BOX_HEIGHT+10, 2 , ECAM_ORANGE)

end

function computer_status(y)

    sasl.gl.drawText(Font_ECAMfont, size[1]/2, y, "Computer Status", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
    sasl.gl.drawText(Font_ECAMfont, 10, y-25, "LGCIU 1", 14, false, false, TEXT_ALIGN_LEFT, get(Wheel_status_LGCIU_1) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 100, y-25, "LGCIU 2", 14, false, false, TEXT_ALIGN_LEFT,get(Wheel_status_LGCIU_2) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 190, y-25, "BSCU 1", 14, false, false, TEXT_ALIGN_LEFT,  get(Wheel_status_BSCU_1) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 280, y-25, "BSCU 2", 14, false, false, TEXT_ALIGN_LEFT, get(Wheel_status_BSCU_2) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 370, y-25, "ABCU", 14, false, false, TEXT_ALIGN_LEFT,   get(Wheel_status_ABCU) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 450, y-25, "TPIU", 14, false, false, TEXT_ALIGN_LEFT,   get(Wheel_status_TPIU) == 1 and ECAM_GREEN or ECAM_RED)
end

function draw_brakes()
    sasl.gl.drawArc(size[1]/2, size[2]/2 + 20, 30, 32, 60, 60, ECAM_WHITE)
    sasl.gl.drawArc(size[1]/2, size[2]/2 + 20, 30, 32, 240, 60, ECAM_WHITE)

    sasl.gl.drawArc(size[1]/2-150, size[2]/2-20, 30, 32, 60, 60, ECAM_WHITE)
    sasl.gl.drawArc(size[1]/2-150, size[2]/2-20, 30, 32, 240, 60, ECAM_WHITE)

    sasl.gl.drawArc(size[1]/2+150, size[2]/2-20, 30, 32, 60, 60, ECAM_WHITE)
    sasl.gl.drawArc(size[1]/2+150, size[2]/2-20, 30, 32, 240, 60, ECAM_WHITE)
    
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-250, size[2]/2-10, "Request: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-250, size[2]/2-25, "Braking: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-250, size[2]/2-40, "Skidding: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-135, size[2]/2-10, Round_fill(get(Joystick_toe_brakes_L), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-135, size[2]/2-25, Round_fill(get(Wheel_brake_L), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-135, size[2]/2-40, Round_fill(get(Wheel_skidding_L), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    
    
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+60, size[2]/2-10, "Request: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+60, size[2]/2-25, "Braking: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+60, size[2]/2-40, "Skidding: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+165, size[2]/2-10, Round_fill(get(Joystick_toe_brakes_R), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+165, size[2]/2-25, Round_fill(get(Wheel_brake_R), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+165, size[2]/2-40, Round_fill(get(Wheel_skidding_R), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_ECAMfont, size[1]/2-95, size[2]/2+5, "Skidding: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+15, size[2]/2+5, Round_fill(get(Wheel_skidding_C), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

end

local function draw_accumulator()
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+220, size[2]/2+50, "Accum.", 12, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+230, size[2]/2-50, Round_fill(get(Brakes_accumulator), 2), 12, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    Sasl_DrawWideFrame(size[1]/2+220, size[2]/2-30, 20, 70, 1, 1, ECAM_WHITE)
    sasl.gl.drawRectangle (size[1]/2+220, size[2]/2-30, 20, 70 * get(Brakes_accumulator) / 4, get(Brakes_accumulator) > 2 and UI_GREEN or ECAM_ORANGE)    
end

local prev_speed = 0
local curr_decel = 0
local function update_deleceration()
    if get(DELTA_TIME) == 0 then
        return
    end
    curr_decel = (prev_speed - get(Ground_speed_ms)) / get(DELTA_TIME)
    prev_speed = get(Ground_speed_ms)
end


local function draw_autobrakes()

    update_deleceration()

    local status_mode = "OK"
    if get(SEC_1_status) + get(SEC_2_status) < 2 then
        status_mode = "SEC FAIL"
    end
    
    if get(FAILURE_GEAR_AUTOBRAKES) == 1 then
        status_mode = "AUTOBRK FAIL"
    end
    
    if get(Brakes_mode) > 1 then
        status_mode = "BRK MODE INH."
    end

    sasl.gl.drawText(Font_ECAMfont, size[1]/2, size[2]-330, "Auto-Brakes", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-250, size[2]-350, "Mode: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    local status_txt = get(Wheel_autobrake_status) == 0 and "OFF" or (get(Wheel_autobrake_status) == 1 and "LO" or (get(Wheel_autobrake_status) == 2 and "MED" or "MAX"))
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-195, size[2]-350, status_txt, 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-250, size[2]-370, "Failed? ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-195, size[2]-370, get(FAILURE_GEAR_AUTOBRAKES) == 1 and "YES" or "NO", 12, false, false, TEXT_ALIGN_LEFT, get(FAILURE_GEAR_AUTOBRAKES) == 1  and ECAM_RED or ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-250, size[2]-390, "Status: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-195, size[2]-390, status_mode, 12, false, false, TEXT_ALIGN_LEFT, status_mode == "OK" and ECAM_GREEN or ECAM_ORANGE)

    local target_decel = get(Wheel_autobrake_status) == 0 and "0.0" or (get(Wheel_autobrake_status) == 1 and "1.7" or (get(Wheel_autobrake_status) == 2 and "3.0" or "MAX"))
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-90, size[2]-350, "Target DECEL: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+10, size[2]-350, target_decel, 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    sasl.gl.drawText(Font_ECAMfont, size[1]/2-90, size[2]-380, "Actual DECEL: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+170, size[2]-380, Round_fill(curr_decel,2), 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    Sasl_DrawWideFrame(size[1]/2+10, size[2]-385, 150, 20, 1, 1, ECAM_WHITE)
    sasl.gl.drawRectangle(size[1]/2+10, size[2]-385, Math_clamp(150 * curr_decel/5, 0,150), 20, ECAM_BLUE)
    local pos_indicator_target = get(Wheel_autobrake_status) == 1 and 1.7 or (get(Wheel_autobrake_status) == 2 and 3 or 0)
    if pos_indicator_target > 0 then
        sasl.gl.drawWideLine (size[1]/2+10+150*pos_indicator_target/5, size[2]-390, size[1]/2+10+150*pos_indicator_target/5, size[2]-360, 2 , ECAM_GREEN)
    end


    sasl.gl.drawText(Font_ECAMfont, size[1]/2-90, size[2]-410, "Braking req.: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+170, size[2]-410, Round_fill(get(Wheel_autobrake_braking),2), 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    Sasl_DrawWideFrame(size[1]/2+10, size[2]-415, 150, 20, 1, 1, ECAM_WHITE)
    sasl.gl.drawRectangle(size[1]/2+10, size[2]-415, 150 * get(Wheel_autobrake_braking), 20, ECAM_BLUE)
end
function draw()
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, size[2]-15, "Steering", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, 10, size[2]-90, "Steering status: ", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, 160, size[2]-90, get(Nosewheel_Steering_working) == 1 and "OK" or "KO", 14, false, false, TEXT_ALIGN_LEFT, get(Nosewheel_Steering_working) == 1 and ECAM_GREEN or ECAM_RED)
    draw_steering_box()

    sasl.gl.drawWideLine ( 10, size[2]-100, size[1]-10, size[2]-100, 1 , ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, size[2]-130, "Brakes", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_ECAMfont, 10, size[2]-155, "Brakes mode: ", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, 130, size[2]-155, "NORMAL", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 1 and ECAM_BLUE or UI_BRIGHT_GREY)
    sasl.gl.drawText(Font_ECAMfont, 195, size[2]-155, "ALTN-ANTISKID", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 2 and ECAM_BLUE or UI_BRIGHT_GREY)
    sasl.gl.drawText(Font_ECAMfont, 320, size[2]-155, "ALTN-WITHOUT", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 3 and ECAM_BLUE or UI_BRIGHT_GREY)
    sasl.gl.drawText(Font_ECAMfont, 430, size[2]-155, "PARKING", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 4 and ECAM_BLUE or UI_BRIGHT_GREY)

    sasl.gl.drawText(Font_ECAMfont, 10, size[2]-175, "Anti-skid active: ", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    draw_brakes()
    draw_accumulator()

    draw_autobrakes()

    computer_status(50)

end
