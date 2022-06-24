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
-- File: cockpit_commands.lua 
-- Short description: All the commands are registered or created here
-------------------------------------------------------------------------------

--ALL COMMANDS USED IN THE COCKPIT, e.g PUSHBUTTONS--

--popup commands--
Pop_out_CAPT_PFD = sasl.createCommand("a321neo/cockpit/popups/pop_out_capt_pfd", "Pop out the CAPT PFD")
Pop_out_FO_PFD =   sasl.createCommand("a321neo/cockpit/popups/Pop_out_fo_pfd", "Pop out the FO PFD")
Pop_out_CAPT_ND =  sasl.createCommand("a321neo/cockpit/popups/Pop_out_capt_nd", "Pop out the CAPT ND")
Pop_out_FO_ND =    sasl.createCommand("a321neo/cockpit/popups/Pop_out_fo_nd", "Pop out the FO ND")
Pop_out_EWD =      sasl.createCommand("a321neo/cockpit/popups/pop_out_ewd", "Pop out the EWD")
Pop_out_ECAM =     sasl.createCommand("a321neo/cockpit/popups/Pop_out_ecam", "Pop out the ECAM")
Pop_out_ISIS =     sasl.createCommand("a321neo/cockpit/popups/Pop_out_isis", "Pop out the ISIS")

-- Buttons with light (check cockpit_datarefs.lua for light datarefs):
Ecam_btn_cmd_ENG   = createCommand("a321neo/cockpit/ecam/buttons/cmd_eng", "ENG pushbutton")
Ecam_btn_cmd_BLEED = createCommand("a321neo/cockpit/ecam/buttons/cmd_bleed", "BLEED pushbutton")
Ecam_btn_cmd_PRESS = createCommand("a321neo/cockpit/ecam/buttons/cmd_press", "PRESS pushbutton")
Ecam_btn_cmd_ELEC  = createCommand("a321neo/cockpit/ecam/buttons/cmd_elec", "ELEC pushbutton")
Ecam_btn_cmd_HYD   = createCommand("a321neo/cockpit/ecam/buttons/cmd_hyd", "HYD pushbutton")
Ecam_btn_cmd_FUEL  = createCommand("a321neo/cockpit/ecam/buttons/cmd_fuel", "FUEL pushbutton")
Ecam_btn_cmd_APU   = createCommand("a321neo/cockpit/ecam/buttons/cmd_apu", "APU pushbutton")
Ecam_btn_cmd_COND  = createCommand("a321neo/cockpit/ecam/buttons/cmd_cond", "COND pushbutton")
Ecam_btn_cmd_DOOR  = createCommand("a321neo/cockpit/ecam/buttons/cmd_door", "DOOR pushbutton")
Ecam_btn_cmd_WHEEL = createCommand("a321neo/cockpit/ecam/buttons/cmd_wheel", "WHEEL pushbutton")
Ecam_btn_cmd_FCTL  = createCommand("a321neo/cockpit/ecam/buttons/cmd_fctl", "FCTL pushbutton")
Ecam_btn_cmd_CLR   = createCommand("a321neo/cockpit/ecam/buttons/cmd_clr", "CLR pushbutton")
Ecam_btn_cmd_STS   = createCommand("a321neo/cockpit/ecam/buttons/cmd_sts", "STS pushbutton")

-- No light buttons:
Ecam_btn_cmd_TOCFG = createCommand("a321neo/cockpit/ecam/buttons/cmd_toconfig", "T.O CONFIG pushbutton")
Ecam_btn_cmd_EMERC = createCommand("a321neo/cockpit/ecam/buttons/cmd_emercanc", "EMER CANC pushbutton")
Ecam_btn_cmd_ALL   = createCommand("a321neo/cockpit/ecam/buttons/cmd_all", "ALL pushbutton")
Ecam_btn_cmd_RCL   = createCommand("a321neo/cockpit/ecam/buttons/cmd_rcl", "RCL pushbutton")

-- DMC
DMC_PFD_ND_xfr_capt = createCommand("a321neo/cockpit/dmc/pdf_nd_xfr_capt", "Captain's side PFD/ND xfr")
DMC_PFD_ND_xfr_fo   = createCommand("a321neo/cockpit/dmc/pdf_nd_xfr_fo", "FO's side PFD/ND xfr")
DMC_EIS_selector_up = createCommand("a321neo/cockpit/dmc/dmc_eis_sel_up", "EIS DMC knob")
DMC_EIS_selector_dn = createCommand("a321neo/cockpit/dmc/dmc_eis_sel_dn", "EIS DMC knob")
DMC_ECAM_ND_xfr_up  = createCommand("a321neo/cockpit/dmc/ecam_nd_xfr_up", "EIS DMC knob")
DMC_ECAM_ND_xfr_dn  = createCommand("a321neo/cockpit/dmc/ecam_nd_xfr_dn", "EIS DMC knob")


--wheels
Toggle_brake_fan = createCommand("a321neo/cockpit/wheel/toggle_brake_fan", "Toggle brake fan")
Toggle_lo_autobrake = createCommand("a321neo/cockpit/wheel/toggle_lo_autobrake", "Toggle LO autobrake")
Toggle_med_autobrake = createCommand("a321neo/cockpit/wheel/toggle_med_autobrake", "Toggle MED autobrake")
Toggle_max_autobrake = createCommand("a321neo/cockpit/wheel/toggle_max_autobrake", "Toggle MAX autobrake")
Toggle_antiskid_ns   = createCommand("a321neo/cockpit/wheel/toggle_antiskid_ns", "Toggle A/SKID and N/W STRG")
Toggle_park_brake    = createCommand("a321neo/cockpit/wheel/toggle_park_brake", "Toggle Park Brake")
-- Airbus TCA support - TCA quadrant has a dial switch and no toggle push buttons
TCA_disable_autobrake= createCommand("a321neo/cockpit/wheel/autobrake_disable", "Disable autobrake")
TCA_park_brake_set   = createCommand("a321neo/cockpit/wheel/park_break_set", "Set parking brake")
Toggle_park_brake_XP    = findCommand("sim/flight_controls/brakes_toggle_max")
Push_brake_regular_XP = findCommand("sim/flight_controls/brakes_regular")
Toggle_brake_regular_XP = findCommand("sim/flight_controls/brakes_toggle_regular")

--brightness control
Capt_PFD_brightness_up = createCommand("a321neo/cockpit/brightness/capt_pfd_brightness_up", "Captain PFD brightness up")
Capt_PFD_brightness_dn = createCommand("a321neo/cockpit/brightness/capt_pfd_brightness_dn", "Captain PFD brightness down")
Capt_ND_brightness_up = createCommand("a321neo/cockpit/brightness/capt_nd_brightness_up", "Captain ND brightness up")
Capt_ND_brightness_dn = createCommand("a321neo/cockpit/brightness/capt_nd_brightness_dn", "Captain ND brightness down")
Fo_PFD_brightness_up = createCommand("a321neo/cockpit/brightness/fo_pfd_brightness_up", "First Officer PFD brightness up")
Fo_PFD_brightness_dn = createCommand("a321neo/cockpit/brightness/fo_pfd_brightness_dn", "First Officer PFD brightness down")
Fo_ND_brightness_up = createCommand("a321neo/cockpit/brightness/fo_nd_brightness_up", "First Officer ND brightness up")
Fo_ND_brightness_dn = createCommand("a321neo/cockpit/brightness/fo_nd_brightness_dn", "First Officer ND brightness down")

Capt_ND_picture_brightness_up = createCommand("a321neo/cockpit/brightness/capt_nd_picture_brightness_up", "First Officer ND brightness up terrain")
Capt_ND_picture_brightness_dn = createCommand("a321neo/cockpit/brightness/capt_nd_picture_brightness_dn", "First Officer ND brightness down terrain" )
Fo_ND_picture_brightness_up = createCommand("a321neo/cockpit/brightness/fo_nd_picture_brightness_up", "First Officer ND brightness up terrain")
Fo_ND_picture_brightness_dn = createCommand("a321neo/cockpit/brightness/fo_nd_picture_brightness_dn", "First Officer ND brightness down terrain")

EWD_brightness_up = createCommand("a321neo/cockpit/brightness/ewd_brightness_up", "EWD brightness up")
EWD_brightness_dn = createCommand("a321neo/cockpit/brightness/ewd_brightness_dn", "EWD brightness down")
ECAM_brightness_up = createCommand("a321neo/cockpit/brightness/ecam_brightness_up", "ECAM brightness up")
ECAM_brightness_dn = createCommand("a321neo/cockpit/brightness/ecam_brightness_dn", "ECAM brightness down")
DCDU_1_brightness_up = createCommand("a321neo/cockpit/brightness/dcdu_1_brightness_up", "DCDU 1 brightness up")
DCDU_1_brightness_dn = createCommand("a321neo/cockpit/brightness/dcdu_1_brightness_dn", "DCDU 1 brightness down")
DCDU_2_brightness_up = createCommand("a321neo/cockpit/brightness/dcdu_2_brightness_up", "DCDU 2 brightness up")
DCDU_2_brightness_dn = createCommand("a321neo/cockpit/brightness/dcdu_2_brightness_dn", "DCDU 2 brightness down")
MCDU_1_brightness_up = createCommand("a321neo/cockpit/brightness/mcdu_1_brightness_up", "MCDU 1 brightness up")
MCDU_1_brightness_dn = createCommand("a321neo/cockpit/brightness/mcdu_1_brightness_dn", "MCDU 1 brightness down")
MCDU_2_brightness_up = createCommand("a321neo/cockpit/brightness/mcdu_2_brightness_up", "MCDU 2 brightness up")
MCDU_2_brightness_dn = createCommand("a321neo/cockpit/brightness/mcdu_2_brightness_dn", "MCDU 2 brightness down")
DRAIMS_1_brightness_up = createCommand("a321neo/cockpit/brightness/draims_1_brightness_up", "DRAIMS 1 brightness up")
DRAIMS_1_brightness_dn = createCommand("a321neo/cockpit/brightness/draims_1_brightness_dn", "DRAIMS 1 brightness down")
DRAIMS_2_brightness_up = createCommand("a321neo/cockpit/brightness/draims_2_brightness_up", "DRAIMS 2 brightness up")
DRAIMS_2_brightness_dn = createCommand("a321neo/cockpit/brightness/draims_2_brightness_dn", "DRAIMS 2 brightness down")
ISIS_brightness_up = createCommand("a321neo/cockpit/brightness/isis_brightness_up", "ISIS brightness up")
ISIS_brightness_dn = createCommand("a321neo/cockpit/brightness/isis_brightness_dn", "ISIS brightness down")

Sqwk_ident = sasl.findCommand("sim/transponder/transponder_ident")

--aircond
Toggle_cab_hotair = createCommand("a321neo/cockpit/aircond/toggle_cab_hotair", "Toggle cabin hot air")
Toggle_cargo_hotair = createCommand("a321neo/cockpit/aircond/toggle_cargo_hotair", "Toggle cargo hot air")
Toggle_aft_cargo_iso_valve = createCommand("a321neo/cockpit/aircond/toggle_aft_cargo_iso_valve", "Toggle aft cargo iso valve")
Cockpit_temp_dial_up = createCommand("a321neo/cockpit/aircond/cockpit_temp_dial_up", "Cockpit temp dial up")
Cockpit_temp_dial_dn = createCommand("a321neo/cockpit/aircond/cockpit_temp_dial_dn", "Cockpit temp dial down")
Front_cab_temp_dial_up = createCommand("a321neo/cockpit/aircond/front_cab_temp_dial_up", "Front cab temp dia up")
Front_cab_temp_dial_dn = createCommand("a321neo/cockpit/aircond/front_cab_temp_dial_dn", "Front cab temp dial down")
Aft_cab_temp_dial_up = createCommand("a321neo/cockpit/aircond/aft_cab_temp_dial_up", "Aft cab temp dial up")
Aft_cab_temp_dial_dn = createCommand("a321neo/cockpit/aircond/aft_cab_temp_dial_dn", "Aft cab temp dial down")
Aft_cargo_temp_dial_up = createCommand("a321neo/cockpit/aircond/aft_cargo_temp_dial_up", "Aft cargo temp dial up")
Aft_cargo_temp_dial_dn = createCommand("a321neo/cockpit/aircond/aft_cargo_temp_dial_dn", "Aft cargo temp dial down")
Toggle_cab_fan = createCommand("a321neo/cockpit/aircond/cab_fan", "Toggle CAB FANS button")

--packs & bleed
Toggle_eng1_bleed = createCommand("a321neo/cockpit/bleed/toggle_eng1_bleed", "Toggle ENG 1 bleed")
Toggle_eng2_bleed = createCommand("a321neo/cockpit/bleed/toggle_eng2_bleed", "Toggle ENG 2 bleed")
Toggle_apu_bleed = createCommand("a321neo/cockpit/bleed/toggle_apu_bleed", "Toggle APU bleed")
X_bleed_dial_up = createCommand("a321neo/cockpit/packs/x_bleed_dial_up", "x bleed dial up")
X_bleed_dial_dn = createCommand("a321neo/cockpit/packs/x_bleed_dial_dn", "x bleed dial down")
Toggle_pack1 = createCommand("a321neo/cockpit/packs/toggle_pack1", "Toggle PACK 1")
Toggle_pack2 = createCommand("a321neo/cockpit/packs/toggle_pack2", "Toggle PACK 2")
Toggle_ram_air = createCommand("a321neo/cockpit/bleed/ram_air", "Toggle RAM AIR")
Toggle_ECON_flow = createCommand("a321neo/cockpit/packs/toggle_ECON_flow", "Toggle ECON flow pb")

-- Press
Press_mode_sel = createCommand("a321neo/cockpit/pressurization/mode_sel", "Press mode sel button")
Press_ditching = createCommand("a321neo/cockpit/pressurization/ditching", "Press DITCHING button")
Press_ldg_elev_dial_dn = createCommand("a321neo/cockpit/pressurization/ldg_elev_dn", "LDG ELEV dial down")
Press_ldg_elev_dial_up = createCommand("a321neo/cockpit/pressurization/ldg_elev_up", "LDG ELEV dial up")
Press_manual_control_dn = createCommand("a321neo/cockpit/pressurization/manual_control_dn", "MAN V/S CTL down")
Press_manual_control_up = createCommand("a321neo/cockpit/pressurization/manual_control_up", "MAN V/S CTL up")

-- DCDU
DCDU_cmd_msg_plus = createCommand("a321neo/cockpit/DCDU/msg_plus", "Next Message")
DCDU_cmd_msg_minus = createCommand("a321neo/cockpit/DCDU/msg_minus", "Previous Message")
DCDU_cmd_page_plus = createCommand("a321neo/cockpit/DCDU/page_plus", "Next Page")
DCDU_cmd_page_minus = createCommand("a321neo/cockpit/DCDU/page_minus", "Previous Page")
DCDU_cmd_left_btm = createCommand("a321neo/cockpit/DCDU/left_btm", "Button Bottom-Left")
DCDU_cmd_left_top = createCommand("a321neo/cockpit/DCDU/left_top", "Button Top-Left")
DCDU_cmd_right_btm = createCommand("a321neo/cockpit/DCDU/right_btm", "Button Bottom-Right")
DCDU_cmd_right_top = createCommand("a321neo/cockpit/DCDU/right_top", "Button Top-Right")

DCDU_cmd_atc_msg_pb = createCommand("a321neo/cockpit/DCDU/atc_msg_pb", "ATC MSG pushbutton")

-- ADIRS
ADIRS_cmd_ADR1 = createCommand("a321neo/cockpit/ADIRS/ADR1_cmd", "Toggle ADR 1")
ADIRS_cmd_ADR2 = createCommand("a321neo/cockpit/ADIRS/ADR2_cmd", "Toggle ADR 2")
ADIRS_cmd_ADR3 = createCommand("a321neo/cockpit/ADIRS/ADR3_cmd", "Toggle ADR 3")
ADIRS_cmd_IR1 = createCommand("a321neo/cockpit/ADIRS/IR1_cmd", "Toggle IR 1")
ADIRS_cmd_IR2 = createCommand("a321neo/cockpit/ADIRS/IR2_cmd", "Toggle IR 2")
ADIRS_cmd_IR3 = createCommand("a321neo/cockpit/ADIRS/IR3_cmd", "Toggle IR 3")

ADIRS_cmd_knob_1_up   = createCommand("a321neo/cockpit/ADIRS/knob_1_up", "Move right the knob")
ADIRS_cmd_knob_2_up   = createCommand("a321neo/cockpit/ADIRS/knob_2_up", "Move right the knob")
ADIRS_cmd_knob_3_up   = createCommand("a321neo/cockpit/ADIRS/knob_3_up", "Move right the knob")
ADIRS_cmd_knob_1_down = createCommand("a321neo/cockpit/ADIRS/knob_1_down", "Move left the knob")
ADIRS_cmd_knob_2_down = createCommand("a321neo/cockpit/ADIRS/knob_2_down", "Move left the knob")
ADIRS_cmd_knob_3_down = createCommand("a321neo/cockpit/ADIRS/knob_3_down", "Move left the knob")

ADIRS_cmd_source_ATHDG_up     = createCommand("a321neo/cockpit/ADIRS/ATHDG_up", "Move right the knob")
ADIRS_cmd_source_AIRDATA_up   = createCommand("a321neo/cockpit/ADIRS/AIRDATA_up", "Move right the knob")
ADIRS_cmd_source_ATHDG_down   = createCommand("a321neo/cockpit/ADIRS/ATHDG_down", "Move left the knob")
ADIRS_cmd_source_AIRDATA_down = createCommand("a321neo/cockpit/ADIRS/AIRDATA_down", "Move left the knob")

--doors
Door_1_l_toggle = createCommand("a321neo/cockpit/door/toggle_door_1_l", "Open/Close door 1 L")
Door_1_r_toggle = createCommand("a321neo/cockpit/door/toggle_door_1_r", "Open/Close door 1 R")
Door_2_l_toggle = createCommand("a321neo/cockpit/door/toggle_door_2_l", "Open/Close door 2 L")
Door_2_r_toggle = createCommand("a321neo/cockpit/door/toggle_door_2_r", "Open/Close door 2 R")
Door_3_l_toggle = createCommand("a321neo/cockpit/door/toggle_door_3_l", "Open/Close door 3 L")
Door_3_r_toggle = createCommand("a321neo/cockpit/door/toggle_door_3_r", "Open/Close door 3 R")
Overwing_exit_1_l_toggle = createCommand("a321neo/cockpit/door/toggle_overwing_exit_1_l", "Open/Close overwing exit 1 L")
Overwing_exit_1_r_toggle = createCommand("a321neo/cockpit/door/toggle_overwing_exit_1_r", "Open/Close overwing exit 1 R")
Overwing_exit_2_l_toggle = createCommand("a321neo/cockpit/door/toggle_overwing_exit_2_l", "Open/Close overwing exit 2 L")
Overwing_exit_2_r_toggle = createCommand("a321neo/cockpit/door/toggle_overwing_exit_2_r", "Open/Close overwing exit 2 R")
Cargo_1_toggle = createCommand("a321neo/cockpit/door/toggle_cargo_1", "Open/Close cargo 1")
Cargo_2_toggle = createCommand("a321neo/cockpit/door/toggle_cargo_2", "Open/Close cargo 2")

-- Failures
Failures_cancel_master_caution   = createCommand("a321neo/cockpit/cancel_master_caution", "Move left the knob")
Failures_cancel_master_warning   = createCommand("a321neo/cockpit/cancel_master_warning", "Move left the knob")

-- HYD
HYD_cmd_Eng1Pump   = createCommand("a321neo/cockpit/HYD/toggle_eng_pump_1", "Toggle HYD Engine 1 pump")
HYD_cmd_Eng2Pump   = createCommand("a321neo/cockpit/HYD/toggle_eng_pump_2", "Toggle HYD Engine 2 pump")
HYD_cmd_PTU        = createCommand("a321neo/cockpit/HYD/toggle_PTU", "Toggle HYD PTU pump")
HYD_cmd_B_ElecPump = createCommand("a321neo/cockpit/HYD/toggle_elec_pump_B", "Toggle HYD Elec Blue pump")
HYD_cmd_Y_ElecPump = createCommand("a321neo/cockpit/HYD/toggle_elec_pump_Y", "Toggle HYD Elec Yellow pump")
HYD_cmd_RAT_man_on = createCommand("a321neo/cockpit/HYD/RAT_manual", "Force RAT out")

HYD_reset_systems  = createCommand("a321neo/internals/HYD/reset_systems", "Reset HYD quantity systems")

-- ELEC
ELEC_cmd_Galley       = createCommand("a321neo/cockpit/electrical/galley", "Toggle galley")
ELEC_cmd_AC_ess_feed  = createCommand("a321neo/cockpit/electrical/AC_ESS_FEED", "Press AC ESS FEED button")
ELEC_cmd_BUS_tie      = createCommand("a321neo/cockpit/electrical/BUS_tie", "Press BUS TIE button")
ELEC_cmd_IDG1         = createCommand("a321neo/cockpit/electrical/IDG_1", "Press IDG1 button")
ELEC_cmd_IDG2         = createCommand("a321neo/cockpit/electrical/IDG_2", "Press IDG2 button")
ELEC_cmd_GEN1         = createCommand("a321neo/cockpit/electrical/GEN_1", "Press GEN1 button")
ELEC_cmd_GEN2         = createCommand("a321neo/cockpit/electrical/GEN_2", "Press GEN2 button")
ELEC_cmd_APU_GEN      = createCommand("a321neo/cockpit/electrical/APU_GEN", "Press APU GEN button")
ELEC_cmd_EXT_PWR      = createCommand("a321neo/cockpit/electrical/EXT_PWR", "Press EXT PWR button")

ELEC_cmd_EMER_GEN_TEST   = createCommand("a321neo/cockpit/electrical/EMER_GEN_TEST", "Press EMER_GEN_TEST on the EMER ELEC PWR panel")
ELEC_cmd_EMER_GEN1_LINE  = createCommand("a321neo/cockpit/electrical/EMER_GEN_1_LINE", "Press GEN 1 LINE button on the EMER ELEC PWR panel")
ELEC_cmd_EMER_RAT        = createCommand("a321neo/cockpit/electrical/EMER_GEN_RAT", "Press RAT MAN ON button on the EMER ELEC PWR panel")

ELEC_vent_blower      = createCommand("a321neo/cockpit/electrical/toggle_vent_blower", "Press BLOWER in the VENTILATION panel")
ELEC_vent_extract     = createCommand("a321neo/cockpit/electrical/toggle_vent_extract", "Press EXTRACT in the VENTILATION panel")

-- FUEL
FUEL_cmd_L_TK_pump_1      = createCommand("a321neo/cockpit/fuel/L_TK_pump_1", "Press L TK 1 pump button in the FUEL panel")
FUEL_cmd_L_TK_pump_2      = createCommand("a321neo/cockpit/fuel/L_TK_pump_2", "Press L TK 2 pump button in the FUEL panel")
FUEL_cmd_R_TK_pump_1      = createCommand("a321neo/cockpit/fuel/R_TK_pump_1", "Press R TK 1 pump button in the FUEL panel")
FUEL_cmd_R_TK_pump_2      = createCommand("a321neo/cockpit/fuel/R_TK_pump_2", "Press R TK 2 pump button in the FUEL panel")
FUEL_cmd_C_TK_XFR_1       = createCommand("a321neo/cockpit/fuel/C_TK_XFR_1", "Press C TK 1 XFR button in the FUEL panel")
FUEL_cmd_C_TK_XFR_2       = createCommand("a321neo/cockpit/fuel/C_TK_XFR_2", "Press C TK 2 XFR button in the FUEL panel")
FUEL_cmd_ACT_TK_XFR       = createCommand("a321neo/cockpit/fuel/ACT_TK_FWD", "Press ACT TK FWD button in the FUEL panel")
FUEL_cmd_RCT_TK_XFR       = createCommand("a321neo/cockpit/fuel/RCT_TK_FWD", "Press RCT TK FWD button in the FUEL panel")
FUEL_cmd_C_TK_mode        = createCommand("a321neo/cockpit/fuel/C_TK_mode", "Press MODE SEL button in the FUEL panel")
FUEL_cmd_X_FEED           = createCommand("a321neo/cockpit/fuel/X_FEED", "Press X FEED button in the FUEL panel")
FUEL_cmd_internal_qs      = sasl.createCommand("a321neo/internals/fuel/quick_start", "Used during quick start") -- This is used only for sasl internals

-- Standby instrument
ISIS_cmd_LS          = createCommand("a321neo/cockpit/ISIS/LS", "Press LS button on ISIS")
ISIS_cmd_Knob_c      = createCommand("a321neo/cockpit/ISIS/Knob_C", "Rotate ISIS knob clockwise")  -- Knob clockwise
ISIS_cmd_Knob_cc     = createCommand("a321neo/cockpit/ISIS/Knob_CC", "Rotate ISIS knob counter-clockwise") -- Knob counter-clockwise
ISIS_cmd_RotaryPress = createCommand("a321neo/cockpit/ISIS/Knob_RotaryPress", "Push spring-loaded ISIS rotary knob inwards.")
ISIS_cmd_rst = createCommand("a321neo/cockpit/ISIS/RST", "Press Reset button on ISIS")
ISIS_cmd_bug = createCommand("a321neo/cockpit/ISIS/BUG", "Press Bug button on ISIS")

--FBW
XP_Capt_sidestick_pb = sasl.findCommand("sim/autopilot/servos_fdir_off")
Capt_sidestick_pb = sasl.createCommand("a321neo/cockpit/FBW/capt_sidestick_pb", "Captain sidestick pushbutton")
Fo_sidestick_pb =   sasl.createCommand("a321neo/cockpit/FBW/fo_sidestick_pb", "First officer sidestick pushbutton")
Toggle_ELAC_1 = sasl.createCommand("a321neo/cockpit/FBW/toggle_elac_1", "toggle ELAC 1")
Toggle_ELAC_2 = sasl.createCommand("a321neo/cockpit/FBW/toggle_elac_2", "toggle ELAC 2")
Toggle_SEC_1 = sasl.createCommand("a321neo/cockpit/FBW/toggle_sec_1", "toggle SEC 1")
Toggle_SEC_2 = sasl.createCommand("a321neo/cockpit/FBW/toggle_sec_2", "toggle SEC 2")
--elevator
XP_trim_up = sasl.findCommand("sim/flight_controls/pitch_trim_up")
XP_trim_dn = sasl.findCommand("sim/flight_controls/pitch_trim_down")
XP_trim_up_mech = sasl.findCommand("sim/flight_controls/pitch_trim_up_mech")
XP_trim_dn_mech = sasl.findCommand("sim/flight_controls/pitch_trim_down_mech")
--rudder--
Rudd_trim_reset = sasl.createCommand("a321neo/cockpit/FBW/rudder_trim_reset", "Rudder Trim Reset")
Rudd_trim_L = sasl.createCommand("a321neo/cockpit/FBW/rudder_trim_L", "Rudder Trim L")
Rudd_trim_R = sasl.createCommand("a321neo/cockpit/FBW/rudder_trim_R", "Rudder Trim R")
--spoilers--
XP_less_speedbrakes = sasl.findCommand("sim/flight_controls/speed_brakes_up_one")
XP_more_speedbrakes = sasl.findCommand("sim/flight_controls/speed_brakes_down_one")
XP_min_speedbrakes  = sasl.findCommand("sim/flight_controls/speed_brakes_up_all")
XP_max_speedbrakes  = sasl.findCommand("sim/flight_controls/speed_brakes_down_all")

-- ENG
ENG_cmd_manual_start_1 = createCommand("a321neo/cockpit/engine/manual_start_1", "Press Manual Start ENG1 pushbutton")
ENG_cmd_manual_start_2 = createCommand("a321neo/cockpit/engine/manual_start_2", "Press Manual Start ENG2 pushbutton")
ENG_cmd_dual_cooling   = createCommand("a321neo/cockpit/engine/dual_cooling", "Press Dual Cooling pushbutton")
ENG_cmd_mode_up        = sasl.createCommand("a321neo/cockpit/engine/mode_up", "engine mode selector up")
ENG_cmd_mode_down      = sasl.createCommand("a321neo/cockpit/engine/mode_dn", "engine mode selector down")
ENG_cmd_master_toggle_1= createCommand("a321neo/cockpit/engine/master_toggle_1", "Master Switch ENG1")
ENG_cmd_master_toggle_2= createCommand("a321neo/cockpit/engine/master_toggle_2", "Master Switch ENG2")
-- Airbus TCA support
ENG_cmd_mode_ignite    = sasl.createCommand("a321neo/cockpit/engine/mode_ignite", "engine mode selector IGN/START")
ENG_cmd_mode_norm      = sasl.createCommand("a321neo/cockpit/engine/mode_norm", "engine mode selector NORM")
ENG_cmd_mode_crank     = sasl.createCommand("a321neo/cockpit/engine/mode_crank", "engine mode selector CRANK")
ENG_cmd_mode_keepon_ignite = sasl.createCommand("a321neo/cockpit/engine/mode_ignite_keep", "engine mode keep IGN/START")
ENG_cmd_mode_keepon_crank  = sasl.createCommand("a321neo/cockpit/engine/mode_crank_keep", "engine mode keep CRANK")
ENG_cmd_master_on_1    = sasl.createCommand("a321neo/cockpit/engine/master_on_1", "Master Switch ENG1 on")
ENG_cmd_master_off_1   = sasl.createCommand("a321neo/cockpit/engine/master_off_1", "Master Switch ENG1 off")
ENG_cmd_master_on_2    = sasl.createCommand("a321neo/cockpit/engine/master_on_2", "Master Switch ENG2 on")
ENG_cmd_master_off_2   = sasl.createCommand("a321neo/cockpit/engine/master_off_2", "Master Switch ENG2 off")
ENG_cmd_master_keepon_1= sasl.createCommand("a321neo/cockpit/engine/master_on_keep_1", "Master Switch ENG 1 keep on")
ENG_cmd_master_keepon_2= sasl.createCommand("a321neo/cockpit/engine/master_on_keep_2", "Master Switch ENG 2 keep on")

-- APU
APU_cmd_master = sasl.createCommand("a321neo/cockpit/engine/apu_master_toggle", "toggle APU master button")
APU_cmd_start  = sasl.createCommand("a321neo/cockpit/engine/apu_start_toggle", "toggle APU start button")

-- Anti-ICE
AI_cmd_probe_window_heat = sasl.createCommand("a321neo/cockpit/anti_ice/probe_wind_heat", "Toggle PROBE WINDOW HEAT button")
AI_cmd_eng_1             = sasl.createCommand("a321neo/cockpit/anti_ice/toggle_eng_1", "Toggle ANTI-ICE ENG 1 button")
AI_cmd_eng_2             = sasl.createCommand("a321neo/cockpit/anti_ice/toggle_eng_2", "Toggle ANTI-ICE ENG 2 button")
AI_cmd_wings             = sasl.createCommand("a321neo/cockpit/anti_ice/toggle_wings", "Toggle ANTI-ICE WING button")

-- Oxygen
Oxygen_toggle_crew = createCommand("a321neo/cockpit/oxygen/crew_supply_toggle", "CREW SUPPLY pb")
Oxygen_man_mask_on = createCommand("a321neo/cockpit/oxygen/man_mask_on", "MAN MASK ON pb")
Oxygen_toggle_high_alt_ldg= createCommand("a321neo/cockpit/oxygen/high_alt_ldg_toggle", "HIGH ALT LDG pb")

-- Cockpit Lights
Cockpit_ann_ovhd_cmd_up = createCommand("a321neo/cockpit/lights/ovhd_ann_lt_up", "OVHD ANN LT UP")
Cockpit_ann_ovhd_cmd_dn = createCommand("a321neo/cockpit/lights/ovhd_ann_lt_down", "OVHD ANN LT DOWN")


Cockpit_Capt_tray_toggle= createCommand("a321neo/cockpit/misc/capt_tray_toggle", "Capt tray toggle")
Cockpit_Fo_tray_toggle  = createCommand("a321neo/cockpit/misc/fo_tray_toggle", "F/O tray toggle")

-- EVAC
EVAC_cmd_command = sasl.createCommand("a321neo/cockpit/evac/command", "Toggle EVAC button")
EVAC_cmd_horn_off= sasl.createCommand("a321neo/cockpit/evac/horn_off", "Press HORN SHUTOFF button")
EVAC_cmd_capt_purs_toggle = sasl.createCommand("a321neo/cockpit/evac/capt_purs_toggle", "Toggle CAPT and PURS")

-- GPWS
GPWS_cmd_TER        = sasl.createCommand("a321neo/cockpit/gpws/ter", "Toggle GPWS TER button")
GPWS_cmd_SYS        = sasl.createCommand("a321neo/cockpit/gpws/sys", "Toggle GPWS SYS button")
GPWS_cmd_GS_MODE    = sasl.createCommand("a321neo/cockpit/gpws/gs_mode", "Toggle GPWS GS MODE button")
GPWS_cmd_FLAP_MODE  = sasl.createCommand("a321neo/cockpit/gpws/flap_mode", "Toggle GPWS FLAP MODE button")
GPWS_cmd_LDG_FLAP_3 = sasl.createCommand("a321neo/cockpit/gpws/ldg_flap_3", "Toggle GPWS LDG FLAP 3 button")
GPWS_cmd_silence    = sasl.createCommand("a321neo/cockpit/gpws/silence", "Toggle the silence button on MIP")

-- RCDR
RCDR_cmd_GND_CTL   = sasl.createCommand("a321neo/cockpit/rcdr/gnd_ctl",  "Toggle RCDR GND CTL button")
RCDR_cmd_CVR_ERASE = sasl.createCommand("a321neo/cockpit/rcdr/cvr_erase","Press CVR ERASE button")
RCDR_cmd_CVR_TEST  = sasl.createCommand("a321neo/cockpit/rcdr/cvr_test", "Press CVR TEST button")

-- CALLS
CALLS_cmd_FWD   = sasl.createCommand("a321neo/cockpit/calls/fwd","Press CALLS FWD button")
CALLS_cmd_MID   = sasl.createCommand("a321neo/cockpit/calls/mid","Press CALLS MID button")
CALLS_cmd_EXIT  = sasl.createCommand("a321neo/cockpit/calls/exit","Press CALLS EXIT button")
CALLS_cmd_MECH  = sasl.createCommand("a321neo/cockpit/calls/mech","Press CALLS MECH button")
CALLS_cmd_ALL   = sasl.createCommand("a321neo/cockpit/calls/all","Press CALLS ALL button")
CALLS_cmd_AFT   = sasl.createCommand("a321neo/cockpit/calls/aft","Press CALLS AFT button")
CALLS_cmd_EMER  = sasl.createCommand("a321neo/cockpit/calls/emer","Press CALLS EMER button")

-- RR / WIPERS
RAIN_cmd_repellent_L = sasl.createCommand("a321neo/cockpit/rain/repellent_L","Press Rain Repellent L button")
RAIN_cmd_repellent_R = sasl.createCommand("a321neo/cockpit/rain/repellent_R","Press Rain Repellent R button")
RAIN_cmd_wiper_L_up = sasl.createCommand("a321neo/cockpit/rain/wiper_L_up_cc","Knob Wiper L CC")
RAIN_cmd_wiper_L_dn = sasl.createCommand("a321neo/cockpit/rain/wiper_L_dn_c","Knob Wiper L C")
RAIN_cmd_wiper_R_up = sasl.createCommand("a321neo/cockpit/rain/wiper_R_up_cc","Knob Wiper R CC")
RAIN_cmd_wiper_R_dn = sasl.createCommand("a321neo/cockpit/rain/wiper_R_dn_c","Knob Wiper R C")


-- Cockpit DOOR and related
VIDEO_cmd_toggle = sasl.createCommand("a321neo/cockpit/misc/toggle_door_video","Press VIDEO DOOR")
VIDEO_cmd_require = sasl.createCommand("a321neo/cockpit/misc/require_door_video","Press VIDEO in the pedestal")
CKPT_DOOR_cmd_unlock = sasl.createCommand("a321neo/cockpit/misc/ckpt_door_unlock","Press VIDEO in the pedestal")
CKPT_DOOR_cmd_lock = sasl.createCommand("a321neo/cockpit/misc/ckpt_door_lock","Press VIDEO in the pedestal")


-- FIRE PROTECTION
FIRE_cmd_ENG_1_A_1 = sasl.createCommand("a321neo/cockpit/fire/eng_1_agent_1","Press ENG 1 AGENT 1")
FIRE_cmd_ENG_1_A_2 = sasl.createCommand("a321neo/cockpit/fire/eng_1_agent_2","Press ENG 1 AGENT 2")
FIRE_cmd_ENG_2_A_1 = sasl.createCommand("a321neo/cockpit/fire/eng_2_agent_1","Press ENG 2 AGENT 1")
FIRE_cmd_ENG_2_A_2 = sasl.createCommand("a321neo/cockpit/fire/eng_2_agent_2","Press ENG 2 AGENT 2")
FIRE_cmd_APU_A     = sasl.createCommand("a321neo/cockpit/fire/apu_agent","Press APU AGENT")
FIRE_cmd_push_ENG_1= sasl.createCommand("a321neo/cockpit/fire/eng_1_push","Press ENG 1 big red button")
FIRE_cmd_push_ENG_2= sasl.createCommand("a321neo/cockpit/fire/eng_2_push","Press ENG 2 big red button")
FIRE_cmd_push_APU  = sasl.createCommand("a321neo/cockpit/fire/apu_push","Press APU big red button")

FIRE_cmd_test_ENG_1= sasl.createCommand("a321neo/cockpit/fire/eng_1_test","Press ENG 1 big red button")
FIRE_cmd_test_ENG_2= sasl.createCommand("a321neo/cockpit/fire/eng_2_test","Press ENG 2 big red button")
FIRE_cmd_test_APU  = sasl.createCommand("a321neo/cockpit/fire/apu_test","Press APU big red button")

FIRE_cmd_smoke_cargo_test = sasl.createCommand("a321neo/cockpit/fire/cargo_test","Press test cargo smoke button")
FIRE_cmd_smoke_cargo_fwd = sasl.createCommand("a321neo/cockpit/fire/cargo_fwd_disch","Press discharge forward cargo agent button")
FIRE_cmd_smoke_cargo_aft = sasl.createCommand("a321neo/cockpit/fire/cargo_aft_disch","Press discharge aft cargo agent button")

-- MAINTENANCE Panel
MNTN_OXY_reset   = sasl.createCommand("a321neo/cockpit/mntn/oxy_tmr_reset","Press OXY TMR RESET")
MNTN_SVCE_INT    = sasl.createCommand("a321neo/cockpit/mntn/svce_int","Press SVCE INT")
MNTN_AVIO_LIGHT  = sasl.createCommand("a321neo/cockpit/mntn/avionics_light","Press AVIONICS LIGHT")
MNTN_HYD_BLUE_override= sasl.createCommand("a321neo/cockpit/mntn/hyd_B_override","Press HYD B override")
MNTN_HYD_G_valve = sasl.createCommand("a321neo/cockpit/mntn/hyd_g_valve","Press HYD G MEAS VALVE")
MNTN_HYD_B_valve = sasl.createCommand("a321neo/cockpit/mntn/hyd_b_valve","Press HYD B MEAS VALVE")
MNTN_HYD_Y_valve = sasl.createCommand("a321neo/cockpit/mntn/hyd_y_valve","Press HYD Y MEAS VALVE")
MNTN_APU_test    = sasl.createCommand("a321neo/cockpit/mntn/apu_test","Press APU test")
MNTN_APU_reset   = sasl.createCommand("a321neo/cockpit/mntn/apu_reset","Press APU reset")
MNTN_FADEC_1_on  = sasl.createCommand("a321neo/cockpit/mntn/fadec_1_on","Press FADEC 1 GND PWR")
MNTN_FADEC_2_on  = sasl.createCommand("a321neo/cockpit/mntn/fadec_2_on","Press FADEC 2 GND PWR")

-- LIGHTS
LIGHTS_cmd_strobe_up = sasl.createCommand("a321neo/cockpit/lights/strobe_up","Move up strobe lever")
LIGHTS_cmd_strobe_dn = sasl.createCommand("a321neo/cockpit/lights/strobe_dn","Move down strobe lever")
LIGHTS_cmd_land_L_up = sasl.createCommand("a321neo/cockpit/lights/land_L_up","Move up land L lever")
LIGHTS_cmd_land_L_dn = sasl.createCommand("a321neo/cockpit/lights/land_L_dn","Move down land L lever")
LIGHTS_cmd_land_R_up = sasl.createCommand("a321neo/cockpit/lights/land_R_up","Move up land R lever")
LIGHTS_cmd_land_R_dn = sasl.createCommand("a321neo/cockpit/lights/land_R_dn","Move down land R lever")
LIGHTS_cmd_nose_up = sasl.createCommand("a321neo/cockpit/lights/nose_up","Move up nose lever")
LIGHTS_cmd_nose_dn = sasl.createCommand("a321neo/cockpit/lights/nose_dn","Move down nose lever")
LIGHTS_cmd_beacon_toggle = sasl.createCommand("a321neo/cockpit/lights/beacon_toggle","Toggle BEACON LIGHT")
LIGHTS_cmd_wing_toggle = sasl.createCommand("a321neo/cockpit/lights/wing_toggle","Toggle WING LIGHT")
LIGHTS_cmd_navlogo_up = sasl.createCommand("a321neo/cockpit/lights/navlogo_up","Move up NAV and LOGO LIGHT")
LIGHTS_cmd_navlogo_dn = sasl.createCommand("a321neo/cockpit/lights/navlogo_dn","Move up NAV and LOGO LIGHT")
LIGHTS_cmd_rwy_turnoff_toggle = sasl.createCommand("a321neo/cockpit/lights/rwy_turnoff_toggle","Toggle RWY TURN OFF LIGHT")

LIGHTS_cmd_compass_toggle = sasl.createCommand("a321neo/cockpit/lights/compass_toggle","Toggle COMPASS LIGHT")
LIGHTS_cmd_emer_exit_up = sasl.createCommand("a321neo/cockpit/lights/emer_exit_up","Move up emer_exit lever")
LIGHTS_cmd_emer_exit_dn = sasl.createCommand("a321neo/cockpit/lights/emer_exit_dn","Move down emer_exit lever")

-- SIGNS
MISC_cmd_seatbelts_up = sasl.createCommand("a321neo/cockpit/misc/seatbelts_up","Seatbelt lever up")
MISC_cmd_seatbelts_dn = sasl.createCommand("a321neo/cockpit/misc/seatbelts_dn","Seatbelt lever down")
MISC_cmd_noped_up = sasl.createCommand("a321neo/cockpit/misc/noped_up","No P.E.D. lever up")
MISC_cmd_noped_dn = sasl.createCommand("a321neo/cockpit/misc/noped_dn","No P.E.D. lever down")

-- ND related
ND_Capt_terrain_toggle = sasl.createCommand("a321neo/cockpit/nd/capt_terrain_toggle","Capt terrain toggle")
ND_Fo_terrain_toggle = sasl.createCommand("a321neo/cockpit/nd/fo_terrain_toggle","F/O terrain toggle")

ND_Capt_mode_cmd_up = sasl.createCommand("a321neo/cockpit/nd/capt_mode_up","Capt ND mode UP")
ND_Capt_mode_cmd_dn = sasl.createCommand("a321neo/cockpit/nd/capt_mode_dn","Capt ND mode DN")
ND_Capt_range_cmd_up = sasl.createCommand("a321neo/cockpit/nd/capt_range_up","Capt ND range UP")
ND_Capt_range_cmd_dn = sasl.createCommand("a321neo/cockpit/nd/capt_range_dn","Capt ND range DN")
ND_Capt_nav1_cmd_left = sasl.createCommand("a321neo/cockpit/nd/capt_nav_1_left","Capt NAV1 L")
ND_Capt_nav1_cmd_right = sasl.createCommand("a321neo/cockpit/nd/capt_nav_1_right","Capt NAV1 R")
ND_Capt_nav2_cmd_left = sasl.createCommand("a321neo/cockpit/nd/capt_nav_2_left","Capt NAV2 L")
ND_Capt_nav2_cmd_right = sasl.createCommand("a321neo/cockpit/nd/capt_nav_2_right","Capt NAV2 R")
ND_Capt_cmd_cstr = sasl.createCommand("a321neo/cockpit/nd/capt_pb_cstr","Capt P/B CSTR")
ND_Capt_cmd_wpt = sasl.createCommand("a321neo/cockpit/nd/capt_pb_wpt","Capt P/B WPT")
ND_Capt_cmd_vord = sasl.createCommand("a321neo/cockpit/nd/capt_pb_vord","Capt P/B VORD")
ND_Capt_cmd_ndb = sasl.createCommand("a321neo/cockpit/nd/capt_pb_ndb","Capt P/B NDB")
ND_Capt_cmd_arpt = sasl.createCommand("a321neo/cockpit/nd/capt_pb_arpt","Capt P/B ARPT")

ND_Fo_mode_cmd_up = sasl.createCommand("a321neo/cockpit/nd/fo_mode_up","F/O ND mode UP")
ND_Fo_mode_cmd_dn = sasl.createCommand("a321neo/cockpit/nd/fo_mode_dn","F/O ND mode DN")
ND_Fo_range_cmd_up = sasl.createCommand("a321neo/cockpit/nd/fo_range_up","F/O ND range UP")
ND_Fo_range_cmd_dn = sasl.createCommand("a321neo/cockpit/nd/fo_range_dn","F/O ND range DN")
ND_Fo_nav1_cmd_left = sasl.createCommand("a321neo/cockpit/nd/fo_nav_1_left","F/O NAV1 L")
ND_Fo_nav1_cmd_right = sasl.createCommand("a321neo/cockpit/nd/fo_nav_1_right","F/O NAV1 R")
ND_Fo_nav2_cmd_left = sasl.createCommand("a321neo/cockpit/nd/fo_nav_2_left","F/O NAV2 L")
ND_Fo_nav2_cmd_right = sasl.createCommand("a321neo/cockpit/nd/fo_nav_2_right","F/O NAV2 R")
ND_Fo_cmd_cstr = sasl.createCommand("a321neo/cockpit/nd/fo_pb_cstr","F/O P/B CSTR")
ND_Fo_cmd_wpt = sasl.createCommand("a321neo/cockpit/nd/fo_pb_wpt","F/O P/B WPT")
ND_Fo_cmd_vord = sasl.createCommand("a321neo/cockpit/nd/fo_pb_vord","F/O P/B VORD")
ND_Fo_cmd_ndb = sasl.createCommand("a321neo/cockpit/nd/fo_pb_ndb","F/O P/B NDB")
ND_Fo_cmd_arpt = sasl.createCommand("a321neo/cockpit/nd/fo_pb_arpt","F/O P/B ARPT")

-- PFD
PFD_Capt_BUSS_enable= sasl.createCommand("a321neo/cockpit/pfd/capt_buss","Capt BUSS toggle")
PFD_Fo_BUSS_enable  = sasl.createCommand("a321neo/cockpit/pfd/fo_buss","F/O BUSS toggle")

-- FCU
FCU_Capt_FD_cmd = sasl.createCommand("a321neo/cockpit/fcu/capt_fd","Capt FD toggle")
FCU_Capt_LS_cmd = sasl.createCommand("a321neo/cockpit/fcu/capt_ls","Capt LS toggle")
FCU_Fo_FD_cmd   = sasl.createCommand("a321neo/cockpit/fcu/fo_fd","F/O FD toggle")
FCU_Fo_LS_cmd   = sasl.createCommand("a321neo/cockpit/fcu/fo_ls","F/O LS toggle")

FCU_Capt_knob_qnh_dn = sasl.createCommand("a321neo/cockpit/fcu/capt_qnh_dn","Capt QNH DN")
FCU_Capt_knob_qnh_up = sasl.createCommand("a321neo/cockpit/fcu/capt_qnh_up","Capt QNH UP")
FCU_Capt_knob_qnh_push = sasl.createCommand("a321neo/cockpit/fcu/capt_qnh_push","Capt QNH Push")
FCU_Capt_knob_qnh_pull = sasl.createCommand("a321neo/cockpit/fcu/capt_qnh_pull","Capt QNH Pull")
FCU_Capt_knob_qnh_unit_toggle = sasl.createCommand("a321neo/cockpit/fcu/capt_qnh_unit_toggle","Capt QNH Unit Toggle")

FCU_Fo_knob_qnh_dn = sasl.createCommand("a321neo/cockpit/fcu/fo_qnh_dn","F/O QNH DN")
FCU_Fo_knob_qnh_up = sasl.createCommand("a321neo/cockpit/fcu/fo_qnh_up","F/O QNH UP")
FCU_Fo_knob_qnh_push = sasl.createCommand("a321neo/cockpit/fcu/fo_qnh_push","F/O QNH Push")
FCU_Fo_knob_qnh_pull = sasl.createCommand("a321neo/cockpit/fcu/fo_qnh_pull","F/O QNH Pull")
FCU_Fo_knob_qnh_unit_toggle = sasl.createCommand("a321neo/cockpit/fcu/fo_qnh_unit_toggle","F/O QNH Unit Toggle")

FCU_knob_speed_up   = sasl.createCommand("a321neo/cockpit/fcu/spd_knob_up","SPD Knob UP")
FCU_knob_speed_dn   = sasl.createCommand("a321neo/cockpit/fcu/spd_knob_dn","SPD Knob DN")
FCU_knob_speed_pull = sasl.createCommand("a321neo/cockpit/fcu/spd_knob_pull","SPD Knob Pull")
FCU_knob_speed_push = sasl.createCommand("a321neo/cockpit/fcu/spd_knob_push","SPD Knob Push")

FCU_knob_hdg_up   = sasl.createCommand("a321neo/cockpit/fcu/hdg_knob_up","HDG Knob UP")
FCU_knob_hdg_dn   = sasl.createCommand("a321neo/cockpit/fcu/hdg_knob_dn","HDG Knob DN")
FCU_knob_hdg_pull = sasl.createCommand("a321neo/cockpit/fcu/hdg_knob_pull","HDG Knob Pull")
FCU_knob_hdg_push = sasl.createCommand("a321neo/cockpit/fcu/hdg_knob_push","HDG Knob Push")

FCU_knob_vs_up   = sasl.createCommand("a321neo/cockpit/fcu/vs_knob_up","V/S Knob UP")
FCU_knob_vs_dn   = sasl.createCommand("a321neo/cockpit/fcu/vs_knob_dn","V/S Knob DN")
FCU_knob_vs_pull = sasl.createCommand("a321neo/cockpit/fcu/vs_knob_pull","V/S Knob Pull")
FCU_knob_vs_push = sasl.createCommand("a321neo/cockpit/fcu/vs_knob_push","V/S Knob Push")

FCU_knob_alt_up   = sasl.createCommand("a321neo/cockpit/fcu/alt_knob_up","ALT Knob UP")
FCU_knob_alt_dn   = sasl.createCommand("a321neo/cockpit/fcu/alt_knob_dn","ALT Knob DN")
FCU_knob_alt_pull = sasl.createCommand("a321neo/cockpit/fcu/alt_knob_pull","ALT Knob Pull")
FCU_knob_alt_push = sasl.createCommand("a321neo/cockpit/fcu/alt_knob_push","ALT Knob Push")
FCU_knob_range_toggle = sasl.createCommand("a321neo/cockpit/fcu/alt_knob_range_toggle","ALT Knob Range Toggle")

FCU_cmd_spd_mach = sasl.createCommand("a321neo/cockpit/fcu/spd_mach","SPD MACH toggle")
FCU_cmd_hdg_trk = sasl.createCommand("a321neo/cockpit/fcu/hdg_trk","HDG TRK toggle")
FCU_cmd_metric_alt = sasl.createCommand("a321neo/cockpit/fcu/metric_alt","Metric alt toggle")

FCU_cmd_pb_loc   = sasl.createCommand("a321neo/cockpit/fcu/pb_loc","AP P/B LOC")
FCU_cmd_pb_ap_1  = sasl.createCommand("a321neo/cockpit/fcu/pb_ap_1","AP 1 Main P/B")
FCU_cmd_pb_ap_2  = sasl.createCommand("a321neo/cockpit/fcu/pb_ap_2","AP 2 Main P/B")
FCU_cmd_pb_athr  = sasl.createCommand("a321neo/cockpit/fcu/pb_athr","STHR Main P/B")
FCU_cmd_pb_exped = sasl.createCommand("a321neo/cockpit/fcu/pb_exped","AP P/B exped")
FCU_cmd_pb_appr  = sasl.createCommand("a321neo/cockpit/fcu/pb_appr","AP P/B appr")

-- CHRONO
Chrono_cmd_Capt_button = sasl.createCommand("a321neo/cockpit/misc/capt_chrono_press","Capt Chrono Press")
Chrono_cmd_Fo_button   = sasl.createCommand("a321neo/cockpit/misc/fo_chrono_press","F/O Chrono Press")
Chrono_cmd_rst         = sasl.createCommand("a321neo/cockpit/misc/chrono_rst","Chrono RST")
Chrono_cmd_date        = sasl.createCommand("a321neo/cockpit/misc/chrono_date","Chrono Date")
Chrono_cmd_date_up     = sasl.createCommand("a321neo/cockpit/misc/chrono_date_up","Chrono Date UP")
Chrono_cmd_date_dn     = sasl.createCommand("a321neo/cockpit/misc/chrono_date_dn","Chrono Date DN")
Chrono_cmd_chr         = sasl.createCommand("a321neo/cockpit/misc/chrono_chr","Chrono CHR")
Chrono_cmd_source_up   = sasl.createCommand("a321neo/cockpit/misc/chrono_source_up","Chrono Source UP")
Chrono_cmd_source_dn   = sasl.createCommand("a321neo/cockpit/misc/chrono_source_dn","Chrono Source DN")
Chrono_cmd_state_up    = sasl.createCommand("a321neo/cockpit/misc/chrono_state_up","Chrono State UP")
Chrono_cmd_state_dn    = sasl.createCommand("a321neo/cockpit/misc/chrono_state_dn","Chrono State DN")

-- MCDU/DMC
MCDU_DMC_cmd_test_1 = sasl.createCommand("a321neo/cockpit/mcdu/trigger_dmc_test_1","Internal use only. DO NOT USE.")
MCDU_DMC_cmd_test_2 = sasl.createCommand("a321neo/cockpit/mcdu/trigger_dmc_test_2","Internal use only. DO NOT USE.")
MCDU_DMC_cmd_test_3 = sasl.createCommand("a321neo/cockpit/mcdu/trigger_dmc_test_3","Internal use only. DO NOT USE.")

--misc--

-- MANUAL GEAR EXT --
Emer_ldg_gear_v_cmd_toggle = sasl.createCommand("a321neo/cockpit/misc/lg_gravity_v_toggle", "Gravity Extension L/G handle toggle")
Emer_ldg_gear_h_cmd_c  = sasl.createCommand("a321neo/cockpit/misc/lg_gravity_h_c", "Gravity Extension L/G handle C") -- Clockwise
Emer_ldg_gear_h_cmd_cc = sasl.createCommand("a321neo/cockpit/misc/lg_gravity_h_cc", "Gravity Extension L/G handle CC") -- Counter-clockwise

--view--
Default_view =          sasl.findCommand("sim/view/default_view")
EXT_linear_spot_view =  sasl.findCommand("sim/view/linear_spot")
EXT_still_spot_view =   sasl.findCommand("sim/view/still_spot")
EXT_runway_view =       sasl.findCommand("sim/view/runway")
EXT_circle_view =       sasl.findCommand("sim/view/circle")
EXT_tower_view =        sasl.findCommand("sim/view/tower")
EXT_ride_along_view =   sasl.findCommand("sim/view/ridealong")
EXT_track_weapon_view = sasl.findCommand("sim/view/track_weapon")
EXT_chase_view =        sasl.findCommand("sim/view/chase")
