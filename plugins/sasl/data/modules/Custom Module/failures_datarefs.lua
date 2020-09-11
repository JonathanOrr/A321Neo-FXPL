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

