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
include('FMGS/cifp_decorator.lua')
include('FMGS/path_generation/cifp_to_segment.lua')
include('FMGS/path_generation/turn_computer.lua')
include('libs/geo-helpers.lua')

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
        decorate_cifp_point(apt_ref, leg)   -- Add lat/lon from database where necessary

        -- TODO: This is the very approximate version (lower than real)
        -- replace when path drawing is available

        local distance = 0
        if leg.lat and leg.lon then
            if prev_point then
                distance = GC_distance_kt(prev_point.lat, prev_point.lon, leg.lat, leg.lon)
            end
            prev_point = GeoPoint:create({ lat = leg.lat, lon = leg.lon})
            table.insert(reference.computed_legs, leg)
        end
        leg.computed_distance = distance
        total_distance = total_distance + distance
    end

    return total_distance, prev_point
end


local function fpln_recompute_distances_fplnlegs(fpln, prev_point)

    local total_distance = 0
    local prev
    if prev_point then
        prev = {lat=prev_point.lat, lon=prev_point.lon}
    end

    for k,x in ipairs(fpln.legs) do
        if prev and not x.discontinuity then
            assert(prev.lat and prev.lon and x.lat and x.lon)
            x.computed_distance = GC_distance_kt(prev.lat, prev.lon, x.lat, x.lon)
            total_distance = total_distance + x.computed_distance
        else
            x.computed_distance = 0 -- As a safety measure we set zero in case we don't know
                                               -- the previous point
        end
        if not x.discontinuity then
            prev = x
        end
    end

    if not prev or prev.discontinuity then
        return total_distance, nil
    else
        return total_distance, GeoPoint:create({ lat=prev.lat, lon=prev.lon})
    end
end

local function perform_FPLN_conversion(fpln)
    local segment_list = convert_from_FMGS_data(fpln)

    local converted_segment_list = convert_holds(segment_list)
    converted_segment_list = convert_pi(converted_segment_list)

    fpln.segment_curved_list = converted_segment_list

    FMGS_sys.fpln.active.sequencer.segment_curved_list_target = nil

end

function update_route()

    -- First of all let's understand which flight plan needs recomputing (precedence given to active F/PLN)
    local fpln
    if FMGS_sys.fpln.active.require_recompute then
        fpln = FMGS_sys.fpln.active
    end
    if FMGS_sys.fpln.temp and FMGS_sys.fpln.temp.require_recompute then
        fpln = FMGS_sys.fpln.temp
    end

    if not fpln then
        -- No F/PLN requires recomputing, bye bye
        return
    end

    local dist, total_distance = 0, 0
    local init_pt

    local dep_rwy, sibl = FMGS_dep_get_rwy(FMGS_sys.fpln.temp and FMGS_sys.fpln.temp.require_recompute)
    if dep_rwy and not fpln.sequencer.sequenced_after_takeoff then
        init_pt = GeoPoint:create({ lat=(not sibl and dep_rwy.s_lat or dep_rwy.lat), lon=(not sibl and dep_rwy.s_lon or dep_rwy.lon)})

        if FMGS_sys.fpln.active.apts.dep_rwy_pt then
            dist, init_pt  = update_cifp(fpln.apts.dep, {legs={FMGS_sys.fpln.active.apts.dep_rwy_pt}}, init_pt)
            total_distance = total_distance + dist
        end
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
    dist, init_pt  = update_cifp(fpln.apts.arr, fpln.apts.arr_map, init_pt)


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

    fpln.segment_curved_list = nil -- Cleanup old list of turns

    if dep_rwy then 
        -- We need a start point for the conversion to the curved segment list.
        -- Without the departure runway, nothing can be done
        perform_FPLN_conversion(fpln)
    end
end

function update_route_turns()
    local fpln
    if FMGS_sys.fpln.active.require_recompute then
        fpln = FMGS_sys.fpln.active
    end
    if FMGS_sys.fpln.temp and FMGS_sys.fpln.temp.require_recompute then
        fpln = FMGS_sys.fpln.temp
    end

    if not fpln then
        -- No F/PLN requires recomputing, bye bye
        return
    end

    fpln.require_recompute = false
    
    if fpln.segment_curved_list and not debug_FMGS_disable_turn_computer then
        -- The list may not exist if the flight plan is incomplete
        create_turns(fpln.segment_curved_list)
    end
end

