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
-- File: graphics_rose.lua
-- Short description: ROSE/NAV mode file
-------------------------------------------------------------------------------

size = {900, 900}

local DEBUG_terrain_center = false

include("ND/subcomponents/helpers.lua")
include("ND/subcomponents/graphics_oans.lua")
include('ND/subcomponents/terrain.lua')
include('ND/subcomponents/tcas.lua')
include('ND/subcomponents/helpers_fmgs.lua')
include('FMGS/functions.lua')
include('libs/geo-helpers.lua')

local image_mask_rose = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-rose.png")
local image_mask_rose_terr = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-rose-terrain.png")

local image_point_apt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-apt.png")
local image_point_vor_only = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-only.png")
local image_point_vor_dme  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-dme.png")
local image_point_dme_only  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-dme-only.png")
local image_point_ndb = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-ndb.png")
local image_point_wpt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-wpt.png")


local image_vor_1 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-VOR1.png")
local image_vor_2 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-VOR2.png")
local image_adf_1 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-ADF1.png")
local image_adf_2 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-ADF2.png")

local image_oans_needle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-oans.png")


local image_track_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-track-ring.png")
local image_hdgsel_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-hdgsel-ring.png")

local image_ils_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-ring.png")
local image_ils_nonprec_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-nonprec-ring.png")

local COLOR_YELLOW = {1,1,0}

local poi_position_last_update = 0
local POI_UPDATE_RATE = 0.1
local MAX_LIMIT_WPT = 750

-------------------------------------------------------------------------------
-- Helpers functions
-------------------------------------------------------------------------------

local function rose_get_px_per_nm(data)
    -- 588 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    return 588 / range_in_nm
end


local function rose_get_x_y_heading(data, lat, lon, heading)
    local px_per_nm = rose_get_px_per_nm(data)
    
    local distance = get_distance_nm(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
    local distance_px = distance * px_per_nm
    local bearing  = get_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
    
    local bear_shift = bearing+heading
    bear_shift = bear_shift - Local_magnetic_deviation()
    local x = size[1]/2 + distance_px * math.cos(math.rad(bear_shift))
    local y = size[2]/2 + distance_px * math.sin(math.rad(bear_shift))
    
    return x,y
end


local function rose_get_lat_lon_with_heading(data, x, y, heading)
    local bearing     = 180+math.deg(math.atan2((size[1]/2 - x), (size[2]/2 - y))) + heading
    local px_per_nm = rose_get_px_per_nm(data)
    local distance_nm = math.sqrt((size[1]/2 - x)*(size[1]/2 - x) + (size[2]/2 - y)*(size[2]/2 - y)) / px_per_nm

    return Move_along_distance_v2(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon, distance_nm*1852, bearing)
end

local function rose_get_lat_lon(data, x, y)
    return rose_get_lat_lon_with_heading(data, x, y, data.inputs.heading - Local_magnetic_deviation())
end

local function rose_get_x_y(data, lat, lon)
    return rose_get_x_y_heading(data, lat, lon, data.inputs.heading)
end


-------------------------------------------------------------------------------
-- draw_* functions
-------------------------------------------------------------------------------
local function draw_backgrounds(data)
    -- Main rose background
    if data.inputs.is_heading_valid then
        ND_DRAWING_small_rose(450 ,450 , -data.inputs.heading)

        if data.misc.tcas_ta_triggered or data.misc.tcas_ra_triggered or data.config.range == ND_RANGE_10 then

            -- Inner (TCAS) circle is activated only when:
            -- - Range is 10, or
            -- - TCAS RA or TA activates
            ND_DRAWING_small_tcas_ring(450,450)

        end
    else
        -- Heading not available
        ND_DRAWING_small_red_ring(450,450)
    end
    
end

local function draw_fixed_symbols(data)

    if not data.inputs.is_heading_valid then
        return
    end

    local plane_color = data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA

    -- Plane
    sasl.gl.drawWideLine(410, 450, 490, 450, 4, plane_color)
    sasl.gl.drawWideLine(450, 400, 450, 475, 4, plane_color)
    sasl.gl.drawWideLine(435, 415, 465, 415, 4, plane_color)

    -- Top heading indicator (yellow)
    sasl.gl.drawWideLine(450, 720, 450, 770, 5, plane_color)

    ND_DRAWING_small_triangle(755 ,450 , 270)
    ND_DRAWING_small_triangle(145 ,450 , 90)
    ND_DRAWING_small_triangle(450 ,145 , 0)
    ND_DRAWING_small_triangle(235 ,235 , 45)
    ND_DRAWING_small_triangle(665 ,235 , 315)
    ND_DRAWING_small_triangle(665 ,665 , 225)
    ND_DRAWING_small_triangle(235 ,665, 135)
    ND_DRAWING_dashed_arcs(450,450,147, 3, 20,20,0, 360, true, true, false, ECAM_WHITE)
    
end

local function draw_ranges(data)
    -- Ranges
    --if data.config.range > 0 then
        local ext_range = get_range_in_nm(data)
        local int_range = ext_range / 2
        sasl.gl.drawText(Font_ECAMfont, 250, 250, ext_range, 24, true, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_ECAMfont, 350, 350, int_range, 24, true, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    --end

end

local function draw_track_symbol(data)
    if not data.inputs.is_track_valid then
        return
    end

    sasl.gl.drawRotatedTexture(image_track_sym, (data.inputs.track-data.inputs.heading), (size[1]-17)/2,(size[2]-594)/2,17,594, ECAM_GREEN)
    
end

local function draw_hdgsel_symbol(data)

    if not data.inputs.hdg_sel_visible then
        return
    end
    
    sasl.gl.drawRotatedTexture(image_hdgsel_sym, (data.inputs.hdg_sel-data.inputs.heading), (size[1]-32)/2,(size[2]-641)/2,32,641, {1,1,1})
end

local function draw_ls_symbol(data)

    if not data.inputs.ls_is_visible then
        return
    end
    
    sasl.gl.drawRotatedTexture(data.inputs.ls_is_precise and image_ils_sym or image_ils_nonprec_sym,
                              (data.inputs.ls_direction-data.inputs.heading+180), (size[1]-19)/2,(size[2]-657)/2,19,657, {1,1,1})
end


local function draw_navaid_pointer_single(data, id)
    if not data.nav[id].needle_visible then
        return
    end

    local image = data.nav[id].selector == ND_SEL_ADF and (id == 1 and image_adf_1 or image_adf_2) or (id == 1 and image_vor_1 or image_vor_2)

    sasl.gl.drawRotatedTexture(image, data.nav[id].needle_angle-data.inputs.heading+180, (size[1]-42)/2,(size[2]-586)/2,42,586, {1,1,1})

end

local function draw_navaid_pointers(data)
    draw_navaid_pointer_single(data, 1)
    draw_navaid_pointer_single(data, 2)
end

local function draw_poi_array(data, poi, texture, color)
    local modified = false

    -- 588 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    local px_per_nm = 588 / range_in_nm

    if poi.distance == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
       poi.distance = get_distance_nm(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,poi.lat,poi.lon)
    end
    
    if poi.distance > range_in_nm * 2 then
        return true, poi
    end

    if poi.x == nil or poi.y == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
        modified = true
        
        poi.x, poi.y = rose_get_x_y_heading(data, poi.lat,poi.lon, data.inputs.heading)
    end


    if poi.x > 0 and poi.x < size[1] and poi.y > 0 and poi.y < size[2] then
    
        sasl.gl.drawTexture(texture, poi.x-16, poi.y-16, 32,32, color)
        sasl.gl.drawText(Font_ECAMfont, poi.x+20, poi.y-20, poi.id, 32, true, false, TEXT_ALIGN_LEFT, color)
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

local function refresh_terrain_texture(data)
    if ND_terrain.is_ready == nil then
        -- This may happen on sasl reboot
        update_terrain_altitudes(data)
    end
    
    -- if the zoom changes or we are too far from the reference point,
    -- we ask to recompute all the coordinates
    
    -- Unfortuntaely, the precision of the map depends on teh latitude. At high latitude and large
    -- range, the limit of the reference point increases
    local approx_limit_up = Math_rescale(ND_RANGE_10, 0.1, ND_RANGE_320, 3.0, data.config.range)
    local approx_limit = Math_rescale(0, 0.1, 90, approx_limit_up, math.abs(data.inputs.plane_coords_lat))
    
    local refresh_condition = data.config.prev_range ~= data.config.range  or data.config.prev_mode ~= data.config.mode
       or math.abs(data.terrain.center[data.terrain.texture_in_use][1] - data.inputs.plane_coords_lat) > approx_limit
       or math.abs(data.terrain.center[data.terrain.texture_in_use][2] - data.inputs.plane_coords_lon) > approx_limit

    if refresh_condition then
        data.bl_lat = nil
        data.bl_lon = nil
        data.tr_lat = nil
        data.tr_lon = nil
    end
    
    if data.config.prev_range ~= data.config.range or data.config.prev_mode ~= data.config.mode then
        data.terrain.texture[1] = nil
        data.terrain.texture[2] = nil
    end
    
    if get(TIME) - data.terrain.last_update > 3 or refresh_condition then
        local functions_for_terrain = {
            get_lat_lon_heading = rose_get_lat_lon_with_heading,
            get_x_y_heading = rose_get_x_y_heading
        }
        data.terrain.texture_in_use = data.terrain.texture_in_use == 1 and 2 or 1
        
        local x1,y1 = rose_get_lat_lon(data, 900, 450)
        local x2,y2 = rose_get_lat_lon(data, 0, 450)
        local x3,y3 = rose_get_lat_lon(data, 0, 900)
        geo_rectangle = { 
            A = {x1,y1}, -- Middle right
            B = {x2,y2}, -- Middle left
            C = {x3,y3}, -- Top left
        }
        update_terrain(data, functions_for_terrain, geo_rectangle)
        data.terrain.last_update = get(TIME)
    end

    data.config.prev_range = data.config.range
    data.config.prev_mode = data.config.mode

end

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

    if ND_terrain.is_ready == nil then
        -- This may happen on sasl reboot
        update_terrain_altitudes(data)
    end

    data.terrain.request_refresh = true

    local incoming_texture = data.terrain.texture_in_use == 1 and 2 or 1
    local outgoing_texture = data.terrain.texture_in_use
    
    if data.terrain.texture[incoming_texture] then
        local diff_x, diff_y = rose_get_x_y_heading(data, data.terrain.center[incoming_texture][1], data.terrain.center[incoming_texture][2], data.inputs.heading)
        local shift_x = 450-diff_x
        local shift_y = 450-diff_y
        reset_terrain_mask(data, image_mask_rose_terr)
        sasl.gl.drawRotatedTexture(data.terrain.texture[incoming_texture], -data.inputs.heading, -shift_x-70, -shift_y-70, 900+140,900+140, {1,1,1})
        if DEBUG_terrain_center then
            -- Draw an X where the terrain center is located
            sasl.gl.drawWideLine(diff_x-10, diff_y-10, diff_x+10, diff_y+10, 4, ECAM_MAGENTA)
            sasl.gl.drawWideLine(diff_x-10, diff_y+10, diff_x+10, diff_y-10, 4, ECAM_MAGENTA)
        end
    end
    
    if data.terrain.texture[outgoing_texture] then
        local diff_x, diff_y = rose_get_x_y_heading(data, data.terrain.center[outgoing_texture][1], data.terrain.center[outgoing_texture][2], data.inputs.heading)
        local shift_x = 450-diff_x
        local shift_y = 450-diff_y

        draw_terrain_mask(data, image_mask_rose_terr, 450)
        sasl.gl.drawRotatedTexture(data.terrain.texture[outgoing_texture], -data.inputs.heading, -shift_x-70, -shift_y-70, 900+140,900+140, {1,1,1})
        reset_terrain_mask(data, image_mask_rose)
    end
    
    sasl.gl.drawRectangle(0, 450, 900, 450, {10/255, 15/255, 25/255 , 1-data.terrain.brightness})
end


local function draw_arpt_symbol(data)
    local apt = FMGS_get_apt_dep()
    if not apt then
        return
    end
    
    local rwy, sibl = FMGS_dep_get_rwy(false)
    if not rwy then
        local x, y = rose_get_x_y_heading(data, apt.lat, apt.lon, data.inputs.heading)
        apt.x = x
        apt.y = y
        draw_poi_array(data, apt, image_point_apt, ECAM_WHITE)
    else
        local x_start, y_start = rose_get_x_y_heading(data, rwy.lat, rwy.lon, data.inputs.heading)
        local x_end, y_end     = rose_get_x_y_heading(data, rwy.s_lat, rwy.s_lon, data.inputs.heading)

        local angle = compute_angle(x_end,y_end,x_start,y_start)    -- This is the runway angle
        local perp_angle = angle + 3.14 / 2 -- This the angle of the base of the runway (perpendicular to the runway)
        
        -- Draw runway
        
        local x_shift = 7 * math.cos(perp_angle)
        local y_shift = 7 * math.sin(perp_angle)
        
        -- LL = Lower-Left, LR=Lower-Right, UL=Upper-Left, UR=Upper-Right
        local ll_x = x_start + x_shift
        local ll_y = y_start + y_shift
        local lr_x = x_start - x_shift
        local lr_y = y_start - y_shift
        local ul_x = x_end   + x_shift
        local ul_y = y_end   + y_shift
        local ur_x = x_end   - x_shift
        local ur_y = y_end   - y_shift

        sasl.gl.drawWideLine(ll_x, ll_y, ul_x, ul_y, 3, ECAM_WHITE)
        sasl.gl.drawWideLine(lr_x, lr_y, ur_x, ur_y, 3, ECAM_WHITE)
        if data.config.range >= ND_RANGE_160 then
            sasl.gl.drawWideLine(ll_x, ll_y, lr_x, lr_y, 3, ECAM_WHITE)
            sasl.gl.drawWideLine(ul_x, ul_y, ur_x, ur_y, 3, ECAM_WHITE)
        end

        local t_x, t_y = (x_end-x_start)/2+x_start+10*x_shift, (y_end-y_start)/2+y_start+10*y_shift
        sasl.gl.drawText(Font_ECAMfont, t_x, t_y, apt.id, 28, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_ECAMfont, t_x, t_y-30, sibl and rwy.sibl_name or rwy.name, 28, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
end

local function draw_active_fpln(data)
    local functions = {
        draw_poi_array = draw_poi_array,
        get_x_y_heading = rose_get_x_y_heading,
        get_px_per_nm = rose_get_px_per_nm
    }

    ND_draw_active_fpln(data, functions)
end

local function draw_pois(data)

    if data.config.range <= ND_RANGE_ZOOM_2 then
        return  -- POIs are not drawn during the zoom mode
    end
    
    if data.misc.map_not_avail then
        return -- No POI is map not avail
    end

    if data.config.mode ~= ND_MODE_NAV then
        return -- No POI in LS or VOR mode
    end

    
    draw_airports(data)
    draw_vors(data)
    draw_dmes(data)
    draw_ndbs(data)
    draw_wpts(data)

    draw_arpt_symbol(data)
    draw_active_fpln(data)

    local need_to_update_poi = (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE
    if need_to_update_poi then
        poi_position_last_update = get(TIME)
    end

end

local function draw_oans_arrow(data)

    if data.oans.displayed_apt and data.oans.displayed_apt.distance and data.oans.displayed_apt.distance > 5 then
        local lat = data.oans.displayed_apt.lat
        local lon = data.oans.displayed_apt.lon

        local bearing = get_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
        
        local angle = ((-90-bearing)%360)-data.inputs.heading
        sasl.gl.drawRotatedTexture(image_oans_needle, angle, (size[1]-37)/2,(size[2]-556)/2,37,556, {1,1,1})
        
        local new_angle = angle + Math_rescale(0, 30, 180, 15, (angle < 180 and angle > 0) and angle or math.abs(360-(angle%360)))

        local R = 230
        local x = 420 + R * math.sin(math.rad(new_angle-180))
        local y = 450 + R * math.cos(math.rad(new_angle-180))
        sasl.gl.drawText(Font_ECAMfont, x, y, data.oans.displayed_apt.id, 32, true, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
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

function draw_rose_unmasked(data)
    draw_backgrounds(data)
    draw_fixed_symbols(data)
    draw_track_symbol(data)
    draw_hdgsel_symbol(data)
    draw_ls_symbol(data)
    draw_ranges(data)
end

function draw_rose(data)

    draw_terrain(data)
    draw_pois(data)
    draw_tcas(data)
    
    if data.config.mode == ND_MODE_NAV then
        local functions_for_oans = {
            get_lat_lon = rose_get_lat_lon,
            get_x_y = rose_get_x_y,
            get_px_per_nm = rose_get_px_per_nm
        }

        draw_oans(data, functions_for_oans)
        
        if data.config.range <= ND_RANGE_ZOOM_2 then
            draw_oans_arrow(data)
        end
    end

    draw_navaid_pointers(data)

end

function update_terrain_texture_rose(data)

    if data.terrain.request_refresh then
        refresh_terrain_texture(data)
    end
    data.terrain.request_refresh = false
end
