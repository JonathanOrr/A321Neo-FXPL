--global variables--

--global dataref for the A32NX project--
DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")
Capt_ra_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_ra_alt_m", 0, false, true, false)
Capt_baro_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_baro_alt_m", 0, false, true, false)
Distance_traveled_mi = createGlobalPropertyf("a321neo/dynamics/distance_traveled_mi", 0, false, true, false)
Distance_traveled_km = createGlobalPropertyf("a321neo/dynamics/distance_traveled_km", 0, false, true, false)
Ground_speed_kmh = createGlobalPropertyf("a321neo/dynamics/groundspeed_kmh", 0, false, true, false)
Ground_speed_mph = createGlobalPropertyf("a321neo/dynamics/groundspeed_mph", 0, false, true, true)
--wheel
Aft_wheel_on_ground = createGlobalPropertyi("a321neo/dynamics/aft_wheels_on_ground", 0, false, true, false)
All_on_ground = createGlobalPropertyi("a321neo/dynamics/all_wheels_on_ground", 0, false, true, false)
Brakes_fan = createGlobalPropertyi("a321neo/dynamics/wheel/brakes_fan", 0, false, true, false)
Left_brakes_temp = createGlobalPropertyf("a321neo/dynamics/wheel/left_brakes_temp", 10, false, true, false) --left brakes temperature
Right_brakes_temp = createGlobalPropertyf("a321neo/dynamics/wheel/right_brakes_temp", 10, false, true, false) --right brakes temperature
Left_tire_psi = createGlobalPropertyf("a321neo/dynamics/wheel/left_tire_psi", 210, false, true, false) --left tire psi
Right_tire_psi = createGlobalPropertyf("a321neo/dynamics/wheel/right_tire_psi", 210, false, true, false) --right tire psi
--engines
Engine_mode_knob = createGlobalPropertyi("a321neo/cockpit/engine/engine_mode", 0, false, true, false) -- -1crank, 0norm, 1ignition
Engine_1_master_switch = createGlobalPropertyi("a321neo/cockpit/engine/master_1", 0, false, true, false)
Engine_2_master_switch = createGlobalPropertyi("a321neo/cockpit/engine/master_2", 0, false, true, false)
Eng_1_FF_kgm = createGlobalPropertyf("a321neo/cockpit/engine/engine_1_fuel_flow_kg_min", 0, false, true, false)
Eng_2_FF_kgm = createGlobalPropertyf("a321neo/cockpit/engine/engine_2_fuel_flow_kg_min", 0, false, true, false)
Engine_option = createGlobalPropertyi("a321neo/customization/engine_option", 0, false, true, false) --0 CFM LEAP, 1 PW1000G
PW_engine_enabled = createGlobalPropertyi("a321neo/customization/pw_engine_enabled", 0, false, true, false)
Leap_engien_option = createGlobalPropertyi("a321neo/customization/leap_engine_enabled", 0, false, true, false)
--pfd
Max_speed = createGlobalPropertyf("a321neo/cockpit/PFD/max_speed", 330, false, true, false)
Max_speed_delta = createGlobalPropertyf("a321neo/cockpit/PFD/max_speed_delta", 0, false, true, false)
--ecam
Ecam_previous_page = createGlobalPropertyi("a321neo/cockpit/ecam/previous", 2, false, true, false) --1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS
Ecam_current_page = createGlobalPropertyi("a321neo/cockpit/ecam/page_num", 2, false, true, false) --1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS
--aircon datarefs
Cockpit_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp_req", 21, false, true, false) --requested cockpit temperature
Front_cab_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp_req", 21, false, true, false) --requested front cabin temperature
Aft_cab_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp_req", 21, false, true, false) --requested aft cabin temperature
Aft_cargo_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cargo_temp_req", 17, false, true, false) ---requested aft cargo temperature
Cockpit_temp = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp", 15, false, true, false) --actual cockpit temperature
Front_cab_temp = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp", 15, false, true, false) --actual front cabin temperature
Aft_cab_temp = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp", 15, false, true, false) --actual aft cabin temperature
Aft_cargo_temp = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cargo_temp", 17, false, true, false) ---requested aft cargo temperature
--PACKS
A321_Pack_Flow_dial = createGlobalPropertyi("a321neo/cockpit/packs/pack_flow_dial", 0, false, true, false) --the pack flow dial 0low, 1norm, 2high
Eng1_bleed_off = createGlobalPropertyi("a321neo/cockpit/packs/eng1_off", 0, false, true, false) --0 is on 1 if off
Eng2_bleed_off = createGlobalPropertyi("a321neo/cockpit/packs/eng2_off", 0, false, true, false) --0 is on 1 if off
L_pack_Flow = createGlobalPropertyi("a321neo/dynamics/packs/l_pack_flow", 0, false, true, false) --0low, 1norm, 2high
R_pack_Flow = createGlobalPropertyi("a321neo/dynamics/packs/r_pack_flow", 0, false, true, false) --0low, 1norm, 2high
L_HP_valve = createGlobalPropertyi("a321neo/dynamics/packs/l_hp_valve", 0, false, true, false)
R_HP_valve = createGlobalPropertyi("a321neo/dynamics/packs/r_hp_valve", 0, false, true, false)
X_bleed_valve = createGlobalPropertyi("a321neo/dynamics/packs/x_bleed_valve", 0, false, true, false) --0closed, 1open
X_bleed_bridge_state = createGlobalPropertyi("a321neo/dynamics/packs/x_bleed_bridge_state", 0, false, true, false) --0closed, 1bridged clsoed, 2bridged open
X_bleed_dial = createGlobalPropertyi("a321neo/dynamics/packs/x_bleed_dial", 1, false, true, false) --0closed, 1auto, 2open
Packs_avail = createGlobalPropertyi("a321neo/dynamics/packs/packs_avail", 0, false, true, false)--if the pack actually has air going through it
L_bleed_state = createGlobalPropertyi("a321neo/dynamics/packs/l_bleed_state", 0, false, true, false)--0engine 1 not running bleed off, 1engine 1 running bleed off, 2engine 1 running bleed on
R_bleed_state = createGlobalPropertyi("a321neo/dynamics/packs/r_bleed_state", 0, false, true, false)--0engine 2 not running bleed off, 1engine 2 running bleed off, 2engine 2 running bleed on
L_bleed_press = createGlobalPropertyf("a321neo/dynamics/packs/l_bleed_press_psi", 0, false, true, false)
R_bleed_press = createGlobalPropertyf("a321neo/dynamics/packs/r_bleed_press_psi", 0, false, true, false)
L_bleed_temp = createGlobalPropertyf("a321neo/dynamics/packs/l_bleed_temp", 10, false, true, false)
R_bleed_temp = createGlobalPropertyf("a321neo/dynamics/packs/r_bleed_temp", 10, false, true, false)
L_compressor_temp = createGlobalPropertyf("a321neo/dynamics/packs/l_compressor_temp", 10, false, true, false)
R_compressor_temp = createGlobalPropertyf("a321neo/dynamics/packs/r_compressor_temp", 10, false, true, false)
L_pack_temp = createGlobalPropertyf("a321neo/dynamics/packs/l_pack_temp", 10, false, true, false)
R_pack_temp = createGlobalPropertyf("a321neo/dynamics/packs/r_pack_temp", 10, false, true, false)
--apu
Apu_avail = createGlobalPropertyi("a321neo/engine/apu_avil", 0, false, true, false)
Apu_gen_load = createGlobalPropertyf("a321neo/cockpit/apu/gen_load", 0, false, true, false)
Apu_gen_volts = createGlobalPropertyf("a321neo/cockpit/apu/gen_volts", 0, false, true, false)
Apu_gen_hz = createGlobalPropertyf("a321neo/cockpit/apu/gen_hz", 0, false, true, false)
Apu_bleed_psi = createGlobalPropertyf("a321neo/cockpit/apu/bleed_psi", 0, false, true, false)
Apu_bleed_state = createGlobalPropertyi("a321neo/apu/apu_bleed_state", 0, false, true, false)--0apu off bleed off, 1apu on bleed off, 2apu on bleed on
Apu_gen_state = createGlobalPropertyi("a321neo/cockpit/apu/apu_gen_state", 0, false, true, false)--0apu off gen off, 1apu on gen off, 2apu on gen on
--FBW--
FBW_on = createGlobalPropertyi("a321neo/dynamics/fctl/FBW_on", 1, false, true, false)
Roll_l_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_l_lim", 0, false, true, false)
Roll_r_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_r_lim", 0, false, true, false)
Pitch_u_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_u_lim", 0, false, true, false)
Pitch_d_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_d_lim", 0, false, true, false)
Pitch_rate_u_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_rate_u_lim", 0, false, true, false)
Pitch_rate_d_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_rate_d_lim", 0, false, true, false)
AOA_lim = createGlobalPropertyf("a321neo/dynamics/FBW/AOA_lim", 0, false, true, false)
MAX_spd_lim = createGlobalPropertyf("a321neo/dynamics/FBW/MAX_spd_lim", 0, false, true, false)
Roll_rate_output = createGlobalPropertyf("a321neo/dynamics/FBW/roll_rate_output", 0, false, true, false)
G_output = createGlobalPropertyf("a321neo/dynamics/FBW/G_output", 0, false, true, false)
Roll_rate_command = createGlobalPropertyf("a321neo/dynamics/FBW/roll_rate_command", 0, false, true, false)--15 degrees max for normal law, 30 degrees in ALT2 or DIRECT
G_load_command = createGlobalPropertyf("a321neo/dynamics/FBW/G_load_command", 1, false, true, false)--2.5G to -1G in normal flight, with flaps 2G to 0G


--global dataref variable from the Sim--
--autopilot
Flight_director_1_mode = globalProperty("sim/cockpit2/autopilot/flight_director_mode")
Flight_director_2_mode = globalProperty("sim/cockpit2/autopilot/flight_director2_mode")
--flight controls
Roll = globalProperty("sim/joystick/yoke_roll_ratio")
Pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
Yaw = globalProperty("sim/joystick/yoke_heading_ratio")
Roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
Pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
Yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")
Servo_roll = globalProperty("sim/joystick/servo_roll_ratio")
Servo_pitch = globalProperty("sim/joystick/servo_pitch_ratio")
Servo_yaw = globalProperty("sim/joystick/servo_heading_ratio")
Flaps_handle_ratio = globalProperty("sim/cockpit2/controls/flap_ratio")
Flaps_handle_deploy_ratio = globalProperty("sim/cockpit2/controls/flap_handle_deploy_ratio")
Flightmodel_roll = globalProperty("sim/flightmodel/position/true_phi")
Flightmodel_pitch = globalProperty("sim/flightmodel/position/true_theta")
Elev_trim_ratio = globalProperty("sim/cockpit2/controls/elevator_trim")
Horizontal_stabilizer_pitch = globalProperty("sim/flightmodel2/controls/stabilizer_deflection_degrees")
Override_artstab = globalProperty("sim/operation/override/override_artstab")
Override_control_surfaces = globalProperty("sim/operation/override/override_control_surfaces")
Total_vertical_g_load = globalProperty("sim/flightmodel/forces/g_nrml")
Roll_rate = globalProperty("sim/flightmodel/position/P")
Pitch_rate = globalProperty("sim/flightmodel/position/Q")
Alpha = globalProperty("sim/flightmodel/position/alpha")
--electrical system
Battery_1 = globalProperty("sim/cockpit/electrical/battery_array_on[0]")
Battery_2 = globalProperty("sim/cockpit/electrical/battery_array_on[1]")
--fuel
Fuel_pump_1 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[0]")
Fuel_pump_2 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[1]")
Fuel_pump_3 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[2]")
Fuel_pump_4 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[3]")
Fuel_pump_5 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[4]")
Fuel_pump_6 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[5]")
Fuel_pump_7 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[6]")
Fuel_pump_8 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[7]")
--ENG and APU
Engine_1_avail = globalProperty("sim/flightmodel/engine/ENGN_running[0]")
Engine_2_avail = globalProperty("sim/flightmodel/engine/ENGN_running[1]")
Eng_1_N1 = globalProperty("sim/flightmodel2/engines/N1_percent[0]")
Eng_2_N1 = globalProperty("sim/flightmodel2/engines/N1_percent[1]")
Eng_1_EGT_c = globalProperty("sim/cockpit2/engine/indicators/EGT_deg_C[0]")
Eng_2_EGT_c = globalProperty("sim/cockpit2/engine/indicators/EGT_deg_C[1]")
Eng_1_N2 = globalProperty("sim/flightmodel2/engines/N2_percent[0]")
Eng_2_N2 = globalProperty("sim/flightmodel2/engines/N2_percent[1]")
Eng_1_FF_kgs = globalProperty("sim/cockpit2/engine/indicators/fuel_flow_kg_sec[0]")
Eng_2_FF_kgs = globalProperty("sim/cockpit2/engine/indicators/fuel_flow_kg_sec[1]")
Apu_N1 = globalProperty("sim/cockpit2/electrical/APU_N1_percent")
APU_EGT = globalProperty("sim/cockpit2/electrical/APU_EGT_c")
--PACKs system
Apu_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/apu_bleed")
ENG_1_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/engine_bleed_sov[0]")
ENG_2_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/engine_bleed_sov[1]")
Left_bleed_avil = globalProperty("sim/cockpit2/bleedair/indicators/bleed_available_left")
Mid_bleed_avil = globalProperty("sim/cockpit2/bleedair/indicators/bleed_available_center")
Right_bleed_avil = globalProperty("sim/cockpit2/bleedair/indicators/bleed_available_right")
Pack_L = globalProperty("sim/cockpit2/bleedair/actuators/pack_left")
Pack_M = globalProperty("sim/cockpit2/bleedair/actuators/pack_center") --needs to be turned off as the A320 does not have one
Pack_R = globalProperty("sim/cockpit2/bleedair/actuators/pack_right")
Sim_pack_flow = globalProperty("sim/cockpit2/pressurization/actuators/fan_setting") --Electric fan (vent blower) setting, consuming 0.1 of rel_HVAVC amps when running. 0 = Auto (Runs whenever air_cond_on or heater_on is on), 1 = Low, 2 = High
Left_pack_iso_valve = globalProperty("sim/cockpit2/bleedair/actuators/isol_valve_left") --Isolation Valve for left duct, close or open. This separates all engines on the left side of the plane, the left wing, and the left pack from the rest of the system
Right_pack_iso_valve = globalProperty("sim/cockpit2/bleedair/actuators/isol_valve_right") --Isolation Valve for right duct, close or open. This separates all engines on the right side of the plane, the right wing, and the right pack from the rest of the system
Cabin_delta_psi = globalProperty("sim/cockpit2/pressurization/indicators/pressure_diffential_psi")
Set_cabin_alt_ft = globalProperty("sim/cockpit2/pressurization/actuators/cabin_altitude_ft")
Cabin_alt_ft = globalProperty("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")
Set_cabin_vs = globalProperty("sim/cockpit2/pressurization/actuators/cabin_vvi_fpm")
Cabin_vs = globalProperty("sim/cockpit2/pressurization/indicators/cabin_vvi_fpm")
Out_flow_valve_ratio = globalProperty("sim/cockpit2/pressurization/indicators/outflow_valve")
--instruments
OTA = globalProperty("sim/cockpit2/temperature/outside_air_temp_degc")
TAT = globalProperty("sim/weather/temperature_le_c")
Gross_weight = globalProperty ("sim/flightmodel/weight/m_total")
Capt_ra_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
Capt_baro_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
IAS = globalProperty("sim/flightmodel/position/indicated_airspeed")
--gear
Gear_handle = globalProperty("sim/cockpit2/controls/gear_handle_down")
Front_gear_deployment = globalProperty("sim/flightmodel2/gear/deploy_ratio[0]")
Left_gear_deployment = globalProperty("sim/flightmodel2/gear/deploy_ratio[1]")
Right_gear_deployment = globalProperty("sim/flightmodel2/gear/deploy_ratio[2]")
Ground_speed_ms = globalProperty("sim/flightmodel/position/groundspeed")
Actual_brake_ratio = globalProperty("sim/flightmodel/controls/parkbrake")
--position
Aircraft_lat = globalProperty("sim/flightmodel/position/latitude")
Aircraft_long = globalProperty("sim/flightmodel/position/longitude")
Distance_traveled_m = globalProperty("sim/flightmodel/controls/dist")
--weights
FOB = globalProperty("sim/flightmodel/weight/m_fuel_total")
--time
ZULU_hours = globalProperty("sim/cockpit2/clock_timer/zulu_time_hours")
ZULU_mins = globalProperty("sim/cockpit2/clock_timer/zulu_time_minutes")
ZULU_secs = globalProperty("sim/cockpit2/clock_timer/zulu_time_seconds")

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

--used to animate a value with a curve USE ONLY WITH FLOAT VALUES
function Set_anim_value(current_value, target, min, max, speed)

  if target >= (max - 0.001) and current_value >= (max - 0.01) then
      return max
  elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
      return min
  else
      return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
  end

end

--used to animate a value with a curve USE ONLY WITH FLOAT VALUES
function Set_linear_anim_value(current_value, target, min, max, speed, dead_zone)
  if target - current_value < dead_zone and target - current_value > -dead_zone then
    return target
  elseif target < current_value then
    return Math_clamp(current_value - (speed * get(DELTA_TIME)), min, max)
  elseif target > current_value then
    return Math_clamp(current_value + (speed * get(DELTA_TIME)), min, max)
  end
end

-- for giving datarefs linear delayed outputs by using set_linear_anim_value
function Set_dataref_linear_anim(dataref, target, min, max, speed, dead_zone)
  set(dataref, Set_linear_anim_value(get(dataref), target, min, max, speed, dead_zone))
end

--used for ecam automation
function Goto_ecam(page_num)
  set(Ecam_previous_page, get(Ecam_current_page))
  set(Ecam_current_page, page_num)
end

--rounding
function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
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

function FBW_PD(pd_array, error)
    local last_error = pd_array.Current_error
	pd_array.Current_error = error + pd_array.Error_offset

	--Proportional--
	local correction = pd_array.Current_error * pd_array.P_gain

	--derivative--
	correction = correction + (pd_array.Current_error - last_error) * pd_array.D_gain

	--limit and rescale output range--
	correction = Math_clamp(correction, pd_array.Min_error, pd_array.Max_error) / pd_array.Max_error

	return correction
end

function FBW_PID(pid_array, error)
    local last_error = pid_array.Current_error
	pid_array.Current_error = error + pid_array.Error_offset

	--Proportional--
	local correction = pid_array.Current_error * pid_array.P_gain

	--integral--
	pid_array.Integral = (pid_array.Integral * (pid_array.I_delay - 1) + pid_array.Current_error) / pid_array.I_delay

	--clamping the integral to minimise the delay
	pid_array.Integral = Math_clamp(pid_array.Integral, pid_array.Min_error, pid_array.Max_error)

	correction = correction + pid_array.Integral * pid_array.I_gain

	--derivative--
	correction = correction + (pid_array.Current_error - last_error) * pid_array.D_gain

	--limit and rescale output range--
	correction = Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error

	return correction
end