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


local THIS_PAGE = MCDU_Page:new({id=608})

local TYPE_ORIGIN = 1
local TYPE_WPT    = 2
local TYPE_PPOS   = 3
local TYPE_DEST   = 4

function THIS_PAGE:render(mcdu_data)

    assert(mcdu_data.vert_rev_subject)

    -- Create the page data table if not existent (first open of the page)
    if not mcdu_data.page_data[608] then
        mcdu_data.page_data[608] = {}
    end

    subject_id = mcdu_data.vert_rev_subject.data.id

    assert(subject_id)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    self:set_multi_title(mcdu_data, {
        {txt="VERT REV " .. mcdu_format_force_to_small("AT").."       ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="             " .. subject_id, col=main_col, size=MCDU_LARGE}
    })

    
    -------------------------------------
    -- LINE 1
    -------------------------------------

    self:set_line(mcdu_data, MCDU_LEFT, 1, " EFOB=---.-  EXTRA=---.-", MCDU_SMALL)

    -------------------------------------
    -- RIGHT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "RTA>", MCDU_LARGE)

    -------------------------------------
    -- LEFT 3
    -------------------------------------


    -------------------------------------
    -- RIGHT 3
    -------------------------------------

    -------------------------------------
    -- LEFT 4
    -------------------------------------


    -------------------------------------
    -- RIGHT 4
    -------------------------------------


    -------------------------------------
    -- LEFT / RIGHT 5
    -------------------------------------

    self:set_line(mcdu_data, MCDU_LEFT, 5, "<WIND", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "STEP ALTS>", MCDU_LARGE)

    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 600)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
