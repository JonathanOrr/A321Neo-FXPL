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

local image_terrain_mask        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/terrain-mask.png")

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function is_inside_rect_vector(p1, p2)
    return {
            (p2[1] - p1[1]),
            (p2[2] - p1[2])
    }
end

local function is_inside_rect_dot(u, v)
    return u[1] * v[1] + u[2] * v[2]; 
end


local function is_inside_rect(A, B, C, P)   -- Check wheter P is inside the rectangle with points A-B B-C
    local AB = is_inside_rect_vector(A, B);
    local AM = is_inside_rect_vector(A, P);
    local BC = is_inside_rect_vector(B, C);
    local BM = is_inside_rect_vector(B, P);
    local dotABAM = is_inside_rect_dot(AB, AM);
    local dotABAB = is_inside_rect_dot(AB, AB);
    local dotBCBM = is_inside_rect_dot(BC, BM);
    local dotBCBC = is_inside_rect_dot(BC, BC);
    return 0 <= dotABAM and dotABAM <= dotABAB and 0 <= dotBCBM and dotBCBM <= dotBCBC
end

function load_altitudes_from_file()

    local filename = moduleDirectory .. "/Custom Module/data/altitudes.csv"
    
    if ND_terrain.world_altitudes then
        return  -- We don't want to reload them
    end
    
    ND_terrain.world_altitudes = {}
    
    for line in io.lines(filename) do
        local c = string.sub(line,1,1)
        if (c ~= "") then   -- Row is not empty
            local startp,endp = string.find(line,',',1) -- Search the first comma
            local startp2,endp2 = string.find(line,',',endp+1) -- Search the second comma

            local lat = tonumber(string.sub(line,1,startp-1))
            local lon = tonumber(string.sub(line,endp+1,startp2-1))
            local alt = tonumber(string.sub(line,endp2+1)) * 3.28084 -- From meters to feet
            lat = math.floor(lat)
            lon = math.floor(lon)

            if ND_terrain.world_altitudes[lat] == nil then
                ND_terrain.world_altitudes[lat] = {}
            end
            ND_terrain.world_altitudes[lat][lon] = alt
        end
    end

end


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

local function reset_min_max_value(data)
    data.terrain.min_altitude_tile = 99999
    data.terrain.max_altitude_tile = -99999
end

local function update_min_max_value(data, texture, altitude, orig_lat, orig_lon, geo_rectangle)
    if texture == image_terrain_blue or texture == image_terrain_magenta then
        return -- Don't compute it from sea level
    end

    if not is_inside_rect(geo_rectangle.A, geo_rectangle.B, geo_rectangle.C, {orig_lat, orig_lon}) then
        return
    end
    
    local color =    (texture == image_terrain_red and ECAM_RED)
                  or (texture == image_terrain_yellow_high and ECAM_ORANGE)
                  or (texture == image_terrain_yellow_low  and ECAM_ORANGE)
                  or (texture == image_terrain_green_high  and ECAM_GREEN)
                  or (texture == image_terrain_green_low   and ECAM_GREEN)
                  or ECAM_MAGENTA -- This should not happen

    if altitude > data.terrain.max_altitude_tile then
        data.terrain.max_altitude_tile = altitude
        data.terrain.max_altitude_tile_color = color
    end
    if altitude < data.terrain.min_altitude_tile then
        data.terrain.min_altitude_tile = altitude
        data.terrain.min_altitude_tile_color = color
    end
end

local function draw_single_tile(data, orig_lat, orig_lon, x, y, tile_size, geo_rectangle)
    -- Converting coordates to the format of array
    local lat = orig_lat - math.fmod(orig_lat, RESOLUTION_LAT) - ND_terrain.altitudes_start[1]
    local lon = orig_lon - math.fmod(orig_lon, RESOLUTION_LON) - ND_terrain.altitudes_start[2]
    lat = math.floor(lat * INV_RESOLUTION_LAT)
    lon = math.floor(lon * INV_RESOLUTION_LON)

    -- Select a random area for our tile:
    local x_start = small_prng(orig_lat,orig_lon)%200
    local y_start = small_prng(orig_lon,orig_lat)%100

    local texture = nil
    
    if lat >= 0 and lat <= NR_TILE_LAT and lon >= 0 and lon <= NR_TILE_LON then -- Valid point
        -- Case 1: high resolution terrain

        local terrain_alt = ND_terrain.altitudes[lat][lon]

        -- When the aicraft is near an airport, we have a 400ft of vertical space before showing
        -- the terrain tiles.  See here for further details:
        -- https://skybrary.aero/bookshelf/books/3364.pdf
        if get(Capt_ra_alt_ft) < 2000 and get(GPWS_dist_airport) < 3
                                      and data.config.range < 3  then
            if terrain_alt > -1000 and terrain_alt < data.inputs.altitude+400  then
                terrain_alt = -3000 -- -3000 is just a random value to show a black square
            end
        end

        texture = terrain_get_texture(data, terrain_alt)

        if texture then
            -- If I'm displayig a valid tile and it's not the sea, then update the numbers
            update_min_max_value(data, texture, terrain_alt, orig_lat, orig_lon, geo_rectangle)
        end
    elseif ND_terrain.world_altitudes ~= nil and math.abs(orig_lat) < 80 then
        -- Case 2: low resolution terrain for large ranges
        local low_res_lat = math.floor(orig_lat * 10)
        local low_res_lon = math.floor(orig_lon * 10)

        local terrain_alt = nil
        if ND_terrain.world_altitudes[low_res_lat] then
            terrain_alt = ND_terrain.world_altitudes[low_res_lat][low_res_lon]
        end
        if terrain_alt then
            texture = terrain_get_texture(data, terrain_alt)
        else
            texture = image_terrain_blue
        end
        if texture and texture ~= image_terrain_blue then
            update_min_max_value(data, texture, terrain_alt, orig_lat, orig_lon, geo_rectangle)
        end
    else
        -- Case 3: No data
        texture = image_terrain_magenta
    end


    if texture then
        sasl.gl.drawTexturePart(texture, x, y, tile_size, tile_size, x_start, y_start, tile_size, tile_size, {1,1,1})
    end

end

function update_terrain(data, functions, geo_rectangle)

    reset_min_max_value(data)   -- Reset numbers

    local mag_dev = Local_magnetic_deviation()

    local extra_size = 140 -- This is necessary because when the texture is rotated of 45° we need extra pixels over 900 weidth/height
    local w = size[1]+extra_size    -- Texture width
    local h = size[2]+extra_size    -- Texture height

    -- The minimun image size (for each time) is computed as follows:
    -- - 32 for zoom 10
    -- - 16 for zoom 20
    -- - 8  for zoom 40
    -- - 4  for zoom 80 and above
    local img_size = 32 / 2^(math.min(3, data.config.range)-1)

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

    data.terrain.center[data.terrain.texture_in_use][1] = bl_lat + multiplier_lat*(nr_tile_y/2-1)
    data.terrain.center[data.terrain.texture_in_use][2] = bl_lon + multiplier_lon*nr_tile_x/2

    if not data.terrain.texture[data.terrain.texture_in_use] then
        data.terrain.texture[data.terrain.texture_in_use] = sasl.gl.createTexture(w,h)
    end

    sasl.gl.setRenderTarget(data.terrain.texture[data.terrain.texture_in_use], true) -- Automatically clear the texture
    Draw_LCD_backlight(0, 0, w, h, 0.2, 1, get(Capt_ND_brightness_act))
        
    for i=0,nr_tile_x do
        for j=0,nr_tile_y do

            local lat = bl_lat + multiplier_lat*j
            local lon = bl_lon + multiplier_lon*i

            local x = -img_size/2 + i*img_size
            local y = -img_size/2 + j*img_size
            draw_single_tile(data, lat, lon, x, y, img_size, geo_rectangle)

        end
    end

    sasl.gl.restoreRenderTarget()

end

function draw_terrain_mask(data, normal_mask_texture, y_start)
    sasl.gl.drawMaskEnd()
    sasl.gl.drawMaskStart()
    sasl.gl.drawTexture(normal_mask_texture, 0,0,900,900)
    local time_ratio = (get(TIME)-data.terrain.last_update)/3   --from 0 (new texture) to 1 (old texture)

    sasl.gl.drawRotatedTextureCenter(image_terrain_mask, 360-90*time_ratio, 450, y_start, 0, y_start, 450, 900)
    sasl.gl.drawRotatedTextureCenter(image_terrain_mask, 90*time_ratio, 450, y_start, 450, y_start, 450, 900)

    sasl.gl.drawUnderMask(true)
end

function reset_terrain_mask(data, normal_mask_texture)
    sasl.gl.drawMaskEnd()
    sasl.gl.drawMaskStart()
    sasl.gl.drawTexture(normal_mask_texture, 0,0,900,900)
    sasl.gl.drawUnderMask(true)
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

