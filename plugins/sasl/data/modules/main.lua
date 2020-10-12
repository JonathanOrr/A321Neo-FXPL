include("cockpit_commands.lua")
include("cockpit_datarefs.lua")
include("dynamic_datarefs.lua")
include("failures_datarefs.lua")
include("global_functions.lua")
include(moduleDirectory .. "/Custom Module/FBW_subcomponents/fbw_system_subcomponents/PID_arrays.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)

-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)

-- Initialize the random seed for math.random
math.randomseed( os.time() )

include(moduleDirectory .. "/main_debug.lua")

size = { 4096, 2048 }

panelWidth3d = 4096
panelHeight3d = 2048

components = {
  engine_and_apu {},
  FBW_main {},
  cabin_screens {},
  fcu_ap_at {},
  AT {},
  ADIRS {},
  MCDU {},
  packs {},
  aircond {},
  wheel {},
  source_switching {},
  PFD {},
  ND {},
  ISIS {},
  ECAM {},
  EWD {},
  EWD_logic {},
  EWD_flight_phases {},
  HUD {},
  DCDU {},
  DRAIMS {},
  failures_manager {},
  display_brightness {},
  doors {},
  hydraulics {},
  electrical {},
  sounds {}
 }

include(moduleDirectory .. "/main_windows.lua")
include(moduleDirectory .. "/main_menu.lua")
