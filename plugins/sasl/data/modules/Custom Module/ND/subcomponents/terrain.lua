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
-- File: terrain.lua
-- Short description: Terrain radar management
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local TERRAIN_WET      = -9999  -- Just a magic number
local TERRAIN_NOTFOUND = -99999 -- Just a magic number

local RESOLUTION_LAT   = 0.01 -- In deg
local RESOLUTION_LON   = 0.01  -- In deg
local MAX_LAT          = 2     -- Number of degrees to load
local MAX_LON          = 2     -- Number of degrees to load


local INV_RESOLUTION_LAT = math.floor(1/RESOLUTION_LAT)
local INV_RESOLUTION_LON = math.floor(1/RESOLUTION_LON)
local NR_TILE_LAT = math.ceil(MAX_LAT / RESOLUTION_LAT)
local NR_TILE_LON = math.ceil(MAX_LON / RESOLUTION_LON)


-------------------------------------------------------------------------------
-- Textures
-------------------------------------------------------------------------------
local image_terrain_red         = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-red.png")
local image_terrain_blue        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-blue.png")
local image_terrain_magenta     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-magenta.png")
local image_terrain_yellow_high = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-high-yellow.png")
local image_terrain_yellow_low  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-low-yellow.png")
local image_terrain_green_high  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-high-green.png")
local image_terrain_green_low   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-low-green.png")


-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------


local function compute_alt_feet(lat, lon)
    x,y,z = sasl.worldToLocal(lat, lon, -100)
    result,locationX,locationY,locationZ,normalX,normalY,normalZ,velocityX,velocityY,velocityZ,isWet = sasl.probeTerrain(x,y, z)

    if result ~= PROBE_HIT_TERRAIN then
        return TERRAIN_NOTFOUND
    end
    if isWet == 1 then
        return TERRAIN_WET
    end
    lat, long, alt = sasl.localToWorld(locationX,locationY,locationZ)
    return alt * 3.28084
end

local function terrain_get_texture(data, terrain_alt)
    local curr_alt = data.inputs.altitude
    local curr_vs  = data.inputs.vs
    if curr_vs < -1000 then
        curr_alt = curr_alt + curr_vs / 2 -- if descending more than 1 000 ft/min, the altitude expected in 30 s
    end

    if terrain_alt == TERRAIN_WET then
        return image_terrain_blue
    elseif terrain_alt == TERRAIN_NOTFOUND then
        return image_terrain_magenta
    elseif terrain_alt > curr_alt + 2000 then
        return image_terrain_red
    elseif  terrain_alt > curr_alt + 1000 then
        return image_terrain_yellow_high
    elseif  terrain_alt > curr_alt - 500 and get(Gear_handle) == 0 then
        return image_terrain_yellow_low
    elseif  terrain_alt > curr_alt - 250 and get(Gear_handle) == 1 then
        return image_terrain_yellow_low
    elseif  terrain_alt > curr_alt - 1000 then
        return image_terrain_green_high
    elseif  terrain_alt > curr_alt - 2000 then
        return image_terrain_green_low
    else
        return nil
    end
end

function update_terrain_altitudes(data)

    -- This function updates the current matrix of altitudes
    -- This is quite expensive but it is called only whe there is a scenery 
    -- load (on startup and when you cross the boundary)

    if ND_terrain.is_ready and get(ND_Capt_Terrain) == 1 and data.id == ND_FO then
        return  -- FO/ND should not update the terrain altitudes if the capt ND is active
    end

    ND_terrain.is_ready = false
    ND_terrain.altitudes = {}

    local start_lat = get(Aircraft_lat)  - math.fmod(get(Aircraft_lat), RESOLUTION_LAT) - MAX_LAT/2
    local start_lon = get(Aircraft_long) - math.fmod(get(Aircraft_long), RESOLUTION_LON) - MAX_LON/2


    ND_terrain.altitudes_start = {start_lat, start_lon}

    for i=0,NR_TILE_LAT do
        ND_terrain.altitudes[i] = {}
        curr_lon = start_lon
        for j=0,NR_TILE_LON do
            ND_terrain.altitudes[i][j] = compute_alt_feet(start_lat, curr_lon)
            curr_lon = curr_lon + RESOLUTION_LON
        end
        start_lat = start_lat + RESOLUTION_LAT
    end

    ND_terrain.is_ready = true
end

function update_terrain(data, functions)
    local mag_dev = Local_magnetic_deviation()

    local extra_size = 140 -- This is necessary because when the texture is rotated of 45° we need extra pixels over 900 weidth/height
    
    -- Lat, lon in the left bottom corner
    local lat, lon = functions.get_lat_lon_heading(data, -extra_size/2, -extra_size/2, mag_dev)
    local rounded_lat = lat - math.fmod(lat, RESOLUTION_LAT)
    local rounded_lon = lon - math.fmod(lon, RESOLUTION_LON)

    data.terrain_center[1] = data.inputs.plane_coords_lat - math.fmod(data.inputs.plane_coords_lat, RESOLUTION_LAT)
    data.terrain_center[2] = data.inputs.plane_coords_lon - math.fmod(data.inputs.plane_coords_lon, RESOLUTION_LON)

    local x1, y1 = functions.get_x_y_heading(data, rounded_lat, rounded_lon, 0)
    local x2, y2 = functions.get_x_y_heading(data, rounded_lat, rounded_lon+RESOLUTION_LON, 0)
    local x3, y3 = functions.get_x_y_heading(data, rounded_lat+RESOLUTION_LAT, rounded_lon, 0)
    
    local multiplier_x = RESOLUTION_LON
    local multiplier_y = RESOLUTION_LAT
    local size_x = math.ceil(x2-x1)
    local size_y = math.ceil(y3-y1)
    assert(size_x > 0 and size_y > 0)
    
    local orig_size_x = size_x
    local orig_size_y = size_y

    -- The minimun image size (for each time) is computed as follows:
    -- - 32 for zoom 10
    -- - 16 for zoom 20
    -- - 8  for zoom 40
    -- - 4  for zoom 80 and above
    local img_size = 32 / 2^(math.min(4, data.config.range)-1)

    while size_x < img_size do
        size_x = size_x + orig_size_x
        multiplier_x = multiplier_x + RESOLUTION_LON
    end
    while size_y < img_size do
        size_y = size_y + orig_size_y
        multiplier_y = multiplier_y + RESOLUTION_LAT
    end
    
    local w = size[1]+extra_size
    local h = size[2]+extra_size
    
    if not data.terrain_texture then
        data.terrain_texture = sasl.gl.createTexture(w,h)
    end

    sasl.gl.setRenderTarget(data.terrain_texture, true) -- Automatically clear the texture
    
    print("size_x=" .. size_x, "size_y=" .. size_y, "multiplier_x=" .. multiplier_x, "multiplier_y=" .. multiplier_y)
    
    for i=0,w/size_x do
        for j=0,h/size_y do
            if i == 1 then
                print("i=" .. i, "j=" .. j, "latitude=" .. (rounded_lat + multiplier_y*j), "longitude=" .. (rounded_lon + multiplier_x*i))
            end

            local lat = rounded_lat + multiplier_y*j - ND_terrain.altitudes_start[1]
            local lon = rounded_lon + multiplier_x*i - ND_terrain.altitudes_start[2]
            lat = math.floor(lat * INV_RESOLUTION_LAT)
            lon = math.floor(lon * INV_RESOLUTION_LON)

            if lat >= 0 and lat <= NR_TILE_LAT and lon >= 0 and lon <= NR_TILE_LON then -- Valid point
                local terrain_alt = ND_terrain.altitudes[lat][lon]
                local texture = terrain_get_texture(data, terrain_alt)
                if texture then
                    local x = (i*size_x)
                    local y = (j*size_y)
                    sasl.gl.drawTexturePart(texture, x, y, size_x, size_y, (lat+lon)%50, (lat)%30, size_x, size_y, {1,1,1})
                end
            else
                sasl.gl.drawRectangle(x, y,size_x, size_y, {1., 0., 1.})
            end
        end
    end

    sasl.gl.restoreRenderTarget()

end


