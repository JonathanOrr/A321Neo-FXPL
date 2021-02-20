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

local function small_prng(lat, lon)
    local state = lat * 1231 + lon
    return (state*1664525 + 1013904223)
end

local function draw_single_tile(data, orig_lat, orig_lon, x, y, tile_size)
    -- Converting coordates to the format of array
    local lat = orig_lat - math.fmod(orig_lat, RESOLUTION_LAT) - ND_terrain.altitudes_start[1]
    local lon = orig_lon - math.fmod(orig_lon, RESOLUTION_LON) - ND_terrain.altitudes_start[2]
    lat = math.floor(lat * INV_RESOLUTION_LAT)
    lon = math.floor(lon * INV_RESOLUTION_LON)

    -- Select a random area for our tile:
    local x_start = small_prng(orig_lat,orig_lon)%200
    local y_start = small_prng(orig_lon,orig_lat)%100

    if lat >= 0 and lat <= NR_TILE_LAT and lon >= 0 and lon <= NR_TILE_LON then -- Valid point
        local terrain_alt = ND_terrain.altitudes[lat][lon]
        local texture = terrain_get_texture(data, terrain_alt)
        if texture then
            sasl.gl.drawTexturePart(texture, x, y, tile_size, tile_size, x_start, y_start, tile_size, tile_size, {1,1,1})
        end
    else

        -- Outside the loaded region
        sasl.gl.drawTexturePart(image_terrain_magenta, x, y, tile_size, tile_size, x_start, y_start, tile_size, tile_size, {1,1,1})
    end

end

function update_terrain(data, functions)
    local mag_dev = Local_magnetic_deviation()

    local extra_size = 140 -- This is necessary because when the texture is rotated of 45° we need extra pixels over 900 weidth/height
    local w = size[1]+extra_size    -- Texture width
    local h = size[2]+extra_size    -- Texture height

    -- The minimun image size (for each time) is computed as follows:
    -- - 32 for zoom 10
    -- - 16 for zoom 20
    -- - 8  for zoom 40
    -- - 4  for zoom 80 and above
    local img_size = 32 / 2^(math.min(4, data.config.range)-1)

    local nr_tile_x = math.ceil(w / img_size)
    local nr_tile_y = math.ceil(h / img_size)

    -- Lat, lon in the left bottom corner
    local bl_px_x = -extra_size/2+img_size/2
    local bl_px_y = -extra_size/2+img_size/2
    
    if not data.bl_lat then
        data.bl_lat, data.bl_lon = functions.get_lat_lon_heading(data, bl_px_x, bl_px_y, mag_dev)
    end
    local bl_lat, bl_lon = data.bl_lat, data.bl_lon
    
    -- Lat, lon in the top right corner (corrected for tile size)
    local tr_px_x = bl_px_x + img_size * nr_tile_x
    local tr_px_y = bl_px_y + img_size * nr_tile_y

    if not data.tr_lat then
        data.tr_lat, data.tr_lon =  functions.get_lat_lon_heading(data, tr_px_x, tr_px_y, mag_dev)
    end
    local tr_lat, tr_lon = data.tr_lat, data.tr_lon

    local multiplier_lat = (tr_lat - bl_lat) / nr_tile_y
    local multiplier_lon = (tr_lon - bl_lon) / nr_tile_x

    data.terrain.center[1] = bl_lat + multiplier_lat*(nr_tile_y/2-1)
    data.terrain.center[2] = bl_lon + multiplier_lon*nr_tile_x/2

    if not data.terrain.texture then
        data.terrain.texture = sasl.gl.createTexture(w,h)
    end

    sasl.gl.setRenderTarget(data.terrain.texture, true) -- Automatically clear the texture

    for i=0,nr_tile_x do
        for j=0,nr_tile_y do

            local lat = bl_lat + multiplier_lat*j
            local lon = bl_lon + multiplier_lon*i

            local x = -img_size/2 + i*img_size
            local y = -img_size/2 + j*img_size
            draw_single_tile(data, lat, lon, x, y, img_size)

        end
    end

    sasl.gl.restoreRenderTarget()

end

function draw_terrain_test_gpws()

    sasl.gl.drawTexture(image_terrain_magenta, 75, 100+300, 250, 150, {1,1,1})
    sasl.gl.drawTexture(image_terrain_red, 75+250, 100+300, 250, 150, {1,1,1})
    sasl.gl.drawTexture(image_terrain_blue, 75+500, 100+300, 250, 150, {1,1,1})

    sasl.gl.drawTexture(image_terrain_yellow_high, 75+250, 100+150, 250, 150, {1,1,1})

    sasl.gl.drawTexture(image_terrain_green_high, 75, 100, 250, 150, {1,1,1})
    sasl.gl.drawTexture(image_terrain_yellow_low, 75+250, 100, 250, 150, {1,1,1})
    sasl.gl.drawTexture(image_terrain_green_low, 75+500, 100, 250, 150, {1,1,1})

end

