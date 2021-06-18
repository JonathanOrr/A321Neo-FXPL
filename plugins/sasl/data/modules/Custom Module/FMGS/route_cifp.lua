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
-- Short description: Compute the route (cifp helpers)
-------------------------------------------------------------------------------


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

local function add_sid_point_FA(prev_point, x)
    local point = read_fix_id(prev_point, x.leg_name)
    if point then
        local line = GeoLine:create_from_course(point, x.outb_mag/10)  -- TODO TRUE/MAG
        local sec_point = line:point_at_given_distance(point, 1)
        return {sec_point, point}
    else
        return {}
    end
end


function add_cifp_point(reference, prev_point, x)
    if x.leg_type == CIFP_LEG_TYPE_IF or x.leg_type == CIFP_LEG_TYPE_TF or x.leg_type == CIFP_LEG_TYPE_DF then
        return add_sid_point_IF_TF(prev_point,x)
    elseif x.leg_type == CIFP_LEG_TYPE_CF then
        return add_sid_point_CF(prev_point, x)
    elseif x.leg_type == CIFP_LEG_TYPE_FA then
        return add_sid_point_FA(prev_point, x)
    end
    return {}
end