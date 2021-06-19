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
-- File: FMGS/geometric_helpers.lua 
-- Short description: Helper geometric functions
-------------------------------------------------------------------------------

local function angle_to_cartesian_deg(crs_angle)
    return (-crs_angle+90)%360
end

GeoPoint = {class="GeoPoint", lat = 0, lon = 0}
function GeoPoint:create (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


GeoLine = {class="GeoLine", a = 0, c = 0}   -- In the form lat = a * lon + c
function GeoLine:create (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function GeoLine:point_at_min_distance(point)  -- Return the point on the line with the minimum distance with respect to the point
                                               -- This works ONLY for small distances!
    assert(point.class == "GeoPoint", "This function works only on one point")

    local a = - self.a
    local b = 1
    local c = - self.c

    -- TODO is division by zero posssible?
    local lat = (a * (-b * point.lon + a * point.lat) - b * c) / (a*a + b*b)
    local lon = (b * (b * point.lon  - a * point.lat) - a * c) / (a*a + b*b)

    return GeoPoint:create ({lat = lat, lon = lon})
end

function GeoLine:point_at_given_distance(orig_point, dist)
    -- This works ONLY for small distances!
    assert(orig_point.class == "GeoPoint", "This function works only on one point")

    local r = math.sqrt(1+self.a*self.a)
    return GeoPoint:create ({lat = orig_point.lat + dist * self.a / r, lon = orig_point.lon + dist / r})
end

function GeoLine:create_from_course(point, crs)  -- Return a line created from a point and a course
    -- lat = a * lon + c
    -- y-y0 = m*(x-x0)
    local angle_deg = angle_to_cartesian_deg(crs)
    local angle = math.rad(angle_deg)
    local a = math.tan(angle)
    local c = point.lat - a*point.lon
    print(point.lat,point.lon,crs,angle_deg,angle,a,c)
    return GeoLine:create ({a=a, c=c})
end
