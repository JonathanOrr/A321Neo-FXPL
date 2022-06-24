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

include("networking/hoppie_aoc.lua")
include("networking/aoc_functions.lua")

local THIS_PAGE = MCDU_Page:new({id=1051})

local arpt = nil

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "ATIS REQ")

    self:set_line(mcdu_data, MCDU_LEFT, 1, " ARPT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, arpt == nil and "____" or arpt, MCDU_LARGE,  arpt == nil and ECAM_ORANGE or ECAM_BLUE)

    self:set_line(mcdu_data, MCDU_LEFT, 2, " SERVICE TYPE", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "VATSIM ATIS", MCDU_LARGE, ECAM_BLUE)

    self:set_line(mcdu_data, MCDU_LEFT, 3, " REPORTING MODE", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "SINGLE REPORT", MCDU_LARGE, ECAM_BLUE)

    self:set_line(mcdu_data, MCDU_LEFT, 6, " RETURN TO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<AOC MENU", MCDU_LARGE, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_RIGHT, 5, arpt == nil and "SEND " or "SEND*", MCDU_LARGE, ECAM_BLUE)

end

function THIS_PAGE:L1(mcdu_data)
    local input = mcdu_get_entry_simple(mcdu_data, {"####"}, false)
    if input == nil then
        return
    end
    arpt = input
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 1050)
end

function THIS_PAGE:R5(mcdu_data)
    if arpt == nil then 
        mcdu_send_message(mcdu_data, "ENTER TARGET STATION")
        return 
    end
    mcdu_open_page(mcdu_data, 1050)
    AOC_fetch_atis(arpt, AOC_atis_req_callback)
    arpt = nil
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
