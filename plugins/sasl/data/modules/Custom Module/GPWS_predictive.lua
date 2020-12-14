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
-- File: GPWS_predictive.lua 
-- Short description: GPWS Predictive system
-------------------------------------------------------------------------------

include('constants.lua')


local function move_along_distance(origin_lat, origin_lon, distance, angle)
    local a = math.rad(angle);

    local lat0 = math.cos(math.pi / 180.0 * origin_lat)

    local lat = origin_lat  + (180/math.pi) * (distance / 6378137) * math.sin(a)
    local lon = origin_lon + (180/math.pi) * (distance / 6378137) / math.cos(lat0) * math.cos(a)
    return lat,lon
end

local function compute_distances()

    -- We need to compute two distances:
    -- - The position of the aircraft in 60s
    -- - The position of the aircraft in 30s
    local speed = get(Ground_speed_ms)  -- m/s
    
    if speed > 25 then -- ~ 50kts
    
        local distance_30 = speed * 30  -- m
        local distance_60 = speed * 60  -- m
        
        set(GPWS_dist_30, distance_30)
        set(GPWS_dist_60, distance_60)
        
        lat, lon = move_along_distance(get(Aircraft_lat), get(Aircraft_long), distance_60, 0)

    else
        set(GPWS_dist_30, 0)
        set(GPWS_dist_60, 0)
    end
    
    
end

function update_gpws_predictive()
    compute_distances()
end

