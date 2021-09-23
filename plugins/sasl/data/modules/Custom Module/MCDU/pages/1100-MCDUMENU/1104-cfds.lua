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


local THIS_PAGE = MCDU_Page:new({id=1104})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "CFDS")

    if get(All_on_ground) == 1 then
        self:set_line(mcdu_data, MCDU_LEFT, 1, "<LAST LEG REPORT", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 2, "<LAST LEG ECAM REPORT", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 3, "<PREVIOUS LEGS REPORT", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 4, "<AVIONICS STATUS", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 5, "<SYSTEM REPORT/TEST", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "POST FLIGHT REP PRINT*", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 1, "<CURRENT LEG REPORT", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 2, "<CURRENT LEG ECAM REPORT", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 5, "<SYSTEM REPORT/TEST", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "*SEND", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "PRINT*", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_CENTER, 6, "CURRENT", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_CENTER, 6, "FLT REP", MCDU_LARGE, ECAM_WHITE)
    end

end


function THIS_PAGE:L5(mcdu_data)
    mcdu_open_page(mcdu_data, 11045)
end



mcdu_pages[THIS_PAGE.id] = THIS_PAGE
