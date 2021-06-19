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
  if get(GPS_1_is_available) == 1 or get(GPS_2_is_available) == 1 then
    return Fwd_string_fill(tostring(get(ZULU_hours)), "0", 2) .. mcdu_format_force_to_small(":") .. Fwd_string_fill(tostring(get(ZULU_mins)), "0", 2) .. mcdu_format_force_to_small(":") .. Fwd_string_fill(tostring(get(ZULU_secs)), "0", 2)
  else
    -- No GPS info? No party
    return "------"
  end
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "GPS MONITOR")

    -- self:set_line(mcdu_data, MCDU_LEFT, 4, "PAGE NOT YET IMPLEMENTED", MCDU_LARGE, ECAM_MAGENTA)

    self:set_line(mcdu_data, MCDU_LEFT, 1, "GPS1 POSITION", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_lat_lon_to_str(get(GPS_1_lat), get(GPS_1_lon)), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "TTRK", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, mcdu_pad_dp(ADIRS_sys[ADIRS_1].track, 1), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "MERIT", MCDU_SMALL, ECAM_WHITE)
    -- TODO have an option/config for meters, then pad with space
    self:set_line(mcdu_data, MCDU_LEFT, 3, "300FT",  MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_CENTER, 2, "UTC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 2, get_gps_time(), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 3, "GPS ALT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 3, mcdu_pad_dp(get(GPS_1_altitude), 1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 2, "GS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, math.floor(ADIRS_sys[ADIRS_1].gs), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, "MODE/SAT", MCDU_SMALL, ECAM_WHITE)
    if get(GPS_1_is_available) == 1 then
      self:set_line(mcdu_data, MCDU_RIGHT, 3, "NAV/6", MCDU_LARGE, ECAM_GREEN)
    else
      self:set_line(mcdu_data, MCDU_RIGHT, 3, "ACQ", MCDU_LARGE, ECAM_GREEN)
    end


    self:set_line(mcdu_data, MCDU_LEFT, 4, "GPS2 POSITION", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_lat_lon_to_str(get(GPS_2_lat), get(GPS_2_lon)), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "TTRK", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, mcdu_pad_dp(ADIRS_sys[ADIRS_2].track, 1), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "MERIT", MCDU_SMALL, ECAM_WHITE)
    -- TODO have an option/config for meters, then pad with space
    self:set_line(mcdu_data, MCDU_LEFT, 6, "300FT",  MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_CENTER, 5, "UTC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 5, get_gps_time(), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 6, "GPS ALT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 6, mcdu_pad_dp(get(GPS_2_altitude), 1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 5, "GS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, math.floor(ADIRS_sys[ADIRS_2].gs), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "MODE/SAT", MCDU_SMALL, ECAM_WHITE)
    if get(GPS_2_is_available) == 1 then
      self:set_line(mcdu_data, MCDU_RIGHT, 6, "NAV/6", MCDU_LARGE, ECAM_GREEN)
    else
      self:set_line(mcdu_data, MCDU_RIGHT, 6, "ACQ", MCDU_LARGE, ECAM_GREEN)
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
