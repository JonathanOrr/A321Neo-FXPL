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


local THIS_PAGE = MCDU_Page:new({id=1000})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "ATSU DATALINK")

    self:set_line(mcdu_data, MCDU_LEFT, 1, "<ATC MENU", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "AOC MENU>", MCDU_LARGE, ECAM_WHITE)
end

function THIS_PAGE:L1(mcdu_data)
    mcdu_open_page(mcdu_data, 1001)
end

function THIS_PAGE:R1(mcdu_data)
    mcdu_open_page(mcdu_data, 1050)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
