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
-- File: nav_updater.lua
-- Short description: Update the information of the NAV aids
-------------------------------------------------------------------------------

include('DRAIMS/radio_logic.lua')
include('ND/subcomponents/helpers.lua') -- for get_bearing
include('libs/geo-helpers.lua')

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local UPDATE_INTERVAL = 0.20
local UPDATE_INTERVAL_ILS = 0.05

local GS_LATERAL_RANGE = 6 -- 6 on the right, 6 on the left
local GS_PERC_UP_RANGE = 1.75
local GS_PERC_DN_RANGE = 0.45

local LOC_NEAR_RANGE = 35
local LOC_FAR_RANGE  = 10

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------
local last_update = 0
local last_update_ils = 0

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------
DRAIMS_common.radio = {}
DRAIMS_common.radio.vor = {nil, nil}
DRAIMS_common.radio.adf = {nil, nil}

radio_ils_set_freq(109.5)

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------
local function get_nearest_navaid(list)
    local min_distance = 999999999
    local min_distance_i = 0
    local acf_lat = get(Aircraft_lat)
    local acf_lon = get(Aircraft_long)
    for k,v in ipairs(list) do
        local distance = GC_distance_kt(acf_lat, acf_lon, v.lat, v.lon)
        if distance < min_distance then
            min_distance = distance
            min_distance_i = k
        end
    end
    
    assert(min_distance_i ~= 0) -- This is not possible
    return list[min_distance_i], min_distance
end

local function navaid_get_bearing(navaid)
    local acf_lat = get(Aircraft_lat)
    local acf_lon = get(Aircraft_long)
    return get_bearing(acf_lat, acf_lon, navaid.lat, navaid.lon)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local function update_vor_nearest(i)
    DRAIMS_common.radio.vor[i] = nil
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local frequency_int = Round(radio_vor_get_freq(i)*100, 0)
        local out = AvionicsBay.navaids.get_by_freq(NAV_ID_VOR, frequency_int, false)
        if #out > 0 then
            local nearest, dist_out = get_nearest_navaid(out)
            DRAIMS_common.radio.vor[i] = nearest
            DRAIMS_common.radio.vor[i].curr_distance = dist_out
            local alt_nm = (get(ACF_elevation) - nearest.alt*0.3048) * 0.000539957
            DRAIMS_common.radio.vor[i].slant_distance = math.sqrt(dist_out * dist_out + alt_nm*alt_nm)
            DRAIMS_common.radio.vor[i].curr_bearing = (90 - navaid_get_bearing(nearest)) % 360
        end
    end
end

local function update_adf_nearest(i)
    DRAIMS_common.radio.adf[i] = nil
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local frequency_int = math.floor(radio_adf_get_freq(i))
        local out = AvionicsBay.navaids.get_by_freq(NAV_ID_NDB, frequency_int, false)
        if #out > 0 then
            local nearest, dist_out = get_nearest_navaid(out)
            DRAIMS_common.radio.adf[i] = nearest
            DRAIMS_common.radio.adf[i].curr_distance = dist_out
            DRAIMS_common.radio.adf[i].curr_bearing = (90 - navaid_get_bearing(nearest)) % 360
        end
    end
end

local function update_gs_nearest()
    local out = AvionicsBay.navaids.get_by_freq(NAV_ID_GS, DRAIMS_common.radio.ils.freq, false)
    if #out > 0 then
        local nearest, dist_out = get_nearest_navaid(out)
        DRAIMS_common.radio.ils.gs = nearest
        DRAIMS_common.radio.ils.gs.curr_distance = dist_out
    end
end

local function update_ils_nearest()
    DRAIMS_common.radio.ils = nil
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local frequency_int = Round(radio_ils_get_freq()*100, 0)
        local out1 = AvionicsBay.navaids.get_by_freq(NAV_ID_LOC, frequency_int, false)
        local out2 = AvionicsBay.navaids.get_by_freq(NAV_ID_LOC_ALONE, frequency_int, false)
        if #out1 > 0 then
            local nearest, dist_out = get_nearest_navaid(out1)
            DRAIMS_common.radio.ils = nearest
            DRAIMS_common.radio.ils.curr_distance = dist_out
            update_gs_nearest()
        end
        if #out2 > 0 then
            local nearest, dist_out = get_nearest_navaid(out2)
            if #out2 == 0 or dist_out < DRAIMS_common.radio.ils.curr_distance then
                DRAIMS_common.radio.ils = nearest
                DRAIMS_common.radio.ils.curr_distance = dist_out
            end
        end
    end
end


-------------------------------------------------------------------------------
-- ILS-related computations
-------------------------------------------------------------------------------

local function update_gs()

    -- G/S
    local d = DRAIMS_common.radio.ils.gs.curr_distance * 1852       -- Distance from the G/S in m 

    local gs_angle = DRAIMS_common.radio.ils.gs.extra_bearing[1]    -- Beam angle (vertical)
    local gs_angle_sin = math.sin(math.rad(gs_angle))
    local d_extended    = d / math.cos(math.rad(gs_angle))
    local gs_alt = DRAIMS_common.radio.ils.gs.alt*0.3048
    local ctr_alt = gs_alt + gs_angle_sin * d_extended

    local max_alt = GS_PERC_UP_RANGE * ctr_alt
    local min_alt = GS_PERC_DN_RANGE * ctr_alt
    local cur_alt   = get(ACF_elevation)

    if cur_alt > max_alt or cur_alt < min_alt then
        DRAIMS_common.radio.ils.gs.reason = 1
        -- Too high too low
        return
    end


    local gs_lat  = DRAIMS_common.radio.ils.gs.lat
    local gs_lon  = DRAIMS_common.radio.ils.gs.lon
    local acf_lat = get(Aircraft_lat)
    local acf_lon = get(Aircraft_long)

    local distance = get_distance_nm(gs_lat, gs_lon, acf_lat, acf_lon)

    if distance > DRAIMS_common.radio.ils.gs.category then
        DRAIMS_common.radio.ils.gs.reason = 2
        -- Too far
        return
    end

    local gs_bearing = DRAIMS_common.radio.ils.gs.extra_bearing[2]    -- Beam angle (horizontal)
    local bearing = get_bearing(gs_lat, gs_lon, acf_lat, acf_lon)
    bearing = (-bearing-90) % 360 -- Report to nord-centric bearing
    local lat_range_m = Math_rescale(100, 45, 5555, GS_LATERAL_RANGE, d)
    if math.abs(bearing - gs_bearing) > lat_range_m then
        DRAIMS_common.radio.ils.gs.reason = 3
        -- Not centered
        return
    end

    DRAIMS_common.radio.ils.gs.reason = 0
    DRAIMS_common.radio.ils.gs.is_ok = true
    DRAIMS_common.radio.ils.gs.deviation = math.deg(math.atan2(cur_alt-gs_alt, d)) - gs_angle
end

local function update_loc()
    local d = DRAIMS_common.radio.ils.curr_distance * 1852       -- Distance from the LOC in m
    
    local max_alt = DRAIMS_common.radio.ils.alt*0.3048 + 1371.6  -- Max altitude is the altitude of the LOC + 4500
    local min_alt = DRAIMS_common.radio.ils.alt*0.3048 + Math_rescale(5500, -50, 50000, 300, d) -- It actually depends on the terrain, but we cannot look that. Let's estimate a sort of gradient

    local cur_alt   = get(ACF_elevation)

    if cur_alt > max_alt or cur_alt < min_alt then
        DRAIMS_common.radio.ils.loc.reason = 1
        -- Too high too low
        return
    end
    
    local loc_lat  = DRAIMS_common.radio.ils.lat
    local loc_lon  = DRAIMS_common.radio.ils.lon
    local acf_lat = get(Aircraft_lat)
    local acf_lon = get(Aircraft_long)

    local distance = get_distance_nm(loc_lat, loc_lon, acf_lat, acf_lon)

    if distance > DRAIMS_common.radio.ils.category then
        DRAIMS_common.radio.ils.loc.reason = 2
        -- Too far
        return
    end

    local loc_bearing = DRAIMS_common.radio.ils.extra_bearing[1]
    local bearing = get_bearing(loc_lat, loc_lon, acf_lat, acf_lon)
    DRAIMS_common.radio.ils.loc.bearing = bearing
    bearing = (-bearing-90) % 360 -- Report to nord-centric bearing
    
    local angle = d < 31.48 and LOC_NEAR_RANGE or LOC_FAR_RANGE -- ICAO Version
    if DRAIMS_common.radio.ils.category < 20 then
        angle = d < 18.52 and LOC_NEAR_RANGE or LOC_FAR_RANGE   -- FAA Version
    end
    
    local deviation = (bearing - loc_bearing) % 360

    if math.abs(deviation) > angle and math.abs(deviation-180) > angle then
        DRAIMS_common.radio.ils.loc.reason = 3
        -- Not centered
        return
    end

    DRAIMS_common.radio.ils.loc.reason = 0
    DRAIMS_common.radio.ils.loc.is_ok = true
    DRAIMS_common.radio.ils.loc.deviation = deviation
end

local function update_ils()

    if DRAIMS_common.radio.ils == nil then
        return
    end
    
    if DRAIMS_common.radio.ils.gs then
        DRAIMS_common.radio.ils.gs.is_ok = false
        update_gs()
    end
    
    if not DRAIMS_common.radio.ils.loc then
        DRAIMS_common.radio.ils.loc = {}
    end
    DRAIMS_common.radio.ils.loc.is_ok = false
    DRAIMS_common.radio.ils.loc.bearing = nil
    update_loc()
    
end

-------------------------------------------------------------------------------
-- main update()
-------------------------------------------------------------------------------

local function update_navaids()
    if get(TIME) - last_update <= UPDATE_INTERVAL then
        return
    end

    last_update = get(TIME)
    
    update_vor_nearest(1)
    update_vor_nearest(2)
    update_adf_nearest(1)
    update_adf_nearest(2)
    update_ils_nearest()
end

local function update_landings()
    if get(TIME) - last_update_ils <= UPDATE_INTERVAL_ILS then
        --return
    end
    last_update_ils = get(TIME)

    update_ils()
end


function update()
    perf_measure_start("nav_updater:update()")

    update_navaids()
    update_landings()

    perf_measure_stop("nav_updater:update()")
end
