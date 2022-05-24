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

function THIS_PAGE:render(mcdu_data)
    assert(mcdu_data.lat_rev_subject and mcdu_data.lat_rev_subject.type == 1)

    if not mcdu_data.page_data[THIS_PAGE.id] then
        mcdu_data.page_data[THIS_PAGE.id] = { curr_page = 1 }
    end

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    self:set_lr_arrows(mcdu_data, true)

    local subject_id = mcdu_data.lat_rev_subject.data.id

    self:set_multi_title(mcdu_data, {
        {txt="  DEPARTURES " .. mcdu_format_force_to_small("FROM").."         ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="              " .. subject_id, col=ECAM_GREEN, size=MCDU_LARGE}
    })

    -------------------------------------
    -- LEFT/CENTER/RIGHT 1
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, " RWY", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "TRANS ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_CENTER, 1, "SID", MCDU_SMALL)

    local sel_rwy, sibl = FMGS_dep_get_rwy(true)
    local sid = FMGS_dep_get_sid(true)
    local trans = FMGS_dep_get_trans(true)
    if sel_rwy then
        self:set_line(mcdu_data, MCDU_LEFT, 1, sibl and sel_rwy.sibl_name or sel_rwy.name, MCDU_LARGE, main_col)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 1, "---", MCDU_LARGE)
    end
    if sid then
        self:set_line(mcdu_data, MCDU_CENTER, 1, Aft_string_fill(sid.proc_name, " ", 7), MCDU_LARGE, main_col)
    else
        self:set_line(mcdu_data, MCDU_CENTER, 1, "------  ", MCDU_LARGE)
    end
    if trans then
        local name = trans.trans_name == "NO TRANS" and "NONE" or trans.trans_name
        self:set_line(mcdu_data, MCDU_RIGHT, 1, name, MCDU_LARGE, main_col)
    else
        self:set_line(mcdu_data, MCDU_RIGHT, 1, "------", MCDU_LARGE)
    end

    -------------------------------------
    -- LEFT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 2, "   AVAILABLE RUNWAYS", MCDU_SMALL)
    
    local n = 2
    local last_showed = true
    for i,rwy in ipairs(mcdu_data.lat_rev_subject.data.rwys) do
        if i > 2 * (mcdu_data.page_data[THIS_PAGE.id].curr_page-1) and i <= 2 * (mcdu_data.page_data[THIS_PAGE.id].curr_page) then

            local arrow = (sel_rwy and rwy.name == sel_rwy.name and not sibl) and " " or "←"
            self:set_line(mcdu_data, MCDU_LEFT, n, arrow .. Aft_string_fill(rwy.name, " ", 9) .. math.floor(rwy.distance) .. "M", MCDU_LARGE, ECAM_BLUE)
            self:set_line(mcdu_data, MCDU_LEFT, n+1, "   " .. Fwd_string_fill(tostring(math.floor(rwy.bearing)), "0", 3), MCDU_SMALL, ECAM_BLUE)

            local arrow = (sel_rwy and rwy.sibl_name == sel_rwy.sibl_name and sibl) and " " or "←"
            self:set_line(mcdu_data, MCDU_LEFT, n+1, arrow .. Aft_string_fill(rwy.sibl_name, " ", 9) .. math.floor(rwy.distance) .. "M", MCDU_LARGE, ECAM_BLUE)
            self:set_line(mcdu_data, MCDU_LEFT, n+2, "   " .. Fwd_string_fill(tostring(math.floor(rwy.bearing+180)%360), "0", 3), MCDU_SMALL, ECAM_BLUE)
            n = n+2
            last_showed = true
        else
            self:set_updn_arrows_bottom(mcdu_data, true)
            last_showed = false
        end
    end

    -------------------------------------
    -- LEFT 6
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE)

    if last_showed then
        self:set_line(mcdu_data, MCDU_CENTER, 6, " END", MCDU_LARGE)
    end
end

function THIS_PAGE:sel_rwy(mcdu_data, i)
    local start_rwy = 2*(mcdu_data.page_data[THIS_PAGE.id].curr_page-1)
    
    local sel_rwy_i = start_rwy + math.ceil(i/2)
    if sel_rwy_i > 2*#mcdu_data.lat_rev_subject.data.rwys then
        MCDU_Page:Slew_Down(mcdu_data)  -- Clicked on empty spot
        return
    end
    FMGS_create_copy_temp_fpln()
    FMGS_reset_dep_sid()
    FMGS_reset_dep_trans()
    FMGS_dep_set_rwy(mcdu_data.lat_rev_subject.data.rwys[sel_rwy_i], i % 2 == 0)
    mcdu_open_page(mcdu_data, 604)
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
    if mcdu_data.page_data[THIS_PAGE.id].curr_page <= 1 then
        MCDU_Page:Slew_Up(mcdu_data)
    else
        mcdu_data.page_data[THIS_PAGE.id].curr_page = mcdu_data.page_data[THIS_PAGE.id].curr_page - 1
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    if math.ceil(#mcdu_data.lat_rev_subject.data.rwys / 2) <= mcdu_data.page_data[THIS_PAGE.id].curr_page then
        MCDU_Page:Slew_Down(mcdu_data)
    else
        mcdu_data.page_data[THIS_PAGE.id].curr_page = mcdu_data.page_data[THIS_PAGE.id].curr_page + 1
    end
end

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 604)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 604)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
