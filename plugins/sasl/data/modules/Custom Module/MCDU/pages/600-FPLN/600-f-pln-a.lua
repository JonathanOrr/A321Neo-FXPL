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

THIS_PAGE.curr_page = 1
THIS_PAGE.curr_fpln = nil

function THIS_PAGE:render_dep(mcdu_data)
    local arpt_id    = THIS_PAGE.curr_fpln.apts.dep.id
    local arpt_alt   = THIS_PAGE.curr_fpln.apts.dep.alt

    THIS_PAGE:render_single(mcdu_data, 1, arpt_id, "0000", nil, tostring(arpt_alt), nil, "", nil, nil, nil, true)

end

function THIS_PAGE:render_single(mcdu_data, i, id, time, spd, alt, alt_col, proc_name, bearing, is_trk, distance, is_arpt, is_the_first)
    local main_col = is_the_first and ECAM_WHITE or (FMGS_sys.fpln.temp and ECAM_YELLOW or ECAM_GREEN)

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
        local brg_trk = is_trk ~= nil and ((is_trk and "TRK" or "BRG") .. Fwd_string_fill(tostring(math.floor(bearing)), "0", 3) .. "°") or "       "
        
        self:set_line(mcdu_data, MCDU_LEFT, i, " " .. Aft_string_fill(proc_name, " ", 8) .. brg_trk .. "  " .. distance .. "NM" , MCDU_SMALL, (i == 2 and THIS_PAGE.curr_page == 1) and ECAM_WHITE or main_col)
    end
    
end

function THIS_PAGE:render_discontinuity(mcdu_data, i)
    self:set_line(mcdu_data, MCDU_LEFT, i, "---F-PLN DISCONTINUITY--" , MCDU_LARGE)
end

function THIS_PAGE:render_dest(mcdu_data)
    self:set_line(mcdu_data, MCDU_LEFT, 6, " DEST   TIME", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "DIST  EFOB", MCDU_SMALL)

    local arr_id    = THIS_PAGE.curr_fpln.apts.arr.id
    local trip_time = (FMGS_sys.data.pred.trip_time and FMGS_sys.data.pred.trip_time or "----")
    self:set_line(mcdu_data, MCDU_LEFT, 6, Aft_string_fill(arr_id, " ", 8, MCDU_LARGE) .. trip_time)

    local trip_dist = (FMGS_sys.data.pred.trip_dist and FMGS_sys.data.pred.trip_dist or "----") 
    local efob = (FMGS_sys.data.pred.efob and FMGS_sys.data.pred.efob or "----")
    self:set_line(mcdu_data, MCDU_RIGHT, 6, trip_dist .. Fwd_string_fill(efob, " ", 6, MCDU_LARGE))

end

function THIS_PAGE:render_list(mcdu_data)
    local list_messages = {
        {} -- First one is always empty (it represents the departure airport)
    }
    
    if not THIS_PAGE.curr_fpln.apts.dep_sid then
        table.insert(list_messages, {discontinuity=true})
    else
        for i,x in ipairs(THIS_PAGE.curr_fpln.apts.dep_sid.legs) do
            table.insert(list_messages, x)
        end
    end
    if THIS_PAGE.curr_fpln.apts.dep_trans then
        for i,x in ipairs(THIS_PAGE.curr_fpln.apts.dep_trans.legs) do
            table.insert(list_messages, x)
        end
    end
    
    local start_i = (THIS_PAGE.curr_page-1) * 5 + 1
    local line_id = 1
    if THIS_PAGE.curr_page == 1 then
        start_i = start_i + 1   -- Skip the departure airport if the first page
        line_id = line_id + 1
    end
    local end_i = (THIS_PAGE.curr_page) * 5
    
    for i=start_i,end_i do
        if not list_messages[i] then
            break   -- end of list
        end
        if list_messages[i].discontinuity then
            THIS_PAGE:render_discontinuity(mcdu_data, line_id)
        else
            local x = list_messages[i]
            local name, proc = cifp_convert_leg_name(x)
            if #proc == 0 then
                proc = THIS_PAGE.curr_fpln.apts.dep_sid.proc_name
            end
            local alt_cstr, alt_cstr_col = cifp_convert_alt_cstr(x)
            local spd_cstr = x.cstr_speed_type ~= CIFP_CSTR_SPD_NONE and tostring(x.cstr_speed) or ""
            THIS_PAGE:render_single(mcdu_data, line_id, name, "----", spd_cstr, alt_cstr, alt_cstr_col, proc, nil, nil, 123, false, start_i == 2 and line_id == 2)
        end
        line_id = line_id + 1
    end
    
end

function THIS_PAGE:render(mcdu_data)

    THIS_PAGE.curr_fpln = FMGS_sys.fpln.temp and FMGS_sys.fpln.temp or FMGS_sys.fpln.active

    local from_ppos = THIS_PAGE.curr_page == 1 and (THIS_PAGE.curr_fpln.apts.dep and "FROM" or "PPOS") or ""
    
    self:set_multi_title(mcdu_data, {
        {txt=Aft_string_fill(from_ppos, " ", 22), col=ECAM_WHITE, size=MCDU_SMALL},
        {txt=Aft_string_fill(THIS_PAGE.curr_fpln == FMGS_sys.fpln.temp and "TMPY" or "", " ", 12), col=ECAM_YELLOW, size=MCDU_LARGE},
        {txt=Fwd_string_fill(FMGS_sys.data.init.flt_nbr and FMGS_sys.data.init.flt_nbr or "", " ", 20) .. "  ", col=ECAM_WHITE, size=MCDU_SMALL}
    })

    self:set_lr_arrows(mcdu_data, true)

    if THIS_PAGE.curr_fpln.apts.dep == nil or THIS_PAGE.curr_fpln.apts.arr == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "------END OF F-PLN------", MCDU_LARGE)
        return
    end

    THIS_PAGE:render_list(mcdu_data)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "TIME  SPD/ALT   ", MCDU_SMALL)

    if THIS_PAGE.curr_page == 1 then
        THIS_PAGE:render_dep(mcdu_data)
    end

    if not FMGS_sys.fpln.temp then
        THIS_PAGE:render_dest(mcdu_data)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)
    end
end

function THIS_PAGE:L1(mcdu_data)
    if THIS_PAGE.curr_page == 1 then
        if THIS_PAGE.curr_fpln.apts.dep then
            mcdu_data.lat_rev_subject = {}
            mcdu_data.lat_rev_subject.type = 1 -- ORIGIN
            mcdu_data.lat_rev_subject.data = THIS_PAGE.curr_fpln.apts.dep
        else
            mcdu_data.lat_rev_subject = {}
            mcdu_data.lat_rev_subject.type = 3 -- PPOS
        end
    end
    
    mcdu_open_page(mcdu_data, 602)
end

function THIS_PAGE:L6(mcdu_data)
    if not FMGS_sys.fpln.temp then
        FMGS_erase_temp_fpln()
    elseif THIS_PAGE.curr_fpln.apts.arr then
        mcdu_data.lat_rev_subject = {}
        mcdu_data.lat_rev_subject.type = 4 -- DEST
        mcdu_data.lat_rev_subject.data = THIS_PAGE.curr_fpln.apts.arr
        mcdu_open_page(mcdu_data, 602)
    else
        MCDU_Page:L6(mcdu_data) -- ERROR
    end
end


function THIS_PAGE:L6(mcdu_data)

    mcdu_open_page(mcdu_data, 600)
end

function THIS_PAGE:R6(mcdu_data)
    if not FMGS_sys.fpln.temp then
        FMGS_insert_temp_fpln()
    else
        MCDU_Page:R6(mcdu_data) -- ERROR
    end
end

function THIS_PAGE:Slew_Down(mcdu_data)
    THIS_PAGE.curr_page = THIS_PAGE.curr_page + 1
end

function THIS_PAGE:Slew_Up(mcdu_data)
    THIS_PAGE.curr_page = math.max(1,THIS_PAGE.curr_page - 1)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
