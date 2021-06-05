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

include("libs/geo-helpers.lua")

local fms1_latlon = "0000.0N/00000.0E"
local fms2_latlon = "0000.0N/00000.0E"
local gpirs_latlon = "0000.0N/00000.0E"
local avg_latlon = "0000.0N/00000.0E"
local drift = {0,0,0}

local mcdu_is_frozen = false
local mcdu_freeze_time = "0000"

local function coord_converter(lat,lon)
    local NS = lat > 0 and "N" or "S"
    local EW = lon > 0 and "E" or "W"
    return Round_fill(math.abs(lat*100),1)..NS.."/"..Round_fill(math.abs(lon*100),1)..EW
end

local THIS_PAGE = MCDU_Page:new({id=502})

function THIS_PAGE:render(mcdu_data)

    self:set_title(mcdu_data, mcdu_is_frozen and "POSITION FROZEN AT "..mcdu_freeze_time.."Z" or "POSITION MONITOR")
    -------------------------------------
    -- STATIC
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_format_force_to_small("FMS1"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, mcdu_format_force_to_small("FMS2"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "      3IRS/GPS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, mcdu_format_force_to_small("GPIRS"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "      3IRS/GPS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_format_force_to_small("MIX IRS"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "  IRS1    IRS2    IRS3", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5,  mcdu_format_force_to_small(tostring("NAV "..drift[1].." NAV "..drift[2].." NAV "..drift[3])), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 6, mcdu_is_frozen and "←UNFREEZE" or "←FREEZE", MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "SEL ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NAVIDS>", MCDU_LARGE, ECAM_WHITE)

    local fms1_latlon_source = {get(Aircraft_lat), get(Aircraft_long)}
    local fms2_latlon_source = {get(Aircraft_lat), get(Aircraft_long)}
    local gpirs_latlon_source = {get(Aircraft_lat), get(Aircraft_long)}
    local avg_latlon_source = 
    {(ADIRS_sys[1].lat + ADIRS_sys[2].lat + ADIRS_sys[3].lat)/3, 
    (ADIRS_sys[1].lon + ADIRS_sys[3].lon + ADIRS_sys[2].lon)/3}

    if not mcdu_is_frozen then
        fms1_latlon = coord_converter(fms1_latlon_source[1], fms1_latlon_source[2])
        fms2_latlon = coord_converter(fms2_latlon_source[1], fms2_latlon_source[2])
        gpirs_latlon = coord_converter(gpirs_latlon_source[1], gpirs_latlon_source[2])
        avg_latlon = coord_converter(avg_latlon_source[1], avg_latlon_source[2])

        for i=1, 3 do
            drift[i] = Round_fill(get_distance_nm(ADIRS_sys[i].lat,ADIRS_sys[i].lon,avg_latlon_source[1],avg_latlon_source[2]),1)
        end
    end

    self:set_line(mcdu_data, MCDU_RIGHT, 1, fms1_latlon ,  MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, fms2_latlon , MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, gpirs_latlon, MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, avg_latlon, MCDU_LARGE, ECAM_GREEN)

end

function MCDU_Page:L6(mcdu_data)
    mcdu_is_frozen = not mcdu_is_frozen
    mcdu_freeze_time = Fwd_string_fill(tostring(get(ZULU_hours)), "0", 2)..Fwd_string_fill(tostring(get(ZULU_mins)), "0", 2)
end

function MCDU_Page:R6(mcdu_data)
    mcdu_open_page(mcdu_data, 508)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
