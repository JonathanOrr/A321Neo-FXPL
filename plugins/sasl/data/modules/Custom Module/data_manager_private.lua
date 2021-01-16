
----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

local NAV_FILE_PATH  = sasl.getXPlanePath() .. "Resources/default data/earth_nav.dat"
local FIX_FILE_PATH  = sasl.getXPlanePath() .. "Resources/default data/earth_fix.dat"
local ARPT_FILE_PATH  = sasl.getXPlanePath() .. "Resources/default scenery/default apt dat/Earth nav data/apt.dat"
--local ARPT_FILE_PATH = "/usr/share/X-Plane 11/test.apt"

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------

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
    
    if #splitted < 5 then
        return  -- Invalid data
    end
    
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

    if #splitted < 5 then
        return  -- Invalid data
    end


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
        signs      = {},
        routes     = {},
        taxi_routes= {},
        tower      = {}
    }
end

Data_manager._parse_line_arpt_runway = function(splitted)
    if #splitted < 22 then
        return  -- Bad line
    end
    
    local rwy_surface = tonumber(splitted[3])
    if rwy_surface ~= 1 and rwy_surface ~= 2 and rwy_surface ~= 14 and rwy_surface ~= 15 then
        return -- Do not consider if it's not a asphalt, concrete, snow, or transparent (custom scenery) runway
    end 

    local rwy_width  = tonumber(splitted[2])

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
    if splitted[4] then
        current_color = tonumber(splitted[4])
    end
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
    Data_manager._save_arpt_node()
end

Data_manager._parse_line_arpt_node_beizer_end = function(splitted)
--    Data_manager._parse_line_arpt_node_beizer_start(splitted)
    Data_manager._save_arpt_node()
end

Data_manager._parse_line_arpt_node_beizer_close = function(splitted)
--    Data_manager._parse_line_arpt_node_beizer_start(splitted)
    Data_manager._save_arpt_node()
end

Data_manager._parse_line_arpt_sign = function(splitted)
    if #splitted < 7 then
        return  -- Invalid data
    end

    local sign_lat = tonumber(splitted[2])
    local sign_lon = tonumber(splitted[3])
    local sign_orient = tonumber(splitted[4])
    local sign_text = splitted[7]

    table.insert(Data_manager._arpt[current_apt].signs, {lat = sign_lat, lon = sign_lon, orient = sign_orient, text = sign_text})

end

Data_manager._parse_line_arpt_route_point = function(splitted)    
    local route_lat = tonumber(splitted[2])
    local route_lon = tonumber(splitted[3])
    local route_id = tonumber(splitted[5])

    Data_manager._arpt[current_apt].routes[route_id] = {lat = route_lat, lon = route_lon}    
end


Data_manager._parse_line_arpt_route_taxi = function(splitted)    
    local route_id_1 = tonumber(splitted[2])
    local route_id_2 = tonumber(splitted[3])
    local route_name = splitted[6]
    if splitted[5] == "runway" then
        return -- We are not interested in runway, we draw them by ourself
    end

    table.insert(Data_manager._arpt[current_apt].taxi_routes, {point_1 = route_id_1, point_2 = route_id_2, name=route_name})
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
    end
end

Data_manager._parse_line_arpt_tower = function(splitted)
    local lat = tonumber(splitted[2])
    local lon = tonumber(splitted[3])
    Data_manager._arpt[current_apt].tower.lat = lat
    Data_manager._arpt[current_apt].tower.lon = lon
end

Data_manager._parse_line_arpt_detailed = function(apt, line)
    if #line < 1 then
        return
    end
    
    local id = get_first_num(line, 1)

    if id == "1" then
        return true -- Stop
    elseif id == "14" then -- Taxyways
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_tower(splitted)
    elseif id == "110" then -- Taxyways
        what_iam_in = ROW_TAXI
    elseif id == "120" then -- Linear feature
        what_iam_in = ROW_LINE
    elseif id == "130" then -- Linear feature
        what_iam_in = ROW_BOUND
    elseif id == "111" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_node_linear_start(splitted)
    elseif id == "112" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_node_beizer_start(splitted)
    elseif id == "113" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_node_linear_close(splitted)
    elseif id == "114" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_node_beizer_close(splitted)
    elseif id == "115" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_node_linear_end(splitted)
    elseif id == "116" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_node_beizer_end(splitted)
--    elseif id == "20" then    -- This is no more needed
--        local splitted = str_split(line)
--        Data_manager._parse_line_arpt_sign(splitted)
    elseif id == "1201" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_route_point(splitted)    
    elseif id == "1202" then
        local splitted = str_split(line)
        Data_manager._parse_line_arpt_route_taxi(splitted)    
    end

    return false -- Continue to read
end

Data_manager._initialize_arpt = function()
    
    Data_manager._arpt = {} -- This will contain all the airports
    
    local file = io.open(ARPT_FILE_PATH, "rb")  -- rb is necessary for Windows, seek is bugged otherwise
    if file == nil then
        logWarning("Unable to load the APT file")
        return
    end

    local curr_seek = file:seek()

    for line in file:lines() do
        Data_manager._parse_line_arpt_generic(curr_seek, line)
        curr_seek = file:seek()
    end

    file:close()
end

Data_manager._load_detailed_apt = function(apt)
    local file = io.open(ARPT_FILE_PATH, "rb")  -- rb is necessary for Windows, seek is bugged otherwise
    if file == nil then
        logWarning("Unable to load the APT file")
        return
    end
   
    local first_encounter = false -- I need to stop at the second airport
   
    file:seek("set", apt.file_seek)
    current_apt = apt.id
    for line in file:lines() do
        if Data_manager._parse_line_arpt_detailed(apt, line) then
            if first_encounter then
                break
            end
            first_encounter = true
        end
    end
    
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
