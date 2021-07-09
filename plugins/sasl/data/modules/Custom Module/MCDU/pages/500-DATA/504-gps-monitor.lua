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


local THIS_PAGE = MCDU_Page:new({id=504})

local function get_gps_time()
  if GPS_sys[GPS_1].status == GPS_STATUS_NAV or GPS_sys[GPS_2].status == GPS_STATUS_NAV then
    return Fwd_string_fill(tostring(get(ZULU_hours)), "0", 2) .. mcdu_format_force_to_small(":") .. Fwd_string_fill(tostring(get(ZULU_mins)), "0", 2) .. mcdu_format_force_to_small(":") .. Fwd_string_fill(tostring(get(ZULU_secs)), "0", 2)
  else
    -- No GPS info? No party
    return "------"
  end
end

local function get_gps_status(i)
  if GPS_sys[i].status == GPS_STATUS_NAV then
    return "NAV/".. GPS_sys[i].nr_satellites
  elseif GPS_sys[i].status == GPS_STATUS_ACQ then
    return "ACQ"
  elseif GPS_sys[i].status == GPS_STATUS_OFF then
    return "OFF"
  elseif GPS_sys[i].status == GPS_STATUS_FAULT then
    return "FAULT"
  elseif GPS_sys[i].status == GPS_STATUS_INIT then
    return "INIT"
  end
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "GPS MONITOR")

    self:set_line(mcdu_data, MCDU_LEFT, 1, "GPS1 POSITION", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_lat_lon_to_str(GPS_sys[GPS_1].lat, GPS_sys[GPS_1].lon), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "TTRK", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, mcdu_pad_dp(GPS_sys[GPS_1].true_track, 1), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "MERIT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "300FT",  MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_CENTER, 2, "UTC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 2, get_gps_time(), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 3, "GPS ALT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 3, mcdu_pad_dp(GPS_sys[GPS_1].alt, 1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 2, "GS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, math.floor(GPS_sys[GPS_1].gs), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, "MODE/SAT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, get_gps_status(GPS_1), MCDU_LARGE, ECAM_GREEN)


    self:set_line(mcdu_data, MCDU_LEFT, 4, "GPS2 POSITION", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_lat_lon_to_str(GPS_sys[GPS_2].lat, GPS_sys[GPS_2].lon), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "TTRK", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, mcdu_pad_dp(GPS_sys[GPS_2].true_track, 1), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "MERIT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "300FT",  MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_CENTER, 5, "UTC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 5, get_gps_time(), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 6, "GPS ALT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 6, mcdu_pad_dp(GPS_sys[GPS_2].alt, 1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 5, "GS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, math.floor(GPS_sys[GPS_2].gs), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "MODE/SAT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, get_gps_status(GPS_2), MCDU_LARGE, ECAM_GREEN)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
