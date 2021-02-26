local initialized = false;
local ffi = require("ffi")
    
local function expose_functions()

    XPFiles.is_initialized = function()
        return initialized
    end

    XPFiles.get_error = function()
        return ffi.string(XPFiles.c.get_error())
    end
    
end

local function load_xpfiles()
    local os_name = sasl.getOS()
    local path = ""
    
    if os_name == "Linux" then
        path = sasl.getAircraftPath() .. "/plugins/xpfiles/libxpfiles.so"
    elseif os_name == "Windows" then
        path = sasl.getAircraftPath() .. "/plugins/xpfiles/libxpfiles.dll"
    elseif os_name == "Mac" then
        path = sasl.getAircraftPath() .. "/plugins/xpfiles/libxpfiles.dylib"
    else
        assert(false) -- This should never happen
    end

    ffi.cdef[[
        bool initialize(void);
        const char* get_error(void);
    ]]

    XPFiles.c = ffi.load(path)
    
    if XPFiles.c.initialize() then
        initialized = true
    else
        initialized = false
    end
    
    expose_functions()
end


load_xpfiles()
