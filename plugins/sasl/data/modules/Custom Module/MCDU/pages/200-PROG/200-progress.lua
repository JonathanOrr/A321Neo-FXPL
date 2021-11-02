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


local THIS_PAGE = MCDU_Page:new({id=200})

local optimum_crz = nil
local rec_max_crz = nil
local to_certain_waypoint = { wpt_name = "RICOO", bearing = 58, distance = 308}
local update_at_prompt = {wpt_name = nil, lat = nil, lon = nil}
local vdev = nil -- enter a number here and the entire VDEV line will show
local nav_accuracy = {required = 2, estimated_drift = 8}

function THIS_PAGE:render(mcdu_data)
    local displayed_fmgs_phase = {"TO", "TO", "CLB", "CRZ", "DES", "APPR", "GA", " "}
    local displayed_fmgs_colour = {ECAM_WHITE, ECAM_GREEN, ECAM_GREEN, ECAM_GREEN, ECAM_GREEN, ECAM_GREEN, ECAM_GREEN, ECAM_GREEN}
    self:set_multi_title(mcdu_data, {
        {txt=Aft_string_fill(Fwd_string_fill(displayed_fmgs_phase[FMGS_get_phase()], " ", 11), " ", 24 ), col=displayed_fmgs_colour[FMGS_get_phase()], size=MCDU_LARGE},
        {txt=" ", col=ECAM_GREEN, size=MCDU_LARGE},
        {txt=Fwd_string_fill(Aft_string_fill(FMGS_init_get_flt_nbr() == nil and " " or FMGS_init_get_flt_nbr(), " ", 12), " ", 24), col=ECAM_WHITE, size=MCDU_LARGE},
    })

    -----LINE 1

    self:add_multi_line(mcdu_data, MCDU_LEFT, 1, " CRZ      OPT    REC MAX" , MCDU_SMALL, ECAM_WHITE)
    local a,b = FMGS_init_get_crz_fl_temp()
    local c = optimum_crz
    local d = rec_max_crz
    local dash_the_crz_and_opt = FMGS_get_phase() >= 5 -- SEE MANUAL PAGE 340 FOR WHY


    self:add_multi_line(mcdu_data, MCDU_LEFT, 1,(a == nil or dash_the_crz_and_opt) and "-----" or (a >= FMGS_perf_get_trans_alt() and "FL"..Fwd_string_fill(tostring(a/100), "0", 3) or " "..ostring(a)) , MCDU_LARGE, a == nil and ECAM_WHITE or ECAM_BLUE)
    
    self:add_multi_line(mcdu_data, MCDU_LEFT, 1,(c == nil or dash_the_crz_and_opt) and "         -----" or "         FL"..tostring(c) , MCDU_LARGE, c == nil and ECAM_WHITE or ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 1,d == nil and "----- " or "FL"..tostring(d).." " , MCDU_LARGE, d == nil and ECAM_WHITE or ECAM_MAGENTA)

    -----LINE 2
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, "<REPORT", MCDU_LARGE, ECAM_WHITE)

    if vdev ~= nil then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, mcdu_format_force_to_small("VDEV=        "), MCDU_LARGE, ECAM_WHITE)
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, (vdev >= 0 and "+" or "")..(#tostring(vdev)< 2 and Fwd_string_fill(tostring(vdev),"0",2) or tostring(vdev)).."  ", MCDU_LARGE, ECAM_GREEN)
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, mcdu_format_force_to_small("FT"), MCDU_LARGE, ECAM_WHITE)
    end

    -----LINE 3
    self:add_multi_line(mcdu_data, MCDU_LEFT, 3, " POSITION UPDATE AT", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 3, "*[     ]", MCDU_LARGE, ECAM_BLUE)

    -----LINE 4
    self:add_multi_line(mcdu_data, MCDU_LEFT, 4, "  BRG /DIST", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 4, mcdu_format_force_to_small("TO           "), MCDU_LARGE, ECAM_WHITE)

    if to_certain_waypoint.wpt_name ~= nil then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 4, Aft_string_fill(to_certain_waypoint.wpt_name, " ", 10), MCDU_LARGE, ECAM_BLUE)
        self:add_multi_line(mcdu_data, MCDU_LEFT, 4, mcdu_format_force_to_small(" "..Fwd_string_fill(tostring(to_certain_waypoint.bearing), "0", 3).."°/"..tostring(to_certain_waypoint.distance)), MCDU_LARGE, ECAM_GREEN)
    end

    -----LINE 5
    self:add_multi_line(mcdu_data, MCDU_LEFT, 5, " PREDICTIVE", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 5, "<GPS", MCDU_LARGE, ECAM_WHITE)

    if FMGS_sys.config.gps_primary then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 5, "GPS PRIMARY", MCDU_LARGE, ECAM_GREEN)
    end

    -----LINE 6
    self:add_multi_line(mcdu_data, MCDU_LEFT, 6, "REQUIRED ACCUR ESTIMATED", MCDU_SMALL, ECAM_WHITE)

    self:add_multi_line(mcdu_data, MCDU_LEFT, 6, Fwd_string_fill(Round_fill(nav_accuracy.required,1), " ", 4).."NM", MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 6, mcdu_format_force_to_small(tostring(nav_accuracy.estimated_drift).."NM"), MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 6, Fwd_string_fill(nav_accuracy.required >= nav_accuracy.estimated_drift and "HIGH" or "LOW" , " ", 14), MCDU_LARGE, ECAM_GREEN)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
