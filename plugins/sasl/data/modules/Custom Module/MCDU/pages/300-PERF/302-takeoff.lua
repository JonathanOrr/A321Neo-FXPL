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
local v_speeds_displayed = {0,0,0}
local flaps_ths = {nil,nil}
local trans_alt = 18000
local thr_red = 2340
local acceleration = 2340
local eng_out_acc = 1000
local to_shift = nil
local flex_or_derate = nil

local THIS_PAGE = MCDU_Page:new({id=302})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "   TAKE OFF")

    --change later, load and read drfs here
    local dep_rwy = nil
    local fso_spd = {0,0,0}
    --BIG LINES
    self:set_line(mcdu_data, MCDU_LEFT, 1, "___", MCDU_LARGE, ECAM_ORANGE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "___", MCDU_LARGE, ECAM_ORANGE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "___", MCDU_LARGE, ECAM_ORANGE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_format_force_to_small(trans_alt), MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, mcdu_format_force_to_small(" "..thr_red .."/".. acceleration), MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<TO DATA", MCDU_LARGE, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_CENTER, 1, "F="..Fwd_string_fill(tostring(fso_spd[1]), "0", 3).."     ", MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 2, "S="..Fwd_string_fill(tostring(fso_spd[2]), "0", 3).."     ", MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 3, "O="..Fwd_string_fill(tostring(fso_spd[3]), "0", 3).."     ", MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, dep_rwy == nil and "---" or dep_rwy, MCDU_LARGE,  dep_rwy == nil and ECAM_WHITE or ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, mcdu_format_force_to_small("[M]")..(to_shift == nil and "[   ]*" or to_shift), MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, (flaps_ths[1] == nil and "[]" or flaps_ths).."/"..(flaps_ths[2] == nil and "[   ]" or flaps_ths), MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, (flex_or_derate == nil and "[ ]" or flex_or_derate), MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, eng_out_acc, MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "PHASE>", MCDU_LARGE, ECAM_WHITE)
    
    --SMALL LINES
    self:set_line(mcdu_data, MCDU_LEFT, 1, " V1", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, " VR", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, " V2", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, "TRANS ALT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "THR RED/ACC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, " EFB REQ", MCDU_SMALL, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_CENTER, 1, "FLP RETR      ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 2, "SLT RETR      ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 3, "   CLEAN      ", MCDU_SMALL, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "RWY ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "TO SHIFT ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, "FLAPS/THS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "DRT TO-FLX TO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "ENG OUT ACC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT ", MCDU_SMALL, ECAM_WHITE)

end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
