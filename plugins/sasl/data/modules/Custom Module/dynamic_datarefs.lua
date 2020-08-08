--global variables--

--global dataref for the A32NX project--
DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")
TIME = globalProperty("sim/time/total_running_time_sec")
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
Engine_option = createGlobalPropertyi("a321neo/customization/engine_option", 0, false, true, false) --0 CFM LEAP, 1 PW1000G
PW_engine_enabled = createGlobalPropertyi("a321neo/customization/pw_engine_enabled", 0, false, true, false)
Leap_engien_option = createGlobalPropertyi("a321neo/customization/leap_engine_enabled", 0, false, true, false)
--PACKS
L_pack_Flow = createGlobalPropertyi("a321neo/dynamics/packs/l_pack_flow", 0, false, true, false) --0low, 1norm, 2high
R_pack_Flow = createGlobalPropertyi("a321neo/dynamics/packs/r_pack_flow", 0, false, true, false) --0low, 1norm, 2high
L_HP_valve = createGlobalPropertyi("a321neo/dynamics/packs/l_hp_valve", 0, false, true, false)
R_HP_valve = createGlobalPropertyi("a321neo/dynamics/packs/r_hp_valve", 0, false, true, false)
X_bleed_valve = createGlobalPropertyi("a321neo/dynamics/packs/x_bleed_valve", 0, false, true, false) --0closed, 1open
X_bleed_bridge_state = createGlobalPropertyi("a321neo/dynamics/packs/x_bleed_bridge_state", 0, false, true, false) --0closed, 1bridged clsoed, 2bridged open
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
--FBW
FBW_status = createGlobalPropertyi("a321neo/dynamics/FBW/FBW_on", 2, false, true, false)--2=NORMAL law, 1=ALT2 law, 0==DIRECT law
FBW_ground_mode = createGlobalPropertyi("a321neo/dynamics/FBW/in_ground_mode", 0, false, true, false)--if the aircraft is on ground and FBW is in normal law
FBW_flare_mode = createGlobalPropertyi("a321neo/dynamics/FBW/in_flare_mode", 0, false, true, false)--if the aircraft is in flare mode
FBW_flaring = createGlobalPropertyi("a321neo/dynamics/FBW/in_flaring", 0, false, true, false)--if the FBW is synthesising a flare
Roll_l_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_l_lim", 0, false, true, false)
Roll_r_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_r_lim", 0, false, true, false)
Pitch_u_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_u_lim", 0, false, true, false)
Pitch_d_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_d_lim", 0, false, true, false)
Pitch_rate_u_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_rate_u_lim", 0, false, true, false)
Pitch_rate_d_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_rate_d_lim", 0, false, true, false)
AOA_lim = createGlobalPropertyf("a321neo/dynamics/FBW/AOA_lim", 0, false, true, false)
MAX_spd_lim = createGlobalPropertyf("a321neo/dynamics/FBW/MAX_spd_lim", 0, false, true, false)
Roll_rate_command = createGlobalPropertyf("a321neo/dynamics/FBW/roll_rate_command", 0, false, true, false)--15 degrees max for normal law, 30 degrees in ALT2 or DIRECT
Roll_rate_output = createGlobalPropertyf("a321neo/dynamics/FBW/roll_rate_output", 0, false, true, false)
G_load_command = createGlobalPropertyf("a321neo/dynamics/FBW/G_load_command", 1, false, true, false)--2.5G to -1G in normal flight, with flaps 2G to 0G
G_output = createGlobalPropertyf("a321neo/dynamics/FBW/G_output", 0, false, true, false)
ELAC_1 = createGlobalPropertyi("a321neo/dynamics/FBW/ELAC_1", 1, false, true, false)--elevator aileron computer 1
ELAC_2 = createGlobalPropertyi("a321neo/dynamics/FBW/ELAC_2", 1, false, true, false)--elevator aileron computer 2
FAC_1 = createGlobalPropertyi("a321neo/dynamics/FBW/FAC_1", 1, false, true, false)--flight augmentation computer 1
FAC_2 = createGlobalPropertyi("a321neo/dynamics/FBW/FAC_2", 1, false, true, false)--flight augmentation computer 2
SEC_1 = createGlobalPropertyi("a321neo/dynamics/FBW/SEC_1", 1, false, true, false)--spoiler elevator computer 1
SEC_2 = createGlobalPropertyi("a321neo/dynamics/FBW/SEC_2", 1, false, true, false)--spoiler elevator computer 2
SEC_3 = createGlobalPropertyi("a321neo/dynamics/FBW/SEC_3", 1, false, true, false)--spoiler elevator computer 3
--electrical system
Commercial_on = createGlobalPropertyi("a321neo/dynamics/electrical/commercial_on", 1, false, true, false)
Gally_on = createGlobalPropertyi("a321neo/dynamics/electrical/gally_on", 1, false, true, false)
DC_ess_bus_on = createGlobalPropertyi("a321neo/dynamics/electrical/dc_ess_bus_on", 1, false, true, false)
DC_bus_1_on = createGlobalPropertyi("a321neo/dynamics/electrical/dc_bus_1_on", 1, false, true, false)
DC_bus_2_on = createGlobalPropertyi("a321neo/dynamics/electrical/dc_bus_2_on", 1, false, true, false)
ESS_TR_on = createGlobalPropertyi("a321neo/dynamics/electrical/ess_tr_on", 1, false, true, false)
TR_1_on = createGlobalPropertyi("a321neo/dynamics/electrical/tr_1_on", 1, false, true, false)
TR_2_on = createGlobalPropertyi("a321neo/dynamics/electrical/tr_2_on", 1, false, true, false)
AC_ess_bus_on = createGlobalPropertyi("a321neo/dynamics/electrical/ac_ess_bus_on", 1, false, true, false)
AC_ess_feed_1_on = createGlobalPropertyi("a321neo/dynamics/electrical/ac_ess_feed_1_on", 1, false, true, false)
AC_ess_feed_2_on = createGlobalPropertyi("a321neo/dynamics/electrical/ac_ess_feed_2_on", 1, false, true, false)
AC_bus_1_on = createGlobalPropertyi("a321neo/dynamics/electrical/ac_bus_1_on", 1, false, true, false)
AC_bus_2_on = createGlobalPropertyi("a321neo/dynamics/electrical/ac_bus_2_on", 1, false, true, false)
Gen_1_on = createGlobalPropertyi("a321neo/dynamics/electrical/gen_1_on", 1, false, true, false)
Gen_2_on = createGlobalPropertyi("a321neo/dynamics/electrical/gen_2_on", 1, false, true, false)
--ADIRS
Adirs_sys_on = createGlobalPropertyi("a321neo/cockpit/adris/adirs_on", 0, false, true, false)
Adirs_irs_aligned = createGlobalPropertyi("a321neo/cockpit/adris/irs_aligned", 0, false, true, false)
-- EWD
EWD_left_memo = {}
EWD_left_memo_group = {}
EWD_left_memo_colors = {}
EWD_left_memo_group_colors = {}
for i=0,6 do
	EWD_left_memo[i] = createGlobalPropertys("a321neo/cockpit/EWD/EWD_left_memo[".. i .. "]", "", false, true, false)
	EWD_left_memo_group[i] = createGlobalPropertys("a321neo/cockpit/EWD/EWD_left_memo_group[".. i .. "]", "", false, true, false)
	EWD_left_memo_colors[i] = createGlobalPropertyi("a321neo/cockpit/EWD/EWD_left_memo_colors[".. i .. "]", 0, false, true, false)
	EWD_left_memo_group_colors[i] = createGlobalPropertyi("a321neo/cockpit/EWD/EWD_left_memo_group_colors[".. i .. "]", 0, false, true, false)
end
EWD_right_memo = {}
EWD_right_memo_colors = {}
for i=0,6 do
	EWD_right_memo[i] = createGlobalPropertys("a321neo/cockpit/EWD/EWD_right_memo[".. i .. "]", "", false, true, false)
	EWD_right_memo_colors[i] = createGlobalPropertyi("a321neo/cockpit/EWD/EWD_right_memo_colors[".. i .. "]", 0, false, true, false)
end
EWD_flight_phase = createGlobalPropertyi("a321neo/cockpit/EWD/flight_phase", 0, false, true, false)
EWD_is_to_memo_showed  = createGlobalPropertyi("a321neo/cockpit/EWD/to_memo_showed", 0, false, true, false)
EWD_is_ldg_memo_showed = createGlobalPropertyi("a321neo/cockpit/EWD/ldg_memo_showed", 0, false, true, false)
EWD_box_adv        = createGlobalPropertyi("a321neo/cockpit/EWD/box_adv", 0, false, true, false) -- Advisory box: 1 displayed, 0 hidden
EWD_box_sts        = createGlobalPropertyi("a321neo/cockpit/EWD/box_sts", 0, false, true, false) -- STS box: 1 displayed, 0 hidden
EWD_arrow_overflow = createGlobalPropertyi("a321neo/cockpit/EWD/arrow_overflow", 0, false, true, false) -- Overflow arrow: 1 displayed, 0 hidden
TO_Config_is_ready = createGlobalPropertyi("a321neo/cockpit/EWD/to_config_ready", 0, false, true, false) -- Overflow arrow: 1 displayed, 0 hidden

--global dataref variable from the Sim--
--camera
Head_x = globalProperty("sim/graphics/view/pilots_head_x")
Head_y = globalProperty("sim/graphics/view/pilots_head_y")
Head_z = globalProperty("sim/graphics/view/pilots_head_z")
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
Speedbrake_handle_ratio = globalProperty("sim/cockpit2/controls/speedbrake_ratio")
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
Eng_1_reverser_deployment = globalProperty("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[0]")
Eng_2_reverser_deployment = globalProperty("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[1]")
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
VVI = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
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
Elevation_m = globalProperty("sim/flightmodel/position/elevation")
Distance_traveled_m = globalProperty("sim/flightmodel/controls/dist")
--weights
FOB = globalProperty("sim/flightmodel/weight/m_fuel_total")
--time
ZULU_hours = globalProperty("sim/cockpit2/clock_timer/zulu_time_hours")
ZULU_mins = globalProperty("sim/cockpit2/clock_timer/zulu_time_minutes")
ZULU_secs = globalProperty("sim/cockpit2/clock_timer/zulu_time_seconds")


