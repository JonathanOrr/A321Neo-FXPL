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


local THIS_PAGE = MCDU_Page:new({id=606})


function THIS_PAGE:render_trans(mcdu_data)
    if not FMGS_arr_get_star(true) then
        return -- No runways or star selected
    end
    
    local trans_list = {}
    local fpln = mcdu_data.page_data[606].curr_fpln
    mcdu_data.page_data[606].trans_length = 0
    
    if not fpln.apts.arr_cifp then
        return  -- This should not happen
    end

    -- Extract the trans
    for i,x in ipairs(fpln.apts.arr_cifp.stars) do

        local rwy_match = x.proc_name == FMGS_arr_get_star(true).proc_name or x.proc_name == "ALL"
        if     x.type == CIFP_TYPE_STAR_ENR_TRANS
            or x.type == CIFP_TYPE_STAR_ENR_TRANS_RNAV
            or x.type == CIFP_TYPE_STAR_ENR_PROF_DESC
            or x.type == CIFP_TYPE_STAR_ENR_TRANS_FMS then

            if rwy_match then
                trans_list[x.trans_name] = i
                mcdu_data.page_data[606].trans_length = mcdu_data.page_data[606].trans_length + 1
            end
        end
    end

    -- If only one star exists, let's select it
    if mcdu_data.page_data[606].trans_length == 1 and not FMGS_arr_get_trans() and FMGS_does_temp_fpln_exist() then
        for k,idx in pairs(trans_list) do
            FMGS_arr_set_trans(mcdu_data.page_data[606].curr_fpln.apts.arr_cifp.stars[idx])
            break -- Well, actually only one is in the array
        end
    end

    mcdu_data.page_data[606].trans_references = {0,0,0}    -- These will contain the references for buttons

    local i = 0
    local n_line = 3
    local curr_page = mcdu_data.page_data[606].curr_page

    for k,idx in pairs(trans_list) do
        i = i + 1
        if i > 3 * (curr_page-1) and i <= 3 * (curr_page) then
            local arrow = (FMGS_arr_get_trans(true) and FMGS_arr_get_trans(true).trans_name == k) and " " or "→"
            self:set_line(mcdu_data, MCDU_RIGHT, n_line, k .. arrow, MCDU_LARGE, ECAM_BLUE)
            mcdu_data.page_data[606].trans_references[n_line-2] = idx    -- Let's same the array index so that we can use this for buttons
            n_line = n_line + 1
        end
    end

    if mcdu_data.page_data[606].trans_length > 3 then
        self:set_updn_arrows_bottom(mcdu_data, true)
    end

end

function THIS_PAGE:render_star(mcdu_data, sel_rwy, sibl)
    if not sel_rwy then
        return -- No approach selected
    end
    
    local fpln = mcdu_data.page_data[606].curr_fpln
    local star_list = {}
    mcdu_data.page_data[606].star_length = 0
    
    if not fpln.apts.arr_cifp then
        logWarning("ARR CIFP not available. This should not happen.")
        return  -- This should not happen
    end

    local rwid = "RW" .. (sibl and sel_rwy.sibl_name or sel_rwy.name)
    local rwid_both = rwid:sub(1,-2) .. "B" -- B stands for L, R, and C. If the runway doesn't have it, it doesn't matter, cannot match

    -- Extract the stars
    for i,x in ipairs(fpln.apts.arr_cifp.stars) do
    
        local rwy_match = x.trans_name == rwid or x.trans_name == rwid_both or x.trans_name == "ALL"

        if     x.type == CIFP_TYPE_STAR_RWY_TRANS
            or x.type == CIFP_TYPE_STAR_CMN_ROUTE
            or x.type == CIFP_TYPE_STAR_RWY_TRANS_RNAV
            or x.type == CIFP_TYPE_STAR_CMN_ROUTE_RNAV
            or x.type == CIFP_TYPE_STAR_RWY_PROF_DESC
            or x.type == CIFP_TYPE_STAR_CMN_PROF_DESC
            or x.type == CIFP_TYPE_STAR_RWY_TRANS_FMS
            or x.type == CIFP_TYPE_STAR_CMN_ROUTE_FMS then
    
            if rwy_match then
                star_list[x.proc_name] = i
                mcdu_data.page_data[606].star_length = mcdu_data.page_data[606].star_length + 1
            end
        end
    end

    mcdu_data.page_data[606].star_references = {0,0,0}    -- These will contain the references for buttons

    local i = 0
    local n_line = 3
    local curr_page = mcdu_data.page_data[606].curr_page
    for k,idx in pairs(star_list) do
        i = i + 1
        if i > 3 * (curr_page-1) and i <= 3 * (curr_page) then
            local arrow = (FMGS_arr_get_star(true) and FMGS_arr_get_star(true).proc_name == k) and " " or "←"
            self:set_line(mcdu_data, MCDU_LEFT, n_line, arrow .. k, MCDU_LARGE, ECAM_BLUE)
            mcdu_data.page_data[606].star_references[n_line-2] = idx    -- Let's same the array index so that we can use this for buttons
            n_line = n_line + 1
        end
    end

    if mcdu_data.page_data[606].star_length > 3 then
        self:set_updn_arrows_bottom(mcdu_data, true)
    end
end

function THIS_PAGE:render(mcdu_data)
    assert(mcdu_data.lat_rev_subject and mcdu_data.lat_rev_subject.type == 4)

    if not mcdu_data.page_data[606] then
        mcdu_data.page_data[606] = {}
        mcdu_data.page_data[606].star_references = {0,0,0}
        mcdu_data.page_data[606].trans_references = {0,0,0}
        mcdu_data.page_data[606].curr_page = 1
    end

    mcdu_data.page_data[606].main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN
    mcdu_data.page_data[606].curr_fpln = FMGS_get_current_fpln()

    self:set_lr_arrows(mcdu_data, true)
    self:set_updn_arrows_bottom(mcdu_data, false)   -- Will be changed later in the code

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
    self:set_line(mcdu_data, MCDU_LEFT, 3, "STARS  AVAILABLE   TRANS", MCDU_SMALL)

    if FMGS_does_temp_fpln_exist() then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)
    end

    -------------------------------------
    -- DYNAMIC
    -------------------------------------
    self:render_top_data(mcdu_data)

    local rwy, sibl = FMGS_arr_get_rwy(true)
    if rwy then
        self:render_star(mcdu_data, rwy, sibl)
        self:render_trans(mcdu_data)
    end

    if FMGS_arr_get_star(true) and #FMGS_arr_get_available_vias(true) > 1 then
        self:set_line(mcdu_data, MCDU_LEFT, 2, " APPR", MCDU_SMALL)
        self:set_line(mcdu_data, MCDU_LEFT, 2, "<VIAS", MCDU_LARGE)
    end
end

function THIS_PAGE:render_top_data(mcdu_data)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    local appr_name  = dest_get_selected_appr_procedure()
    local star_name  = FMGS_arr_get_star(true) and FMGS_arr_get_star(true).proc_name or nil
    local via_name   = FMGS_arr_get_via(true) and FMGS_arr_get_via(true).trans_name or nil
    if FMGS_arr_get_star(true) and via_name == nil and #FMGS_arr_get_available_vias(true) <= 1 then
        via_name = "NONE"
    end
    local trans_name = FMGS_arr_get_trans(true) and FMGS_arr_get_trans(true).trans_name or nil
    self:set_line(mcdu_data, MCDU_LEFT,  1, appr_name and appr_name or "------", MCDU_LARGE, appr_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, star_name and star_name or "------", MCDU_LARGE, star_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER,1, via_name and " " .. via_name or " ------", MCDU_LARGE, via_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, trans_name and trans_name or "------", MCDU_LARGE,  trans_name and main_col or ECAM_WHITE)

end

function THIS_PAGE:L2(mcdu_data)
    if #FMGS_arr_get_available_vias(true) > 1 then
        mcdu_open_page(mcdu_data, 607)
    else
        MCDU_Page:L2(mcdu_data) -- Error
    end
end

function THIS_PAGE:sel_star(mcdu_data, i)
    
   
    if mcdu_data.page_data[606].star_references[i] > 0 then
        if not FMGS_does_temp_fpln_exist() then
            FMGS_create_copy_temp_fpln()
        end
    
        FMGS_arr_set_star(mcdu_data.page_data[606].curr_fpln.apts.arr_cifp.stars[mcdu_data.page_data[606].star_references[i]])
        FMGS_reset_arr_via()
        FMGS_reset_arr_trans()

        local available_vias = FMGS_arr_get_available_vias(true)
        if #available_vias == 2 then
            FMGS_arr_set_via(available_vias[2])
        end

        mcdu_data.page_data[606].curr_page = 1
    else
        MCDU_Page:L2(mcdu_data) -- Error
    end
    
end

function THIS_PAGE:L3(mcdu_data)
    THIS_PAGE:sel_star(mcdu_data, 1)
end
function THIS_PAGE:L4(mcdu_data)
    THIS_PAGE:sel_star(mcdu_data, 2)
end
function THIS_PAGE:L5(mcdu_data)
    THIS_PAGE:sel_star(mcdu_data, 3)
end


function THIS_PAGE:sel_trans(mcdu_data, i)

    if mcdu_data.page_data[606].trans_references[i] > 0 then
        if not FMGS_does_temp_fpln_exist() then
            FMGS_create_copy_temp_fpln()
        end
        FMGS_arr_set_trans(mcdu_data.page_data[606].curr_fpln.apts.arr_cifp.stars[mcdu_data.page_data[606].trans_references[i]])
    else
        MCDU_Page:R2(mcdu_data) -- Error
    end
end

function THIS_PAGE:R3(mcdu_data)
    THIS_PAGE:sel_trans(mcdu_data, 1)
end
function THIS_PAGE:R4(mcdu_data)
    THIS_PAGE:sel_trans(mcdu_data, 2)
end
function THIS_PAGE:R5(mcdu_data)
    THIS_PAGE:sel_trans(mcdu_data, 3)
end


function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 605)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 605)
end

function THIS_PAGE:L6(mcdu_data)
    FMGS_erase_temp_fpln()
    mcdu_open_page(mcdu_data, 600)
end

function THIS_PAGE:R6(mcdu_data)
    FMGS_reshape_fpln()
    FMGS_insert_temp_fpln()
    mcdu_open_page(mcdu_data, 600)
end

function THIS_PAGE:Slew_Down(mcdu_data)
    local pd_data = mcdu_data.page_data[606]

    if pd_data.curr_page <= 1 then
        MCDU_Page:Slew_Down(mcdu_data)
    else
        pd_data.curr_page = pd_data.curr_page - 1
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    local pd_data = mcdu_data.page_data[606]
    if math.floor(pd_data.star_length / 3) <= pd_data.curr_page then
        MCDU_Page:Slew_Up(mcdu_data)
    else
        pd_data.curr_page = pd_data.curr_page + 1
    end
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
