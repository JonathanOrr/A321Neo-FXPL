----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

local NAV_FILE_PATH = sasl.getXPlanePath() .. "Resources/default data/earth_nav.dat"
local FIX_FILE_PATH = sasl.getXPlanePath() .. "Resources/default data/earth_fix.dat"

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------

local time_to_initialize_nav = 0
local time_to_initialize_fix = 0
local time_to_reshape_freq = 0
local time_to_reshape_coordinates = 0
local time_to_reshape_coordinates_fix = 0

----------------------------------------------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------------------------------------------

local function char_at(str, index)
	return string.sub(str, index, index)
end

local function str_split (inputstr, sep) -- Split a string into a vector of elements
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end


----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

Data_manager._parse_line_nav = function(line)
    local splitted = str_split(line)
    local id = tonumber(splitted[1])

    if id == nil or ((id < NAV_ID_NDB or id > NAV_ID_IM) and (id < NAV_ID_DME or id > NAV_ID_DME_ALONE)) then
        return  -- Not a valid line / something not interesting
    end

    local navaid_name = splitted[8]
    local full_name = table.concat(splitted, " ", 11)

    Data_manager._nav[id][navaid_name]  = {
        id   = navaid_name,
        lat  = tonumber(splitted[2]),
        lon  = tonumber(splitted[3]),
        alt  = tonumber(splitted[4]),
        freq = tonumber(splitted[5]),
        name = full_name
    }
end

Data_manager._parse_line_fix = function(line)
    local splitted = str_split(line)

    if #splitted ~= 6 then
        return  -- Not a valid line / something not interesting
    end

    local navaid_name = splitted[3]

    Data_manager._fix[navaid_name]  = {
        id   = navaid_name,
        lat  = tonumber(splitted[1]),
        lon  = tonumber(splitted[2]),
        type = tonumber(splitted[6])
    }
end

Data_manager._initialize_nav = function()

    Data_manager._nav = {} -- This will contain all the navaids, the only one it contains the data

    local list_ids = {NAV_ID_NDB, NAV_ID_VOR, NAV_ID_LOC, NAV_ID_LOC_ALONE, NAV_ID_GS, NAV_ID_OM, NAV_ID_MM, NAV_ID_IM, NAV_ID_DME, NAV_ID_DME_ALONE}

    for i,nav_type in ipairs(list_ids) do
        Data_manager._nav[nav_type] = {}
    end

    local file = io.open(NAV_FILE_PATH, "r")
    if file == nil then
        logWarning("Unable to load the NAV file")
        return
    end

    file:close()

    for line in io.lines(NAV_FILE_PATH) do
        if char_at(line, 1) ~= "I" then
            Data_manager._parse_line_nav(line)
        end        
    end
end

Data_manager._initialize_fix = function()

    Data_manager._fix = {} -- This will contain all the fixes

    local file = io.open(FIX_FILE_PATH, "r")
    if file == nil then
        logWarning("Unable to load the FIX file")
        return
    end

    file:close()

    for line in io.lines(FIX_FILE_PATH) do
        if char_at(line, 1) ~= "I" then
            Data_manager._parse_line_fix(line)
        end        
    end
end

Data_manager._reshape_nav_freq = function()
    Data_manager._nav_by_freq = {}
    
    local list_ids = {NAV_ID_NDB, NAV_ID_VOR, NAV_ID_LOC, NAV_ID_LOC_ALONE, NAV_ID_GS, NAV_ID_DME, NAV_ID_DME_ALONE}
    
    for i,nav_type in ipairs(list_ids) do
        Data_manager._nav_by_freq[nav_type] = {}
    end
    
    for i,nav_type in ipairs(list_ids) do
        for k,x in pairs(Data_manager._nav[nav_type]) do
            if Data_manager._nav_by_freq[nav_type][x.freq] == nil then
                Data_manager._nav_by_freq[nav_type][x.freq] = {}
            end
            table.insert(Data_manager._nav_by_freq[nav_type][x.freq], x)
        end
    end

end

Data_manager._reshape_nav_coords = function()
    Data_manager._nav_by_coords = {}

    local list_ids = {NAV_ID_NDB, NAV_ID_VOR, NAV_ID_LOC, NAV_ID_LOC_ALONE, NAV_ID_GS, NAV_ID_OM, NAV_ID_MM, NAV_ID_IM, NAV_ID_DME, NAV_ID_DME_ALONE}
    
    for i,nav_type in ipairs(list_ids) do
        Data_manager._nav_by_coords[nav_type] = {}
    end
    
    for i,nav_type in ipairs(list_ids) do
        for k,x in pairs(Data_manager._nav[nav_type]) do

            local lat = math.floor(x.lat + 90)
            local lon = math.floor(x.lon + 180)

            local lat = lat - (lat % 2)
            local lon = lon - (lon % 2)


            if Data_manager._nav_by_coords[nav_type][lat] == nil then
                Data_manager._nav_by_coords[nav_type][lat] = {}
            end

            if Data_manager._nav_by_coords[nav_type][lat][lon] == nil then
                Data_manager._nav_by_coords[nav_type][lat][lon] = {}
            end

            table.insert(Data_manager._nav_by_coords[nav_type][lat][lon], x)
        end
    end

end

Data_manager._reshape_fix_coords = function()
    Data_manager._fix_by_coords = {}

    for k,x in pairs(Data_manager._fix) do

        local lat = math.floor(x.lat + 90)
        local lon = math.floor(x.lon + 180)

        local lat = lat - (lat % 2)
        local lon = lon - (lon % 2)


        if Data_manager._fix_by_coords[lat] == nil then
            Data_manager._fix_by_coords[lat] = {}
        end

        if Data_manager._fix_by_coords[lat][lon] == nil then
            Data_manager._fix_by_coords[lat][lon] = {}
        end

        table.insert(Data_manager._fix_by_coords[lat][lon], x)
    end

end

Data_manager.initialize = function()
    if disable_data_manager then
        return -- Manually disabled
    end 
    Data_manager._initialize_nav()
    Data_manager._reshape_nav_freq()
    Data_manager._reshape_nav_coords()
    Data_manager._initialize_fix()
    Data_manager._reshape_fix_coords()
end

Data_manager.get_fix_by_coords = function(lat, lon)
    if disable_data_manager then
        return {}
    end

    return Data_manager._fix_by_coords[math.floor(lat)+90][math.floor(lon)+180]
end

Data_manager.get_nav_by_coords = function(navtype, lat, lon)
    if disable_data_manager then
        return {}
    end

    lat = math.floor(lat) + 90
    lon = math.floor(lon) + 180
    lat = lat - (lat % 2)
    lon = lon - (lon % 2)
    return Data_manager._nav_by_coords[navtype][lat][lon]
end

Data_manager.get_nav_by_freq = function(navtype, freq) -- In 10Khz format, e.g. 12550 = 125.5
    if disable_data_manager then
        return {}
    end

    return Data_manager._nav_by_freq[navtype][math.floor(freq)]
end

Data_manager.get_nav_by_name = function(navtype, name)
    if disable_data_manager then
        return {}
    end

    return Data_manager._nav[navtype][name]
end

-- Example:
-- Data_manager.initialize()
-- Data_manager.get_nav_by_name(NAV_ID_VOR, "SRN")


