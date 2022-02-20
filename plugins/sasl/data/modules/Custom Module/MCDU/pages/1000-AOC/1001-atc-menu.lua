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


local THIS_PAGE = MCDU_Page:new({id=1001})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "ATC MENU")

    self:set_line(mcdu_data, MCDU_LEFT, 1, "<LAT REQ", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "<WHEN CAN WE", MCDU_LARGE, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_LEFT, 4, "<MSG RECORD", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "<NOTIFICATION", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, " RETURN TO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<ATSU DLNK", MCDU_LARGE, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "VERT REQ>", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "OTHER REQ>", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, "TEXT>", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "REPORTS>", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "CONNECTION ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "STATUS>", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "EMERGENCY>", MCDU_LARGE, ECAM_ORANGE)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 1000)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
