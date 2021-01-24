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
-- File: global_variables.lua
-- Short description: A global file containing miscellaneous variables
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- CAUTION: Global = bad. You have been warned. Rico's watching you.
-------------------------------------------------------------------------------
-- NO FUNCTIONS HERE! See `global_functions.lua`
-- NO CONSTANTS HERE! See `constants.lua` (except fonts)
-- NO DATAREFS HERE! See `dynamic_datarefs.lua`, `cockpit_datarefs.lua`, `failure_datarefs.lua`
-- NO COMMANDS HERE! See `cockpit_commands.lua`
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

Font_7_digits         = sasl.gl.loadFont("fonts/digital-7.mono.ttf")
Font_B612regular      = sasl.gl.loadFont("fonts/B612-Regular.ttf")
Font_B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
Font_B612MONO_bold    = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")

Perf_array = {}

ELEC_sys = {}
Fuel_sys = {}
FIRE_sys = {}
AI_sys   = {}
ADIRS_sys= {}

EFB_preferences = {}

Data_manager = {}

Mcdu_popup = {}
Mcdu_popup_lut = 0


