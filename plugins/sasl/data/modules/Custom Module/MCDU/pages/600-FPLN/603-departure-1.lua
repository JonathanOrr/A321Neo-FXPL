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


local THIS_PAGE = MCDU_Page:new({id=603})

THIS_PAGE.curr_page = 1

function THIS_PAGE:render(mcdu_data)
    assert(mcdu_data.lat_rev_subject and mcdu_data.lat_rev_subject.type == 1)

    self:set_lr_arrows(mcdu_data, true)

    local subject_id = mcdu_data.lat_rev_subject.data.id

    self:set_multi_title(mcdu_data, {
        {txt="DEPARTURES " .. mcdu_format_force_to_small("FROM").."           ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="             " .. subject_id, col=ECAM_GREEN, size=MCDU_LARGE}
    })

    -------------------------------------
    -- LEFT/CENTER/RIGHT 1
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, " RWY", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "TRANS ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_CENTER, 1, "SID", MCDU_SMALL)

    local rwy = FMGS_dep_get_rwy()
    local sid = FMGS_dep_get_sid()
    local trans = FMGS_dep_get_trans()
    if rwy then
        self:set_line(mcdu_data, MCDU_LEFT, 1, rwy, MCDU_LARGE, ECAM_YELLOW)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 1, "---", MCDU_LARGE)
    end
    if sid then
        self:set_line(mcdu_data, MCDU_CENTER, 1, Aft_string_fill(sid, " ", 7), MCDU_LARGE, ECAM_YELLOW)
    else
        self:set_line(mcdu_data, MCDU_CENTER, 1, "------  ", MCDU_LARGE)
    end
    if trans then
        self:set_line(mcdu_data, MCDU_RIGHT, 1, trans, MCDU_LARGE, ECAM_YELLOW)
    else
        self:set_line(mcdu_data, MCDU_RIGHT, 1, "------", MCDU_LARGE)
    end

    -------------------------------------
    -- LEFT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 2, "   AVAILABLE RUNWAYS", MCDU_SMALL)
    
    local n = 2
    
    for i,rwy in ipairs(mcdu_data.lat_rev_subject.data.rwys) do
        if i > 2 * (THIS_PAGE.curr_page-1) and i <= 2 * (THIS_PAGE.curr_page) then
            self:set_line(mcdu_data, MCDU_LEFT, n, "←" .. Aft_string_fill(rwy.name, " ", 9) .. math.floor(rwy.distance) .. "M", MCDU_LARGE, ECAM_BLUE)
            self:set_line(mcdu_data, MCDU_LEFT, n+1, "   " .. Fwd_string_fill(tostring(math.floor(rwy.bearing)), "0", 3), MCDU_SMALL, ECAM_BLUE)
            self:set_line(mcdu_data, MCDU_LEFT, n+1, "←" .. Aft_string_fill(rwy.sibl_name, " ", 9) .. math.floor(rwy.distance) .. "M", MCDU_LARGE, ECAM_BLUE)
            self:set_line(mcdu_data, MCDU_LEFT, n+2, "   " .. Fwd_string_fill(tostring(math.floor(rwy.bearing+180)%360), "0", 3), MCDU_SMALL, ECAM_BLUE)
            n = n+2
        else
            self:set_updn_arrows_bottom(mcdu_data, true)
        end
    end

    -------------------------------------
    -- LEFT 6
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 602)
end

function THIS_PAGE:Slew_Down(mcdu_data)
    if math.floor(#mcdu_data.lat_rev_subject.data.rwys / 2) <= THIS_PAGE.curr_page then
        MCDU_Page:Slew_Down(mcdu_data)
    else
        THIS_PAGE.curr_page = THIS_PAGE.curr_page + 1
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    if THIS_PAGE.curr_page <= 1 then
        MCDU_Page:Slew_Up(mcdu_data)
    else
        THIS_PAGE.curr_page = THIS_PAGE.curr_page - 1
    end
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
