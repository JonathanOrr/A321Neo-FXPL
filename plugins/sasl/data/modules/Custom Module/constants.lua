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
-- File: constants.lua 
-- Short description: This file contains the global constants
-------------------------------------------------------------------------------

--colors
ECAM_WHITE = {1.0, 1.0, 1.0}
ECAM_LINE_GREY = {62/255, 74/255, 91/255}
ECAM_HIGH_GREY = {0.6, 0.6, 0.6}
ECAM_BLUE = {0.004, 1.0, 1.0}
ECAM_GREEN = {0.20, 0.98, 0.20}
ECAM_HIGH_GREEN = {0.1, 0.6, 0.1}
ECAM_ORANGE = {1, 0.66, 0.16}
ECAM_RED = {1.0, 0.0, 0.0}
ECAM_MAGENTA = {1.0, 0.0, 1.0}
ECAM_GREY = {0.3, 0.3, 0.3}
ECAM_BLACK = {0, 0, 0}
UI_WHITE = {1.0, 1.0, 1.0}
UI_LIGHT_RED = {1.0, 0.3, 0.3}
UI_LIGHT_BLUE = {0, 0.708, 1}
UI_LIGHT_GREY = {0.2039, 0.2235, 0.247}
UI_DARK_GREY = {0.1568, 0.1803, 0.2039}
UI_DARK_BLUE = {0, 0.5, 0.7}
UI_BRIGHT_GREY = {0.5, 0.5, 0.5}
UI_GREEN = {0.10, 1, 0.30}
UI_YELLOW = {1, 1, 0.30}

-- ELEC buses
ELEC_BUS_AC_1 = 1
ELEC_BUS_AC_2 = 2
ELEC_BUS_AC_ESS = 3
ELEC_BUS_AC_ESS_SHED = 4
ELEC_BUS_DC_1 = 5
ELEC_BUS_DC_2 = 6
ELEC_BUS_DC_ESS = 7
ELEC_BUS_DC_ESS_SHED = 8
ELEC_BUS_DC_BAT_BUS = 9
ELEC_BUS_HOT_BUS_1 = 10
ELEC_BUS_HOT_BUS_2 = 11
ELEC_BUS_GALLEY = 12
ELEC_BUS_COMMERCIAL = 13
ELEC_BUS_STAT_INV = 14

-- Flight phases
PHASE_UNKNOWN        = 0
PHASE_ELEC_PWR       = 1
PHASE_1ST_ENG_ON     = 2
PHASE_1ST_ENG_TO_PWR = 3
PHASE_ABOVE_80_KTS   = 4
PHASE_LIFTOFF        = 5
PHASE_AIRBONE        = 6 
PHASE_FINAL          = 7        
PHASE_TOUCHDOWN      = 8
PHASE_BELOW_80_KTS   = 9 
PHASE_2ND_ENG_OFF    = 10

-- FUEL
FUEL_TOT_MAX   = 40962
FUEL_LR_MAX    = 8449
FUEL_C_MAX     = 8941
FUEL_ACT_MAX   = 5031
FUEL_RCT_MAX   = 10089

-- Pumps and XFR ids
L_TK_PUMP_1  = 1
L_TK_PUMP_2  = 2
R_TK_PUMP_1  = 3
R_TK_PUMP_2  = 4
C_TK_XFR_1   = 5
C_TK_XFR_2   = 6
ACT_TK_XFR = 7
RCT_TK_XFR = 8

-- Tanks
tank_LEFT  = 1
tank_RIGHT = 2
tank_CENTER= 0
tank_ACT   = 3
tank_RCT   = 4

-- Anti-ice
ANTIICE_ENG_1        = 1
ANTIICE_ENG_2        = 2
ANTIICE_WING_L       = 3
ANTIICE_WING_R       = 4
ANTIICE_WINDOW_HEAT_L= 5
ANTIICE_WINDOW_HEAT_R= 6
ANTIICE_PITOT_CAPT   = 7
ANTIICE_PITOT_FO     = 8
ANTIICE_PITOT_STDBY  = 9
ANTIICE_STATIC_CAPT  = 10
ANTIICE_STATIC_FO    = 11
ANTIICE_STATIC_STDBY = 12
ANTIICE_AOA_CAPT     = 13
ANTIICE_AOA_FO       = 14
ANTIICE_AOA_STDBY    = 15
ANTIICE_TAT_CAPT     = 16
ANTIICE_TAT_FO       = 17

-- Fonts
Font_AirbusDUL = sasl.gl.loadFont("fonts/AirbusDULiberationMono.ttf")
sasl.gl.setFontRenderMode(Font_AirbusDUL, TEXT_RENDER_FORCED_MONO, 0.6)

Font_AirbusDUL_small = sasl.gl.loadFont("fonts/AirbusDULiberationMono.ttf")
sasl.gl.setFontRenderMode(Font_AirbusDUL_small, TEXT_RENDER_FORCED_MONO, 0.6*1.47)

