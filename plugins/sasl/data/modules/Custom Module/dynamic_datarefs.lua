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
-- File: dynamic_datarefs.lua 
-- Short description: Registration or creation of global datarefs
-------------------------------------------------------------------------------


--global dataref for the A32NX project--
DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")
DELTA_TIME_NO_STOP = globalProperty("sim/time/framerate_period") -- Delta time active also in pause
TIME = globalProperty("sim/time/total_running_time_sec")
FLIGHT_TIME = globalProperty("sim/time/total_flight_time_sec")
Distance_traveled_mi = createGlobalPropertyf("a321neo/dynamics/distance_traveled_mi", 0, false, true, false)
Distance_traveled_km = createGlobalPropertyf("a321neo/dynamics/distance_traveled_km", 0, false, true, false)
Ground_speed_kmh = createGlobalPropertyf("a321neo/dynamics/groundspeed_kmh", 0, false, true, false)
Ground_speed_mph = createGlobalPropertyf("a321neo/dynamics/groundspeed_mph", 0, false, true, true)
Ground_speed_kts = createGlobalPropertyf("a321neo/dynamics/groundspeed_kts", 0, false, true, false) --ground speed in kts
Ground_speed_ms = globalProperty("sim/flightmodel/position/groundspeed")
Startup_running = globalProperty("sim/operation/prefs/startup_running") -- 1 if user asked to startup with engines running
--wheel
Override_wheel_steering = globalProperty("sim/operation/override/override_wheel_steer")
Override_wheel_gear_and_brk = globalProperty("sim/operation/override/override_gearbrake")
Nosewheel_Steering_working = createGlobalPropertyi("a321neo/dynamics/wheel/steering_is_working", 0, false, true, false)  -- 0: no, 1: yes
Nosewheel_Steering_limit   = createGlobalPropertyi("a321neo/dynamics/wheel/steering_limit", 0, false, true, false)  -- Limit (abs value) for steering
Steer_ratio_setpoint       = createGlobalPropertyi("a321neo/dynamics/wheel/steer_setpoint", 0, false, true, false)
Steer_ratio_actual         = globalProperty("sim/flightmodel2/gear/tire_steer_command_deg[0]")
Either_Aft_on_ground = createGlobalPropertyi("a321neo/dynamics/either_aft_on_ground", 0, false, true, false)
Aft_wheel_on_ground = createGlobalPropertyi("a321neo/dynamics/aft_wheels_on_ground", 0, false, true, false)
All_on_ground = createGlobalPropertyi("a321neo/dynamics/all_wheels_on_ground", 0, false, true, false)
Any_wheel_on_ground = createGlobalPropertyi("a321neo/dynamics/any_wheel_on_ground", 0, false, true, false)
Brakes_fan = createGlobalPropertyi("a321neo/dynamics/wheel/brakes_fan", 0, false, true, false)
Left_brakes_temp = createGlobalPropertyf("a321neo/dynamics/wheel/left_brakes_temp", 10, false, true, false) --left brakes temperature
Right_brakes_temp = createGlobalPropertyf("a321neo/dynamics/wheel/right_brakes_temp", 10, false, true, false) --right brakes temperature
Nose_tire_psi = createGlobalPropertyf("a321neo/dynamics/wheel/nose_tire_psi", 180, false, true, false) --left tire psi
Left_tire_psi = createGlobalPropertyf("a321neo/dynamics/wheel/left_tire_psi", 210, false, true, false) --left tire psi
Right_tire_psi = createGlobalPropertyf("a321neo/dynamics/wheel/right_tire_psi", 210, false, true, false) --right tire psi

Brakes_mode = createGlobalPropertyi("a321neo/dynamics/wheel/brake_mode", 4, false, true, false) -- 0: unknown, 1: normal, 2: alternate with antiskid, 3: alternate without antiskid, 4: parking
Wheel_status_LGCIU_1 = createGlobalPropertyi("a321neo/dynamics/wheel/computers/lgciu_1_status", 0, false, true, false)
Wheel_status_LGCIU_2 = createGlobalPropertyi("a321neo/dynamics/wheel/computers/lgciu_2_status", 0, false, true, false)
Wheel_status_BSCU_1 = createGlobalPropertyi("a321neo/dynamics/wheel/computers/bscu_1_status", 0, false, true, false)
Wheel_status_BSCU_2 = createGlobalPropertyi("a321neo/dynamics/wheel/computers/bscu_2_status", 0, false, true, false)
Wheel_status_ABCU   = createGlobalPropertyi("a321neo/dynamics/wheel/computers/abcu_status", 0, false, true, false)
Wheel_status_TPIU   = createGlobalPropertyi("a321neo/dynamics/wheel/computers/tpiu_status", 0, false, true, false)
Wheel_brake_L       = globalProperty("sim/cockpit2/controls/left_brake_ratio")
Wheel_brake_R       = globalProperty("sim/cockpit2/controls/right_brake_ratio")
Wheel_skidding_C    = createGlobalPropertyf("a321neo/dynamics/wheel/tire_skid_C", 0, false, true, false)
Wheel_skidding_L    = createGlobalPropertyf("a321neo/dynamics/wheel/tire_skid_L", 0, false, true, false)
Wheel_skidding_R    = createGlobalPropertyf("a321neo/dynamics/wheel/tire_skid_R", 0, false, true, false)

Wheel_skid_speed_C  = globalProperty("sim/flightmodel2/gear/tire_skid_speed_mtr_sec[0]")
Wheel_skid_speed_L  = globalProperty("sim/flightmodel2/gear/tire_skid_speed_mtr_sec[1]")
Wheel_skid_speed_R  = globalProperty("sim/flightmodel2/gear/tire_skid_speed_mtr_sec[2]")

Wheel_autobrake_status= createGlobalPropertyi("a321neo/dynamics/wheel/autobrake_status", 0, false, true, false)   -- 0: OFF, 1: LOW, 2: MID, 3: MAX
Wheel_autobrake_braking=createGlobalPropertyf("a321neo/dynamics/wheel/autobrake_braking", 0, false, true, false)

Wheel_better_pushback = createGlobalPropertyi("model/controls/park_break", 0, false, true, false) -- A dataref for Better Pushback plugin
Wheel_better_pushback_connected = createGlobalPropertyi("bp/connected", 0, false, true, true) -- A dataref for Better Pushback plugin

--engines
Engine_option = createGlobalPropertyi("a321neo/customization/engine_option", 0, false, true, false) --0 CFM LEAP, 1 PW1000G
PW_engine_enabled = createGlobalPropertyi("a321neo/customization/pw_engine_enabled", 0, false, true, false)
Leap_engien_option = createGlobalPropertyi("a321neo/customization/leap_engine_enabled", 0, false, true, false)
--aircond
Cockpit_temp_req = createGlobalPropertyf("a321neo/dynamics/aircond/cockpit_temp_req", 21, false, true, false) --requested cockpit temperature
Front_cab_temp_req = createGlobalPropertyf("a321neo/dynamics/aircond/front_cab_temp_req", 21, false, true, false) --requested front cabin temperature
Aft_cab_temp_req = createGlobalPropertyf("a321neo/dynamics/aircond/aft_cab_temp_req", 21, false, true, false) --requested aft cabin temperature
Aft_cargo_temp_req = createGlobalPropertyf("a321neo/dynamics/aircond/aft_cargo_temp_req", 17, false, true, false) ---requested aft cargo temperature
Cockpit_temp = createGlobalPropertyf("a321neo/dynamics/aircond/cockpit_temp", 15, false, true, false) --actual cockpit temperature
Front_cab_temp = createGlobalPropertyf("a321neo/dynamics/aircond/front_cab_temp", 15, false, true, false) --actual front cabin temperature
Aft_cab_temp = createGlobalPropertyf("a321neo/dynamics/aircond/aft_cab_temp", 15, false, true, false) --actual aft cabin temperature
Aft_cargo_temp = createGlobalPropertyf("a321neo/dynamics/aircond/aft_cargo_temp", 17, false, true, false) ---requested aft cargo temperature
Aircond_injected_flow_temp = createGlobalPropertyfa("a321neo/dynamics/aircond/injected_flow_temp", 4)
Aircond_trim_valve = createGlobalPropertyfa("a321neo/dynamics/aircond/trim_valve", 4)
Aircond_mixer_temp = createGlobalPropertyf("a321neo/dynamics/aircond/mixer_temp", 0, false, true, false)

Ventilation_blower_override  = createGlobalPropertyi("a321neo/dynamics/aircond/vent_blower_override", 0, false, true, false)  -- 0 normal, 1 override
Ventilation_extract_override = createGlobalPropertyi("a321neo/dynamics/aircond/vent_extract_override", 0, false, true, false) -- 0 normal, 1 override
Ventilation_blower_running  = createGlobalPropertyi("a321neo/dynamics/aircond/vent_blower_running", 0, false, true, false)  -- 0 OFF, 1 ON
Ventilation_extract_running = createGlobalPropertyi("a321neo/dynamics/aircond/vent_extract_running", 0, false, true, false) -- 0 OFF, 1 ON
Ventilation_avio_inlet_valve = createGlobalPropertyf("a321neo/dynamics/aircond/avio_inlet_valve", 1, false, true, false)    -- 0 closed, 10 full open
Ventilation_avio_outlet_valve = createGlobalPropertyf("a321neo/dynamics/aircond/avio_outlet_valve", 0, false, true, false)  -- 0 closed, 10 full open

--PACKS
L_Eng_LP_press = createGlobalPropertyi("a321neo/dynamics/packs/l_eng_press", 0, false, true, false)
R_Eng_LP_press = createGlobalPropertyi("a321neo/dynamics/packs/r_eng_press", 0, false, true, false)

L_pack_Flow = createGlobalPropertyi("a321neo/dynamics/packs/l_pack_flow", 0, false, true, false) --0 no flow, 1 low, 2norm, 3high
R_pack_Flow = createGlobalPropertyi("a321neo/dynamics/packs/r_pack_flow", 0, false, true, false) --0 no flow, 1 low, 2norm, 3high
L_pack_Flow_value = createGlobalPropertyf("a321neo/dynamics/packs/l_pack_flow_value", 0, false, true, false) -- In kg/s
R_pack_Flow_value = createGlobalPropertyf("a321neo/dynamics/packs/r_pack_flow_value", 0, false, true, false) -- In kg/s
L_HP_valve = createGlobalPropertyi("a321neo/dynamics/packs/l_hp_valve", 0, false, true, false)
R_HP_valve = createGlobalPropertyi("a321neo/dynamics/packs/r_hp_valve", 0, false, true, false)
X_bleed_valve = createGlobalPropertyi("a321neo/dynamics/packs/x_bleed_valve", 0, false, true, false) --0closed, 1open
X_bleed_bridge_state = createGlobalPropertyi("a321neo/dynamics/packs/x_bleed_bridge_state", 0, false, true, false) --0closed, 1bridged clsoed, 2bridged open
L_bleed_press = createGlobalPropertyf("a321neo/dynamics/packs/l_bleed_press_psi", 0, false, true, false)
R_bleed_press = createGlobalPropertyf("a321neo/dynamics/packs/r_bleed_press_psi", 0, false, true, false)
L_bleed_temp = createGlobalPropertyf("a321neo/dynamics/packs/l_bleed_temp", 10, false, true, false)
R_bleed_temp = createGlobalPropertyf("a321neo/dynamics/packs/r_bleed_temp", 10, false, true, false)
L_compressor_temp = createGlobalPropertyf("a321neo/dynamics/packs/l_compressor_temp", 10, false, true, false)
R_compressor_temp = createGlobalPropertyf("a321neo/dynamics/packs/r_compressor_temp", 10, false, true, false)
L_pack_temp = createGlobalPropertyf("a321neo/dynamics/packs/l_pack_temp", 10, false, true, false)
R_pack_temp = createGlobalPropertyf("a321neo/dynamics/packs/r_pack_temp", 10, false, true, false)
L_pack_byp_valve = createGlobalPropertyf("a321neo/dynamics/packs/l_pack_byp_valve", 0.2, false, true, false) -- Bypass valve to control temperature
R_pack_byp_valve = createGlobalPropertyf("a321neo/dynamics/packs/r_pack_byp_valve", 0.2, false, true, false) -- Bypass valve to control temperature
GAS_bleed_avail = createGlobalPropertyf("a321neo/dynamics/packs/ground_air_supply", 0, false, true, false)
Emer_ram_air = createGlobalPropertyf("a321neo/dynamics/packs/emer_ram_air", 0, false, true, false)
Cargo_isol_in_valve = createGlobalPropertyi("a321neo/dynamics/packs/cargo_isol_in_valve", 0, false, true, false)
Cargo_isol_out_valve = createGlobalPropertyi("a321neo/dynamics/packs/cargo_isol_out_valve", 0, false, true, false)
Hot_air_valve_pos = createGlobalPropertyi("a321neo/dynamics/packs/cabin_hot_air_pos", 0, false, true, false)    -- 0: closed, 1: open
Hot_air_valve_pos_cargo = createGlobalPropertyi("a321neo/dynamics/packs/cargo_hot_air_pos", 0, false, true, false)    -- 0: closed, 1: open
Hot_air_temp       = createGlobalPropertyf("a321neo/dynamics/packs/cabin_hot_air_temp", 0, false, true, false)
Hot_air_temp_cargo = createGlobalPropertyf("a321neo/dynamics/packs/cargo_hot_air_temp", 0, false, true, false)
Cab_fan_fwd_running= createGlobalPropertyi("a321neo/dynamics/packs/cabin_fan_fwd", 0, false, true, false)   -- 1 running, 0 not running
Cab_fan_aft_running= createGlobalPropertyi("a321neo/dynamics/packs/cabin_fan_aft", 0, false, true, false)    -- 1 running, 0 not running

--apu
Apu_master_button_state = createGlobalPropertyi("a321neo/dynamics/engines/apu/state", 0, false, true, false)-- master off 0, master on 1 (do not use for button light)
Apu_start_position = globalProperty("sim/cockpit2/electrical/APU_starter_switch") --apu start button state 0: off, 1: on, 2: avail
Apu_avail = createGlobalPropertyi("a321neo/engine/apu_avil", 0, false, true, false)
Apu_bleed_psi = createGlobalPropertyf("a321neo/cockpit/apu/bleed_psi", 0, false, true, false)
Apu_fuel_valve  = createGlobalPropertyi("a321neo/cockpit/apu/fuel_valve", 0, false, true, false) -- 0 closed, 1 open
Apu_fuel_source = createGlobalPropertyi("a321neo/cockpit/apu/fuel_source", 0, false, true, false) -- 0 none, 1 left side, 2 right side (x feed)

--FBW
FBW_status = createGlobalPropertyi("a321neo/dynamics/FBW/FBW_status", 2, false, true, false)--2=NORMAL law, 1=ALT2 law, 0==DIRECT law
FBW_pitch_mode = createGlobalPropertyi("a321neo/dynamics/FBW/FBW_pitch_mode", 2, false, true, false)--0=holding pitch(stable), 1=holding vpath(unstable) 2=holding persec vpath(more stable) 3=holding 1G(most accurate)
FBW_ground_mode = createGlobalPropertyi("a321neo/dynamics/FBW/in_ground_mode", 0, false, true, false)--if the aircraft is on ground and FBW is in normal law
FBW_flare_mode = createGlobalPropertyi("a321neo/dynamics/FBW/in_flare_mode", 0, false, true, false)--if the aircraft is in flare mode
FBW_flaring = createGlobalPropertyi("a321neo/dynamics/FBW/in_flaring", 0, false, true, false)--if the FBW is synthesising a flare
Roll_l_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_l_lim", 0, false, true, false)
Roll_r_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_r_lim", 0, false, true, false)
Pitch_u_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_u_lim", 0, false, true, false)
Pitch_d_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_d_lim", 0, false, true, false)
AOA_lim = createGlobalPropertyf("a321neo/dynamics/FBW/AOA_lim", 0, false, true, false)
MAX_spd_lim = createGlobalPropertyf("a321neo/dynamics/FBW/MAX_spd_lim", 0, false, true, false)
Roll_rate_command = createGlobalPropertyf("a321neo/dynamics/FBW/roll_rate_command", 0, false, true, false)--15 degrees max for normal law, 30 degrees in ALT2 or DIRECT
Roll_rate_output = createGlobalPropertyf("a321neo/dynamics/FBW/roll_rate_output", 0, false, true, false)
G_load_command = createGlobalPropertyf("a321neo/dynamics/FBW/G_load_command", 1, false, true, false)--2.5G to -1G in normal flight, with flaps 2G to 0G
Neutral_G_output = createGlobalPropertyf("a321neo/dynamics/FBW/1_G_output", 0, false, true, false)
G_output = createGlobalPropertyf("a321neo/dynamics/FBW/G_output", 0, false, true, false)
Vpath_output = createGlobalPropertyf("a321neo/dynamics/FBW/vpath_output", 0, false, true, false)
Abs_pitch_rate = createGlobalPropertyf("a321neo/dynamics/FBW/abs_Q", 0, false, true, false)
Abs_vpath_pitch_rate = createGlobalPropertyf("a321neo/dynamics/FBW/abs_vpath_Q", 0, false, true, false)

-- Electrical system
--- BUSES (0: not providing elec power, 1: providing elec power) - influenced by switches, faults, engine status etc.
Gally_pwrd      = createGlobalPropertyi("a321neo/dynamics/electrical/bus/galley_powered", 0, false, true, false)
HOT_bus_1_pwrd  = createGlobalPropertyi("a321neo/dynamics/electrical/bus/hot_1_powered", 0, false, true, false)
HOT_bus_2_pwrd  = createGlobalPropertyi("a321neo/dynamics/electrical/bus/hot_2_powered", 0, false, true, false)
DC_ess_bus_pwrd = createGlobalPropertyi("a321neo/dynamics/electrical/bus/dc_ess_powered", 0, false, true, false)
DC_shed_ess_pwrd= createGlobalPropertyi("a321neo/dynamics/electrical/bus/dc_ess_shed_powered", 0, false, true, false)
DC_bat_bus_pwrd = createGlobalPropertyi("a321neo/dynamics/electrical/bus/dc_bat_powered", 0, false, true, false)
DC_bus_1_pwrd   = createGlobalPropertyi("a321neo/dynamics/electrical/bus/dc_1_powered", 0, false, true, false)
DC_bus_2_pwrd   = createGlobalPropertyi("a321neo/dynamics/electrical/bus/dc_2_powered", 0, false, true, false)
AC_ess_bus_pwrd = createGlobalPropertyi("a321neo/dynamics/electrical/bus/ac_ess_powered", 0, false, true, false)
AC_ess_shed_pwrd= createGlobalPropertyi("a321neo/dynamics/electrical/bus/ac_ess_shed_powered", 0, false, true, false)
AC_bus_1_pwrd   = createGlobalPropertyi("a321neo/dynamics/electrical/bus/ac_1_powered", 0, false, true, false)
AC_bus_2_pwrd   = createGlobalPropertyi("a321neo/dynamics/electrical/bus/ac_2_powered", 0, false, true, false)
AC_STAT_INV_pwrd= createGlobalPropertyi("a321neo/dynamics/electrical/bus/ac_stat_inv", 0, false, true, false) -- This is powered on ground when stat. inverter is active

OVHR_elec_panel_pwrd = createGlobalPropertyi("a321neo/dynamics/electrical/ovhr_elec_panel_powered", 0, false, true, false) -- Is the elec overhead panel powered for buttons' lights?

--- TRS/INV (0: not working, 1: working) - influenced by switches, faults, etc.
TR_ESS_online = createGlobalPropertyi("a321neo/dynamics/electrical/trs/tr_ess_online", 0, false, true, false)
TR_1_online   = createGlobalPropertyi("a321neo/dynamics/electrical/trs/tr_1_online", 0, false, true, false)
TR_2_online   = createGlobalPropertyi("a321neo/dynamics/electrical/trs/tr_2_online", 0, false, true, false)
INV_online   = createGlobalPropertyi("a321neo/dynamics/electrical/trs/INV_online", 0, false, true, false)

--- ELEC sources (0: not providing elec power, 1: providing elec power) - influenced by switches, faults, etc.
Gen_1_pwr  = createGlobalPropertyi("a321neo/dynamics/electrical/sources/gen_1_pwr", 0, false, true, false)
Gen_2_pwr  = createGlobalPropertyi("a321neo/dynamics/electrical/sources/gen_2_pwr", 0, false, true, false)
Gen_APU_pwr = createGlobalPropertyi("a321neo/dynamics/electrical/sources/gen_APU_pwr", 0, false, true, false) -- See also Apu_gen_state
Gen_EXT_pwr = createGlobalPropertyi("a321neo/dynamics/electrical/sources/gen_EXT_pwr", 0, false, true, false)
Gen_EMER_pwr = createGlobalPropertyi("a321neo/dynamics/electrical/sources/gen_EMER_pwr", 0, false, true, false)
Gen_1_line_active = createGlobalPropertyi("a321neo/dynamics/electrical/gen_1_line_active", 0, false, true, false)   -- GEN 1 Line has been pressed, 0 normal

Gen_TEST_pressed= createGlobalPropertyi("a321neo/dynamics/electrical/gen_test_pressed", 0, false, true, false)

IDG_1_temp = createGlobalPropertyf("a321neo/dynamics/electrical/IDG_1_temp", 0, false, true, false)
IDG_2_temp = createGlobalPropertyf("a321neo/dynamics/electrical/IDG_2_temp", 0, false, true, false)

Adirs_total_time_to_align = createGlobalPropertyf("a321neo/cockpit/ADIRS/total_time", 0, false, true, false)  -- Total time (depending on latitude, to align the IRS)

GPS_1_is_available = createGlobalPropertyi("a321neo/cockpit/ADIRS/gps_1_is_available", 0, false, true, false) 
GPS_2_is_available = createGlobalPropertyi("a321neo/cockpit/ADIRS/gps_2_is_available", 0, false, true, false) 

--doors
Door_1_l_ratio = createGlobalPropertyf("a321neo/dynamics/door/door_1_l_rat", 0, false, true, false)
Door_1_r_ratio = createGlobalPropertyf("a321neo/dynamics/door/door_1_r_rat", 0, false, true, false)
Door_2_l_ratio = createGlobalPropertyf("a321neo/dynamics/door/door_2_l_rat", 0, false, true, false)
Door_2_r_ratio = createGlobalPropertyf("a321neo/dynamics/door/door_2_r_rat", 0, false, true, false)
Door_3_l_ratio = createGlobalPropertyf("a321neo/dynamics/door/door_3_l_rat", 0, false, true, false)
Door_3_r_ratio = createGlobalPropertyf("a321neo/dynamics/door/door_3_r_rat", 0, false, true, false)
Overwing_exit_1_l_ratio = createGlobalPropertyf("a321neo/dynamics/door/overwing_exit_1_l_rat", 0, false, true, false)
Overwing_exit_1_r_ratio = createGlobalPropertyf("a321neo/dynamics/door/overwing_exit_1_r_rat", 0, false, true, false)
Overwing_exit_2_l_ratio = createGlobalPropertyf("a321neo/dynamics/door/overwing_exit_2_l_rat", 0, false, true, false)
Overwing_exit_2_r_ratio = createGlobalPropertyf("a321neo/dynamics/door/overwing_exit_2_r_rat", 0, false, true, false)
Cargo_1_ratio = createGlobalPropertyf("a321neo/dynamics/door/cargo_1_rat", 0, false, true, false)
Cargo_2_ratio = createGlobalPropertyf("a321neo/dynamics/door/cargo_2_rat", 0, false, true, false)

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
EWD_box_adv         = createGlobalPropertyi("a321neo/cockpit/EWD/box_adv", 0, false, true, false) -- Advisory box: 1 displayed, 0 hidden
EWD_box_sts         = createGlobalPropertyi("a321neo/cockpit/EWD/box_sts", 0, false, true, false) -- STS box: 1 displayed, 0 hidden
EWD_arrow_overflow  = createGlobalPropertyi("a321neo/cockpit/EWD/arrow_overflow", 0, false, true, false) -- Overflow arrow: 1 displayed, 0 hidden
TO_Config_is_ready  = createGlobalPropertyi("a321neo/cockpit/EWD/to_config_ready", 0, false, true, false) -- TO Config: 1 executed OK, 0 not executed or error
TO_Config_is_pressed= createGlobalPropertyi("a321neo/cockpit/EWD/to_config_pressed", 0, false, true, false) -- TO Config: 1 pressed, 0 not pressed
EWD_show_normal     = createGlobalPropertyi("a321neo/cockpit/EWD/show_normal_msg", 0, false, true, false) -- Time value to trigger "NORMAL" message on EWD (set this to get(TIME) to show the message)
EWD_is_clerable     = createGlobalPropertyi("a321neo/cockpit/EWD/is_clearable", 0, false, true, false) -- used when a message is clearable but do not show a ECAM page

-- ECAM
Ecam_is_sts_clearable = createGlobalPropertyi("a321neo/cockpit/ecam/is_sts_clearable", 0, false, true, false) -- 0: NO, 1: YES, this is used to decide whether CLR clear the EDW or the STS page
Ecam_EDW_requested_page = createGlobalPropertyi("a321neo/cockpit/ecam/edw_requested_page", 0, false, true, false) -- Page requested by EDW (can be overriden by pilot action)
Ecam_current_status = createGlobalPropertyi("a321neo/cockpit/ecam/internal_status", 0, false, true, false) -- Internal status for ECAM, please check ECAM-automation.lua for values
Ecam_sts_scroll_page = createGlobalPropertyi("a321neo/cockpit/ecam/sts_scroll_page", 0, false, true, false) --Current scroll page for STS, 0 is the first page
Ecam_arrow_overflow = createGlobalPropertyi("a321neo/cockpit/ecam/arrow_overflow", 0, false, true, false) -- Overflow arrow: 1 displayed, 0 hidden
Ecam_status_is_normal = createGlobalPropertyi("a321neo/cockpit/ecam/is_normal", 0, false, true, false) -- 1 if NORMAL showed (used for logic purposes)

Ecam_advisory_ENG   = createGlobalPropertyi("a321neo/cockpit/ecam/adv/eng", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_BLEED = createGlobalPropertyi("a321neo/cockpit/ecam/adv/bleed", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_PRESS = createGlobalPropertyi("a321neo/cockpit/ecam/adv/press", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_ELEC  = createGlobalPropertyi("a321neo/cockpit/ecam/adv/elec", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_HYD   = createGlobalPropertyi("a321neo/cockpit/ecam/adv/hyd", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_FUEL  = createGlobalPropertyi("a321neo/cockpit/ecam/adv/fuel", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_APU   = createGlobalPropertyi("a321neo/cockpit/ecam/adv/apu", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_COND  = createGlobalPropertyi("a321neo/cockpit/ecam/adv/cond", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_DOOR  = createGlobalPropertyi("a321neo/cockpit/ecam/adv/door", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_WHEEL = createGlobalPropertyi("a321neo/cockpit/ecam/adv/wheel", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)
Ecam_advisory_FCTL  = createGlobalPropertyi("a321neo/cockpit/ecam/adv/fctl", 0, false, true, false) -- Set to 1 to trigger advisory (auto-cleared)

DMC_requiring_ECAM_EWD_swap = createGlobalPropertyi("a321neo/cockpit/ecam/ewd_ecam_swap", 0, false, true, false) 

--global dataref variable from the Sim--
--camera
Head_x = globalProperty("sim/graphics/view/pilots_head_x")
Head_y = globalProperty("sim/graphics/view/pilots_head_y")
Head_z = globalProperty("sim/graphics/view/pilots_head_z")
Head_phi = globalProperty("sim/graphics/view/pilots_head_phi")--roll
Head_psi = globalProperty("sim/graphics/view/pilots_head_psi")--yaw
Head_the = globalProperty("sim/graphics/view/pilots_head_the")--pitch
--autopilot
Flight_director_1_mode = globalProperty("sim/cockpit2/autopilot/flight_director_mode")
Flight_director_2_mode = globalProperty("sim/cockpit2/autopilot/flight_director2_mode")

--electrical system
XP_Battery_1 = globalProperty("sim/cockpit2/electrical/battery_on[0]")
XP_Battery_2 = globalProperty("sim/cockpit2/electrical/battery_on[1]")
--fuel
Fuel_pump_1 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[0]")
Fuel_pump_2 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[1]")
Fuel_pump_3 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[2]")
Fuel_pump_4 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[3]")
Fuel_pump_5 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[4]")
Fuel_pump_6 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[5]")
Fuel_pump_7 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[6]")
Fuel_pump_8 = globalProperty("sim/cockpit2/engine/actuators/fuel_pump_on[7]")
--ENG
Engine_1_avail = createGlobalPropertyi("a321neo/dynamics/engines/eng_1_avail", 0, false, true, false)
Engine_2_avail = createGlobalPropertyi("a321neo/dynamics/engines/eng_2_avail", 0, false, true, false)
Eng_1_N1 = globalProperty("sim/flightmodel2/engines/N1_percent[0]")
Eng_2_N1 = globalProperty("sim/flightmodel2/engines/N1_percent[1]")
Eng_1_N2 = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_n2", 0, false, true, false) -- Corrected value for N2
Eng_2_N2 = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_n2", 0, false, true, false) -- Corrected value for N2
Eng_1_EGT_c = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_EGT", 0, false, true, false)
Eng_2_EGT_c = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_EGT", 0, false, true, false)
Eng_1_FF_kgs = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_FF", 0, false, true, false)
Eng_2_FF_kgs = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_FF", 0, false, true, false)
Eng_1_OIL_qty = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_oil_qty", 0, false, true, false)
Eng_2_OIL_qty = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_oil_qty", 0, false, true, false)
Eng_1_OIL_press = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_oil_press", 0, false, true, false)
Eng_2_OIL_press = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_oil_press", 0, false, true, false)
Eng_1_OIL_temp  = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_oil_temp", 0, false, true, false) -- In Celsius
Eng_2_OIL_temp  = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_oil_temp", 0, false, true, false) -- In Celsius
Eng_1_VIB_N1  = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_vib_n1", 0, false, true, false)
Eng_2_VIB_N1  = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_vib_n1", 0, false, true, false)
Eng_1_VIB_N2  = createGlobalPropertyf("a321neo/dynamics/engines/eng_1_vib_n2", 0, false, true, false)
Eng_2_VIB_N2  = createGlobalPropertyf("a321neo/dynamics/engines/eng_2_vib_n2", 0, false, true, false)

Eng_N1_idle = createGlobalPropertyf("a321neo/dynamics/engines/n1_idle", 1, false, true, false) -- current value (depends on altitude) for the minimum N1
Eng_Dual_Cooling = createGlobalPropertyf("a321neo/dynamics/engines/dual_cooling", 0, false, true, false) -- Is dual cooling on?
Eng_Continuous_Ignition = createGlobalPropertyf("a321neo/dynamics/engines/continuous_ignition", 0, false, true, false) -- Is continuous ignition active?

Eng_N1_mode = createGlobalPropertyi("a321neo/dynamics/engines/n1_mode", 0, false, true, false) -- 0: not visible, 1: TOGA, 2:MCT, 3:CLB, 4: IDLE, 5: MREV, 6: FLEX, 7: SOFT GA
Eng_N1_flex_temp = createGlobalPropertyf("a321neo/dynamics/engines/n1_flex_temp", 0, false, true, false)

Eng_N1_max              = createGlobalPropertyf("a321neo/dynamics/engines/n1_max", 0, false, true, false) -- Current max
Eng_N1_max_detent_toga  = createGlobalPropertyf("a321neo/dynamics/engines/n1_max_toga", 0, false, true, false) -- TOGA
Eng_N1_max_detent_mct   = createGlobalPropertyf("a321neo/dynamics/engines/n1_max_mcl", 0, false, true, false)  -- MCL/FLEX/SGA
Eng_N1_max_detent_clb   = createGlobalPropertyf("a321neo/dynamics/engines/n1_max_clb", 0, false, true, false)  -- CLB


Eng_1_reverser_deployment = globalProperty("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[0]")
Eng_2_reverser_deployment = globalProperty("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[1]")
Eng_1_Firewall_valve = createGlobalPropertyi("a321neo/dynamics/engines/eng_1_firewall_valve_1", 1, false, true, false) -- 0 open, 1 - closed, 2 : transit - firewall valve
Eng_2_Firewall_valve = createGlobalPropertyi("a321neo/dynamics/engines/eng_2_firewall_valve_2", 1, false, true, false) -- 0 open, 1 - closed, 2 : transit - firewall valve

Eng_is_spooling_up  = createGlobalPropertyia("a321neo/dynamics/engines/is_spooling_up", 2)

-- APU
Apu_N1 = globalProperty("sim/cockpit2/electrical/APU_N1_percent")
APU_EGT = createGlobalPropertyf("a321neo/cockpit/apu/EGT", 0, false, true, false)
APU_flap = createGlobalPropertyi("a321neo/cockpit/apu/flap_open", 0, false, true, false)

--PACKs system
Apu_bleed_xplane = globalProperty("sim/cockpit2/bleedair/actuators/apu_bleed")
Gpu_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/gpu_bleed")
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
Cabin_delta_psi = createGlobalPropertyf("a321neo/dynamics/pressurization/delta_psi", 0, false, true, false)
Cabin_alt_ft = globalProperty("sim/cockpit2/pressurization/actuators/cabin_altitude_ft")
Cabin_vs = globalProperty("sim/cockpit2/pressurization/actuators/cabin_vvi_fpm")
Out_flow_valve_ratio = globalProperty("sim/cockpit2/pressurization/indicators/outflow_valve")
Weather_curr_press_sea_level = globalProperty("sim/weather/barometer_sealevel_inhg")
Weather_curr_press_flight_level = globalProperty("sim/weather/barometer_current_inhg")
Override_pressurization = globalProperty("sim/operation/override/override_pressurization")
Override_oxygen = globalProperty("sim/operation/override/override_oxygen_system")
Press_safety_valve_pos = createGlobalPropertyi("a321neo/dynamics/pressurization/safety_valve_pos", 0, false, true, false) -- 0 closed, 1 open
Press_outflow_valve_flow = createGlobalPropertyf("a321neo/dynamics/pressurization/outflow_valve_flow", 0, false, true, false)
Press_outflow_valve_press = createGlobalPropertyf("a321neo/dynamics/pressurization/outflow_valve_press", 0, false, true, false)
Oxygen_pilot_feeling = globalProperty("sim/cockpit2/oxygen/indicators/pilot_felt_altitude_ft")

-- The folloing datarefs are used for debug only
Press_controller_output_vs  = createGlobalPropertyf("a321neo/dynamics/pressurization/cabin_vs_ctr", 0, false, true, false)
Press_controller_output_ovf = createGlobalPropertyf("a321neo/dynamics/pressurization/outflow_valve_ctr", 0, false, true, false)
Press_controller_sp_vs      = createGlobalPropertyf("a321neo/dynamics/pressurization/cabin_vs_sp", 0, false, true, false)
Press_controller_sp_ovf     = createGlobalPropertyf("a321neo/dynamics/pressurization/outflow_valve_sp", 0, false, true, false)
Press_controller_last_vs    = createGlobalPropertyf("a321neo/dynamics/pressurization/cabin_vs_last_update", 0, false, true, false)
Press_controller_last_ovf   = createGlobalPropertyf("a321neo/dynamics/pressurization/outflow_valve_last_update", 0, false, true, false)
Press_mode_sel_is_man       = createGlobalPropertyf("a321neo/dynamics/pressurization/mode_sel_is_man", 0, false, true, false) -- 1: MAN 0 : AUTO

Press_ditching_enabled      = createGlobalPropertyf("a321neo/dynamics/pressurization/ditching_enabled", 0, false, true, false) 

--instruments
VVI = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
OTA = globalProperty("sim/cockpit2/temperature/outside_air_temp_degc")
TAT = globalProperty("sim/weather/temperature_le_c")
Gross_weight = globalProperty ("sim/flightmodel/weight/m_total")
Capt_ra_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
Fo_ra_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_copilot")
Capt_baro_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
IAS = globalProperty("sim/flightmodel/position/indicated_airspeed")
DH_alt_ft = globalProperty("sim/cockpit/misc/radio_altimeter_minimum")


Capt_IAS     = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")   -- Consider to use PFD_Capt_IAS instead (check cockpit_datarefs.lua)
Fo_IAS       = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_copilot") -- Consider to use PFD_Fo_IAS instead (check cockpit_datarefs.lua)
Capt_Baro_Alt= globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")    -- Consider to use PFD_Capt_Baro_Altitude instead (check cockpit_datarefs.lua)
Fo_Baro_Alt  = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_copilot")  -- Consider to use PFD_Fo_Baro_Altitude instead (check cockpit_datarefs.lua)
Capt_VVI     = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")        -- Consider to use PFD_Capt_VS instead (check cockpit_datarefs.lua)
Fo_VVI       = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_copilot")      -- Consider to use PFD_Fo_VS instead (check cockpit_datarefs.lua)
Capt_Mach    = globalProperty("sim/cockpit2/gauges/indicators/mach_pilot")
Fo_Mach      = globalProperty("sim/cockpit2/gauges/indicators/mach_copilot")
Capt_Baro    = globalProperty("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot") -- Baro settings for Pilot
Fo_Baro      = globalProperty("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot") -- Baro settings for F/O
Capt_pitch   = globalProperty("sim/cockpit2/gauges/indicators/pitch_electric_deg_pilot")
Fo_pitch     = globalProperty("sim/cockpit2/gauges/indicators/pitch_electric_deg_copilot")
Capt_bank    = globalProperty("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
Fo_bank      = globalProperty("sim/cockpit2/gauges/indicators/roll_AHARS_deg_copilot")
Capt_hdg     = globalProperty("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
Fo_hdg       = globalProperty("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_copilot")

Capt_IAS_trend = globalProperty("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot")
Fo_IAS_trend = globalProperty("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_copilot")

Stby_Alt     = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_stby")     -- Altitude in the stdby instrument
Stby_IAS     = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_stby")    -- IAS in the stdby instrument
Stby_Baro    = globalProperty("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_stby") -- Baro settings for STBY

Capt_TAS     = globalProperty("sim/cockpit2/gauges/indicators/true_airspeed_kts_pilot")
Fo_TAS       = globalProperty("sim/cockpit2/gauges/indicators/true_airspeed_kts_copilot")

Capt_Track     = globalProperty("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
Fo_Track       = globalProperty("sim/cockpit2/gauges/indicators/ground_track_mag_copilot")

Wind_SPD     = globalProperty("sim/cockpit2/gauges/indicators/wind_speed_kts")
Wind_HDG     = globalProperty("sim/cockpit2/gauges/indicators/wind_heading_deg_mag")

--gear
Gear_handle = globalProperty("sim/cockpit2/controls/gear_handle_down")
Front_gear_deployment = globalProperty("sim/flightmodel2/gear/deploy_ratio[0]")
Left_gear_deployment = globalProperty("sim/flightmodel2/gear/deploy_ratio[1]")
Right_gear_deployment = globalProperty("sim/flightmodel2/gear/deploy_ratio[2]")
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

ZULU_day   =  globalProperty("sim/cockpit2/clock_timer/current_day")
ZULU_month =  globalProperty("sim/cockpit2/clock_timer/current_month")

-- Misc
Sun_pitch  = globalProperty("sim/graphics/scenery/sun_pitch_degrees")
is_RAT_out = createGlobalPropertyi("a321neo/dynamics/is_RAT_out", 0, false, true, false)-- Is Ram Air Turbine out? 0: no, 1: yes (it does NOT mean that the generator is on)

-- ACARS & DCDU
Acars_status = createGlobalPropertyi("a321neo/dynamics/ACARS/comm_status", 0, false, true, false) -- 0 no connection, 1 - SATCOM only, 2 - VHF only, 3 - Both
Acars_incoming_message = createGlobalPropertys("a321neo/dynamics/ACARS/incoming_msg", "", false, true, false) -- Message that is currently receiving
Acars_incoming_message_type = createGlobalPropertyi("a321neo/dynamics/ACARS/incoming_msg_type", 0, false, true, false) -- Type of message that is currently receiving, 0 - no message
Acars_incoming_message_length = createGlobalPropertyi("a321neo/dynamics/ACARS/incoming_msg_len", 0, false, true, false) -- Length of the message (do not use string.len, it doesn't work)

-- HYD
Hydraulic_G_press    = createGlobalPropertyi("a321neo/dynamics/HYD/G_press", 0, false, true, false)
Hydraulic_B_press    = createGlobalPropertyi("a321neo/dynamics/HYD/B_press", 0, false, true, false)
Hydraulic_Y_press    = createGlobalPropertyi("a321neo/dynamics/HYD/Y_press", 0, false, true, false)
Hydraulic_G_qty      = createGlobalPropertyf("a321neo/dynamics/HYD/G_qty", 0, false, true, false) -- In percentage 0;1
Hydraulic_B_qty      = createGlobalPropertyf("a321neo/dynamics/HYD/B_qty", 0, false, true, false) -- In percentage 0;1
Hydraulic_Y_qty      = createGlobalPropertyf("a321neo/dynamics/HYD/Y_qty", 0, false, true, false) -- In percentage 0;1
Hydraulic_Y_elec_status = createGlobalPropertyi("a321neo/dynamics/HYD/Y_ELEC_status", 0, false, true, false) -- 0: OFF, 1: ON
Hydraulic_PTU_status = createGlobalPropertyi("a321neo/dynamics/HYD/PTU_status", 0, false, true, false) -- 0: OFF, 1: ON idle, 2: ON Y->G, 3: G->Y
Hydraulic_RAT_status = createGlobalPropertyi("a321neo/dynamics/HYD/RAT_status", 0, false, true, false) -- 0: OFF ready, 1: Running OK, 2: FAULT or low speed

--aircraft limits
Capt_VMAX_prot =   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/capt_vmax_prot_speed", 0, false, true, false)--uses different pilot's mach
Fo_VMAX_prot =	   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/fo_vmax_prot_speed", 0, false, true, false)
Capt_VMAX =		   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/capt_vmax_speed", 0, false, true, false)--uses different pilot's mach
Fo_VMAX =		   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/fo_vmax_speed", 0, false, true, false)
S_speed = 		   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/s_speed", 0, false, true, false)
F_speed = 		   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/f_speed", 0, false, true, false)
VFE_speed = 	   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/vfe_speed", 0, false, true, false)
VLS = 			   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/vls_speed", 0, false, true, false)
Capt_GD =		   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/capt_green_dot_speed", 0, false, true, false)--uses different pilot's baro alt
Fo_GD = 		   createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/fo_green_dot_speed", 0, false, true, false)
Capt_Vaprot_vsw =  createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/capt_alpha_prot_speed", 0, false, true, false)--uses different pilot's alpha
Fo_Vaprot_vsw =    createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/fo_alpha_prot_speed", 0, false, true, false)
Capt_Valpha_MAX =  createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/capt_alpha_max_speed", 0, false, true, false)--uses different pilot's alpha
Fo_Valpha_MAX =    createGlobalPropertyf("a321neo/dynamics/FBW/limit_speeds/fo_alpha_max_speed", 0, false, true, false)

Aircraft_total_weight_kgs = globalProperty("sim/flightmodel/weight/m_total")

--AUTO THRUST / FADEC--
Override_throttle = globalProperty("sim/operation/override/override_throttles")
Override_eng_1_lever = globalProperty("sim/flightmodel/engine/ENGN_thro_use[0]")
Override_eng_2_lever = globalProperty("sim/flightmodel/engine/ENGN_thro_use[1]")

--flight controls
Joystick_connected = globalProperty("sim/joystick/has_joystick")
Servo_roll = globalProperty("sim/joystick/servo_roll_ratio")
Servo_pitch = globalProperty("sim/joystick/servo_pitch_ratio")
Servo_yaw = globalProperty("sim/joystick/servo_heading_ratio")
Roll_rate = globalProperty("sim/flightmodel/position/P")
Pitch_rate = globalProperty("sim/flightmodel/position/Q")
Joystick_toe_brakes_L = globalProperty("sim/joystick/joy_mapped_axis_value[6]")
Joystick_toe_brakes_R = globalProperty("sim/joystick/joy_mapped_axis_value[7]")

--Surfaces / FBW / flight controls--
--dev & debuging
Override_artstab = globalProperty("sim/operation/override/override_artstab")
Override_control_surfaces = globalProperty("sim/operation/override/override_control_surfaces")
FBW_kill_switch = createGlobalPropertyi("a321neo/dynamics/FBW/debug/kill_switch", 1, false, true, false)
Force_full_rudder_limit = createGlobalPropertyi("a321neo/dynamics/FBW/debug/force_full_rudder_limit", 0, false, true, false)
Bypass_speedbrakes_inhibition = createGlobalPropertyi("a321neo/dynamics/FBW/debug/bypass_spdbrakes_inhibition", 0, false, true, false)
--customizations
Project_square_input = createGlobalPropertyi("a321neo/dynamics/FBW/customizations/projected_square_input", 0, false, true, false)
Trim_wheel_smoothing_on = createGlobalPropertyi("a321neo/dynamics/FBW/customizations/trim_wheel_smoothing_on", 1, false, true, false)--is the trim wheel is smoothed
--inputs--
Roll = globalProperty("sim/joystick/yoke_roll_ratio")
Pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
Yaw = globalProperty("sim/joystick/yoke_heading_ratio")
Augmented_roll = createGlobalPropertyf("a321neo/dynamics/FBW/inputs/augmented_roll", 0, false, true, false)
Augmented_pitch = createGlobalPropertyf("a321neo/dynamics/FBW/inputs/augmented_pitch", 0, false, true, false)
Speedbrake_handle_ratio = globalProperty("sim/cockpit2/controls/speedbrake_ratio")
--outputs--
Roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
Pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
Yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")
--flight envelope "sensors"
Alpha = globalProperty("sim/flightmodel/position/alpha")
Vpath = globalProperty("sim/flightmodel/position/vpath")
Flightmodel_roll = globalProperty("sim/flightmodel/position/true_phi")
Flightmodel_pitch = globalProperty("sim/flightmodel/position/true_theta")
Flightmodel_true_heading = globalProperty("sim/flightmodel/position/true_psi")
Flightmodel_mag_heading = globalProperty("sim/flightmodel/position/mag_psi")
Total_vertical_g_load = globalProperty("sim/flightmodel/forces/g_nrml")
Total_long_g_load = globalProperty("sim/flightmodel/forces/g_axil")
Vpath_pitch_rate = createGlobalPropertyf("a321neo/dynamics/FBW/aerodynamics/vpath_Q", 0, false, true, false)
True_roll_rate = createGlobalPropertyf("a321neo/dynamics/FBW/aerodynamics/true_P", 0, false, true, false)--true roll rate(in relation to the previous reference frame instead of the flight path)
True_pitch_rate = createGlobalPropertyf("a321neo/dynamics/FBW/aerodynamics/true_Q", 0, false, true, false)--true pitch rate(in relation to the previous reference frame instead of the flight path)
Slide_slip_angle = globalProperty("sim/cockpit2/gauges/indicators/sideslip_degrees")
--FBW system status--
FBW_total_control_law = createGlobalPropertyi("a321neo/dynamics/FBW/system_status/total_control_law", 0, false, true, false)   -- -2 mechanical backup law, -1 abnormal law, 0 direct law, 1 alternate law, 2 alternate law(reduced prot), 3 normal law
FBW_lateral_law =       createGlobalPropertyi("a321neo/dynamics/FBW/system_status/lateral_control_law", 0, false, true, false) -- -2 mechanical backup law,                  0 direct law,                  							   3 normal law (abnormal law / alt law doesn't exist)
FBW_vertical_law =      createGlobalPropertyi("a321neo/dynamics/FBW/system_status/vertical_control_law", 0, false, true, false)-- -2 mechanical backup law, -1 abnormal law, 0 direct law, 1 alternate law, 2 alternate law(reduced prot), 3 normal law
FBW_yaw_law =           createGlobalPropertyi("a321neo/dynamics/FBW/system_status/yaw_control_law", 0, false, true, false)     -- -2 mechanical backup law, -1 abnormal law, 0 direct law, 1 alternate law, 							   3 normal law
FBW_in_flight_mode = createGlobalPropertyi("a321neo/dynamics/FBW/system_status/in_flight_mode", 0, false, true, false)--is FBW in flight mode
FBW_in_ground_mode = createGlobalPropertyi("a321neo/dynamics/FBW/system_status/in_ground_mode", 0, false, true, false)--is FBW in ground mode
FBW_in_flare_mode =  createGlobalPropertyi("a321neo/dynamics/FBW/system_status/in_flare_mode", 0, false, true, false) --is FBW in flare mode
FBW_lateral_ground_mode_ratio =  createGlobalPropertyf("a321neo/dynamics/FBW/system_status/lateral_ground_mode_ratio", 1, false, true, false) --FBW lateral  ground mode transition ratio (5.0s of transition at takeoff/landing)
FBW_vertical_ground_mode_ratio = createGlobalPropertyf("a321neo/dynamics/FBW/system_status/vertical_ground_mode_ratio", 1, false, true, false)--FBW vertical ground mode transition ratio (0.5s of transition at takeoff/landing)
FBW_vertical_flare_mode_ratio =  createGlobalPropertyf("a321neo/dynamics/FBW/system_status/vertical_flare_mode_ratio", 0, false, true, false) --FBW vertical flare mode transition ratio  (1.0s of transition at landing)
FBW_flare_mode_memorised_att = createGlobalPropertyf("a321neo/dynamics/FBW/system_status/flare_mode_memorised_attitude", 0, false, true, false) --FBW flare mode memorised att at 50ft RA
FBW_flare_mode_computed_Q =    createGlobalPropertyf("a321neo/dynamics/FBW/system_status/flare_mode_computed_Q", 0, false, true, false) --FBW flare mode computed pitch rate 8 seconds from memorised ATT --> -2 degrees
--flight computers status
ELAC_1_status = createGlobalPropertyi("a321neo/dynamics/FBW/flight_computers/elac_1_status", 1, false, true, false)--elevator aileron computer(protection outputs)
ELAC_2_status = createGlobalPropertyi("a321neo/dynamics/FBW/flight_computers/elac_2_status", 1, false, true, false)
FAC_1_status = 	createGlobalPropertyi("a321neo/dynamics/FBW/flight_computers/fac_1_status",  1, false, true, false)--flight augmentation computer(speeds calculations)
FAC_2_status = 	createGlobalPropertyi("a321neo/dynamics/FBW/flight_computers/fac_2_status",  1, false, true, false)
SEC_1_status = 	createGlobalPropertyi("a321neo/dynamics/FBW/flight_computers/sec_1_status",  1, false, true, false)--spolier and elevator computer
SEC_2_status = 	createGlobalPropertyi("a321neo/dynamics/FBW/flight_computers/sec_2_status",  1, false, true, false)
SEC_3_status = 	createGlobalPropertyi("a321neo/dynamics/FBW/flight_computers/sec_3_status",  1, false, true, false)
--ailerons
Left_aileron =  globalProperty("sim/flightmodel/controls/wing4l_ail1def") -- -25 deg up 25 deg down
Right_aileron = globalProperty("sim/flightmodel/controls/wing4r_ail1def") -- -25 deg up 25 deg down
--spoilers
Ground_spoilers_armed = createGlobalPropertyi("a321neo/dynamics/FBW/controls/ground_spoilers_armed", 0, false, true, false)--mostly used for animation but 0 is disarmed 1 is armed
Ground_spoilers_mode = createGlobalPropertyi("a321neo/dynamics/FBW/controls/ground_spoilers_mode", 0, false, true, false)--0 retracted, 1 half deployed, 2 full extention
Ground_spoilers_act_method = createGlobalPropertyi("a321neo/dynamics/FBW/controls/ground_spoilers_activation_method", 0, false, true, false)--0 no action, 1 unarmed activation, 2 armed activation
Speedbrakes_inhibited = createGlobalPropertyi("a321neo/dynamics/FBW/control_limitations/speedbrakes_inhibited", 0, false, true, false)--if the speedbrakes are inhibited, reset the lever to restore to 0
Speedbrakes_ratio = globalProperty("sim/flightmodel2/controls/speedbrake_ratio")--used to enable the rotation of spoiler 2 & 3 feed the sum of sidestick input & speedbrake handle in
Left_spoiler_1 =  globalProperty("sim/flightmodel/controls/wing2l_spo1def")
Left_spoiler_2 =  globalProperty("sim/flightmodel2/wing/speedbrake1_deg[4]")
Left_spoiler_3 =  globalProperty("sim/flightmodel2/wing/speedbrake2_deg[4]")
Left_spoiler_4 =  globalProperty("sim/flightmodel/controls/wing3l_spo1def")
Left_spoiler_5 =  globalProperty("sim/flightmodel/controls/wing3l_spo2def")
Right_spoiler_1 = globalProperty("sim/flightmodel/controls/wing2r_spo1def")
Right_spoiler_2 = globalProperty("sim/flightmodel2/wing/speedbrake1_deg[5]")
Right_spoiler_3 = globalProperty("sim/flightmodel2/wing/speedbrake2_deg[5]")
Right_spoiler_4 = globalProperty("sim/flightmodel/controls/wing3r_spo1def")
Right_spoiler_5 = globalProperty("sim/flightmodel/controls/wing3r_spo2def")
--high lift devices
Flaps_handle_ratio = 	globalProperty("sim/cockpit2/controls/flap_ratio")
Flaps_handle_position = createGlobalPropertyf("a321neo/dynamics/surfaces/flaps_handle_position", 0, false, true, false)--0, 1, 2, 3, full
Flaps_internal_config = createGlobalPropertyf("a321neo/dynamics/surfaces/flaps_internal_config", 0, false, true, false)--0 = clean, 1 = 1, 2 = 1+f, 3 = 2, 4 = 3, 5 = full
Slats_predeploy_ratio = createGlobalPropertyf("a321neo/dynamics/surfaces/slats_pre_deploy_ratio") -- 0 --> 1
Slats =                 globalProperty("sim/flightmodel2/controls/slat1_deploy_ratio") --deploys with flaps 0 = 0, 1 = 0.7, 2 = 0.8, 3 = 0.8, 4 = 1
Left_outboard_flaps =   globalProperty("sim/flightmodel/controls/wing3l_fla2def") -- flap detents 0 = 0, 1 = 10, 2 = 14, 3 = 21, 4 = 25
Left_inboard_flaps =    globalProperty("sim/flightmodel/controls/wing2l_fla1def")
Right_inboard_flaps =   globalProperty("sim/flightmodel/controls/wing2r_fla1def")
Right_outboard_flaps =  globalProperty("sim/flightmodel/controls/wing3r_fla2def")
SFCC_1_status = 	    createGlobalPropertyi("a321neo/dynamics/FBW/slats_and_flaps/sfcc_1_status", 1, false, true, false)--slats flaps control computer 1
SFCC_2_status = 	    createGlobalPropertyi("a321neo/dynamics/FBW/slats_and_flaps/sfcc_2_status", 1, false, true, false)--slats flaps control computer 2
Slats_ecam_amber = 	    createGlobalPropertyi("a321neo/dynamics/FBW/slats_and_flaps/slats_ecam_amber", 0, false, true, false)--slats indication on the ecam is amber
Slats_in_transit = 	    createGlobalPropertyi("a321neo/dynamics/FBW/slats_and_flaps/slats_in_transit", 0, false, true, false)--slats moving
Flaps_ecam_amber = 	    createGlobalPropertyi("a321neo/dynamics/FBW/slats_and_flaps/flaps_ecam_amber", 0, false, true, false)--flaps indication on the ecam is amber
Flaps_in_transit = 	    createGlobalPropertyi("a321neo/dynamics/FBW/slats_and_flaps/flaps_in_transit", 0, false, true, false)--flaps moving
Flaps_deployed_ratio =  createGlobalPropertyf("a321neo/dynamics/FBW/slats_and_flaps/flaps_deployed_ratio", 0, false, true, false)--0, 0, 10, 14, 21, 25
Flaps_deployed_angle =  createGlobalPropertyf("a321neo/dynamics/FBW/slats_and_flaps/flaps_deployed_angle", 0, false, true, false)--0, 0, 10, 14, 21, 25
--hstabs
Human_pitch_trim = createGlobalPropertyi("a321neo/dynamics/FBW/controls/human_pitch_trim", 0, false, true, false)-- 1 trim up, 0 no action, -1 trim down
Augmented_pitch_trim_ratio = createGlobalPropertyf("a321neo/dynamics/FBW/controls/augmented_pitch_trim_ratio", 0, false, true, false)
Horizontal_stabilizer_deflection = globalProperty("sim/flightmodel2/controls/stabilizer_deflection_degrees")
Elev_trim_ratio = globalProperty("sim/flightmodel2/controls/elevator_trim")
Max_THS_up = globalProperty("sim/aircraft/controls/acf_hstb_trim_up")--11 deggrees
Max_THS_dn = globalProperty("sim/aircraft/controls/acf_hstb_trim_dn")--3.5 degrees
Elevators_hstab_1 = globalProperty("sim/flightmodel/controls/hstab1_elv1def") --elevators 17 deg down -30 deg up
Elevators_hstab_2 = globalProperty("sim/flightmodel/controls/hstab2_elv1def") --elevators 17 deg down -30 deg up
--vstabs
Human_rudder_trim = createGlobalPropertyi("a321neo/dynamics/FBW/controls/human_rudder_trim", 0, false, true, false)-- -1 trim left, 0 no action, 1 trim right
Rudder_trim_angle = createGlobalPropertyf("a321neo/dynamics/FBW/controls/rudder_trim_angle", 0, false, true, false)-- left -20 degrees, right 20 degrees
Resetting_rudder_trim = createGlobalPropertyi("a321neo/dynamics/FBW/controls/resetting_rudder_trim", 0, false, true, false)-- 0 no action, 1 resetting
Augmented_rudder_angle = createGlobalPropertyf("a321neo/dynamics/FBW/controls/augmented_rudder_angle", 0, false, true, false)--the angle of deviation from the position of the rudder trim angle
Rudder = globalProperty("sim/flightmodel/controls/vstab1_rud1def")--rudder 30 deg left -30 deg right
Rudder_travel_lim = createGlobalPropertyf("a321neo/dynamics/FBW/control_limitations/rudder_travel_limit", 25, false, true, false)--25 degrees in augmented mode, 30 degrees in mechanical mode
--surface availablility
L_aileron_avail =   createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/l_aileron_avail", 1, false, true, false)
R_aileron_avail =   createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/r_aileron_avail", 1, false, true, false)
L_spoiler_1_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/l_spoiler_1_avail", 1, false, true, false)
L_spoiler_2_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/l_spoiler_2_avail", 1, false, true, false)
L_spoiler_3_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/l_spoiler_3_avail", 1, false, true, false)
L_spoiler_4_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/l_spoiler_4_avail", 1, false, true, false)
L_spoiler_5_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/l_spoiler_5_avail", 1, false, true, false)
R_spoiler_1_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/r_spoiler_1_avail", 1, false, true, false)
R_spoiler_2_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/r_spoiler_2_avail", 1, false, true, false)
R_spoiler_3_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/r_spoiler_3_avail", 1, false, true, false)
R_spoiler_4_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/r_spoiler_4_avail", 1, false, true, false)
R_spoiler_5_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/r_spoiler_5_avail", 1, false, true, false)
L_elevator_avail =  createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/l_elevator_avail", 1, false, true, false)
R_elevator_avail =  createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/r_elevator_avail", 1, false, true, false)
THS_avail = 		createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/ths_avail", 1, false, true, false)
Yaw_damper_avail =  createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/yaw_damper_avail", 1, false, true, false)
Rudder_avail =  	createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/rudder_avail", 1, false, true, false)
Rudder_lim_avail =  createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/rudder_lim_avail", 1, false, true, false)
Rudder_trim_avail = createGlobalPropertyi("a321neo/dynamics/FBW/surface_availability/rudder_trim_avail", 1, false, true, false)


-- Fuel
Fuel_quantity = {}
Fuel_quantity[0] =   globalProperty("sim/flightmodel/weight/m_fuel[0]")
Fuel_quantity[1] =   globalProperty("sim/flightmodel/weight/m_fuel[1]")
Fuel_quantity[2] =   globalProperty("sim/flightmodel/weight/m_fuel[2]")
Fuel_quantity[3] =   globalProperty("sim/flightmodel/weight/m_fuel[3]")
Fuel_quantity[4] =   globalProperty("sim/flightmodel/weight/m_fuel[4]")
Fuel_pump_on = {}
Fuel_pump_on[0]  = globalProperty("sim/cockpit2/fuel/fuel_tank_pump_on[0]")
Fuel_pump_on[1]  = globalProperty("sim/cockpit2/fuel/fuel_tank_pump_on[1]")
Fuel_pump_on[2]  = globalProperty("sim/cockpit2/fuel/fuel_tank_pump_on[2]")
Fuel_pump_on[3]  = globalProperty("sim/cockpit2/fuel/fuel_tank_pump_on[3]")
Fuel_pump_on[4]  = globalProperty("sim/cockpit2/fuel/fuel_tank_pump_on[4]")

Fuel_tank_selector_eng_1 = globalProperty("sim/cockpit2/fuel/fuel_tank_selector_left")  -- 0=none,1=left,2=center,3=right,4=all
Fuel_tank_selector_eng_2 = globalProperty("sim/cockpit2/fuel/fuel_tank_selector_right") -- 0=none,1=left,2=center,3=right,4=all

Fuel_wing_L_temp = createGlobalPropertyf("a321neo/dynamics/fuel/fuel_temp_L", 0, false, true, false) -- Temperature of the fuel LEFT wing
Fuel_wing_R_temp = createGlobalPropertyf("a321neo/dynamics/fuel/fuel_temp_R", 0, false, true, false) -- Temperature of the fuel RIGHT wing

Fuel_on_takeoff = createGlobalPropertyf("a321neo/dynamics/fuel/fot", 0, false, true, false) -- Fuel on takeoff for EWD messages

Fuel_wing_L_overflow = createGlobalPropertyi("a321neo/dynamics/fuel/fuel_overflow_L", 0, false, true, false) -- 1: overflow, 0:normal
Fuel_wing_R_overflow = createGlobalPropertyi("a321neo/dynamics/fuel/fuel_overflow_R", 0, false, true, false) -- 1: overflow, 0:normal


-- Anti-ICE
AI_wing_L_operating = createGlobalPropertyi("a321neo/dynamics/anti_ice/wing_L_operating", 0, false, true, false) -- 0: pause, 1: working
AI_wing_R_operating = createGlobalPropertyi("a321neo/dynamics/anti_ice/wing_R_operating", 0, false, true, false) -- 0: pause, 1: working

-- Oxygen
Oxygen_ckpt_psi  = globalProperty("sim/cockpit2/oxygen/indicators/o2_bottle_pressure_psi")

-- GPWS
GPWS_mode_is_active  = createGlobalPropertyia("a321neo/dynamics/gpws/mode_active", 6) -- Mode from 1 to 5, 6 is the predictive GPWS
GPWS_mode_1_sinkrate = createGlobalPropertyi("a321neo/dynamics/gpws/mode_1/sinkrate", 0, false, true, false)
GPWS_mode_1_pullup   = createGlobalPropertyi("a321neo/dynamics/gpws/mode_1/pullup", 0, false, true, false)
GPWS_mode_2_mode_a   = createGlobalPropertyi("a321neo/dynamics/gpws/mode_2/mode_a", 0, false, true, false)
GPWS_mode_2_mode_b   = createGlobalPropertyi("a321neo/dynamics/gpws/mode_2/mode_b", 0, false, true, false)
GPWS_mode_2_terrterr = createGlobalPropertyi("a321neo/dynamics/gpws/mode_2/terrainterrain", 0, false, true, false)
GPWS_mode_2_pullup   = createGlobalPropertyi("a321neo/dynamics/gpws/mode_2/pullup", 0, false, true, false)
GPWS_mode_2_terr     = createGlobalPropertyi("a321neo/dynamics/gpws/mode_2/terrain", 0, false, true, false)

GPWS_mode_3_dontsink = createGlobalPropertyi("a321neo/dynamics/gpws/mode_3/dontsink", 0, false, true, false)

GPWS_mode_4_mode_a = createGlobalPropertyi("a321neo/dynamics/gpws/mode_3/mode_a", 0, false, true, false)
GPWS_mode_4_mode_b = createGlobalPropertyi("a321neo/dynamics/gpws/mode_3/mode_b", 0, false, true, false)
GPWS_mode_4_mode_c = createGlobalPropertyi("a321neo/dynamics/gpws/mode_3/mode_c", 0, false, true, false)

GPWS_mode_4_a_terrain = createGlobalPropertyi("a321neo/dynamics/gpws/mode_4/terrain_a", 0, false, true, false)
GPWS_mode_4_b_terrain = createGlobalPropertyi("a321neo/dynamics/gpws/mode_4/terrain_b", 0, false, true, false)
GPWS_mode_4_c_terrain = createGlobalPropertyi("a321neo/dynamics/gpws/mode_4/terrain_c", 0, false, true, false)
GPWS_mode_4_tl_flaps  = createGlobalPropertyi("a321neo/dynamics/gpws/mode_4/tl_flaps", 0, false, true, false)
GPWS_mode_4_tl_gear   = createGlobalPropertyi("a321neo/dynamics/gpws/mode_4/tl_gear", 0, false, true, false)

GPWS_mode_5_glideslope = createGlobalPropertyi("a321neo/dynamics/gpws/mode_5/glideslope", 0, false, true, false)
GPWS_mode_5_glideslope_hard = createGlobalPropertyi("a321neo/dynamics/gpws/mode_5/glideslope_hard", 0, false, true, false)

GPWS_mode_pitch = createGlobalPropertyi("a321neo/dynamics/gpws/mode_pitch", 0, false, true, false)

GPWS_pred_is_active = createGlobalPropertyi("a321neo/dynamics/gpws/pred/is_active", 0, false, true, false)
GPWS_pred_terr      = createGlobalPropertyi("a321neo/dynamics/gpws/pred/terrain", 0, false, true, false)
GPWS_pred_obst      = createGlobalPropertyi("a321neo/dynamics/gpws/pred/obstacle", 0, false, true, false)
GPWS_pred_terr_pull = createGlobalPropertyi("a321neo/dynamics/gpws/pred/terrain_pull", 0, false, true, false)
GPWS_pred_obst_pull = createGlobalPropertyi("a321neo/dynamics/gpws/pred/obstacle_pull", 0, false, true, false)

GPWS_dist_60 = createGlobalPropertyf("a321neo/dynamics/gpws/pred/debug_dist_60", 0, false, true, false) -- Distance in 60 sec for debug only
GPWS_dist_30 = createGlobalPropertyf("a321neo/dynamics/gpws/pred/debug_dist_30", 0, false, true, false) -- Distance in 30 sec for debug only
GPWS_dist_airport = createGlobalPropertyf("a321neo/dynamics/gpws/pred/debug_dist_airport", 0, false, true, false) -- Distance from the nearest airport

GPWS_pred_front     = createGlobalPropertyia("a321neo/dynamics/gpws/pred/front_array", 6) -- 0: not visible, 1: yellow-ish, 2: yellow, 3: orange, 4: red
GPWS_pred_front_L   = createGlobalPropertyia("a321neo/dynamics/gpws/pred/front_array_L", 6) -- 0: not visible, 1: yellow-ish, 2: yellow, 3: orange, 4: red
GPWS_pred_front_R   = createGlobalPropertyia("a321neo/dynamics/gpws/pred/front_array_R", 6) -- 0: not visible, 1: yellow-ish, 2: yellow, 3: orange, 4: red

GPWS_mode_flap_disabled = createGlobalPropertyi("a321neo/dynamics/gpws/no_flaps", 0, false, true, false)
GPWS_mode_flap_3 = createGlobalPropertyi("a321neo/dynamics/gpws/flaps_3", 0, false, true, false)

GPWS_req_inop = createGlobalPropertyi("a321neo/dynamics/gpws/req_inop", 0, false, true, false)  -- 1 if GPWS becomes off (*for sounds only*)
GPWS_req_terr_inop = createGlobalPropertyi("a321neo/dynamics/gpws/req_terr_inop", 0, false, true, false) -- 1 if GPWS Terrain becomes off (*for sounds only*)

