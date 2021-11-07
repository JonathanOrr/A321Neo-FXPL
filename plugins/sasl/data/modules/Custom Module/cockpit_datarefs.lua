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
-- File: cockpit_datarefs.lua 
-- Short description: It contains all the datarefs used in the cockpit model
-------------------------------------------------------------------------------

--ALL DATAREFS USED IN THE COCKPIT, e.g DIALS, KNOBS, BUTTONS--
--PUSH BUTTON STATES-- e.g the lights on the buttons(blank, on, fault, fault on) these datarefs should follow the 00, 01, 10, 11 principle

--BUTTON COMMANDED POSTION-- e.g. button commanding on, off but lights on the button can show otherwise(fault on, fault off....)
X_bleed_dial = createGlobalPropertyi("a321neo/cockpit/packs/x_bleed_dial_status", 1, false, true, false) --0closed, 1auto, 2open
X_bleed_dial_anim = createGlobalPropertyf("a321neo/cockpit/packs/x_bleed_dial", 1, false, true, false) --0closed, 1auto, 2open


Press_manual_control_lever_pos = createGlobalPropertyi("a321neo/cockpit/pressurization/manual_control_sw_pos", 0, false, true, false) -- 0 neutral, -1 down, 1 up
Press_ldg_elev_knob_pos = createGlobalPropertyf("a321neo/cockpit/pressurization/ldg_elev_knob_pos", -3, false, true, false) -- -3 is auto, then from -2 to 14 is the knob position

--FBW
ELAC_1_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/elac_1_off", 0, false, true, false) --0 is on 1 if off
ELAC_2_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/elac_2_off", 0, false, true, false) --0 is on 1 if off
FAC_1_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/fac_1_off", 0, false, true, false) --0 is on 1 if off
FAC_2_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/fac_2_off", 0, false, true, false) --0 is on 1 if off
SEC_1_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/sec_1_off", 0, false, true, false) --0 is on 1 if off
SEC_2_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/sec_2_off", 0, false, true, false) --0 is on 1 if off
SEC_3_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/sec_3_off", 0, false, true, false) --0 is on 1 if off

Rudder_trim_knob_pos = createGlobalPropertyf("a321neo/cockpit/FBW/rudder_trim_pos", 0, false, true, false) -- -1, 0, 1
Rudder_pedal_pos = createGlobalPropertyf("a321neo/cockpit/FBW/rudder_pedals_pos", 0, false, true, false)  -- -1, 0, 1
---------------------------------------------------------------------------------------------------------------------------------------
--display brightness
Total_element_brightness = globalProperty("sim/cockpit/electrical/instrument_brightness")

-- The following are the **requested** brightness linked to knobs
Capt_PFD_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/capt_pfd_brightness", 1, false, true, false)
Capt_ND_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/capt_nd_brightness", 1, false, true, false)
Fo_PFD_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/fo_pfd_brightness", 1, false, true, false)
Fo_ND_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/fo_nd_brightness", 1, false, true, false)
EWD_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/ewd_brightness", 1, false, true, false)
ECAM_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/ecam_brightness", 1, false, true, false)
DCDU_1_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/dcdu_1_brightness", 1, false, true, false)
DCDU_2_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/dcdu_2_brightness", 1, false, true, false)
MCDU_1_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/mcdu_1_brightness", 1, false, true, false)
MCDU_2_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/mcdu_2_brightness", 1, false, true, false)
DRAIMS_1_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/draims_1_brightness", 1, false, true, false)
DRAIMS_2_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/draims_2_brightness", 1, false, true, false)
DRAIMS_1_keys_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/draims_1_keys_brightness", 1, false, true, false)
DRAIMS_2_keys_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/draims_2_keys_brightness", 1, false, true, false)
ISIS_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/isis_brightness", 1, false, true, false)

-- The following are the **actual** brightness linked to the requested ones, electrical power status, and failures
Capt_PFD_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/capt_pfd_brightness_act", 1, false, true, false)
Capt_ND_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/capt_nd_brightness_act", 1, false, true, false)
Fo_PFD_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/fo_pfd_brightness_act", 1, false, true, false)
Fo_ND_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/fo_nd_brightness_act", 1, false, true, false)
EWD_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/ewd_brightness_act", 1, false, true, false)
ECAM_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/ecam_brightness_act", 1, false, true, false)
DCDU_1_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/dcdu_1_brightness_act", 1, false, true, false)
DCDU_2_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/dcdu_2_brightness_act", 1, false, true, false)
MCDU_1_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/mcdu_1_brightness_act", 1, false, true, false)
MCDU_2_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/mcdu_2_brightness_act", 1, false, true, false)
DRAIMS_1_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/draims_1_brightness_act", 1, false, true, false)
DRAIMS_2_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/draims_2_brightness_act", 1, false, true, false)
ISIS_brightness_act = createGlobalPropertyf("a321neo/cockpit/brightness/isis_brightness_act", 1, false, true, false)

Capt_PFD_disable_click = createGlobalPropertyi("a321neo/cockpit/brightness/capt_pfd_disable_click", 0, false, true, false)
Capt_ND_disable_click  = createGlobalPropertyi("a321neo/cockpit/brightness/capt_nd_disable_click", 0, false, true, false)
Fo_PFD_disable_click   = createGlobalPropertyi("a321neo/cockpit/brightness/fo_pfd_disable_click", 0, false, true, false)
Fo_ND_disable_click    = createGlobalPropertyi("a321neo/cockpit/brightness/fo_nd_disable_click", 0, false, true, false)

Audio_nav_selection = globalProperty("sim/cockpit2/radios/actuators/audio_nav_selection")--0=nav1, 1=nav2, 2=adf1, 3=adf2, 9=none
NAV_1_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/nav1_frequency_Mhz")
NAV_1_freq_khz = globalProperty("sim/cockpit2/radios/actuators/nav1_frequency_khz")
NAV_1_capt_obs = globalProperty("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot")--captain nav 1 obs

NAV_1_is_valid = globalProperty("sim/cockpit2/radios/indicators/nav1_display_horizontal")
NAV_1_bearing_deg = globalProperty("sim/cockpit2/radios/indicators/nav1_bearing_deg_mag")
NAV_2_is_valid = globalProperty("sim/cockpit2/radios/indicators/nav2_display_horizontal")
NAV_2_bearing_deg = globalProperty("sim/cockpit2/radios/indicators/nav1_bearing_deg_mag")

NAV_1_dme_value = globalProperty("sim/cockpit2/radios/indicators/nav1_dme_distance_nm")
NAV_2_dme_value = globalProperty("sim/cockpit2/radios/indicators/nav2_dme_distance_nm")
NAV_1_dme_valid = globalProperty("sim/cockpit2/radios/indicators/nav1_has_dme")
NAV_2_dme_valid = globalProperty("sim/cockpit2/radios/indicators/nav2_has_dme")

ILS_1_glideslope_flag = globalProperty("sim/cockpit2/radios/indicators/nav1_flag_glideslope") -- 1: no signal received, 0: signal received
ILS_1_loc_dots = globalProperty("sim/cockpit/radios/nav1_hdef_dot") -- Nr. Dots for NAV1/LOC - each dot = 1.5 deg
ILS_1_glideslope_dots = globalProperty("sim/cockpit/radios/nav1_vdef_dot") -- Nr. Dots for NAV1/GS - each dot = 0.28 deg

VHF_transmit_dest = globalProperty("sim/cockpit2/radios/actuators/audio_com_selection")--6=com1,7=com2
VHF_transmit_dest_manual = globalProperty("sim/cockpit2/radios/actuators/audio_com_selection_man")--6=com1,7=com2, manual without auto switching monitor source
Capt_VHF_1_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/capt_vhf_1_transmit_selected", 0, false, true, false)--0off, 1selected
Capt_VHF_2_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/capt_vhf_2_transmit_selected", 0, false, true, false)--0off, 1selected
Capt_VHF_3_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/capt_vhf_3_transmit_selected", 0, false, true, false)--0off, 1selected
Fo_VHF_1_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/fo_vhf_1_transmit_selected", 0, false, true, false)--0off, 1selected
Fo_VHF_2_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/fo_vhf_2_transmit_selected", 0, false, true, false)--0off, 1selected
Fo_VHF_3_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/fo_vhf_3_transmit_selected", 0, false, true, false)--0off, 1selected

Capt_VHF_recv_selected = createGlobalPropertyia("a321neo/cockpit/draims/capt_vhf_recv_selected", 3)
Fo_VHF_recv_selected = createGlobalPropertyia("a321neo/cockpit/draims/fo_vhf_recv_selected", 3)
Capt_NAV_recv_selected = createGlobalPropertyi("a321neo/cockpit/draims/capt_nav_recv_selected", 0)
Fo_NAV_recv_selected = createGlobalPropertyi("a321neo/cockpit/draims/fo_nav_recv_selected", 0)

DRAIMS_dynamic_NAV_audio_selected = createGlobalPropertyi("a321neo/cockpit/draims/dynamic_nav_audio_selected", 0, false, true, false)--0off, 1selected
DRAIMS_dynamic_NAV_volume = createGlobalPropertyf("a321neo/cockpit/draims/dynamic_nav_volume", 1, false, true, false)--volume of dynamic navigation audio

VHF_1_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_com1")
VHF_2_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_com2")
NAV_1_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_nav1")
NAV_2_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_nav2")
ADF_1_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_adf1")
ADF_2_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_adf2")
VHF_1_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_com1")
VHF_2_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_com2")
NAV_1_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_nav1")
NAV_2_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_nav2")
DME_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_dme")
DME_1_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_dme1")
DME_2_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_dme2")
ADF_1_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_adf1")
ADF_2_volume = globalProperty("sim/cockpit2/radios/actuators/audio_volume_adf2")

Capt_pfd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/capt_pfd_displaying_status", 1, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam, 5 fo/pfd, 6 fo/nd
Capt_nd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/capt_nd_displaying_status", 2, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam, 5 fo/pfd, 6 fo/nd
Fo_pfd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/fo_pfd_displaying_status", 5, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam, 5 fo/pfd, 6 fo/nd
Fo_nd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/fo_nd_displaying_status", 6, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam, 5 fo/pfd, 6 fo/nd
EWD_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/ewd_displaying_status", 3, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam, 5 fo/pfd, 6 fo/nd
ECAM_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/ecam_displaying_status", 4, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam, 5 fo/pfd, 6 fo/nd

Capt_pfd_position =        createGlobalPropertyfa("a321neo/cockpit/source_switching/capt_pfd_position", 4, false, true, false)
Capt_nd_position =         createGlobalPropertyfa("a321neo/cockpit/source_switching/capt_nd_position",  4, false, true, false)
Fo_pfd_position =          createGlobalPropertyfa("a321neo/cockpit/source_switching/fo_pfd_position",   4, false, true, false)
Fo_nd_position =           createGlobalPropertyfa("a321neo/cockpit/source_switching/fo_nd_position",    4, false, true, false)
EWD_displaying_position =  createGlobalPropertyfa("a321neo/cockpit/source_switching/ewd_position",      4, false, true, false)
ECAM_displaying_position = createGlobalPropertyfa("a321neo/cockpit/source_switching/ecam_position",     4, false, true, false)

ECAM_on_nd_dial = createGlobalPropertyi("a321neo/cockpit/source_switching/ECAM_on_nd_dial", 0, false, true, false)--used to swap the position of the ECAM with the NDs 0capt, 1norm, 2FO

Capt_pfd_valid= createGlobalPropertyi("a321neo/cockpit/source_switching/capt_pfd_valid",0, false, true, false) -- 0: invalid data, 1: OK, 2: test mode, 3: waiting for data
Capt_nd_valid = createGlobalPropertyi("a321neo/cockpit/source_switching/capt_nd_valid", 0, false, true, false) -- 0: invalid data, 1: OK, 2: test mode, 3: waiting for data
Fo_pfd_valid  = createGlobalPropertyi("a321neo/cockpit/source_switching/fo_pfd_valid",  0, false, true, false) -- 0: invalid data, 1: OK, 2: test mode, 3: waiting for data
Fo_nd_valid   = createGlobalPropertyi("a321neo/cockpit/source_switching/fo_nd_valid",   0, false, true, false) -- 0: invalid data, 1: OK, 2: test mode, 3: waiting for data
EWD_valid = createGlobalPropertyi("a321neo/cockpit/source_switching/ewd_valid",     0, false, true, false) -- 0: invalid data, 1: OK, 2: test mode, 3: waiting for data
ECAM_valid = createGlobalPropertyi("a321neo/cockpit/source_switching/ecam_valid",    0, false, true, false) -- 0: invalid data, 1: OK, 2: test mode, 3: waiting for data

--engine & apu
Engine_mode_knob = createGlobalPropertyi("a321neo/cockpit/engine/engine_mode_value", 0, false, true, false) -- -1crank, 0norm, 1ignition
Engine_mode_knob_pos = createGlobalPropertyf("a321neo/cockpit/engine/engine_mode", 0, false, true, false) -- -1crank, 0norm, 1ignition
Engine_1_master_switch = createGlobalPropertyi("a321neo/cockpit/engine/master_1_status", 0, false, true, false)
Engine_2_master_switch = createGlobalPropertyi("a321neo/cockpit/engine/master_2_status", 0, false, true, false)
Engine_1_master_switch_anim = createGlobalPropertyf("a321neo/cockpit/engine/master_1", 0, false, true, false)
Engine_2_master_switch_anim = createGlobalPropertyf("a321neo/cockpit/engine/master_2", 0, false, true, false)

APU_bleed_switch_pos = createGlobalPropertyi("a321neo/cockpit/bleed/apu_bleed_switch_pos", 0, false, true, false) -- Commaned position (not actual!) 1: enabled, 0: disabled
APU_flap_open_pos    = createGlobalPropertyf("a321neo/cockpit/apu/apu_flap_pos", 0, false, true, false)   -- 0 closed, 1 open

--pfd
Capt_landing_system_enabled = createGlobalPropertyi("a321neo/cockpit/PFD/capt_ls_enabled", 0, false, true, false)--for the LS button on the PFD
Fo_landing_system_enabled = createGlobalPropertyi("a321neo/cockpit/PFD/fo_ls_enabled", 0, false, true, false)--for the LS button on the PFD
Max_speed = createGlobalPropertyf("a321neo/cockpit/PFD/max_speed", 330, false, true, false)
Max_speed_delta = createGlobalPropertyf("a321neo/cockpit/PFD/max_speed_delta", 0, false, true, false)

PFD_Capt_IAS = createGlobalPropertyf("a321neo/cockpit/PFD/capt_ias", 0, false, true, false) -- Displayed IAS CAPT (affected by ADIRS)
PFD_Fo_IAS = createGlobalPropertyf("a321neo/cockpit/PFD/fo_ias", 0, false, true, false)   -- Displayed IAS F/O (affected by ADIRS)
PFD_Capt_Baro_Altitude = createGlobalPropertyf("a321neo/cockpit/PFD/capt_baro_alt", 0, false, true, false) -- Displayed Altitude CAPT (affected by ADIRS)
PFD_Fo_Baro_Altitude = createGlobalPropertyf("a321neo/cockpit/PFD/fo_baro_alt", 0, false, true, false)   -- Displayed Altitude F/O (affected by ADIRS)
PFD_Capt_VS = createGlobalPropertyf("a321neo/cockpit/PFD/capt_vs", 0, false, true, false) -- Displayed V/S CAPT (affected by ADIRS)
PFD_Fo_VS = createGlobalPropertyf("a321neo/cockpit/PFD/fo_vs", 0, false, true, false)   -- Displayed V/S F/O (affected by ADIRS)

PFD_Capt_Pitch = createGlobalPropertyf("a321neo/cockpit/PFD/capt_pitch", 0, false, true, false) -- Displayed Pitch CAPT (affected by ADIRS)
PFD_Capt_Roll = createGlobalPropertyf("a321neo/cockpit/PFD/capt_roll", 0, false, true, false) -- Displayed Roll CAPT (affected by ADIRS)
PFD_Fo_Pitch = createGlobalPropertyf("a321neo/cockpit/PFD/fo_pitch", 0, false, true, false) -- Displayed Pitch CAPT (affected by ADIRS)
PFD_Fo_Roll = createGlobalPropertyf("a321neo/cockpit/PFD/fo_roll", 0, false, true, false) -- Displayed Roll CAPT (affected by ADIRS)

PFD_Capt_ias_accel = globalProperty("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot")
PFD_Fo_ias_accel = globalProperty("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_copilot")

PFD_Capt_Ground_line = createGlobalPropertyf("a321neo/cockpit/PFD/capt_att_ground_line", 0, false, true, false)   -- Ground line on ATT moving during t/o or landing
PFD_Fo_Ground_line = createGlobalPropertyf("a321neo/cockpit/PFD/fo_att_ground_line", 0, false, true, false)   -- Ground line on ATT moving during t/o or landing

PFD_Capt_radioalt_val = createGlobalPropertyi("a321neo/cockpit/PFD/capt_radioalt_val", 0, false, true, false)
PFD_Capt_radioalt_col = createGlobalPropertyi("a321neo/cockpit/PFD/capt_radioalt_col", 0, false, true, false)       -- 0: green, 1: amber
PFD_Capt_radioalt_status = createGlobalPropertyi("a321neo/cockpit/PFD/capt_radioalt_status", 0, false, true, false) -- 0: not shown, 1: shown, 2: error "RA" showed

PFD_Capt_tailstrike_ind = createGlobalPropertyi("a321neo/cockpit/PFD/capt_tailstrike_ind", 0, false, true, false)   -- 0: not shown, 1: shown

PFD_Capt_bird_vert_pos = createGlobalPropertyf("a321neo/cockpit/PFD/capt_bird_vert_pos", 0, false, true, false)
PFD_Capt_bird_horiz_pos = createGlobalPropertyf("a321neo/cockpit/PFD/capt_bird_horiz_pos", 0, false, true, false)

-- ECAM
Ecam_previous_page  = createGlobalPropertyi("a321neo/cockpit/ecam/previous", 13, false, true, false) --1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS
Ecam_current_page   = createGlobalPropertyi("a321neo/cockpit/ecam/page_num", 4, false, true, false) --1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS

Ecam_elec_bat_1_status = createGlobalPropertyi("a321neo/cockpit/ecam/electrical/bat_1_status", 0, false, true, false) -- 1 on, 0 off
Ecam_elec_bat_2_status = createGlobalPropertyi("a321neo/cockpit/ecam/electrical/bat_2_status", 0, false, true, false) -- 1 on, 0 off
Ecam_elec_apu_gen_status = createGlobalPropertyi("a321neo/cockpit/ecam/electrical/apu_gen_status", 0, false, true, false) -- 0: apu off, 1: gen off, 2: online, 3:failed
Ecam_elec_tr_ess_status = createGlobalPropertyi("a321neo/cockpit/ecam/electrical/tr_ess_status", 0, false, true, false) -- 0: TR off, 1: TR on, 2: TR failed
Ecam_elec_rat_status = createGlobalPropertyi("a321neo/cockpit/ecam/electrical/emer_gen_status", 0, false, true, false) -- 0: RAT off, 1: RAT on, 2: RAT failed

Ecam_fuel_usage_1 = createGlobalPropertyf("a321neo/cockpit/ecam/fuel/usage_eng_1", 0, false, true, false)
Ecam_fuel_usage_2 = createGlobalPropertyf("a321neo/cockpit/ecam/fuel/usage_eng_2", 0, false, true, false)

Ecam_fuel_valve_L_1 = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_L_1", 0, false, true, false) -- 0: closed OK, 1: closed amber, 2: LO PRESS, 3: open
Ecam_fuel_valve_L_2 = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_L_2", 0, false, true, false) -- 0: closed OK, 1: closed amber, 2: LO PRESS, 3: open
Ecam_fuel_valve_R_1 = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_R_1", 0, false, true, false) -- 0: closed OK, 1: closed amber, 2: LO PRESS, 3: open
Ecam_fuel_valve_R_2 = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_R_2", 0, false, true, false) -- 0: closed OK, 1: closed amber, 2: LO PRESS, 3: open
Ecam_fuel_valve_C_1 = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_C_1", 0, false, true, false) -- 0: closed GREEN, 1: closed AMBER+ARROW, 2: OPEN GREEN+ARROW
Ecam_fuel_valve_C_2 = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_C_2", 0, false, true, false) -- 0: closed GREEN, 1: closed AMBER+ARROW, 2: OPEN GREEN+ARROW
Ecam_fuel_valve_ENG_1   = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_ENG_1", 0, false, true, false) -- 0: closed OK, 1: closed amber, 2: open OK, 3: open amber, 4: transition
Ecam_fuel_valve_ENG_2   = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_ENG_2", 0, false, true, false) -- 0: closed OK, 1: closed amber, 2: open OK, 3: open amber, 4: transition
Ecam_fuel_valve_X_BLEED = createGlobalPropertyi("a321neo/cockpit/ecam/fuel/valve_X_BLEED", 0, false, true, false) -- 0: closed OK, 1: closed amber, 2: open OK, 3: open amber, 4: transition

Ecam_apu_needle_state = createGlobalPropertyi("a321neo/cockpit/apu/apu_needle_state", 0, false, true, false)
Ecam_apu_gen_state    = createGlobalPropertyi("a321neo/cockpit/apu/apu_gen_state", 0, false, true, false)   -- 0: invisible, 1: OFF, 2: online, 3: failed

Ecam_eng_igniter_eng_1 = createGlobalPropertyi("a321neo/cockpit/ecam/eng/igniter_eng1", 0, false, true, false) -- 0: no, 1: A, 2: B, 3: AB
Ecam_eng_igniter_eng_2 = createGlobalPropertyi("a321neo/cockpit/ecam/eng/igniter_eng2", 0, false, true, false) -- 0: no, 1: A, 2: B, 3: AB

-- For all the following: 0: closed green, 1: closed amber, 2: open green, 3: open amber, 4: transition
Ecam_bleed_ip_valve_L    = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/ip_valve_L", 0, false, true, false)  
Ecam_bleed_ip_valve_R    = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/ip_valve_R", 0, false, true, false)
Ecam_bleed_hp_valve_L    = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/hp_valve_L", 0, false, true, false)
Ecam_bleed_hp_valve_R    = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/hp_valve_R", 0, false, true, false)
Ecam_bleed_xbleed_valve  = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/xbleed_valve", 0, false, true, false)
Ecam_bleed_pack_valve_L  = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/pack_valve_L", 0, false, true, false)
Ecam_bleed_pack_valve_R  = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/pack_valve_R", 0, false, true, false)
Ecam_bleed_ram_air       = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/ram_air", 0, false, true, false)
Ecam_bleed_top_mix_line  = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/top_mix_line", 0, false, true, false) -- 0: amber, 1: green

Ecam_cond_valve_hot_air        = createGlobalPropertyi("a321neo/cockpit/ecam/aircond/valve_hot_air", 0, false, true, false)  -- 0: closed green, 1: closed amber, 2: open green, 3: open amber, 4: transition
Ecam_cond_valve_hot_air_cargo  = createGlobalPropertyi("a321neo/cockpit/ecam/aircond/valve_hot_air_cargo", 0, false, true, false)  -- 0: closed green, 1: closed amber, 2: open green, 3: open amber, 4: transition
Ecam_cond_valve_isol_cargo_in  = createGlobalPropertyi("a321neo/cockpit/ecam/aircond/valve_isol_cargo_in", 0, false, true, false)  -- 0: closed green, 1: closed amber, 2: open green, 3: open amber, 4: transition
Ecam_cond_valve_isol_cargo_out = createGlobalPropertyi("a321neo/cockpit/ecam/aircond/valve_isol_cargo_out", 0, false, true, false)  -- 0: closed green, 1: closed amber, 2: open green, 3: open amber, 4: transition

Ecam_press_pack_1_triangle = createGlobalPropertyi("a321neo/cockpit/ecam/press/pack_1", 0, false, true, false)  -- 0: amber, 1: green
Ecam_press_pack_2_triangle = createGlobalPropertyi("a321neo/cockpit/ecam/press/pack_2", 0, false, true, false)  -- 0: amber, 1: green
Ecam_press_ovf_valve_color = createGlobalPropertyi("a321neo/cockpit/ecam/press/ovf_valve_color", 0, false, true, false)  -- 0: amber, 1: green
Ecam_press_cabin_alt_limit = createGlobalPropertyf("a321neo/cockpit/ecam/press/cabin_alt_limited", 0, false, true, false)  -- -500 - 10500
Ecam_press_cabin_alt_color = createGlobalPropertyi("a321neo/cockpit/ecam/press/cabin_alt_color", 0, false, true, false)  -- 0: red, 1: green
Ecam_press_cabin_vs_limit  = createGlobalPropertyf("a321neo/cockpit/ecam/press/cabin_vs_limited", 0, false, true, false)  -- -2100 - 2100
Ecam_press_delta_p_limit   = createGlobalPropertyf("a321neo/cockpit/ecam/press/delta_p_limited", 0, false, true, false)  -- -1 - 9
Ecam_press_delta_p_color   = createGlobalPropertyf("a321neo/cockpit/ecam/press/delta_p_color", 0, false, true, false)  -- 0: amber, 1: green

Ecam_wheel_release_L = createGlobalPropertyi("a321neo/cockpit/ecam/wheel/release_L", 0, false, true, false)
Ecam_wheel_release_R = createGlobalPropertyi("a321neo/cockpit/ecam/wheel/release_R", 0, false, true, false)


-- ECAM button lights
Ecam_btn_light_ENG   = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_eng", 0, false, true, false)   --0: OFF, 1: ON
Ecam_btn_light_BLEED = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_bleed", 0, false, true, false) --0: OFF, 1: ON
Ecam_btn_light_PRESS = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_press", 0, false, true, false) --0: OFF, 1: ON
Ecam_btn_light_ELEC  = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_elec", 0, false, true, false)  --0: OFF, 1: ON
Ecam_btn_light_HYD   = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_hyd", 0, false, true, false)   --0: OFF, 1: ON
Ecam_btn_light_FUEL  = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_fuel", 0, false, true, false)  --0: OFF, 1: ON
Ecam_btn_light_APU   = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_apu", 0, false, true, false)   --0: OFF, 1: ON
Ecam_btn_light_COND  = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_cond", 0, false, true, false)  --0: OFF, 1: ON
Ecam_btn_light_DOOR  = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_door", 0, false, true, false)  --0: OFF, 1: ON
Ecam_btn_light_WHEEL = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_wheel", 0, false, true, false) --0: OFF, 1: ON
Ecam_btn_light_FCTL  = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_fctl", 0, false, true, false)  --0: OFF, 1: ON
Ecam_btn_light_CLR   = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_clr", 0, false, true, false)   --0: OFF, 1: ON
Ecam_btn_light_STS   = createGlobalPropertyi("a321neo/cockpit/ecam/buttons/light_sts", 0, false, true, false)   --0: OFF, 1: ON

--wheel
XPlane_parkbrake_ratio = globalProperty("sim/cockpit2/controls/parking_brake_ratio")
Nosewheel_Steering_and_AS_sw = createGlobalPropertyf("a321neo/cockpit/wheel/antiskid_steering", 0, false, true, false)  -- 0: off, 1: on
Parkbrake_switch_pos      = createGlobalPropertyi("a321neo/cockpit/wheel/park_brake_pos_value", 1, false, true, false)  -- 0: off, 1: on
Parkbrake_switch_pos_anim = createGlobalPropertyf("a321neo/cockpit/wheel/park_brake_pos", 1, false, true, false)  -- 0: off, 1: on
Brakes_press_ind_L = createGlobalPropertyf("a321neo/cockpit/wheel/brake_indicator_press_L", 0, false, true, false) -- [0;3000]
Brakes_press_ind_R = createGlobalPropertyf("a321neo/cockpit/wheel/brake_indicator_press_R", 0, false, true, false) -- [0;3000]
Brakes_accumulator = createGlobalPropertyf("a321neo/cockpit/wheel/accumulator_indicator", 3, false, true, false) -- [0;4]

--aircond
Cockpit_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp_dial", 0.5, false, true, false) --cockpit temperature dial position
Front_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp_dial", 0.5, false, true, false) --front cabin temperature dial position
Aft_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp_dial", 0.5, false, true, false) --aft cabin temperature dial position
Aft_cargo_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cargo_temp_dial", 0.5, false, true, false) --aft cargo temperature dial position

--misc
Capt_ra_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_ra_alt_m", 0, false, true, false)
Capt_baro_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_baro_alt_m", 0, false, true, false)
Seatbelts = globalProperty("sim/cockpit2/switches/fasten_seat_belts")
NoSmoking = globalProperty("sim/cockpit2/switches/no_smoking")
CabinIsReady = createGlobalPropertyi("a321neo/cockpit/cabin_ready", 0, false, true, false)  -- 0 cabin is not ready, 1 cabin is ready
Lights_emer_exit = createGlobalPropertyi("a321neo/cockpit/lights/emer_exit_switch", 0, false, true, false)
EVAC_cabin_active = createGlobalPropertyi("a321neo/cockpit/misc/evac_cabin_active", 0, false, true, false)
EVAC_cockpit_horn = createGlobalPropertyi("a321neo/cockpit/misc/evac_cockpit_horn", 0, false, true, false)

--MCDU
Mcdu_enabled = createGlobalPropertyi("a321neo/debug/mcdu/mcdu_enabled", 1, false, true, false)
mcdu_page = createGlobalPropertyi("a321neo/cockpit/mcdu/mcdu_page", 0, false, true, false)

-- ACARS & DCDU
DCDU_page_no = createGlobalPropertyi("a321neo/cockpit/DCDU/page_no", 0, false, true, false) -- Current page number, from 0
DCDU_msg_no  = createGlobalPropertyi("a321neo/cockpit/DCDU/msg_no" , 0, false, true, false) -- Current message number, from 0
DCDU_pages_total = createGlobalPropertyi("a321neo/cockpit/DCDU/pages_total", 0, false, true, false) -- Total number of pages
DCDU_msgs_total  = createGlobalPropertyi("a321neo/cockpit/DCDU/msgs_total" , 0, false, true, false) -- Total number of messages
DCDU_recall_mode = createGlobalPropertyi("a321neo/cockpit/DCDU/recall_mode" , 0, false, true, false) -- 1 if in recall mode, 0 otherwise
DCDU_new_msgs    = createGlobalPropertyi("a321neo/cockpit/DCDU/new_messages" , 0, false, true, false) -- 1 if at least one new message is present

-- ADIRS
ADIRS_light_onbat   = createGlobalPropertyi("a321neo/cockpit/ADIRS/on_bat", 0, false, true, false)   --0: OFF, 1: ON

ADIRS_rotary_btn = {}
ADIRS_rotary_btn[1]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/mode_1_status", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT
ADIRS_rotary_btn[2]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/mode_2_status", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT
ADIRS_rotary_btn[3]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/mode_3_status", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT

ADIRS_rotary_btn_anim = {}
ADIRS_rotary_btn_anim[1]  = createGlobalPropertyf("a321neo/cockpit/ADIRS/buttons/mode_1", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT
ADIRS_rotary_btn_anim[2]  = createGlobalPropertyf("a321neo/cockpit/ADIRS/buttons/mode_2", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT
ADIRS_rotary_btn_anim[3]  = createGlobalPropertyf("a321neo/cockpit/ADIRS/buttons/mode_3", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT

ADIRS_source_rotary_ATHDG   = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/atthdg_source_state", 0, false, true, false)    -- Pedestal switch, 0 NORM, -1 CAPT3, 1 FO3
ADIRS_source_rotary_AIRDATA = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/airdata_source_state", 0, false, true, false)   -- Pedestal switch, 0 NORM, -1 CAPT3, 1 FO3
ADIRS_source_rotary_ATHDG_anim   = createGlobalPropertyf("a321neo/cockpit/ADIRS/buttons/atthdg_source", 0, false, true, false)    -- Pedestal switch, 0 NORM, -1 CAPT3, 1 FO3
ADIRS_source_rotary_AIRDATA_anim = createGlobalPropertyf("a321neo/cockpit/ADIRS/buttons/airdata_source", 0, false, true, false)   -- Pedestal switch, 0 NORM, -1 CAPT3, 1 FO3

--doors
Ecam_door_click_shown = createGlobalPropertyf("a321neo/cockpit/door/ecam_door_click_shown", 0, false, true, false)--used to show and hide the click spots on the ecam door page
Door_1_l_switch = createGlobalPropertyi("a321neo/cockpit/door/door_1_l_switch", 0, false, true, false)--commanded door positions
Door_1_r_switch = createGlobalPropertyi("a321neo/cockpit/door/door_1_r_switch", 0, false, true, false)--commanded door positions
Door_2_l_switch = createGlobalPropertyi("a321neo/cockpit/door/door_2_l_switch", 0, false, true, false)--commanded door positions
Door_2_r_switch = createGlobalPropertyi("a321neo/cockpit/door/door_2_r_switch", 0, false, true, false)--commanded door positions
Door_3_l_switch = createGlobalPropertyi("a321neo/cockpit/door/door_3_l_switch", 0, false, true, false)--commanded door positions
Door_3_r_switch = createGlobalPropertyi("a321neo/cockpit/door/door_3_r_switch", 0, false, true, false)--commanded door positions
Overwing_exit_1_l_switch = createGlobalPropertyi("a321neo/cockpit/door/overwing_exit_1_l_switch", 0, false, true, false)--commanded door positions
Overwing_exit_1_r_switch = createGlobalPropertyi("a321neo/cockpit/door/overwing_exit_1_r_switch", 0, false, true, false)--commanded door positions
Overwing_exit_2_l_switch = createGlobalPropertyi("a321neo/cockpit/door/overwing_exit_2_l_switch", 0, false, true, false)--commanded door positions
Overwing_exit_2_r_switch = createGlobalPropertyi("a321neo/cockpit/door/overwing_exit_2_r_switch", 0, false, true, false)--commanded door positions
Cargo_1_switch = createGlobalPropertyi("a321neo/cockpit/door/cargo_1_switch", 0, false, true, false)--commanded door positions
Cargo_2_switch = createGlobalPropertyi("a321neo/cockpit/door/cargo_2_switch", 0, false, true, false)--commanded door positions


-- ELEC
Elec_bat_1_V  = createGlobalPropertyf("a321neo/cockpit/electrical/battery_1_voltage", 0, false, true, false)
Elec_bat_2_V  = createGlobalPropertyf("a321neo/cockpit/electrical/battery_2_voltage", 0, false, true, false)

-- ISIS

-- Fuel
Fuel_is_refuelG     = createGlobalPropertyi("a321neo/cockpit/fuel/refuelg", 0, false, true, false) -- Refuel panel is active (1: yes, 0 : no)

-- Fire
Fire_pb_APU_status = createGlobalPropertyi("a321neo/cockpit/fire/buttons/APU_pb", 0, false, true, false)
Fire_pb_ENG1_status = createGlobalPropertyi("a321neo/cockpit/fire/buttons/ENG1_pb", 0, false, true, false)
Fire_pb_ENG2_status = createGlobalPropertyi("a321neo/cockpit/fire/buttons/ENG2_pb", 0, false, true, false)

-- EWD
EWD_engine_avail_ind_start = createGlobalPropertyia("a321neo/cockpit/ewd/ENG_avail_indicator_start", 2) -- Time point when the engine is avail
EWD_engine_1_rev_ind = createGlobalPropertyi("a321neo/cockpit/ewd/ENG1_rev_ind", 0, false, true, false) -- 0: no rev, 2: rev amber, 2: rev amber HIGH, 4: rev green
EWD_engine_2_rev_ind = createGlobalPropertyi("a321neo/cockpit/ewd/ENG2_rev_ind", 0, false, true, false) -- 0: no rev, 2: rev amber, 2: rev amber HIGH, 4: rev green
EWD_engine_1_XX = createGlobalPropertyi("a321neo/cockpit/EWD/ENG1_XX", 0, false, true, false) -- 0: normal, 1: XX on engine parameters
EWD_engine_2_XX = createGlobalPropertyi("a321neo/cockpit/EWD/ENG2_XX", 0, false, true, false) -- 0: normal, 1: XX on engine parameters

EWD_engine_cooling      = createGlobalPropertyia("a321neo/cockpit/EWD/ENG_cooling", 2) -- 0: no cooling, 1: cooling procedure
EWD_engine_cooling_time = createGlobalPropertyia("a321neo/cockpit/EWD/ENG_cooling_time", 2) -- time left

--ENG
Cockpit_throttle_lever_L = createGlobalPropertyf("a321neo/cockpit/engine/throttle_lever_L", 0, false, true, false)  -- From -1 to 1
Cockpit_throttle_lever_R = createGlobalPropertyf("a321neo/cockpit/engine/throttle_lever_R", 0, false, true, false)  -- From -1 to 1
Throttle_blue_dot = createGlobalPropertyfa("a321neo/cockpit/engine/lever_blue_dot", 2)

-- AI
No_ice_detected       = createGlobalPropertyi("a321neo/cockpit/anti_ice/no_ice_detected", 0, false, true, false) --0: ice detected or system off, 1: no ice detected and system ON

-- DMC
DMC_position_dmc_eis = createGlobalPropertyf("a321neo/cockpit/dmc/dmc_eis_sel_position", 0, false, true, false) -- usual -1, 0, 1
DMC_position_ecam_nd = createGlobalPropertyf("a321neo/cockpit/dmc/ecan_nd_xfr_position", 0, false, true, false) -- usual -1, 0, 1

-- Cockpit lights - Other dataerfs
Cockpit_annnunciators_test = createGlobalPropertyi("a321neo/cockpit/lights/ann_test", 0, false, true, false) -- 1 if testing annunciators
Cockpit_ann_ovhd_switch    = createGlobalPropertyf("a321neo/cockpit/lights/ovhd_ann_lt_pos", 0, false, true, false) -- -1, 0, 1

Cockpit_Capt_tray_pos = createGlobalPropertyf("a321neo/cockpit/misc/capt_tray_pos", 0, false, true, false)
Cockpit_Fo_tray_pos   = createGlobalPropertyf("a321neo/cockpit/misc/fo_tray_pos", 0, false, true, false)
Cockpit_door_lever_pos = createGlobalPropertyf("a321neo/cockpit/misc/ckpt_door_lever_pos", 0, false, true, false) -- -1, 0, 1

-- Cockpit lights - Extra datarefs for positioning the lights
Lights_extra = createGlobalPropertyf("a321neo/cockpit/lights/extra", 0, false, true, false) -- This is used for internals for lights, ask Jon

-- Overhead panel levers position
EVAC_capt_purs_lever = createGlobalPropertyf("a321neo/cockpit/evac/buttons/capt_purs_pos", 1, false, true, false) -- 0 CAPT, 1 CAPT+PURS
Rain_wiper_L_lever = createGlobalPropertyf("a321neo/cockpit/rain/buttons/wiper_L_pos", 0, false, true, false)
Rain_wiper_R_lever = createGlobalPropertyf("a321neo/cockpit/rain/buttons/wiper_R_pos", 0, false, true, false)
Fire_pb_APU_lever = createGlobalPropertyf("a321neo/cockpit/fire/buttons/APU_lever_pos", 0, false, true, false)
Fire_pb_ENG_1_lever = createGlobalPropertyf("a321neo/cockpit/fire/buttons/ENG1_lever_pos", 0, false, true, false)
Fire_pb_ENG_2_lever = createGlobalPropertyf("a321neo/cockpit/fire/buttons/ENG2_lever_pos", 0, false, true, false)

Lights_strobe_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/strobe_lever_pos", 0, false, true, false)
Lights_land_L_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/land_L_pos", 0, false, true, false)
Lights_land_R_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/land_R_pos", 0, false, true, false)
Lights_nose_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/nose_lever_pos", 0, false, true, false)
Lights_beacon_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/beacon_lever_pos", 0, false, true, false)
Lights_wing_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/wing_lever_pos", 0, false, true, false)
Lights_navlogo_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/navlogo_lever_pos", 0, false, true, false)
Lights_rwy_turnoff_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/rwy_turnoff_lever_pos", 0, false, true, false)
Lights_compass_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/rwy_compass_pos", 0, false, true, false)
Lights_emer_exit_lever = createGlobalPropertyf("a321neo/cockpit/lights/buttons/emer_exit_pos", 0, false, true, false)
Lights_seatbelts_lever = createGlobalPropertyf("a321neo/cockpit/misc/buttons/seatbelts_pos", 0, false, true, false)
Lights_noped_lever = createGlobalPropertyf("a321neo/cockpit/misc/buttons/noped_pos", 0, false, true, false)

Lights_strobe = createGlobalPropertyf("a321neo/cockpit/lights/buttons/strobe_lever", 0, false, true, false)
Lights_land_L = createGlobalPropertyf("a321neo/cockpit/lights/buttons/land_L", 0, false, true, false)
Lights_land_R = createGlobalPropertyf("a321neo/cockpit/lights/buttons/land_R", 0, false, true, false)
Lights_nose = createGlobalPropertyf("a321neo/cockpit/lights/buttons/nose_lever", 0, false, true, false)
Lights_beacon = createGlobalPropertyf("a321neo/cockpit/lights/buttons/beacon_lever", 0, false, true, false)
Lights_wing = createGlobalPropertyf("a321neo/cockpit/lights/buttons/wing_lever", 0, false, true, false)
Lights_navlogo = createGlobalPropertyf("a321neo/cockpit/lights/buttons/navlogo_lever", 0, false, true, false)
Lights_rwy_turnoff = createGlobalPropertyf("a321neo/cockpit/lights/buttons/rwy_turnoff_lever", 0, false, true, false)



-- Chrono
Chrono_state_button = createGlobalPropertyf("a321neo/cockpit/misc/chrono_state", 1, false, true, false)
Chrono_source_button = createGlobalPropertyf("a321neo/cockpit/misc/chrono_source", 0, false, true, false)

-- ND
ND_Capt_mode_knob  = createGlobalPropertyf("a321neo/cockpit/nd/capt_mode_knob", 0, false, true, false) -- -2:2
ND_Capt_range_knob = createGlobalPropertyf("a321neo/cockpit/nd/capt_range_knob", 0, false, true, false) -- 0:10
ND_Capt_nav1_level = createGlobalPropertyf("a321neo/cockpit/nd/capt_nav1_lever", 0, false, true, false) -- -1,0,1
ND_Capt_nav2_level = createGlobalPropertyf("a321neo/cockpit/nd/capt_nav2_lever", 0, false, true, false) -- -1,0,1

ND_Fo_mode_knob  = createGlobalPropertyf("a321neo/cockpit/nd/fo_mode_knob", 0, false, true, false) -- -2:2
ND_Fo_range_knob = createGlobalPropertyf("a321neo/cockpit/nd/fo_range_knob", 0, false, true, false) -- 0:10
ND_Fo_nav1_level = createGlobalPropertyf("a321neo/cockpit/nd/fo_nav1_lever", 0, false, true, false) -- -1,0,1
ND_Fo_nav2_level = createGlobalPropertyf("a321neo/cockpit/nd/fo_nav2_lever", 0, false, true, false) -- -1,0,1

ND_Capt_Terrain = createGlobalPropertyi("a321neo/cockpit/nd/terrain_capt", 0, false, true, false) -- 0,1
ND_Fo_Terrain   = createGlobalPropertyi("a321neo/cockpit/nd/terrain_fo", 0, false, true, false) -- 0,1

ND_Capt_picture_brightness = createGlobalPropertyf("a321neo/cockpit/nd/terrain_bright_capt", 1, false, true, false) 
ND_Fo_picture_brightness = createGlobalPropertyf("a321neo/cockpit/nd/terrain_bright_fo", 1, false, true, false) 

ND_GPIRS_indication = createGlobalPropertyi("a321neo/cockpit/nd/gpirs_is_on", 0, false, true, false) -- 0,1,2

--PFD--
Current_heading = globalProperty("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
Ground_track = globalProperty("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
VVI = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")

Marker_OM_over = globalProperty("sim/cockpit/misc/over_outer_marker")
Marker_MM_over = globalProperty("sim/cockpit/misc/over_middle_marker")
Marker_IM_over = globalProperty("sim/cockpit/misc/over_inner_marker")

--AUTOFLT--
AUTOFLT_FCU_SPD_or_MACH     = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/spd_or_mach", 0, false, true, false)
AUTOFLT_FCU_HDGVS_or_TRKFPA = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/hdgvs_or_trkfpa", 0, false, true, false)
AUTOFLT_FCU_M_ALT           = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/meter_alt", 0, false, false, false)
AUTOFLT_FCU_ALT_1000_or_100 = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/altitude_1000_or_100", 0, false, true, false)
AUTOFLT_FCU_SPD             = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/speed", 100, false, true, false)
AUTOFLT_FCU_MACH            = createGlobalPropertyf("a321neo/cockpit/AUTOFLT/FCU/mach", 0.1, false, true, false)
AUTOFLT_FCU_HDG_TRK         = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/heading_track", 0, false, true, false)
AUTOFLT_FCU_ALT             = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/altitude", 1000, false, true, false)
AUTOFLT_FCU_VS              = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/vertical_speed", 0, false, true, false)
AUTOFLT_FCU_FPA             = createGlobalPropertyf("a321neo/cockpit/AUTOFLT/FCU/flight_path_angle", 0, false, true, false)

AUTOFLT_FCU_SPD_KNOB_CLICKS = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/animation/spd_knob_clicks", 0, false, true, false)
AUTOFLT_FCU_HDG_KNOB_CLICKS = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/animation/hdg_knob_clicks", 0, false, true, false)
AUTOFLT_FCU_ALT_KNOB_CLICKS = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/animation/alt_knob_clicks", 0, false, true, false)
AUTOFLT_FCU_VS_KNOB_CLICKS  = createGlobalPropertyi("a321neo/cockpit/AUTOFLT/FCU/animation/vs_knob_clicks", 0, false, true, false)

-- MANUAL GEAR EXT --
Emer_ldg_gear_v_pos = createGlobalPropertyf("a321neo/cockpit/misc/lg_gravity_v_pos", 0, false, true, false) -- 0 retract, 1 extended
Emer_ldg_gear_h_pos = createGlobalPropertyf("a321neo/cockpit/misc/lg_gravity_h_pos", 0, false, true, false) -- 0 initial,  1 final




