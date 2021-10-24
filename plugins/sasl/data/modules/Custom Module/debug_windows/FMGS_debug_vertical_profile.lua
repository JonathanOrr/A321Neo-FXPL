include('libs/geo-helpers.lua')

local trip_dist = 500
local accel_alt = 2000
local climb_trans_alt = 10000
local crz_alt = 33000
local dep_alt = 0
local arr_alt = 0
local transition_distance = 10
local acceleration_distance = 6
local decelleration_distance = 10

local climb_gradient = {
    ["empty"] = {
            {0, 13},
            {1000,13},
            {2000,12},
            {5000,11},
            {8000,10},
            {10000,9},
            {14000,8},
            {17000,7},
            {21000,5},
            {25000,4},
            {30000,3},
            {40000,2},
        },
    ["full"] = {
        {0, 13-2},
        {1000,13-2},
        {2000,12-2},
        {5000,11-2},
        {8000,10-2},
        {10000,9-2},
        {14000,8-2},
        {17000,7-1},
        {21000,5-1},
        {25000,4-1},
        {30000,3-1},
        {40000,2-1},
    }
}

local legs_list = table.load(moduleDirectory .. "/Custom Module/debug_windows/FMGS Example Data/final_list.lua")
local climb_profile = {}

local function dist_to_px(dist)
    local point_relative_ratio = Math_rescale_no_lim(0,0,trip_dist,1,dist)
    local ratio = Math_rescale_no_lim(vprof_view_start,0,vprof_view_end,1,point_relative_ratio)
    local px = Math_rescale_no_lim(0,50,1,900,ratio)
    return px
end

local function alt_to_px(alt)
    return Math_rescale_no_lim(0, 60, 40000, 380, alt)
end

local function draw_wpt(dist, alt, name)
    sasl.gl.drawCircle (  dist_to_px(dist) ,  alt_to_px(alt) ,  3 ,  true , UI_GREEN )
    sasl.gl.drawText(Font_B612MONO_regular, dist_to_px(dist),alt_to_px(alt) + 5, name == nil and "INVLD" or name, 16, false, false, TEXT_ALIGN_CENTER,name == nil and UI_LIGHT_RED or UI_GREEN)
end

local function draw_constrain(dist, alt, type, missed) -- 1 = abv, 2 = blw, 3 = at
    local x = dist_to_px(dist)
    local y = alt_to_px(alt)
    if type == 1 then
        sasl.gl.drawTriangle (x , y,  x-6 ,  y-10 ,  x+6 , y-10 ,  missed and UI_YELLOW or UI_WHITE )
    elseif type == 2 then
        sasl.gl.drawTriangle (x , y,  x-6 ,  y+10 ,  x+6 , y+10 ,  missed and UI_YELLOW or UI_WHITE  )
    elseif type == 3 then
        sasl.gl.drawTriangle (x , y,  x-6 ,  y-10 ,  x+6 , y-10 ,  missed and UI_YELLOW or UI_WHITE  )
        sasl.gl.drawTriangle (x , y,  x-6 ,  y+10 ,  x+6 , y+10 ,  missed and UI_YELLOW or UI_WHITE  )
    end
end

local function request_climb_gradient(aircraft_mass, altitude)
    local empty_gradient = Table_extrapolate(climb_gradient["empty"], altitude)
    local full_gradient = Table_extrapolate(climb_gradient["full"], altitude)
    local predicted_gradient = Math_rescale_no_lim(50000, empty_gradient, 100000, full_gradient, aircraft_mass)
    return predicted_gradient
end

local function request_climb_distance(aircraft_mass, start_alt, end_alt)
    distance = (end_alt - start_alt) / math.tan(math.rad(request_climb_gradient(aircraft_mass, start_alt))) -- computing required climb distance from start_alt directly to end_alt
    distance = distance* 0.00016457883 -- back into nautical miles
    return distance
end

    -------------------------------------------- Actual Profile Computing

local function compute_ideal_profile()
    trip_dist = 0
    for i=1, #legs_list do
        trip_dist = trip_dist + get_distance_nm(legs_list[i]["start_lat"],legs_list[i]["start_lon"],legs_list[i]["end_lat"],legs_list[i]["end_lon"])
    end

    climb_profile = {}
    local cumulative_dist = 0
    -- departure phase
    for i = math.floor(dep_alt/1000), crz_alt/1000 do --so every 1000ft we recompute the gradient,
        cumulative_dist = cumulative_dist + request_climb_distance(88000, i*1000, (i+1)*1000)

        if (i-1)*1000 > accel_alt - 1000 and (i-1)*1000 <= accel_alt then -- the transition height is less than 1000 ft apart
            print(i)
            cumulative_dist = cumulative_dist + acceleration_distance -- the altitude rised is still 1000ft, assuming it uses 1000ft to accelerate (it doesn;t level off). However, the distance travelled is increased.
        end

        if (i-1)*1000 > climb_trans_alt - 1000 and (i-1)*1000 <= climb_trans_alt then -- the transition height is less than 1000 ft apart
            print(i)
            cumulative_dist = cumulative_dist + transition_distance -- the altitude rised is still 1000ft, assuming it uses 1000ft to accelerate (it doesn;t level off). However, the distance travelled is increased.
        end
        table.insert(climb_profile, {cumulative_dist, i*1000})
    end

end

local function draw_ideal_profile()
    local cumulative_dist = 0
    for i=1, #legs_list do
        -- draw the waypoint
        cumulative_dist = cumulative_dist + get_distance_nm(legs_list[i]["start_lat"],legs_list[i]["start_lon"],legs_list[i]["end_lat"],legs_list[i]["end_lon"])
        draw_wpt(cumulative_dist, Table_extrapolate(climb_profile, cumulative_dist), legs_list[i]["leg_name"])

                -- draw the constrains
        local cstr = legs_list[i]["orig_ref"]["cstr_altitude1"]
        local cstr_in_fl = legs_list[i]["orig_ref"]["cstr_altitude1_fl"]
        local cstr_type = legs_list[i]["orig_ref"]["cstr_alt_type"]
        local expected_alt = Table_extrapolate(climb_profile, cumulative_dist)
        if cstr and cstr_type ~= 0 then
            local missed = false
            if cstr_type == CIFP_CSTR_ALT_ABOVE and expected_alt < cstr - 100 then
                missed = true
            elseif cstr_type == CIFP_CSTR_ALT_BELOW and expected_alt > cstr + 100 then
                missed = true
            elseif cstr_type == CIFP_CSTR_ALT_AT and math.abs(expected_alt - cstr) >100 then
                missed = true
            end

            if cstr_in_fl then
                draw_constrain(cumulative_dist, cstr*1000, cstr_type, missed)
            else
                draw_constrain(cumulative_dist, cstr, cstr_type, missed)
            end
        end
    end

    for i=1, #climb_profile -1 do
        sasl.gl.drawLine(dist_to_px(climb_profile[i][1]), alt_to_px(climb_profile[i][2]), dist_to_px(climb_profile[i+1][1]), alt_to_px(climb_profile[i+1][2]), UI_LIGHT_RED)
    end
end

    -------------------------------------------- Loops
    
function update_vprof_actual()
    compute_ideal_profile()
end

function draw_vprof_actual()
    draw_ideal_profile()
end
