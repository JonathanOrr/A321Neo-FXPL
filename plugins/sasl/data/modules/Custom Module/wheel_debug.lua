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


include('constants.lua')

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

    sasl.gl.drawText(Font_AirbusDUL, box_convert_coord(get(Steer_ratio_setpoint)), size[2]-35, "SP", 15, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawWideLine (box_convert_coord(get(Steer_ratio_setpoint)), size[2]-38, box_convert_coord(get(Steer_ratio_setpoint)), size[2]-45, 1 , ECAM_BLUE)

    local pos_x_lim = box_convert_coord(get(Nosewheel_Steering_limit))

    sasl.gl.drawWideLine (pos_x_lim, size[2]-70, pos_x_lim, size[2]-70+STEER_BOX_HEIGHT+10, 2 , ECAM_ORANGE)
    sasl.gl.drawWideLine (size[1]-pos_x_lim, size[2]-70, size[1]-pos_x_lim, size[2]-70+STEER_BOX_HEIGHT+10, 2 , ECAM_ORANGE)

end

function computer_status(y)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, y, "Computer Status", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
    sasl.gl.drawText(Font_AirbusDUL, 10, y-25, "LGCIU 1", 14, false, false, TEXT_ALIGN_LEFT, get(Wheel_status_LGCIU_1) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, 100, y-25, "LGCIU 2", 14, false, false, TEXT_ALIGN_LEFT,get(Wheel_status_LGCIU_2) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, 190, y-25, "BSCU 1", 14, false, false, TEXT_ALIGN_LEFT,  get(Wheel_status_BSCU_1) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, 280, y-25, "BSCU 2", 14, false, false, TEXT_ALIGN_LEFT, get(Wheel_status_BSCU_2) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, 370, y-25, "ABCU", 14, false, false, TEXT_ALIGN_LEFT,   get(Wheel_status_ABCU) == 1 and ECAM_GREEN or ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, 450, y-25, "TPIU", 14, false, false, TEXT_ALIGN_LEFT,   get(Wheel_status_TPIU) == 1 and ECAM_GREEN or ECAM_RED)
end

function draw_brakes()
    sasl.gl.drawArc(size[1]/2, size[2]/2 + 20, 30, 32, 60, 60, ECAM_WHITE)
    sasl.gl.drawArc(size[1]/2, size[2]/2 + 20, 30, 32, 240, 60, ECAM_WHITE)

    sasl.gl.drawArc(size[1]/2-150, size[2]/2-20, 30, 32, 60, 60, ECAM_WHITE)
    sasl.gl.drawArc(size[1]/2-150, size[2]/2-20, 30, 32, 240, 60, ECAM_WHITE)

    sasl.gl.drawArc(size[1]/2+150, size[2]/2-20, 30, 32, 60, 60, ECAM_WHITE)
    sasl.gl.drawArc(size[1]/2+150, size[2]/2-20, 30, 32, 240, 60, ECAM_WHITE)
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-10, "Request: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-25, "Braking: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-40, "Skidding: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, size[2]/2-10, Round_fill(get(Joystick_toe_brakes_L), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, size[2]/2-25, Round_fill(get(Wheel_brake_L), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, size[2]/2-40, Round_fill(get(Wheel_skidding_L), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+60, size[2]/2-10, "Request: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+60, size[2]/2-25, "Braking: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+60, size[2]/2-40, "Skidding: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+165, size[2]/2-10, Round_fill(get(Joystick_toe_brakes_R), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+165, size[2]/2-25, Round_fill(get(Wheel_brake_R), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+165, size[2]/2-40, Round_fill(get(Wheel_skidding_R), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-95, size[2]/2+5, "Skidding: ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+15, size[2]/2+5, Round_fill(get(Wheel_skidding_C), 2), 12, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

end

local function draw_accumulator()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+220, size[2]/2+50, "Accum.", 12, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+230, size[2]/2-50, Round_fill(get(Brakes_accumulator), 2), 12, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    Sasl_DrawWideFrame(size[1]/2+220, size[2]/2-30, 20, 70, 1, 1, ECAM_WHITE)
    sasl.gl.drawRectangle (size[1]/2+220, size[2]/2-30, 20, 70 * get(Brakes_accumulator) / 4, get(Brakes_accumulator) > 2 and UI_GREEN or ECAM_ORANGE)    
end

function draw()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]-15, "Steering", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-90, "Steering status: ", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 160, size[2]-90, get(Nosewheel_Steering_working) == 1 and "OK" or "KO", 14, false, false, TEXT_ALIGN_LEFT, get(Nosewheel_Steering_working) == 1 and ECAM_GREEN or ECAM_RED)
    draw_steering_box()

    sasl.gl.drawWideLine ( 10, size[2]-100, size[1]-10, size[2]-100, 1 , ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]-130, "Brakes", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-155, "Brakes mode: ", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 130, size[2]-155, "NORMAL", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 1 and ECAM_BLUE or UI_BRIGHT_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 195, size[2]-155, "ALTN-ANTISKID", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 2 and ECAM_BLUE or UI_BRIGHT_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 320, size[2]-155, "ALTN-WITHOUT", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 3 and ECAM_BLUE or UI_BRIGHT_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 430, size[2]-155, "PARKING", 13, false, false, TEXT_ALIGN_LEFT, get(Brakes_mode) == 4 and ECAM_BLUE or UI_BRIGHT_GREY)

    sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-175, "Anti-skid active: ", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    draw_brakes()
    draw_accumulator()

    computer_status(50)

end
