----------------------------------------------------------------------------------------------------
-- This file contains the global constants
----------------------------------------------------------------------------------------------------

--colors
ECAM_WHITE = {1.0, 1.0, 1.0}
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

-- Fonts
Font_AirbusDUL = sasl.gl.loadFont("fonts/AirbusDULiberationMono.ttf")
sasl.gl.setFontRenderMode(Font_AirbusDUL, TEXT_RENDER_FORCED_MONO, 0.6)
