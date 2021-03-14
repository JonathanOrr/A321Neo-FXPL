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

    local w,h = sasl.gl.measureText(Font_B612regular, text, size, false, false)

    if align == TEXT_ALIGN_LEFT then
        sasl.gl.drawRectangle(x-2,y-2, w+4, h+3, color)
    elseif align == TEXT_ALIGN_CENTER then
        sasl.gl.drawRectangle(x-w/2-2,y-2, w+4, h+3, color)
    elseif align == TEXT_ALIGN_RIGHT then
        sasl.gl.drawRectangle(x-w-2,y-2, w+4, h+3, color)
    end
    sasl.gl.drawText(Font_B612regular, x, y, text, size, false, false, align, ECAM_BLACK)
    
end

