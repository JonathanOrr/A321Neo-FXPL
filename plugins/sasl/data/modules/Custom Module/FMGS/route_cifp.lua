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


local function read_fix_id(fix_id, target_region_code, airport)  -- Convert the a FIX field of the CIFP to the avionics_bay object
    local fixes_1 = nil
    local fixes_2 = nil

    -- VOR or NDB
    if #fix_id == 3 then
        fixes_1 = AvionicsBay.navaids.get_by_name(NAV_ID_NDB, fix_id, false)
        fixes_2 = AvionicsBay.navaids.get_by_name(NAV_ID_VOR, fix_id, false)

    -- RUNWAY identifier
    elseif fix_id:sub(1,2) == "RW" and tonumber(fix_id:sub(3,4)) ~= nil  then    -- Runway

        for i,rwy in ipairs(airport.rwys) do
            if rwy.name == fix_id:sub(3) then
                return {lat=rwy.lat, lon=rwy.lon}
            elseif rwy.s_name == fix_id:sub(3) then
                return {lat=rwy.s_lat, lon=rwy.s_lon}
            else
                return nil
            end
        end

    -- AIRPORT
    elseif #fix_id == 4 then
        fixes_1 = AvionicsBay.apts.get_by_name(fix_id, false)
    
    -- Waypoint
    elseif #fix_id == 5 then
        fixes_1 = AvionicsBay.fixes.get_by_name(fix_id, false)
    end
    
    local found_x

    local check_correct= function(fixes)
        for _,x in ipairs(fixes) do
            if x.region_code == target_region_code then
                found_x = x
                break
            end
        end
    end

    if fixes_1 then
        check_correct(fixes_1)
    end

    if fixes_2 then
        check_correct(fixes_2)
    end
    
    return found_x
end

local function add_cifp_point_IF_TF(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        return {point}
    else
        return {}
    end
end

local function add_cifp_point_CF(apt_ref, prev_point, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        if prev_point then
            local line = GeoLine:create_from_course(point, x.outb_mag/10)  -- TODO TRUE/MAG
            local sec_point = line:point_at_min_distance(prev_point)
            return {sec_point, point}
        else
            return {point}
        end
    else
        return {}
    end
end

local function add_cifp_point_FA(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        x.lat = point.lat
        x.lon = point.lon
        local line = GeoLine:create_from_course(point, x.outb_mag/10)  -- TODO TRUE/MAG
        local sec_point = line:point_at_given_distance(point, 1)
        return {sec_point, point}
    else
        return {}
    end
end

local function add_cifp_point_RF(apt_ref, x)
    local point     = read_fix_id(x.leg_name,  x.leg_name_region_code, apt_ref)
    local point_ctr = read_fix_id(x.center_fix,x.center_fix_region_code, apt_ref)
    if point and point_ctr then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        x.ctr_lat = point_ctr.lat
        x.ctr_lon = point_ctr.lon
        return {point}  -- TODO Not ok for distance
    else
        sasl.logWarning("Point RF " .. x.leg_name .. " or center " .. x.center_fix .. " not found.")
        return {}
    end
end

local function add_cifp_point_HM(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        return {point}
    else
        return {}
    end
end

local function add_cifp_point_DF(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        return {point}
    else
        return {}
    end
end

local function add_cifp_point_VR_CR(apt_ref, x)
    local point = read_fix_id(x.recomm_navaid, x.recomm_navaid_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.recomm_navaid_lat = point.lat
        x.recomm_navaid_lon = point.lon
    end
    return {}
end

local function add_cifp_point_FM(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        return {point}
    else
        return {}
    end
end

local function add_cifp_point_holds(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        return {point}
    else
        return {}
    end
end

function add_cifp_point(apt_ref, prev_point, x)
    -- WARNING: prev_point may be nil
    assert(apt_ref)
    assert(x)
    if x.leg_type == CIFP_LEG_TYPE_IF or x.leg_type == CIFP_LEG_TYPE_TF or x.leg_type == CIFP_LEG_TYPE_DF then
        return add_cifp_point_IF_TF(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_CF then
        return add_cifp_point_CF(apt_ref, prev_point, x)
    elseif x.leg_type == CIFP_LEG_TYPE_FA then
        return add_cifp_point_FA(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_RF then
        return add_cifp_point_RF(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_HM then
        return add_cifp_point_HM(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_DF then
        return add_cifp_point_DF(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_VR or x.leg_type == CIFP_LEG_TYPE_CR then
        return add_cifp_point_VR_CR(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_FM then
        return add_cifp_point_FM(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_HA or x.leg_type == CIFP_LEG_TYPE_HF or x.leg_type == CIFP_LEG_TYPE_HM then
        return add_cifp_point_holds(apt_ref, x)
    end
    return {}
end
