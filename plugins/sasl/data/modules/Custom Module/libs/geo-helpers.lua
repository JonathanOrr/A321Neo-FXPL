local mrad = math.rad
local mdeg = math.deg
local mcos = math.cos
local msin = math.sin
local masin = math.asin
local macos = math.acos
local matan2= math.atan2

function Move_along_distance(origin_lat, origin_lon, distance, angle)   -- Distance in M
    -- WARNING
    -- WARNING: Probably incorrect, consider to use Move_along_distance_v2
    -- WARNING
    local a = mrad(90-angle)

    local lat0 = mcos(math.pi / 180.0 * origin_lat)

    local lat = origin_lat  + (180/math.pi) * (distance / 6378137) * msin(a)
    local lon = origin_lon + (180/math.pi) * (distance / 6378137) / mcos(lat0) * mcos(a)
    return lat,lon
end

function Move_along_distance_v2(origin_lat, origin_lon, distance, angle) -- Distance in M
    local theta = mrad(angle)
    local EARTH_RADIUS = 6378136.6
    local angular_dist = distance / EARTH_RADIUS

    local s_lat1 = msin(mrad(origin_lat))
    local c_lat1 = mcos(mrad(origin_lat))
    local c_ang  = mcos(angular_dist)
    local s_ang  = msin(angular_dist)
    local c_theta= mcos(theta)
    local s_theta= msin(theta)

    local lat2 = masin(s_lat1 * c_ang + c_lat1 * s_ang * c_theta)
    local s_lat2 = msin(lat2)

    local lon2 = mrad(origin_lon) + matan2(s_theta * s_ang * c_lat1, c_ang - s_lat1 * s_lat2)
    
    return mdeg(lat2), mdeg(lon2)
end

function Move_along_distance_NM(origin_lat, origin_lon, distance, angle) -- Distance in NM
    local theta = mrad(angle)
    local EARTH_RADIUS = 6378136.6
    local angular_dist = distance * 1852 / EARTH_RADIUS

    local s_lat1 = msin(mrad(origin_lat))
    local c_lat1 = mcos(mrad(origin_lat))
    local c_ang  = mcos(angular_dist)
    local s_ang  = msin(angular_dist)
    local c_theta= mcos(theta)
    local s_theta= msin(theta)

    local lat2 = masin(s_lat1 * c_ang + c_lat1 * s_ang * c_theta)
    local s_lat2 = msin(lat2)

    local lon2 = mrad(origin_lon) + matan2(s_theta * s_ang * c_lat1, c_ang - s_lat1 * s_lat2)
    
    return mdeg(lat2), mdeg(lon2)
end



function GC_distance_kt(lat1, lon1, lat2, lon2)

    --This function returns great circle distance between 2 points.
    --Found here: http://bluemm.blogspot.gr/2007/01/excel-formula-to-calculate-distance.html
    --lat1, lon1 = the coords from start position (or aircraft's) / lat2, lon2 coords of the target waypoint.
    --6371km is the mean radius of earth in meters. Since X-Plane uses 6378 km as radius, which does not makes a big difference,
    --(about 5 NM at 6000 NM), we are going to use the same.
    --Other formulas I've tested, seem to break when latitudes are in different hemisphere (west-east).

    if lat1 == lat2 and lon1 == lon2 then
        return 0
    end

    local distance = macos(mcos(mrad(90-lat1))*mcos(mrad(90-lat2))+ msin(mrad(90-lat1))*msin(mrad(90-lat2))*mcos(mrad(lon1-lon2))) * (6378000/1852)

    return distance

end

function GC_distance_km(lat1, lon1, lat2, lon2)
    return GC_distance_kt(lat1, lon1, lat2, lon2) * 1.852
end


function get_distance_nm(lat1,lon1,lat2,lon2)
    return GC_distance_kt(lat1, lon1, lat2, lon2)
end

function get_bearing(lat1,lon1,lat2,lon2)
    local lat1_rad = mrad(lat1)
    local lat2_rad = mrad(lat2)
    local lon1_rad = mrad(lon1)
    local lon2_rad = mrad(lon2)

    local x = msin(lon2_rad - lon1_rad) * mcos(lat2_rad)
    local y = mcos(lat1_rad) * msin(lat2_rad) - msin(lat1_rad)*mcos(lat2_rad)*mcos(lon2_rad - lon1_rad)
    local theta = matan2(y, x)
    local brng = (theta * 180 / math.pi + 360) % 360

    return brng
end

function get_earth_bearing(lat1,lon1,lat2,lon2)
    return (90 - get_bearing(lat1,lon1,lat2,lon2)) % 360
end

function geo_get_mora(lat, lon)
    if not (AvionicsBay.is_initialized() and AvionicsBay.is_ready()) then
        return 0
    end

    local mora_curr = AvionicsBay.c.get_mora(lat, lon)

    local directions = {0, 45, 90, 135, 180, 235, 270, 315}
    for k,x in ipairs(directions) do
        local n_lat, n_lon = Move_along_distance_v2(lat, lon, 74080, x)   -- 40nm
        if (math.floor(n_lat) ~= math.floor(lat)) or (math.floor(n_lon) ~= math.floor(lon)) then
            mora_curr = math.max(mora_curr, AvionicsBay.c.get_mora(n_lat, n_lon))
        end
    end
    
    return mora_curr
end


function point_from_a_segment(x1, y1, x2, y2, distance)
    local den = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    local t = distance / den
    local x3 = (1-t) * x1 + t * x2
    local y3 = (1-t) * y1 + t * y2

    return x3,y3
end

function point_from_a_segment_lat_lon(lat1, lon1, lat2, lon2, distance_nm)  -- APPROXIMATED! Only for short distances
    local den = get_distance_nm(lat1,lon1,lat2,lon2)
    local t = distance_nm / den
    local lat3 = (1-t) * lat1 + t * lat2
    local lon3 = (1-t) * lon1 + t * lon2

    return lat3, lon3
end

function point_from_a_segment_lat_lon_limited(lat1, lon1, lat2, lon2, distance_nm, limit)  -- APPROXIMATED! Only for short distances
    local den = get_distance_nm(lat1,lon1,lat2,lon2)
    local t = distance_nm / den
    t = math.min(limit, t)
    local lat3 = (1-t) * lat1 + t * lat2
    local lon3 = (1-t) * lon1 + t * lon2

    return lat3, lon3
end

function heading_difference(hdg1,hdg2) -- range -180 to 180, difference between 2 bearings, +ve is right turn, -ve is left.
    local turn = 0
    turn =  (hdg1-hdg2)%360
    turn = turn > 180 and (360-turn) or -turn
    return turn
end

function mid_point(lat1, lon1, lat2, lon2)
    return (lat1+lat2)/2,(lon1+lon2)/2
end


function intersecting_radials(lat1, lon1, lat2, lon2, crs13, crs23)
    assert(lat1 and lat2 and lon1 and lon2 and crs13 and crs23)
    lat1  = math.rad(lat1)
    lat2  = math.rad(lat2)
    lon1  = -math.rad(lon1)
    lon2  = -math.rad(lon2)
 
    crs13 = math.rad(crs13)
    crs23 = math.rad(crs23)
 
    local dphi   = lat1 - lat2
    local ddelta = lon1 - lon2
 
    local square1 = (math.sin(dphi/2))^2
    local square2 = (math.sin(ddelta/2))^2
    local dst12=2*math.asin(math.sqrt(square1+ math.cos(lat1)*math.cos(lat2)*square2))
 
    if(math.abs(dst12) < 1e-6) then
       return math.deg(lat1), -math.deg(lon1) -- Coincidental points
    end
 
    local cos_t_a = (math.sin(lat2) - math.sin(lat1)*math.cos(dst12)) / (math.sin(dst12)*math.cos(lat1))
    local cos_t_b = (math.sin(lat1) - math.sin(lat2)*math.cos(dst12)) / (math.sin(dst12)*math.cos(lat2))
    local t_a = math.acos(math.min(math.max(cos_t_a, -1), 1))
    local t_b = math.acos(math.min(math.max(cos_t_b, -1), 1))
 
    local crs12 = math.sin(lon2-lon1)<0 and t_a or (2*math.pi-t_a)
    local crs21 = math.sin(lon2-lon1)<0 and (2*math.pi-t_b) or t_b
 
 
    local ang1=((crs13-crs12+math.pi) % (2.*math.pi)) - math.pi
    local ang2=((crs21-crs23+math.pi) % (2.*math.pi)) - math.pi
 
 
    local lat3, lon3
 
    if math.sin(ang1) == 0 and math.sin(ang2) == 0 then
       return nil, nil  -- Infinite intersections
    elseif math.sin(ang1) * math.sin(ang2) < 0 then 
       return nil, nil  -- Ambiguous intersection
    else
       ang1=math.abs(ang1)
       ang2=math.abs(ang2)
       local ang3=math.acos(-math.cos(ang1)*math.cos(ang2)+math.sin(ang1)*math.sin(ang2)*math.cos(dst12)) 
       local dst13=math.atan2(math.sin(dst12)*math.sin(ang1)*math.sin(ang2),math.cos(ang2)+math.cos(ang1)*math.cos(ang3))
       lat3=math.asin(math.sin(lat1)*math.cos(dst13)+math.cos(lat1)*math.sin(dst13)*math.cos(crs13))
       local dlon=math.atan2(math.sin(crs13)*math.sin(dst13)*math.cos(lat1),math.cos(dst13)-math.sin(lat1)*math.sin(lat3))
       lon3=((lon1-dlon+math.pi) % (2*math.pi)) - math.pi
    end
 
    return math.deg(lat3), -math.deg(lon3)
 end
 