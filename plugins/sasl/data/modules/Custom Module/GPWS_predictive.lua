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

local last_update_time = 0

local distances_front     = {0,0,0,0,0,0}
local terrain_alt_front   = {0,0,0,0,0,0}
local terrain_alt_front_L = {0,0,0,0,0,0}
local terrain_alt_front_R = {0,0,0,0,0,0}

local function move_along_distance(origin_lat, origin_lon, distance, angle)
    local a = math.rad(90-angle);

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
        
        for i=1,6 do
            distances_front[i] = speed * 10 * i
        end
        
        set(GPWS_dist_30, distances_front[3] * 0.000539957)
        set(GPWS_dist_60, distances_front[6] * 0.000539957)
        
    else
        set(GPWS_dist_30, 0)
        set(GPWS_dist_60, 0)
    end
end

local function compute_alt(lat, lon)
    x,y,z = sasl.worldToLocal(lat, lon, -100)
    result,locationX,locationY,locationZ,normalX,normalY,normalZ,velocityX,velocityY,velocityZ,isWet = sasl.probeTerrain(x,y, z)
    lat, long, alt = sasl.localToWorld(locationX,locationY,locationZ)
    return alt
end

local function search_terrain_altitude()

    local roll = math.max(-30, math.min(30, get(Flightmodel_roll)))
    local heading = get(Flightmodel_heading) + roll/10  -- +/- 3 deg roll correction

    for i=1,6 do

        -- Front
        lat, lon = move_along_distance(get(Aircraft_lat), get(Aircraft_long), distances_front[i], heading)
        alt = compute_alt(lat, lon)
        terrain_alt_front[i] = alt * 3.28084

        -- Front L
        lat_L, lon_L = move_along_distance(lat, lon, 230, heading-90)
        alt = compute_alt(lat_L, lon_L)
        terrain_alt_front_L[i] = alt * 3.28084

        -- Front R
        lat_R, lon_R = move_along_distance(lat, lon, 230, heading+90)
        alt = compute_alt(lat_R, lon_R)
        terrain_alt_front_R[i] = alt * 3.28084

    end
end

local function update_dr_pred(dr, i, diff)
    -- Here we have 5 possible output:
    -- - 0: I'm definetely higher than the terrain - no problems
    -- - 1: Always caution
    -- - 2: Caution if I'm far (>30s), Warning otherwise (<30s)
    -- - 3/4: Definetely a warning, pull up 
    
    -- The threshold depends on the nearest airport distance:
    -- If distance <= 1 then lower threshold: 0
    -- If 1 < distance <= 5 nm, the threshold goes from 0 to 400 
    -- If 5 < distance <= 12 nm, the threshold stays 400 
    -- If 12 < distance <= 15 nm, the threshold goes from 400 to 700
    -- If distance > 15 then the threshold is 700.
    
    local lower_threshold = 700
    if get(GPWS_dist_airport) < 1 then
        lower_threshold = 0
    elseif get(GPWS_dist_airport) < 5 then
        lower_threshold = Math_rescale(1, 0, 5, 400, get(GPWS_dist_airport))
    elseif get(GPWS_dist_airport) < 12 then
        lower_threshold = 400
    elseif get(GPWS_dist_airport) < 15 then
        lower_threshold = Math_rescale(12, 400, 15, 700, get(GPWS_dist_airport))
    end

    if diff < -lower_threshold then
        set(dr, 0, i)
    elseif diff < -500 then
        set(dr, 1, i)
    elseif diff < 0 then
        set(dr, 2, i)
    elseif diff < 700 then
        set(dr, 3, i)
    else
        set(dr, 4, i)
    end
end

local function update_predictions()
    for i=1,6 do
        local diff = terrain_alt_front[i] - get(Capt_Baro_Alt)
        update_dr_pred(GPWS_pred_front, i, diff)

        local diff = terrain_alt_front_R[i] - get(Capt_Baro_Alt)
        update_dr_pred(GPWS_pred_front_R, i, diff)

        local diff = terrain_alt_front_L[i] - get(Capt_Baro_Alt)
        update_dr_pred(GPWS_pred_front_L, i, diff)
        
    end
end

function update_gpws_predictive_cautions()

    is_caution = false
    is_warning = false

    -- Collision <= 30s 
    for i=1,3 do
        if get(GPWS_pred_front, i) == 1 then
            is_caution = true
        elseif get(GPWS_pred_front, i) >= 2 then
            is_warning = true
            break
        end
    end

    -- 30s < Collision <= 60s 
    for i=4,6 do
        if get(GPWS_pred_front, i) > 0 then
            is_caution = true
        elseif get(GPWS_pred_front, i) > 2 then
            is_warning = true
            break
        end
    end

    is_caution = is_caution and not is_warning

    set(GPWS_pred_terr, is_caution and 1 or 0)
    set(GPWS_pred_terr_pull, is_warning and 1 or 0)

    return is_caution, is_warning

end

local function compute_dist_runway()
    local nav_aid_id = sasl.findNavAid(nil, nil , get(Aircraft_lat), get(Aircraft_long), nil, NAV_AIRPORT)
    if nav_aid_id ~= NAV_NOT_FOUND then
        nav_type, airport_lat, airport_lon, airport_height = sasl.getNavAidInfo(nav_aid_id)
        
        dist = GC_distance_km(get(Aircraft_lat), get(Aircraft_long), airport_lat, airport_lon)
        set(GPWS_dist_airport, dist * 0.539957)
    else
        set(GPWS_dist_airport, 999999)    
    end
    
end

function update_gpws_predictive()

    if get(TIME) - last_update_time > 0.5 then
        last_update_time = get(TIME)
        compute_dist_runway()
        compute_distances()
        search_terrain_altitude()
        update_predictions()
    end
end

