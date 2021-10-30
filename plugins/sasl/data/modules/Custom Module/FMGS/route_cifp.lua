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
            elseif rwy.sibl_name == fix_id:sub(3) then
                return {lat=rwy.s_lat, lon=rwy.s_lon}
            end
        end
        return nil

    -- AIRPORT
    elseif #fix_id == 4 then
        fixes_1 = AvionicsBay.apts.get_by_name(fix_id, false)
        fixes_2 = AvionicsBay.fixes.get_by_name(fix_id, false)

    -- Waypoint
    elseif #fix_id == 5 then
        fixes_1 = AvionicsBay.fixes.get_by_name(fix_id, false)
    end
    
    local found_x

    local check_correct= function(fixes)
        for _,x in ipairs(fixes) do
            if x.region_code == target_region_code and 
               ((not x.airport_id) or x.airport_id == "ENRT" or x.airport_id == airport.id)
            then
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

local function decorate_cifp_point_fix(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        local _, year = AvionicsBay.get_data_cycle()
        x.mag_decl = AvionicsBay.get_declination(x.lat, x.lon, year)
    else
        sasl.logWarning("[decorate_cifp_point_fix]", "Point " .. x.leg_name .. " not found in the database.")
    end
end

local function decorate_cifp_point_fix_rn(apt_ref, x)
    local point = read_fix_id(x.leg_name, x.leg_name_region_code, apt_ref)
    local rn_point = read_fix_id(x.recomm_navaid, x.recomm_navaid_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        local _, year = AvionicsBay.get_data_cycle()
        x.mag_decl = AvionicsBay.get_declination(x.lat, x.lon, year)
    else
        sasl.logWarning("[decorate_cifp_point_fix_rn]", "Point " .. x.leg_name .. " (" .. x.leg_name_region_code .. ") not found in the database.")
    end
    if rn_point then
        -- Save also on the cifp for later usage
        x.recomm_navaid_lat = rn_point.lat
        x.recomm_navaid_lon = rn_point.lon
    else
        sasl.logWarning("[decorate_cifp_point_fix_rn]", "Point RN " .. x.recomm_navaid .. " (".. x.recomm_navaid_region_code ..") not found in the database.")
    end
end

local function decorate_cifp_point_fix_ctr(apt_ref, x)
    local point     = read_fix_id(x.leg_name,  x.leg_name_region_code, apt_ref)
    local ctr_point = read_fix_id(x.center_fix,x.center_fix_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.lat = point.lat
        x.lon = point.lon
        local _, year = AvionicsBay.get_data_cycle()
        x.mag_decl = AvionicsBay.get_declination(x.lat, x.lon, year)
    else
        sasl.logWarning("[decorate_cifp_point_fix_ctr]", "Point " .. x.leg_name .. " (" .. x.leg_name_region_code .. ") not found in the database.")
    end
    if ctr_point then
        -- Save also on the cifp for later usage
        x.ctr_lat = ctr_point.lat
        x.ctr_lon = ctr_point.lon
    else
        sasl.logWarning("[decorate_cifp_point_fix_ctr]", "Point CTR " .. x.recomm_navaid .. " (".. x.recomm_navaid_region_code ..") not found in the database.")
    end
end

local function decorate_cifp_point_rn(apt_ref, x)
    local point = read_fix_id(x.recomm_navaid, x.recomm_navaid_region_code, apt_ref)
    if point then
        -- Save also on the cifp for later usage
        x.recomm_navaid_lat = point.lat
        x.recomm_navaid_lon = point.lon
    else
        sasl.logWarning("[decorate_cifp_point_rn]", "Point " .. x.recomm_navaid .. " (" .. x.recomm_navaid_region_code .. ") not found in the database.")
    end
end


function decorate_cifp_point(apt_ref, x)    -- Load LAT/LON of all the entities of the CIFP
    assert(apt_ref)
    assert(x)
    if x.leg_type == CIFP_LEG_TYPE_IF or
       x.leg_type == CIFP_LEG_TYPE_TF or
       x.leg_type == CIFP_LEG_TYPE_CF or
       x.leg_type == CIFP_LEG_TYPE_DF or
       x.leg_type == CIFP_LEG_TYPE_FA or
       x.leg_type == CIFP_LEG_TYPE_FC or 
       x.leg_type == CIFP_LEG_TYPE_FM or
       x.leg_type == CIFP_LEG_TYPE_HA or
       x.leg_type == CIFP_LEG_TYPE_HF or
       x.leg_type == CIFP_LEG_TYPE_HM or
       x.leg_type == CIFP_LEG_TYPE_PI
    then
        decorate_cifp_point_fix(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_FD or
           x.leg_type == CIFP_LEG_TYPE_AF
    then
        decorate_cifp_point_fix_rn(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_RF
    then
        decorate_cifp_point_fix_ctr(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_VR or
           x.leg_type == CIFP_LEG_TYPE_VD or
           x.leg_type == CIFP_LEG_TYPE_CR or
           x.leg_type == CIFP_LEG_TYPE_CD
    then
        decorate_cifp_point_rn(apt_ref, x)
    elseif x.leg_type == CIFP_LEG_TYPE_CA or
           x.leg_type == CIFP_LEG_TYPE_CI or
           x.leg_type == CIFP_LEG_TYPE_VA or
           x.leg_type == CIFP_LEG_TYPE_VI or
           x.leg_type == CIFP_LEG_TYPE_VM
    then
        -- Nothing to do for these legs
    else
        assert(false, "Unknown CIFP leg type, this shouldn't occur.")
    end

end
