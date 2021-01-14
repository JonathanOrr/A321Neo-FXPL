----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

include('data_manager_private.lua')

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------

local init_step = 0

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
