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
-- File: helpers.lua
-- Short description: Misc functions related to graphics
-------------------------------------------------------------------------------

local msin = math.sin
local mcos = math.cos
local mrad = math.rad
local matan2 = math.atan2

function get_range_in_nm(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        local zoom = math.floor(2^(data.config.range-1) * 10)
        if data.config.mode ~= ND_MODE_ARC then
            zoom = zoom / 2
        end
        return zoom
    elseif data.config.range == ND_RANGE_ZOOM_2 then
        return 2
    elseif data.config.range == ND_RANGE_ZOOM_1 then
        return 1
    elseif data.config.range == ND_RANGE_ZOOM_05 then
        return 0.5
    elseif data.config.range == ND_RANGE_ZOOM_02 then
        return 0.2
    end
    assert(false) -- Should never happen
end

function compute_angle(x1, y1, x2, y2)
    return matan2(y1-y2, x1-x2)
end 

function rotate_xy_point(x, y, cx, cy, angle)

    if angle == 0 then
        return x,y
    end

    local s = msin(mrad(angle))
    local c = mcos(mrad(angle))

    x = x - cx
    y = y - cy

    local xnew = x * c - y * s
    local ynew = x * s + y * c
    
    xnew = xnew + cx
    ynew = ynew + cy

    return xnew, ynew
end

local function do_segments_intersect(x1, y1, x2, y2, x3, y3, x4, y4)

    local s1_x = x2 - x1
    local s2_x = x4 - x3
    local s1_y = y2 - y1
    local s2_y = y4 - y3
    
    local s = (-s1_y * (x1 - x3) + s1_x * (y1 - y3)) / (-s2_x * s1_y + s1_x * s2_y)
    local t = ( s2_x * (y1 - y3) - s2_y * (x1 - x3)) / (-s2_x * s1_y + s1_x * s2_y)

    return (s >= 0 and s <= 1 and t >= 0 and t <= 1)
end

function is_polygon_visible(polygon, size, diff_x, diff_y) -- It works only for convex polygon

    local polygon_nr = #polygon/2
    
    local at_least_q1 = false
    local at_least_q2 = false
    local at_least_q3 = false
    local at_least_q4 = false

    for i=1,polygon_nr do
        local x = polygon[2*i-1] - diff_x
        local y = polygon[2*i] - diff_y
        
        if x < 0 then
            at_least_q4 = true
        end
        if x > size[1] then
            at_least_q2 = true
        end
        if y < 0 then
            at_least_q3 = true
        end
        if y > size[1] then
            at_least_q1 = true
        end
        
        -- Case 1: the point is inside the polygon
        if x >= 0 and x <= size[1] and y >= 0 and y <= size[2] then
            return true
        end
        
        if i > 1 then
        -- Case 2: the edge intersect the polygon
            local prev_x = polygon[2*(i-1)-1] - diff_x
            local prev_y = polygon[2*(i-1)] - diff_y

            if do_segments_intersect(x, y, prev_x, prev_y, 0, size[2], 0, 0) then
                return true
            end
            if do_segments_intersect(x, y, prev_x, prev_y, size[1], 0, 0, 0) then
                return true
            end
            if do_segments_intersect(x, y, prev_x, prev_y, 0, 0, 0, size[2]) then
                return true
            end
            if do_segments_intersect(x, y, prev_x, prev_y, 0, 0, size[1], 0) then
                return true
            end

        end
    end

    return at_least_q1 and at_least_q2 and at_least_q3 and at_least_q4
end

