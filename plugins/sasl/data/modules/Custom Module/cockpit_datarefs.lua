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

--draims
DRAIMS_current_page = createGlobalPropertyi("a321neo/cockpit/draims/current_page", 1, false, true, false)--the page the draims unit is currently displaying 1VHF, 2HFs, 3TEL, 4ATC, 5MENU, 6NAV, 7ILS, 8VOR, 9ADF
DRAIMS_line_1_speaker_shown = createGlobalPropertyi("a321neo/cockpit/draims/line_1_speaker_shown", 0, false, true, false)--if the little speaker on the first line is shown
DRAIMS_line_2_speaker_shown = createGlobalPropertyi("a321neo/cockpit/draims/line_2_speaker_shown", 0, false, true, false)--if the little speaker on the second line is shown
DRAIMS_line_3_speaker_shown = createGlobalPropertyi("a321neo/cockpit/draims/line_3_speaker_shown", 0, false, true, false)--if the little speaker on the third line is shown
DRAIMS_format_error = createGlobalPropertyi("a321neo/cockpit/draims/format_error", 0, false, true, false)--if the format error message is shown
Radio_nav_selection = globalProperty("sim/cockpit2/radios/actuators/audio_nav_selection")--0=nav1, 1=nav2, 2=adf1, 3=adf2, 9=none

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
Max_speed = createGlobalPropertyf("a321neo/cockpit/PFD/max_speed", 330, false, true, false)
Max_speed_delta = createGlobalPropertyf("a321neo/cockpit/PFD/max_speed_delta", 0, false, true, false)

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

--wheel
Cockpit_parkbrake_ratio = globalProperty("sim/cockpit2/controls/parking_brake_ratio")
Autobrakes = createGlobalPropertyi("a321neo/cockpit/wheel/autobrakes", 0, false, true, false) -- 0: off, 1: low, 2:med, 3:max

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
