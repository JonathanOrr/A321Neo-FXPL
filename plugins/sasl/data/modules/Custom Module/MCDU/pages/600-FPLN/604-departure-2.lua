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
THIS_PAGE.sid_length = 0
THIS_PAGE.eosid = nil
THIS_PAGE.sid_references = {0,0,0,0}
THIS_PAGE.trans_references = {0,0,0,0}

function THIS_PAGE:render_trans(mcdu_data, sel_rwy)
    if not sel_rwy or not FMGS_dep_get_sid(true) then
        return -- No runways or sid selected
    end
    
    local trans_list = {}
    THIS_PAGE.trans_length = 0
    
    if not THIS_PAGE.curr_fpln.apts.dep_cifp then
        return  -- This should not happen
    end

    -- Extract the trans
    for i,x in ipairs(THIS_PAGE.curr_fpln.apts.dep_cifp.sids) do
    
        local rwy_match = x.proc_name == FMGS_dep_get_sid(true).proc_name or x.proc_name == "ALL"
        if     x.type == CIFP_TYPE_SS_ENR_TRANS
            or x.type == CIFP_TYPE_SS_ENR_TRANS_RNAV
            or x.type == CIFP_TYPE_SS_ENR_TRANS_FMS then

            if rwy_match then
                trans_list[x.trans_name] = i
                THIS_PAGE.trans_length = THIS_PAGE.trans_length + 1
            end
        end
    end

    THIS_PAGE.trans_references = {0,0,0,0}    -- These will contain the references for buttons

    local i = 0
    local n_line = 2
    for k,idx in pairs(trans_list) do
        i = i + 1
        if i > 4 * (THIS_PAGE.curr_page-1) and i <= 4 * (THIS_PAGE.curr_page) then
            local arrow = (FMGS_dep_get_trans(true) and FMGS_dep_get_trans(true).trans_name == k) and " " or "→"
            self:set_line(mcdu_data, MCDU_RIGHT, n_line, k .. arrow, MCDU_LARGE, ECAM_BLUE)
            THIS_PAGE.trans_references[n_line-1] = idx    -- Let's same the array index so that we can use this for buttons
            n_line = n_line + 1
        end
    end
    

end

function THIS_PAGE:render_sid(mcdu_data, sel_rwy, sibl)
    if not sel_rwy then
        return -- No runways selected
    end
    
    local sid_list = {}
    THIS_PAGE.sid_length = 0
    THIS_PAGE.eosid = nil
    
    if not THIS_PAGE.curr_fpln.apts.dep_cifp then
        return  -- This should not happen
    end

    local rwid = "RW" .. (sibl and sel_rwy.sibl_name or sel_rwy.name)
    local rwid_both = rwid:sub(1,-2) .. "B" -- B stands for L, R, and C. If the runway doesn't have it, it doesn't matter, cannot match

    -- Extract the sids
    for i,x in ipairs(THIS_PAGE.curr_fpln.apts.dep_cifp.sids) do
    
        local rwy_match = x.trans_name == rwid or x.trans_name == rwid_both or x.trans_name == "ALL"
        if x.type == CIFP_TYPE_SS_ENG_OUT and rwy_match then
            THIS_PAGE.eosid = x
        elseif x.type == CIFP_TYPE_SS_RWY_TRANS
            or x.type == CIFP_TYPE_SS_CMN_ROUTE
            or x.type == CIFP_TYPE_SS_RWY_TRANS_RNAV
            or x.type == CIFP_TYPE_SS_CMN_ROUTE_RNAV
            or x.type == CIFP_TYPE_SS_RWY_TRANS_FMS
            or x.type == CIFP_TYPE_SS_CMN_ROUTE_FMS then

            if rwy_match then
                sid_list[x.proc_name] = i
                THIS_PAGE.sid_length = THIS_PAGE.sid_length + 1
            end
        end
    end

    THIS_PAGE.sid_references = {0,0,0,0}    -- These will contain the references for buttons

    local i = 0
    local n_line = 2
    for k,idx in pairs(sid_list) do
        i = i + 1
        if i > 4 * (THIS_PAGE.curr_page-1) and i <= 4 * (THIS_PAGE.curr_page) then
            local arrow = (FMGS_dep_get_sid(true) and FMGS_dep_get_sid(true).proc_name == k) and " " or "←"
            self:set_line(mcdu_data, MCDU_LEFT, n_line, arrow .. k, MCDU_LARGE, ECAM_BLUE)
            THIS_PAGE.sid_references[n_line-1] = idx    -- Let's same the array index so that we can use this for buttons
            n_line = n_line + 1
        end
    end
    
end

function THIS_PAGE:render(mcdu_data)
    assert(mcdu_data.lat_rev_subject and mcdu_data.lat_rev_subject.type == 1)

    self:set_lr_arrows(mcdu_data, true)

    THIS_PAGE.main_col  = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN
    THIS_PAGE.curr_fpln = FMGS_get_current_fpln()

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
        self:set_line(mcdu_data, MCDU_LEFT, 1, sibl and sel_rwy.sibl_name or sel_rwy.name, MCDU_LARGE, THIS_PAGE.main_col)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 1, "---", MCDU_LARGE)
    end
    if sid then
        local name = sid.proc_name == "NO SID" and "NONE" or sid.proc_name
        self:set_line(mcdu_data, MCDU_CENTER, 1, Aft_string_fill(name, " ", 7), MCDU_LARGE, THIS_PAGE.main_col)
    else
        self:set_line(mcdu_data, MCDU_CENTER, 1, "------  ", MCDU_LARGE)
    end
    if trans then
        local name = trans.trans_name == "NO TRANS" and "NONE" or trans.trans_name
        self:set_line(mcdu_data, MCDU_RIGHT, 1, name, MCDU_LARGE, THIS_PAGE.main_col)
    else
        self:set_line(mcdu_data, MCDU_RIGHT, 1, "------", MCDU_LARGE)
    end

    -------------------------------------
    -- LEFT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 2, "SIDS   AVAILABLE   TRANS", MCDU_SMALL)

    THIS_PAGE:render_sid(mcdu_data, sel_rwy, sibl)
    THIS_PAGE:render_trans(mcdu_data, sel_rwy)

    -------------------------------------
    -- LEFT/RIGHT 6
    -------------------------------------
    if FMGS_does_temp_fpln_exist() then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)
    end

    self:set_line(mcdu_data, MCDU_CENTER, 6, "EOSID", MCDU_SMALL)
    if THIS_PAGE.eosid then
        self:set_line(mcdu_data, MCDU_CENTER, 6, THIS_PAGE.eosid.proc_name, MCDU_LARGE, THIS_PAGE.main_col)
    else
        self:set_line(mcdu_data, MCDU_CENTER, 6, " NONE", MCDU_LARGE, ECAM_WHITE)
    end
end

function THIS_PAGE:sel_sid(mcdu_data, i)
    
    if not FMGS_does_temp_fpln_exist() then
        FMGS_create_copy_temp_fpln()
        FMGS_reset_dep_trans()
    end
    
    if THIS_PAGE.sid_references[i] > 0 then
        FMGS_dep_set_sid(THIS_PAGE.curr_fpln.apts.dep_cifp.sids[THIS_PAGE.sid_references[i]])
        FMGS_reset_dep_trans()
        THIS_PAGE.curr_page = 1
    else
        MCDU_Page:L2(mcdu_data) -- Error
    end
    
end

function THIS_PAGE:sel_trans(mcdu_data, i)
    if not FMGS_does_temp_fpln_exist() then
        FMGS_create_copy_temp_fpln()
    end

    if THIS_PAGE.trans_references[i] > 0 then
        FMGS_dep_set_trans(THIS_PAGE.curr_fpln.apts.dep_cifp.sids[THIS_PAGE.trans_references[i]])
    else
        MCDU_Page:R2(mcdu_data) -- Error
    end
end


function THIS_PAGE:L2(mcdu_data)
    THIS_PAGE:sel_sid(mcdu_data, 1)
end
function THIS_PAGE:L3(mcdu_data)
    THIS_PAGE:sel_sid(mcdu_data, 2)
end
function THIS_PAGE:L4(mcdu_data)
    THIS_PAGE:sel_sid(mcdu_data, 3)
end
function THIS_PAGE:L5(mcdu_data)
    THIS_PAGE:sel_sid(mcdu_data, 4)
end

function THIS_PAGE:R2(mcdu_data)
    THIS_PAGE:sel_trans(mcdu_data, 1)
end
function THIS_PAGE:R3(mcdu_data)
    THIS_PAGE:sel_trans(mcdu_data, 2)
end
function THIS_PAGE:R4(mcdu_data)
    THIS_PAGE:sel_trans(mcdu_data, 3)
end
function THIS_PAGE:R5(mcdu_data)
    THIS_PAGE:sel_trans(mcdu_data, 4)
end


function THIS_PAGE:L6(mcdu_data)
    FMGS_erase_temp_fpln()
    mcdu_open_page(mcdu_data, 600)
end

function THIS_PAGE:R6(mcdu_data)
    FMGS_reshape_fpln()
    FMGS_reshape_fpln_dep(FMGS_get_current_fpln()) -- Add discontinuity if necessary
    FMGS_insert_temp_fpln()
    mcdu_open_page(mcdu_data, 600)
end
function THIS_PAGE:Slew_Down(mcdu_data)
    if THIS_PAGE.curr_page <= 1 then
        MCDU_Page:Slew_Down(mcdu_data)
    else
        THIS_PAGE.curr_page = THIS_PAGE.curr_page - 1
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    if math.floor(THIS_PAGE.sid_length / 4) <= THIS_PAGE.curr_page then
        MCDU_Page:Slew_Up(mcdu_data)
    else
        THIS_PAGE.curr_page = THIS_PAGE.curr_page + 1
    end
end


function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 603)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 603)
end



mcdu_pages[THIS_PAGE.id] = THIS_PAGE
