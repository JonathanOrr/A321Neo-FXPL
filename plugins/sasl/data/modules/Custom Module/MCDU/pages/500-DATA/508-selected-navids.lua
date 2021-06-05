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
-- File: 505-ac-status.lua 
-------------------------------------------------------------------------------

local THIS_PAGE = MCDU_Page:new({id=508})


function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data,"SELECTED NAVIDS")
    self:set_line(mcdu_data, MCDU_LEFT, 1, " VOR/TAC  AUTO  DESELECT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "[  ]*" , MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, " VOR/DME  AUTO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, " VOR/TAC  AUTO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, " ILS      AUTO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, " RADIONAV SELECTED", MCDU_SMALL, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, " GPS SELECTED", MCDU_SMALL, ECAM_BLUE)

    local nav_info = {
        {"ABC" , "000.00"},--do the tostring or rounding stuff here plz, don't do it below in the multititle
        {"DEF" , "000.00"},
        {"GHI" , "000.00"},
        {"JKLM", "000.00"},
    }

    --self:set_multi_title(mcdu_data, {
    --    {txt= "<"..L1_nav_info[1] , col=ECAM_BLUE, size=MCDU_LARGE},
    --    {txt="   "..mcdu_format_force_to_small(L1_nav_info[2]), col=ECAM_GREEN, size=MCDU_LARGE}
    --})
    for i=1, 4 do
        self:set_line(mcdu_data, MCDU_LEFT, i, "<"..nav_info[i][1] , MCDU_LARGE, ECAM_BLUE)
    end

    self:set_line(mcdu_data, MCDU_LEFT, 5, "←DESELECT" , MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "←DESELECT" , MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "RETURN>" , MCDU_LARGE, ECAM_WHITE)
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_open_page(mcdu_data, 502)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
