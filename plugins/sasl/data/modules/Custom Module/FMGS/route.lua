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
include('libs/geo-helpers.lua')

local ROUTE_FREQ_UPDATE_SEC = 0.5

local route_last_update = 0


local function update_active_fpln()
    local fpln_active = FMGS_sys.fpln.active.legs
    
    local nr_points = #fpln_active
    if nr_points <= 1 then
        return  -- We need at least 2 waypoints to build a route...
    end
    
    local roll_limit = FMGS_get_roll_limit()
    local NM_ARC = math.max(0, math.floor(adirs_get_avg_tas())^2 / (math.tan(math.rad(roll_limit)) * 11.294) * 0.000164579)
    
    for k,r in ipairs(fpln_active) do
        if k > 1 and k < nr_points then
        
            -- Limited to 0.5 to avoid that when the aircraft is too fast a too large curve would overshoot the next curve.
            lat_start, lon_start = point_from_a_segment_lat_lon_limited(r.lat, r.lon, fpln_active[k-1].lat, fpln_active[k-1].lon, NM_ARC, 0.5)
            lat_end,   lon_end   = point_from_a_segment_lat_lon_limited(r.lat, r.lon, fpln_active[k+1].lat, fpln_active[k+1].lon, NM_ARC, 0.5)
            
            fpln_active[k].beizer = {
                start_lat =  lat_start,
                start_lon =  lon_start,
                end_lat   =  lat_end,
                end_lon   =  lon_end,
            }

        end
    end
    
end

local function read_fix_id(prev_point,fix_id)  -- Convert the FIX IDENT field of the CIFP to the avionics_bay object
    local fixes_1 = nil
    local fixes_2 = nil

    -- VOR or NDB
    if #fix_id == 3 then
        fixes_1 = AvionicsBay.navaids.get_by_name(NAV_ID_NDB, fix_id, false)
        fixes_2 = AvionicsBay.navaids.get_by_name(NAV_ID_VOR, fix_id, false)

    -- RUNWAY identifier
    elseif fix_id:sub(1,2) == "RW" and tonumber(fix_id:sub(3,4)) ~= nil  then    -- Runway
        local dep_rwy, sibl = FMGS_dep_get_rwy(false)
        if (dep_rwy.name == fix_id:sub(3) and not sibl) or (dep_rwy.s_name == fix_id:sub(3) and not sibl) then
            return dep_rwy
        else
            return nil
        end

    -- AIRPORT
    elseif #fix_id == 4 then
        fixes_1 = AvionicsBay.apts.get_by_name(fix_id, false)
    
    -- Waypoint
    elseif #fix_id == 5 then
        fixes_1 = AvionicsBay.fixes.get_by_name(fix_id, false)
    end
    
    -- Ok, now I need to find the nearest one
    local nearest = nil
    local nearest_distance = 10^50
    
    local check_minimum = function(fixes) 
        for _,x in ipairs(fixes) do
            local this_dist = GC_distance_kt(x.lat, x.lon, prev_point.lat, prev_point.lon)
            if this_dist < nearest_distance then
                nearest_distance = this_dist
                nearest = x
            end
        end
    end

    if fixes_1 then
        check_minimum(fixes_1)
    end

    if fixes_2 then
        check_minimum(fixes_2)
    end
    
    return nearest
end

local function add_sid_point_IF_TF(prev_point, x)
    local point = read_fix_id(prev_point, x.leg_name)
    if point then
        return {point}
    else
        return {}
    end
end

local function add_sid_point_CF(prev_point, x)
    local point = read_fix_id(prev_point, x.leg_name)
    if point then
        local line = GeoLine:create_from_course(point, x.outb_mag/10)  -- TODO TRUE/MAG
        local sec_point = line:point_at_min_distance(prev_point)
        return {sec_point, point}
    else
        return {}
    end
end


local function add_sid_point(prev_point, x)
    if x.leg_type == CIFP_LEG_TYPE_IF or x.leg_type == CIFP_LEG_TYPE_TF then
        return add_sid_point_IF_TF(prev_point,x)
    elseif x.leg_type == CIFP_LEG_TYPE_CF then
        return add_sid_point_CF(prev_point, x)
    end
    return {}
--    elseif x.leg_type == CIFP_LEG_TYPE_TF then
--        return {{prev_point.lat, prev_point.lon}, {x.lat, x.lon}}
--    elseif x.leg_type == CIFP_LEG_TYPE_CF then
--        return {{prev_point.lat, prev_point.lon}, {x.lat, x.lon}}
end

local function update_sid()
    if not FMGS_sys.fpln.active.apts.dep_sid then
        return -- No SID no party
    end

    FMGS_sys.fpln.active.apts.dep_sid.computed_legs = {}
    local dep_rwy, sibl = FMGS_dep_get_rwy(false)
    local prev_point = GeoPoint:create({ lat=(not sibl and dep_rwy.s_lat or dep_rwy.lat), lon=(not sibl and dep_rwy.s_lon or dep_rwy.lon)})

    FMGS_sys.fpln.active.apts.dep_sid.computed_legs = {{lat=prev_point.lat, lon=prev_point.lon}}

    for i,leg in ipairs(FMGS_sys.fpln.active.apts.dep_sid.legs) do
        local leg_points = add_sid_point(prev_point,leg)    -- Get the points for the single legs
        local distance = 0
        
        local prev_leg_points = prev_point
        for j,x in ipairs(leg_points) do
            distance = distance + GC_distance_kt(prev_point.lat, prev_point.lon, x.lat, x.lon)
            table.insert(FMGS_sys.fpln.active.apts.dep_sid.computed_legs, x)
            prev_leg_points = x
            --print(i,j,y.id, y.lat, y.lon)
        end

        leg.computed_distance = distance
        local nr_leg_points = #leg_points
        if nr_leg_points > 0 then
            prev_point = GeoPoint:create({ lat = leg_points[nr_leg_points].lat, lon = leg_points[nr_leg_points].lon})
        end
    end
end

function update_route()

--[[    -- Disable for testing
    if get(TIME) - route_last_update < ROUTE_FREQ_UPDATE_SEC then
        return
    end
    
    route_last_update = get(TIME)
]]--

    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        if not FMGS_sys.fpln.active.apts.dep_sid then
            if not FMGS_sys.fpln.temp then
                FMGS_set_apt_dep("LIML")
                FMGS_set_apt_arr("LIRF")
                FMGS_create_temp_fpln()
                FMGS_dep_set_rwy(FMGS_sys.fpln.temp.apts.dep.rwys[1], true)
               print("LOADED 1/2")
            end
            if FMGS_sys.fpln.temp.apts.dep_cifp then
                for i,x in ipairs(FMGS_sys.fpln.temp.apts.dep_cifp.sids) do
                    --print(i, x.proc_name, x.leg_name)
                end
                FMGS_dep_set_sid(FMGS_sys.fpln.temp.apts.dep_cifp.sids[49])
                FMGS_dep_set_trans(FMGS_sys.fpln.temp.apts.dep_cifp.sids[50])
                FMGS_insert_temp_fpln()
               print("LOADED 2/2")
            end
        end
    end
    update_sid()
    update_active_fpln()

end

