include("helpers.lua")
include("global_datarefs_functions.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)

-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)



size = { 4096, 2048 }

panelWidth3d = 4096
panelHeight3d = 2048



components = {
  engine_and_apu {},
  cabin_screens {},
  flight_controls {},
  fcu_ap_at {},
  AT {},
  packs {},
  aircond {},
  wheel {},
  EWD {},
  ECAM {}
 }

 --windows
Vnav_debug_window = contextWindow {
  name = "VNAV DEBUG";
  position = { 50 , 50 , 750 , 450};
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
  position = { 100 , 100 , 750 , 450};
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

FBW_debug_window = contextWindow {
  name = "FBW DEBUG";
  position = { 150 , 150 , 340 , 500};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 340 , 500 };
  maximumSize = { 680 , 1000 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = true ;
  components = {
    FBW_debug {position = { 0 , 0 , 340 , 500 }}
  };
}

--menu item functions
function Show_hide_vnav_debug()
  Vnav_debug_window:setIsVisible(not Vnav_debug_window:isVisible())
end

function Show_hide_packs_debug()
  Packs_debug_window:setIsVisible(not Packs_debug_window:isVisible())
end

function Show_hide_FBW_debug()
  FBW_debug_window:setIsVisible(not Packs_debug_window:isVisible())
end

-- create top level menu in plugins menu
Menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "A321NEO" )
-- add a submenu
Menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, Menu_master)
-- add menu entry
ShowHideVnavDebug	= sasl.appendMenuItem(Menu_main, "Show/Hide VNAV Debug", Show_hide_vnav_debug)
-- add menu entry
ShowHidePacksDebug	= sasl.appendMenuItem(Menu_main, "Show/Hide PACKS Debug", Show_hide_packs_debug)
-- add menu entry
ShowHideFBWDebug	= sasl.appendMenuItem(Menu_main, "Show/Hide FBW Debug", Show_hide_FBW_debug)
--initialise menu item status
sasl.setMenuItemState(Menu_main, ShowHideVnavDebug, MENU_UNCHECKED)
sasl.setMenuItemState(Menu_main, ShowHidePacksDebug, MENU_UNCHECKED)
sasl.setMenuItemState(Menu_main, ShowHideFBWDebug, MENU_UNCHECKED)