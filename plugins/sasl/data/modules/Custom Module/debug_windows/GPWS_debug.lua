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
-- Short description: GPWS debug window
-------------------------------------------------------------------------------

size = {500, 500}



include('constants.lua')

local image_plane = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/top-alpha.png", 0, 0, 497, 606)

function draw_mode_1()
    local color_mode     = ECAM_HIGH_GREY
    local color_sinkrate = ECAM_HIGH_GREY
    local color_pullup   = ECAM_HIGH_GREY
    if get(GPWS_mode_is_active, 1) == 1 then
        color_mode = ECAM_WHITE
        color_sinkrate = get(GPWS_mode_1_sinkrate) == 1 and ECAM_ORANGE or  ECAM_HIGH_GREY
        color_pullup   = get(GPWS_mode_1_pullup) == 1   and ECAM_RED or  ECAM_HIGH_GREY        
    end

    sasl.gl.drawRectangle(10, size[2]-90, size[2]/2-20, 100, UI_DARK_GREY)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/4, size[2]-20, "MODE 1", 14, false, false, TEXT_ALIGN_CENTER, color_mode)
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-50, "SINK RATE, SINK RATE", 14, false, false, TEXT_ALIGN_LEFT, color_sinkrate)
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-75, "PULL UP", 14, false, false, TEXT_ALIGN_LEFT, color_pullup)
end

function draw_mode_2()
    sasl.gl.drawRectangle(10, size[2]-250, size[2]/2-20, 150, UI_DARK_GREY)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/4, size[2]-130, "MODE 2", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_is_active, 2) == 1 and ECAM_WHITE or ECAM_HIGH_GREY)


    sasl.gl.drawText(Font_AirbusDUL, size[1]/4+65, size[2]-240, "2A", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_2_mode_a) == 1 and ECAM_GREEN or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/4+80, size[2]-240, "/", 14, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/4+95, size[2]-240, "2B", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_2_mode_b) == 1 and ECAM_GREEN or ECAM_HIGH_GREY)

    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-160, "TERRAIN, TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_mode_2_terrterr) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-185, "PULL UP", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_mode_2_pullup) == 1 and ECAM_RED or ECAM_HIGH_GREY)

    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-210, "TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_mode_2_terr) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)
end

function draw_mode_3()
    sasl.gl.drawRectangle(size[1]/2 + 10, size[2]-65, size[2]/2-20, 75, UI_DARK_GREY)
    
    local color_mode = get(GPWS_mode_is_active, 3) == 1 and ECAM_WHITE or ECAM_HIGH_GREY
    local color_dontsink = get(GPWS_mode_is_active, 3) == 1 and get(GPWS_mode_3_dontsink) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY
    
    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/4, size[2]-20, "MODE 3", 14, false, false, TEXT_ALIGN_CENTER, color_mode)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 +20, size[2]-50, "DON'T SINK, DON'T SINK", 14, false, false, TEXT_ALIGN_LEFT, color_dontsink)
end

function draw_mode_4()
    local color_mode = get(GPWS_mode_is_active, 4) == 1 and ECAM_WHITE or ECAM_HIGH_GREY
    
    sasl.gl.drawRectangle(size[1]/2 + 10, size[2]-185, size[2]/2-20, 110, UI_DARK_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/4, size[2]-95, "MODE 4", 14, false, false, TEXT_ALIGN_CENTER, color_mode)
    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/4-70, size[2]-110, "A", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_4_mode_a) == 1 and ECAM_GREEN or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/4+70, size[2]-110, "B", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_4_mode_b) == 1 and ECAM_GREEN or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/4-40, size[2]-175, "C", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_4_mode_c) == 1 and ECAM_GREEN or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 +20, size[2]-130, "TL TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_mode_4_a_terrain) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 +20, size[2]-150, "TL GEAR", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_mode_4_tl_gear) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 +145, size[2]-130, "TL TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_mode_4_b_terrain) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 +145, size[2]-150, "TL FLAPS", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_mode_4_tl_flaps) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)

    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/4+25, size[2]-175, "TL TERRAIN", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_4_c_terrain) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)

end

function draw_mode_5()
    sasl.gl.drawRectangle(size[1]/2 + 10, size[2]-250, size[2]/2-20, 55, UI_DARK_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/4, size[2]-215, "MODE 5", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_is_active, 5) == 1 and ECAM_WHITE or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2 +20, size[2]-240, "GLIDESLOPE, GLIDESLOPE", 14, get(GPWS_mode_5_glideslope_hard) == 1, false, TEXT_ALIGN_LEFT, get(GPWS_mode_5_glideslope) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)
end

function draw_predictive_output()
    local is_active = get(GPWS_pred_is_active) == 1
    sasl.gl.drawText(Font_AirbusDUL, 20, 180, "Status: ", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 85, 180, is_active and "ACTIVE" or "INACTIVE", 14, false, false, TEXT_ALIGN_LEFT, is_active and ECAM_GREEN or ECAM_HIGH_GREY)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/5, 150, "OUTPUTS", 16, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 20, 120, "TERRAIN AHEAD,", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_pred_terr_pull) == 1 and ECAM_RED or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 20, 100, "PULL UP", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_pred_terr_pull) == 1 and ECAM_RED or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 20, 80, "OBSTACLE AHEAD,", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_pred_obst_pull) == 1 and ECAM_RED or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 20, 60,  "PULL UP", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_pred_obst_pull) == 1 and ECAM_RED or ECAM_HIGH_GREY)

    sasl.gl.drawText(Font_AirbusDUL, 20, 30, "TERRAIN AHEAD", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_pred_terr) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 20, 10, "OBSTACLE AHEAD", 14, false, false, TEXT_ALIGN_LEFT, get(GPWS_pred_obst) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)

end

local function terrain_int_to_color(i)
    if i == 1 then
        return {0.5,0.5,0}
    elseif i == 2 then
        return {1,1,0}
    elseif i == 3 then
        return ECAM_ORANGE
    elseif i == 4 then
        return ECAM_RED
    end
end

function draw_predictive_areas()
    sasl.gl.drawTexture(image_plane, 252, 5, 331/10, 404/10)
    sasl.gl.drawWideLine ( 240, 50, 240, 170, 1, ECAM_HIGH_GREY)
    sasl.gl.drawWideLine ( 300, 50, 300, 170, 1, ECAM_HIGH_GREY)

    local roll = math.max(-30, math.min(30, get(Flightmodel_roll)))
    
    sasl.gl.drawWideLine ( 240, 50, 240+25*math.min(0,roll/30), 170, 1, ECAM_HIGH_GREY)
    sasl.gl.drawWideLine ( 300, 50, 300+25*math.max(0,roll/30), 170, 1, ECAM_HIGH_GREY)

    sasl.gl.drawText(Font_AirbusDUL, 330, 170, "d(60s) = " .. Round_fill(get(GPWS_dist_60),2) .. " nm", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, 330, 90, "d(30s) = " .. Round_fill(get(GPWS_dist_30),2) .. " nm", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    sasl.gl.drawText(Font_AirbusDUL, 330, 30, "d(nearest airport) = ", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 400, 10, Round_fill(get(GPWS_dist_airport), 2) .. " nm", 13, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    
    for i=1,6 do
        if get(GPWS_pred_front, i) > 0 then
            sasl.gl.drawRectangle(260,  150-20*(6-i), 20, 20, terrain_int_to_color(get(GPWS_pred_front, i)))
        end

        if get(GPWS_pred_front_L, i) > 0 then
            sasl.gl.drawRectangle(240,  150-20*(6-i), 20, 20, terrain_int_to_color(get(GPWS_pred_front_L, i)))
        end

        if get(GPWS_pred_front_R, i) > 0 then
            sasl.gl.drawRectangle(280,  150-20*(6-i), 20, 20, terrain_int_to_color(get(GPWS_pred_front_R, i)))
        end
    end
end

function draw_mode_pitch()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 232, "PITCH PITCH", 14, false, false, TEXT_ALIGN_CENTER, get(GPWS_mode_pitch) == 1 and ECAM_ORANGE or ECAM_HIGH_GREY)
end

function draw()

    draw_mode_1()
    draw_mode_2()
    draw_mode_3()
    draw_mode_4()
    draw_mode_5()
    draw_mode_pitch()
    sasl.gl.drawWideLine ( 10, 225, size[1]-10, 225, 1 , ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 200, "Predictive GPWS", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    draw_predictive_output()
    draw_predictive_areas()
end
