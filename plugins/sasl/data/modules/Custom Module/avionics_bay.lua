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

    ffi.cdef[[

        typedef int xpdata_navaid_type_t;

        typedef struct xpdata_coords_t {
            double lat;
            double lon;
        } xpdata_coords_t;

        /******************************* NAVAIDS *******************************/
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

        /******************************* FIXES *******************************/
        typedef struct xpdata_fix_t {
            const char *id;         // e.g., ROMEO
            int id_len;
            xpdata_coords_t coords;
        } xpdata_fix_t;

        typedef struct xpdata_fix_array_t {
            const struct xpdata_fix_t * const * fixes;
            int len;
        } xpdata_fix_array_t;

        /******************************* ARPT *******************************/

        typedef struct xpdata_apt_rwy_t {
            char name[4];
            char sibl_name[4];              // On the other head of the runway

            xpdata_coords_t coords;
            xpdata_coords_t sibl_coords;    // On the other head of the runway
            
            double width;
            int surface_type;
            bool has_ctr_lights;
            
        } xpdata_apt_rwy_t;

        typedef struct xpdata_apt_node_t {

            xpdata_coords_t coords;
            bool is_bez;
            xpdata_coords_t bez_cp;

        } xpdata_apt_node_t;

        typedef struct xpdata_apt_node_array_t {
            int color;
            
            xpdata_apt_node_t *nodes;
            int nodes_len;
            
            struct xpdata_apt_node_array_t *hole; // For linear feature this value is nullptr
        } xpdata_apt_node_array_t;

        typedef struct xpdata_apt_route_t {
            const char *name;
            int name_len;
            int route_node_1;   // Identifiers for the route nodes, to be used with get_route_node()
            int route_node_2;   // Identifiers for the route nodes, to be used with get_route_node()
        } xpdata_apt_route_t;

        typedef struct xpdata_apt_gate_t {
            const char *name;
            int name_len;
            xpdata_coords_t coords;
        } xpdata_apt_gate_t;

        typedef struct xpdata_apt_details_t {
            xpdata_coords_t tower_pos; 

            xpdata_apt_node_array_t *pavements;
            int pavements_len;
            
            xpdata_apt_node_array_t *linear_features;
            int linear_features_len;

            xpdata_apt_node_array_t *boundaries;
            int boundaries_len;

            xpdata_apt_route_t *routes;
            int routes_len;

            xpdata_apt_gate_t  *gates;
            int gates_len;

        } xpdata_apt_details_t;

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
            
            bool is_loaded_details;
            xpdata_apt_details_t *details;
            
        } xpdata_apt_t;

        typedef struct xpdata_apt_array_t {
            const struct xpdata_apt_t * const * apts;
            int len;
        } xpdata_apt_array_t;
        

        typedef struct xpdata_triangulation_t {
            const xpdata_coords_t* points;
            int points_len;
        } xpdata_triangulation_t;

        bool initialize(const char* xplane_path);
        const char* get_error(void);
        void terminate(void);
        xpdata_navaid_array_t get_navaid_by_name  (xpdata_navaid_type_t, const char*);
        xpdata_navaid_array_t get_navaid_by_freq  (xpdata_navaid_type_t, unsigned int);
        xpdata_navaid_array_t get_navaid_by_coords(xpdata_navaid_type_t, double, double);

        xpdata_fix_array_t get_fixes_by_name  (const char*);
        xpdata_fix_array_t get_fixes_by_coords(double, double);

        xpdata_apt_array_t get_apts_by_name  (const char*);
        xpdata_apt_array_t get_apts_by_coords(double, double);

        const xpdata_apt_t* get_nearest_apt();
        void set_acf_coords(double lat, double lon);
        void request_apts_details(const char* arpt_id);
        xpdata_coords_t get_route_pos(const xpdata_apt_t *apt, int route_id);
        xpdata_triangulation_t triangulate(const xpdata_apt_node_array_t* array);
        bool xpdata_is_ready(void);
    ]]

    AvionicsBay.c = ffi.load(path)
    
    if AvionicsBay.c.initialize(sasl.getXPlanePath ()) then
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
