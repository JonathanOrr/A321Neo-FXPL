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
-- File: pages.lua 
-- Short description: Draw pages background and fixed elements
-------------------------------------------------------------------------------

size = {600, 400}

local function draw_line_bottom_area(is_right_complete)
    sasl.gl.drawWideLine(0, 100, size[1], 100, 4, ECAM_WHITE)
    sasl.gl.drawWideLine(150, 100, 150, 0, 4, ECAM_WHITE)
    
    
    if is_right_complete then
    
    end
end

function draw_page_static()

    draw_line_bottom_area(true)

end
