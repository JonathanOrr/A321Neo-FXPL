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
-- File: helpers.lua
-- Short description: Misc functions related to graphics
-------------------------------------------------------------------------------



function get_range_in_nm(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        return math.floor(2^(data.config.range-1) * 10)
    elseif data.config.range == ND_RANGE_ZOOM_2 then
        return 2
    elseif data.config.range == ND_RANGE_ZOOM_1 then
        return 1
    elseif data.config.range == ND_RANGE_ZOOM_05 then
        return 0.5
    elseif data.config.range == ND_RANGE_ZOOM_02 then
        return 0.2
    end
    assert(false) -- Should never happen
end

function get_distance_nm(lat1,lon1,lat2,lon2)
    return GC_distance_km(lat1, lon1, lat2, lon2) * 0.539957
end

function get_bearing(lat1,lon1,lat2,lon2)
    local lat1_rad = math.rad(lat1)
    local lat2_rad = math.rad(lat2)
    local lon1_rad = math.rad(lon1)
    local lon2_rad = math.rad(lon2)

    local x = math.sin(lon2_rad - lon1_rad) * math.cos(lat2_rad)
    local y = math.cos(lat1_rad) * math.sin(lat2_rad) - math.sin(lat1_rad)*math.cos(lat2_rad)*math.cos(lon2_rad - lon1_rad)
    local theta = math.atan2(y, x)
    local brng = (theta * 180 / math.pi + 360) % 360

    return brng
end

function compute_angle(x1, y1, x2, y2)
    return math.atan2(y1-y2, x1-x2)
end 

