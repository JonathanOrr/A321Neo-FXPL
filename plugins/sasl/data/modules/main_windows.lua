
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
  position = { 100 , 100 , 750 , 450 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 750 , 450 };
  maximumSize = { 1125 , 675 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    packs_debug {position = { 0 , 0 , 750 , 450 }}
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
