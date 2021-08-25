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
    local start_i = mcdu_data.page_data[611].curr_page * 5 + 1  -- Current airways
    local end_i   = math.min(#mcdu_data.page_data[611].awys, start_i + 5) -- Current airways
    
    for i=start_i, end_i do
        self:set_line(mcdu_data, MCDU_LEFT, curr_displayed_line, " VIA", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, curr_displayed_line, mcdu_data.page_data[611].awys[i].id, MCDU_LARGE, ECAM_BLUE)

        self:set_line(mcdu_data, MCDU_RIGHT, curr_displayed_line, "TO ", MCDU_SMALL, ECAM_WHITE)
        if i < end_i then
            self:set_line(mcdu_data, MCDU_RIGHT, curr_displayed_line, mcdu_data.page_data[611].awys[i+1].begin_point, MCDU_LARGE, ECAM_BLUE)
        else
            self:set_line(mcdu_data, MCDU_RIGHT, curr_displayed_line, "[     ]", MCDU_LARGE, ECAM_BLUE)    
        end

        curr_displayed_line = curr_displayed_line + 1
        if curr_displayed_line >= 6 then
            break
        end
    end

    if curr_displayed_line >= 6 or mcdu_data.page_data[611].curr_page > 0 then
        self:set_updn_arrows_bottom(mcdu_data, true)
    end

    if curr_displayed_line < 6 then
        self:set_line(mcdu_data, MCDU_LEFT, curr_displayed_line, " VIA", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, curr_displayed_line, "[   ]", MCDU_LARGE, ECAM_BLUE)
    end

end

function THIS_PAGE:reset_page_data(mcdu_data)
    mcdu_data.page_data[611] = { awys={}, curr_page=0 }
end

function THIS_PAGE:render(mcdu_data)

    assert(mcdu_data.airways.source_wpt, "Provide me which navaid you want.")
    assert(mcdu_data.airways.return_page, "Provide me where to return")

    local source_name = mcdu_data.airways.source_wpt.id

    if not mcdu_data.page_data[611] then
        self:reset_page_data(mcdu_data)
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

local function reachable_from_awy_recursion(result_set, all_set, start_point, prev)
    for _,a in ipairs(all_set) do
        if a.start_wpt == start_point and a.end_wpt ~= prev then
            result_set[a.end_wpt] = true
            reachable_from_awy_recursion(result_set, all_set, a.end_wpt, start_point)
        end
    end
end

local function reachable_from_awy(all_points, start_point)
    local result_set = {}
    local result_set_expanded = {}
    reachable_from_awy_recursion(result_set, all_points, start_point, "FOR_SURE_NOT")

    for k,_ in pairs(result_set) do
        table.insert(result_set_expanded, k)
    end

    return result_set_expanded
end

local function build_awy_representation(all_points)

    local next = {} -- This is a map mapping each fix to the next
                    -- or nexts

    for i,x in ipairs(all_points) do
        if next[x.start_wpt] then
            table.insert(next[x.start_wpt], x.end_wpt)
        else
            next[x.start_wpt] = {x.end_wpt}
        end
    end

    return next
end

local function find_awy_path(awy_repr, prev_point, begin_point, end_point)
    if begin_point == end_point then
        return {end_point}
    end

    local to_explore = awy_repr[begin_point]

    if to_explore == nil then
        return nil
    end

    for _,p in ipairs(to_explore) do
        local path
        if p ~= prev_point then
            path = find_awy_path(awy_repr, begin_point, p, end_point)
        end
        if path ~= nil then
            table.insert(path, begin_point)
            return path
        end
    end

    return nil
end

local function table_reverse(t)
	local len = #t
	for i = len - 1, 1, -1 do
		t[len] = table.remove(t, i)
	end
end


function THIS_PAGE:add_airway(mcdu_data, id)
    id = id + mcdu_data.page_data[611].curr_page * 5
    if id > #mcdu_data.page_data[611].awys + 1 then
        MCDU_Page:L1(mcdu_data)
        return
    end

    if not(AvionicsBay.is_initialized() and AvionicsBay.is_ready()) then
        mcdu_send_message(mcdu_data, "AVIONICSBAY NOT READY")
        return
    end


    local input = mcdu_get_entry(mcdu_data)
    local awy_points
    if #input > 0 and #input < 6 then
        awy_points = AvionicsBay.awys.get_by_id(input)
    else
        mcdu_send_message(mcdu_data, "FORMAT ERROR")
        return
    end

    if #awy_points == 0 then
        mcdu_send_message(mcdu_data, "NOT IN DATABASE")
        return
    end

    -- Check if at least one point is the previous (or the LAT REV one)
    local intersection_point
    if id == 1 then
        for _,k in ipairs(awy_points) do
            if k.start_wpt == mcdu_data.airways.source_wpt.id then
                intersection_point = k.start_wpt
                break
            end
        end
    else
        -- Find intersection point
        local reachable_from_here = mcdu_data.page_data[611].awys[id-1].all_reachable_points
        for _,a in ipairs(reachable_from_here) do
            for _,b in ipairs(awy_points) do
                if a == b.start_wpt then
                    intersection_point = b.start_wpt
                    break
                end
            end
        end
    end

    if not intersection_point then
        mcdu_send_message(mcdu_data, "NO INTERSECTION FOUND")
        return
    else
        if not FMGS_does_temp_fpln_exist() then
            FMGS_create_copy_temp_fpln()
        end
        -- Get (and save) all the points in the airways reachable from the starting intersection point
        local reachable = reachable_from_awy(awy_points, intersection_point)
        table.insert(mcdu_data.page_data[611].awys, {id=input, begin_point=intersection_point, awy_points = awy_points, all_reachable_points=reachable})
    end

    mcdu_data.page_data[611].manual_to = nil

end


function THIS_PAGE:L1(mcdu_data)
    self:add_airway(mcdu_data, 1)
end

function THIS_PAGE:L2(mcdu_data)
    self:add_airway(mcdu_data, 2)
end

function THIS_PAGE:L3(mcdu_data)
    self:add_airway(mcdu_data, 3)
end

function THIS_PAGE:L4(mcdu_data)
    self:add_airway(mcdu_data, 4)
end

function THIS_PAGE:L5(mcdu_data)
    self:add_airway(mcdu_data, 5)
end

function THIS_PAGE:L6(mcdu_data)
    if FMGS_does_temp_fpln_exist() then
        FMGS_erase_temp_fpln()
    end
    self:reset_page_data(mcdu_data)
    mcdu_open_page(mcdu_data, mcdu_data.airways.return_page)
end

function THIS_PAGE:R6(mcdu_data)
    if not FMGS_does_temp_fpln_exist() then
        MCDU_Page:R6(mcdu_data)
        return
    end

    local full_path = {}

    for i,awy in ipairs(mcdu_data.page_data[611].awys) do

        local next_awy = mcdu_data.page_data[611].awys[i+1]
        if not next_awy and not mcdu_data.page_data[611].manual_to then
            break
        end

        local last_point = next_awy and next_awy.begin_point or mcdu_data.page_data[611].manual_to

        local awy_repr = build_awy_representation(awy.awy_points)
        local path = find_awy_path(awy_repr, "", mcdu_data.page_data[611].awys[i].begin_point, last_point)
        assert(path)

        table_reverse(path)

        for j,p in ipairs(path) do
            local last = full_path[#full_path]
            if last ~= p then
                table.insert(full_path, p)
            end
        end
    end

    for i,awy in ipairs(full_path) do
        print(awy)
    end

    self:reset_page_data(mcdu_data)
end


function THIS_PAGE:Slew_Down(mcdu_data)
    if mcdu_data.page_data[611].curr_page == 0 then
        mcdu_data.page_data[611].curr_page = math.ceil(#mcdu_data.page_data[611].awys/5) - 1
    else
        mcdu_data.page_data[611].curr_page = mcdu_data.page_data[611].curr_page - 1
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    local last_page = math.ceil(#mcdu_data.page_data[611].awys/5) - 1
    if mcdu_data.page_data[611].curr_page == last_page then
        mcdu_data.page_data[611].curr_page = 0
    else
        mcdu_data.page_data[611].curr_page = mcdu_data.page_data[611].curr_page + 1
    end
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
