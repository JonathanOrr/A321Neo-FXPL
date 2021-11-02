local function cos(x)
    return math.cos(x)
end

local function sin(x)
    return math.sin(x)
end

local function tan(x)
    return math.tan(x)
end

local function deg(x)
    return math.deg(x)
end

local function rad(x)
    return math.rad(x)
end

local CIFP = {
    {"WPT1",22,113,"TF"},
    {"WPT2",23,114,"TF"},
    {"WPT3",21,115,"TF"},
    {"WPT4",23,117,"TF"},
    {"WPT5",24,114,"CF",180,20}, -- CF, Inbound Heading, Radius
}

local function AIRNC_LEGS_curve_three_points(lat1,lon1,lat2,lon2,lat3,lon3,turn_radius) -- TESTING PURPOSES

    local start_heading = get_earth_bearing(lat1,lon1,lat2,lon2)
    local end_heading = get_earth_bearing(lat2,lon2,lat3,lon3)
    local turn = heading_difference(start_heading,end_heading)

    local points = {{lat1,lon1},{lat2,lon2},{lat3,lon3}}

    local tip_angle = (180-turn)/2
    local turn_starting_point = turn_radius / tan(rad(tip_angle))
    print(turn_starting_point)

    --turn starting coordinates
    local a,b = Move_along_distance_NM(points[2][1], points[2][2], math.max(turn_radius,turn_starting_point), (start_heading + 180)%360)
    --turn ending coordinates
    local c,d = Move_along_distance_NM(points[2][1], points[2][2], math.max(turn_radius,turn_starting_point), end_heading)

    ND_FLIGHTPATH_drawbezier(a,b,points[2][1], points[2][2],c,d,50,ECAM_GREEN)

    ND_FLIGHTPATH_drawline(points[1][1], points[1][2],a,b,false)
    ND_FLIGHTPATH_drawline(c,d,points[3][1], points[3][2],false)
end

local function ARINC_LEGS_BEAM(lat,lon,bearing)
    local a,b = Move_along_distance_NM(lat, lon, 999 , bearing)
    ND_FLIGHTPATH_drawline_special(lat,lon,a,b,{0.8,0.8,0.8})
end

local function ARINC_LEGS_IF(lat,lon,name)
    ND_FLIGHTPATH_drawfix(lat,lon,name)
end

local function ARINC_LEGS_TF(lat1,lon1,lat2,lon2,dash_or_not)
    ND_FLIGHTPATH_drawline(lat1,lon1,lat2,lon2,dash_or_not)
end

local function ARINC_LEGS_CF(lat1,lon1,lat2,lon2,radius,intercept_hdg,current_hdg)
    local theta = heading_difference(current_hdg,intercept_hdg)
    --if theta < 0 then theta = theta + 180 end
    --print(theta)
    --local a,b = Move_along_distance_NM(lat2, lon2, xtk , intercept_hdg - 90) --coordinates of fix 1
    --ARINC_LEGS_IF(a,b,"FIX 1")

    local track_bearing_to_wpt = get_earth_bearing(lat1,lon1,lat2,lon2)

    ARINC_LEGS_BEAM(lat1,lon1,track_bearing_to_wpt)
    ARINC_LEGS_BEAM(lat1,lon1,current_hdg)
    ARINC_LEGS_BEAM(lat2,lon2,intercept_hdg)
end

function draw_flightpaths()
    for i=1, #CIFP do
        leg_type = CIFP[i][4]
        if leg_type == "TF" and i ~= 1 then
            ARINC_LEGS_TF(CIFP[i-1][2],CIFP[i-1][3],CIFP[i][2],CIFP[i][3],false)
        elseif leg_type == "CF" then
            ARINC_LEGS_CF(CIFP[i-1][2],CIFP[i-1][3],CIFP[i][2],CIFP[i][3], CIFP[i][6],CIFP[i][5],340)
        end

        -- DRAW THE WAYPOINTS
        ARINC_LEGS_IF(CIFP[i][2],CIFP[i][3],CIFP[i][1]) 
    end
end