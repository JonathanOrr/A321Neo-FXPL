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

local THIS_PAGE = MCDU_Page:new({id=507})


function THIS_PAGE:render(mcdu_data)
    
    if not mcdu_data.v.pnxload_subpage then
        self:set_subpages(mcdu_data, 1, 2)
        mcdu_data.v.pnxload_subpage = 1
    end
    
    self:set_subpages(mcdu_data, mcdu_data.v.pnxload_subpage, 2)
    
    if mcdu_data.v.pnxload_subpage == 1 then
        self:set_title(mcdu_data, "P/N XLOAD")

        self:set_line(mcdu_data, MCDU_LEFT, 1, "X LOAD NOT AVAIL", MCDU_LARGE)
        self:set_line(mcdu_data, MCDU_LEFT, 4, "  FMS1/FMS2 IDENTICAL", MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 5, "<A/C STATUS", MCDU_LARGE)
    elseif mcdu_data.v.pnxload_subpage == 2 then
        self:set_title(mcdu_data, "P/N STATUS")

        self:set_line(mcdu_data, MCDU_LEFT, 1, "AVIONICS BAY INIT", MCDU_SMALL)
        self:set_line(mcdu_data, MCDU_LEFT, 1, AvionicsBay.is_initialized() and "INIT" or "NOT INIT", MCDU_LARGE, AvionicsBay.is_initialized() and ECAM_GREEN or ECAM_ORANGE)

        self:set_line(mcdu_data, MCDU_LEFT, 2, "AVIONICS BAY READY", MCDU_SMALL)
        self:set_line(mcdu_data, MCDU_LEFT, 2, AvionicsBay.is_ready() and "READY" or "LOADING", MCDU_LARGE, AvionicsBay.is_ready() and ECAM_GREEN or ECAM_ORANGE)
    end

    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT PAGE>", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<PREV PAGE", MCDU_LARGE)
end

function THIS_PAGE:L5(mcdu_data)
    mcdu_open_page(mcdu_data, 505)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_data.v.pnxload_subpage = mcdu_data.v.pnxload_subpage - 1
    if mcdu_data.v.pnxload_subpage == 0 then mcdu_data.v.pnxload_subpage = 2 end
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_data.v.pnxload_subpage = mcdu_data.v.pnxload_subpage % 2 + 1
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
