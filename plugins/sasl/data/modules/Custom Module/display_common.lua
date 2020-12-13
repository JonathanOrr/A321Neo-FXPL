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
-- File: display_common.lua
-- Short description: A file containing various functions to manage the display test etc.
-------------------------------------------------------------------------------

local Font_AirbusDUL = sasl.gl.loadFont("fonts/AirbusDULiberationMono.ttf")
sasl.gl.setFontRenderMode(Font_AirbusDUL, TEXT_RENDER_FORCED_MONO, 0.6)

local function draw_invalid(size)
    sasl.gl.drawRectangle(0, 0, size[1], size[2], {0,0,0})
    sasl.gl.drawWideLine(0,0,size[1],size[2],2,{1,1,1})
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2, "INVALID DATA", 40, false, false, TEXT_ALIGN_CENTER, {1, 0.66, 0.16})
end

local function draw_test(size)
    sasl.gl.drawRectangle(0, 2*size[2]/3, size[1]/8, size[2]/3, {1.0, 0.0, 0.0})
    sasl.gl.drawRectangle(size[1]/8, 2*size[2]/3, size[1]/8, size[2]/2, {1, 0.33, 0})
    sasl.gl.drawRectangle(2*size[1]/8, 2*size[2]/3, size[1]/8, size[2]/2, {1, 0.66, 0.16})
    sasl.gl.drawRectangle(3*size[1]/8, 2*size[2]/3, size[1]/8, size[2]/2, {0.20, 0.98, 0.20})
    sasl.gl.drawRectangle(4*size[1]/8, 2*size[2]/3, size[1]/8, size[2]/2, {0.004, 1.0, 1.0})
    sasl.gl.drawRectangle(5*size[1]/8, 2*size[2]/3, size[1]/8, size[2]/2, {0, 0.4, 1.0})
    sasl.gl.drawRectangle(6*size[1]/8, 2*size[2]/3, size[1]/8, size[2]/2, {0.1, 0.6, 1.0})
    sasl.gl.drawRectangle(7*size[1]/8, 2*size[2]/3, size[1]/8, size[2]/2, {1.0, 0.0, 1.0})
    
    sasl.gl.drawRectangle(0, size[2]/3, size[1], size[2]/3, {1,1,1})
    
    sasl.gl.drawRectangle(0, 0, size[1]/8, size[2]/3, {0.1, 0.1, 0.1})
    sasl.gl.drawRectangle(1*size[1]/8, 0, size[1]/8, size[2]/3, {0.2, 0.2, 0.2})
    sasl.gl.drawRectangle(2*size[1]/8, 0, size[1]/8, size[2]/3, {0.3, 0.3, 0.3})
    sasl.gl.drawRectangle(3*size[1]/8, 0, size[1]/8, size[2]/3, {0.4, 0.4, 0.4})
    sasl.gl.drawRectangle(4*size[1]/8, 0, size[1]/8, size[2]/3, {0.5, 0.5, 0.5})
    sasl.gl.drawRectangle(5*size[1]/8, 0, size[1]/8, size[2]/3, {0.6, 0.6, 0.6})
    sasl.gl.drawRectangle(6*size[1]/8, 0, size[1]/8, size[2]/3, {0.8, 0.8, 0.8})
    sasl.gl.drawRectangle(7*size[1]/8, 0, size[1]/8, size[2]/3, {1, 1, 1})
    
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]/2+100, "P/N : C483719090304", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]/2+70, "S/N : C483719090304-2323", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]/2-80, "EIS SW", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]/2-110, "P/N : SXT40DXE254628440023400", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})


    sasl.gl.drawText(Font_AirbusDUL, size[1]-20, size[2]/2+100, "SIDESTICKSIM AVIONICS", 25, false, false, TEXT_ALIGN_RIGHT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, size[1]-20, size[2]/2-110, "LCDU 725", 25, false, false, TEXT_ALIGN_RIGHT,  {0,0,0})
end

local function draw_maintain(size)
    sasl.gl.drawRectangle(0, 0, size[1], size[2], {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2, "MAINTENANCE MODE", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
end

local function draw_wait_for_data(size)
    sasl.gl.drawRectangle(0, 0, size[1], size[2], {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2, "WAITING FOR DATA", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
end

local function draw_self_test(size)
    sasl.gl.drawRectangle(0, 0, size[1], size[2], {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+20, "SELF-TEST IN PROGRESS", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-20, "(MAX 30 SECONDS)", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
end


function display_special_mode(size, dataref)
    if get(dataref) == 0 then
        draw_invalid(size)
        return true
    elseif get(dataref) == 2 then
        draw_test(size)
        return true
    elseif get(dataref) == 3 then
        draw_maintain(size)
        return true
    elseif get(dataref) == 4 then
        draw_wait_for_data(size)
        return true
    elseif get(dataref) == 5 then
        draw_self_test(size)
        return true
    end
    return false
end

