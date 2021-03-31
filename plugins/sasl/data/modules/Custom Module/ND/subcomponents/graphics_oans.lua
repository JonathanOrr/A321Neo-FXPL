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
-- Short description: OANS mode file
-------------------------------------------------------------------------------
include("ND/subcomponents/helpers.lua")

local ffi = require("ffi")  -- This is needed to convert C string of raw data

local Y_ARC_CENTER = 145
-------------------------------------------------------------------------------
-- Textures
-------------------------------------------------------------------------------

local image_black_square    = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/black-square.png")
local image_icon_flag       = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/icon-flag.png")
local image_icon_cross      = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/icon-cross.png")

-------------------------------------------------------------------------------
-- Caching math functions
-------------------------------------------------------------------------------
local msin = math.sin
local mcos = math.cos
local mdeg = math.deg

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function rotate_cached_triangle(data, points)
    local y_center = data.config.mode == ND_MODE_ARC and Y_ARC_CENTER or 450
    local rot_ctr_x = 450 - data.oans_cache.diff_x
    local rot_ctr_y = y_center - data.oans_cache.diff_y
    points[1], points[2] = rotate_xy_point(points[1], points[2], rot_ctr_x, rot_ctr_y, data.oans_cache.diff_bear)
    points[3], points[4] = rotate_xy_point(points[3], points[4], rot_ctr_x, rot_ctr_y, data.oans_cache.diff_bear)
    points[5], points[6] = rotate_xy_point(points[5], points[6], rot_ctr_x, rot_ctr_y, data.oans_cache.diff_bear)
end

local function rotate_cached_point(data, x, y)
    local y_center = data.config.mode == ND_MODE_ARC and Y_ARC_CENTER or 450
    local rot_ctr_x = 450 - data.oans_cache.diff_x
    local rot_ctr_y = y_center - data.oans_cache.diff_y
    return rotate_xy_point(x, y, rot_ctr_x, rot_ctr_y, data.oans_cache.diff_bear)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local function draw_oans_rwy(data, rwy_start, functions)

    -- Welcome in the horrible world of drawing a runway...

    local x_start,y_start = functions.get_x_y(data, rwy_start.lat, rwy_start.lon)   -- Start middle point of a runway
    local x_end,y_end = functions.get_x_y(data, rwy_start.s_lat, rwy_start.s_lon)   -- End middle point of a runway

    local px_per_nm = functions.get_px_per_nm(data)
    local semiwidth_px = math.floor(rwy_start.width * 0.000539957 * px_per_nm / 2)

    local angle = compute_angle(x_end,y_end,x_start,y_start)    -- This is the runway angle
    local perp_angle = angle + 3.14 / 2 -- This the angle of the base of the runway (perpendicular to the runway)
    
    -- Draw runway
    
    local x_shift = semiwidth_px * mcos(perp_angle)
    local y_shift = semiwidth_px * msin(perp_angle)
    
    -- LL = Lower-Left, LR=Lower-Right, UL=Upper-Left, UR=Upper-Right
    local ll_x = x_start + x_shift
    local ll_y = y_start + y_shift
    local lr_x = x_start - x_shift
    local lr_y = y_start - y_shift
    local ul_x = x_end   + x_shift
    local ul_y = y_end   + y_shift
    local ur_x = x_end   - x_shift
    local ur_y = y_end   - y_shift

    -- Let's draw the pavement of the runway...
    sasl.gl.drawConvexPolygon ({ll_x, ll_y, lr_x, lr_y , ur_x, ur_y  , ul_x, ul_y} , true , 1 , {0.6,0.6,0.6})
    
    -- Draw runway marks
    local dist_line = 7
    local x_shift_line = (semiwidth_px-dist_line) * mcos(perp_angle)
    local y_shift_line = (semiwidth_px-dist_line) * msin(perp_angle)
    local x_shift_inner = dist_line * mcos(angle)
    local y_shift_inner = dist_line * msin(angle)

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

    -- Draw sign middle
    local m_x = (x_start + x_end) / 2
    local m_y = (y_start + y_end) / 2
    local m_angle = -mdeg(angle)
    if m_angle > 180 then m_angle = m_angle - 180 end
    if m_angle < 0 then m_angle = m_angle + 180 end
    
    
    if semiwidth_px*2 >= 40 then    -- When the runway is sufficiently large, we draw the number on it
        local font_size = 50
        local text_rwy = rwy_start.sibl_name .. "-" .. rwy_start.name
        
        local width, height = sasl.gl.measureText (Font_AirbusDUL, text_rwy, font_size, false, false)
        
        sasl.gl.drawRotatedTexturePart(image_black_square, m_angle, m_x-width/2-2 , m_y-height/2, width+4, height, 0, 0, width+4, height, {0,0,0})    
        sasl.gl.drawRotatedText(Font_AirbusDUL, m_x , m_y-height/2 , m_x, m_y, m_angle, text_rwy, font_size, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    -- Runway sign start/end
    m_angle = m_angle+90
    
    local direction = tonumber(string.sub(rwy_start.name,1,2))
    if direction ~= nil then
        if direction >= 9 and direction < 27 then
            if  m_angle < 90 or m_angle > 270 then
                m_angle = m_angle + 180
            end
        else
            if m_angle >= 90 and m_angle <= 270 then
                m_angle = m_angle + 180
            end
        end
    end

    local dist_text = -70
    local x_shift = x_start + dist_text * mcos(angle)
    local y_shift = y_start + dist_text * msin(angle)
    local font_size = 50
    local width = 30 * #rwy_start.name
    sasl.gl.drawRotatedText(Font_AirbusDUL, x_shift, y_shift, x_shift, y_shift, m_angle, rwy_start.name, font_size, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    local x_shift = x_end - dist_text * mcos(angle)
    local y_shift = y_end - dist_text * msin(angle)
    sasl.gl.drawRotatedText(Font_AirbusDUL, x_shift, y_shift, x_shift, y_shift, 180+m_angle, rwy_start.sibl_name, font_size, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

end

local function draw_oans_rwys(data, functions, apt)
    for rwyname,rwy in pairs(apt.rwys) do   -- For each runway...
        draw_oans_rwy(data, rwy, functions)
    end
end

local function draw_oans_airport_bounds(data, functions, apt, apt_details)

    if data.oans_cache.apt_bounds == nil then
       data.oans_cache.apt_bounds = {}
    end

    for i=0,apt_details.boundaries_len-1 do -- For each bound area (I expected there's only one per
                                            -- airport, but don't trust this).
    
        ----- CACHING START
        if data.oans_cache.apt_bounds[i] == nil then
            data.oans_cache.apt_bounds[i] = {}
            local bound_array = apt_details.boundaries[i]
            local triangles = AvionicsBay.graphics.triangulate_apt_node(bound_array)    -- C++ call
            
            for j=0,triangles.points_len-1 do
                local x,y = functions.get_x_y(data, triangles.points[j].lat, triangles.points[j].lon)
                table.insert(data.oans_cache.apt_bounds[i], x)
                table.insert(data.oans_cache.apt_bounds[i], y)
            end
        end
        ----- CACHING END

        local curr_nr_points = #data.oans_cache.apt_bounds[i]
        for k=1,curr_nr_points do
            if k % 6 == 0 then  -- For each triangle
                local points = { data.oans_cache.apt_bounds[i][k-5] - data.oans_cache.diff_x,
                                 data.oans_cache.apt_bounds[i][k-4] - data.oans_cache.diff_y,
                                 data.oans_cache.apt_bounds[i][k-3] - data.oans_cache.diff_x,
                                 data.oans_cache.apt_bounds[i][k-2] - data.oans_cache.diff_y,
                                 data.oans_cache.apt_bounds[i][k-1] - data.oans_cache.diff_x,
                                 data.oans_cache.apt_bounds[i][k] - data.oans_cache.diff_y
                               }
                rotate_cached_triangle(data, points)
                sasl.gl.drawConvexPolygon (points, true, 0, {0.1,0.1,0.1})
            end
        end
    end
end


local function draw_oans_taxiways(data, functions, apt, apt_details)

    if data.oans_cache.taxi_c_p == nil then
       data.oans_cache.taxi_c_p = {}
    end

    local color = {0.5,0.5,0.5}
    if data.config.range == ND_RANGE_ZOOM_2 then    -- Color change for greater zooms
        color = {0.2,0.2,0.2}
    end

    for i=0,apt_details.pavements_len-1 do  -- For each taxiway...
        local bound_array = apt_details.pavements[i]

        ----- CACHING START
        if data.oans_cache.taxi_c_p[i] == nil then
            local triangles = AvionicsBay.graphics.triangulate_apt_node(bound_array)

            data.oans_cache.taxi_c_p[i] = {}
            for j=0,triangles.points_len-1 do
                local x,y = functions.get_x_y(data, triangles.points[j].lat, triangles.points[j].lon)
                table.insert(data.oans_cache.taxi_c_p[i], x)
                table.insert(data.oans_cache.taxi_c_p[i], y)

            end
        end
        ----- CACHING END

        local curr_nr_points = #data.oans_cache.taxi_c_p[i]
        for k=1,curr_nr_points do
            if k % 6 == 0 then  -- For each triangle
                local points = { data.oans_cache.taxi_c_p[i][k-5] - data.oans_cache.diff_x,
                                 data.oans_cache.taxi_c_p[i][k-4] - data.oans_cache.diff_y,
                                 data.oans_cache.taxi_c_p[i][k-3] - data.oans_cache.diff_x,
                                 data.oans_cache.taxi_c_p[i][k-2] - data.oans_cache.diff_y,
                                 data.oans_cache.taxi_c_p[i][k-1] - data.oans_cache.diff_x,
                                 data.oans_cache.taxi_c_p[i][k] - data.oans_cache.diff_y
                               }
                rotate_cached_triangle(data, points)
                sasl.gl.drawConvexPolygon (points, true, 0, color)
            end
        end
    end
end

local function draw_oans_mark_lines(data, functions, apt, apt_details)

    local len = apt_details.linear_features_len  -- They must be drawn in the opposite order

    if data.oans_cache.mark_lines == nil then
        data.oans_cache.mark_lines = {}
    end

    for i=len-1, 0, -1 do   -- For each line
        local line = apt_details.linear_features[i]
        
        -- >= 60 numbering is not in apt.dat specification, but some airports have them, like KJFK

        if    line.color == 1 or line.color == 51 or line.color == 60 or line.color == 61   -- Taxiway centerlines 
           or line.color == 4 or line.color == 54   -- Runways hold positions
           or line.color == 5 or line.color == 55   -- Non-runway hold positions
           or line.color == 8 or line.color == 58   -- Lanes queue
           or line.color == 9 or line.color == 59   -- Lanes queue
           or line.color == 22 or line.color == 62  -- Roadway centerline
        then

            local color = COLOR_YELLOW
            if line.color == 4 or line.color == 54 then
                color = ECAM_RED
            elseif line.color == 5 or line.color == 55 then
                color = ECAM_WHITE
            elseif line.color == 8 or line.color == 58 or line.color == 9 or line.color == 59 then
                color = ECAM_WHITE
            elseif line.color == 22 or line.color == 62 then
                color = {0.55, 0.55, 0}
            end

            local last_prev_x = nil
            local last_prev_y = nil

            if data.oans_cache.mark_lines[i] == nil then
                data.oans_cache.mark_lines[i] = {}
            end

            -- Ok so, we have to do one segment at a time
            -- DO NOT use PolyLine here for two reasons:
            -- - At some point in the future we will implement curved lines and we cannot use PolyLine for them
            -- - You have to rototranslate each single point in any case (then you need a for), so it's useless

            for j=0,line.nodes_len-1 do -- For each line point
            
                ----- CACHING START
                if data.oans_cache.mark_lines[i][j] == nil then
                    local x,y = functions.get_x_y(data, line.nodes[j].coords.lat, line.nodes[j].coords.lon)
                    data.oans_cache.mark_lines[i][j] = {x,y}
                end
                ----- CACHING END

                -- Translate and rotate the original cache x,y to the actualy one
                local x = data.oans_cache.mark_lines[i][j][1] - data.oans_cache.diff_x
                local y = data.oans_cache.mark_lines[i][j][2] - data.oans_cache.diff_y
                x, y = rotate_cached_point(data, x, y)

                if last_prev_x ~= nil and last_prev_y ~= nil then   -- Skip the first point of the line
                    sasl.gl.drawWideLine(last_prev_x, last_prev_y, x, y, 3, color)
                end
                last_prev_x = x
                last_prev_y = y
            end
        end
    end

end

local function draw_oans_tower(data, functions, apt, apt_details)

    if apt_details.tower_pos.lat ~= 0. then -- There's ONE and only ONE tower per airport in XP apt.dat
    
        -- No need to cache, just 1 call of get_x_y
        local x,y = functions.get_x_y(data, apt_details.tower_pos.lat, apt_details.tower_pos.lon)
        
        local width  = 40
        local height =  36
        local y_shift = (height-3)/2

        sasl.gl.drawRectangle (x-width/2-2, y-y_shift-3+data.config.range, width+4, height-4,  {0,0,0})
        sasl.gl.drawText(Font_AirbusDUL,x,y-y_shift, "TWR", height-4, false, false, TEXT_ALIGN_CENTER, {0., 0.6, 0.})
        k_v = height - 5
        sasl.gl.drawTriangle ( x-15, y+k_v, x+15, y+k_v , x, y+k_v+15, {0., 0.6, 0.})
    
    end
end

local function draw_oans_mark_taxi(data, functions, apt, apt_details)
    if data.oans_cache.routes_four == nil then
        data.oans_cache.routes_four = {}
    end

    for i=0,apt_details.routes_len-1 do
        local route = apt_details.routes[i]
        if route.name_len > 0 then
        
            ----- CACHING START
            if data.oans_cache.routes_four[i] == nil then
                local point_1 = AvionicsBay.apts.get_route(apt.ref_orig, route.route_node_1)
                local point_2 = AvionicsBay.apts.get_route(apt.ref_orig, route.route_node_2)
                local x1,y1 = functions.get_x_y(data, point_1.lat, point_1.lon)
                local x2,y2 = functions.get_x_y(data, point_2.lat, point_2.lon)

                local x = (x1+x2)/2
                local y = (y1+y2)/2

                data.oans_cache.routes_four[i] = {x,y}
            end
            ----- CACHING END

            -- Translate and rotate the original cache x,y to the actualy one
            local x = data.oans_cache.routes_four[i][1] - data.oans_cache.diff_x
            local y = data.oans_cache.routes_four[i][2] - data.oans_cache.diff_y
            x, y = rotate_cached_point(data, x, y)

            local name = ffi.string(route.name, route.name_len);

            local width  = 20 * #name
            local height = 36
            local y_shift = (height-3)/2

            sasl.gl.drawRectangle (x-width/2, y-y_shift-3+data.config.range, width, height-4,  {0,0,0})

            sasl.gl.drawText(Font_AirbusDUL,x,y-y_shift, name, height-4, false, false, TEXT_ALIGN_CENTER, COLOR_YELLOW)
        end
    end
end

local function draw_oans_mark_gate(data, functions, apt, apt_details)

    if data.oans_cache.gates == nil then
        data.oans_cache.gates = {}
    end

    for i=0,apt_details.gates_len-1 do  -- For each gate...
        local gate = apt_details.gates[i]
        local name = ffi.string(gate.name, gate.name_len);

        ----- CACHING START
        if data.oans_cache.gates[i] == nil then
            local x,y = functions.get_x_y(data, gate.coords.lat, gate.coords.lon)
            data.oans_cache.gates[i] = {x,y}
        end
        ----- CACHING END

        -- Translate and rotate the original cache x,y to the actualy one
        local x = data.oans_cache.gates[i][1] - data.oans_cache.diff_x
        local y = data.oans_cache.gates[i][2] - data.oans_cache.diff_y
        x, y = rotate_cached_point(data, x, y)

        
        local width  = 20 * #name -- Behind rectangle width
        local height = 36         -- ... and height
        local y_shift = (height-3)/2

        sasl.gl.drawRectangle (x-width/2, y-y_shift-3+data.config.range, width, height-4,  {0,0,0})
        sasl.gl.drawText(Font_AirbusDUL,x,y-y_shift, name, height-4, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end

end

local function draw_oans_flags_and_crosses(data,functions)

    -- Flags
    for i,flag in ipairs(data.poi.flag) do
        if flag.x ~= nil then
            flag.lat, flag.lon = functions.get_lat_lon(data,flag.x,flag.y)
            flag.x = nil
            flag.y = nil
        end
        local x,y = functions.get_x_y(data, flag.lat, flag.lon)
        sasl.gl.drawTexture(image_icon_flag, x-25, y-35, 50, 70, {1,1,1})
    end

    -- Crosses
    for i,cross in ipairs(data.poi.cross) do
        if cross.x ~= nil then
            cross.lat, cross.lon = functions.get_lat_lon(data,cross.x,cross.y)
            cross.x = nil
            cross.y = nil
        end
        local x,y = functions.get_x_y(data, cross.lat, cross.lon)
        sasl.gl.drawTexture(image_icon_cross, x-25, y-25, 50, 50, {1,1,1})
    end
end

-------------------------------------------------------------------------------
-- Cache-related
-------------------------------------------------------------------------------

local function update_oans_cache(data, functions, apt)

    local local_lat = nd_data.config.mode == ND_MODE_PLAN and data.plan_ctr_lat or data.inputs.plane_coords_lat
    local local_lon = nd_data.config.mode == ND_MODE_PLAN and data.plan_ctr_lon or data.inputs.plane_coords_lon
    local local_angle = nd_data.config.mode == ND_MODE_PLAN and 0 or data.inputs.heading

    if    data.oans_cache == nil or data.oans_cache.mode ~= data.config.mode
       or data.oans_cache.range ~= data.config.range or data.oans_cache.apt_id ~= apt.id then
        -- These are the cases when we need to wipe (or initialize) the cache
        data.oans_cache = {
            mode = data.config.mode,
            range = data.config.range,
            apt_id = apt.id,
            ref_lat = local_lat,
            ref_lon = local_lon,
            ref_bear = local_angle
        }
    end

    -- Compute the difference position in px from the original one to the current position,
    -- so that we can use the cache data

    local x_now, y_now = functions.get_x_y(data, local_lat, local_lon)
    local x_orig, y_orig = functions.get_x_y(data, data.oans_cache.ref_lat, data.oans_cache.ref_lon)

    data.oans_cache.diff_x    = x_now - x_orig  -- This is the offset between the center of the cache and the current center (X)
    data.oans_cache.diff_y    = y_now - y_orig  -- This is the offset between the center of the cache and the current center (Y)
    data.oans_cache.diff_bear = nd_data.config.mode == ND_MODE_PLAN and 0 or data.inputs.heading - data.oans_cache.ref_bear -- This is the bearing offset
end

-------------------------------------------------------------------------------
-- Main draw functions
-------------------------------------------------------------------------------

function draw_oans_go(data, functions, apt, apt_details)

    -- 1st Airport bounds (cached)
    draw_oans_airport_bounds(data, functions, apt, apt_details)

    -- 2nd Taxiways (cached)
    draw_oans_taxiways(data, functions, apt, apt_details)

    -- 2rd Various yellow and not lines (cached)
    if data.config.range <= ND_RANGE_ZOOM_1 then
        draw_oans_mark_lines(data, functions, apt, apt_details)
    end

    -- 3th Runways (NOT cached)
    draw_oans_rwys(data, functions, apt)

    if data.config.range <= ND_RANGE_ZOOM_05 then
        -- 4th Tower position (NOT cached)
        draw_oans_tower(data, functions, apt, apt_details)
        -- 5th Taxi names (cached)
        draw_oans_mark_taxi(data, functions, apt, apt_details)
    end

    -- 6th Gates names (cached)
    if data.config.range <= ND_RANGE_ZOOM_02 then
        draw_oans_mark_gate(data, functions, apt, apt_details)
    end

    -- 7th Flags and crosses (NOT cached)
    if data.config.range <= ND_RANGE_ZOOM_1 then
        draw_oans_flags_and_crosses(data,functions)
    end

end

function draw_oans(data, functions)
    assert(data)

    if data.config.range > ND_RANGE_ZOOM_2 then
        data.misc.please_wait = false
        return  -- No OANS over zoom
    end
    
    local failure_condition = (get(GPS_1_is_available) == 0 and get(GPS_2_is_available) == 0) or adirs_how_many_irs_fully_work() < 3
    if failure_condition then
        data.misc.apt_pos_lost = true
        return
    end
    
    data.misc.apt_pos_lost = false
    data.misc.please_wait  = true   -- Let's turn on the message

    local nearest_airport = AvionicsBay.apts.get_nearest_apt(true)
    
    local apt = nearest_airport -- TODO: Change depending on MCDU ecc.

    if apt == nil then
        return  -- Nearest airport not yet loaded
    end

    AvionicsBay.apts.request_details(apt.id)
    
    if not AvionicsBay.apts.details_available(apt.id) then
        return -- Still loading the details
    end

    local apt_details = AvionicsBay.apts.get_details(apt.id)

    if (data.plan_ctr_lat == 0 and data.plan_ctr_lon == 0) or (data.oans_cache == nil or data.oans_cache.apt_id ~= apt.id) then
        -- This is for PLAN only, PLAN initial position is the airport center
        data.plan_ctr_lat = apt.lat
        data.plan_ctr_lon = apt.lon
    end

    update_oans_cache(data, functions, apt) -- Init/Wipe the cache if needed and update the offsets
    
    draw_oans_go(data, functions, apt, apt_details)

    data.misc.please_wait = false  -- If we reached this point, the the OANS is actually drawn
end


