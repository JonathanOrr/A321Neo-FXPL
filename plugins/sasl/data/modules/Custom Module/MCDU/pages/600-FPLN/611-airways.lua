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

local THIS_PAGE = MCDU_Page:new({id=611})

function THIS_PAGE:render_awys(mcdu_data)

    local curr_displayed_line = 1   -- Current MCDU line being drawn
    local start_i = mcdu_data.page_data[602].curr_page * 5 + 1  -- Current airways
    local end_i   = math.min(#mcdu_data.page_data[602].awys, start_i + 5) -- Current airways
    
    for i=start_i, end_i do
        self:set_line(mcdu_data, MCDU_LEFT, curr_displayed_line, ""..i, MCDU_SMALL, ECAM_WHITE)

        curr_displayed_line = curr_displayed_line + 1
        if curr_displayed_line >= 6 then
            break
        end
    end

    if curr_displayed_line >= 6 or mcdu_data.page_data[602].curr_page > 0 then
        self:set_updn_arrows_bottom(mcdu_data, true)
    end

    if curr_displayed_line < 6 then
        self:set_line(mcdu_data, MCDU_LEFT, curr_displayed_line, "VIA", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, curr_displayed_line, "[   ]", MCDU_LARGE, ECAM_BLUE)
    end

end

function THIS_PAGE:render(mcdu_data)

    --------------------------------------------------- TODO: REMOVE
    mcdu_data.airways.source_wpt  = {id="ABESI"}
    mcdu_data.airways.return_page = 200
    --------------------------------------------------- END TODO: REMOVE

    assert(mcdu_data.airways.source_wpt, "Provide me which navaid you want.")
    assert(mcdu_data.airways.return_page, "Provide me where to return")

    local source_name = mcdu_data.airways.source_wpt.id

    if not mcdu_data.page_data[602] then
        mcdu_data.page_data[602] = { awys={{},{},{},{},{},{}}, curr_page=0 }
    end

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    self:set_multi_title(mcdu_data, {
        {txt="AIRWAYS " .. mcdu_format_force_to_small("FROM").."      ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="             " .. source_name, col=main_col, size=MCDU_LARGE}
    })

    self:render_awys(mcdu_data)

    if not FMGS_does_temp_fpln_exist() then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE, ECAM_WHITE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)
    end

end

function THIS_PAGE:L1(mcdu_data)
    MCDU_Page:L1(mcdu_data) -- Error
end

function THIS_PAGE:Slew_Down(mcdu_data)
    if mcdu_data.page_data[602].curr_page == 0 then
        mcdu_data.page_data[602].curr_page = math.ceil(#mcdu_data.page_data[602].awys/5) - 1
    else
        mcdu_data.page_data[602].curr_page = mcdu_data.page_data[602].curr_page - 1
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    local last_page = math.ceil(#mcdu_data.page_data[602].awys/5) - 1
    if mcdu_data.page_data[602].curr_page == last_page then
        mcdu_data.page_data[602].curr_page = 0
    else
        mcdu_data.page_data[602].curr_page = mcdu_data.page_data[602].curr_page + 1
    end
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
