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
-- File: main.lua 
-- Short description: The main file for the project 
-------------------------------------------------------------------------------

include("cockpit_commands.lua")
include("cockpit_datarefs.lua")
include("dynamic_datarefs.lua")
include("failures_datarefs.lua")
include("global_variables.lua")
include("global_functions.lua")
include("pushbuttons.lua")
include("FBW_subcomponents/PID_arrays.lua")
include("sasl_drawing_assets.lua")
include("constants.lua")
include("ADIRS_data_source.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)

-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)

-- Initialize the random seed for math.random
math.randomseed( os.time() )

include(moduleDirectory .. "/main_debug.lua")
addSearchPath(moduleDirectory .. "/Custom Module/PFD/")
addSearchPath(moduleDirectory .. "/Custom Module/ND/")
addSearchPath(moduleDirectory .. "/Custom Module/EFB/")
addSearchPath(moduleDirectory .. "/Custom Module/PFD/PFD_subcomponents/")

position = {0, 0, 4096, 4096}
size = { 4096, 4096 }

panelWidth3d = 4096
panelHeight3d = 4096

components = {
  screen_backlights {},
  apu {},
  fuel {}, -- Please keep this before engines
  engines {},
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
  PFD_main {},
  CAPT_PFD {},
  FO_PFD {},
  CAPT_ND {},
  FO_ND {},
  ISIS {},
  ECAM {},
  EWD {},
  EWD_logic {},
  EWD_flight_phases {},
  HUD {},
  DCDU {},
  DRAIMS {},
  clock {},
  LED_screens {},
  failures_manager {},
  doors {},
  hydraulics {},
  electrical {},
  pressurization {},
  oxygen {},
  anti_ice {},
  calls {},
  GPWS {},
  sounds {},
  graphics {},
  display_brightness {},
  librain{},
  efb{},
}

include(moduleDirectory .. "/main_windows.lua")
include(moduleDirectory .. "/main_menu.lua")

