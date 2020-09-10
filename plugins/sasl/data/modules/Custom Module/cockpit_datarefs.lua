--ALL DATAREFS USED IN THE COCKPIT, e.g DIALS, KNOBS, BUTTONS--
--PUSH BUTTON STATES-- e.g the lights on the buttons(blank, on, fault, fault on) these datarefs should follow the 00, 01, 10, 11 principle
--apu
Apu_start_button_state = createGlobalPropertyi("a321neo/cockpit/engine/apu_start_button_state", 0, false, true, false)--follow 00, 01, 10, 11 for the buttons(black, on, fault, fault on)
Apu_master_button_state = createGlobalPropertyi("a321neo/cockpit/engine/apu_master_button_state", 0, false, true, false)--follow 00, 01, 10, 11 for the buttons
--wheel
Brake_fan_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/brake_fan_button_state", 0, false, true, false)--blank, on, hot, hot on
Autobrakes_lo_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes_lo_button_state", 0, false, true, false)--blank, on, decel(should not happen), decel on
Autobrakes_med_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes_med_button_state", 0, false, true, false)--blank, on, decel(should not happen), decel on
Autobrakes_max_button_state = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes_max_button_state", 0, false, true, false)--blank, on, decel(should not happen), decel on

--BUTTON COMMANDED POSTION-- e.g. button commanding on, off but lights on the button can show otherwise(fault on, fault off....)
Eng1_bleed_off_button = createGlobalPropertyi("a321neo/cockpit/packs/eng1_bleed_off", 0, false, true, false) --0 is on 1 if off
Eng2_bleed_off_button = createGlobalPropertyi("a321neo/cockpit/packs/eng2_bleed_off", 0, false, true, false) --0 is on 1 if off
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
Eng_1_FF_kgm = createGlobalPropertyf("a321neo/cockpit/engine/engine_1_fuel_flow_kg_min", 0, false, true, false)
Eng_2_FF_kgm = createGlobalPropertyf("a321neo/cockpit/engine/engine_2_fuel_flow_kg_min", 0, false, true, false)

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

-- ECAM
Ecam_previous_page  = createGlobalPropertyi("a321neo/cockpit/ecam/previous", 13, false, true, false) --1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS
Ecam_current_page   = createGlobalPropertyi("a321neo/cockpit/ecam/page_num", 13, false, true, false) --1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS

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
Nosewheel_Steering_and_AS = globalProperty("sim/cockpit2/controls/nosewheel_steer_on") -- 0: off, 1: on

--aircond
Cab_hot_air = createGlobalPropertyi("a321neo/cockpit/aircond/cab_hot_air", 1, false, true, false)
Cargo_hot_air = createGlobalPropertyi("a321neo/cockpit/aircond/cargo_hot_air", 1, false, true, false)
Cockpit_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp_dial", 0.5, false, true, false) --cockpit temperature dial position
Front_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp_dial", 0.5, false, true, false) --front cabin temperature dial position
Aft_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp_dial", 0.5, false, true, false) --aft cabin temperature dial position
Aft_cargo_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cargo_temp_dial", 0.5, false, true, false) --aft cargo temperature dial position

--packs
X_bleed_dial = createGlobalPropertyi("a321neo/cockpit/packs/x_bleed_dial", 1, false, true, false) --0closed, 1auto, 2open
A321_Pack_Flow_dial = createGlobalPropertyi("a321neo/cockpit/packs/pack_flow_dial", 0, false, true, false) --the pack flow dial 0low, 1norm, 2high

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
Adirs_capt_has_ADR_blink = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_ADR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages
Adirs_capt_has_IR_blink  = createGlobalPropertyi("a321neo/cockpit/ADIRS/capt_has_IR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages

Adirs_fo_has_ADR    = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_ADR", 0, false, true, false) -- 0: FAIL, 1: OK. It provides: altitude, airspeed, mach, AoA, temperature, overspeed warning
Adirs_fo_has_IR     = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_IR", 0, false, true, false) -- 0: FAIL, 1: partial, 2: complete. It provides: attitude (1,2), heading (1,2), track (only 2), accelerations (only 2), angular rates (only 2), ground speed (only 2), position (only 2)
Adirs_fo_has_ADR_blink = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_ADR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages
Adirs_fo_has_IR_blink  = createGlobalPropertyi("a321neo/cockpit/ADIRS/fo_has_IR_blinking", 0, false, true, false) -- This is used for blinking the PFD messages

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
Hyd_light_Eng1Pump  = createGlobalPropertyi("a321neo/cockpit/HYD/buttons/Eng1_pump", 0, false, true, false)          --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_Eng2Pump  = createGlobalPropertyi("a321neo/cockpit/HYD/buttons/Eng2_pump", 0, false, true, false)          --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_PTU       = createGlobalPropertyi("a321neo/cockpit/HYD/buttons/PTU", 0, false, true, false)                --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_B_ElecPump= createGlobalPropertyi("a321neo/cockpit/HYD/buttons/B_Elec_pump", 0, false, true, false) --00: No lights, 01: [OFF], 10: FAULT, 11 [OFF] + FAULT
Hyd_light_Y_ElecPump= createGlobalPropertyi("a321neo/cockpit/HYD/buttons/Y_Elec_pump", 0, false, true, false) --00: No lights, 01: [ON],  10: FAULT, 11 [ON] + FAULT


