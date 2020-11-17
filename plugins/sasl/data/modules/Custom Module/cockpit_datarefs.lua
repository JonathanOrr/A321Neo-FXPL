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
--apu
Apu_start_button_state = createGlobalPropertyi("a321neo/cockpit/apu/start_button_state", 0, false, true, false)--follow 00, 01, 10, 11 for the buttons(black, on, fault, fault on)
Apu_master_button_light = createGlobalPropertyi("a321neo/cockpit/apu/master_button_state", 0, false, true, false)--follow 00, 01, 10, 11 for the buttons

--wheel
Brake_fan_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/brake_fan_button_state", 0, false, true, false)--blank, on, hot, hot on
Autobrakes_lo_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes_lo_button_state", 0, false, true, false)--blank, on, decel(should not happen), decel on
Autobrakes_med_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes_med_button_state", 0, false, true, false)--blank, on, decel(should not happen), decel on
Autobrakes_max_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes_max_button_state", 0, false, true, false)--blank, on, decel(should not happen), decel on

--FBW
ELAC_1_button_state = createGlobalPropertyi("a321neo/cockpit/FBW/elac_1_button_state", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
ELAC_2_button_state = createGlobalPropertyi("a321neo/cockpit/FBW/elac_2_button_state", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
FAC_1_button_state = createGlobalPropertyi("a321neo/cockpit/FBW/fac_1_button_state", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
FAC_2_button_state = createGlobalPropertyi("a321neo/cockpit/FBW/fac_2_button_state", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
SEC_1_button_state = createGlobalPropertyi("a321neo/cockpit/FBW/sec_1_button_state", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
SEC_2_button_state = createGlobalPropertyi("a321neo/cockpit/FBW/sec_2_button_state", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
SEC_3_button_state = createGlobalPropertyi("a321neo/cockpit/FBW/sec_3_button_state", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT

--BUTTON COMMANDED POSTION-- e.g. button commanding on, off but lights on the button can show otherwise(fault on, fault off....)
Eng1_bleed_off_button = createGlobalPropertyi("a321neo/cockpit/packs/eng1_bleed_off", 0, false, true, false) --0 is on 1 if off, 10 fault, 11 off+fault
Eng2_bleed_off_button = createGlobalPropertyi("a321neo/cockpit/packs/eng2_bleed_off", 0, false, true, false) --0 is on 1 if off, 10 fault, 11 off+fault
APU_bleed_on_button   = createGlobalPropertyi("a321neo/cockpit/packs/apu_bleed_on", 0, false, true, false) --0 is off 1 if on, 10 fault, 11 on+fault
RAM_air_button   = createGlobalPropertyi("a321neo/cockpit/packs/ram_air_on", 0, false, true, false) --0 is [nothing] 1 if on, 10 fault, 11 on+fault
X_bleed_dial = createGlobalPropertyi("a321neo/cockpit/packs/x_bleed_dial", 1, false, true, false) --0closed, 1auto, 2open
Pack1_off_button = createGlobalPropertyi("a321neo/cockpit/packs/pack1_off", 0, false, true, false) --0 is nothing 1 if off, 10 fault, 11 off+fault
Pack2_off_button = createGlobalPropertyi("a321neo/cockpit/packs/pack2_off", 0, false, true, false) --0 is nothing 1 if off, 10 fault, 11 off+fault
Econ_flow_button = createGlobalPropertyi("a321neo/cockpit/packs/econ_flow", 0, false, true, false) --0 is nothing 1 if on, 10 fault, 11 on+fault
Ditching_button  = createGlobalPropertyi("a321neo/cockpit/pressurization/ditching", 0, false, true, false) --0 is nothing 1 is on


Press_manual_control_lever_pos = createGlobalPropertyi("a321neo/cockpit/pressurization/manual_control_sw_pos", 0, false, true, false) -- 0 neutral, -1 down, 1 up
Press_ldg_elev_knob_pos = createGlobalPropertyf("a321neo/cockpit/pressurization/ldg_elev_knob_pos", -3, false, true, false) -- -3 is auto, then from -2 to 14 is the knob position
Press_mode_sel_button = createGlobalPropertyi("a321neo/cockpit/pressurization/mode_sel", 0, false, true, false) -- 0 - nothing, 1 - [MAN], 10 - Fault, 11 - [MAN] + Fault   

--FBW
ELAC_1_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/elac_1_off", 0, false, true, false) --0 is on 1 if off
ELAC_2_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/elac_2_off", 0, false, true, false) --0 is on 1 if off
FAC_1_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/fac_1_off", 0, false, true, false) --0 is on 1 if off
FAC_2_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/fac_2_off", 0, false, true, false) --0 is on 1 if off
SEC_1_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/sec_1_off", 0, false, true, false) --0 is on 1 if off
SEC_2_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/sec_2_off", 0, false, true, false) --0 is on 1 if off
SEC_3_off_button = createGlobalPropertyi("a321neo/cockpit/FBW/sec_3_off", 0, false, true, false) --0 is on 1 if off
---------------------------------------------------------------------------------------------------------------------------------------
--display brightness
Total_element_brightness = globalProperty("sim/cockpit/electrical/instrument_brightness")

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
ISIS_brightness = createGlobalPropertyf("a321neo/cockpit/brightness/isis_brightness", 1, false, true, false)

--draims--
DRAIMS_current_page = createGlobalPropertyi("a321neo/cockpit/draims/current_page", 1, false, true, false)--the page the draims unit is currently displaying 1VHF, 2HFs, 3TEL, 4ATC, 5MENU, 6NAV, 7ILS, 8VOR, 9ADF
DRAIMS_format_error = createGlobalPropertyi("a321neo/cockpit/draims/format_error", 0, false, true, false)--if the format error message is shown ---> 1 invalid freqency format, 2 VHF out of range, 3 ILS out of range, 4 ILS freq spacing error(not odd), 5 VOR out of range, 6 VOR freq spacing error, 7 ADF out of range, 8 sqwk out of range, 9 sqwk integer only, 10 cursor in use, 11 more than 1 decimal point, 12 only decimal points, 13 cursor and VHF is identical, 14 green cursor use only, 15 crs integer only, 16 crs out of range, 17 ADF int only, 18 ils xxx.x>x< not 0 or 5, 19 sqwk 0 to 7 per digit
DRAIMS_easter_egg = createGlobalPropertyi("a321neo/cockpit/draims/easter_egg", 0, false, true, false)--if the user clicks the empty scratchpad

VHF_1_freq_swapped = globalProperty("sim/cockpit2/radios/actuators/com1_right_is_selected")--if the left and the right side vhf 1 freqencies are swapped very useful
VHF_1_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com1_frequency_Mhz")--vhf 1 freq Mhz >xxx<.xx, range from 118.000 to 137.000
VHF_1_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com1_frequency_khz")--vhf 1 freq khz xxx.>xx<, range from 118.000 to 137.000
VHF_1_stby_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com1_standby_frequency_Mhz")--vhf 1 stby freq Mhz >xxx<.xx, range from 118.000 to 137.000
VHF_1_stby_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com1_standby_frequency_khz")--vhf 1 stby freq khz xxx.>xx<, range from 118.000 to 137.000
VHF_2_freq_swapped = globalProperty("sim/cockpit2/radios/actuators/com2_right_is_selected")--if the left and the right side vhf 2 freqencies are swapped very useful
VHF_2_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com2_frequency_Mhz")--vhf 2 freq Mhz >xxx<.xx, range from 118.000 to 137.000
VHF_2_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com2_frequency_khz")--vhf 2 freq khz xxx.>xx<, range from 118.000 to 137.000
VHF_2_stby_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com2_standby_frequency_Mhz")--vhf 2 stby freq Mhz >xxx<.xx, range from 118.000 to 137.000
VHF_2_stby_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com2_standby_frequency_khz")--vhf 2 stby freq khz xxx.>xx<, range from 118.000 to 137.000

DRAIMS_VHF_cursor_pos = createGlobalPropertyi("a321neo/cockpit/draims/vhf_cursor_position", 3, false, true, false)--DRAIMS VHF blue cursor position
DRAIMS_cursor_freq_Mhz = createGlobalPropertyi("a321neo/cockpit/draims/cursor_frequency_Mhz", 121, false, true, false)--vhf 3 guard freq khz xxx.>xx<, when touched should be 121.500
DRAIMS_cursor_freq_khz = createGlobalPropertyi("a321neo/cockpit/draims/cursor_guard_frequency_khz", 500, false, true, false)--vhf 3 guard freq khz xxx.>xx<, when touched should be 121.500
DRAIMS_NAV_cursor_pos = createGlobalPropertyi("a321neo/cockpit/draims/nav_cursor_position", 3, false, true, false)--DRAIMS NAV green cursor position

Audio_nav_selection = globalProperty("sim/cockpit2/radios/actuators/audio_nav_selection")--0=nav1, 1=nav2, 2=adf1, 3=adf2, 9=none
NAV_1_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/nav1_frequency_Mhz")--nav 1 freq Mhz >xxx<.xx, ILS range from 108.100 to 111.950 with xxx.>x<xx always being odd, VOR from 108.000 to 117.950 with 50 khz spacing and first 4 Mhz shared with ILS
NAV_1_freq_10khz = globalProperty("sim/cockpit2/radios/actuators/nav1_frequency_khz")--nav 1 freq khz xxx.>xx<, ILS range from 108.100 to 111.950 with xxx.>x<xx always being odd, VOR from 108.00 to 117.950 with 50 khz spacing and first 4 Mhz shared with ILS
NAV_1_capt_obs = globalProperty("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot")--captain nav 1 obs
NAV_1_fo_obs = globalProperty("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_copilot")--first officer nav 1 obs
ADF_1_freq_hz = globalProperty("sim/cockpit2/radios/actuators/adf1_frequency_hz")--adf 1 freq hz typically 190hz to 535hz
NAV_2_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_Mhz")--nav 2 freq Mhz >xxx<.xx, ILS range from 108.100 to 111.950 with xxx.>x<xx always being odd, VOR from 108.00 to 117.950 with 50 khz spacing and first 4 Mhz shared with ILS
NAV_2_freq_10khz = globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_khz")--nav 2 freq khz xxx.>xx<, ILS range from 108.100 to 111.950 with xxx.>x<xx always being odd, VOR from 108.00 to 117.950 with 50 khz spacing and first 4 Mhz shared with ILS
NAV_2_capt_obs = globalProperty("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot")--captain nav 2 obs
NAV_2_fo_obs = globalProperty("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_copilot")--first officer nav 2 obs
ADF_2_freq_hz = globalProperty("sim/cockpit2/radios/actuators/adf2_frequency_hz")--adf 2 freq hz typically 190hz to 535hz

Sqwk_identifying = globalProperty("sim/cockpit2/radios/indicators/transponder_id")--if the transponder is identifiying right now
Sqwk_code = globalProperty("sim/cockpit2/radios/actuators/transponder_code")--sqwk code range 0000 to 7777
Sqwk_mode = globalProperty("sim/cockpit2/radios/actuators/transponder_mode") --Transponder mode (off=0,stdby=1,on=2,test=3) --> a321 0off, 1stby, 2TA, 2RA
DRAIMS_Sqwk_mode = createGlobalPropertyi("a321neo/cockpit/draims/transponder_mode", 0, false, true, false)--0off, 1stby, 2TA, 3RA

VHF_transmit_dest = globalProperty("sim/cockpit2/radios/actuators/audio_com_selection")--6=com1,7=com2
VHF_transmit_dest_manual = globalProperty("sim/cockpit2/radios/actuators/audio_com_selection_man")--6=com1,7=com2, manual without auto switching monitor source
VHF_1_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/vhf_1_transmit_selected", 0, false, true, false)--0off, 1selected
VHF_2_transmit_selected = createGlobalPropertyi("a321neo/cockpit/draims/vhf_2_transmit_selected", 0, false, true, false)--0off, 1selected

DRAIMS_dynamic_NAV_audio_selected = createGlobalPropertyi("a321neo/cockpit/draims/dynamic_nav_audio_selected", 0, false, true, false)--0off, 1selected
DRAIMS_dynamic_NAV_volume = createGlobalPropertyf("a321neo/cockpit/draims/dynamic_nav_volume", 1, false, true, false)--volume of dynamic navigation audio

VHF_1_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_com1")
VHF_2_audio_selected = globalProperty("sim/cockpit2/radios/actuators/audio_selection_com2")
VHF_3_monitor_selected = createGlobalPropertyi("a321neo/cockpit/draims/vhf_3_monitor_selected", 0, false, true, false)--0off, 1selected(USE FOR DCDU DATALINK)
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

--source switching
Override_DMC = createGlobalPropertyi("a321neo/cockpit/source_switching/override_DMC", 0, false, true, false)--override display source control computers

Capt_pfd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/capt_pfd_displaying_status", 1, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam
Capt_nd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/capt_nd_displaying_status", 2, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam
Fo_pfd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/fo_pfd_displaying_status", 1, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam
Fo_nd_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/fo_nd_displaying_status", 2, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam
EWD_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/ewd_displaying_status", 3, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam
ECAM_displaying_status = createGlobalPropertyf("a321neo/cockpit/source_switching/ecam_displaying_status", 4, false, true, false)--source being displayed 1pfd, 2nd, 3ewd, 4ecam

--the index follows the source proirity[0,1,2,3] pfd, nd, ewd, ecam^^^^
Capt_pfd_show = createGlobalPropertyfa("a321neo/cockpit/source_switching/capt_pfd_show", 4, false, true, false)--used for source switching changing the positions of the screens(automated)
Capt_nd_show = createGlobalPropertyfa("a321neo/cockpit/source_switching/capt_nd_show", 4, false, true, false)--used for source switching changing the positions of the screens(automated)
Fo_pfd_show = createGlobalPropertyfa("a321neo/cockpit/source_switching/fo_pfd_show", 4, false, true, false)--used for source switching changing the positions of the screens(automated)
Fo_nd_show = createGlobalPropertyfa("a321neo/cockpit/source_switching/fo_nd_show", 4, false, true, false)--used for source switching changing the positions of the screens(automated)
EWD_show = createGlobalPropertyfa("a321neo/cockpit/source_switching/ewd_show", 4, false, true, false)--used for source switching changing the positions of the screens(automated)
ECAM_show = createGlobalPropertyfa("a321neo/cockpit/source_switching/ecam_show", 4, false, true, false)--used for source switching changing the positions of the screens(automated)

ECAM_on_nd_dial = createGlobalPropertyi("a321neo/cockpit/source_switching/ECAM_on_nd_dial", 0, false, true, false)--used to swap the position of the ECAM with the NDs 0capt, 1norm, 2FO

--engine & apu
Engine_mode_knob = createGlobalPropertyi("a321neo/cockpit/engine/engine_mode", 0, false, true, false) -- -1crank, 0norm, 1ignition
Engine_1_master_switch = createGlobalPropertyi("a321neo/cockpit/engine/master_1", 0, false, true, false)
Engine_2_master_switch = createGlobalPropertyi("a321neo/cockpit/engine/master_2", 0, false, true, false)
Engine_1_man_start  = createGlobalPropertyi("a321neo/cockpit/engine/manual_start_1", 0, false, true, false) -- 0: OFF (no show), 1: ON (blue)
Engine_2_man_start  = createGlobalPropertyi("a321neo/cockpit/engine/manual_start_2", 0, false, true, false) -- 0: OFF (no show), 1: ON (blue)
Engine_dual_cooling_light = createGlobalPropertyi("a321neo/cockpit/engine/dual_cooling", 0, false, true, false)   -- 0: OFF (no show), 1: ON (blue)

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

Ecam_fctl_is_rudder_ok     = createGlobalPropertyi("a321neo/cockpit/ecam/fctl_is_rudder_ok", 0, false, true, false) -- 1 ok, 0 not working
Ecam_fctl_is_aileron_ok    = createGlobalPropertyi("a321neo/cockpit/ecam/fctl_is_aileron_ok", 0, false, true, false) -- 1 ok, 0 not working
Ecam_fctl_is_elevator_R_ok   = createGlobalPropertyi("a321neo/cockpit/ecam/fctl_is_elevator_R_ok", 0, false, true, false) -- 1 ok, 0 not working
Ecam_fctl_is_elevator_L_ok   = createGlobalPropertyi("a321neo/cockpit/ecam/fctl_is_elevator_L_ok", 0, false, true, false) -- 1 ok, 0 not working
Ecam_fctl_is_pitch_trim_ok = createGlobalPropertyi("a321neo/cockpit/ecam/fctl_is_pitch_trim_ok", 0, false, true, false) -- 1 ok, 0 not working

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
Ecam_bleed_apu_valve     = createGlobalPropertyi("a321neo/cockpit/ecam/bleed/apu_valve", 0, false, true, false) -- This has an extra position: -1: hidden
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

--flight controls
Elev_trim_degrees = createGlobalPropertyf("a321neo/cockpit/controls/elevator_trim_degrees", 0, false, true, false)


--wheel
Cockpit_parkbrake_ratio = globalProperty("sim/cockpit2/controls/parking_brake_ratio")
Autobrakes = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes", 0, false, true, false) -- 0: off, 1: low, 2:med, 3:max
Nosewheel_Steering_and_AS_sw = createGlobalPropertyi("a321neo/cockpit/wheel/antiskid_steering", 0, false, true, false)  -- 0: off, 1: on

--aircond
Cab_hot_air = createGlobalPropertyi("a321neo/cockpit/aircond/cab_hot_air", 1, false, true, false)
Cargo_hot_air = createGlobalPropertyi("a321neo/cockpit/aircond/cargo_hot_air", 1, false, true, false)
Cockpit_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp_dial", 0.5, false, true, false) --cockpit temperature dial position
Front_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp_dial", 0.5, false, true, false) --front cabin temperature dial position
Aft_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp_dial", 0.5, false, true, false) --aft cabin temperature dial position
Aft_cargo_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cargo_temp_dial", 0.5, false, true, false) --aft cargo temperature dial position

Cargo_isolation_status = createGlobalPropertyi("a321neo/cockpit/aircond/light_cargo_isol", 0, false, true, false)     --00: No lights, 01: [ON], 10: FAULT, 11 [ON] + FAULT
Ventilation_light_blower = createGlobalPropertyi("a321neo/cockpit/aircond/light_blower", 0, false, true, false)     --00: No lights, 01: [OVRD], 10: FAULT, 11 [OVRD] + FAULT
Ventilation_light_extract = createGlobalPropertyi("a321neo/cockpit/aircond/light_extract", 0, false, true, false)     --00: No lights, 01: [OVRD], 10: FAULT, 11 [OVRD] + FAULT

Cabin_fan_button  = createGlobalPropertyi("a321neo/cockpit/aircond/cabin_fan", 0, false, true, false) -- 0 blank, 1 : [OFF]

--misc
Capt_ra_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_ra_alt_m", 0, false, true, false)
Capt_baro_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_baro_alt_m", 0, false, true, false)
Seatbelts = globalProperty("sim/cockpit2/annunciators/fasten_seatbelt")
NoSmoking = globalProperty("sim/cockpit2/annunciators/no_smoking")
CabinIsReady = createGlobalPropertyi("a321neo/cockpit/cabin_ready", 0, false, true, false)  -- 0 cabin is not ready, 1 cabin is ready

--MCDU
Mcdu_enabled = createGlobalPropertyi("a321neo/debug/mcdu/mcdu_enabled", 1, false, true, false)

-- ACARS & DCDU
DCDU_page_no = createGlobalPropertyi("a321neo/cockpit/DCDU/page_no", 0, false, true, false) -- Current page number, from 0
DCDU_msg_no  = createGlobalPropertyi("a321neo/cockpit/DCDU/msg_no" , 0, false, true, false) -- Current message number, from 0
DCDU_pages_total = createGlobalPropertyi("a321neo/cockpit/DCDU/pages_total", 0, false, true, false) -- Total number of pages
DCDU_msgs_total  = createGlobalPropertyi("a321neo/cockpit/DCDU/msgs_total" , 0, false, true, false) -- Total number of messages
DCDU_recall_mode = createGlobalPropertyi("a321neo/cockpit/DCDU/recall_mode" , 0, false, true, false) -- 1 if in recall mode, 0 otherwise
DCDU_new_msgs    = createGlobalPropertyi("a321neo/cockpit/DCDU/new_messages" , 0, false, true, false) -- 1 if at least one new message is present

-- ADIRS
ADIRS_light_onbat   = createGlobalPropertyi("a321neo/cockpit/ADIRS/on_bat", 0, false, true, false)   --0: OFF, 1: ON
ADIRS_light_IR = {}
ADIRS_light_ADR = {}
ADIRS_light_IR[1]   = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/light_IR1", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
ADIRS_light_IR[2]   = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/light_IR2", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
ADIRS_light_IR[3]   = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/light_IR3", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
ADIRS_light_ADR[1]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/light_ADR1", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
ADIRS_light_ADR[2]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/light_ADR2", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
ADIRS_light_ADR[3]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/light_ADR3", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT

ADIRS_rotary_btn = {}
ADIRS_rotary_btn[1]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/mode_1", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT
ADIRS_rotary_btn[2]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/mode_2", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT
ADIRS_rotary_btn[3]  = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/mode_3", 0, false, true, false)   -- 0 OFF, 1 NAV, 2 ATT

ADIRS_source_rotary_ATHDG   = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/atthdg_source", 0, false, true, false)    -- Pedestal switch, 0 NORM, -1 CAPT3, 1 FO3
ADIRS_source_rotary_AIRDATA = createGlobalPropertyi("a321neo/cockpit/ADIRS/buttons/airdata_source", 0, false, true, false)   -- Pedestal switch, 0 NORM, -1 CAPT3, 1 FO3


Adirs_capt_has_ADR    = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_ADR", 0, false, true, false) -- 0: FAIL, 1: OK. It provides: altitude, airspeed, mach, AoA, temperature, overspeed warning
Adirs_capt_has_IR     = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_IR", 0, false, true, false) -- 0: FAIL, 1: partial, 2: complete. It provides: attitude (1,2), heading (1,2), track (only 2), accelerations (only 2), angular rates (only 2), ground speed (only 2), position (only 2)
Adirs_capt_has_ATT  = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_ATT", 0, false, true, false) -- Captain has attitude information
Adirs_capt_has_ATT_blink  = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_ATT_blinking", 0, false, true, false) -- Captain has attitude information (blinking)

Adirs_capt_has_ADR_blink = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_ADR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages
Adirs_capt_has_IR_blink  = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_IR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages

Adirs_fo_has_ADR    = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_ADR", 0, false, true, false) -- 0: FAIL, 1: OK. It provides: altitude, airspeed, mach, AoA, temperature, overspeed warning
Adirs_fo_has_IR     = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_IR", 0, false, true, false) -- 0: FAIL, 1: partial, 2: complete. It provides: attitude (1,2), heading (1,2), track (only 2), accelerations (only 2), angular rates (only 2), ground speed (only 2), position (only 2)
Adirs_fo_has_ATT  = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_ATT", 0, false, true, false) -- Captain has attitude information
Adirs_fo_has_ADR_blink = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_ADR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages
Adirs_fo_has_IR_blink  = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_IR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages
Adirs_fo_has_ATT_blink  = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_ATT_blinking", 0, false, true, false) -- F/O has attitude information (blinking)

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

-- Failures
MasterCaution         = createGlobalPropertyi("a321neo/failures/master_caution", 0, false, true, false) -- Button light dataref - 0: OFF, 1: ON
MasterWarning         = createGlobalPropertyi("a321neo/failures/master_warning", 0, false, true, false) -- Button light dataref - 0: OFF, 1: ON
MasterWarningBlinking = createGlobalPropertyi("a321neo/failures/master_warning_blink", 0, false, true, false) -- Button light dataref - 0: OFF, 1: ON


-- HYD
Hyd_light_Eng1Pump  = createGlobalPropertyi("a321neo/cockpit/HYD/buttons/Eng1_pump", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_Eng2Pump  = createGlobalPropertyi("a321neo/cockpit/HYD/buttons/Eng2_pump", 0, false, true, false)   --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_PTU       = createGlobalPropertyi("a321neo/cockpit/HYD/buttons/PTU", 0, false, true, false)         --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_B_ElecPump= createGlobalPropertyi("a321neo/cockpit/HYD/buttons/B_Elec_pump", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_Y_ElecPump= createGlobalPropertyi("a321neo/cockpit/HYD/buttons/Y_Elec_pump", 0, false, true, false) --00: No lights, 01: [ON],  10: FAULT, 11 [ON] + FAULT

-- ELEC
Elec_light_battery_1  = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/battery_1", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Elec_light_battery_2  = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/battery_2", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT

Elec_light_Galley       = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/galley", 0, false, true, false)      --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Elec_light_AC_ess_feed  = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/AC_ess_feed", 0, false, true, false) --00: No lights, 01: [ALTN], 10: FAULT, 11 [ALTN] + FAULT
Elec_light_BUS_tie      = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/BUS_tie", 0, false, true, false)     --00: No lights, 01: [OFF]
Elec_light_IDG1         = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/IDG1", 0, false, true, false)        --00: No lights, 10: FAULT
Elec_light_IDG2         = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/IDG2", 0, false, true, false)        --00: No lights, 10: FAULT
Elec_light_GEN1         = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/GEN1", 0, false, true, false)        --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Elec_light_GEN2         = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/GEN2", 0, false, true, false)        --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Elec_light_APU_GEN      = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/APU_GEN", 0, false, true, false)     --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Elec_light_EXT_PWR      = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/EXT_PWR", 0, false, true, false)     --00: No lights, 01: [ON], 10: AVAIL, 11 [ON] + AVAIL

Elec_light_EMER_GEN1_LINE= createGlobalPropertyi("a321neo/cockpit/electrical/buttons/EMER_GEN_1_LINE", 0, false, true, false) --00: No lights, 01: [OFF], 10: SMOKE, 11 [OFF] + SMOKE
Elec_light_RAT_FAULT     = createGlobalPropertyi("a321neo/cockpit/electrical/buttons/EMER_RAT_FAULT", 0, false, true, false)  --00: No lights, 10: FAULT


Elec_bat_1_V  = createGlobalPropertyf("a321neo/cockpit/electrical/battery_1_voltage", 0, false, true, false)
Elec_bat_2_V  = createGlobalPropertyf("a321neo/cockpit/electrical/battery_2_voltage", 0, false, true, false)

-- ISIS
ISIS_landing_system_enabled = createGlobalPropertyi("a321neo/cockpit/ISIS/isis_ls_enabled", 0, false, true, false)-- LS status for the ISIS: 0-off, 1-on
ISIS_powered = createGlobalPropertyi("a321neo/cockpit/ISIS/isis_is_powered", 0, false, true, false)-- ISIS is powered: 0-no, 1-yes
ISIS_ready   = createGlobalPropertyi("a321neo/cockpit/ISIS/isis_is_ready", 0, false, true, false)-- ISIS is ready to use: 0-off, 1-on

-- Fuel
Fuel_light_pumps = createGlobalPropertyia("a321neo/cockpit/fuel/buttons/pumps", 8)  -- Array [0]=L1, [1]=L2, [2]=R1, [3]=R2, [4]=C1, [5]=C2, [6]=ACT, [7]=RCT
                                                                            -- 00: no lights, 01: OFF (FWD for ACT and RCT), 10: FAULT, 11: FAULT+OFF (FWD for ACT and RCT)
Fuel_light_mode_sel = createGlobalPropertyi("a321neo/cockpit/fuel/buttons/c_mode_sel", 0, false, true, false)      --00: No lights, 01: [MAN], 10: FAULT, 11 [MAN] + FAULT
Fuel_light_x_feed   = createGlobalPropertyi("a321neo/cockpit/fuel/buttons/x_feed", 0, false, true, false)      --00: No lights, 01: [ON], 10: OPEN, 11 [ON] + OPEN
Fuel_is_refuelG     = createGlobalPropertyi("a321neo/cockpit/fuel/refuelg", 0, false, true, false) -- Refuel panel is active (1: yes, 0 : no)

-- Fire
Fire_pb_APU_status = createGlobalPropertyi("a321neo/cockpit/fire/buttons/APU_pb", 0, false, true, false) 
Fire_pb_ENG1_status = createGlobalPropertyi("a321neo/cockpit/fire/buttons/ENG1_pb", 0, false, true, false) 
Fire_pb_ENG2_status = createGlobalPropertyi("a321neo/cockpit/fire/buttons/ENG2_pb", 0, false, true, false) 

-- EWD
EWD_engine_avail_ind_1_start = createGlobalPropertyi("a321neo/cockpit/ewd/ENG1_avail_indicator_start", 0, false, true, false) -- Time point when the engine is avail
EWD_engine_avail_ind_2_start = createGlobalPropertyi("a321neo/cockpit/ewd/ENG2_avail_indicator_start", 0, false, true, false) -- Time point when the engine is avail
EWD_engine_avail_ind_1 = createGlobalPropertyi("a321neo/cockpit/ewd/ENG1_avail_indicator", 0, false, true, false) -- 1 : avail showed, 0 : none
EWD_engine_avail_ind_2 = createGlobalPropertyi("a321neo/cockpit/ewd/ENG2_avail_indicator", 0, false, true, false) -- 1 : avail showed, 0 : none
EWD_engine_1_rev_ind = createGlobalPropertyi("a321neo/cockpit/ewd/ENG1_rev_ind", 0, false, true, false) -- 0: no rev, 2: rev amber, 2: rev amber HIGH, 4: rev green
EWD_engine_2_rev_ind = createGlobalPropertyi("a321neo/cockpit/ewd/ENG2_rev_ind", 0, false, true, false) -- 0: no rev, 2: rev amber, 2: rev amber HIGH, 4: rev green
EWD_engine_1_XX = createGlobalPropertyi("a321neo/cockpit/EWD/ENG1_XX", 0, false, true, false) -- 0: normal, 1: XX on engine parameters
EWD_engine_2_XX = createGlobalPropertyi("a321neo/cockpit/EWD/ENG2_XX", 0, false, true, false) -- 0: normal, 1: XX on engine parameters

EWD_engine_cooling      = createGlobalPropertyia("a321neo/cockpit/EWD/ENG_cooling", 2) -- 0: no cooling, 1: cooling procedure
EWD_engine_cooling_time = createGlobalPropertyia("a321neo/cockpit/EWD/ENG_cooling_time", 2) -- time left

--ENG
L_sim_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[0]")
R_sim_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[1]")
L_throttle_blue_dot = createGlobalPropertyf("a321neo/cockpit/engine/l_lever_blue_dot", 0, false, true, false)
R_throttle_blue_dot = createGlobalPropertyf("a321neo/cockpit/engine/r_lever_blue_dot", 0, false, true, false)

-- AI
AI_Eng_1_button_light = createGlobalPropertyi("a321neo/cockpit/anti_ice/ai_eng_1", 0, false, true, false) --00: No lights, 01: [ON],  10: FAULT, 11 [ON] + FAULT
AI_Eng_2_button_light = createGlobalPropertyi("a321neo/cockpit/anti_ice/ai_eng_2", 0, false, true, false) --00: No lights, 01: [ON],  10: FAULT, 11 [ON] + FAULT
AI_Wing_button_light  = createGlobalPropertyi("a321neo/cockpit/anti_ice/ai_wing", 0, false, true, false)  --00: No lights, 01: [ON],  10: FAULT, 11 [ON] + FAULT
AI_probe_window_heat  = createGlobalPropertyi("a321neo/cockpit/anti_ice/probe_window", 0, false, true, false)  --00: No lights, 01: [ON],  10: FAULT, 11 [ON] + FAULT
No_ice_detected       = createGlobalPropertyi("a321neo/cockpit/anti_ice/no_ice_detected", 0, false, true, false) --0: ice detected or system off, 1: no ice detected and system ON

-- DMC
DMC_position_dmc_eis = createGlobalPropertyi("a321neo/cockpit/dmc/dmc_eis_sel_position", 0, false, true, false) -- usual -1, 0, 1
DMC_position_ecam_nd = createGlobalPropertyi("a321neo/cockpit/dmc/ecan_nd_xfr_position", 0, false, true, false) -- usual -1, 0, 1

