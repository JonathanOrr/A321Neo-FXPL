FAILURE_Apu = globalProperty("sim/operation/failures/rel_apu")
FAILURE_Apu_fire = globalProperty("sim/operation/failures/rel_apu_fire")
FAILURE_TCAS = globalProperty("sim/operation/failures/rel_xpndr")


FAILURE_gear = createGlobalPropertyi("a321neo/failures/gear_failure", 0, false, true, false) -- 0: NO, 1: NOT UPLOCKED, 2: NOT DOWNLOCKED (internal use only, do not set manually)
