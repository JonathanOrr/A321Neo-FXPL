--[[A32NX Adaptive Auto Throttle
Copyright (C) 2020 Jonathan Orr

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.]]

include("global_datarefs_functions.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)

-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)

--size = { 4096, 2048 }

components = {
  AT {}
}

--windows
A32nx_at_UI = contextWindow {
  name = "A32NX OPEN-SOURCE ADAPTIVE A/T";
  position = { 50 , 50 , 340 , 420};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 340 , 420 };
  maximumSize = { 340 , 420 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    at_ui {position = { 0 , 0 , 340 , 420 }}
  };
}

A32nx_at_graph = contextWindow {
  name = "A32NX A/T OUTPUT GRAPH";
  position = { 50 , 500 , 420 , 340};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 420 , 340 };
  maximumSize = { 420 , 340 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    at_graph {position = { 0 , 0 , 420 , 340 }}
  };
}

A32nx_FD = contextWindow {
  name = "A32NX FD POINTERS";
  position = { 50 , 500 , 800 , 400};
  noBackground = true ;
  proportional = false ;
  minimumSize = { 400 , 200 };
  maximumSize = { 800 , 400 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    fd {position = { 0 , 0 , 800 , 400 }}
  };
}


--menu item functions
function show_hide_ui()
  A32nx_at_UI:setIsVisible(not A32nx_at_UI:isVisible())
end

function show_hide_graph()
  A32nx_at_graph:setIsVisible(not A32nx_at_graph:isVisible())
end

function show_hide_fd()
  A32nx_FD:setIsVisible(not A32nx_FD:isVisible())
end


--change menu item status
function update()
  if A32nx_at_UI:isVisible() == true then
    sasl.setMenuItemState(Menu_main, ShowHideUi, MENU_CHECKED)
  else
    sasl.setMenuItemState(Menu_main, ShowHideUi, MENU_UNCHECKED)
  end

  if A32nx_at_graph:isVisible() == true then
    sasl.setMenuItemState(Menu_main, ShowHideGraph, MENU_CHECKED)
  else
    sasl.setMenuItemState(Menu_main, ShowHideGraph, MENU_UNCHECKED)
  end

  if A32nx_FD:isVisible() == true then
    sasl.setMenuItemState(Menu_main, ShowHideFd, MENU_CHECKED)
  else
    sasl.setMenuItemState(Menu_main, ShowHideFd, MENU_UNCHECKED)
  end

  updateAll(components)
end

-- create top level menu in plugins menu
Menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "A32NX ADAPTIVE A/T" )
-- add a submenu
Menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, Menu_master)
-- add menu entry
ShowHideUi	= sasl.appendMenuItem(Menu_main, "Show/Hide UI", show_hide_ui)
-- add menu entry
ShowHideFd	= sasl.appendMenuItem(Menu_main, "Show/Hide FD", show_hide_fd)
-- add menu entry
ShowHideGraph	= sasl.appendMenuItem(Menu_main, "Show/Hide Debug Graph", show_hide_graph)
--initialise menu item status
sasl.setMenuItemState(Menu_main, ShowHideUi, MENU_UNCHECKED)
sasl.setMenuItemState(Menu_main, ShowHideFd, MENU_UNCHECKED)
sasl.setMenuItemState(Menu_main, ShowHideGraph, MENU_UNCHECKED)