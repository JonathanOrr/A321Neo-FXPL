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


local THIS_PAGE = MCDU_Page:new({id=605})

THIS_PAGE.curr_page = 1
THIS_PAGE.apprs_length = 0
THIS_PAGE.apprs_references = {0,0,0,0}

local function type_char_to_idx(x)
    if x == CIFP_TYPE_APPR_MLS then
        return 1, "MLS"
    elseif x == CIFP_TYPE_APPR_ILS then
        return 2, "ILS"
    elseif x == CIFP_TYPE_APPR_GLS then
        return 3, "GLS"
    elseif x == CIFP_TYPE_APPR_IGS then
        return 4, "IGS"
    elseif x == CIFP_TYPE_APPR_LOC_ONLY then
        return 5, "LOC"
    elseif x == CIFP_TYPE_APPR_LOC_BC then
        return 6, "BAC"
    elseif x == CIFP_TYPE_APPR_LDA then
        return 7, "LDA"
    elseif x == CIFP_TYPE_APPR_SDF then
        return 8, "SDF"
    elseif x == CIFP_TYPE_APPR_GPS then
        return 9, "GPS"
    elseif x == CIFP_TYPE_APPR_RNAV then
        return 10, "RNAV"
    elseif x == CIFP_TYPE_APPR_VOR or x == CIFP_TYPE_APPR_VORDMETAC then
        return 11, "VOR"
    elseif x == CIFP_TYPE_APPR_NDB or x == CIFP_TYPE_APPR_NDBDME then
        return 12, "NDB"
    else
        return nil, nil
    end
end

function THIS_PAGE:render_apprs(mcdu_data)
    if not THIS_PAGE.curr_fpln.apts.arr_cifp then
        return  -- This should not happen
    end
    
    local apprs_list = {}
    THIS_PAGE.apprs_length = 0
    
    for i,x in ipairs(THIS_PAGE.curr_fpln.apts.arr_cifp.apprs) do
        local type_idx, type_str = type_char_to_idx(x.type)
        if type_idx ~= nil then
            if not apprs_list[type_idx] then
                 apprs_list[type_idx] = {}
            end
            table.insert(apprs_list[type_idx], {name=x.proc_name:sub(2), idx=i, prefix=type_str})
            THIS_PAGE.apprs_length = THIS_PAGE.apprs_length + 1
        end
    end
    
    THIS_PAGE.apprs_references = {0,0,0,0}    -- These will contain the references for buttons

    local i = 0
    local n_line = 3
    for _,data_content in pairs(apprs_list) do
        for _,data in pairs(data_content) do
            i = i + 1
            if i > 3 * (THIS_PAGE.curr_page-1) and i <= 3 * (THIS_PAGE.curr_page) then
                local arrow = "←" -- (FMGS_dep_get_sid(true) and FMGS_dep_get_sid(true).proc_name == k) and " " or "←"
                self:set_line(mcdu_data, MCDU_LEFT, n_line, arrow .. data.prefix .. data.name, MCDU_LARGE, ECAM_BLUE)
                THIS_PAGE.apprs_references[n_line-1] = data.idx    -- Let's same the array index so that we can use this for buttons
                n_line = n_line + 1
            end
        end
    end
end

function THIS_PAGE:render(mcdu_data)
    assert(mcdu_data.lat_rev_subject and mcdu_data.lat_rev_subject.type == 4)
    THIS_PAGE.main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN
    THIS_PAGE.curr_fpln = FMGS_get_current_fpln()

    self:set_lr_arrows(mcdu_data, true)

    local subject_id = mcdu_data.lat_rev_subject.data.id

    self:set_multi_title(mcdu_data, {
        {txt="  ARRIVAL " .. mcdu_format_force_to_small("TO").."         ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="          " .. subject_id, col=ECAM_GREEN, size=MCDU_LARGE}
    })

    -------------------------------------
    -- STATIC
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, " APPR", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "STAR ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_CENTER, 1, "VIA", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "TRANS ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "APPR   AVAILABLE", MCDU_SMALL)

    -------------------------------------
    -- DYNAMIC
    -------------------------------------
    THIS_PAGE:render_apprs(mcdu_data)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 602)
end

function THIS_PAGE:Slew_Down(mcdu_data)
    if THIS_PAGE.curr_page <= 1 then
        MCDU_Page:Slew_Down(mcdu_data)
    else
        THIS_PAGE.curr_page = THIS_PAGE.curr_page - 1
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    if math.floor(THIS_PAGE.apprs_length / 3) <= THIS_PAGE.curr_page then
        MCDU_Page:Slew_Up(mcdu_data)
    else
        THIS_PAGE.curr_page = THIS_PAGE.curr_page + 1
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
