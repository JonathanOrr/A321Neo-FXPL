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
include("ND/libs/polygon.lua")

local image_black_square    = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/black-square.png")
local image_icon_flag       = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/icon-flag.png")
local image_icon_cross      = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/icon-cross.png")

local function draw_oans_rwy(data, rwy_start, rwy_end, functions)

    local x_start,y_start = functions.get_x_y(data, rwy_start.lat, rwy_start.lon)
    local x_end,y_end = functions.get_x_y(data, rwy_end.lat, rwy_end.lon)

    local px_per_nm = functions.get_px_per_nm(data)
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

    -- Draw sign middle
    local m_x = (x_start + x_end) / 2
    local m_y = (y_start + y_end) / 2
    local m_angle = -math.deg(angle)
    if m_angle > 180 then m_angle = m_angle - 180 end
    if m_angle < 0 then m_angle = m_angle + 180 end
    
    
    if semiwidth_px*2 >= 40 then
        local font_size = 50
        local text_rwy = rwy_start.sibling .. "-" .. rwy_end.sibling
        
        local width, height = sasl.gl.measureText (Font_AirbusDUL, text_rwy, font_size, false, false)
        
        sasl.gl.drawRotatedTexturePart(image_black_square, m_angle, m_x-width/2-2 , m_y-height/2, width+4, height, 0, 0, width+4, height, {0,0,0})    
        sasl.gl.drawRotatedText(Font_AirbusDUL, m_x , m_y-height/2 , m_x, m_y, m_angle, text_rwy, font_size, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    -- Runway sign start/end
    m_angle = m_angle+90
    
    local direction = tonumber(string.sub(rwy_end.sibling,1,2))
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
    local x_shift = x_start + dist_text * math.cos(angle)
    local y_shift = y_start + dist_text * math.sin(angle)
    local font_size = 60
    local width = 30 * #rwy_end.sibling

    sasl.gl.drawRotatedText(Font_AirbusDUL, x_shift, y_shift, x_shift, y_shift, m_angle, rwy_end.sibling, font_size, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    local x_shift = x_end - dist_text * math.cos(angle)
    local y_shift = y_end - dist_text * math.sin(angle)
    sasl.gl.drawRotatedText(Font_AirbusDUL, x_shift, y_shift, x_shift, y_shift, 180+m_angle, rwy_start.sibling, font_size, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

end

local function draw_oans_rwys(data, functions, apt)

    local already_seen_runways = {}

    for rwyname,rwy in pairs(apt.rwys) do
        
        if already_seen_runways[rwyname] == nil then
            already_seen_runways[rwyname] = true
            already_seen_runways[rwy.sibling] = true
            
            local sibling_rwy = apt.rwys[rwy.sibling]
            draw_oans_rwy(data, rwy, sibling_rwy, functions)
        end            
    end
end

local function draw_oans_taxiways(data, functions, apt)
    for i,line in ipairs(apt.taxys) do
    
        local points = {}
        for j,segment in ipairs(line.points) do
            if #segment == 2 then
                local x,y = functions.get_x_y(data, segment[1], segment[2])
                table.insert(points, {x,y})
            end
        end

        triangles = polygon_triangulation(points)
        
        if #triangles > 0 then
            for j,v in ipairs(triangles) do
                if #v == 3 then
                    local color = {0.5,0.5,0.5}
                    if data.config.range == ND_RANGE_ZOOM_2 then
                        color = {0.2,0.2,0.2}
                    end
                    sasl.gl.drawConvexPolygon ({ v[1][1], v[1][2], v[2][1], v[2][2], v[3][1], v[3][2] }, true, 0, color) 
                end
            end
        end

    end
end

local function draw_oans_airport_bounds(data, functions, apt)
    for i,line in ipairs(apt.bounds) do
    
        local points = {}
        for j,segment in ipairs(line.points) do
            if #segment == 2 then
                local x,y = functions.get_x_y(data, segment[1], segment[2])
                table.insert(points, {x,y})
            end
        end

        triangles = polygon_triangulation(points)
        
        if #triangles > 0 then
            for j,v in ipairs(triangles) do
                if #v == 3 then
                    sasl.gl.drawConvexPolygon ({ v[1][1], v[1][2], v[2][1], v[2][2], v[3][1], v[3][2] }, true, 0, {0.1,0.1,0.1})
                end
            end
        end

    end
end

local function draw_oans_mark_lines(data, functions, apt)

    local len = #apt.mark_lines  -- They must be drawn in the opposite order

    for i=len, 1, -1 do
        local line = apt.mark_lines[i] 
        
        if    line.color == 1 or line.color == 51   -- Taxiway centerlines 
           or line.color == 4 or line.color == 54   -- Runways hold positions
           or line.color == 5 or line.color == 55   -- Non-runway hold positions
           or line.color == 8 or line.color == 58   -- Lanes queue
           or line.color == 9 or line.color == 59   -- Lanes queue
           or line.color == 22                      -- Roadway centerline
        then

            local color = COLOR_YELLOW
            if line.color == 4 or line.color == 54 then
                color = ECAM_RED
            elseif line.color == 5 or line.color == 55 then
                color = ECAM_WHITE
            elseif line.color == 8 or line.color == 58 or line.color == 9 or line.color == 59 then
                color = ECAM_WHITE
            elseif line.color == 22 then
                color = {0.6, 0.6, 0}    
            end

            local last_prev_x = nil 
            local last_prev_y = nil 

            for j,segment in ipairs(line.points) do
                local x,y = functions.get_x_y(data, segment[1], segment[2])
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

local function draw_oans_tower(data, functions, apt)
    if apt.tower.lat ~= nil then
        local x,y = functions.get_x_y(data, apt.tower.lat, apt.tower.lon)
        
        local width  = 40
        local height =  36
        local y_shift = (height-3)/2

        sasl.gl.drawRectangle (x-width/2, y-y_shift-3+data.config.range, width, height-4,  {0,0,0})
        sasl.gl.drawText(Font_AirbusDUL,x,y-y_shift, "TWR", height-4, false, false, TEXT_ALIGN_CENTER, {0., 0.6, 0.})
        k_v = height - 5
        sasl.gl.drawTriangle ( x-15, y+k_v, x+15, y+k_v , x, y+k_v+15, {0., 0.6, 0.})
    
    end
end

local function draw_oans_mark_taxi(data, functions, apt)
    for i,line in ipairs(apt.taxi_routes) do
    
        if line.name ~= nil then
            local point_1 = apt.routes[line.point_1]
            local point_2 = apt.routes[line.point_2]
        
            local x1,y1 = functions.get_x_y(data, point_1.lat, point_1.lon)
            local x2,y2 = functions.get_x_y(data, point_2.lat, point_2.lon)

            local x = (x1+x2)/2
            local y = (y1+y2)/2

            local width  = 20 * #line.name
            local height = 36
            local y_shift = (height-3)/2

            sasl.gl.drawRectangle (x-width/2, y-y_shift-3+data.config.range, width, height-4,  {0,0,0})

            sasl.gl.drawText(Font_AirbusDUL,x,y-y_shift, line.name, height-4, false, false, TEXT_ALIGN_CENTER, COLOR_YELLOW)
        end    
    end
end

local function draw_oans_mark_gate(data, functions, apt)
    for i,line in ipairs(apt.gates) do
    
        if line.name ~= nil then
            local x,y = functions.get_x_y(data, line.lat, line.lon)

            local width  = 20 * #line.name
            local height = 36
            local y_shift = (height-3)/2

            sasl.gl.drawRectangle (x-width/2, y-y_shift-3+data.config.range, width, height-4,  {0,0,0})

            sasl.gl.drawText(Font_AirbusDUL,x,y-y_shift, line.name, height-4, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        end    
    end
end

local function draw_oans_flags_and_crosses(data,functions)
    for i,flag in ipairs(data.poi.flag) do
        if flag.x ~= nil then
            flag.lat, flag.lon = functions.get_lat_lon(data,flag.x,flag.y)
            flag.x = nil
            flag.y = nil
        end
        local x,y = functions.get_x_y(data, flag.lat, flag.lon)            
        sasl.gl.drawTexture(image_icon_flag, x-25, y-35, 50, 70, {1,1,1})
    end
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

function draw_oans(data, functions)
    if data.config.range > ND_RANGE_ZOOM_2 then
        return  -- No OANS over zoom
    end

    local nearest_airport = Data_manager.nearest_airport
    if nearest_airport ~= nil then
        local apt = Data_manager.get_arpt_by_name(nearest_airport.id)
        
        if data.plan_ctr_lat == 0 and data.plan_ctr_lon == 0 then
            data.plan_ctr_lat = apt.lat
            data.plan_ctr_lon = apt.lon
        end
        
        draw_oans_airport_bounds(data, functions, apt)
        draw_oans_taxiways(data, functions, apt)
        if data.config.range <= ND_RANGE_ZOOM_1 then
            draw_oans_mark_lines(data, functions, apt)
        end
        draw_oans_rwys(data, functions, apt)
        
        if data.config.range <= ND_RANGE_ZOOM_05 then
            draw_oans_tower(data, functions, apt)
            draw_oans_mark_taxi(data, functions, apt)
        end        
        if data.config.range <= ND_RANGE_ZOOM_02 then
            draw_oans_mark_gate(data, functions, apt)
        end
        
        if data.config.range <= ND_RANGE_ZOOM_1 then
            draw_oans_flags_and_crosses(data,functions)
        end
    end
end


