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

local image_bkg_plan        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/plan.png")
local image_bkg_plan_middle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/ring-middle.png")

-------------------------------------------------------------------------------
-- Caching math functions
-------------------------------------------------------------------------------
local msin = math.sin
local mcos = math.cos
local mrad = math.rad
local mdeg = math.deg
local msqrt = math.sqrt
local matan2 = math.atan2


local function plan_get_px_per_nm(data)
    -- 588 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data) / 2
    -- The the per_px nm is:
    return 621 / range_in_nm
end

local function draw_ranges(data)
    -- Ranges
    if data.config.range > 0 then
        local ext_range = math.floor(2^(data.config.range-1) * 10 / 2) 
        local int_range = math.floor(ext_range / 2)
        sasl.gl.drawText(Font_AirbusDUL, 230, 250, ext_range, 20, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, 365, 340, int_range, 20, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    end

end

local function draw_background(data)
    sasl.gl.drawTexture(image_bkg_plan, (size[1]-621)/2,(size[2]-621)/2,621,621, {1,1,1})
    sasl.gl.drawTexture(image_bkg_plan_middle, (size[1]-750)/2,(size[2]-750)/2,750,750, {1,1,1})
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
    draw_oans(data, functions_for_oans)
    draw_plane(data)
end

