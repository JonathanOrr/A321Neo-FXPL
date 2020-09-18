-- General
ReqMasterCaution      = createGlobalPropertyi("a321neo/failures/req_master_caution", 0, false, true, false) -- When a component (typically EWD) wants to trigger a caution put this to 1
ReqMasterWarning      = createGlobalPropertyi("a321neo/failures/req_master_warning", 0, false, true, false) -- When a component (typically EWD) wants to trigger a warning put this to 1

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

