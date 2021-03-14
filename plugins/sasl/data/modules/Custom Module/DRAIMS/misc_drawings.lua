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
-- File: misc_drawings.lua 
-- Short description: Helper functions for radio-related stuffs
-------------------------------------------------------------------------------

function draw_inverted_text(x, y, text, size, align, color)

    local w,h = sasl.gl.measureText(Font_Roboto, text, size, false, false)

    if align == TEXT_ALIGN_LEFT then
        sasl.gl.drawRectangle(x-2,y-2, w+4, h+3, color)
    elseif align == TEXT_ALIGN_CENTER then
        sasl.gl.drawRectangle(x-w/2-2,y-2, w+4, h+3, color)
    elseif align == TEXT_ALIGN_RIGHT then
        sasl.gl.drawRectangle(x-w-2,y-2, w+4, h+3, color)
    end
    sasl.gl.drawText(Font_Roboto, x, y, text, size, false, false, align, ECAM_BLACK)
    
end

function draw_menu_item_right(line, text, color)

    color = color or ECAM_WHITE
    local x = size[1] - 10
    local y = size[2] - ((line-1) * 100)-46
    sasl.gl.drawText(Font_Roboto, x-29, y-10, text, 25, false, false, TEXT_ALIGN_RIGHT, color)

    sasl.gl.drawConvexPolygon ({x, y, x-12, y+12, x-12, y-12}, true, 0, color)

end

function draw_menu_item_left(line, text, color)

    color = color or ECAM_WHITE
    local x = 10
    local y = size[2] - ((line-1) * 100)-46
    sasl.gl.drawText(Font_Roboto, x+29, y-10, text, 25, false, false, TEXT_ALIGN_LEFT, color)

    sasl.gl.drawConvexPolygon ({x, y, x+12, y-12, x+12, y+12}, true, 0, color)

end
