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

    local subject = mcdu_data.vert_rev_subject
    local subject_id = subject.data.id

    assert(subject_id)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    self:set_multi_title(mcdu_data, {
        {txt="VERT REV " .. mcdu_format_force_to_small("AT").."       ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="             " .. subject_id, col=main_col, size=MCDU_LARGE}
    })

    if subject.data.point_type == POINT_TYPE_DEP_SID
       or subject.data.point_type == POINT_TYPE_DEP_TRANS then
        mcdu_data.page_data[608].is_clb_or_desc = 1  -- CLIMB
    elseif subject.data.point_type == POINT_TYPE_ARR_APPR
        or subject.data.point_type == POINT_TYPE_ARR_STAR
        or subject.data.point_type == POINT_TYPE_ARR_VIA
        or subject.data.point_type == POINT_TYPE_ARR_TRANS
    then
        mcdu_data.page_data[608].is_clb_or_desc = 2  -- DESCENT
    elseif subject.data.pred and subject.data.pred.is_climb then
        mcdu_data.page_data[608].is_clb_or_desc = 1  -- CLIMB
    elseif subject.data.pred and subject.data.pred.is_descent then
        mcdu_data.page_data[608].is_clb_or_desc = 2  -- DESCENT
    end

    
    -------------------------------------
    -- LINE 1
    -------------------------------------

    self:set_line(mcdu_data, MCDU_LEFT, 1, " EFOB".. mcdu_format_force_to_small("=").. "---.-  EXTRA=---.-", MCDU_SMALL)

    -------------------------------------
    -- RIGHT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "RTA>", MCDU_LARGE)

    -------------------------------------
    -- LEFT 2
    -------------------------------------

    if mcdu_data.page_data[608].is_clb_or_desc > 0 then
        if mcdu_data.page_data[608].is_clb_or_desc == 1 then
            self:set_line(mcdu_data, MCDU_LEFT, 2, "CLB SPD LIM", MCDU_SMALL)
        elseif mcdu_data.page_data[608].is_clb_or_desc == 2 then
            self:set_line(mcdu_data, MCDU_LEFT, 2, "DES SPD LIM", MCDU_SMALL)
        end

        if FMGS_sys.data.init.alt_speed_limit_climb then
            -- ex: 210/5000 or 210/50.
            local text = FMGS_sys.data.init.alt_speed_limit_climb[1].."/"..FMGS_sys.data.init.alt_speed_limit_climb[2]
            text = (FMGS_sys.data.init.alt_speed_limit_climb[1] == 250 and FMGS_sys.data.init.alt_speed_limit_climb[2] == 10000) and mcdu_format_force_to_small(text) or text
            self:set_line(mcdu_data, MCDU_LEFT, 2, text, MCDU_LARGE, ECAM_MAGENTA)
        else
            self:set_line(mcdu_data, MCDU_LEFT, 2, "[  ]/[     ]", MCDU_LARGE, ECAM_MAGENTA)
        end
    end
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

function THIS_PAGE:L2(mcdu_data)
    if mcdu_data.clr then   -- A clear is requested
        if mcdu_data.page_data[608].is_clb_or_desc == 1 then
            FMGS_sys.data.init.alt_speed_limit_climb = nil
            return
        elseif mcdu_data.page_data[608].is_clb_or_desc == 2 then
            FMGS_sys.data.init.alt_speed_limit_descent = nil
            return
        end
    else
        local a, b = mcdu_get_entry(mcdu_data, {"!!!"}, {"!!!!!","!!!!", "!!!","!!"}, false)
        b = tonumber(b)
        if b < 1000 then
            b = b * 100
        end
        local new_limit = {tonumber(a), b}
        if mcdu_data.page_data[608].is_clb_or_desc == 1 then
            FMGS_sys.data.init.alt_speed_limit_climb = new_limit
            return
        elseif mcdu_data.page_data[608].is_clb_or_desc == 2 then
            FMGS_sys.data.init.alt_speed_limit_descent = new_limit
            return
        end
    end

    MCDU_Page:L2(mcdu_data) -- Error
end
function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 600)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
