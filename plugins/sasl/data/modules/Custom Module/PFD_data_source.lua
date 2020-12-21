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
-- File: PFD_data_source.lua
-- Short description: Various helper functions to get data and statuses for PFD 
-------------------------------------------------------------------------------

include('constants.lua')

local function is_adr_working(i)
    local rotary_pos = i == PFD_CAPT and -1 or 1
    return (get(Adirs_adr_is_ok[i]) == 1 and get(ADIRS_source_rotary_AIRDATA) ~= rotary_pos)
          or (get(Adirs_adr_is_ok[3]) == 1 and get(ADIRS_source_rotary_AIRDATA) == rotary_pos)
end

local function ir_works_nav_mode(i)
    local rotary_pos = i == PFD_CAPT and -1 or 1
    local (get(Adirs_ir_is_ok[i]) == 1 and get(ADIRS_source_rotary_ATHDG) ~= rotary_pos) 
          or (get(Adirs_ir_is_ok[3]) == 1 and get(ADIRS_source_rotary_ATHDG) == rotary_pos)
end

local function ir_works_att_mode(i)
    local rotary_pos = i == PFD_CAPT and -1 or 1
    local (get(Adirs_ir_is_ok[i]) == 1 and get(ADIRS_source_rotary_ATHDG) ~= rotary_pos) 
          or (get(Adirs_ir_is_ok[3]) == 1 and get(ADIRS_source_rotary_ATHDG) == rotary_pos)
end

function is_spd_ok(i)
    return is_adr_working(i)
end

function is_track_ok(i)
    return ir_works_nav_mode(i)
end

function is_att_ok(i)
    return ir_works_nav_mode(i) or ir_works_att_mode(i)
end




