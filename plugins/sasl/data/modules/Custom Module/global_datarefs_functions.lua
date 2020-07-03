--global dataref for the A32NX project
DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")
Capt_ra_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_ra_alt_m", 0, false, true, false)
Capt_baro_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_baro_alt_m", 0, false, true, false)
Distance_traveled_mi = createGlobalPropertyf("a321neo/dynamics/distance_traveled_mi", 0, false, true, false)
Distance_traveled_km = createGlobalPropertyf("a321neo/dynamics/distance_traveled_km", 0, false, true, false)
Ground_speed_kmh = createGlobalPropertyf("a321neo/dynamics/groundspeed_kmh", 0, false, true, false)
Ground_speed_mph = createGlobalPropertyf("a321neo/dynamics/groundspeed_mph", 0, false, true, true)
Engine_1_master_switch = createGlobalPropertyi("a321neo/engine/master_1", 0, false, true, false)
Engine_2_master_switch = createGlobalPropertyi("a321neo/engine/master_2", 0, false, true, false)
Engine_option = createGlobalPropertyi("a321neo/customization/engine_option", 0, false, true, false) --0 CFM LEAP, 1 PW1000G
PW_engine_enabled = createGlobalPropertyi("a321neo/customization/pw_engine_enabled", 0, false, true, false)
Leap_engien_option = createGlobalPropertyi("a321neo/customization/leap_engine_enabled", 0, false, true, false)

--global dataref variable from the Sim
Battery_1 = globalProperty("sim/cockpit/electrical/battery_array_on[0]")
Battery_2 = globalProperty("sim/cockpit/electrical/battery_array_on[1]")
Apu_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/apu_bleed")
ENG_1_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/engine_bleed_sov[0]")
ENG_2_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/engine_bleed_sov[1]")
Left_bleed_avil = globalProperty("sim/cockpit2/bleedair/indicators/bleed_available_left")
Mid_bleed_avil = globalProperty("sim/cockpit2/bleedair/indicators/bleed_available_center")
Right_bleed_avil = globalProperty("sim/cockpit2/bleedair/indicators/bleed_available_right")
OTA = globalProperty("sim/cockpit2/temperature/outside_air_temp_degc")
Capt_ra_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
Capt_baro_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
Distance_traveled_m = globalProperty("sim/flightmodel/controls/dist")
Ground_speed_ms = globalProperty("sim/flightmodel/position/groundspeed")
Engine_1_avail = globalProperty("sim/flightmodel/engine/ENGN_running[0]")
Engine_2_avail = globalProperty("sim/flightmodel/engine/ENGN_running[1]")
Aircraft_lat = globalProperty("sim/flightmodel/position/latitude")
Aircraft_long = globalProperty("sim/flightmodel/position/longitude")

--custom functions
function Math_clamp(val, min, max)
  if min > max then LogWarning("Min is larger than Max invalid") end
  if val < min then
      return min
  elseif val > max then
      return max
  elseif val <= max and val >= min then
      return val
  end
end

--used to animate a value with a curve
function Set_anim_value(current_value, target, min, max, speed)

  if target >= (max - 0.001) and current_value >= (max - 0.01) then
      return max
  elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
      return min
  else
      return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
  end

end

function GC_distance_kt(lat1, lon1, lat2, lon2)

  --This function returns great circle distance between 2 points.
  --Found here: http://bluemm.blogspot.gr/2007/01/excel-formula-to-calculate-distance.html
  --lat1, lon1 = the coords from start position (or aircraft's) / lat2, lon2 coords of the target waypoint.
  --6371km is the mean radius of earth in meters. Since X-Plane uses 6378 km as radius, which does not makes a big difference,
  --(about 5 NM at 6000 NM), we are going to use the same.
  --Other formulas I've tested, seem to break when latitudes are in different hemisphere (west-east).
  
  local distance = math.acos(math.cos(math.rad(90-lat1))*math.cos(math.rad(90-lat2))+
      math.sin(math.rad(90-lat1))*math.sin(math.rad(90-lat2))*math.cos(math.rad(lon1-lon2))) * (6378000/1852)
  
  return distance
  
end

function GC_distance_km(lat1, lon1, lat2, lon2)

  --This function returns great circle distance between 2 points.
  --Found here: http://bluemm.blogspot.gr/2007/01/excel-formula-to-calculate-distance.html
  --lat1, lon1 = the coords from start position (or aircraft's) / lat2, lon2 coords of the target waypoint.
  --6371km is the mean radius of earth in meters. Since X-Plane uses 6378 km as radius, which does not makes a big difference,
  --(about 5 NM at 6000 NM), we are going to use the same.
  --Other formulas I've tested, seem to break when latitudes are in different hemisphere (west-east).
  
  local distance = math.acos(math.cos(math.rad(90-lat1))*math.cos(math.rad(90-lat2))+
      math.sin(math.rad(90-lat1))*math.sin(math.rad(90-lat2))*math.cos(math.rad(lon1-lon2))) * (6378000/1000)
  
  return distance
  
end