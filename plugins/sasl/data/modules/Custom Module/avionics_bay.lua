local initialized = false;
local ffi = require("ffi")

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
                is_coupled_dme = nav_array.navaids[i-1].is_coupled_dme
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

    for j=1,apt.rwys_len do
        table.insert(new_apt.rwys, {
            name = ffi.string(apt.rwys[j-1].name),
            sibl_name = ffi.string(apt.rwys[j-1].sibl_name),
            lat  = apt.rwys[j-1].coords.lat,
            lon  = apt.rwys[j-1].coords.lon,
            s_lat  = apt.rwys[j-1].sibl_coords.lat,
            s_lon  = apt.rwys[j-1].sibl_coords.lon,
            width = apt.rwys[j-1].width,
            surf_type = apt.rwys[j-1].surface_type,
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
    
    if AvionicsBay.c.initialize(sasl.getXPlanePath(), sasl.getAircraftPath() .. "/") then
        initialized = true
    else
        initialized = false
        logWarning("Avionics Bay NOT initialized.")
    end
    
    expose_functions()

    
end


load_avionicsbay()

function update()
    AvionicsBay.c.set_acf_coords(get(Aircraft_lat), get(Aircraft_long));
end

function onModuleShutdown()
    print("Cleaning...")
    AvionicsBay.c.terminate()
end
