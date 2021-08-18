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

local function update_cifp(reference)
    if not reference then
        return -- No Data no party
    end

    reference.computed_legs = {}
    local dep_rwy, sibl = FMGS_dep_get_rwy(false)
    local prev_point = GeoPoint:create({ lat=(not sibl and dep_rwy.s_lat or dep_rwy.lat), lon=(not sibl and dep_rwy.s_lon or dep_rwy.lon)})

    reference.computed_legs = {{lat=prev_point.lat, lon=prev_point.lon}}

    for i,leg in ipairs(reference.legs) do
        local leg_points = add_cifp_point(reference, prev_point,leg)    -- Get the points for the single legs
        local distance = 0
        
        local prev_leg_points = prev_point
        for j,x in ipairs(leg_points) do
            distance = distance + GC_distance_kt(prev_point.lat, prev_point.lon, x.lat, x.lon)
            table.insert(reference.computed_legs, x)
            prev_leg_points = x
        end

        leg.computed_distance = distance
        local nr_leg_points = #leg_points
        if nr_leg_points > 0 then
            prev_point = GeoPoint:create({ lat = leg_points[nr_leg_points].lat, lon = leg_points[nr_leg_points].lon})
        end
    end

end

function update_route()

    if true then
        --return -- Disabled in the master branch for now
    end

    -- Disable for testing
    if get(TIME) - route_last_update < ROUTE_FREQ_UPDATE_SEC then
        return
    end
    
    route_last_update = get(TIME)


    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        if not FMGS_sys.fpln.active.apts.dep_sid then
            if not FMGS_sys.fpln.temp then
                FMGS_set_apt_dep("LIML")
                FMGS_set_apt_arr("VABB")
                FMGS_set_apt_alt("LIMC")
                FMGS_create_temp_fpln()
                FMGS_dep_set_rwy(FMGS_sys.fpln.temp.apts.dep.rwys[1], true)
                logInfo("DEBUG F/PLN is active: LOADED 1/2")
            end
            if FMGS_sys.fpln.temp.apts.dep_cifp then
                FMGS_dep_set_sid(FMGS_sys.fpln.temp.apts.dep_cifp.sids[49])
                FMGS_dep_set_trans(FMGS_sys.fpln.temp.apts.dep_cifp.sids[50])
                FMGS_reshape_temp_fpln()
                FMGS_insert_temp_fpln()
                logInfo("DEBUG F/PLN is active: LOADED 1/2")
            end
        end
    end
   
    update_cifp(FMGS_sys.fpln.active.apts.dep_sid)
    update_cifp(FMGS_sys.fpln.active.apts.dep_trans)
    
    update_active_fpln()


end

