FAILURE_Apu = globalProperty("sim/operation/failures/rel_apu")
FAILURE_Apu_fire = globalProperty("sim/operation/failures/rel_apu_fire")
FAILURE_TCAS = globalProperty("sim/operation/failures/rel_xpndr")


FAILURE_gear = createGlobalPropertyi("a321neo/failures/gear_failure", 0, false, true, false) -- 0: OK, 1: NOT UPLOCKED, 2: NOT DOWNLOCKED (internal use only, do not set manually)

FAILURE_ADR = {}
FAILURE_ADR[1] = createGlobalPropertyi("a321neo/failures/adirs/adr_1", 0, false, true, false) -- 0: OK, 1: FAILED
FAILURE_ADR[2] = createGlobalPropertyi("a321neo/failures/adirs/adr_2", 0, false, true, false) -- 0: OK, 1: FAILED
FAILURE_ADR[3] = createGlobalPropertyi("a321neo/failures/adirs/adr_3", 0, false, true, false) -- 0: OK, 1: FAILED
