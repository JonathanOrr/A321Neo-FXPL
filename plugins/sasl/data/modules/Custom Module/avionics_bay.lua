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

local function convert_apts_array(rawdata, fix_array)
    if rawdata then
        return {
            apts  = apt_array.apts,
            len   = apt_array.len
        }
    else
        to_return = {}
        for i=1,apt_array.len do
            local new_apt = {
                id   = ffi.string(apt_array.apts[i-1].id,  apt_array.apts[i-1].id_len),
                name = ffi.string(apt_array.apts[i-1].full_name, apt_array.apts[i-1].full_name_len),
                alt  = apt_array.apts[i-1].altitude,
                lat  = apt_array.apts[i-1].apt_center.lat,
                lon  = apt_array.apts[i-1].apt_center.lon,
                rwys = {}
            };
            
            for j=1,apt_array.apts[i-1].rwys_len do
                table.insert(new_apt.rwys, {
                    name = ffi.string(apt_array.apts[i-1].rwys[j-1].name),
                    sibl_name = ffi.string(apt_array.apts[i-1].rwys[j-1].sibl_name),
                    lat  = apt_array.apts[i-1].rwys[j-1].coords.lat,
                    lon  = apt_array.apts[i-1].rwys[j-1].coords.lon,
                    s_lat  = apt_array.apts[i-1].rwys[j-1].sibl_coords.lat,
                    s_lon  = apt_array.apts[i-1].rwys[j-1].sibl_coords.lon,
                    width = apt_array.apts[i-1].rwys[j-1].width,
                    surf_type = apt_array.apts[i-1].rwys[j-1].surface_type,
                    has_ctr_lights = apt_array.apts[i-1].rwys[j-1].has_ctr_lights
                })
            end
            
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

    ffi.cdef[[
        typedef int xpdata_navaid_type_t;

        typedef struct xpdata_coords_t {
            double lat;
            double lon;
        } xpdata_coords_t;
        typedef struct xpdata_navaid_t {
            const char *id;         // e.g., SRN
            int id_len;
            const char *full_name;  // e.g., Saronno VOR
            int full_name_len;
            xpdata_navaid_type_t type; // Constants NAV_ID_* 
            xpdata_coords_t coords;
            int altitude;
            unsigned int frequency;
            bool is_coupled_dme;    // True if the vor is coupled with DME
        } xpdata_navaid_t;

        typedef struct xpdata_navaid_array_t {
            const struct xpdata_navaid_t * const * navaids;
            int len;
        } xpdata_navaid_array_t;


        typedef struct xpdata_fix_t {
            const char *id;         // e.g., ROMEO
            int id_len;
            xpdata_coords_t coords;
        } xpdata_fix_t;

        typedef struct xpdata_fix_array_t {
            const struct xpdata_fix_t * const * fixes;
            int len;
        } xpdata_fix_array_t;


        typedef struct xpdata_apt_rwy_t {
            char name[4];
            char sibl_name[4];              // On the other head of the runway

            xpdata_coords_t coords;
            xpdata_coords_t sibl_coords;    // On the other head of the runway
            
            double width;
            int surface_type;
            bool has_ctr_lights;
            
        } xpdata_apt_rwy_t;

        typedef struct xpdata_apt_t {
            const char *id;         // e.g., LIRF
            int id_len;
            
            const char *full_name;  // e.g., Roma Fiumicino
            int full_name_len;
            
            int altitude;

            const xpdata_apt_rwy_t *rwys;
            int rwys_len;
            
            xpdata_coords_t apt_center;
            
            long pos_seek;   // For internal use only, do not modify this value
            
        } xpdata_apt_t;

        typedef struct xpdata_apt_array_t {
            const struct xpdata_apt_t * const * apts;
            int len;
        } xpdata_apt_array_t;

        bool initialize(const char*);
        const char* get_error(void);
        xpdata_navaid_array_t get_navaid_by_name(xpdata_navaid_type_t type, const char* name);
        xpdata_navaid_array_t get_navaid_by_freq  (xpdata_navaid_type_t, unsigned int);
        xpdata_navaid_array_t get_navaid_by_coords(xpdata_navaid_type_t, double, double);
        xpdata_fix_array_t get_fixes_by_name  (const char*);
        xpdata_fix_array_t get_fixes_by_coords(double, double);
        xpdata_apt_array_t get_apts_by_name  (const char*);
        xpdata_apt_array_t get_apts_by_coords(double, double);
        bool xpdata_is_ready(void);
    ]]

    AvionicsBay.c = ffi.load(path)
    
    if AvionicsBay.c.initialize(sasl.getXPlanePath ()) then
        initialized = true
        print("Initialized")
    else
        initialized = false
        print("not Initialized")
    end
    
    expose_functions()

    
end


load_avionicsbay()
