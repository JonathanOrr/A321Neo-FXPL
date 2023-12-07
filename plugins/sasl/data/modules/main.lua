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
include("graphics_helpers.lua")
include("pushbuttons.lua")
include("global_constants.lua")
include("PID.lua")
include("FLT_SYS/FBW/PID_arrays.lua")
include("sasl_drawing_assets.lua")
include("ADIRS_data_source.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)

-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)

-- Initialize the random seed for math.random
math.randomseed( os.time() )

include(moduleDirectory .. "/main_debug.lua")
addSearchPath(moduleDirectory .. "/Custom Module/NAV/")
addSearchPath(moduleDirectory .. "/Custom Module/PFD/")
addSearchPath(moduleDirectory .. "/Custom Module/ND/")
addSearchPath(moduleDirectory .. "/Custom Module/DRAIMS/")
addSearchPath(moduleDirectory .. "/Custom Module/EFB/")
addSearchPath(moduleDirectory .. "/Custom Module/PFD/PFD_subcomponents/")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/FBW")
addSearchPath(moduleDirectory .. "/Custom Module/MCDU/")
addSearchPath(moduleDirectory .. "/Custom Module/AUTOFLT/")
addSearchPath(moduleDirectory .. "/Custom Module/AOC_ATC/")
addSearchPath(moduleDirectory .. "/Custom Module/display_pop-ups/")
addSearchPath(moduleDirectory .. "/Custom Module/LED/")

position = {0, 0, 4096, 4096}
size = { 4096, 4096 }

panelWidth3d = 4096
panelHeight3d = 4096

components = {
  avionics_bay {},
  efb{},
  display_backlights {},    -- This must stay at the top
  display_switching {},
  apu {},
  fuel {}, -- Please keep this before engines
  engines {},
  cabin_screens {},

  NAV_main {},

  FMGS {},
  CAPT_MCDU {},
  FO_MCDU {},
  packs {},
  aircond {},
  wheel {},
  CAPT_ND {},
  FO_ND {},
  ISIS {},
  ECAM {},
  EWD {},
  EWD_logic {},
  EWD_flight_phases {},
  HUD {},
  DCDU {},
  clock {},
  LED_main {},
  failures_manager {},
  doors {},
  hydraulics {},
  electrical {},
  pressurization {},
  oxygen {},
  anti_ice {},
  fire_eng_apu {},
  fire_cargo {},

  FBW_main {},
  AUTOFLT_main {},

  CAPT_PFD {},
  FO_PFD {},
  calls {},
  GPWS {},
  sounds {},
  lights_external {},
  graphics {},
  radio_logic {},
  DRAIMS_CAPT {},
  DRAIMS_FO {},
  nav_updater {},
  tcas {},
  weights {},
  display_brightness {}, -- This must stay at the bottom

  main_popup {},

  librain{},

}

include(moduleDirectory .. "/main_windows.lua")
include(moduleDirectory .. "/main_menu.lua")

