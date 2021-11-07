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
-- File: graphics_plan.lua
-- Short description: PLAN mode file
-------------------------------------------------------------------------------

include("ND/subcomponents/graphics_oans.lua")
include('libs/geo-helpers.lua')
size = {900, 900}

local image_point_apt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-apt.png")
local image_point_vor_only = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-only.png")
local image_point_vor_dme  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-dme.png")
local image_point_dme_only  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-dme-only.png")
local image_point_ndb = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-ndb.png")
local image_point_wpt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-wpt.png")

-------------------------------------------------------------------------------
-- Caching math functions
-------------------------------------------------------------------------------
local msin = math.sin
local mcos = math.cos
local mrad = math.rad
local mdeg = math.deg
local msqrt = math.sqrt
local matan2 = math.atan2

local poi_position_last_update = 0
local POI_UPDATE_RATE = 0.1
local MAX_LIMIT_WPT = 750

-------------------------------------------------------------------------------
-- Helpers functions
-------------------------------------------------------------------------------

local function plan_get_px_per_nm(data)
    -- 621 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    return 621 / range_in_nm
end

local function plan_get_x_y(data, lat, lon)  -- Do not use this for poi
    local px_per_nm = plan_get_px_per_nm(data)
    
    local distance = get_distance_nm(data.plan_ctr_lat, data.plan_ctr_lon,lat,lon)
    local distance_px = distance * px_per_nm
    local bearing  = get_bearing(data.plan_ctr_lat, data.plan_ctr_lon,lat,lon)

    local x = size[1]/2 + distance_px * mcos(mrad(bearing))
    local y = size[2]/2 + distance_px * msin(mrad(bearing))
    
    return x,y
end

local function plan_get_lat_lon(data, x, y)
    local bearing     = 180+mdeg(matan2((size[1]/2 - x), (size[2]/2 -    y)))
    
    local px_per_nm = plan_get_px_per_nm(data)
    local distance_nm = msqrt((size[1]/2 - x)*(size[1]/2 - x) + (size[2]/2 - y)*(size[2]/2 - y)) / px_per_nm

    return Move_along_distance(data.plan_ctr_lat, data.plan_ctr_lon, distance_nm*1852, bearing)
end

-------------------------------------------------------------------------------
-- draw_* functions
-------------------------------------------------------------------------------

local function draw_ranges(data)
    -- Ranges
    if data.config.range > 0 then
        local ext_range = math.floor(2^(data.config.range-1) * 10 / 2) 
        local int_range = math.floor(ext_range / 2)
        sasl.gl.drawText(Font_AirbusDUL, 240, 260, ext_range, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, 365, 340, int_range, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    end

end

local function draw_background(data)
    ND_DRAWING_dashed_arcs(450,450,147, 3, 20,20,0, 360, true, true, false, ECAM_WHITE)
    sasl.gl.drawArc(450, 450, 292, 295,0,360,ECAM_WHITE)
    ND_DRAWING_small_triangle(730 ,450 , 90)
    ND_DRAWING_small_triangle(170 ,450 , -90)
    ND_DRAWING_small_triangle(450 ,730 , 0)
    ND_DRAWING_small_triangle(450 ,170 , 180)
    sasl.gl.drawText(Font_AirbusDUL, 440, 692, "N", 36, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 440, 185, "S", 36, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 694, 438, "E", 36, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 187, 438, "W", 36, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
end

local function draw_plane(data)

    if not data.inputs.is_heading_valid then
        return
    end

    local range_in_nm = get_range_in_nm(data)
    local px_per_nm = plan_get_px_per_nm(data)

    local distance = get_distance_nm(data.plan_ctr_lat, data.plan_ctr_lon, data.inputs.plane_coords_lat,data.inputs.plane_coords_lon)

    if distance > range_in_nm then
        return
    end

    local bearing  = get_bearing(data.plan_ctr_lat, data.plan_ctr_lon, data.inputs.plane_coords_lat,data.inputs.plane_coords_lon)
    local distance_px = distance * px_per_nm

    local plane_pos_x = size[1]/2 + distance_px * mcos(mrad(bearing))
    local plane_pos_y = size[1]/2 + distance_px * msin(mrad(bearing))
    local angle = -data.inputs.true_heading
    
    -- Plane
    local x1, y1 = rotate_xy_point(plane_pos_x, plane_pos_y-37, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_xy_point(plane_pos_x, plane_pos_y+37, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)

    local x1, y1 = rotate_xy_point(plane_pos_x-40, plane_pos_y+13, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_xy_point(plane_pos_x+40, plane_pos_y+13, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)

    local x1, y1 = rotate_xy_point(plane_pos_x-15, plane_pos_y-22, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_xy_point(plane_pos_x+15, plane_pos_y-22, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)
    
end

local function draw_poi_array(data, poi, texture, color)
    local modified = false

    -- 621 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    local px_per_nm = 621 / range_in_nm

    if poi.plan_dist == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
       poi.plan_dist = get_distance_nm(data.plan_ctr_lat, data.plan_ctr_lon,poi.lat,poi.lon)
    end
    
    if poi.plan_dist > range_in_nm * 2 then

        return true, poi
    end

    if poi.x == nil or poi.y == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
        modified = true
        
        poi.x, poi.y = plan_get_x_y(data, poi.lat,poi.lon)
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

local function draw_active_fpln(data)   -- This is just a test

    local active_legs = FMGS_get_enroute_legs()

    local routes = {{}}
    local i_route = 1
    -- For each point in the FPLN...
    for k,x in ipairs(active_legs) do

        if not x.discontinuity then

            local c_x,c_y = plan_get_x_y(data, x.lat, x.lon)
            table.insert(routes[i_route], c_x)
            table.insert(routes[i_route], c_y)
            x.x = c_x
            x.y = c_y

            local color = k == 1 and ECAM_WHITE or ECAM_GREEN

            if x.ptr_type == FMGS_PTR_WPT then
                draw_poi_array(data, x, image_point_wpt, color)
            elseif x.ptr_type == FMGS_PTR_NAVAID then
                if x.navaid_type == NAV_ID_NDB then
                    draw_poi_array(data, x, image_point_ndb, color)
                elseif x.navaid_type == NAV_ID_VOR then
                    draw_poi_array(data, x, x.has_dme and image_point_vor_dme or image_point_vor_only, color)
                end -- TODO missing cases
            elseif x.ptr_type == FMGS_PTR_APT then
                draw_poi_array(data, x, image_point_apt, color)
            elseif x.ptr_type == FMGS_PTR_COORDS then
                -- TODO Does it exist this case?
            end
        else
            i_route = i_route + 1
            routes[i_route] = {}
        end
    end
    
    for i=1,i_route do
        local route = routes[i]
        if #route > 0 then
            sasl.gl.drawWidePolyLine(route, 2, ECAM_GREEN)
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

    draw_active_fpln(data)

    local need_to_update_poi = (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE
    if need_to_update_poi then
        poi_position_last_update = get(TIME)
    end

end

local functions_for_oans = {
    get_lat_lon = plan_get_lat_lon,
    get_x_y = plan_get_x_y,
    get_px_per_nm = plan_get_px_per_nm
}

function draw_plan_unmasked(data)
    draw_background(data)
    draw_ranges(data)
end

function draw_plan(data)
    draw_pois(data)
    draw_oans(data, functions_for_oans)
    draw_plane(data)
end

