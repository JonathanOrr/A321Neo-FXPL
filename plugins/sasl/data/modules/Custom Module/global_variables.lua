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

-- Performance array (used only when debug_performance_measure in main_debug.lua is `true`)
Perf_array = {}

-- Systems
ELEC_sys = {}
Fuel_sys = {}
FIRE_sys = {}
AI_sys   = {}
ADIRS_sys= {}
PFD = {}
ND_all_data  = {nil, nil}
ND_terrain = {}
DRAIMS_common = {}
FMGS_sys = {}
GPS_sys = {}
TCAS_sys = {}

WEIGHTS = {}

-- Engine data depending on the user choice
ENG = { data_is_loaded = false }

EFB = {
    prefrences = {
        toggles = {
            syncqnh = true,
            pausetd = false,
            copilot = false,
        },
        sliders = {
            sound_int = 1,
            sound_ext = 1,
            sound_warn = 1,
            sound_enviro = 1,
            display_aa = 0,
            brk_strength = 1,
        },
        dropdowns = {
            nws = 0,
        },
        networking = {
            simbrief_id = ""
        },
    },
}   


AvionicsBay = {}


-- MCDU
MCDU = {}

FBW = {
    rates = {},
    fctl = {
        surfaces = {},
        status = {},
        control = {},
    },
    lateral = {
        protections = {},
        inputs = {},
    },
    vertical = {
        protections = {},
        inputs = {},
    },
    yaw = {
        protections = {},
        inputs = {},
    },
    LAF = {
        inputs = {},
    },
    filtered_sensors = {}
}

Cinetracker = {}