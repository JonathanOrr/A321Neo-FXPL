-- General
ReqMasterCaution      = createGlobalPropertyi("a321neo/failures/req_master_caution", 0, false, true, false) -- When a component (typically EWD) wants to trigger a caution put this to 1
ReqMasterWarning      = createGlobalPropertyi("a321neo/failures/req_master_warning", 0, false, true, false) -- When a component (typically EWD) wants to trigger a warning put this to 1

-- Instruments
FAILURE_radioalt_cap = createGlobalPropertyi("a321neo/failures/pfd/capt_radioalt", 0, false, true, false) -- 0: OK, 1: FAILED

-- Systems
FAILURE_Apu = globalProperty("sim/operation/failures/rel_apu")
FAILURE_Apu_fire = globalProperty("sim/operation/failures/rel_apu_fire")
FAILURE_TCAS = globalProperty("sim/operation/failures/rel_xpndr")


FAILURE_gear = createGlobalPropertyi("a321neo/failures/gear_failure", 0, false, true, false) -- 0: OK, 1: NOT UPLOCKED, 2: NOT DOWNLOCKED (internal use only, do not set manually)

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

FAILURE_FCTL_SFCC_1 = createGlobalPropertyi("a321neo/failures/fctl/sfcc_1", 0, false, true, false)--slats flaps computer 1 failure
FAILURE_FCTL_SFCC_2 = createGlobalPropertyi("a321neo/failures/fctl/sfcc_2", 0, false, true, false)--slats flaps computer 1 failure
FAILURE_FCTL_LAIL = createGlobalPropertyi("a321neo/failures/fctl/left_aileron", 0, false, true, false)--jam l aileron
FAILURE_FCTL_RAIL = createGlobalPropertyi("a321neo/failures/fctl/right_aileron", 0, false, true, false)--jam r aileron

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

FAILURE_AIRCOND_FAN_FWD = createGlobalPropertyi("a321neo/failures/aircond/fan_fwd", 0, false, true, false)
FAILURE_AIRCOND_FAN_AFT = createGlobalPropertyi("a321neo/failures/aircond/fan_aft", 0, false, true, false)
FAILURE_AIRCOND_HOT_AIR_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_stuck", 0, false, true, false)
FAILURE_AIRCOND_HOT_AIR_CARGO_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_cargo_stuck", 0, false, true, false)
FAILURE_AIRCOND_ISOL_CARGO_IN_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_cargo_stuck_in", 0, false, true, false)
FAILURE_AIRCOND_ISOL_CARGO_OUT_STUCK = createGlobalPropertyi("a321neo/failures/aircond/hot_air_cargo_stuck_out", 0, false, true, false)


