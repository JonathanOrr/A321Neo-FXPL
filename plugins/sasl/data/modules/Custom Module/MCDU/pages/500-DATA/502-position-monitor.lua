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

local THIS_PAGE = MCDU_Page:new({id=502})

local fms1_latlon = "0000.0N/00000.0E"
local fms2_latlon = "0000.0N/00000.0E"
local gpirs_latlon = "0000.0N/00000.0E"
local avg_latlon = "0000.0N/00000.0E"
local drift = {0,0,0}

local mcdu_is_frozen = false
local mcdu_freeze_time = "0000"

local function coord_converter(lat,lon)
    if lat == nil or lon == nil then
        return "----.-/-----.-"
    end
    local NS = lat > 0 and "N" or "S"
    local EW = lon > 0 and "E" or "W"
    
    local lat_str = Fwd_string_fill(Round_fill(math.abs(lat*100),1)..NS, "0", 7)
    local lon_str = Fwd_string_fill(Round_fill(math.abs(lon*100),1)..EW, "0", 8)
    return lat_str .."/".. lon_str
end

local function get_txt_from_status(irs)
    if ADIRS_sys[irs].ir_status == IR_STATUS_OFF or ADIRS_sys[irs].ir_status == IR_STATUS_FAULT then
        return "INVAL", ECAM_ORANGE
    elseif ADIRS_sys[irs].ir_status == IR_STATUS_IN_ALIGN then
        return "ALIGN", ECAM_ORANGE
    elseif ADIRS_sys[irs].ir_status == IR_STATUS_ATT_ALIGNED then
        return "ATT", ECAM_ORANGE
    elseif ADIRS_sys[irs].ir_status == IR_STATUS_ALIGNED then
        return "NAV", ECAM_GREEN
    else
        return "UKNWN", ECAM_ORANGE
    end
end

function THIS_PAGE:render_irs_status(mcdu_data)
    local irs_1_txt, irs_1_col = get_txt_from_status(1)
    local irs_2_txt, irs_2_col = get_txt_from_status(2)
    local irs_3_txt, irs_3_col = get_txt_from_status(3)

    local drift1 = irs_1_col == ECAM_GREEN and tostring(drift[1]) or ""
    local drift2 = irs_2_col == ECAM_GREEN and tostring(drift[2]) or "  "
    local drift3 = irs_3_col == ECAM_GREEN and tostring(drift[3]) or "  "

    self:set_line(mcdu_data, MCDU_LEFT, 5,  mcdu_format_force_to_small(irs_1_txt .. " " .. drift1), MCDU_LARGE, irs_1_col)
    self:set_line(mcdu_data, MCDU_CENTER, 5,  mcdu_format_force_to_small(irs_2_txt .. " " .. drift2), MCDU_LARGE, irs_2_col)
    self:set_line(mcdu_data, MCDU_RIGHT, 5,  mcdu_format_force_to_small(irs_3_txt .. " " .. drift3), MCDU_LARGE, irs_3_col)
end

function THIS_PAGE:render(mcdu_data)

    self:set_title(mcdu_data, mcdu_is_frozen and "POSITION FROZEN AT "..mcdu_freeze_time.."Z" or "POSITION MONITOR")
    -------------------------------------
    -- STATIC
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_format_force_to_small("FMS1"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, mcdu_format_force_to_small("FMS2"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, mcdu_format_force_to_small("GPIRS"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_format_force_to_small("MIX IRS"), MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "  IRS1    IRS2    IRS3", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, mcdu_is_frozen and "←UNFREEZE" or "←FREEZE", MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "SEL ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NAVIDS>", MCDU_LARGE, ECAM_WHITE)

    -------------------------------------
    -- DYNAMIC
    -------------------------------------
    local irs_gps_str = "      "
    local irs_working = adirs_how_many_irs_fully_work()
    if irs_working > 0 then
        irs_gps_str = irs_gps_str .. irs_working .. "IRS"
        if get(GPS_1_is_available) == 1 or get(GPS_2_is_available) == 1 then
            irs_gps_str = irs_gps_str .. "/GPS"
        end
    end
    self:set_line(mcdu_data, MCDU_LEFT, 2, irs_gps_str, MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, irs_gps_str, MCDU_SMALL, ECAM_WHITE)

    local fms1_latlon_source = adirs_get_fms(1)
    local fms2_latlon_source = adirs_get_fms(2)
    local gpirs_latlon_source= adirs_get_gpirs(mcdu_data.id)
    local avg_latlon_source  = adirs_get_mixed_irs()

    if gpirs_latlon_source[1] == nil and (get(GPS_1_is_available) == 1 or get(GPS_2_is_available) == 1) then
        self:set_line(mcdu_data, MCDU_LEFT, 3, mcdu_format_force_to_small("GPS"), MCDU_LARGE, ECAM_WHITE)
        gpirs_latlon_source = get(GPS_1_is_available) == 1 and {get(GPS_1_lat), get(GPS_1_lon)} or {get(GPS_2_lat), get(GPS_2_lon)}
    end

    THIS_PAGE:render_irs_status(mcdu_data)

    if not mcdu_is_frozen then
        fms1_latlon  = coord_converter(fms1_latlon_source[1], fms1_latlon_source[2])
        fms2_latlon  = coord_converter(fms2_latlon_source[1], fms2_latlon_source[2])
        gpirs_latlon = coord_converter(gpirs_latlon_source[1], gpirs_latlon_source[2])
        avg_latlon   = coord_converter(avg_latlon_source[1], avg_latlon_source[2])

        for i=1, 3 do
            drift[i] = Round_fill(ADIRS_sys[i].ir_drift,1)
        end
    end

    self:set_line(mcdu_data, MCDU_RIGHT, 1, fms1_latlon ,  MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, fms2_latlon , MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, gpirs_latlon, MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, avg_latlon, MCDU_LARGE, ECAM_GREEN)

end

function THIS_PAGE:L6(mcdu_data)
    mcdu_is_frozen = not mcdu_is_frozen
    mcdu_freeze_time = Fwd_string_fill(tostring(get(ZULU_hours)), "0", 2)..Fwd_string_fill(tostring(get(ZULU_mins)), "0", 2)
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_open_page(mcdu_data, 508)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
