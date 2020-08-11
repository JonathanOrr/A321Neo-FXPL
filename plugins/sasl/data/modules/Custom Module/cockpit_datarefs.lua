--ALL DATAREFS USED IN THE COCKPIT, e.g DIALS, KNOBS, BUTTONS--
--engine
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

--autobrakes
Autobrakes = createGlobalPropertyi("a321neo/cockpit/autobrakes", 0, false, true, false) -- 0: off, 1: low, 2:med, 3:max
--aircon datarefs
Cockpit_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp_req", 21, false, true, false) --requested cockpit temperature
Front_cab_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp_req", 21, false, true, false) --requested front cabin temperature
Aft_cab_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp_req", 21, false, true, false) --requested aft cabin temperature
Aft_cargo_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cargo_temp_req", 17, false, true, false) ---requested aft cargo temperature
Cockpit_temp = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp", 15, false, true, false) --actual cockpit temperature
Front_cab_temp = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp", 15, false, true, false) --actual front cabin temperature
Aft_cab_temp = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp", 15, false, true, false) --actual aft cabin temperature
Aft_cargo_temp = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cargo_temp", 17, false, true, false) ---requested aft cargo temperature
--packs
X_bleed_dial = createGlobalPropertyi("a321neo/cockpit/packs/x_bleed_dial", 1, false, true, false) --0closed, 1auto, 2open
A321_Pack_Flow_dial = createGlobalPropertyi("a321neo/cockpit/packs/pack_flow_dial", 0, false, true, false) --the pack flow dial 0low, 1norm, 2high
Eng1_bleed_off = createGlobalPropertyi("a321neo/cockpit/packs/eng1_off", 0, false, true, false) --0 is on 1 if off
Eng2_bleed_off = createGlobalPropertyi("a321neo/cockpit/packs/eng2_off", 0, false, true, false) --0 is on 1 if off
--misc
Capt_ra_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_ra_alt_m", 0, false, true, false)
Capt_baro_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_baro_alt_m", 0, false, true, false)
Window_ice_test = createGlobalPropertyf("a321neo/cockpit/window_ice", 0, false, true, false)
Seatbelts = globalProperty("sim/cockpit2/annunciators/fasten_seatbelt")
NoSmoking = globalProperty("sim/cockpit2/annunciators/no_smoking")
CabinIsReady = createGlobalPropertyi("a321neo/cockpit/cabin_ready", 0, false, true, false)  -- 0 cabin is not ready, 1 cabin is ready
--MCDU
Mcdu_enabled = createGlobalPropertyi("a321neo/debug/mcdu/mcdu_enabled", 1, false, true, false)
