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
    sasl.gl.drawWideLine(140, 100, 140, 0, 4, ECAM_WHITE)

    if is_right_complete then
        sasl.gl.drawWideLine(320, 100, 320, 0, 4, ECAM_WHITE)
        sasl.gl.drawWideLine(420, 100, 420, 0, 4, ECAM_WHITE)
    end
end

local function draw_top_lines()
    sasl.gl.drawWideLine(0, 200, size[1], 200, 4, ECAM_WHITE)
    sasl.gl.drawWideLine(0, 300, size[1], 300, 4, ECAM_WHITE)
end

function draw_page_static(data)

    if data.current_page ~= PAGE_MENU then
        draw_line_bottom_area(data.current_page ~= PAGE_NAV)
    end

    if data.current_page ~= PAGE_MENU and data.current_page ~= PAGE_NAV then
        draw_top_lines()
    end
end
