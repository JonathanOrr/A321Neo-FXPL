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
include("ND/subcomponents/tcas.lua")
include('libs/geo-helpers.lua')

local DEBUG_terrain_center = false
local Y_CENTER = 145

local COLOR_YELLOW = {1,1,0}
local poi_position_last_update = 0
local POI_UPDATE_RATE = 0.1
local MAX_LIMIT_WPT = 750

-------------------------------------------------------------------------------
-- Textures
-------------------------------------------------------------------------------

local image_point_apt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-apt.png")
local image_point_vor_only = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-only.png")
local image_point_vor_dme  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-dme.png")
local image_point_dme_only  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-dme-only.png")
local image_point_ndb = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-ndb.png")
local image_point_wpt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-wpt.png")

local image_vor_1 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-VOR1-arc.png")
local image_vor_2 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-VOR2-arc.png")
local image_adf_1 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-ADF1-arc.png")
local image_adf_2 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-ADF2-arc.png")

local image_oans_needle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-oans-arc.png")

local image_track_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-track-arc.png")
local image_hdgsel_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-hdgsel-arc.png")

local image_ils_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-arc.png")
local image_ils_nonprec_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-nonprec-arc.png")
local image_mask_arc  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-arc.png")
local image_mask_arc_terr  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-arc-terrain.png")

-------------------------------------------------------------------------------
-- Helpers functions
-------------------------------------------------------------------------------
local function arc_get_px_per_nm(data)
    -- 1155 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    return 1155 / range_in_nm
end

local function arc_get_x_y_heading(data, lat, lon, heading)
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
    local angle_respect_dir = math.deg(math.atan2((x-size[1]/2), (y-Y_CENTER)))
    
    local bearing     = (heading + angle_respect_dir) % 360
    local px_per_nm = arc_get_px_per_nm(data)
    local distance_nm = math.sqrt((size[1]/2 - x)*(size[1]/2 - x) + (Y_CENTER - y)*(Y_CENTER - y)) / px_per_nm

    return Move_along_distance_v2(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon, distance_nm*1852, bearing)
end

local function arc_get_lat_lon(data, x, y)
    return arc_get_lat_lon_with_heading(data, x, y, data.inputs.heading-Local_magnetic_deviation())
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
        ND_DRAWING_large_rose(450,137 , -data.inputs.heading )

        if data.config.range > ND_RANGE_ZOOM_2 then
            ND_DRAWING_large_dashed_rings(450,137)
        else
            ND_DRAWING_large_dashed_rings_zoom(450,137)
        end

        if data.misc.tcas_ta_triggered or data.misc.tcas_ra_triggered or data.config.range == ND_RANGE_20 then

            -- Inner (TCAS) circle is activated only when:
            -- - Range is 10, or
            -- - TCAS RA or TA activates
            ND_DRAWING_large_tcas_ring(450,137)
        end
        
    else
        -- Heading not available
       ND_DRAWING_hdg_not_avail(450,137)
    end
end

local function draw_fixed_symbols(data)

    if not data.inputs.is_heading_valid then
        return
    end
    
    local plane_color = data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA

    -- Plane
    sasl.gl.drawWideLine(410, 145, 490, 145, 4, plane_color)
    sasl.gl.drawWideLine(450, 95, 450, 170, 4,  plane_color)   -- H=75
    sasl.gl.drawWideLine(435, 110, 465, 110, 4, plane_color)

    -- Top heading indicator (yellow)
    sasl.gl.drawWideLine(450, 690, 450, 740, 5, plane_color)
    
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

    local ext_range = get_range_in_nm(data)
    local second_ring = ext_range * 3 / 4
    local third_ring  = ext_range * 2 / 4


    if data.config.range > ND_RANGE_ZOOM_2 then
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2-370, 320, second_ring, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2+370, 320, second_ring, 24, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-240, 250, third_ring, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+240, 250, third_ring, 24, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    
end

local function draw_navaid_pointer_single(data, id)
    if not data.nav[id].needle_visible then
        return
    end

    local image = data.nav[id].selector == ND_SEL_ADF and (id == 1 and image_adf_1 or image_adf_2) or (id == 1 and image_vor_1 or image_vor_2)

    sasl.gl.drawRotatedTexture(image, data.nav[id].needle_angle-data.inputs.heading+180, (size[1]-44)/2,(size[2]-1153)/2-312,44,1153, {1,1,1})

end

local function draw_navaid_pointers(data)
    draw_navaid_pointer_single(data, 1)
    draw_navaid_pointer_single(data, 2)
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

        poi.x, poi.y = arc_get_x_y_heading(data, poi.lat,poi.lon, data.inputs.heading)
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

    if data.misc.map_not_avail then
        return -- No POI is map not avail
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

local function draw_terrain(data)
    if    (data.id == ND_CAPT and get(ND_Capt_Terrain) == 0)
       or (data.id == ND_FO and get(ND_Fo_Terrain) == 0)
       or get(GPWS_long_test_in_progress) == 1 then
        -- Terrain disabled
        return
    end

    if not data.inputs.is_heading_valid or not adirs_is_position_ok(data.id) or data.misc.map_not_avail then
        return  -- Cannot show terrain if I don't know where I am
    end

    if data.config.range <= ND_RANGE_ZOOM_2 then
        -- No terrain on oans
        return
    end
    
    data.terrain.request_refresh = true

    local incoming_texture = data.terrain.texture_in_use == 1 and 2 or 1
    local outgoing_texture = data.terrain.texture_in_use
    
    if data.terrain.texture[incoming_texture] then
        local diff_x, diff_y = arc_get_x_y_heading(data, data.terrain.center[incoming_texture][1], data.terrain.center[incoming_texture][2], data.inputs.heading)
        local shift_x = 900-diff_x
        local shift_y = 900-diff_y
        reset_terrain_mask(data, image_mask_arc_terr)
        sasl.gl.drawRotatedTexture(data.terrain.texture[incoming_texture], -data.inputs.heading, -shift_x-70, -shift_y-70, 900*2+140,900*2+140, {1,1,1})
        if DEBUG_terrain_center then
            -- Draw an X where the terrain center is located
            sasl.gl.drawWideLine(diff_x-10, diff_y-10, diff_x+10, diff_y+10, 4, ECAM_MAGENTA)
            sasl.gl.drawWideLine(diff_x-10, diff_y+10, diff_x+10, diff_y-10, 4, ECAM_MAGENTA)
        end
    end
    
    if data.terrain.texture[outgoing_texture] then
        local diff_x, diff_y = arc_get_x_y_heading(data, data.terrain.center[outgoing_texture][1], data.terrain.center[outgoing_texture][2], data.inputs.heading)
        local shift_x = 900-diff_x
        local shift_y = 900-diff_y

        draw_terrain_mask(data, image_mask_arc_terr, 145)
        sasl.gl.drawRotatedTexture(data.terrain.texture[outgoing_texture], -data.inputs.heading, -shift_x-70, -shift_y-70, 900*2+140,900*2+140, {1,1,1})
        reset_terrain_mask(data, image_mask_arc)

    end
    
    sasl.gl.drawRectangle(0, 0, 900, 900, {10/255, 15/255, 25/255 , 1-data.terrain.brightness})
end

local function draw_oans_arrow(data)

    if data.oans.displayed_apt and data.oans.displayed_apt.distance and data.oans.displayed_apt.distance > 5 then
        local lat = data.oans.displayed_apt.lat
        local lon = data.oans.displayed_apt.lon

        local bearing = get_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
        
        local angle = ((-90-bearing)%360)-data.inputs.heading
        sasl.gl.drawRotatedTexture(image_oans_needle, angle, (size[1]-37)/2,(size[2]-1153)/2-312,37,1153, {1,1,1})
        
        local new_angle = angle + Math_rescale(0, 30, 180, 7, (angle < 180 and angle > 0) and angle or math.abs(360-(angle%360)))

        local R = 460
        local x = 420 + R * math.sin(math.rad(new_angle-180))
        local y = 450 -312 + R * math.cos(math.rad(new_angle-180))
        sasl.gl.drawText(Font_ECAMfont, x, y, data.oans.displayed_apt.id, 32, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end
end

local function draw_tcas(data)

    if data.config.range <= ND_RANGE_ZOOM_2 or data.config.range >= ND_RANGE_80 then
        return  -- TCASs are not drawn during the zoom mode or large modes
    end

    if data.misc.map_not_avail then
        return -- No TCAS is map not avail
    end
    
    if get(TCAS_actual_mode) == TCAS_MODE_OFF or get(TCAS_actual_mode) == TCAS_MODE_FAULT then
        return
    end

    for i,acf in ipairs(TCAS_sys.acf_data) do

        local poi = acf.poi ~= nil and acf.poi or {id="", lat=acf.lat, lon=acf.lon}
        poi.distance = get_distance_nm(data.inputs.plane_coords_lat, data.inputs.plane_coords_lon, acf.lat, acf.lon)


        local modified, poi = draw_tcas_acf(data, acf, poi, draw_poi_array)
        if modified then
            TCAS_sys.acf_data[i].poi = poi
        end
    end

end
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
    draw_terrain(data)
    draw_pois(data)
    draw_tcas(data)
    
    local functions_for_oans = {
        get_lat_lon = arc_get_lat_lon,
        get_x_y = arc_get_x_y,
        get_px_per_nm = arc_get_px_per_nm
    }
    
    draw_oans(data, functions_for_oans)

    if data.config.range <= ND_RANGE_ZOOM_2 and data.oans_cache and not data.oans_cache.is_visible then
        draw_oans_arrow(data)
    end

    draw_navaid_pointers(data)
end
