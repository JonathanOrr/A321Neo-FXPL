--global dataref for the A32NX project
Distance_traveled_km = createGlobalPropertyf("a321neo/dynamics/distance_traveled_km", 0, false, true, false)
Groudn_speed_kmh = createGlobalPropertyf("a321neo/dynamics/groundspeed_kmh", 0, false, true, false)
Engine_1_master_switch = createGlobalPropertyi("a321neo/engine/master_1", 0, false, true, false)
Engine_2_master_switch = createGlobalPropertyi("a321neo/engine/master_2", 0, false, true, false)

--global dataref variable from the Sim
Distance_traveled_m = globalProperty("sim/flightmodel/controls/dist")
Ground_speed_ms = globalProperty("sim/flightmodel/position/groundspeed")
Engine_1_avail = globalProperty("sim/flightmodel/engine/ENGN_running[0]")
Engine_2_avail = globalProperty("sim/flightmodel/engine/ENGN_running[1]")