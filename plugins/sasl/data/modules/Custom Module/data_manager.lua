----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

include('libs/table.save.lua')

local NAV_FILE_PATH  = sasl.getXPlanePath() .. "Resources/default data/earth_nav.dat"
local FIX_FILE_PATH  = sasl.getXPlanePath() .. "Resources/default data/earth_fix.dat"
local ARPT_FILE_PATH  = sasl.getXPlanePath() .. "Resources/default scenery/default apt dat/Earth nav data/apt.dat"
--local ARPT_FILE_PATH = "/usr/share/X-Plane 11/temp.apt"
--Data_manager = {}

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------

local init_step = 0
local current_apt = ""
local current_obj = {}
local current_color = 0
local ROW_TAXI  = 1
local ROW_BOUND = 2
local ROW_LINE  = 3
local what_iam_in = 0

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

local function get_first_num(inputstr, start_pos)
    local len = #inputstr
    local i = start_pos
    while i <= len do
        local char = char_at(inputstr,i)
        if char == " " or char == "\t" or char == nil then
            break
        end
        i = i + 1
    end
    return string.sub(inputstr, start_pos, i-1)
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

            local lat = lat - (lat % 4)
            local lon = lon - (lon % 4)


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

        local lat = lat - (lat % 4)
        local lon = lon - (lon % 4)


        if Data_manager._fix_by_coords[lat] == nil then
            Data_manager._fix_by_coords[lat] = {}
        end

        if Data_manager._fix_by_coords[lat][lon] == nil then
            Data_manager._fix_by_coords[lat][lon] = {}
        end

        table.insert(Data_manager._fix_by_coords[lat][lon], x)
    end

end

Data_manager._parse_line_arpt_header = function(curr_seek, splitted)
    local apt_alt = tonumber(splitted[2])
    local icao_id = splitted[5]
    local apt_name = table.concat(splitted, " ", 6)
    
    current_apt = icao_id
    
    Data_manager._arpt[icao_id] = {
        id = icao_id,
        file_seek = curr_seek,
        name     = apt_name,
        altitude = apt_alt,
        rwys = {},
        taxys      = {},
        bounds     = {},
        mark_lines = {},
        signs      = {}
    }
end

Data_manager._parse_line_arpt_runway = function(splitted)
    local rwy_width  = tonumber(splitted[2])
    local rwy_surface = tonumber(splitted[3])
    local rwy_has_ctr_lights = splitted[6] == "1"
    local rwy_side_1_name = splitted[9]
    local rwy_side_1_lat = tonumber(splitted[10])
    local rwy_side_1_lon = tonumber(splitted[11])
    local rwy_side_1_disp_thr = tonumber(splitted[12])
    local rwy_side_1_overrun  = tonumber(splitted[13])

    local rwy_side_2_name = splitted[18]
    local rwy_side_2_lat = tonumber(splitted[19])
    local rwy_side_2_lon = tonumber(splitted[20])
    local rwy_side_2_disp_thr = tonumber(splitted[21])
    local rwy_side_2_overrun  = tonumber(splitted[22])
    
    Data_manager._arpt[current_apt].lat = (rwy_side_1_lat+rwy_side_2_lat) / 2
    Data_manager._arpt[current_apt].lon = (rwy_side_1_lon+rwy_side_2_lon) / 2
    
    Data_manager._arpt[current_apt].rwys[rwy_side_1_name] = {
        sibling  = rwy_side_2_name,
        width   = rwy_width,
        surface  = rwy_surface,
        has_ctr_lights = rwy_has_ctr_lights,
        lat      = rwy_side_1_lat,
        lon      = rwy_side_1_lon,
        disp_thr = rwy_side_1_disp_thr,
        overrun  = rwy_side_1_overrun
    }
    
    Data_manager._arpt[current_apt].rwys[rwy_side_2_name] = {
        sibling  = rwy_side_1_name,
        width    = rwy_width,
        surface  = rwy_surface,
        has_ctr_lights = rwy_has_ctr_lights,
        lat      = rwy_side_2_lat,
        lon      = rwy_side_2_lon,
        disp_thr = rwy_side_2_disp_thr,
        overrun  = rwy_side_2_overrun
    }

end

Data_manager._save_arpt_node = function()
    if what_iam_in == ROW_TAXI then
        table.insert(Data_manager._arpt[current_apt].taxys, { color = current_color, points = current_obj })
    elseif what_iam_in == ROW_BOUND then
        table.insert(Data_manager._arpt[current_apt].bounds, { color = current_color, points = current_obj })    
    elseif what_iam_in == ROW_LINE then
        table.insert(Data_manager._arpt[current_apt].mark_lines, { color = current_color, points = current_obj })
    end
    current_obj = {}
end

Data_manager._parse_line_arpt_node_linear_start = function(splitted)
    table.insert(current_obj, {tonumber(splitted[2]), tonumber(splitted[3])})
    current_color = tonumber(splitted[4])
end

Data_manager._parse_line_arpt_node_beizer_start = function(splitted)
    table.insert(current_obj, {tonumber(splitted[2]), tonumber(splitted[3]), tonumber(splitted[4]), tonumber(splitted[5])})
    current_color = tonumber(splitted[6])
end

Data_manager._parse_line_arpt_node_linear_end = function(splitted)
    Data_manager._parse_line_arpt_node_linear_start(splitted)
    Data_manager._save_arpt_node()
end

Data_manager._parse_line_arpt_node_linear_close = function(splitted)
    Data_manager._parse_line_arpt_node_linear_start(splitted)
    table.insert(current_obj, current_obj[1])
    Data_manager._save_arpt_node()
end

Data_manager._parse_line_arpt_node_beizer_end = function(splitted)
    Data_manager._parse_line_arpt_node_beizer_start(splitted)
    Data_manager._save_arpt_node()
end

Data_manager._parse_line_arpt_node_beizer_close = function(splitted)
    Data_manager._parse_line_arpt_node_beizer_start(splitted)
    table.insert(current_obj, current_obj[1])
    Data_manager._save_arpt_node()
end

Data_manager._parse_line_arpt_sign = function(splitted)
    local sign_lat = tonumber(splitted[2])
    local sign_lon = tonumber(splitted[3])
    local sign_orient = tonumber(splitted[4])
    local sign_text = splitted[7]

    table.insert(Data_manager._arpt[current_apt].signs, {lat = sign_lat, lon = sign_lon, orient = sign_orient, text = sign_text})

end

Data_manager._parse_line_arpt_generic = function(curr_seek, line)
    if #line < 1 then
        return
    end
    local id = get_first_num(line, 1)

    if id == "1" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_header(curr_seek, splitted)
    elseif id == "100" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_runway(splitted)
--[[    elseif id == "110" then -- Taxyways
        what_iam_in = ROW_TAXI
    elseif id == "120" then -- Linear feature
        what_iam_in = ROW_LINE
    elseif id == "130" then -- Linear feature
        what_iam_in = ROW_BOUND
    elseif id == "111" then
        Data_manager._parse_line_arpt_node_linear_start(splitted)
    elseif id == "112" then
        Data_manager._parse_line_arpt_node_beizer_start(splitted)
    elseif id == "113" then
        Data_manager._parse_line_arpt_node_linear_close(splitted)
    elseif id == "114" then
        Data_manager._parse_line_arpt_node_beizer_close(splitted)
    elseif id == "115" then
        Data_manager._parse_line_arpt_node_linear_end(splitted)
    elseif id == "116" then
        Data_manager._parse_line_arpt_node_beizer_end(splitted)
    elseif id == "20" then
        Data_manager._parse_line_arpt_sign(splitted)
        ]]--
    end
end

Data_manager._initialize_arpt = function()
    
    Data_manager._arpt = {} -- This will contain all the airports
    
    local file = io.open(ARPT_FILE_PATH, "r")
    if file == nil then
        logWarning("Unable to load the FIX file")
        return
    end

    local curr_seek = file:seek()    

    for line in file:lines() do
        Data_manager._parse_line_arpt_generic(curr_seek, line)
        curr_seek = file:seek()
    end

    file:close()
end

Data_manager._reshape_arpt_coords = function()
    Data_manager._arpt_by_coords = {}

    for k,x in pairs(Data_manager._arpt) do

        if x.lat ~= nil and x.lon ~= nil then

            local lat = math.floor(x.lat + 90)
            local lon = math.floor(x.lon + 180)

            local lat = lat - (lat % 4)
            local lon = lon - (lon % 4)

            if Data_manager._arpt_by_coords[lat] == nil then
                Data_manager._arpt_by_coords[lat] = {}
            end

            if Data_manager._arpt_by_coords[lat][lon] == nil then
                Data_manager._arpt_by_coords[lat][lon] = {}
            end

            table.insert(Data_manager._arpt_by_coords[lat][lon], x)
        end
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
    Data_manager._initialize_arpt()
    Data_manager._reshape_arpt_coords()
end

local function get_safe_arpt_coords(lat, lon)
    if Data_manager._arpt_by_coords ~= nil then
        if Data_manager._arpt_by_coords[lat] ~= nil then
            if Data_manager._arpt_by_coords[lat][lon] ~= nil then
                return Data_manager._arpt_by_coords[lat][lon]
            end
        end
    end
    return {}
end

Data_manager.get_arpt_by_coords = function(lat, lon, more_than_180)
    if disable_data_manager or init_step < 2  then
        return {}
    end
    
    lat = math.floor(lat) + 90
    lon = math.floor(lon) + 180
    lat = lat - (lat % 4)
    lon = lon - (lon % 4)
    
    local return_table = {}

    table.insert(return_table, get_safe_arpt_coords(lat, lon))
    
    if more_than_180 then
        if lon < 360 then table.insert(return_table, get_safe_arpt_coords(lat, lon+4)) end
        if lat < 180 then table.insert(return_table, get_safe_arpt_coords(lat+4, lon)) end
        if lon < 360 and lat < 180 then table.insert(return_table, get_safe_arpt_coords(lat+4, lon+4)) end
        if lon > 0 then table.insert(return_table, get_safe_arpt_coords(lat, lon-4)) end
        if lat > 0 then table.insert(return_table, get_safe_arpt_coords(lat-4, lon)) end
        if lat > 0 and lon > 0 then table.insert(return_table, get_safe_arpt_coords(lat-4, lon-4)) end
    end
        
    return return_table
end


Data_manager.get_fix_by_coords = function(lat, lon, more_than_180)
    if disable_data_manager or init_step < 2 then
        return {}
    end
    
    lat = math.floor(lat) + 90
    lon = math.floor(lon) + 180
    lat = lat - (lat % 4)
    lon = lon - (lon % 4)
    
    local return_table = {}
    table.insert(return_table, Data_manager._fix_by_coords[lat][lon])
    
    if more_than_180 then
        if lon < 360 then table.insert(return_table, Data_manager._fix_by_coords[lat][lon+4]) end
        if lat < 180 then table.insert(return_table, Data_manager._fix_by_coords[lat+4][lon]) end
        if lon < 360 and lat < 180 then table.insert(return_table, Data_manager._fix_by_coords[lat+4][lon+4]) end
        if lon > 0 then table.insert(return_table, Data_manager._fix_by_coords[lat][lon-4]) end
        if lat > 0 then table.insert(return_table, Data_manager._fix_by_coords[lat-4][lon]) end
        if lat > 0 and lon > 0 then table.insert(return_table, Data_manager._fix_by_coords[lat-4][lon-4]) end
    end
        
    return return_table
end

Data_manager.get_nav_by_coords = function(navtype, lat, lon, more_than_180)
    if disable_data_manager or init_step < 2 then
        return {}
    end

    lat = math.floor(lat) + 90
    lon = math.floor(lon) + 180
    lat = lat - (lat % 4)
    lon = lon - (lon % 4)
    
    local return_table = {}
    table.insert(return_table, Data_manager._nav_by_coords[navtype][lat][lon])
    
    if more_than_180 then
        if lon < 360 then table.insert(return_table, Data_manager._nav_by_coords[navtype][lat][lon+4]) end
        if lat < 180 then table.insert(return_table, Data_manager._nav_by_coords[navtype][lat+4][lon]) end
        if lon < 360 and lat < 180 then table.insert(return_table, Data_manager._nav_by_coords[navtype][lat+4][lon+4]) end
        if lon > 0 then table.insert(return_table, Data_manager._nav_by_coords[navtype][lat][lon-4]) end
        if lat > 0 then table.insert(return_table, Data_manager._nav_by_coords[navtype][lat-4][lon]) end
        if lat > 0 and lon > 0 then table.insert(return_table, Data_manager._nav_by_coords[navtype][lat-4][lon-4]) end
    end
    
    return return_table
end

Data_manager.get_nav_by_freq = function(navtype, freq) -- In 10Khz format, e.g. 12550 = 125.5
    if disable_data_manager or init_step < 2 then
        return {}
    end

    return Data_manager._nav_by_freq[navtype][math.floor(freq)]
end

Data_manager.get_nav_by_name = function(navtype, name)
    if disable_data_manager or init_step < 2 then
        return {}
    end

    return Data_manager._nav[navtype][name]
end

Data_manager.get_fix_by_name = function(name)
    if disable_data_manager or init_step < 2 then
        return {}
    end

    return Data_manager._fix[name]
end

Data_manager.get_arpt_by_name = function(name)
    if disable_data_manager or init_step < 2 then
        return {}
    end

    return Data_manager._arpt[name]
end

Data_manager.nearest_airport = nil
Data_manager.nearest_airport_update = 0

local function update_init()
    if init_step == 0 then
        Welcome_window:setIsVisible(true)
        init_step = 1
    elseif init_step == 1 then
        Data_manager.initialize()
        init_step = 2
        Welcome_window:setIsVisible(false)
    end
end


local function find_nearest_airport()
    local nearest = nil
    local distance = 99999999
    
    if Data_manager._arpt == nil then
        return nil
    end
    
    for k,airport in pairs(Data_manager._arpt) do
        if airport.lat ~= nil and airport.lon ~= nil then

            if nearest == nil then
                nearest = airport
            else
                new_dist = GC_distance_km(get(Aircraft_lat),get(Aircraft_long),airport.lat,airport.lon)
                if distance > new_dist then
                    distance = new_dist
                    nearest = airport
                end
            end
        end
    end
    
    return nearest
end


local function update_nearest_airport()

    if Data_manager.nearest_airport_update == 0 or get(TIME) - Data_manager.nearest_airport_update > 30 then
        Data_manager.nearest_airport = find_nearest_airport()
        if Data_manager.nearest_airport ~= nil then
            Data_manager.nearest_airport_update = get(TIME)
        end
    end
end

function onAirportLoaded()
    Data_manager.nearest_airport_update = 0
end

function update()
    if disable_data_manager then
        return -- Manually disabled
    end
    
    update_init()
    update_nearest_airport()
    
end

-- Example:
-- Data_manager.initialize()
-- Data_manager.get_nav_by_name(NAV_ID_VOR, "SRN")
--print(collectgarbage("count"))
--Data_manager._initialize_arpt()
--print(collectgarbage("count"))
