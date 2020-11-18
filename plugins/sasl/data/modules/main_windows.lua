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

 --windows
MCDU_window = contextWindow {
  name = "Airbus MCDU";
  position = { 150 , 150 , 463 , 683 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 463 , 683 };
  maximumSize = { 877 , 1365 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    MCDU_popup {position = { 0 , 0 , 463 , 683 }, focused = true}
  };
}

Vnav_debug_window = contextWindow {
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
}

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

SSS_FBW_UI = contextWindow {
  name = "SSS FBW UI";
  position = { 50 , 250 , 1000 , 600};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 500 , 300 };
  maximumSize = { 1000 , 600 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    FBW_UI {position = { 0 , 0 , 1000 , 600 }}
  };
}

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

DMC_debug_window = contextWindow {
  name = "DMC DEBUG";
  position = { 200 , 200 , 400 , 200};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 400 , 200 };
  maximumSize = { 400 , 200 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    dmc_debug {position = { 0 , 0 , 400 , 200 }}
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

PID_UI_window = contextWindow {
  name = "PID TUNING UI";
  position = { 150 , 150 , 600, 260 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 600 , 260 };
  maximumSize = { 600 , 260 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    PID_UI {position = { 0 , 0 , 600 , 260 }}
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
  visible = true;
  components = {
    wheel_debug {position = { 0 , 0 , 500, 500 }}
  };
}


