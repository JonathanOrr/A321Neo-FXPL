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

include("ND/subcomponents/helpers.lua")
include("ND/subcomponents/graphics_plan_mouse.lua")

size = {900, 900}


local image_bkg_plan        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/plan.png")
local image_bkg_plan_middle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/ring-middle.png")

local COLOR_YELLOW = {1,1,0}

local function get_px_per_nm(data)
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




local function rotate_point(point_to_rotate_x, point_to_rotate_y, center_of_rotation_x, center_of_rotation_y, angle)
    local cos_t = math.cos(math.rad(angle))
    local sin_t = math.sin(math.rad(angle))

    local x = cos_t * (point_to_rotate_x - center_of_rotation_x) - 
              sin_t * (point_to_rotate_y - center_of_rotation_y) + center_of_rotation_x

    local y = sin_t * (point_to_rotate_x - center_of_rotation_x) +
              cos_t * (point_to_rotate_y - center_of_rotation_y) + center_of_rotation_y

    return x,y
end

local function draw_plane(data)

    if not data.inputs.is_heading_valid then
        return
    end

    local range_in_nm = get_range_in_nm(data)
    local px_per_nm = get_px_per_nm(data)

    local distance = get_distance_nm(data.plan_ctr_lat, data.plan_ctr_lon, data.inputs.plane_coords_lat,data.inputs.plane_coords_lon)

    if distance > range_in_nm then
        return
    end

    local bearing  = get_bearing(data.plan_ctr_lat, data.plan_ctr_lon, data.inputs.plane_coords_lat,data.inputs.plane_coords_lon)
    local distance_px = distance * px_per_nm

    local plane_pos_x = size[1]/2 + distance_px * math.cos(math.rad(bearing))
    local plane_pos_y = size[1]/2 + distance_px * math.sin(math.rad(bearing))
    local angle = -data.inputs.true_heading
    
    -- Plane
    local x1, y1 = rotate_point(plane_pos_x, plane_pos_y-37, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_point(plane_pos_x, plane_pos_y+37, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)

    local x1, y1 = rotate_point(plane_pos_x-40, plane_pos_y+13, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_point(plane_pos_x+40, plane_pos_y+13, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)

    local x1, y1 = rotate_point(plane_pos_x-15, plane_pos_y-22, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_point(plane_pos_x+15, plane_pos_y-22, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)
    
end


local function get_x_y(data, lat, lon)  -- Do not use this for poi
    local px_per_nm = get_px_per_nm(data)
    
    local distance = get_distance_nm(data.plan_ctr_lat, data.plan_ctr_lon,lat,lon)
    local distance_px = distance * px_per_nm
    local bearing  = get_bearing(data.plan_ctr_lat, data.plan_ctr_lon,lat,lon)

    local x = size[1]/2 + distance_px * math.cos(math.rad(bearing))
    local y = size[1]/2 + distance_px * math.sin(math.rad(bearing))
    
    return x,y
end

local function draw_oans_rwy(data, rwy_start, rwy_end)

    local x_start,y_start = get_x_y(data, rwy_start.lat, rwy_start.lon)
    local x_end,y_end = get_x_y(data, rwy_end.lat, rwy_end.lon)

    local px_per_nm = get_px_per_nm(data)
    local semiwidth_px = math.floor(rwy_start.width * 0.000539957 * px_per_nm / 2)

    local angle = compute_angle(x_end,y_end,x_start,y_start)    -- This is the runway angle
    local perp_angle = angle + 3.14 / 2 -- This the angle of the base of the runway
    
    -- Draw runway
    
    local x_shift = semiwidth_px * math.cos(perp_angle)
    local y_shift = semiwidth_px * math.sin(perp_angle)
    
    local ll_x = x_start + x_shift
    local ll_y = y_start + y_shift
    local lr_x = x_start - x_shift
    local lr_y = y_start - y_shift
    local ul_x = x_end   + x_shift
    local ul_y = y_end   + y_shift
    local ur_x = x_end   - x_shift
    local ur_y = y_end   - y_shift

    sasl.gl.drawConvexPolygon ({ll_x, ll_y, lr_x, lr_y , ur_x, ur_y  , ul_x, ul_y} , true , 1 , {0.6,0.6,0.6})
    
    -- Draw runway marks
    local dist_line = 7
    local x_shift_line = (semiwidth_px-dist_line) * math.cos(perp_angle)
    local y_shift_line = (semiwidth_px-dist_line) * math.sin(perp_angle)
    local x_shift_inner = dist_line * math.cos(angle)
    local y_shift_inner = dist_line * math.sin(angle)

    local ll_x = x_start + x_shift_line + x_shift_inner
    local ll_y = y_start + y_shift_line + y_shift_inner
    local lr_x = x_start - x_shift_line + x_shift_inner
    local lr_y = y_start - y_shift_line + y_shift_inner
    local ul_x = x_end   + x_shift_line - x_shift_inner
    local ul_y = y_end   + y_shift_line - y_shift_inner
    local ur_x = x_end   - x_shift_line - x_shift_inner
    local ur_y = y_end   - y_shift_line - y_shift_inner
    sasl.gl.drawWidePolyLine  ({ll_x, ll_y, lr_x, lr_y , ur_x, ur_y  , ul_x, ul_y, ll_x, ll_y} , 1 - data.config.range * 2 , {1,1,1} )

    -- Draw center line
    sasl.gl.setLinePattern ({10.0, -10.0 })
    sasl.gl.drawLinePattern (x_start,y_start,x_end,y_end, false, ECAM_WHITE)

end

local function draw_oans_rwys(data, apt)

    local already_seen_runways = {}

    for rwyname,rwy in pairs(apt.rwys) do
        
        if already_seen_runways[rwyname] == nil then
            already_seen_runways[rwyname] = true
            already_seen_runways[rwy.sibling] = true
            
            local sibling_rwy = apt.rwys[rwy.sibling]
            draw_oans_rwy(data, rwy, sibling_rwy)
        end            
    end
end

local function draw_oans_taxiways(data, apt)
    for i,line in ipairs(apt.taxys) do
    
        local points = {}
        for j,segment in ipairs(line.points) do
            if #segment == 2 then
                local x,y = get_x_y(data, segment[1], segment[2])
                table.insert(points, x)
                table.insert(points, y)
            end
        end

        sasl.gl.drawConvexPolygon (points, false, 2, {0.5,0.5,0.5})
    end
end

local function draw_oans_mark_lines(data, apt)

    for i,line in ipairs(apt.mark_lines) do
        
        if line.color == 1 or line.color == 51 or line.color == 4 or line.color == 5 or line.color == 54 
            or line.color == 8 or line.color == 58  or line.color == 9 or line.color == 59 then

            local color = COLOR_YELLOW
            if line.color == 4 or line.color == 54 then
                color = ECAM_RED
            elseif line.color == 5 or line.color == 55 then
                color = ECAM_WHITE
            elseif line.color == 8 or line.color == 58 or line.color == 9 or line.color == 59 then
                color = ECAM_WHITE
            end

            local last_prev_x = nil 
            local last_prev_y = nil 

            for j,segment in ipairs(line.points) do
                local x,y = get_x_y(data, segment[1], segment[2])
                --if #segment == 2 then
                    if last_prev_x ~= nil and last_prev_y ~= nil then
                        sasl.gl.drawWideLine (last_prev_x, last_prev_y, x,y, 3, color)
                    end
                --else
                --    if last_prev_x ~= nil and last_prev_y ~= nil then
                --        local c_x,c_y = get_x_y(data, segment[3], segment[4])
                --        sasl.gl.drawWideBezierLineQAdaptive(last_prev_x,last_prev_y,c_x,c_y,x,y,3,color)
                --    end
                --end
                last_prev_x = x
                last_prev_y = y                
            end
            
        end        
    end

end

local function draw_oans_mark_signs(data, apt)

end

local function draw_oans(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        return  -- No OANS over zoom
    end

    local nearest_airport = Data_manager.nearest_airport
    if nearest_airport ~= nil then
        local apt = Data_manager.get_arpt_by_name(nearest_airport.id)
        
        --print(#apt.signs)
        if data.plan_ctr_lat == 0 and data.plan_ctr_lon == 0 then
            data.plan_ctr_lat = apt.lat
            data.plan_ctr_lon = apt.lon
        end
        draw_oans_rwys(data, apt)
        --draw_oans_taxiways(data, apt)
        draw_oans_mark_lines(data, apt)
        draw_oans_mark_signs(data, apt)
    end
end

function draw_plan_unmasked(data)
    draw_background(data)
    draw_ranges(data)
    draw_mouse(data)
end
function draw_plan(data)
    draw_oans(data)
    draw_plane(data)
end

