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

local CSTR_MET = 1
local CSTR_NOT_MET = 2

-------------------------------------------------------------------------------
-- WINDS
-------------------------------------------------------------------------------
local function get_wind_str(leg)
    local err_str = "---°/---"
    local is_climb   = (leg.flt_phase_user and leg.flt_phase_user.is_climb) or  (leg.flt_phase and leg.flt_phase.is_climb)
    local is_descent = (leg.flt_phase_user and leg.flt_phase_user.is_descent) or  (leg.flt_phase and leg.flt_phase.is_descent)

    if leg.pred then
        is_climb = is_climb or leg.pred.is_climb or leg.pred.is_toc
        is_descent = is_descent or leg.pred.is_descent or leg.pred.is_tod
    end
    local format_wind_num = function(num) return Fwd_string_fill(Round(num,0).."", " ", 3) end

    if not leg.pred or not leg.pred.altitude then
        return err_str
    elseif is_climb then
        local wind = FMGS_winds_get_climb_at_alt(leg.pred.altitude)
        return wind and (format_wind_num(wind.dir) .. "°/" .. format_wind_num(wind.spd)) or err_str
    elseif is_descent then
        local wind = FMGS_winds_get_descent_at_alt(leg.pred.altitude)
        return wind and (format_wind_num(wind.dir) .. "°/" .. format_wind_num(wind.spd)) or err_str
    elseif leg.winds then
        local wind = FMGS_winds_get_cruise_at_alt(leg.pred.altitude, leg.winds)
        return wind and (format_wind_num(wind.dir) .. "°/" .. format_wind_num(wind.spd)) or err_str
    else
        return err_str
    end
end

local function get_efob(x)

    local taxi_fuel = FMGS_init_get_taxi_fuel() or 0
    if FMGS_init_get_block_fuel() and x.pred and x.pred.fuel then
        local fuel = FMGS_init_get_block_fuel() - taxi_fuel - x.pred.fuel/1000
        return Round_fill(fuel,1)
    end
    return "----"
end

local function get_arrival_wind_str()
    return (FMGS_get_landing_wind_mag() and Fwd_string_fill(Round(FMGS_get_landing_wind_mag(),0).."", " ", 3) or "---") 
    .. "°/" .. 
    (FMGS_get_landing_wind() and Fwd_string_fill(Round(FMGS_get_landing_wind(),0).."", " ", 3) or "---")
end

-------------------------------------------------------------------------------
-- DEPARTURE
-------------------------------------------------------------------------------
function THIS_PAGE:render_dep(mcdu_data)
    local arpt_id    = mcdu_data.page_data[600].curr_fpln.apts.dep.id
    local arpt_alt   = mcdu_data.page_data[600].curr_fpln.apts.dep.alt

    local data = {
        id = arpt_id,
        time = mcdu_time_beautify(0), 
        spd = FMGS_perf_get_v_speeds(),
        efob = FMGS_init_get_block_fuel()-FMGS_init_get_taxi_fuel(),
        wind = "",
        alt = tostring(arpt_alt),
        proc_name = "",
        is_arpt = true,
    } 
    THIS_PAGE:render_single(mcdu_data, 1, data)
end

-------------------------------------------------------------------------------
-- ARRIVAL
-------------------------------------------------------------------------------
function THIS_PAGE:render_dest(mcdu_data)
    local time_str = FMGS_get_phase() > FMGS_PHASE_PREFLIGHT and "UTC " or "TIME"

    self:set_line(mcdu_data, MCDU_LEFT, 6, " DEST   " .. time_str, MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "DIST  EFOB", MCDU_SMALL)

    local arr_id    = mcdu_data.page_data[600].curr_fpln.apts.arr.id
    local rwy, sibl = FMGS_arr_get_rwy(false)
    if rwy then
        arr_id = arr_id .. (sibl and rwy.sibl_name or rwy.name)
    end
    local trip_time = mcdu_time_beautify(FMGS_perf_get_pred_trip_time())
    self:set_line(mcdu_data, MCDU_LEFT, 6, Aft_string_fill(arr_id, " ", 8).. trip_time, MCDU_LARGE)

    local trip_dist_num = FMGS_perf_get_pred_trip_dist()
    local trip_dist = trip_dist_num and Fwd_string_fill(""..math.ceil(trip_dist_num), " ", 4) or "----"
    local efob_num = FMGS_perf_get_pred_trip_efob()
    local efob = efob_num and Round_fill(efob_num, 1) or "----"
    local efob_col = efob_num and (efob_num <= 0) and ECAM_ORANGE or ECAM_WHITE

    self:set_line(mcdu_data, MCDU_CENTER, 6, "        " .. trip_dist, MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, Fwd_string_fill(efob, " ", 6), MCDU_LARGE, efob_col)

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
function THIS_PAGE:render_single(mcdu_data, i, data)
    local main_col = data.is_the_first and ECAM_WHITE or (FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN)

    data.time = data.is_arpt and data.time or mcdu_format_force_to_small(data.time) -- TIME is small only for airports
    data.efob = data.is_arpt and data.efob or mcdu_format_force_to_small(data.efob) -- EFOB is small only for airports

    local left_side  = Aft_string_fill(data.id, " ", 8) .. (mcdu_data.page_data[600].is_b_page and data.efob or data.time)
    local ctr_side   = mcdu_data.page_data[600].is_b_page and "" or (data.spd and data.spd or "---")
    local right_side = mcdu_data.page_data[600].is_b_page and data.wind or ("/" .. Fwd_string_fill(data.alt or "", " ", 6))
    if not data.is_arpt then
        ctr_side   = mcdu_format_force_to_small(ctr_side)
        right_side = mcdu_format_force_to_small(right_side)
    end

    self:set_line(mcdu_data, MCDU_LEFT, i, left_side, MCDU_LARGE, main_col)
    self:add_multi_line(mcdu_data, MCDU_CENTER, i, "       " .. ctr_side, MCDU_LARGE, data.spd and main_col or ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_RIGHT, i, right_side, MCDU_LARGE, mcdu_data.page_data[600].is_b_page and main_col or (data.alt_col or main_col))

    if not mcdu_data.page_data[600].is_b_page and data.spd_cstr_status and data.spd_cstr_status > 0 then
        self:add_multi_line(mcdu_data, MCDU_CENTER, i, "   " .. mcdu_format_force_to_small("*"), MCDU_LARGE, data.spd_cstr_status == CSTR_MET and ECAM_MAGENTA or ECAM_ORANGE)
    end
    if not mcdu_data.page_data[600].is_b_page and data.alt_cstr_status and data.alt_cstr_status > 0 then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, i, mcdu_format_force_to_small("*") .. "     ", MCDU_LARGE, data.alt_cstr_status == CSTR_MET and ECAM_MAGENTA or ECAM_ORANGE)
    end
    
    if i ~= 1 then
        local brg_trk = data.is_trk ~= nil and ((data.is_trk and "TRK" or "BRG") .. Fwd_string_fill(tostring(math.floor(data.bearing)), "0", 3) .. "°") or "    "

        local dist_text=""
        if data.distance ~= nil then
            dist_text = Round(data.distance, 0) .. (i == 2 and "NM" or "  ")
        end
        dist_text = Fwd_string_fill(dist_text, " ", 6) .. "   "
        local color_proc_name = data.proc_name:match("%(%w*%)") and ECAM_GREEN or ECAM_WHITE -- If (SPD) or similar, use green
        self:set_line(mcdu_data, MCDU_LEFT, i, " " .. data.proc_name, MCDU_SMALL, color_proc_name)
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

local function prepare_add_generic_pseudo(list_messages, pseudo_wpt, name, upper_name, is_climb, is_descent)
    if not pseudo_wpt then
        return
    end
    for i,x in ipairs(list_messages) do
        if x == pseudo_wpt.prev_wpt then
            assert(pseudo_wpt.dist_prev_wpt, "dist_prev_wpt is mandatory for pseudo wpts, but not present in " .. name .. "/" .. (pseudo_wpt.id or "[UNKN]"))
            list_messages[i].temp_computed_distance = list_messages[i].computed_distance - pseudo_wpt.dist_prev_wpt
            table.insert(list_messages, i, {id=name, 
                                            airway_name=upper_name, -- May be nil
                                            pred={  time=pseudo_wpt.time, 
                                                    ias=pseudo_wpt.ias, 
                                                    mach=pseudo_wpt.mach,
                                                    altitude=pseudo_wpt.altitude or pseudo_wpt.alt, 
                                                    fuel=pseudo_wpt.fuel,
                                                    cms_segment = true,
                                                    is_climb = is_climb,
                                                    is_descent = is_descent
                                            },
                                            computed_distance = pseudo_wpt.dist_prev_wpt,
                                            point_type=POINT_TYPE_PSUEDO}
                        )
            break   -- This is super important, otherwise inifnite loop will occur
        end
    end
end

function THIS_PAGE:prepare_list_pseudo(mcdu_data, list_messages)
    prepare_add_generic_pseudo(list_messages, FMGS_pred_get_toc(), "(T/C)", nil, true, false)
    prepare_add_generic_pseudo(list_messages, FMGS_pred_get_climb_lim(), "(LIM)", "(SPD)", true, false)
    prepare_add_generic_pseudo(list_messages, FMGS_pred_get_descent_lim(), "(LIM)", "(SPD)", false, true)
    prepare_add_generic_pseudo(list_messages, FMGS_pred_get_tod(), "(T/D)", nil, false, true)

    local DECEL = FMGS_pred_get_decel_point()
    if DECEL.prev_wpt then
        prepare_add_generic_pseudo(list_messages, DECEL, "(DECEL)", nil, false, true) 
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

    THIS_PAGE:prepare_list_pseudo(mcdu_data, list_messages)


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
    local spd_cstr_status = 0
    local alt_cstr_status = 0
    if x.cstr_speed_type and x.cstr_speed_type ~= CIFP_CSTR_SPD_NONE then
        spd_cstr = tostring(x.cstr_speed)
    end

    if x.pred then
        if x.pred.ias then
            spd_cstr = tostring(Round(x.pred.ias,0))
            if x.pred.cms_segment and x.pred.mach then
                spd_cstr = "." .. Round(x.pred.mach*100,0)
            end
            if x.cstr_speed_type and x.cstr_speed_type ~= CIFP_CSTR_SPD_NONE then
                if x.pred.cstr_ias_met then
                    spd_cstr_status = CSTR_MET
                else
                    spd_cstr_status = CSTR_NOT_MET
                end
            end
        elseif x.pred.mach then
            spd_cstr = "." .. Round(x.pred.mach*100,0)
        end
    end
    
    if x.pred and x.pred.altitude then
        alt_cstr = render_altitude(x.pred.altitude)
        alt_cstr_col = nil -- Default one
        if x.cstr_alt_type and x.cstr_alt_type ~= CIFP_CSTR_ALT_NONE then
            if x.pred.cstr_alt_met then
                alt_cstr_status = CSTR_MET
            else
                alt_cstr_status = CSTR_NOT_MET
            end
        end
    end

    return spd_cstr, alt_cstr, alt_cstr_col, spd_cstr_status, alt_cstr_status
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
        elseif x.point_type ~= POINT_TYPE_LEG and x.point_type ~= POINT_TYPE_PSUEDO then
            local name, proc = cifp_convert_leg_name(x)
            x.id = name -- This is necessary for the LAT REV page

            if #proc == 0 then
                proc = get_proc_name(mcdu_data,x)
            end

            local spd_cstr, alt_cstr, alt_cstr_col, spd_cstr_status, alt_cstr_status = get_spd_alt_cstr(x)
            local spd_cstr_req_elipses = false

            if spd_cstr == "" then
                last_spd_cstr_value = nil
            elseif last_spd_cstr_value == spd_cstr then
                spd_cstr_req_elipses = true
            else
                last_spd_cstr_value = spd_cstr
            end

            local distance = x.temp_computed_distance or x.computed_distance
            local time = x.pred and x.pred.time and mcdu_time_beautify(x.pred.time) or "----"
            local efob = get_efob(x)
            self:add_f(mcdu_data, function(line_id)
                local spd_cstr_str = (spd_cstr_req_elipses and line_id ~= 1) and "\"" or spd_cstr
                local data = {
                    id = name,
                    time = time,
                    efob = efob,
                    wind = get_wind_str(x), 
                    spd = spd_cstr_str,
                    alt = alt_cstr,
                    alt_col = alt_cstr_col,
                    proc_name = proc,
                    bearing = nil,
                    is_trk = nil,
                    distance = distance,
                    is_arpt = false,
                    is_the_first = i == 2,
                    spd_cstr_status = spd_cstr_status,
                    alt_cstr_status = alt_cstr_status
                } 
                THIS_PAGE:render_single(mcdu_data, line_id, data)
            end, x)
        else
            local distance = x.temp_computed_distance or x.computed_distance
            local proc = x.airway_name or ""
            local spd_cstr, alt_cstr, alt_cstr_col, spd_cstr_status, alt_cstr_status = get_spd_alt_cstr(x)
            local spd_cstr_req_elipses = false
            
            if spd_cstr == "" then
                last_spd_cstr_value = nil
            elseif last_spd_cstr_value == spd_cstr then
                spd_cstr_req_elipses = true
            else
                last_spd_cstr_value = spd_cstr
            end

            local name = x.id or "(MAN)"
            local efob = get_efob(x)
            self:add_f(mcdu_data, function(line_id)
                local spd_cstr_str = (spd_cstr_req_elipses and line_id ~= 1) and "\"" or spd_cstr
                local time = x.pred and mcdu_time_beautify(x.pred.time) or "----"
                local data = {
                    id = name,
                    time = time, 
                    efob = efob,
                    wind = get_wind_str(x), 
                    spd = spd_cstr_str,
                    alt = alt_cstr,
                    alt_col = alt_cstr_col,
                    proc_name = proc,
                    bearing = nil,
                    is_trk = nil,
                    distance = distance,
                    is_arpt = false,
                    is_the_first = i == 2,
                    spd_cstr_status = spd_cstr_status,
                    alt_cstr_status = alt_cstr_status
                } 
                THIS_PAGE:render_single(mcdu_data, line_id, data)
            end, x)
        end
    end

    local arr_rwy_valid = mcdu_data.page_data[600].curr_fpln.apts.arr_rwy and mcdu_data.page_data[600].curr_fpln.apts.arr_rwy[1]
    local wind_str = get_arrival_wind_str()

    self:print_simple_airport(mcdu_data,
                              mcdu_data.page_data[600].curr_fpln.apts.arr,
                              mcdu_data.page_data[600].curr_fpln.apts.arr,
                              arr_rwy_valid and mcdu_data.page_data[600].curr_fpln.apts.arr_rwy[1].last_distance,
                              FMGS_perf_get_pred_trip_time(),
                              FMGS_perf_get_pred_trip_efob(),
                              wind_str,
                              ECAM_GREEN)

    self:add_f(mcdu_data, function(line_id)
        self:set_line(mcdu_data, MCDU_LEFT, line_id, "------END OF F-PLN------", MCDU_LARGE)
    end)
    THIS_PAGE:render_list_altn(mcdu_data)
end

function THIS_PAGE:print_simple_airport(mcdu_data, apt, apt_obj, distance, trip_time, efob, wind, color)
    -- APT Obj represents the object we want to save for lateral revision
    -- it should be nil, for instance, for the line with the arrival airport in the
    -- altn fpln.
    local arr_id    = apt.id
    local arr_alt   = apt.alt

    local left_side  = arr_id

    local time_str = mcdu_format_force_to_small(mcdu_time_beautify(trip_time)) -- TIME is small only for airports
    local efob_str = efob and mcdu_format_force_to_small(Round_fill(efob,1)) or "----" -- EFOB is small only for airports

    local ctr_side   = " " .. (mcdu_data.page_data[600].is_b_page and efob_str .. "     " or time_str .. "  ---") 
    local right_side

    if mcdu_data.page_data[600].is_b_page then
        right_side = wind or "---°/---"
    else
        right_side = mcdu_format_force_to_small("/" .. Fwd_string_fill(tostring(arr_alt)," ", 6))
    end

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
    local wind_str = get_arrival_wind_str()
    THIS_PAGE:print_simple_airport(mcdu_data, mcdu_data.page_data[600].curr_fpln.apts.arr, nil, nil, FMGS_perf_get_pred_trip_time(), FMGS_perf_get_pred_trip_efob(), wind_str, ECAM_BLUE)

    -- TODO: ALTN route
    self:add_f(mcdu_data, function(line_id)
        self:set_line(mcdu_data, MCDU_LEFT, line_id, "---F-PLN DISCONTINUITY--" , MCDU_LARGE)
    end)

    -- ALTN aiport
    THIS_PAGE:print_simple_airport(mcdu_data, mcdu_data.page_data[600].curr_fpln.apts.alt, nil, nil, nil, nil, nil, ECAM_BLUE) -- TODO Trip time

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
        mcdu_data.page_data[600].is_b_page  = false
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

    local time_str = FMGS_get_phase() > FMGS_PHASE_PREFLIGHT and "UTC " or "TIME"
    local full_str = time_str .. "  SPD/ALT   "
    if mcdu_data.page_data[600].is_b_page then
        time_str = "EFOB"
        full_str = time_str ..   "      WIND  "
    end
    self:set_line(mcdu_data, MCDU_RIGHT, 1, full_str, MCDU_SMALL)

    if mcdu_data.page_data[600].curr_idx == 1 then
        THIS_PAGE:render_dep(mcdu_data)
    end

    if not FMGS_does_temp_fpln_exist() then
        THIS_PAGE:render_dest(mcdu_data)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)
    end

    self:set_updn_arrows_bottom(mcdu_data, #mcdu_data.page_data[600].render_functions > 5)


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

        if obj.invalid or obj.point_type == POINT_TYPE_PSUEDO then
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
            FMGS_refresh_pred()

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

        if obj.discontinuity or obj.point_type == POINT_TYPE_PSUEDO then
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

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_data.page_data[600].is_b_page = not mcdu_data.page_data[600].is_b_page
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_data.page_data[600].is_b_page = not mcdu_data.page_data[600].is_b_page
end



mcdu_pages[THIS_PAGE.id] = THIS_PAGE
