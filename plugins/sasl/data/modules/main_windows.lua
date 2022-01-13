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
-- File: main_windows.lua 
-- Short description: The file containing the code for the windows
-------------------------------------------------------------------------------

addSearchPath(moduleDirectory .. "/Custom Module/debug_windows/")
addSearchPath(moduleDirectory .. "/Custom Module/display_pop-ups/")
addSearchPath(moduleDirectory .. "/Custom Module/Cinetracker/")
addSearchPath(moduleDirectory .. "/Custom Module/Cinetracker/cinetracker_huds")

 --windows
MCDU_window = contextWindow {
  name = "Captain MCDU";
  position = { 150 , 150 , 413 , 644 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 413 , 644 };
  maximumSize = { 826, 1290 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    MCDU_popup {position = { 0 , 0 , 413 , 644 }, focused = true}
  };
}


--[[Vnav_debug_window = contextWindow {
  name = "VNAV DEBUG";
  position = { 50 , 50 , 750 , 450 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 750 , 450 };
  maximumSize = { 1125 , 675 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    vnav_debug {position = { 0 , 0 , 750 , 450 }}
  };
}]]

Packs_debug_window = contextWindow {
  name = "PACKS DEBUG";
  position = { 100 , 100 , 750 , 550 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 750 , 550 };
  maximumSize = { 750 , 550 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    packs_debug {position = { 0 , 0 , 750 , 550 }}
  };
}

--[[SSS_FBW_UI = contextWindow {
  name = "SSS FBW UI";
  position = { 50 , 250 , 975 , 600};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 500 , 300 };
  maximumSize = { 1000 , 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    FBW_UI {position = { 0 , 0 , 1000 , 600 }}
  };
}]]

ECAM_debug_window = contextWindow {
  name = "ECAM DEBUG";
  position = { 200 , 200 , 340 , 200};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 340 , 400 };
  maximumSize = { 340 , 400 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    ECAM_debug {position = { 0 , 0 , 340 , 200 }}
  };
}

ELEC_debug_window = contextWindow {
  name = "ELEC DEBUG";
  position = { 200 , 200 , 1000 , 600};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 1000 , 600 };
  maximumSize = { 1000 , 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    electrical_debug {position = { 0 , 0 , 1000 , 600 }}
  };
}

ENG_debug_window = contextWindow {
  name = "ENG DEBUG";
  position = { 200 , 200 , 500 , 500};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 500 , 500 };
  maximumSize = { 500 , 500 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    engines_debug {position = { 0 , 0 , 500 , 500 }}
  };
}

PRESS_debug_window = contextWindow {
  name = "Pressurization Debug";
  position = { 150 , 150 , 500 , 300 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 500 , 300 };
  maximumSize = { 500 , 300 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    pressurization_debug {position = { 0 , 0 , 500 , 300 }}
  };
}

ADIRS_debug_window = contextWindow {
  name = "ADIRS Debug";
  position = { 150 , 150 , 700 , 500 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 700 , 500 };
  maximumSize = { 700 , 500 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    adirs_debug {position = { 0 , 0 , 700 , 500 }}
  };
}


DCDU_window = contextWindow {
  name = "DCDU Management";
  position = { 150 , 150 , 463 , 683 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 400 , 400 };
  maximumSize = { 400 , 400 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    DCDU_window {position = { 0 , 0 , 463 , 683 }, focused = true}
  };
}

failures_window = contextWindow {
  name = "Failures Management";
  position = { 150 , 150 , 800 , 600 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 800 , 600 };
  maximumSize = { 800 , 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    failures_window {position = { 0 , 0 , 800 , 600 }}
  };
}

Checklist_window = contextWindow {
  name = "A32NX Interactive Checklist";
  position = { 50 , 50 , 480 , 550 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 240 , 275 };
  maximumSize = { 480 , 550 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    checklist {position = { 0 , 0 , 480 , 550 }}
  };
}

fuel_window = contextWindow {
  name = "Refuel Panel";
  position = { 150 , 150 , 800 , 600 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 800 , 600 };
  maximumSize = { 800 , 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    fuel_window {position = { 0 , 0 , 800 , 600 }}
  };
}

Performance_debug_window = contextWindow {
  name = "PERFORMANCE DEBUG";
  position = { 150 , 150 , 400, 600 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 400, 600 };
  maximumSize = { 400, 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = debug_performance_measure;
  components = {
    performance_debug {position = { 0 , 0 , 400 , 600 }}
  };
}

Wheel_debug_window = contextWindow {
  name = "WHEEL DEBUG";
  position = { 150 , 150 , 500, 500 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 500, 500 };
  maximumSize = { 500, 500 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
    wheel_debug {position = { 0 , 0 , 500, 500 }}
  };
}

GPWS_debug_window = contextWindow {
  name = "GPWS DEBUG";
  position = { 150 , 150 , 500, 500 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 500, 500 };
  maximumSize = { 500, 500 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
    GPWS_debug {position = { 0 , 0 , 500, 500 }}
  };
}


NAVAIDs_debug_window = contextWindow {
  name = "NAVAIDs DEBUG";
  position = { 150 , 150 , 600, 600 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 600, 600 };
  maximumSize = { 600, 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
    navaids_debug {position = { 0 , 0 , 600, 600 }}
  };
}


--popups--
CAPT_PFD_window = contextWindow {
  name = "CAPT PFD";
  position = { 0 , 0 , 900, 900 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 400, 400 };
  maximumSize = { 900, 900 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      CAPT_PFD_pop_up {}
  };
}

FO_PFD_window = contextWindow {
  name = "FO PFD";
  position = { 0 , 0 , 900, 900 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 400, 400 };
  maximumSize = { 900, 900 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      FO_PFD_pop_up {}
  };
}

CAPT_ND_window = contextWindow {
  name = "CAPT ND";
  position = { 0 , 0 , 900, 900 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 400, 400 };
  maximumSize = { 900, 900 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      CAPT_ND_pop_up {}
  };
}

FO_ND_window = contextWindow {
  name = "FO ND";
  position = { 0 , 0 , 900, 900 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 400, 400 };
  maximumSize = { 900, 900 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      FO_ND_pop_up {}
  };
}

EWD_window = contextWindow {
  name = "EWD";
  position = { 0 , 0 , 900, 900 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 400, 400 };
  maximumSize = { 900, 900 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      EWD_pop_up {}
  };
}

ECAM_window = contextWindow {
  name = "ECAM";
  position = { 0 , 0 , 900, 900 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 400, 400 };
  maximumSize = { 900, 900 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      ECAM_pop_up {}
  };
}

ISIS_window = contextWindow {
  name = "ISIS";
  position = { 0 , 0 , 250, 250 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 250, 250 };
  maximumSize = { 500, 500 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      ISIS_popup {}
  };
}

MAGIC_window = contextWindow {
  name = "Magic";
  position = { 0 , 0 , 300, 100 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 300, 100 };
  maximumSize = { 300, 100 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      magic {}
  };
}

PID_UI_window = contextWindow {
  name = "PID TUNING UI";
  position = { 150 , 150 , 600, 300 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 600 , 300 };
  maximumSize = { 600 , 300 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    PID_UI {position = { 0 , 0 , 600 , 300 }}
  };
}

Lnav_debug_window = contextWindow {
  name = "LNAV DEBUG";
  position = { 0 , 0 , 900, 900 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 400, 400 };
  maximumSize = { 900, 900 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      lnav_debug {}
  };
}

Cinetracker_window = contextWindow {
  name = "C* CINETRACKER";
  position = { 50 , 50 , 480 , 550 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 240 , 275 };
  maximumSize = { 480 , 550 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    cinetracker_main {}
  };
}

Cinetracker_HUD = contextWindow {
  name = "CINETRACKER HUD";
  position = { 0 , 0 , 408 , 561 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 408 / 4 , 561 / 4};
  maximumSize = { 408 , 561 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  noDecore = true ;
  layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
  noMove = true;
  components = {
    spd {}
  };
}

Cinetracker_ABNZ = contextWindow {
  name = "CINETRACKER ABNZ";
  position = { 0 , 0 , 600, 424 };
  noBackground = false ;
  proportional = true ;
  minimumSize = { 600/10, 424/10 };
  maximumSize = { 600, 424 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
      alpha_beta_nz {}
  };
}


FMGS_debug_window = contextWindow {
  name = "FMGS Debug";
  position = { 150 , 150 , 1000 , 600 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 1000 , 600 };
  maximumSize = { 1000 , 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    FMGS_debug {position = { 0 , 0 , 1000 , 600 }}
  };
}