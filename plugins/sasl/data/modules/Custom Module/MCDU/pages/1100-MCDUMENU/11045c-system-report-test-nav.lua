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


local THIS_PAGE = MCDU_Page:new({id="11045c"})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "NAV")

    self:set_line(mcdu_data, MCDU_LEFT, 1, "<ADIRS1", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "<ADIRS2", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "<ADIRS3", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "MIX>", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "GPIRS>", MCDU_LARGE, ECAM_WHITE)

end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 11045)
end

function THIS_PAGE:R1(mcdu_data)
    mcdu_open_page(mcdu_data, "11045c7")
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
