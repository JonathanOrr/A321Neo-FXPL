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
-- File: cifp_to_segment.lua 
-- Short description: Convert a FPLN to a sequence of segments
-------------------------------------------------------------------------------

local debug_leg_names = {"IF", "TF", "CF", "DF", "FA", "FC", "FD", "FM", "CA", "CD", "CI", "CR", "RF", "AF", "VA", "VD", "VI", "VM", "VR", "PI", "HA", "HF", "HM" }
local last_mag_decl = 0

local function estimate_vertical_performance(start_alt, end_alt)
   return (end_alt - start_alt) * (1/500)
end

local function estimate_distance(minutes, course_reversal)
   if course_reversal then
      return math.min(4.3, 3.5 * minutes) -- 4.3 is the minimum
   else
      return 3.5 * minutes -- 3.5 NM per minute
   end
end


local function point_from_point_course_distance(lat, lon, crs, dist)

   local angle_deg = crs
   local angle = math.rad(angle_deg)


   local R = 6378.1
   local d = 1.852 * dist
      
   lat = math.rad(lat)
   lon = math.rad(lon)
   
   local lat2 = math.asin( math.sin(lat)*math.cos(d/R) + math.cos(lat)*math.sin(d/R)*math.cos(angle))
   
   local lon2 = lon + math.atan2(math.sin(angle)*math.sin(d/R)*math.cos(lat), math.cos(d/R)-math.sin(lat)*math.sin(lat2))
   
   lat2 = math.deg(lat2)
   lon2 = math.deg(lon2)
   
   return lat2, lon2
end

local function head_mag_to_true(deg)
   return deg + last_mag_decl
end

local function convert_generic_RF(x, last_lat, last_lon)
   local radius_in_nm = x.radius / 1000

   assert(last_lat)
   assert(last_lon)
   assert(x.lat)
   assert(x.lon)
   assert(x.ctr_lat)
   assert(x.ctr_lon)

   local bearing_to_start = get_bearing(x.ctr_lat,x.ctr_lon,last_lat,last_lon)
   local bearing_to_end   = get_bearing(x.ctr_lat,x.ctr_lon,x.lat,x.lon)

   local bearing_length = heading_difference(bearing_to_start, bearing_to_end)

   return { segment_type=FMGS_COMP_SEGMENT_ARC, start_lat=last_lon, start_lon=last_lat, end_lat=x.lat, end_lon=x.lon, ctr_lat=x.ctr_lat, ctr_lon=x.ctr_lon, radius=radius_in_nm, start_angle=bearing_to_start, arc_length_deg=bearing_length, leg_name = x.leg_name, orig_ref=x}
end


local function convert_generic_CA(x, last_lat, last_lon, last_alt)
   local altitude_start = last_alt
   local altitude_end   = x.cstr_altitude1_fl and x.cstr_altitude1*100 or x.cstr_altitude1
   local nm_needed = estimate_vertical_performance(altitude_start, altitude_end)

   local outb_mag = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

   local p_lat, p_lon = point_from_point_course_distance(last_lat, last_lon, outb_mag, nm_needed)

   return { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=p_lat, end_lon=p_lon, leg_name = x.leg_name, orig_ref=x }
end

local function convert_generic_FA(x, last_lat, last_lon, last_alt)
   local prev_leg
   if x.lat ~= last_lat and x.lon ~= last_lon then
      prev_leg = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x}
   end

   local altitude_start = last_alt
   local altitude_end   = x.cstr_altitude1_fl and x.cstr_altitude1*100 or x.cstr_altitude1
   local nm_needed = estimate_vertical_performance(altitude_start, altitude_end)

   local outb_mag = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

   local p_lat, p_lon = point_from_point_course_distance(x.lat, x.lon, outb_mag, nm_needed)

   return prev_leg, { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=x.lat, start_lon=x.lon, end_lat=p_lat, end_lon=p_lon, leg_name = x.leg_name, orig_ref=x }
end


local function convert_generic_VR(x, last_lat, last_lon)

   local outb_mag = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

   local next_lat, next_lon = intersecting_radials(last_lat, last_lon, x.recomm_navaid_lat, x.recomm_navaid_lon, outb_mag, x.theta/10)
   if next_lat and next_lon then
      return { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=next_lat, end_lon=next_lon, leg_name = x.leg_name, orig_ref=x }
   else
      -- TODO Manage error
      assert(false)
   end
end

local function convert_generic_CF(x, last_lat, last_lon, last_course, enforce_intercept_course)
   assert(last_course)

   local outb = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

   local heading_diff = math.abs(heading_difference(last_course, outb))
   if heading_diff < 5 then
      -- Simple case, just keep the heading
      return { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
   end

   -- If not, we have to intercept the new course
   local INTERCEPT_ANGLE = 30 -- From 30 to 45

   local goal_out_radial    = (outb+180+360)%360;
   local intercept_radial_1 = (outb+INTERCEPT_ANGLE+360) % 360;
   local intercept_radial_2 = (outb-INTERCEPT_ANGLE+360) % 360;

   -- We try 3 ways to intercept the course: directly with the last course and at 45/-45 degrees

   -- Try to intercept with the last course
   local next_lat, next_lon = intersecting_radials(last_lat, last_lon, x.lat, x.lon, last_course, goal_out_radial)
   if next_lat and next_lon then
      return { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=next_lat, end_lon=next_lon, leg_name = x.leg_name, orig_ref=x },
             { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=next_lat, start_lon=next_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
   end

   -- Try to intercept from the bottom (or from the forced ones)
   local next_lat, next_lon = intersecting_radials(last_lat, last_lon, x.lat, x.lon, intercept_radial_1, goal_out_radial)
   if next_lat and next_lon then
      return { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=next_lat, end_lon=next_lon, leg_name = x.leg_name, orig_ref=x },
             { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=next_lat, start_lon=next_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
   end
   
   -- Try to intercept from the top
   local next_lat, next_lon = intersecting_radials(last_lat, last_lon, x.lat, x.lon, intercept_radial_2, goal_out_radial)
   if next_lat and next_lon then
      return { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=next_lat, end_lon=next_lon, leg_name = x.leg_name, orig_ref=x },
             { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=next_lat, start_lon=next_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
   end

   -- This is something unexpected, but let's skip the radial connection
   -- and go direct
   sasl.logWarning("convert_generic_CF: CF cannot find radial. last_course="..last_course.." outb="..outb.. " INTERCEPT_ANGLE="..INTERCEPT_ANGLE.." radial1="..intercept_radial_1.." radial2="..intercept_radial_2)
   return { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
end

local function convert_generic_FD_CD(x, last_lat, last_lon)

   local origin_lat = last_lat   -- For CD
   local origin_lon = last_lon   -- For CD
   local prev_connection

   if x.leg_type == CIFP_LEG_TYPE_FD then
      -- If the leg is a FD type, it's possible that we have to add
      -- a new segment from the last lat/lon to the fix of this leg.
      -- This is not the case of CD, because we don't have a fix there.
      if last_lat and last_lon and last_lat ~= x.lat and last_lon ~= x.lon then
         assert(x.lat)
         assert(x.lon)
         prev_connection = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
      end

      origin_lat = x.lat
      origin_lon = x.lon
   end
   -- To understand this check the picture on Discord
   local fix_rn_angle = get_earth_bearing(origin_lat, origin_lon, x.recomm_navaid_lat, x.recomm_navaid_lon)

   local outb_mag = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

   local A = math.abs(heading_difference(fix_rn_angle, outb_mag))
   local b = get_distance_nm(origin_lat, origin_lon, x.recomm_navaid_lat, x.recomm_navaid_lon)
   
   local rte_dme = x.rte_hold_in_time and estimate_distance(x.rte_hold / 10.) or x.rte_hold / 10.

   local a = rte_dme

   A = math.rad(A)
   b = math.pi / (180*60) * b
   a = math.pi / (180*60) * a

   local y=math.sin(A)*math.sin(b)/math.sin(a)
   if y > 1 then
      return prev_connection, nil -- Doesn't exist? wtf?
   end
   local B = y == 1 and math.pi / 2 or math.asin(y)

   local c=(2*math.atan2(math.cos((A+B)/2)*math.sin((a+b)/2), math.cos((A-B)/2)*math.cos((a+b)/2))) % (2*math.pi)

   c = ((180*60)/math.pi)*c

   local new_lat, new_lon = Move_along_distance_NM(origin_lat, origin_lon, c, outb_mag)
   assert(new_lat)
   assert(new_lon)
   local new_segment = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=origin_lat, start_lon=origin_lon, end_lat=new_lat, end_lon=new_lon, leg_name = x.leg_name, orig_ref=x }

   return prev_connection, new_segment
end

local function convert_generic_AF(x, last_lat, last_lon)
   local ctr_lat = x.recomm_navaid_lat
   local ctr_lon = x.recomm_navaid_lon

   local outb_mag = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

   local in_radial = outb_mag
   local dme = x.rho/10

   local end_fix_lat = x.lat
   local end_fix_lon = x.lon

   assert(ctr_lat, ctr_lon, in_radial, dme, end_fix_lat, end_fix_lon)

   local start_lat, start_lon = Move_along_distance_NM(ctr_lat, ctr_lon, dme, in_radial)  -- TODO MAG on radial

   local prev_connection
   if start_lat ~= last_lat or start_lon ~= last_lon then
      prev_connection = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=start_lat, end_lon=start_lon, leg_name = x.leg_name, orig_ref=x }
   end

   local bearing_to_start = get_bearing(ctr_lat,ctr_lon,start_lat,start_lon)
   local bearing_to_end   = get_bearing(ctr_lat,ctr_lon,end_fix_lat,end_fix_lon)

   local bearing_length = math.abs(heading_difference(bearing_to_start, bearing_to_end))

   assert(bearing_to_start, bearing_to_end, bearing_length)

   return prev_connection, { segment_type=FMGS_COMP_SEGMENT_ARC, start_lat=start_lat, start_lon=start_lon, end_lat=end_fix_lat, end_lon=end_fix_lon, ctr_lat=ctr_lat, ctr_lon=ctr_lon, radius=dme, start_angle=bearing_to_start, arc_length_deg=bearing_length, leg_name = x.leg_name, orig_ref=x}


end

local function convert_generic_FC(x, last_lat, last_lon)
   local prev_connection
   if last_lat and last_lon and last_lat ~= x.lat and last_lon ~= x.lon then
      assert(x.lat)
      assert(x.lon)
      prev_connection = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
   end

   local outb_mag = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

   local rte_dme = x.rte_hold_in_time and estimate_distance(x.rte_hold / 10.) or x.rte_hold / 10.

   local new_lat, new_lon = Move_along_distance_NM(x.lat, x.lon, rte_dme, outb_mag)
   local new_segment = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=x.lat, start_lon=x.lon, end_lat=new_lat, end_lon=new_lon, leg_name = x.leg_name, orig_ref=x }
   return prev_connection, new_segment
end

local function convert_generic_VI_CI(x, last_lat, last_lon, last_course)

      -- In this case I need to advance a little bit to satisfy the VI/CI straight line leg
      local STD_TURN_RADIUS = 1.385746606 -- in NM @ 210 kts
      local outb_mag = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)

      if math.abs(heading_difference(last_course, outb_mag)) < 1 then
         return nil -- Almost straight, that's fine
      end

      local angle_diff   = heading_difference(last_course, outb_mag)
      local is_left_turn = angle_diff < 0
      local arc_start    = (last_course+270-(is_left_turn and 180 or 0)+360) % 360

      local ctr_angle    = (arc_start - 180 + 360) % 360
      local ctr_lat, ctr_lon = Move_along_distance_NM(last_lat, last_lon, STD_TURN_RADIUS, ctr_angle)
      local end_lat, end_lon = Move_along_distance_NM(ctr_lat, ctr_lon, STD_TURN_RADIUS, (ctr_angle-180+angle_diff) % 360)


      local point = { segment_type=FMGS_COMP_SEGMENT_ARC, 
                      start_lat=last_lat, 
                      start_lon=last_lon, 
                      end_lat=end_lat, 
                      end_lon=end_lon, 
                      ctr_lat=ctr_lat, 
                      ctr_lon=ctr_lon, 
                      radius=STD_TURN_RADIUS,
                      start_angle=90-arc_start,
                      arc_length_deg=-angle_diff,
                      leg_name = x.leg_name,
                      orig_ref=x}


      return point
end

local function convert_generic(i_legs, begin_lat, begin_lon, begin_alt, begin_course)
   local converted_legs = {}
   local last_lat = begin_lat
   local last_lon = begin_lon
   local last_at_cstr_alt = begin_alt
   local last_outbound_course = begin_course
   local enforce_intercept_course = false

   if not i_legs then
      return {}, begin_lat, begin_lon, begin_course, begin_alt
   end

   if debug_FMGS_path_generation then
      print("Starting from ", begin_lat,  begin_lon, " with CRS=", begin_course)
   end
   for i,x in ipairs(i_legs) do

      if debug_FMGS_path_generation then
         print("I'm doing " .. debug_leg_names[x.leg_type] .. " leg...", x.leg_name)
      end

      if x.mag_decl then
         last_mag_decl = x.mag_decl
      end


      local leg1, leg2

      if x.leg_type == CIFP_LEG_TYPE_IF then
         -- Here we have two cases:
         -- - We have a previous point, just go direct to the IF fix then
         -- - This is the first point ever (in this save it and do nothing)
         if last_lat and last_lon and last_lat ~= x.lat and last_lon ~= x.lon  then
            -- Let's consider it similar to a TF leg
            leg1 = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
         else
            -- First point ever, this is a special case
            last_lat = x.lat
            last_lon = x.lon
         end

      elseif x.leg_type == CIFP_LEG_TYPE_TF or x.leg_type == CIFP_LEG_TYPE_DF then
         -- For TF the outb_mag may or may not be valid (optional field)
         -- we enforce it with the correct computation 
         x.outb_mag = get_earth_bearing(last_lat, last_lon, x.lat, x.lon)*10
         x.outb_mag_in_true = true
         leg1 = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
      elseif x.leg_type == CIFP_LEG_TYPE_RF then
         leg1 = convert_generic_RF(x, last_lat, last_lon)
      elseif x.leg_type == CIFP_LEG_TYPE_CA or x.leg_type == CIFP_LEG_TYPE_VA then  -- TODO Wind
         leg1 = convert_generic_CA(x, last_lat, last_lon, last_at_cstr_alt)
      elseif x.leg_type == CIFP_LEG_TYPE_FA then  -- TODO Wind
         leg1, leg2 = convert_generic_FA(x, last_lat, last_lon, last_at_cstr_alt)
      elseif x.leg_type == CIFP_LEG_TYPE_CR or x.leg_type == CIFP_LEG_TYPE_VR then  -- TODO Wind
         leg1 = convert_generic_VR(x, last_lat, last_lon)
      elseif x.leg_type == CIFP_LEG_TYPE_VI or x.leg_type == CIFP_LEG_TYPE_CI then  -- TODO Wind
         leg1 = convert_generic_VI_CI(x, last_lat, last_lon, last_outbound_course)
      elseif x.leg_type == CIFP_LEG_TYPE_CF then
         leg1, leg2 = convert_generic_CF(x, last_lat, last_lon, last_outbound_course, enforce_intercept_course)
      elseif x.leg_type == CIFP_LEG_TYPE_FD or x.leg_type == CIFP_LEG_TYPE_CD then
         leg1, leg2 = convert_generic_FD_CD(x, last_lat, last_lon)
      elseif x.leg_type == CIFP_LEG_TYPE_FC then
         leg1, leg2 = convert_generic_FC(x, last_lat, last_lon)
      elseif x.leg_type == CIFP_LEG_TYPE_AF then
         leg1, leg2 = convert_generic_AF(x, last_lat, last_lon)
      elseif x.leg_type == CIFP_LEG_TYPE_FM or x.leg_type == CIFP_LEG_TYPE_VM then
         leg1 = { segment_type=FMGS_COMP_SEGMENT_INFINITE_LINE, start_lat=x.lat, start_lon=x.lon, orig_ref=x }
         local outb = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)
         if x.leg_type == CIFP_LEG_TYPE_FM then
            leg1.track=outb
         else
            leg1.heading=outb
         end
      elseif x.leg_type == CIFP_LEG_TYPE_HA or x.leg_type == CIFP_LEG_TYPE_HF or x.leg_type == CIFP_LEG_TYPE_HM then
         -- When we have an hold, we have two segments: the "TF" leg to the hold fix, and then
         -- the hold itself (which is marked with the special type FMGS_COMP_SEGMENT_HOLD)
         -- Distinctions between HA, HF, and HM are managed later not here
         local rte_dme = x.rte_hold_in_time and estimate_distance(x.rte_hold / 10.) or x.rte_hold / 10.
         local outb = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)
         local spd_cstr = x.cstr_speed_type > 0 and x.cstr_speed or nil
         leg1 = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
         leg2 = { segment_type=FMGS_COMP_SEGMENT_HOLD, start_lat=x.lat, start_lon=x.lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, dist=rte_dme, start_crs=outb, turn=x.turn_direction, orig_ref=x, spd_cstr=spd_cstr }
      elseif x.leg_type == CIFP_LEG_TYPE_PI then
         -- When we have an hold, we have two segments: the "TF" leg to the PI fix
         if last_lat ~= x.lat or last_lon ~= x.lon then
            leg1 = { segment_type=FMGS_COMP_SEGMENT_LINE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.leg_name, orig_ref=x }
         end

         local outb = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)
         local rte_dme = x.rte_hold_in_time and estimate_distance(x.rte_hold / 10.) or x.rte_hold / 10.

         leg2 = { segment_type=FMGS_COMP_SEGMENT_PI, start_lat=x.lat, start_lon=x.lon, end_lat=x.lat, end_lon=x.lon, start_crs=outb, turn=x.turn_direction, dist=rte_dme, leg_name = x.leg_name, orig_ref=x }
      else
         sasl.logWarning("convert_generic: skipped leg: " .. x.leg_type)
      end

      enforce_intercept_course = x.leg_type == CIFP_LEG_TYPE_VI or x.leg_type == CIFP_LEG_TYPE_CI

      -- Add the leg
      if leg1 then
         table.insert(converted_legs, leg1)
         if leg1.end_lat and leg1.end_lon then 
            last_lat = leg1.end_lat
            last_lon = leg1.end_lon
         elseif leg1.lat and leg1.lon then
            last_lat = leg1.lat
            last_lon = leg1.lon
         else
            sasl.logWarning("convert_generic: Primary leg valid but no end point")
         end
      end

      if leg2 then
         table.insert(converted_legs, leg2)
         if leg2.end_lat and leg2.end_lon then 
            last_lat = leg2.end_lat
            last_lon = leg2.end_lon
         elseif leg2.lat and leg2.lon then
            last_lat = leg2.lat
            last_lon = leg2.lon
         else
            sasl.logWarning("convert_generic: Secondary leg valid but no end point")
         end
      end

      if  x.leg_type ~= CIFP_LEG_TYPE_IF and not leg1 and not leg2 then
         sasl.logWarning("convert_generic: it seems I skipped a valid leg")
      end

      -- Update last outbound course
      if x.leg_type ~= CIFP_LEG_TYPE_IF and x.outb_mag then
         local outb = x.outb_mag_in_true and x.outb_mag/10 or head_mag_to_true(x.outb_mag/10)
         if x.leg_type == CIFP_LEG_TYPE_PI then
            last_outbound_course = (outb + 180) % 360
         else
            last_outbound_course = outb
         end
      end

      if x.cstr_alt_type == CIFP_CSTR_ALT_AT then
         -- Keep track of the AT constraint (we need it, for instance, for CA leg)
         last_at_cstr_alt = x.cstr_altitude1_fl and x.cstr_altitude1*100 or x.cstr_altitude1
      elseif x.cstr_alt_type == CIFP_CSTR_ALT_ABOVE then
         last_at_cstr_alt = x.cstr_altitude1_fl and x.cstr_altitude1*100 or x.cstr_altitude1
      end
      
   end

   return converted_legs, last_lat, last_lon, last_outbound_course, last_at_cstr_alt
end

local function debug_print_segments(points)
   for i,x in ipairs(points) do
      if x.segment_type == FMGS_COMP_SEGMENT_LINE then
         print("DRAW LINE", x.start_lat, x.start_lon, x.end_lat, x.end_lon, x.leg_name)
      elseif x.segment_type == FMGS_COMP_SEGMENT_ARC then
         print("DRAW ARC", x.start_lat, x.start_lon, x.end_lat, x.end_lon, x.ctr_lat, x.ctr_lon, x.radius, x.start_angle, x.arc_length_deg, x.leg_name)
      elseif x.segment_type == FMGS_COMP_SEGMENT_INFINITE_LINE then
         print("DRAW INFINITE LINE")
      elseif x.segment_type == FMGS_COMP_SEGMENT_HOLD then
         print("DRAW HOLD")
      elseif x.segment_type == FMGS_COMP_SEGMENT_PI then
         print("DRAW PI")
      end
   end
end

function convert_from_FMGS_data(fpln)

    local apts = FMGS_sys.fpln.active.apts

    local rwy_lon = (not apts.dep_rwy[2]) and apts.dep_rwy[1].s_lon or apts.dep_rwy[1].lon
    local rwy_lat = (not apts.dep_rwy[2]) and apts.dep_rwy[1].s_lat or apts.dep_rwy[1].lat
    local rwy_s_lon = (apts.dep_rwy[2]) and apts.dep_rwy[1].s_lon or apts.dep_rwy[1].lon
    local rwy_s_lat = (apts.dep_rwy[2]) and apts.dep_rwy[1].s_lat or apts.dep_rwy[1].lat
    local bearing = (not apts.dep_rwy[2]) and apts.dep_rwy[1].bearing or (apts.dep_rwy[1].bearing + 180) % 360
 
    last_mag_decl = apts.dep_rwy[1].mag_decl or 0
 
    local last_lat = rwy_lat
    local last_lon = rwy_lon
    local last_ob = bearing                              -- Outbound course
    local last_c_alt = apts.dep.alt -- Last @ constraints altitude
    local i_legs
    local segments
 
    local final_list = {}
 
    local parse_section = function(name, str_desc)
       i_legs = apts[name] and apts[name].legs
       segments, last_lat, last_lon, last_ob, last_c_alt = convert_generic(i_legs,last_lat,last_lon,last_c_alt,last_ob)
 
       if debug_FMGS_path_generation then
          print(str_desc)
          debug_print_segments(segments)
       end
       for i,x in ipairs(segments) do
          table.insert(final_list, x)
       end
    end
 
    table.insert(final_list, {segment_type=FMGS_COMP_SEGMENT_RWY_LINE, start_lat=rwy_s_lat, start_lon=rwy_s_lon, end_lat=rwy_lat, end_lon=rwy_lon, orig_ref = {}})   
 
    parse_section("dep_sid", "-- DEP SID --")
    parse_section("dep_trans", "-- DEP TRANS --")
 
 
    for i,x in ipairs(FMGS_sys.fpln.active.legs) do
       if not x.discontinuity then
          local seg = { segment_type=FMGS_COMP_SEGMENT_ENROUTE, start_lat=last_lat, start_lon=last_lon, end_lat=x.lat, end_lon=x.lon, leg_name = x.id, orig_ref=x }
          last_lat = x.lat
          last_lon = x.lon
          table.insert(final_list, seg)
       end
    end
 
    if #FMGS_sys.fpln.active.legs >= 2 then
       last_ob = get_bearing(final_list[#final_list].start_lat,final_list[#final_list].start_lon,final_list[#final_list].end_lat,final_list[#final_list].end_lon)
    end
 
    parse_section("arr_trans", "-- ARR TRANS --")
    parse_section("arr_star", "-- ARR STAR --")
    parse_section("arr_via", "-- ARR VIA --")
    parse_section("arr_appr", "-- ARR APPR --")
    
    if debug_FMGS_path_generation then
       table.save( final_list, "final_list.lua" )
    end
    return final_list
 
end