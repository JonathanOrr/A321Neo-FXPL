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
-- File: graphics_arc.lua
-- Short description: ARC mode file
-------------------------------------------------------------------------------

size = {900, 900}

include("ND/subcomponents/helpers.lua")
include("ND/subcomponents/graphics_oans.lua")
include('ND/subcomponents/terrain.lua')

local DEBUG_terrain_center = false
local Y_CENTER = 145

local COLOR_YELLOW = {1,1,0}
local poi_position_last_update = 0
local POI_UPDATE_RATE = 0.1
local MAX_LIMIT_WPT = 750

-------------------------------------------------------------------------------
-- Textures
-------------------------------------------------------------------------------

local image_bkg_arc        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/arc.png")
local image_bkg_arc_red    = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/arc-red.png")
local image_bkg_arc_inner  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/arc-inner.png")
local image_bkg_arc_tcas   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/tcas-arc.png")

local image_point_apt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-apt.png")
local image_point_vor_only = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-only.png")
local image_point_vor_dme  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-dme.png")
local image_point_dme_only  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-dme-only.png")
local image_point_ndb = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-ndb.png")
local image_point_wpt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-wpt.png")


local image_track_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-track-arc.png")
local image_hdgsel_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-hdgsel-arc.png")

local image_ils_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-arc.png")
local image_ils_nonprec_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-nonprec-arc.png")


-------------------------------------------------------------------------------
-- Helpers functions
-------------------------------------------------------------------------------
local function arc_get_px_per_nm(data)
    -- 1155 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    return 1155 / range_in_nm
end

local function arc_get_x_y_heading(data, lat, lon, heading)  -- Do not use this for poi
    local px_per_nm = arc_get_px_per_nm(data)
    
    local distance = get_distance_nm(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
    local distance_px = distance * px_per_nm
    local bearing  = get_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
    
    local bear_shift = bearing+heading
    bear_shift = bear_shift - Local_magnetic_deviation()
    local x = size[1]/2 + distance_px * math.cos(math.rad(bear_shift))
    local y = Y_CENTER + distance_px * math.sin(math.rad(bear_shift))
    
    return x,y
end

local function arc_get_lat_lon_with_heading(data, x, y, heading)
    local bearing     = 180+math.deg(math.atan2((size[1]/2 - x), (Y_CENTER - y))) + heading
    local px_per_nm = arc_get_px_per_nm(data)
    local distance_nm = math.sqrt((size[1]/2 - x)*(size[1]/2 - x) + (Y_CENTER - y)*(Y_CENTER - y)) / px_per_nm

    return Move_along_distance(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon, distance_nm*1852, bearing)
end

local function arc_get_lat_lon(data, x, y)
    return arc_get_lat_lon_with_heading(data, x, y, Local_magnetic_deviation() + data.inputs.heading)
end

local function arc_get_x_y(data, lat, lon)  -- Do not use this for poi
    return arc_get_x_y_heading(data, lat, lon, data.inputs.heading)
end


-------------------------------------------------------------------------------
-- draw_* functions
-------------------------------------------------------------------------------

local function draw_backgrounds(data)
    -- Main arc background
    if data.inputs.is_heading_valid then
        sasl.gl.drawRotatedTexture(image_bkg_arc, -data.inputs.heading, (size[1]-1330)/2,(size[2]-1330)/2-312,1330,1330, {1,1,1})
        sasl.gl.drawTexture(image_bkg_arc_inner, (size[1]-898)/2,(size[2]-568)/2-13,898,568, {1,1,1})
        
        if data.misc.tcas_ta_triggered or data.misc.tcas_ra_triggered or data.config.range == ND_RANGE_20 then

            -- Inner (TCAS) circle is activated only when:
            -- - Range is 10, or
            -- - TCAS RA or TA activates
            sasl.gl.drawTexture(image_bkg_arc_tcas, (size[1]-122)/2,(size[2]-41)/2-252,122,41, {1,1,1})
        end
        
    else
        -- Heading not available
       sasl.gl.drawTexture(image_bkg_arc_red, (size[1]-898)/2,(size[2]-600)/2-30,898,600, {1,1,1})
    end
end

local function draw_fixed_symbols(data)

    if not data.inputs.is_heading_valid then
        return
    end

    -- Plane
    sasl.gl.drawWideLine(410, 145, 490, 145, 4, COLOR_YELLOW)
    sasl.gl.drawWideLine(450, 95, 450, 170, 4, COLOR_YELLOW)   -- H=75
    sasl.gl.drawWideLine(435, 110, 465, 110, 4, COLOR_YELLOW)

    -- Top heading indicator (yellow)
    sasl.gl.drawWideLine(450, 690, 450, 740, 5, COLOR_YELLOW)
    
end

local function draw_track_symbol(data)
    if not data.inputs.is_track_valid then
        return
    end
    
    if math.abs(data.inputs.track-data.inputs.heading) > 110 then
        return -- not visible, out of visible area
    end

    sasl.gl.drawRotatedTexture(image_track_sym, (data.inputs.track-data.inputs.heading), (size[1]-17)/2,(size[2]-1154)/2-312,17,1154, {1,1,1})
end

local function draw_hdgsel_symbol(data)

    if not data.inputs.hdg_sel_visible then
        return
    end


    if math.abs(data.inputs.hdg_sel-data.inputs.heading) > 50 then
        -- If the HDG sel is over the limit of the arc, then we write the text at left or right depending
        -- on where it is.
        
        local start_x = ((data.inputs.heading - data.inputs.hdg_sel)%180 > 0) and size[1]-40 or 40   -- true -> right, false -> left
        
        -- TODO Rotate
        sasl.gl.drawText(Font_AirbusDUL, start_x, 575 , data.inputs.hdg_sel , 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)    
        return -- not visible, out of visible area
    end

    
    sasl.gl.drawRotatedTexture(image_hdgsel_sym, (data.inputs.hdg_sel-data.inputs.heading), (size[1]-32)/2,(size[2]-1201)/2-312,32,1201, {1,1,1})
end


local function draw_ls_symbol(data)

    if not data.inputs.ls_is_visible then
        return
    end
    
    sasl.gl.drawRotatedTexture(data.inputs.ls_is_precise and image_ils_sym or image_ils_nonprec_sym,
                              (data.inputs.ls_direction-data.inputs.heading+180), (size[1]-19)/2,(size[2]-1217)/2-312,19,1217, {1,1,1})
end

local function draw_ranges(data)

    if data.config.range > 0 then
        local second_ring = math.floor(2^(data.config.range-1) * 10 * 3 / 4)
        local third_ring  = math.floor(2^(data.config.range-1) * 10 * 2 / 4)

        if data.config.range == 1 then
            second_ring = "7.5"  -- This is the only one not integer
        end
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2-240, 250, third_ring, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2-370, 320, second_ring, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2+240, 250, third_ring, 24, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2+370, 320, second_ring, 24, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end
    
end

-------------------------------------------------------------------------------
-- POIs
-------------------------------------------------------------------------------

local function draw_poi_array(data, poi, texture, color)
    local modified = false

    -- 588 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    local px_per_nm = 1155 / range_in_nm

    if poi.distance == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
       poi.distance = get_distance_nm(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,poi.lat,poi.lon)
    end
    
    if poi.distance > range_in_nm * 2 then
        return true, poi
    end

    if poi.x == nil or poi.y == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
        modified = true
        
        local bearing  = get_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,poi.lat,poi.lon)
        
        local distance_px = poi.distance * px_per_nm

        poi.x = size[1]/2 + distance_px * math.cos(math.rad(bearing+data.inputs.heading))
        poi.y = Y_CENTER + distance_px * math.sin(math.rad(bearing+data.inputs.heading))
    end


    if poi.x > 0 and poi.x < size[1] and poi.y > 0 and poi.y < size[2] then
        sasl.gl.drawTexture(texture, poi.x-16, poi.y-16, 32,32, color)
        sasl.gl.drawText(Font_AirbusDUL, poi.x+20, poi.y-20, poi.id, 32, false, false, TEXT_ALIGN_LEFT, color)
    end
    
    return modified, poi
end

local function draw_airports(data)
    if data.config.extra_data ~= ND_DATA_ARPT then
        return  -- Airport button not selected
    end
    
    -- For each airtport visible...
    for i,airport in ipairs(data.poi.arpt) do
        local modified, poi = draw_poi_array(data, airport, image_point_apt, ECAM_MAGENTA)
        if modified then
            data.poi.arpt[i] = poi
        end
    end
end

local function draw_vors(data)

    if data.config.extra_data ~= ND_DATA_VORD then
        return  -- Vor button not selected
    end

    -- For each airtport visible...
    for i,vor in ipairs(data.poi.vor) do
        local modified, poi = draw_poi_array(data, vor, vor.is_coupled_dme and image_point_vor_dme or image_point_vor_only, ECAM_MAGENTA)
        if modified then
            data.poi.vor[i] = poi
        end
    end
    
end

local function draw_dmes(data)

    if data.config.extra_data ~= ND_DATA_VORD then
        return  -- Vor button not selected
    end

    -- For each airtport visible...
    for i,dme in ipairs(data.poi.dme) do
        local modified, poi = draw_poi_array(data, dme, image_point_dme_only, ECAM_MAGENTA)
        if modified then
            data.poi.dme[i] = poi
        end
    end
    
end

local function draw_ndbs(data)

    if data.config.extra_data ~= ND_DATA_NDB then
        return  -- Vor button not selected
    end

    -- For each airtport visible...
    for i,ndb in ipairs(data.poi.ndb) do
        local modified, poi = draw_poi_array(data, ndb, image_point_ndb, ECAM_MAGENTA)
        if modified then
            data.poi.ndb[i] = poi
        end
    end
    
end

local function draw_wpts(data)

    if data.config.extra_data ~= ND_DATA_WPT then
        return  -- Vor button not selected
    end

    local displayed_num = 0
    data.misc.not_displaying_all_data = false
    
    -- For each waypoint visible...
    local nr_wpts = #data.poi.wpt
    if nr_wpts > MAX_LIMIT_WPT and data.config.range >= ND_RANGE_160 then
        data.misc.not_displaying_all_data = true
    end
    
    for i=1,nr_wpts do
        local wpt = data.poi.wpt[i]
        if nr_wpts <= MAX_LIMIT_WPT or i % math.ceil(nr_wpts/MAX_LIMIT_WPT) == 0 or data.config.range < ND_RANGE_160 then
            local modified, poi = draw_poi_array(data, wpt, image_point_wpt, ECAM_MAGENTA)
            if modified then
                data.poi.wpt[i] = poi
            end
       end
    end
    
end

local function draw_pois(data)

    if data.config.range <= ND_RANGE_ZOOM_2 then
        return  -- POIs are not drawn during the zoom mode
    end

    
    draw_airports(data)
    draw_vors(data)
    draw_dmes(data)
    draw_ndbs(data)
    draw_wpts(data)

    local need_to_update_poi = (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE
    if need_to_update_poi then
        poi_position_last_update = get(TIME)
    end

end
-------------------------------------------------------------------------------
-- Terrain
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main draw_* functions
-------------------------------------------------------------------------------

function draw_arc_unmasked(data)
    draw_backgrounds(data)
    draw_fixed_symbols(data)
    draw_ranges(data)
    draw_track_symbol(data)
    draw_hdgsel_symbol(data)
    draw_ls_symbol(data)
end

function draw_arc(data)
    --draw_terrain(data)
    draw_pois(data)
    
    local functions_for_oans = {
        get_lat_lon = arc_get_lat_lon,
        get_x_y = arc_get_x_y,
        get_px_per_nm = arc_get_px_per_nm
    }

--[[    lat,lon = arc_get_lat_lon(data, 450, 450)
    x,y = arc_get_x_y(data, lat, lon)
    print(lat,lon,x,y)
]]--
    draw_oans(data, functions_for_oans)
    
end
