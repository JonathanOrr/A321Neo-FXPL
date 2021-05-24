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
-- File: avionics_bay.lua
-- Short description: Interface file with the AvioncisBay library
-------------------------------------------------------------------------------

include('libs/geo-helpers.lua')

local initialized = false
local ffi = require("ffi")

local function convert_bearing(type, bearing_raw)
    if type == NAV_ID_NDB then
        return 0
    end
    
    bearing_raw = bearing_raw / 1000
    
    if type == NAV_ID_VOR or type == NAV_ID_OM or type == NAV_ID_IM or type == NAV_ID_MM or type == NAV_ID_DME or type == NAV_ID_DME_ALONE or type == NAV_ID_FPAP then
        return bearing_raw  -- Please check XP file for details
    end
    
    if type == NAV_ID_LOC or type == NAV_ID_LOC_ALONE then
        local true_bearing = bearing_raw % 360
        local mag_front_course = (bearing_raw - true_bearing) / 360
        return {true_bearing, mag_front_course}
    end
    
    if type == NAV_ID_GS or type == NAV_ID_LTPFTP or type == NAV_ID_GLS then
        local glideslope = math.floor(bearing_raw / 1000) / 100
        local true_angle = bearing_raw % 1000
        return {glideslope, true_angle}
    end
end

local function convert_navaid_array(rawdata, nav_array)
    if rawdata then
        return {
            navaids = nav_array.navaids,
            len = nav_array.len
        }
    else
        to_return = {}
        for i=1,nav_array.len do
            table.insert(to_return, {
                id   = ffi.string(nav_array.navaids[i-1].id,  nav_array.navaids[i-1].id_len),
                name = ffi.string(nav_array.navaids[i-1].full_name, nav_array.navaids[i-1].full_name_len),
                type = nav_array.navaids[i-1].type,
                lat  = nav_array.navaids[i-1].coords.lat,
                lon  = nav_array.navaids[i-1].coords.lon,
                alt  = nav_array.navaids[i-1].altitude,
                freq = nav_array.navaids[i-1].frequency,
                is_coupled_dme = nav_array.navaids[i-1].is_coupled_dme,
                category = nav_array.navaids[i-1].category,
                extra_bearing = convert_bearing(nav_array.navaids[i-1].type, nav_array.navaids[i-1].bearing),
            })
        end
        return to_return
    end
end

local function convert_fixes_array(rawdata, fix_array)
    if rawdata then
        return {
            fixes = fix_array.fixes,
            len   = fix_array.len
        }
    else
        to_return = {}
        for i=1,fix_array.len do
            table.insert(to_return, {
                id   = ffi.string(fix_array.fixes[i-1].id,  fix_array.fixes[i-1].id_len),
                lat  = fix_array.fixes[i-1].coords.lat,
                lon  = fix_array.fixes[i-1].coords.lon
            })
        end
        return to_return
    end
end

local function convert_cifp_array(rawdata, cifp_arr)
    if rawdata then
        return {
            data = cifp_arr.data,
            len  = cifp_arr.len
        }
    end
    
    to_return = {}
    for i=1,cifp_arr.len do
        local new_dat =  {
            type        = ("").char(cifp_arr.data[i-1].type),
            proc_name   = ffi.string(cifp_arr.data[i-1].proc_name,  cifp_arr.data[i-1].proc_name_len),
            trans_name  = ffi.string(cifp_arr.data[i-1].trans_name,  cifp_arr.data[i-1].trans_name_len),
            legs = {}
        }
        
        for j=1,cifp_arr.data[i-1].legs_len do
            local l = cifp_arr.data[i-1].legs[j-1]
            table.insert(new_dat.legs, {
                leg_name = ffi.string(l.leg_name, l.leg_name_len),
                turn_direction = l.turn_direction,
                leg_type = l.leg_type,
                radius = l.radius,
                theta = l.theta,
                rho = l.rho,
                outb_mag = l.outb_mag,
                rte_hold = l.rte_hold,
                outb_mag_in_true = l.outb_mag_in_true,
                rte_hold_in_time = l.rte_hold_in_time,
                cstr_alt_type = l.cstr_alt_type,
                cstr_altitude1 = l.cstr_altitude1,
                cstr_altitude2 = l.cstr_altitude2,
                cstr_speed_type = l.cstr_speed_type,
                cstr_speed = l.cstr_speed,
                vpath_angle = l.vpath_angle,
                center_fix = ffi.string(l.center_fix, l.center_fix_len)
            })
        end
        
        table.insert(to_return, new_dat)
    end
    return to_return
end

local function convert_single_apt(apt, load_rwys)
    local new_apt = {
        ref_orig = apt,
        id   = ffi.string(apt.id,  apt.id_len),
        name = ffi.string(apt.full_name, apt.full_name_len),
        alt  = apt.altitude,
        lat  = apt.apt_center.lat,
        lon  = apt.apt_center.lon,
        rwys = {}
    };

    if not load_rwys then
        return new_apt
    end

    for j=1,apt.rwys_len do
        local rwy_lat = apt.rwys[j-1].coords.lat
        local rwy_lon = apt.rwys[j-1].coords.lon
        local rwy_lat_s = apt.rwys[j-1].sibl_coords.lat
        local rwy_lon_s = apt.rwys[j-1].sibl_coords.lon
        
        table.insert(new_apt.rwys, {
            name     = ffi.string(apt.rwys[j-1].name),
            sibl_name= ffi.string(apt.rwys[j-1].sibl_name),
            lat      = rwy_lat,
            lon      = rwy_lon,
            s_lat    = rwy_lat_s,
            s_lon    = rwy_lon_s,
            bearing  = get_earth_bearing(rwy_lat,rwy_lon,rwy_lat_s,rwy_lon_s),
            distance = GC_distance_km(rwy_lat,rwy_lon,rwy_lat_s,rwy_lon_s) * 1000,
            width    = apt.rwys[j-1].width,
            surf_type= apt.rwys[j-1].surface_type,
            has_ctr_lights = apt.rwys[j-1].has_ctr_lights
        })
    end
    return new_apt
end

local function convert_apts_array(rawdata, fix_array)
    if rawdata then
        return {
            apts  = apt_array.apts,
            len   = apt_array.len
        }
    else
        to_return = {}
        for i=1,apt_array.len do
            local new_apt = convert_single_apt(apt_array.apts[i-1], true)
            
            table.insert(to_return, new_apt)
        end
        return to_return
    end
end

local function expose_functions()

    AvionicsBay.is_initialized = function()
        return initialized
    end

    AvionicsBay.get_error = function()
        return ffi.string(AvionicsBay.c.get_error())
    end
    
    AvionicsBay.is_ready = function()
        return AvionicsBay.c.xpdata_is_ready()
    end
    
    AvionicsBay.navaids = {}
    AvionicsBay.navaids.get_by_name = function(nav_type, name, rawdata)
        assert(initialized, "You must initialize avionicsbay before use")
        assert(type(nav_type) == "number", "nav_type must be a number")
        assert(type(name) == "string", "name must be a string")
        rawdata = rawdata or false
        
        nav_array = AvionicsBay.c.get_navaid_by_name(nav_type, name);
        return convert_navaid_array(rawdata, nav_array)
    end
    
    AvionicsBay.navaids.get_by_freq = function(nav_type, freq, rawdata)
        assert(initialized, "You must initialize avionicsbay before use")
        assert(type(nav_type) == "number", "nav_type must be a number")
        assert(type(freq) == "number", "name must be a number")
        rawdata = rawdata or false
        
        nav_array = AvionicsBay.c.get_navaid_by_freq(nav_type, math.floor(freq));
        return convert_navaid_array(rawdata, nav_array)
    end
    
    AvionicsBay.navaids.get_by_coords = function(nav_type, lat, lon, rawdata)
        assert(initialized, "You must initialize avionicsbay before use")
        assert(type(nav_type) == "number", "nav_type must be a number")
        assert(type(lat) == "number", "lat must be a string")
        assert(type(lon) == "number", "lon must be a string")
        rawdata = rawdata or false

        nav_array = AvionicsBay.c.get_navaid_by_coords(nav_type, lat, lon);
        return convert_navaid_array(rawdata, nav_array)
    end
    
    
    AvionicsBay.fixes = {}
    AvionicsBay.fixes.get_by_name = function(name, rawdata)
        assert(initialized, "You must initialize avionicsbay before use")
        assert(type(name) == "string", "name must be a string")
        rawdata = rawdata or false
        
        fix_array = AvionicsBay.c.get_fixes_by_name(name);
        return convert_fixes_array(rawdata, fix_array)
    end
    
    AvionicsBay.fixes.get_by_coords = function(lat, lon, rawdata)
        assert(initialized, "You must initialize avionicsbay before use")
        assert(type(lat) == "number", "lat must be a string")
        assert(type(lon) == "number", "lon must be a string")
        rawdata = rawdata or false

        fix_array = AvionicsBay.c.get_fixes_by_coords(lat, lon);
        return convert_fixes_array(rawdata, fix_array)
    end

    AvionicsBay.apts = {}
    AvionicsBay.apts.get_by_name = function(name, rawdata)
        assert(initialized, "You must initialize avionicsbay before use")
        assert(type(name) == "string", "name must be a string")
        rawdata = rawdata or false
        
        apt_array = AvionicsBay.c.get_apts_by_name(name);
        return convert_apts_array(rawdata, apt_array)
    end
    
    AvionicsBay.apts.get_by_coords = function(lat, lon, rawdata)
        assert(initialized, "You must initialize avionicsbay before use")
        assert(type(lat) == "number", "lat must be a string")
        assert(type(lon) == "number", "lon must be a string")
        rawdata = rawdata or false

        apt_array = AvionicsBay.c.get_apts_by_coords(lat, lon);
        return convert_apts_array(rawdata, apt_array)
    end

    AvionicsBay.apts.is_nearest_apt_computed = function()
        return AvionicsBay.c.get_nearest_apt() ~= nil
    end

    AvionicsBay.apts.get_nearest_apt = function(load_rwys)
        local apt = AvionicsBay.c.get_nearest_apt()
        if apt == nil then
            return nil
        else
            return convert_single_apt(apt, load_rwys)
        end
    end
    
    AvionicsBay.apts.request_details = function(apt_name)
        assert(type(apt_name) == "string", "name must be a string")
        AvionicsBay.c.request_apts_details(apt_name);
    end
    
    AvionicsBay.apts.details_available = function(apt_name)
        assert(type(apt_name) == "string", "name must be a string")
        return AvionicsBay.c.get_apts_by_name(apt_name).apts[0].is_loaded_details
    end

    AvionicsBay.apts.get_details = function(apt_name)
        assert(type(apt_name) == "string", "name must be a string")
        return AvionicsBay.c.get_apts_by_name(apt_name).apts[0].details
    end
    
    AvionicsBay.apts.get_route = function(apt_raw, route_id) 
        return AvionicsBay.c.get_route_pos(apt_raw, route_id)
    end

    AvionicsBay.graphics = {}
    AvionicsBay.graphics.triangulate_apt_node = function(array)
        return AvionicsBay.c.triangulate(array);
    end

    AvionicsBay.cifp = {}
    AvionicsBay.cifp.is_ready = function()
        return AvionicsBay.c.is_cifp_ready()
    end

    AvionicsBay.cifp.load_apt = function(arpt_id)
        assert(AvionicsBay.c.is_cifp_ready())
        assert(type(arpt_id) == "string", "name must be a string")
        AvionicsBay.c.load_cifp(arpt_id)
    end

    AvionicsBay.cifp.get = function(arpt_id, rawdata)
        assert(AvionicsBay.c.is_cifp_ready())
        assert(type(arpt_id) == "string", "name must be a string")
        rawdata = rawdata or false
        local cifp_data = AvionicsBay.c.get_cifp(arpt_id)
        
        return {
            sids  = convert_cifp_array(rawdata, cifp_data.sids),
            stars = convert_cifp_array(rawdata, cifp_data.stars),
            apprs = convert_cifp_array(rawdata, cifp_data.apprs)
        }
    end


end

local function load_avionicsbay()
    local os_name = sasl.getOS()
    local path = ""
    
    if os_name == "Linux" then
        path = sasl.getAircraftPath() .. "/plugins/avionicsbay/libavionicsbay.so"
    elseif os_name == "Windows" then
        path = sasl.getAircraftPath() .. "/plugins/avionicsbay/libavionicsbay.dll"
    elseif os_name == "Mac" then
        path = sasl.getAircraftPath() .. "/plugins/avionicsbay/libavionicsbay.dylib"
    else
        assert(false) -- This should never happen
    end

    ffi.cdef(require("avionics_bay_include"))

    AvionicsBay.c = ffi.load(path)
    
    if not AvionicsBay.c then
        logWarning("Unable to laod AvionicsBay FFI library.")
    end
    
    if AvionicsBay.c.initialize(sasl.getXPlanePath(), sasl.getAircraftPath() .. "/") then
        initialized = true
    else
        initialized = false
        logWarning("Avionics Bay NOT initialized.")
    end
    
    expose_functions()

    
end

if not disable_avionicsbay then
    load_avionicsbay()
else
    AvionicsBay.is_initialized = function() return false end
    logWarning("AvionicsBay is disabled.")
end

function update()
    if not disable_avionicsbay then
        AvionicsBay.c.set_acf_coords(get(Aircraft_lat), get(Aircraft_long));
    end
end

function onModuleShutdown()
    if initialized then
        print("Cleaning...")
        AvionicsBay.c.terminate()
    end
end
