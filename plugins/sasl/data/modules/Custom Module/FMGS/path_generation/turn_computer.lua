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
-- File: turn_computer.lua 
-- Short description: Generates turn for a given segmented FPLN
-------------------------------------------------------------------------------


local function get_turn_radius(spd)
    return spd * spd / (8.84*3600)
end

function convert_holds(old_FPLN)

    local new_FPLN = {}

    for i,x in ipairs(old_FPLN) do
        if x.segment_type == FMGS_COMP_SEGMENT_HOLD then
            local hold_diameter = 4
            if x.spd_cstr then
                local radius = get_turn_radius(x.spd_cstr)
                hold_diameter = 2 * radius
            end

            local single_line_length = x.dist

            
            local per_angle = x.turn == "R" and (x.start_crs + 90) or (x.start_crs - 90)  -- perpendicular angle
            per_angle = per_angle % 360

            local ib_end_lat, ib_end_lon = Move_along_distance_NM(x.start_lat, x.start_lon, single_line_length, (x.start_crs+180) % 360)
            local ob_start_lat, ob_start_lon = Move_along_distance_NM(x.start_lat, x.start_lon, hold_diameter, per_angle)
            local ob_end_lat, ob_end_lon = Move_along_distance_NM(ob_start_lat, ob_start_lon, single_line_length, (x.start_crs+180) % 360)


            local ctr_1_lat, ctr_1_lon = Move_along_distance_NM(x.start_lat, x.start_lon, hold_diameter/2, per_angle)
            local ctr_2_lat, ctr_2_lon = Move_along_distance_NM(ib_end_lat, ib_end_lon, hold_diameter/2, per_angle)

            local leg_line = { segment_type=FMGS_COMP_SEGMENT_LINE, in_hold=true, start_lat=x.start_lat, start_lon=x.start_lon, end_lat=ib_end_lat, end_lon=ib_end_lon, leg_name = "", orig_ref=x.orig_ref }
            table.insert(new_FPLN, leg_line)

            local leg_line = { segment_type=FMGS_COMP_SEGMENT_LINE, in_hold=true,  start_lat=ob_start_lat, start_lon=ob_start_lon, end_lat=ob_end_lat, end_lon=ob_end_lon, leg_name = "", orig_ref=x.orig_ref }
            table.insert(new_FPLN, leg_line)

            local arc1 = { segment_type=FMGS_COMP_SEGMENT_ARC, in_hold=true,  start_lat=x.start_lat, start_lon=x.start_lon, end_lat=ob_start_lat, end_lon=ob_start_lon, ctr_lat=ctr_1_lat, ctr_lon=ctr_1_lon, radius=hold_diameter/2, start_angle=-x.start_crs+180, arc_length_deg=-180, leg_name = "", orig_ref=x.orig_ref}
            table.insert(new_FPLN, arc1)

            local arc2 = { segment_type=FMGS_COMP_SEGMENT_ARC, in_hold=true,  end_lat=ib_end_lat, end_lon=ib_end_lon, end_lat=ob_end_lat, end_lon=ob_end_lon, ctr_lat=ctr_2_lat, ctr_lon=ctr_2_lon, radius=hold_diameter/2, start_angle=-x.start_crs, arc_length_deg=-180, leg_name = "", orig_ref=x.orig_ref}
            table.insert(new_FPLN, arc2)


        else
            table.insert(new_FPLN, x)
        end
    end

    return new_FPLN

end


local function create_turn_less_180(curr, next, curr_bear, next_bear, speed)

    local turn_radius = get_turn_radius(speed)

    local sign_diff = heading_difference(curr_bear, next_bear)
    local diff = math.abs(sign_diff) 
    local internal_angle = 180 - diff   -- (0 to 90]

    local back_space = turn_radius * math.tan(math.rad(internal_angle/2))   -- Amount of space that we need to remove from
                                                                            -- the segment in order to make space for the arc
    
    -- Compute the length of the legs (original, previous of the arc creation)
    curr.orig_length = get_distance_nm(curr.start_lat, curr.start_lon, curr.end_lat, curr.end_lon)
    next.orig_length = get_distance_nm(next.start_lat, next.start_lon, next.end_lat, next.end_lon)

    -- Try to move the final position of the current segment and the start position of the next segment
    curr.end_lat, curr.end_lon     = Move_along_distance_NM(curr.end_lat, curr.end_lon, back_space, curr_bear)
    next.start_lat, next.start_lon = Move_along_distance_NM(next.start_lat, next.start_lon, back_space, next_bear)

    if curr.orig_length < back_space then
        -- In this case the original segment is not sufficiently long to have space for the arc
        -- so let's hide it and starts the arc from the previous end point
        curr.segment_type = FMGS_COMP_SEGMENT_DELETED
        curr.end_lat, curr.end_lon = Move_along_distance_NM(curr.end_lat, curr.end_lon, -(back_space-curr.orig_length), curr_bear)
        next.start_lat, next.start_lon = Move_along_distance_NM(next.start_lat, next.start_lon, -(back_space-curr.orig_length), curr_bear)
    end

    if next.orig_length < back_space then
        next.segment_type = FMGS_COMP_SEGMENT_DELETED
        next.end_lat, next.end_lon = next.start_lat, next.start_lon
    end
    local perp_angle = sign_diff > 0 and (curr_bear+90)%360 or (curr_bear-90)%360

    local ctr_lat, ctr_lon = Move_along_distance_NM(curr.end_lat, curr.end_lon, turn_radius, perp_angle)

    if sign_diff > 0 then
        internal_angle = - internal_angle
    end
    return { segment_type=FMGS_COMP_SEGMENT_ARC, end_lat=curr.end_lat, end_lon=curr.end_lon, end_lat=next.start_lat, end_lon=next.start_lon, ctr_lat=ctr_lat, ctr_lon=ctr_lon, radius=turn_radius, start_angle=-perp_angle-90, arc_length_deg=-internal_angle, leg_name = ""}

end

local function create_turn_less_90(curr, next, curr_bear, next_bear, speed)
    return create_turn_less_180(curr, next, curr_bear, next_bear, speed) -- It seems workign for now
end

local function create_turn(curr, next, speed)
    local curr_bear = get_earth_bearing(curr.end_lat,curr.end_lon,curr.start_lat,curr.start_lon)
    local next_bear = get_earth_bearing(next.start_lat,next.start_lon,next.end_lat,next.end_lon)

    local diff = math.abs(heading_difference(curr_bear, next_bear)) 
    if diff > 0 and diff <= 90 then
        return create_turn_less_90(curr, next, curr_bear, next_bear, speed)
    elseif diff > 0 and diff < 180 then
        return create_turn_less_180(curr, next, curr_bear, next_bear, speed)
    else
        return nil  -- No need a turn
    end

end

local function create_turn_fly_over(curr, next, speed)

    local curr_bear = get_earth_bearing(curr.start_lat, curr.start_lon, curr.end_lat, curr.end_lon)
    local next_bear = get_earth_bearing(next.start_lat,next.start_lon, next.end_lat, next.end_lon)
    next.orig_length = get_distance_nm(next.start_lat, next.start_lon, next.end_lat, next.end_lon)
    local sign_diff = heading_difference(curr_bear, next_bear)

    local turn_radius = get_turn_radius(speed)

    local is_left_turn = sign_diff < 0

    -- See Discord diagram
    local alpha  = math.abs(sign_diff)
    local beta   = 90 - alpha

    local a = turn_radius
    local b = turn_radius * math.sin(math.rad(alpha))
    local c = math.sqrt(4*turn_radius*turn_radius - (turn_radius + turn_radius*math.cos(math.rad(alpha)))^2)

    local delta = math.deg(math.asin((1 + math.cos(math.rad(alpha)))/(2)))
    local gamma = 180 - (90 + delta)
    local epsilon = 180 - beta - delta


    local perp_angle_next = (next_bear-90)%360
    if is_left_turn then
        perp_angle_next = (perp_angle_next-180)%360
    end

    local ctr_2_lat, ctr_2_lon = Move_along_distance_NM(curr.end_lat, curr.end_lon, b+c, next_bear)
    next.start_lat, next.start_lon = ctr_2_lat, ctr_2_lon
    ctr_2_lat, ctr_2_lon = Move_along_distance_NM(ctr_2_lat, ctr_2_lon, a, perp_angle_next)

    if next.orig_length < b+c then
        next.segment_type = FMGS_COMP_SEGMENT_DELETED
        next.end_lat, next.end_lon = next.start_lat, next.start_lon
    end

    local perp_angle = (curr_bear+90)%360
    if is_left_turn then
        perp_angle = (perp_angle-180)%360
    end

    local ctr_1_lat, ctr_1_lon = Move_along_distance_NM(curr.end_lat, curr.end_lon, turn_radius, perp_angle)

    local start_first_segment
    local start_second_segment
    if is_left_turn then
        start_first_segment = perp_angle+90
        start_second_segment = perp_angle-90+epsilon
        epsilon = -epsilon
        gamma = - gamma
    else
        start_first_segment  = -perp_angle-90
        start_second_segment = -perp_angle+90-epsilon
    end

    return {
        { segment_type=FMGS_COMP_SEGMENT_ARC, start_lat=curr.end_lat, start_lon=curr.end_lon, end_lat=next.start_lat, end_lon=next.start_lon, ctr_lat=ctr_1_lat, ctr_lon=ctr_1_lon, radius=turn_radius, start_angle=start_first_segment, arc_length_deg=-epsilon, leg_name = "XXXX"},
        { segment_type=FMGS_COMP_SEGMENT_ARC, start_lat=curr.end_lat, start_lon=curr.end_lon, end_lat=next.start_lat, end_lon=next.start_lon, ctr_lat=ctr_2_lat, ctr_lon=ctr_2_lon, radius=turn_radius, start_angle=start_second_segment, arc_length_deg=gamma, leg_name = "XXXX"}
    }
end


function create_turns(old_FPLN)
    local new_FPLN = {}

    local i = 1
    while i <= #old_FPLN-1 do
        local curr = old_FPLN[i]
        local next = old_FPLN[i+1]

        local speed = curr.orig_ref.cstr_speed_type and curr.orig_ref.cstr_speed_type > 0 and curr.orig_ref.cstr_speed or 150    -- TODO Speed profile

        if     (curr.segment_type == FMGS_COMP_SEGMENT_LINE or curr.segment_type == FMGS_COMP_SEGMENT_ENROUTE) 
           and (next.segment_type == FMGS_COMP_SEGMENT_LINE or next.segment_type == FMGS_COMP_SEGMENT_ENROUTE)
           and (not curr.in_hold and not next.in_hold)
        then
            local turn
            if not curr.orig_ref.fly_over_wpt then
                turn = create_turn(curr, next, speed)
            else
                local turns = create_turn_fly_over(curr, next, speed)
                table.insert(old_FPLN, i+1, turns[1])
                i = i + 1
                turn = turns[2]
            end
            if turn then
                table.insert(old_FPLN, i+1, turn)
                i = i + 1
            end
        elseif (curr.segment_type == FMGS_COMP_SEGMENT_DELETED) 
        and (next.segment_type == FMGS_COMP_SEGMENT_LINE or next.segment_type == FMGS_COMP_SEGMENT_ENROUTE) then
            next.start_lat, next.start_lon = curr.end_lat, curr.end_lon
        end
        i = i + 1
    end

end


function convert_pi(old_FPLN)
    local new_FPLN = {}

    for i,x in ipairs(old_FPLN) do
        if x.segment_type == FMGS_COMP_SEGMENT_PI then
--        { segment_type=FMGS_COMP_SEGMENT_PI, start_lat=40.3, start_lon=10.3, end_lat=40.3, end_lon=10.3, start_crs=63, leg_name = "PI", turn="R", dist=2, orig_ref=x }

            local speed = x.orig_ref.cstr_speed_type and x.orig_ref.cstr_speed_type > 0 and x.orig_ref.cstr_speed or 150    -- TODO Speed profile
            local turn_radius = get_turn_radius(speed)

            local arc_length = math.pi * turn_radius

            -- Segments: a, b, c (arc), d, e, f
            local a_len = x.dist
            local e_len = math.sqrt(2 * (2*turn_radius)^2) + a_len
            local d_len = math.pi/4 * turn_radius -- Give some space for the turn
            local b_len = 2 * turn_radius + d_len

            local AB_lat, AB_lon = Move_along_distance_NM(x.start_lat, x.start_lon, a_len, x.start_crs)
            local next_angle = x.start_crs + (x.turn == "L" and -1 or 1) * 45
            local BC_lat, BC_lon = Move_along_distance_NM(AB_lat, AB_lon, b_len, next_angle)
            next_angle = next_angle + (x.turn == "L" and 1 or -1) * 90
            local CC_lat, CC_lon = Move_along_distance_NM(BC_lat, BC_lon, turn_radius, next_angle)
            local CD_lat, CD_lon = Move_along_distance_NM(CC_lat, CC_lon, turn_radius, next_angle)
            next_angle = next_angle + (x.turn == "L" and 1 or -1) * 90
            local DE_lat, DE_lon = Move_along_distance_NM(CD_lat, CD_lon, d_len, next_angle)

            local leg_a_line = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=x.start_lat, start_lon=x.start_lon, end_lat=AB_lat, end_lon=AB_lon, leg_name = "", orig_ref=x.orig_ref }
            table.insert(new_FPLN, leg_a_line)

            local leg_b_line = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=AB_lat, start_lon=AB_lon, end_lat=BC_lat, end_lon=BC_lon, leg_name = "", orig_ref=x.orig_ref }
            table.insert(new_FPLN, leg_b_line)

            local leg_c_line = { segment_type=FMGS_COMP_SEGMENT_ARC, start_lat=BC_lat, start_lon=BC_lon, end_lat=CD_lat, end_lon=CD_lon, ctr_lat=CC_lat, ctr_lon=CC_lon, radius=turn_radius, start_angle=-x.start_crs-((x.turn == "L" and -1 or 1)*45), arc_length_deg=180, leg_name = "", orig_ref=x.orig_ref }
            table.insert(new_FPLN, leg_c_line)

            local leg_d_line = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=CD_lat, start_lon=CD_lon, end_lat=DE_lat, end_lon=DE_lon, leg_name = "", orig_ref=x.orig_ref }
            table.insert(new_FPLN, leg_d_line)

            local leg_e_line = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=DE_lat, start_lon=DE_lon, end_lat=x.start_lat, end_lon=x.start_lon, leg_name = "", orig_ref=x.orig_ref }
            table.insert(new_FPLN, leg_e_line)

        else
            table.insert(new_FPLN, x)
        end
    end

    return new_FPLN
end