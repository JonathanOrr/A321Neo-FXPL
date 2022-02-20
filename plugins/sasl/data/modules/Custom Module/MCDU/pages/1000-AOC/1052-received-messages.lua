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


local THIS_PAGE = MCDU_Page:new({id=1052})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "AOC RCVD MSGS")

    if #AOC_sys.msgs > 0 then
        for i=1, #AOC_sys.msgs do
            self:set_line(mcdu_data, MCDU_LEFT, i, " "..AOC_sys.msgs[i].time.." "..(AOC_sys.msgs[i].opened == false and "NEW" or "VIEWED"), MCDU_SMALL, ECAM_GREEN)
            self:set_line(mcdu_data, MCDU_LEFT, i, "<"..AOC_sys.msgs[i].title, MCDU_LARGE, ECAM_WHITE)
        end
    end

    self:set_line(mcdu_data, MCDU_LEFT, 6, " RETURN TO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<AOC MENU", MCDU_LARGE, ECAM_WHITE)
end

function THIS_PAGE:L1(mcdu_data)
    if AOC_sys.msgs[1] == nil then return end
    AOC_sys.msgs[1].opened = true
    AOC_sys.reading_msg = 1
    mcdu_open_page(mcdu_data, 1053)
end
function THIS_PAGE:L2(mcdu_data)
    if AOC_sys.msgs[2] == nil then return end
    AOC_sys.msgs[2].opened = true
    AOC_sys.reading_msg = 2
    mcdu_open_page(mcdu_data, 1053)
end
function THIS_PAGE:L3(mcdu_data)
    if AOC_sys.msgs[3] == nil then return end
    AOC_sys.msgs[3].opened = true
    AOC_sys.reading_msg = 3
    mcdu_open_page(mcdu_data, 1053)
end
function THIS_PAGE:L4(mcdu_data)
    if AOC_sys.msgs[4] == nil then return end
    AOC_sys.msgs[4].opened = true
    AOC_sys.reading_msg = 4
    mcdu_open_page(mcdu_data, 1053)
end
function THIS_PAGE:L5(mcdu_data)
    if AOC_sys.msgs[5] == nil then return end
    AOC_sys.msgs[5].opened = true
    AOC_sys.reading_msg = 5
    mcdu_open_page(mcdu_data, 1053)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 1050)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
