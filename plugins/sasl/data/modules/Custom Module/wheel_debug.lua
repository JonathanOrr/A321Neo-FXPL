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

end
