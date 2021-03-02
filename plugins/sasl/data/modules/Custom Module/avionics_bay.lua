local initialized = false;
local ffi = require("ffi")
    
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
        nav_array = AvionicsBay.c.get_navaid_by_name(nav_type, name);

        if rawdata then
            return {
                navaids = nav_array.navaids,
                len = nav_array.len
            }
        else
            to_return = {}
            print(nav_array.len)
            for i=1,nav_array.len do
                table.insert(to_return, {
                    id        = nav_array.navaids[i-1].id,
                    full_name = ffi.string(nav_array.navaids[i-1].full_name, nav_array.navaids[i-1].full_name_len),
                    type      = nav_array.navaids[i-1].type,
                    coords    = { lat = nav_array.navaids[i-1].coords.lat, lon = nav_array.navaids[i-1].coords.lon },
                    altitude  = nav_array.navaids[i-1].altitude,
                    frequency = nav_array.navaids[i-1].frequency
                })
            end
            return to_return
        end
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
        } xpdata_navaid_t;

        typedef struct xpdata_navaid_array_t {
            const struct xpdata_navaid_t * const * navaids;
            int len;
        } xpdata_navaid_array_t;

        bool initialize(const char*);
        const char* get_error(void);
        xpdata_navaid_array_t get_navaid_by_name(xpdata_navaid_type_t type, const char* name);
        xpdata_navaid_array_t get_navaid_by_freq  (xpdata_navaid_type_t, unsigned int);
        xpdata_navaid_array_t get_navaid_by_coords(xpdata_navaid_type_t, double, double, bool);
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
