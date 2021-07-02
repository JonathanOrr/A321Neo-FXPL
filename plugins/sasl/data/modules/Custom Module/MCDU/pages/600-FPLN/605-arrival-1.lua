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

local function extract_rwy_name(rwy_name_with_suffix)

    local rwy_name = rwy_name_with_suffix:sub(1,2)

    if rwy_name_with_suffix:sub(3,3) == "L" then
        rwy_name = rwy_name .. "L"
    elseif rwy_name_with_suffix:sub(3,3) == "R" then
        rwy_name = rwy_name .. "R"
    elseif rwy_name_with_suffix:sub(3,3) == "C" then
        rwy_name = rwy_name .. "C"
    end

    return rwy_name
end

function THIS_PAGE:get_runway_info(rwy_name)
    local rwy_info, ils_info, rwy_obj, rwy_sibl

    for k,x in ipairs(THIS_PAGE.curr_fpln.apts.arr.rwys) do
        if x.name == rwy_name then
            rwy_info = {math.floor(x.distance), math.floor(x.bearing)}
            rwy_obj = x
            rwy_sibl = false
            break
        end
        if x.sibl_name == rwy_name then
            rwy_info = {math.floor(x.distance), math.floor(x.bearing+180)%360}
            rwy_obj = x
            rwy_sibl = true
            break
        end
    end

    for k,x in ipairs(THIS_PAGE.curr_fpln.apts.arr_cifp.rwys) do
        if x.name == rwy_name then

            local nav_aid  = AvionicsBay.navaids.get_by_name(NAV_ID_LOC, x.loc_ident, false)
            local nav_aid2 = AvionicsBay.navaids.get_by_name(NAV_ID_LOC_ALONE, x.loc_ident, false)

            local freq = #nav_aid > 0 and nav_aid[1].freq or (#nav_aid2 > 0 and nav_aid2[1].freq or nil)
            freq = freq and Round_fill(freq / 100, 2)

            ils_info = {x.loc_ident, freq}
            break
        end
    end

    return rwy_info, ils_info, rwy_obj, rwy_sibl
end

function THIS_PAGE:render_apprs(mcdu_data)
    if not THIS_PAGE.curr_fpln.apts.arr_cifp then
        return  -- This should not happen
    end
    
    local apprs_list = {}
    THIS_PAGE.apprs_length = 0
    
    for i=1,20 do
        apprs_list[i] = {}
    end

    for i,x in ipairs(THIS_PAGE.curr_fpln.apts.arr_cifp.apprs) do
        local type_idx, type_str = appr_type_char_to_idx(x.type)
        if type_idx ~= nil then
            local rwy_name_with_suffix = x.proc_name:sub(2)
            local rwy_name = extract_rwy_name(rwy_name_with_suffix)
            local rwy_info, ils_info, rwy_obj, rwy_sibl = self:get_runway_info(rwy_name)
            table.insert(apprs_list[type_idx], {name=rwy_name_with_suffix, idx=i, prefix=type_str, rwy_info=rwy_info, ils_info=ils_info, rwy_obj=rwy_obj, rwy_sibl=rwy_sibl})
            THIS_PAGE.apprs_length = THIS_PAGE.apprs_length + 1
        end
    end
    
    mcdu_data.page_data[605].apprs_references = {nil,nil,nil}    -- These will contain the references for buttons

    local i = 0
    local n_line = 3
    for _,data_content in ipairs(apprs_list) do
        for _,data in pairs(data_content) do
            i = i + 1
            if i > 3 * (THIS_PAGE.curr_page-1) and i <= 3 * (THIS_PAGE.curr_page) then
                local full_name = data.prefix .. data.name
                local select_appr_name = dest_get_selected_appr_procedure()
                local arrow = (select_appr_name and select_appr_name == full_name) and " " or "←"
                local top_line = Aft_string_fill(arrow .. full_name, " ", 11) .. (data.rwy_info and data.rwy_info[1] .. mcdu_format_force_to_small("M") or "")
                local bottom_line = "   " .. Aft_string_fill(data.rwy_info and Fwd_string_fill(""..data.rwy_info[2], "0", 3) or "", " ", 5)
                if data.ils_info then
                    bottom_line = bottom_line .. (data.ils_info[1] and data.ils_info[1] or "") .. (data.ils_info[2] and "/".. data.ils_info[2] or "")
                end
                
                self:set_line(mcdu_data, MCDU_LEFT, n_line, top_line, MCDU_LARGE, ECAM_BLUE)
                self:set_line(mcdu_data, MCDU_LEFT, n_line+1, bottom_line, MCDU_SMALL, ECAM_BLUE)
                mcdu_data.page_data[605].apprs_references[n_line-2] = data    -- Let's same the array index so that we can use this for buttons
                n_line = n_line + 1
            end
        end
    end

    mcdu_data.page_data[605].apprs_list = apprs_list
end

function THIS_PAGE:render_top_data(mcdu_data)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    local appr_name = dest_get_selected_appr_procedure()
    local star_name = FMGS_arr_get_star(true) and FMGS_arr_get_star(true).proc_name or nil
    self:set_line(mcdu_data, MCDU_LEFT,  1, appr_name and appr_name or "------", MCDU_LARGE, appr_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, star_name and star_name or "------", MCDU_LARGE, star_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER,1, " ------", MCDU_LARGE, main_col)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "------", MCDU_LARGE,  main_col)

end

function THIS_PAGE:render(mcdu_data)

    if not mcdu_data.page_data[605] then
        mcdu_data.page_data[605] = {}
    end

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
    THIS_PAGE:render_top_data(mcdu_data)
    THIS_PAGE:render_apprs(mcdu_data)
end

function THIS_PAGE:sel_appr(mcdu_data, i)
   
    local data = mcdu_data.page_data[605].apprs_references[i]

    if not data then
        MCDU_Page:Slew_Down(mcdu_data)  -- Clicked on empty spot
        return
    end

    FMGS_create_temp_fpln()
    FMGS_arr_set_appr(THIS_PAGE.curr_fpln.apts.arr_cifp.apprs[data.idx], data.rwy_obj, data.rwy_sibl)
    mcdu_open_page(mcdu_data, 606)
end

function THIS_PAGE:L3(mcdu_data)
    THIS_PAGE:sel_appr(mcdu_data, 1)
end
function THIS_PAGE:L4(mcdu_data)
    THIS_PAGE:sel_appr(mcdu_data, 2)
end
function THIS_PAGE:L5(mcdu_data)
    THIS_PAGE:sel_appr(mcdu_data, 3)
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

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 606)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 606)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
