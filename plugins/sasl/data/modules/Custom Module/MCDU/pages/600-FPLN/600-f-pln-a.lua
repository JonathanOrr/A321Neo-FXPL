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


local THIS_PAGE = MCDU_Page:new({id=600})


-------------------------------------------------------------------------------
-- DEPARTURE
-------------------------------------------------------------------------------
function THIS_PAGE:render_dep(mcdu_data)
    local arpt_id    = mcdu_data.page_data[600].curr_fpln.apts.dep.id
    local arpt_alt   = mcdu_data.page_data[600].curr_fpln.apts.dep.alt

    THIS_PAGE:render_single(mcdu_data, 1, arpt_id, "0000", FMGS_perf_get_v_speeds(), tostring(arpt_alt), nil, "", nil, nil, nil, true)
end

-------------------------------------------------------------------------------
-- ARRIVAL
-------------------------------------------------------------------------------
function THIS_PAGE:render_dest(mcdu_data)
    self:set_line(mcdu_data, MCDU_LEFT, 6, " DEST   TIME", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "DIST  EFOB", MCDU_SMALL)

    local arr_id    = mcdu_data.page_data[600].curr_fpln.apts.arr.id
    if mcdu_data.page_data[600].curr_fpln.apts.arr_rwy then
        local rwy, sibl = FMGS_arr_get_rwy(false)
        arr_id = arr_id .. (sibl and rwy.sibl_name or rwy.name)
    end
    local trip_time = mcdu_time_beautify(FMGS_perf_get_pred_trip_time())
    self:set_line(mcdu_data, MCDU_LEFT, 6, Aft_string_fill(arr_id, " ", 8).. trip_time, MCDU_LARGE)

    local trip_dist_num = FMGS_perf_get_pred_trip_dist()
    local trip_dist = trip_dist_num and math.ceil(trip_dist_num) or "----"
    local efob = FMGS_perf_get_pred_trip_efob() and Round_fill(FMGS_perf_get_pred_trip_efob(), 1) or "----"
    self:set_line(mcdu_data, MCDU_RIGHT, 6, trip_dist .. Fwd_string_fill(efob, " ", 6), MCDU_LARGE)

end

local function render_altitude(x)
    if not x then
        return "-----"
    end

    if x > FMGS_perf_get_current_trans_alt() then
        return "FL" .. Fwd_string_fill(tostring(math.ceil(x/100)), "0", 3)
    else
        return tostring(math.ceil(x))
    end
end

-------------------------------------------------------------------------------
-- COMMON
-------------------------------------------------------------------------------
function THIS_PAGE:render_single(mcdu_data, i, id, time, spd, alt, alt_col, proc_name, bearing, is_trk, distance, is_arpt, is_the_first)
    local main_col = is_the_first and ECAM_WHITE or (FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN)

    time = is_arpt and time or mcdu_format_force_to_small(time) -- TIME is small only for airports

    local left_side  = Aft_string_fill(id, " ", 8) 
    local ctr_side   = (spd and spd or "---")
    local right_side = "/" .. Fwd_string_fill(alt or "", " ", 6)
    if not is_arpt then
        left_side  = left_side .. mcdu_format_force_to_small(time)
        ctr_side   = mcdu_format_force_to_small(ctr_side)
        right_side = mcdu_format_force_to_small(right_side)
    else
        left_side  = left_side .. time
    end

    self:set_line(mcdu_data, MCDU_LEFT, i, left_side, MCDU_LARGE, main_col)
    self:set_line(mcdu_data, MCDU_CENTER, i, "       " .. ctr_side, MCDU_LARGE, spd and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, i, right_side, MCDU_LARGE, alt_col or main_col)
    
    if i ~= 1 then
        local brg_trk = is_trk ~= nil and ((is_trk and "TRK" or "BRG") .. Fwd_string_fill(tostring(math.floor(bearing)), "0", 3) .. "°") or "    "

        local dist_text=""
        if distance ~= nil then
            dist_text = Round(distance, 0) .. (i == 2 and "NM" or "  ")
        end
        dist_text = Fwd_string_fill(dist_text, " ", 6) .. "   "
        self:set_line(mcdu_data, MCDU_LEFT, i, " " .. proc_name, MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, i, brg_trk .. "  " .. dist_text, MCDU_SMALL, (i == 2 and mcdu_data.page_data[600].curr_idx == 1) and ECAM_WHITE or main_col)
    end
    
end

function THIS_PAGE:render_discontinuity(mcdu_data, i)
    self:set_line(mcdu_data, MCDU_LEFT, i, "---F-PLN DISCONTINUITY--" , MCDU_LARGE)
end

-------------------------------------------------------------------------------
-- Prepare list
-------------------------------------------------------------------------------
function THIS_PAGE:prepare_list_departure(mcdu_data, list_messages)
    if mcdu_data.page_data[600].curr_fpln.apts.dep_sid then
        for i,x in ipairs(mcdu_data.page_data[600].curr_fpln.apts.dep_sid.legs) do
            x.ref_id = i
            x.point_type = POINT_TYPE_DEP_SID
            table.insert(list_messages, x)
        end
    end
    if mcdu_data.page_data[600].curr_fpln.apts.dep_trans then
        for i,x in ipairs(mcdu_data.page_data[600].curr_fpln.apts.dep_trans.legs) do
            x.ref_id = i
            x.point_type = POINT_TYPE_DEP_TRANS
            table.insert(list_messages, x)
        end
    end
end

function THIS_PAGE:prepare_list_arrival(mcdu_data, list_messages)
    local fpln = mcdu_data.page_data[600].curr_fpln
    if fpln.apts.arr_trans then
        for i,x in ipairs(fpln.apts.arr_trans.legs) do
            x.ref_id = i
            x.point_type = POINT_TYPE_ARR_TRANS
            table.insert(list_messages, x)
        end
    end

    local is_via_valid = fpln.apts.arr_via and not fpln.apts.arr_via.novia and fpln.apts.arr_via.legs and fpln.apts.arr_via.legs[1]

    if fpln.apts.arr_star then
        for i,x in ipairs(fpln.apts.arr_star.legs) do
            if is_via_valid and x.leg_name == fpln.apts.arr_via.legs[1].leg_name then
                break
            end
            x.ref_id = i
            x.point_type = POINT_TYPE_ARR_STAR
            table.insert(list_messages, x)
        end
    end

    if is_via_valid then
        for i,x in ipairs(fpln.apts.arr_via.legs) do
            x.ref_id = i
            x.point_type = POINT_TYPE_ARR_VIA
            table.insert(list_messages, x)
        end
    end

    if fpln.apts.arr_appr then
        for i,x in ipairs(fpln.apts.arr_appr.legs) do
            x.ref_id = i
            x.point_type = POINT_TYPE_ARR_APPR
            table.insert(list_messages, x)
        end
    end

end

function THIS_PAGE:prepare_list(mcdu_data)
    local list_messages = {
        {invalid=true} -- First one is always empty (it represents the departure airport)
    }

    THIS_PAGE:prepare_list_departure(mcdu_data, list_messages)

    if mcdu_data.page_data[600].curr_fpln.legs then
        for i,x in ipairs(mcdu_data.page_data[600].curr_fpln.legs) do
            x.ref_id = i
            x.point_type = POINT_TYPE_LEG
            table.insert(list_messages, x)
        end
    end

    THIS_PAGE:prepare_list_arrival(mcdu_data, list_messages)

    return list_messages
end
-------------------------------------------------------------------------------
-- Render list
-------------------------------------------------------------------------------
local function get_proc_name(mcdu_data,obj)
    if obj.point_type == POINT_TYPE_DEP_SID then
        return mcdu_data.page_data[600].curr_fpln.apts.dep_sid.proc_name
    elseif obj.point_type == POINT_TYPE_DEP_TRANS then
        return mcdu_data.page_data[600].curr_fpln.apts.dep_trans.proc_name
    elseif obj.point_type == POINT_TYPE_ARR_APPR then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_appr.proc_name
    elseif obj.point_type == POINT_TYPE_ARR_TRANS then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_trans.proc_name
    elseif obj.point_type == POINT_TYPE_ARR_VIA then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_via.proc_name
    elseif obj.point_type == POINT_TYPE_ARR_STAR then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_star.proc_name
    end
    return ""         
end

local function get_spd_alt_cstr(x)
    local alt_cstr, alt_cstr_col = cifp_convert_alt_cstr(x)
    local spd_cstr = ""
    if x.cstr_speed_type and x.cstr_speed_type ~= CIFP_CSTR_SPD_NONE then
        spd_cstr = tostring(x.cstr_speed)
    end

    if x.pred and x.pred.ias then
        spd_cstr = tostring(math.ceil(x.pred.ias))
        if x.pred.cms_segment then
            spd_cstr = "." .. math.ceil(x.pred.mach*100)
        end
    end
    
    if x.pred and x.pred.altitude then
        alt_cstr = render_altitude(x.pred.altitude)
        alt_cstr_col = nil -- Default one
    end

    return spd_cstr, alt_cstr, alt_cstr_col
end

function THIS_PAGE:render_list(mcdu_data)

    local list_messages = THIS_PAGE:prepare_list(mcdu_data)
    local last_spd_cstr_value = nil

    for i,x in ipairs(list_messages) do

        if x.discontinuity then
            self:add_f(mcdu_data, function(line_id)
                THIS_PAGE:render_discontinuity(mcdu_data, line_id)
            end, x)
            last_spd_cstr_value = nil
        elseif x.point_type == nil then
             -- NOP -- This is normal: in some cases we add a non existent line
                    -- to the array (see prepare_list)
            last_spd_cstr_value = nil
        elseif x.point_type ~= POINT_TYPE_LEG then
            local name, proc = cifp_convert_leg_name(x)
            x.id = name -- This is necessary for the LAT REV page

            if #proc == 0 then
                proc = get_proc_name(mcdu_data,x)
            end

            local spd_cstr, alt_cstr, alt_cstr_col = get_spd_alt_cstr(x)
            
            if spd_cstr == "" then
                last_spd_cstr_value = nil
            elseif last_spd_cstr_value == spd_cstr then
                spd_cstr = "\""
            else
                last_spd_cstr_value = spd_cstr
            end

            local distance = x.computed_distance
            local time = x.pred and x.pred.time and mcdu_time_beautify(x.pred.time) or "----"
            self:add_f(mcdu_data, function(line_id)
                THIS_PAGE:render_single(mcdu_data, line_id, name, time, spd_cstr, alt_cstr, alt_cstr_col, proc, nil, nil, distance, false, i == 2)
            end, x)
        else
            local distance = x.computed_distance
            local proc = x.airway_name or ""
            local spd_cstr, alt_cstr, alt_cstr_col = get_spd_alt_cstr(x)
            
            if spd_cstr == "" then
                last_spd_cstr_value = nil
            elseif last_spd_cstr_value == spd_cstr then
                spd_cstr = "\""
            else
                last_spd_cstr_value = spd_cstr
            end

            local name = x.id or "(MAN)"
            self:add_f(mcdu_data, function(line_id)
                local time = x.pred and mcdu_time_beautify(x.pred.time) or "----"
                THIS_PAGE:render_single(mcdu_data, line_id, name, time, spd_cstr, alt_cstr, alt_cstr_col, proc, nil, nil, distance, false, false)
            end, x)
        end
    end

    local arr_rwy_valid = mcdu_data.page_data[600].curr_fpln.apts.arr_rwy and mcdu_data.page_data[600].curr_fpln.apts.arr_rwy[1]
    self:print_simple_airport(mcdu_data,
                              mcdu_data.page_data[600].curr_fpln.apts.arr,
                              mcdu_data.page_data[600].curr_fpln.apts.arr,
                              arr_rwy_valid and mcdu_data.page_data[600].curr_fpln.apts.arr_rwy[1].last_distance,
                              FMGS_perf_get_pred_trip_time(),
                              ECAM_GREEN)

    self:add_f(mcdu_data, function(line_id)
        self:set_line(mcdu_data, MCDU_LEFT, line_id, "------END OF F-PLN------", MCDU_LARGE)
    end)
    THIS_PAGE:render_list_altn(mcdu_data)
end

function THIS_PAGE:print_simple_airport(mcdu_data, apt, apt_obj, distance, trip_time, color)
    -- APT Obj represents the object we want to save for lateral revision
    -- it should be nil, for instance, for the line with the arrival airport in the
    -- altn fpln.
    local arr_id    = apt.id
    local arr_alt   = apt.alt
    trip_time = trip_time or "----"

    local left_side  = arr_id
    local ctr_side   = mcdu_format_force_to_small(" " .. mcdu_time_beautify(trip_time) .. "  ---")
    local right_side = mcdu_format_force_to_small("/" .. Fwd_string_fill(tostring(arr_alt)," ", 6))

    local dist_text=""
    if distance ~= nil then
        dist_text = Round(distance, 0) .. "  "
    end
    dist_text = Fwd_string_fill(dist_text, " ", 6) .. "   "


    self:add_f(mcdu_data, function(line_id)
        self:set_line(mcdu_data, MCDU_LEFT,   line_id, left_side, MCDU_LARGE, color)
        self:set_line(mcdu_data, MCDU_CENTER, line_id, ctr_side, MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT,  line_id, right_side, MCDU_LARGE, color)
        self:set_line(mcdu_data, MCDU_RIGHT,  line_id, dist_text, MCDU_SMALL, color)
    end, apt_obj)
end

function THIS_PAGE:render_list_altn(mcdu_data, last_i, end_i)
    mcdu_data.page_data[600].page_end = false

    if FMGS_get_apt_alt() == nil then
        self:add_f(mcdu_data, function(line_id)
            self:set_line(mcdu_data, MCDU_LEFT, line_id, "-----NO ALTN F-PLN------", MCDU_LARGE)
        end)
        return
    end

    -- Arrival aiport
    THIS_PAGE:print_simple_airport(mcdu_data, mcdu_data.page_data[600].curr_fpln.apts.arr, nil, nil, FMGS_perf_get_pred_trip_time(), ECAM_BLUE)

    -- TODO: ALTN route
    self:add_f(mcdu_data, function(line_id)
        self:set_line(mcdu_data, MCDU_LEFT, line_id, "---F-PLN DISCONTINUITY--" , MCDU_LARGE)
    end)

    -- ALTN aiport
    THIS_PAGE:print_simple_airport(mcdu_data, mcdu_data.page_data[600].curr_fpln.apts.alt, nil, nil, nil, ECAM_BLUE) -- TODO Trip time

    self:add_f(mcdu_data, function(line_id)
        self:set_line(mcdu_data, MCDU_LEFT, line_id, "---END OF ALTN F-PLN----", MCDU_LARGE)
    end)
 
    mcdu_data.page_data[600].page_end = true
end


function THIS_PAGE:add_f(mcdu_data, func, ref_object)
    table.insert(mcdu_data.page_data[600].render_functions, {func, ref_object})
end

function THIS_PAGE:print_render_list(mcdu_data)

    if mcdu_data.page_data[600].goto_last then
        mcdu_data.page_data[600].goto_last = false
        mcdu_data.page_data[600].curr_idx = math.max(1, #mcdu_data.page_data[600].render_functions-3)
    end

    local start_i = math.max(1, mcdu_data.page_data[600].curr_idx - 1)
    local line_id = mcdu_data.page_data[600].curr_idx == 1 and 2 or 1
    local end_i = mcdu_data.page_data[600].curr_idx + 5

    local breaked = false
    mcdu_data.page_data[600].ref_lines = {}
    for i,x in ipairs(mcdu_data.page_data[600].render_functions) do
        if i >= start_i then
            if i <= end_i and line_id <= 5 then
                x[1](line_id)
                mcdu_data.page_data[600].ref_lines[line_id] = x[2]
                line_id = line_id + 1
            else
                breaked = true
                break
            end
        end
    end

    mcdu_data.page_data[600].page_end = not breaked

end

-------------------------------------------------------------------------------
-- Directly add a new waypoint after coming back from 610
-------------------------------------------------------------------------------
function THIS_PAGE:add_new_wpt(mcdu_data)

    local obj_clicked = mcdu_data.page_data[600].in_direct_add
    -- How to add it depends on the type of navaid of the lateral revision
    if obj_clicked.point_type == POINT_TYPE_LEG then
        local sel_navaid = mcdu_data.dup_names.selected_navaid
        local sel_navaid_type = avionics_bay_generic_wpt_to_fmgs_type(sel_navaid)
        local leg = {
                    ptr_type = sel_navaid_type,
                    id=sel_navaid.id,
                    lat=sel_navaid.lat,
                    lon=sel_navaid.lon,
                    navaid_type = sel_navaid.navaid_type    -- VOR, LOC, etc. nil if WPT or APT
                }
        if not FMGS_does_temp_fpln_exist() then
            FMGS_create_copy_temp_fpln()
        end
        FMGS_fpln_temp_leg_add(leg, obj_clicked.ref_id)
        FMGS_reshape_fpln(true)
        FMGS_insert_temp_fpln()
    else
        mcdu_send_message(mcdu_data, "NOT YET IMPLEMENTED")
    end

end


-------------------------------------------------------------------------------
-- MAIN render() function
-------------------------------------------------------------------------------


function THIS_PAGE:render(mcdu_data)

    if not mcdu_data.page_data[600] or mcdu_data.is_page_button_hit then
        mcdu_data.page_data[600] = {}
        mcdu_data.page_data[600].curr_idx  = 1
        mcdu_data.page_data[600].page_end = false
        mcdu_data.page_data[600].goto_last = false
        mcdu_data.is_page_button_hit = false
    end
    mcdu_data.page_data[600].render_functions = {}

    mcdu_data.page_data[600].curr_fpln = FMGS_get_current_fpln()

    if mcdu_data.page_data[600].in_direct_add then
        -- If we are here, we added a direct waypoint to the F/PLN, and we 
        -- are coming back from the 610 page
        if not mcdu_data.dup_names.not_found and mcdu_data.dup_names.selected_navaid then
            -- If we are here, then we have a valid waypoint to add as "next wpt"
            self:add_new_wpt(mcdu_data)
        end
        mcdu_data.page_data[600].in_direct_add = nil
    end

    local from_ppos = mcdu_data.page_data[600].curr_idx == 1 and (mcdu_data.page_data[600].curr_fpln.apts.dep and "FROM" or "PPOS") or ""
    
    self:set_multi_title(mcdu_data, {
        {txt=Aft_string_fill(from_ppos, " ", 22), col=ECAM_WHITE, size=MCDU_SMALL},
        {txt=Aft_string_fill(mcdu_data.page_data[600].curr_fpln == FMGS_does_temp_fpln_exist() and "TMPY" or "", " ", 12), col=ECAM_YELLOW, size=MCDU_LARGE},
        {txt=Fwd_string_fill(FMGS_init_get_flt_nbr() and FMGS_init_get_flt_nbr() or "", " ", 20) .. "  ", col=ECAM_WHITE, size=MCDU_SMALL}
    })

    self:set_lr_arrows(mcdu_data, true)

    if mcdu_data.page_data[600].curr_fpln.apts.dep == nil or mcdu_data.page_data[600].curr_fpln.apts.arr == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "------END OF F-PLN------", MCDU_LARGE)
        return
    end

    THIS_PAGE:render_list(mcdu_data)
    THIS_PAGE:print_render_list(mcdu_data)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "TIME  SPD/ALT   ", MCDU_SMALL)

    if mcdu_data.page_data[600].curr_idx == 1 then
        THIS_PAGE:render_dep(mcdu_data)
    end

    if not FMGS_does_temp_fpln_exist() then
        THIS_PAGE:render_dest(mcdu_data)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)
    end

end

-------------------------------------------------------------------------------
-- ACTIONS
-------------------------------------------------------------------------------

local function point_get_table(mcdu_data, obj_type) 

    if obj_type == POINT_TYPE_DEP_SID then
        return mcdu_data.page_data[600].curr_fpln.apts.dep_sid.legs
    elseif obj_type == POINT_TYPE_DEP_TRANS then
        return mcdu_data.page_data[600].curr_fpln.apts.dep_trans.legs
    elseif obj_type == POINT_TYPE_LEG then
        return mcdu_data.page_data[600].curr_fpln.legs
    elseif obj_type == POINT_TYPE_ARR_TRANS then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_trans.legs
    elseif obj_type == POINT_TYPE_ARR_STAR then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_star.legs
    elseif obj_type == POINT_TYPE_ARR_VIA then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_via.legs
    elseif obj_type == POINT_TYPE_ARR_APPR then
        return mcdu_data.page_data[600].curr_fpln.apts.arr_appr.legs
    end

    assert(false)   -- This should not happen
end

local function add_direct_waypoint(mcdu_data, x)
    local input = mcdu_get_entry(mcdu_data)
    if #input > 0 and #input < 6 then
        mcdu_data.dup_names.req_text = input
        mcdu_data.dup_names.return_page = 600
        mcdu_data.page_data[600].waiting_next_wpt = true
        mcdu_data.page_data[600].in_direct_add = x
        mcdu_open_page(mcdu_data, 610)
    else
        mcdu_send_message(mcdu_data, "FORMAT ERROR")
    end

end

local function trigger_lat_rev_apt_dest(mcdu_data)
    mcdu_data.lat_rev_subject = {}
    mcdu_data.lat_rev_subject.type = 4 -- DEST
    mcdu_data.lat_rev_subject.data = mcdu_data.page_data[600].curr_fpln.apts.arr
    mcdu_open_page(mcdu_data, 602)
end

local function trigger_lat_rev(mcdu_data, id)
    if mcdu_data.page_data[600].ref_lines and mcdu_data.page_data[600].ref_lines[id] then

        local obj = mcdu_data.page_data[600].ref_lines[id]

        if obj.invalid then
            return false
        end

        if mcdu_data.page_data[600].curr_fpln.apts.arr and obj.id == mcdu_data.page_data[600].curr_fpln.apts.arr.id then
            trigger_lat_rev_apt_dest(mcdu_data)
            return true
        end

        if mcdu_data.clr then   -- A clear is requested
            local table_obj = point_get_table(mcdu_data, obj.point_type)
            table.remove(table_obj, obj.ref_id)
            FMGS_reshape_fpln(true)

        elseif #mcdu_data.entry.text > 0 then
            add_direct_waypoint(mcdu_data, obj)
        else
            mcdu_data.lat_rev_subject = {}
            mcdu_data.lat_rev_subject.type = 2 -- WPT
            mcdu_data.lat_rev_subject.data = obj
            mcdu_data.lat_rev_subject.is_cifp = obj.leg_type ~= nil
            mcdu_open_page(mcdu_data, 602)
        end
        return true
    end
    return false
end

local function trigger_vert_rev(mcdu_data, id)
    if mcdu_data.page_data[600].ref_lines and mcdu_data.page_data[600].ref_lines[id] then

        local obj = mcdu_data.page_data[600].ref_lines[id]

        if obj.invalid then
            return false
        end

        if obj.discontinuity then
            return false
        end

        if mcdu_data.page_data[600].curr_fpln.apts.arr and obj.id == mcdu_data.page_data[600].curr_fpln.apts.arr.id then
            return false
        end

        mcdu_data.vert_rev_subject = {}
        mcdu_data.vert_rev_subject.data = obj
        mcdu_open_page(mcdu_data, 608)
        return true
    end
    return false
end


function THIS_PAGE:L1(mcdu_data)
    if mcdu_data.page_data[600].curr_idx == 1 then
        if mcdu_data.page_data[600].curr_fpln.apts.dep then
            mcdu_data.lat_rev_subject = {}
            mcdu_data.lat_rev_subject.type = 1 -- ORIGIN
            mcdu_data.lat_rev_subject.data = mcdu_data.page_data[600].curr_fpln.apts.dep
            mcdu_open_page(mcdu_data, 602)
        else
            mcdu_data.lat_rev_subject = {}
            mcdu_data.lat_rev_subject.type = 3 -- PPOS
            mcdu_open_page(mcdu_data, 602)
        end
    else
        if not trigger_lat_rev(mcdu_data, 1) then
            MCDU_Page:L2(mcdu_data) -- Error
            return
        end
    end
    
end

function THIS_PAGE:L2(mcdu_data)
    if not trigger_lat_rev(mcdu_data, 2) then
        MCDU_Page:L2(mcdu_data) -- Error
    end
end

function THIS_PAGE:L3(mcdu_data)
    if not trigger_lat_rev(mcdu_data, 3) then
        MCDU_Page:L3(mcdu_data) -- Error
    end
end

function THIS_PAGE:L4(mcdu_data)
    if not trigger_lat_rev(mcdu_data, 4) then
        MCDU_Page:L4(mcdu_data) -- Error
    end
end
function THIS_PAGE:L5(mcdu_data)
    if not trigger_lat_rev(mcdu_data, 5) then
        MCDU_Page:L5(mcdu_data) -- Error
    end
end


function THIS_PAGE:L6(mcdu_data)

    if FMGS_does_temp_fpln_exist() then
        FMGS_erase_temp_fpln()
    elseif mcdu_data.page_data[600].curr_fpln.apts.arr then
        trigger_lat_rev_apt_dest(mcdu_data)
    else
        MCDU_Page:L6(mcdu_data) -- ERROR
    end
end


function THIS_PAGE:R1(mcdu_data)
    if mcdu_data.page_data[600].curr_idx == 1 then
        MCDU_Page:R1(mcdu_data) -- Error
    else
        if not trigger_vert_rev(mcdu_data, 1) then
            MCDU_Page:R1(mcdu_data) -- Error
            return
        end
    end
end

function THIS_PAGE:R2(mcdu_data)
    if not trigger_vert_rev(mcdu_data, 2) then
        MCDU_Page:R2(mcdu_data) -- Error
    end
end

function THIS_PAGE:R3(mcdu_data)
    if not trigger_vert_rev(mcdu_data, 3) then
        MCDU_Page:R3(mcdu_data) -- Error
    end
end

function THIS_PAGE:R4(mcdu_data)
    if not trigger_vert_rev(mcdu_data, 4) then
        MCDU_Page:R4(mcdu_data) -- Error
    end
end

function THIS_PAGE:R5(mcdu_data)
    if not trigger_vert_rev(mcdu_data, 5) then
        MCDU_Page:R5(mcdu_data) -- Error
    end
end


function THIS_PAGE:R6(mcdu_data)
    if FMGS_does_temp_fpln_exist() then
        FMGS_reshape_fpln()
        FMGS_insert_temp_fpln()
    else
        MCDU_Page:R6(mcdu_data) -- ERROR
    end
end

function THIS_PAGE:Slew_Down(mcdu_data)
    if mcdu_data.page_data[600].curr_idx - 1 > 0 then
        mcdu_data.page_data[600].curr_idx = mcdu_data.page_data[600].curr_idx - 1
    else
        mcdu_data.page_data[600].goto_last = true
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    if not mcdu_data.page_data[600].page_end then
        mcdu_data.page_data[600].curr_idx = mcdu_data.page_data[600].curr_idx + 1
    else
        mcdu_data.page_data[600].curr_idx = 1
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
