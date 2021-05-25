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

    THIS_PAGE:render_single(mcdu_data, 1, arpt_id, "0000", nil, tostring(arpt_alt), "", nil, nil, nil, true)

end

function THIS_PAGE:render_single(mcdu_data, i, id, time, spd, alt, proc_name, bearing, is_trk, distance, is_arpt)
    local main_col = FMGS_sys.fpln.temp and ECAM_YELLOW or ECAM_GREEN

    time = is_arpt and time or mcdu_format_force_to_small(time) -- TIME is small only for airports

    local left_side  = Aft_string_fill(id, " ", 8) 
    local right_side = (spd and spd or "") .. "/" .. Fwd_string_fill(alt, " ", 6)
    if not is_arpt then
        left_side  = left_side .. mcdu_format_force_to_small(time)
        right_side = mcdu_format_force_to_small(right_side)
    else
        left_side  = left_side .. time
    end
    self:set_line(mcdu_data, MCDU_LEFT, i, left_side, MCDU_LARGE, main_col)
    self:set_line(mcdu_data, MCDU_RIGHT, i, right_side, MCDU_LARGE, main_col)
    
    if spd == nil then
        self:set_line(mcdu_data, MCDU_CENTER, i, "       ---", is_arpt and MCDU_LARGE or MCDU_SMALL)
    end
    
    if i ~= 1 then
        local brg_trk = is_trk ~= nil and ((is_trk and "TRK" or "BRG") .. Fwd_string_fill(tostring(math.floor(bearing)), "0", 3) .. "°") or "       "
        
        self:set_line(mcdu_data, MCDU_LEFT, i, " " .. Aft_string_fill(proc_name, " ", 8) .. brg_trk .. "  " .. distance .. "NM" , MCDU_SMALL, (i == 2 and THIS_PAGE.curr_page == 1) and ECAM_WHITE or main_col)
    end
    
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

    THIS_PAGE:render_single(mcdu_data, 2, "2340", "0001", 153, "2340", "KMS118", 120, false, 2, false)
    THIS_PAGE:render_single(mcdu_data, 3, "JACKO", "0002", 250, "4070", "", 119, true, 5, false)
    THIS_PAGE:render_single(mcdu_data, 4, "(LIM)", "0004", 153, "10000", "(SPD)", nil, nil, 9, false)
    THIS_PAGE:render_single(mcdu_data, 5, "(T/C)", "0023", ".78", "FL370", "", nil, nil, 131, false)

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


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
