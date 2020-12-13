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
    sasl.gl.drawText(Font_AirbusDUL, size[1]/5, 180, "OUTPUTS", 16, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 20, 150, "TERRAIN, TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, 20, 130, "PULL UP", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, 20, 110, "AVOID TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)

    sasl.gl.drawText(Font_AirbusDUL, 20, 80, "CAUTION TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, 20, 60, "TOO LOW TERRAIN", 14, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)

end

function draw()

    draw_mode_1()
    draw_mode_2()
    draw_mode_3()
    draw_mode_4()
    draw_mode_5()
    
    sasl.gl.drawWideLine ( 10, 230, size[1]-10, 230, 1 , ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 200, "Predictive GPWS", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    draw_predictive_output()
end
