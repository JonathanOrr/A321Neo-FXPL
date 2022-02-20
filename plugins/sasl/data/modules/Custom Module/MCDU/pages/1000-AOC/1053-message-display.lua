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
include("libs/table.save.lua")

local THIS_PAGE = MCDU_Page:new({id=1053})

THIS_PAGE.current_page_number = 1

function THIS_PAGE:render(mcdu_data)

    if not mcdu_data.page_data[1053] then mcdu_data.page_data[1053] = {} end

    self:set_title(mcdu_data, "AOC MSG DISPLAY")

    local reading_msg = AOC_sys.reading_msg
    self:set_line(mcdu_data, MCDU_LEFT, 1, AOC_sys.msgs[reading_msg].time.." "..(AOC_sys.msgs[reading_msg].opened == false and "NEW" or "VIEWED"), MCDU_SMALL, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_format_force_to_small("FROM "..AOC_sys.msgs[reading_msg].from_who), MCDU_LARGE, ECAM_BLUE)

    mcdu_data.page_data[1053].number_of_lines = #(AOC_sys.msgs[reading_msg].message)
    mcdu_data.page_data[1053].number_of_pages = math.ceil((mcdu_data.page_data[1053].number_of_lines)/8)
    mcdu_data.page_data[1053].skip_lines = ((THIS_PAGE.current_page_number)-1)*8

    self:set_line(mcdu_data, MCDU_RIGHT, 1, (THIS_PAGE.current_page_number).."/".. (mcdu_data.page_data[1053].number_of_pages), MCDU_SMALL, ECAM_WHITE)

    for i=1, mcdu_data.page_data[1053].number_of_lines - mcdu_data.page_data[1053].skip_lines do
        mcdu_line_number = Round(i/2 + 1, 0) -- make into pattern 1,2,2,3,3,4,4,5,5,6... etc
        if i%2 == 0 then -- Odd number, small line
            self:set_line(mcdu_data, MCDU_LEFT, mcdu_line_number, mcdu_format_force_to_small(string.upper(AOC_sys.msgs[reading_msg].message[i + mcdu_data.page_data[1053].skip_lines])), MCDU_LARGE, ECAM_GREEN)
        else
            self:set_line(mcdu_data, MCDU_LEFT, mcdu_line_number, string.upper((AOC_sys.msgs[reading_msg].message[i + mcdu_data.page_data[1053].skip_lines])), MCDU_SMALL, ECAM_GREEN)
        end
    end

    self:set_line(mcdu_data, MCDU_LEFT, 6, " RETURN TO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<AOC MSGS", MCDU_LARGE, ECAM_WHITE)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 1052)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    THIS_PAGE.current_page_number = math.min(THIS_PAGE.current_page_number + 1, mcdu_data.page_data[1053].number_of_pages)
end

function THIS_PAGE:Slew_Left(mcdu_data)
    THIS_PAGE.current_page_number = math.max(THIS_PAGE.current_page_number - 1, 1)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
