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
-- File: FMGS/route.lua 
-- Short description: Compute the route
-------------------------------------------------------------------------------

include('FMGS/functions.lua')
include('FMGS/nav_helpers.lua')
include('FMGS/geometric_helpers.lua')
include('FMGS/route_cifp.lua')
include('libs/geo-helpers.lua')

local ROUTE_FREQ_UPDATE_SEC = 0.5

local route_last_update = 0

local function compute_arc_radius(tas, roll_limit)
    return math.max(0, math.floor(tas)^2 / (math.tan(math.rad(roll_limit)) * 11.294) * 0.000164579)
end

local function update_active_fpln()
    local fpln_active = FMGS_sys.fpln.active.legs
    
    local nr_points = #fpln_active
    if nr_points <= 1 then
        return  -- We need at least 2 waypoints to build a route...
    end
    
    local roll_limit = FMGS_get_roll_limit()
    local NM_ARC = compute_arc_radius(adirs_get_avg_tas(), roll_limit)
    
    for k,r in ipairs(fpln_active) do

        if k > 1 and k < nr_points then
            local in_between_discontinuity = r.discontinuity or fpln_active[k-1].discontinuity or fpln_active[k+1].discontinuity
            if not in_between_discontinuity then
                -- Limited to 0.5 to avoid that when the aircraft is too fast a too large curve would overshoot the next curve.
                lat_start, lon_start = point_from_a_segment_lat_lon_limited(r.lat, r.lon, fpln_active[k-1].lat, fpln_active[k-1].lon, NM_ARC, 0.5)
                lat_end,   lon_end   = point_from_a_segment_lat_lon_limited(r.lat, r.lon, fpln_active[k+1].lat, fpln_active[k+1].lon, NM_ARC, 0.5)
                
                fpln_active[k].beizer = {
                    start_lat =  lat_start,
                    start_lon =  lon_start,
                    end_lat   =  lat_end,
                    end_lon   =  lon_end,
                }
            else
                 -- TODO manage discontinuity
            end
        end
    end
    
end

local function update_cifp(apt_ref, reference, initial_point)
    if not reference then
        return 0, initial_point -- No Data no party
    end

    local total_distance = 0

    if initial_point then
        reference.computed_legs = {{lat=initial_point.lat, lon=initial_point.lon}}
    else
        reference.computed_legs = {}
    end

    local prev_point = initial_point

    for i,leg in ipairs(reference.legs) do
        local leg_points = add_cifp_point(apt_ref, prev_point,leg)    -- Get the points for the single legs
        local distance = 0
        
        for _,x in ipairs(leg_points) do
            if prev_point then
                distance = distance + GC_distance_kt(prev_point.lat, prev_point.lon, x.lat, x.lon)
            end
            prev_point = GeoPoint:create({ lat = x.lat, lon = x.lon})
            table.insert(reference.computed_legs, x)
        end

        leg.computed_distance = distance
        total_distance = total_distance + distance
    end

    return total_distance, prev_point
end

local function debug_add_route()

    -- Disable for testing
    if get(TIME) - route_last_update < ROUTE_FREQ_UPDATE_SEC then
        return
    end
    
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        if not FMGS_sys.fpln.active.apts.dep_sid then
            if not FMGS_sys.fpln.temp then
                FMGS_set_apt_dep("LIML")
                FMGS_set_apt_arr("LIMC")
                FMGS_set_apt_alt("VABB")
                FMGS_create_temp_fpln()
                FMGS_dep_set_rwy(FMGS_sys.fpln.temp.apts.dep.rwys[1], true)
                logInfo("DEBUG F/PLN is active: LOADED 1/2")
            end
            if FMGS_sys.fpln.temp.apts.dep_cifp then
                FMGS_dep_set_sid(FMGS_sys.fpln.temp.apts.dep_cifp.sids[49])
                FMGS_dep_set_trans(FMGS_sys.fpln.temp.apts.dep_cifp.sids[50])
                FMGS_reshape_fpln()
                FMGS_insert_temp_fpln()
                logInfo("DEBUG F/PLN is active: LOADED 2/2")
                route_last_update = get(TIME) + 100000000
            end
        end
    end
   
    route_last_update = get(TIME)

end

local function fpln_recompute_distances_fplnlegs(fpln, prev_point)

    local total_distance = 0
    local prev
    if prev_point then
        prev = {lat=prev_point.lat, lon=prev_point.lon}
    end

    for k,x in ipairs(fpln.legs) do
        if (prev and not prev.discontinuity) and not x.discontinuity then
            assert(prev.lat and prev.lon and x.lat and x.lon)
            fpln.legs[k].computed_distance = GC_distance_kt(prev.lat, prev.lon, x.lat, x.lon)
            total_distance = total_distance + fpln.legs[k].computed_distance
        end
        prev = fpln.legs[k]
    end

    if prev.discontinuity then
        return total_distance, nil
    else
        return total_distance, GeoPoint:create({ lat=prev.lat, lon=prev.lon})
    end
end


function update_route()

    --debug_add_route()

    local fpln
    if FMGS_sys.fpln.active.require_recompute then
        fpln = FMGS_sys.fpln.active
    end
    if FMGS_sys.fpln.temp and FMGS_sys.fpln.temp.require_recompute then
        fpln = FMGS_sys.fpln.temp
    end

    if not fpln then
        return
    end

    fpln.require_recompute = false

    local dist, total_distance = 0, 0
    local init_pt

    local dep_rwy, sibl = FMGS_dep_get_rwy(FMGS_sys.fpln.temp and FMGS_sys.fpln.temp.require_recompute)
    if dep_rwy then
        init_pt = GeoPoint:create({ lat=(not sibl and dep_rwy.s_lat or dep_rwy.lat), lon=(not sibl and dep_rwy.s_lon or dep_rwy.lon)})
    end
    
    dist, init_pt  = update_cifp(fpln.apts.dep, fpln.apts.dep_sid, init_pt)
    total_distance = total_distance + dist
    dist, init_pt  = update_cifp(fpln.apts.dep, fpln.apts.dep_trans, init_pt)
    total_distance = total_distance + dist
    
    dist, init_pt  = fpln_recompute_distances_fplnlegs(fpln, init_pt)
    total_distance = total_distance + dist

    dist, init_pt  = update_cifp(fpln.apts.arr, fpln.apts.arr_trans, init_pt)
    total_distance = total_distance + dist
    dist, init_pt  = update_cifp(fpln.apts.arr, fpln.apts.arr_star, init_pt)
    total_distance = total_distance + dist
    dist, init_pt  = update_cifp(fpln.apts.arr, fpln.apts.arr_via, init_pt)
    total_distance = total_distance + dist
    dist, init_pt  = update_cifp(fpln.apts.arr, fpln.apts.arr_appr, init_pt)
    total_distance = total_distance + dist

    if init_pt then
        local arr_rwy, sibl = FMGS_arr_get_rwy(FMGS_sys.fpln.temp and FMGS_sys.fpln.temp.require_recompute)
        if arr_rwy then
            local last_pt = GeoPoint:create({ lat=(not sibl and arr_rwy.s_lat or arr_rwy.lat), lon=(not sibl and arr_rwy.s_lon or arr_rwy.lon)})
            local dest_apt_dist = GC_distance_kt(last_pt.lat, last_pt.lon, init_pt.lat, init_pt.lon)
            arr_rwy.last_distance = dest_apt_dist
            total_distance = total_distance + dest_apt_dist
        end
    end

    if total_distance <= 9999 then
        FMGS_sys.data.pred.trip_dist = total_distance
    else
        FMGS_sys.data.pred.trip_dist = nil -- This has no sense
    end
end

