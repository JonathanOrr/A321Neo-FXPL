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


local THIS_PAGE = MCDU_Page:new({id=604})

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

    local sel_rwy, sibl = FMGS_dep_get_rwy()
    local sid = FMGS_dep_get_sid()
    local trans = FMGS_dep_get_trans()
    if sel_rwy then
        self:set_line(mcdu_data, MCDU_LEFT, 1, sibl and sel_rwy.sibl_name or sel_rwy.name, MCDU_LARGE, ECAM_YELLOW)
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
    self:set_line(mcdu_data, MCDU_LEFT, 2, "SIDS   AVAILABLE   TRANS", MCDU_SMALL)

    -------------------------------------
    -- LEFT 6
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)

    -------------------------------------
    -- RIGHT 6
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)

    self:set_line(mcdu_data, MCDU_CENTER, 6, "EOSID", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_CENTER, 6, "TODO ", MCDU_LARGE, ECAM_YELLOW)   -- TODO
end

function THIS_PAGE:sel_rwy(mcdu_data, i)
    local start_rwy = 2*(THIS_PAGE.curr_page-1)
    
    local sel_rwy_i = start_rwy + math.ceil(i/2)
    if sel_rwy_i > 2*#mcdu_data.lat_rev_subject.data.rwys then
        MCDU_Page:Slew_Down(mcdu_data)  -- Clicked on empty spot
        return
    end
    FMGS_dep_set_rwy(mcdu_data.lat_rev_subject.data.rwys[sel_rwy_i], i % 2 == 0)
end


function THIS_PAGE:L2(mcdu_data)
    THIS_PAGE:sel_rwy(mcdu_data, 1)
end
function THIS_PAGE:L3(mcdu_data)
    THIS_PAGE:sel_rwy(mcdu_data, 2)
end
function THIS_PAGE:L4(mcdu_data)
    THIS_PAGE:sel_rwy(mcdu_data, 3)
end
function THIS_PAGE:L5(mcdu_data)
    THIS_PAGE:sel_rwy(mcdu_data, 4)
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


function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 603)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 603)
end



mcdu_pages[THIS_PAGE.id] = THIS_PAGE
