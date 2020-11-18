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
-- File: failures_datarefs.lua
-- Short description: It contains the datarefs used for failures
-------------------------------------------------------------------------------

-- General
ReqMasterCaution      = createGlobalPropertyi("a321neo/failures/req_master_caution", 0, false, true, false) -- When a component (typically EWD) wants to trigger a caution put this to 1
ReqMasterWarning      = createGlobalPropertyi("a321neo/failures/req_master_warning", 0, false, true, false) -- When a component (typically EWD) wants to trigger a warning put this to 1

-- Instruments
FAILURE_radioalt_cap = createGlobalPropertyi("a321neo/failures/pfd/capt_radioalt", 0, false, true, false) -- 0: OK, 1: FAILED

-- Systems
FAILURE_Apu_fire = globalProperty("sim/operation/failures/rel_apu_fire")     -- TODO This should be replaced/removed
FAILURE_TCAS = globalProperty("sim/operation/failures/rel_xpndr")            -- TODO This should be replaced/removed


FAILURE_gear = createGlobalPropertyi("a321neo/failures/gear_failure", 0, false, true, false) -- 0: OK, 1: NOT UPLOCKED, 2: NOT DOWNLOCKED (internal use only, do not set manually)
                                                                                             -- TODO 0/1 logic should be fixed

FAILURE_GEAR_NWS = createGlobalPropertyi("a321neo/failures/ns_steer", 0, false, true, false) 
FAILURE_GEAR_BSCU1 = createGlobalPropertyi("a321neo/failures/bscu_1", 0, false, true, false) 
FAILURE_GEAR_BSCU2 = createGlobalPropertyi("a321neo/failures/bscu_2", 0, false, true, false) 
FAILURE_GEAR_ABCU  = createGlobalPropertyi("a321neo/failures/abcu", 0, false, true, false)

FAILURE_ADR = {}
FAILURE_ADR[1] = createGlobalPropertyi("a321neo/failures/adirs/adr_1", 0, false, true, false) -- 0: OK, 1: FAILED
FAILURE_ADR[2] = createGlobalPropertyi("a321neo/failures/adirs/adr_2", 0, false, true, false) -- 0: OK, 1: FAILED
FAILURE_ADR[3] = createGlobalPropertyi("a321neo/failures/adirs/adr_3", 0, false, true, false) -- 0: OK, 1: FAILED


FAILURE_IR = {}
FAILURE_IR[1] = createGlobalPropertyi("a321neo/failures/adirs/ir_1", 0, false, true, false) -- 0: OK, 1: FAILED partial, 2: complete FAILURE
FAILURE_IR[2] = createGlobalPropertyi("a321neo/failures/adirs/ir_2", 0, false, true, false) -- 0: OK, 1: FAILED partial, 2: complete FAILURE
FAILURE_IR[3] = createGlobalPropertyi("a321neo/failures/adirs/ir_3", 0, false, true, false) -- 0: OK, 1: FAILED partial, 2: complete FAILURE


FAILURE_HYD_Y_E_overheat = createGlobalPropertyi("a321neo/failures/HYD/Y_E_overheat", 0, false, true, false) -- Yellow Elec pump 0: normal 1: overheat
FAILURE_HYD_B_E_overheat = createGlobalPropertyi("a321neo/failures/HYD/B_E_overheat", 0, false, true, false) -- Blue Elec pump 0: normal 1: overheat
FAILURE_HYD_G_R_overheat = createGlobalPropertyi("a321neo/failures/HYD/G_R_overheat", 0, false, true, false) -- Green Reservoir 0: normal 1: overheat
FAILURE_HYD_B_R_overheat = createGlobalPropertyi("a321neo/failures/HYD/B_R_overheat", 0, false, true, false) -- Blue Reservoir 0: normal 1: overheat
FAILURE_HYD_Y_R_overheat = createGlobalPropertyi("a321neo/failures/HYD/Y_R_overheat", 0, false, true, false) -- Yellow Reservoir 0: normal 1: overheat
FAILURE_HYD_G_low_air    = createGlobalPropertyi("a321neo/failures/HYD/G_low_air", 0, false, true, false) -- Green LO air press Reservoir 0: normal 1: overheat
FAILURE_HYD_B_low_air    = createGlobalPropertyi("a321neo/failures/HYD/B_low_air", 0, false, true, false) -- Blue LO air press Reservoir 0: normal 1: overheat
FAILURE_HYD_Y_low_air    = createGlobalPropertyi("a321neo/failures/HYD/Y_low_air", 0, false, true, false) -- Yellow LO air press Reservoir 0: normal 1: overheat
FAILURE_HYD_G_leak       = createGlobalPropertyi("a321neo/failures/HYD/G_leak", 0, false, true, false) -- Green system has a leak! (0: normal, 1:leak)
FAILURE_HYD_B_leak       = createGlobalPropertyi("a321neo/failures/HYD/B_leak", 0, false, true, false) -- Blue system has a leak! (0: normal, 1:leak)
FAILURE_HYD_Y_leak       = createGlobalPropertyi("a321neo/failures/HYD/Y_leak", 0, false, true, false) -- Yellow system has a leak! (0: normal, 1:leak)
FAILURE_HYD_G_pump       = createGlobalPropertyi("a321neo/failures/HYD/G_pump", 0, false, true, false) -- ENG1 pump failure
FAILURE_HYD_Y_pump       = createGlobalPropertyi("a321neo/failures/HYD/Y_pump", 0, false, true, false) -- ENG2 pump failure
FAILURE_HYD_B_pump       = createGlobalPropertyi("a321neo/failures/HYD/B_pump", 0, false, true, false) -- BLUE elec pump failure
FAILURE_HYD_Y_E_pump     = createGlobalPropertyi("a321neo/failures/HYD/Y_elec_pump", 0, false, true, false) -- Y elec pump failure
FAILURE_HYD_RAT          = createGlobalPropertyi("a321neo/failures/HYD/rat", 0, false, true, false) -- RAT failure
FAILURE_HYD_PTU          = createGlobalPropertyi("a321neo/failures/HYD/ptu", 0, false, true, false) -- PTU failure

FAILURE_ELEC_battery_1 = createGlobalPropertyi("a321neo/failures/electrical/bat_1", 0, false, true, false) -- BAT1 failure
FAILURE_ELEC_battery_2 = createGlobalPropertyi("a321neo/failures/electrical/bat_2", 0, false, true, false) -- BAT2 failure
FAILURE_ELEC_GEN_1     = createGlobalPropertyi("a321neo/failures/electrical/gen_1", 0, false, true, false) -- GEN1 failure
FAILURE_ELEC_GEN_2     = createGlobalPropertyi("a321neo/failures/electrical/gen_2", 0, false, true, false) -- GEN2 failure
FAILURE_ELEC_GEN_APU   = createGlobalPropertyi("a321neo/failures/electrical/gen_apu", 0, false, true, false) -- GEN APU failure
FAILURE_ELEC_GEN_EMER  = createGlobalPropertyi("a321neo/failures/electrical/gen_emer", 0, false, true, false) -- GEN EMER failure
FAILURE_ELEC_GEN_EXT   = createGlobalPropertyi("a321neo/failures/electrical/gen_ext", 0, false, true, false) -- GEN EXT failure

FAILURE_ELEC_STATIC_INV= createGlobalPropertyi("a321neo/failures/electrical/static_inv", 0, false, true, false) -- STATIC INV failure
FAILURE_ELEC_TR_1   = createGlobalPropertyi("a321neo/failures/electrical/tr_1", 0, false, true, false) -- TR 1
FAILURE_ELEC_TR_2   = createGlobalPropertyi("a321neo/failures/electrical/tr_2", 0, false, true, false) -- TR 2
FAILURE_ELEC_TR_ESS = createGlobalPropertyi("a321neo/failures/electrical/tr_ess", 0, false, true, false) -- TR ESS

FAILURE_ELEC_GALLEY = createGlobalPropertyi("a321neo/failures/electrical/galley", 0, false, true, false) 

FAILURE_ELEC_IDG1_temp = createGlobalPropertyi("a321neo/failures/electrical/idg1_temp", 0, false, true, false)
FAILURE_ELEC_IDG1_oil  = createGlobalPropertyi("a321neo/failures/electrical/idg1_oil", 0, false, true, false)
FAILURE_ELEC_IDG2_temp = createGlobalPropertyi("a321neo/failures/electrical/idg2_temp", 0, false, true, false)
FAILURE_ELEC_IDG2_oil  = createGlobalPropertyi("a321neo/failures/electrical/idg2_oil", 0, false, true, false)

FAILURE_ELEC_AC1_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_ac1", 0, false, true, false)
FAILURE_ELEC_AC2_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_ac2", 0, false, true, false)
FAILURE_ELEC_AC_ESS_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_ac_ess", 0, false, true, false)
FAILURE_ELEC_AC_ESS_SHED_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_ac_ess_shed", 0, false, true, false)
FAILURE_ELEC_DC1_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_dc1", 0, false, true, false)
FAILURE_ELEC_DC2_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_dc2", 0, false, true, false)
FAILURE_ELEC_DC_ESS_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_dc_ess", 0, false, true, false)
FAILURE_ELEC_DC_ESS_SHED_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_dc_ess_shed", 0, false, true, false)
FAILURE_ELEC_DC_BAT_bus = createGlobalPropertyi("a321neo/failures/electrical/bus_dc_bat", 0, false, true, false)

FAILURE_FCTL_SFCC_1 =        createGlobalPropertyi("a321neo/failures/fctl/sfcc_1", 0, false, true, false)--slats flaps computer 1 failure
FAILURE_FCTL_SFCC_2 =        createGlobalPropertyi("a321neo/failures/fctl/sfcc_2", 0, false, true, false)--slats flaps computer 2 failure
FAILURE_FCTL_ELAC_1 =        createGlobalPropertyi("a321neo/failures/fctl/elac_1", 0, false, true, false)--elevator aileron computer 1 failure
FAILURE_FCTL_ELAC_2 =        createGlobalPropertyi("a321neo/failures/fctl/elac_2", 0, false, true, false)--elevator aileron computer 2 failure
FAILURE_FCTL_FAC_1 =        createGlobalPropertyi("a321neo/failures/fctl/fac_1", 0, false, true, false)--flight augmentation computer 1 failure
FAILURE_FCTL_FAC_2 =        createGlobalPropertyi("a321neo/failures/fctl/fac_2", 0, false, true, false)--flight augmentation computer 2 failure
FAILURE_FCTL_SEC_1 =        createGlobalPropertyi("a321neo/failures/fctl/sec_1", 0, false, true, false)--spoiler elevator computer 1 failure
FAILURE_FCTL_SEC_2 =        createGlobalPropertyi("a321neo/failures/fctl/sec_2", 0, false, true, false)--spoiler elevator computer 2 failure
FAILURE_FCTL_SEC_3 =        createGlobalPropertyi("a321neo/failures/fctl/sec_3", 0, false, true, false)--spoiler elevator computer 3 failure
FAILURE_FCTL_LAIL =          createGlobalPropertyi("a321neo/failures/fctl/l_aileron", 0, false, true, false)--jam l aileron
FAILURE_FCTL_RAIL =          createGlobalPropertyi("a321neo/failures/fctl/r_aileron", 0, false, true, false)--jam r aileron
FAILURE_FCTL_LSPOIL_1 =      createGlobalPropertyi("a321neo/failures/fctl/l_spoiler_1", 0, false, true, false)--jam l spoiler 1
FAILURE_FCTL_LSPOIL_2 =      createGlobalPropertyi("a321neo/failures/fctl/l_spoiler_2", 0, false, true, false)--jam l spoiler 2
FAILURE_FCTL_LSPOIL_3 =      createGlobalPropertyi("a321neo/failures/fctl/l_spoiler_3", 0, false, true, false)--jam l spoiler 3
FAILURE_FCTL_LSPOIL_4 =      createGlobalPropertyi("a321neo/failures/fctl/l_spoiler_4", 0, false, true, false)--jam l spoiler 4
FAILURE_FCTL_LSPOIL_5 =      createGlobalPropertyi("a321neo/failures/fctl/l_spoiler_5", 0, false, true, false)--jam l spoiler 5
FAILURE_FCTL_RSPOIL_1 =      createGlobalPropertyi("a321neo/failures/fctl/r_spoiler_1", 0, false, true, false)--jam r spoiler 1
FAILURE_FCTL_RSPOIL_2 =      createGlobalPropertyi("a321neo/failures/fctl/r_spoiler_2", 0, false, true, false)--jam r spoiler 2
FAILURE_FCTL_RSPOIL_3 =      createGlobalPropertyi("a321neo/failures/fctl/r_spoiler_3", 0, false, true, false)--jam r spoiler 3
FAILURE_FCTL_RSPOIL_4 =      createGlobalPropertyi("a321neo/failures/fctl/r_spoiler_4", 0, false, true, false)--jam r spoiler 4
FAILURE_FCTL_RSPOIL_5 =      createGlobalPropertyi("a321neo/failures/fctl/r_spoiler_5", 0, false, true, false)--jam r spoiler 5
FAILURE_FCTL_LELEV =         createGlobalPropertyi("a321neo/failures/fctl/l_elevator", 0, false, true, false)--jam l elevator
FAILURE_FCTL_RELEV =         createGlobalPropertyi("a321neo/failures/fctl/r_elevator", 0, false, true, false)--jam r elevator
FAILURE_FCTL_THS =           createGlobalPropertyi("a321neo/failures/fctl/ths_trim", 0, false, true, false)--jam eletrical ths motor
FAILURE_FCTL_THS_MECH =      createGlobalPropertyi("a321neo/failures/fctl/ths_mechanical", 0, false, true, false)--jam mechanical ths deflection
FAILURE_FCTL_UP_SHIT_CREEK = createGlobalPropertyi("a321neo/failures/fctl/up_shit_creek", 0, false, true, false)--jam every single surface

FAILURE_FUEL = createGlobalPropertyia("a321neo/failures/fuel/pumps", 8)
FAILURE_FUEL_X_FEED = createGlobalPropertyi("a321neo/failures/fuel/x_feed_valve", 0, false, true, false)--x feed valve
FAILURE_FUEL_APU_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/fuel/apu_valve_stuck", 0, false, true, false)
FAILURE_FUEL_APU_PUMP_FAIL   = createGlobalPropertyi("a321neo/failures/fuel/apu_pump_fail", 0, false, true, false)
FAILURE_FUEL_ENG1_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/fuel/eng1_firewall_valve_stuck", 0, false, true, false)
FAILURE_FUEL_ENG2_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/fuel/eng2_firewall_valve_stuck", 0, false, true, false)
FAILURE_FUEL_LEAK = createGlobalPropertyia("a321neo/failures/fuel/leak", 5) -- Leak, 0: ctr, 1: l, 2: r, 3: act, 4: rct
FAILURE_FUEL_FQI_1_FAULT = createGlobalPropertyi("a321neo/failures/fuel/fqi_1", 0, false, true, false)
FAILURE_FUEL_FQI_2_FAULT = createGlobalPropertyi("a321neo/failures/fuel/fqi_2", 0, false, true, false)


FAILURE_ENG_1_FUEL_CLOG = createGlobalPropertyi("a321neo/failures/engines/eng_1_fuel_clog", 0, false, true, false)
FAILURE_ENG_2_FUEL_CLOG = createGlobalPropertyi("a321neo/failures/engines/eng_2_fuel_clog", 0, false, true, false)
FAILURE_ENG_1_OIL_CLOG = createGlobalPropertyi("a321neo/failures/engines/eng_1_oil_clog", 0, false, true, false)
FAILURE_ENG_2_OIL_CLOG = createGlobalPropertyi("a321neo/failures/engines/eng_2_oil_clog", 0, false, true, false)
FAILURE_ENG_APU_FAIL   = createGlobalPropertyi("a321neo/failures/engines/apu_fail", 0, false, true, false)
FAILURE_ENG_APU_LOW_OIL_P = createGlobalPropertyi("a321neo/failures/engines/apu_low_oil_press", 0, false, true, false) -- 0: OK, 1: FAILED

FAILURE_ENG_1_FAILURE = createGlobalPropertyi("a321neo/failures/engines/eng_1_failure", 0, false, true, false)
FAILURE_ENG_2_FAILURE = createGlobalPropertyi("a321neo/failures/engines/eng_2_failure", 0, false, true, false)


FAILURE_BLEED_HP_1_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/hp_valve_1_stuck", 0, false, true, false)
FAILURE_BLEED_HP_2_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/hp_valve_2_stuck", 0, false, true, false)
FAILURE_BLEED_IP_1_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/ip_valve_1_stuck", 0, false, true, false)
FAILURE_BLEED_IP_2_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/ip_valve_2_stuck", 0, false, true, false)
FAILURE_BLEED_APU_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/apu_valve_stuck", 0, false, true, false)
FAILURE_BLEED_XBLEED_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/xbleed_valve_stuck", 0, false, true, false)
FAILURE_BLEED_PACK_1_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/pack_1_stuck", 0, false, true, false)
FAILURE_BLEED_PACK_2_VALVE_STUCK = createGlobalPropertyi("a321neo/failures/bleed/pack_2_stuck", 0, false, true, false)
FAILURE_BLEED_BMC_1 = createGlobalPropertyi("a321neo/failures/bleed/bmc_1", 0, false, true, false)
FAILURE_BLEED_BMC_2 = createGlobalPropertyi("a321neo/failures/bleed/bmc_2", 0, false, true, false)
FAILURE_BLEED_RAM_AIR_STUCK = createGlobalPropertyi("a321neo/failures/bleed/ram_air_stuck", 0, false, true, false)

FAILURE_AIRCOND_FAN_FWD = createGlobalPropertyi("a321neo/failures/aircond/vent/cab_fan_fwd", 0, false, true, false)
FAILURE_AIRCOND_FAN_AFT = createGlobalPropertyi("a321neo/failures/aircond/vent/cab_fan_aft", 0, false, true, false)
FAILURE_AIRCOND_HOT_AIR_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_stuck", 0, false, true, false)
FAILURE_AIRCOND_HOT_AIR_CARGO_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_cargo_stuck", 0, false, true, false)
FAILURE_AIRCOND_ISOL_CARGO_IN_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_cargo_stuck_in", 0, false, true, false)
FAILURE_AIRCOND_ISOL_CARGO_OUT_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_cargo_stuck_out", 0, false, true, false)
FAILURE_AIRCOND_VENT_BLOWER = createGlobalPropertyi("a321neo/failures/aircond/vent/avionics_blower", 0, false, true, false)
FAILURE_AIRCOND_VENT_EXTRACT = createGlobalPropertyi("a321neo/failures/aircond/vent/avionics_extract", 0, false, true, false)

FAILURE_AI_PITOT_CAPT = createGlobalPropertyi("a321neo/failures/anti_ice/capt_pitot", 0, false, true, false)
FAILURE_AI_PITOT_FO   = createGlobalPropertyi("a321neo/failures/anti_ice/fo_pitot", 0, false, true, false)
FAILURE_AI_PITOT_STDBY= createGlobalPropertyi("a321neo/failures/anti_ice/stdby_pitot", 0, false, true, false)
FAILURE_AI_SP_CAPT    = createGlobalPropertyi("a321neo/failures/anti_ice/capt_sp", 0, false, true, false)
FAILURE_AI_SP_FO      = createGlobalPropertyi("a321neo/failures/anti_ice/fo_sp", 0, false, true, false)
FAILURE_AI_SP_STDBY   = createGlobalPropertyi("a321neo/failures/anti_ice/stdby_ap", 0, false, true, false)
FAILURE_AI_AOA_CAPT   = createGlobalPropertyi("a321neo/failures/anti_ice/capt_aoa", 0, false, true, false)
FAILURE_AI_AOA_FO     = createGlobalPropertyi("a321neo/failures/anti_ice/fo_aoa", 0, false, true, false)
FAILURE_AI_AOA_STDBY  = createGlobalPropertyi("a321neo/failures/anti_ice/stdby_aoa", 0, false, true, false)
FAILURE_AI_TAT_CAPT   = createGlobalPropertyi("a321neo/failures/anti_ice/capt_tat", 0, false, true, false)
FAILURE_AI_TAT_FO     = createGlobalPropertyi("a321neo/failures/anti_ice/fo_tat", 0, false, true, false)

FAILURE_AI_Eng1_valve_stuck = createGlobalPropertyi("a321neo/failures/anti_ice/eng_1_valve", 0, false, true, false)
FAILURE_AI_Eng2_valve_stuck = createGlobalPropertyi("a321neo/failures/anti_ice/eng_2_valve", 0, false, true, false)
FAILURE_AI_Wing_L_valve_stuck = createGlobalPropertyi("a321neo/failures/anti_ice/wing_r_valve", 0, false, true, false)
FAILURE_AI_Wing_R_valve_stuck = createGlobalPropertyi("a321neo/failures/anti_ice/wing_l_valve", 0, false, true, false)
FAILURE_AI_Window_Heat_L = createGlobalPropertyi("a321neo/failures/anti_ice/window_heat_l", 0, false, true, false)
FAILURE_AI_Window_Heat_R = createGlobalPropertyi("a321neo/failures/anti_ice/window_heat_r", 0, false, true, false)

FAILURE_AVIONICS_SMOKE = createGlobalPropertyi("a321neo/failures/misc/avionics_smoke", 0, false, true, false)
FAILURE_AVIONICS_INLET = createGlobalPropertyi("a321neo/failures/misc/avionics_inlet", 0, false, true, false)
FAILURE_AVIONICS_OUTLET = createGlobalPropertyi("a321neo/failures/misc/avionics_outlet", 0, false, true, false)

FAILURE_PRESS_SAFETY_OPEN = createGlobalPropertyi("a321neo/failures/pressurization/safety_valve_open", 0, false, true, false)
FAILURE_OXY_REGUL_FAIL = createGlobalPropertyi("a321neo/failures/misc/oxy_reg_fault", 0, false, true, false)

