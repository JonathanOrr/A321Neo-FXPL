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
-- File: main_menu.lua 
-- Short description: The file containing the functions related to the X-Plane
--                    menu 
-------------------------------------------------------------------------------

include("libs/table.save.lua")

--menu item functions
function Show_hide_MCDU()
  MCDU_window:setIsVisible(not MCDU_window:isVisible())
end

--function Show_hide_vnav_debug()
--  Vnav_debug_window:setIsVisible(not Vnav_debug_window:isVisible())
--end

function Show_hide_packs_debug()
  Packs_debug_window:setIsVisible(not Packs_debug_window:isVisible())
end

--[[function Show_hide_FBW_UI()
  SSS_FBW_UI:setIsVisible(not SSS_FBW_UI:isVisible())
end]]--

function Show_hide_PID_UI()
  PID_UI_window:setIsVisible(not PID_UI_window:isVisible())
end

function Show_hide_ADIRS_debug()
  ADIRS_debug_window:setIsVisible(not ADIRS_debug_window:isVisible())
end

function Show_hide_ECAM_debug()
  ECAM_debug_window:setIsVisible(not ECAM_debug_window:isVisible())
end

function Show_hide_ELEC_debug()
  ELEC_debug_window:setIsVisible(not ELEC_debug_window:isVisible())
end

function Show_hide_FMGS_debug()
  FMGS_debug_window:setIsVisible(not FMGS_debug_window:isVisible())
end


function Show_hide_ENG_debug()
  ENG_debug_window:setIsVisible(not ENG_debug_window:isVisible())
end

function Show_hide_PRESS_debug()
    PRESS_debug_window:setIsVisible(not PRESS_debug_window:isVisible())
end

function Show_hide_DCDU()
  DCDU_window:setIsVisible(not DCDU_window:isVisible())
end

function Show_hide_Failures()
  failures_window:setIsVisible(not failures_window:isVisible())
end

function Show_hide_Checklist()
  Checklist_window:setIsVisible(not Checklist_window:isVisible())
end

function Show_hide_Fuel()
  fuel_window:setIsVisible(not fuel_window:isVisible())
end

function Show_hide_Performance_Debug()
  Performance_debug_window:setIsVisible(not Performance_debug_window:isVisible())
end

function Show_hide_Wheel_Debug()
  Wheel_debug_window:setIsVisible(not Wheel_debug_window:isVisible())
end

function Show_hide_GPWS_Debug()
  GPWS_debug_window:setIsVisible(not GPWS_debug_window:isVisible())
end

function Show_hide_NAVAIDs_Debug()
  NAVAIDs_debug_window:setIsVisible(not NAVAIDs_debug_window:isVisible())
end

function Show_hide_Lnav_Debug()
  Lnav_debug_window:setIsVisible(not Lnav_debug_window:isVisible())
end

function Show_hide_MAGIC_Debug()
  MAGIC_window:setIsVisible(not MAGIC_window:isVisible())
end

function Show_hide_Cinetracker()
  Cinetracker_window:setIsVisible(not Cinetracker_window:isVisible())
end

function Show_hide_Exporter()
  Exporter_window:setIsVisible(not Exporter_window:isVisible())
end


function IRs_instaneous_align()
    ADIRS_cmd_instantaneous_align = sasl.findCommand("a321neo/cockpit/ADIRS/instantaneous_align")
    sasl.messageWindow (500 , 500 , 300 , 100 , " IRs auto-align " , 
                    " I will instantaneous align ONLY the IR turned ON and with knob selector to NAV ",
                    1 , " Understood " , function() sasl.commandOnce (ADIRS_cmd_instantaneous_align) end)
end

function Save_current_view_as_default()
    local current_view = {
      get(Head_x),
      get(Head_y),
      get(Head_z),
      get(Head_the),
    }

    table.save(current_view, moduleDirectory .. "/Custom Module/saved_configs/saved_view")
end

function Reset_RAT()
    if get(All_on_ground) == 0 then
        sasl.messageWindow (500 , 500 , 300 , 150 , " This is a ground-only operation " , 
                "In order to stow the RAT you must be on ground and press a switch in a panel accessible from the belly of the aircraft.",
                2 , " Cancel " , function() end, " I'm spiderman ", function()
                    ELEC_sys.generators[5].switch_status = false
                    set(is_RAT_out, 0)
                end)
    else
        ELEC_sys.generators[5].switch_status = false
        set(is_RAT_out, 0)
    end
end

function Reset_HYD()
    if get(All_on_ground) == 0 then
        sasl.messageWindow (500 , 500 , 300 , 150 , " This is a ground-only operation " , 
                "In order to refill the HYD systems you must be on ground, open a panel accessible from the belly of the aircraft and do fancy stuff with tubes and pumps.",
                2 , " Cancel " , function() end, " I'm spiderman ", function() sasl.commandOnce(HYD_reset_systems) end)
    else
        sasl.commandOnce(HYD_reset_systems)
    end
end

function Reset_IDG()
    if get(All_on_ground) == 0 then
        sasl.messageWindow (500 , 500 , 300 , 150 , " This is a ground-only operation " , 
                "In order to reconnect the IDGs you must be on ground, open the engine cowl and pull a special ring.",
                2 , " Cancel " , function() end, " I'm spiderman ", function() ELEC_sys.generators[1].idg_status = true; ELEC_sys.generators[2].idg_status = true end)
    else
        ELEC_sys.generators[1].idg_status = true
        ELEC_sys.generators[2].idg_status = true
    end
end

function Toggle_Ground_Air_Supply()
    if get(All_on_ground) == 0 then
        sasl.messageWindow (500 , 500 , 300 , 150 , " This is a ground-only operation " , 
                "In order to connect the Ground Air Supply you need to be on ground.",
                1 , " Ok " , function() end)
    else
        set(GAS_bleed_avail, 1 - get(GAS_bleed_avail))
    end
end

function Reset_Abn_law()
  set(Debug_FBW_ABN_LAW_RESET, 1)
end

-- create top level menu in plugins menu
Menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "A321NEO" )
-- add a submenu
Menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, Menu_master)

ShowHideChecklist   = sasl.appendMenuItem(Menu_main, "Show/Hide Checklist", Show_hide_Checklist)
ShowHideMCDU        = sasl.appendMenuItem(Menu_main, "Show/Hide MCDU", Show_hide_MCDU)
ShowHideDCDU        = sasl.appendMenuItem(Menu_main, "Show/Hide DCDU Manager", Show_hide_DCDU)
ShowHideFailures    = sasl.appendMenuItem(Menu_main, "Show/Hide Failures Manager", Show_hide_Failures)
ShowHideFuel        = sasl.appendMenuItem(Menu_main, "Show/Hide Fuel Panel", Show_hide_Fuel)
ShowHideCinetracker = sasl.appendMenuItem(Menu_main, "Show/Hide Cinetracker", Show_hide_Cinetracker)

sasl.appendMenuSeparator(Menu_main)

SaveView          = sasl.appendMenuItem(Menu_main, "Save view as default", Save_current_view_as_default)
ADIRSAlign        = sasl.appendMenuItem(Menu_main, "Instantaneous align IRs", IRs_instaneous_align)
ADIRSAlign        = sasl.appendMenuItem(Menu_main, "Toggle Ground Air Supply", Toggle_Ground_Air_Supply)
ResetAbnLaw       = sasl.appendMenuItem(Menu_main, "Reset Abnormal Law", Reset_Abn_law)
-- Maintenance submenu
Maintenance_item  = sasl.appendMenuItem (Menu_main, "Maintenance")
Maintenance_menu  = sasl.createMenu ("", Menu_main, Maintenance_item)
ShowHideVnavDebug	= sasl.appendMenuItem(Maintenance_menu, "Stow the RAT", Reset_RAT)
ShowHideVnavDebug	= sasl.appendMenuItem(Maintenance_menu, "Refill HYD systems", Reset_HYD)
ShowHideVnavDebug	= sasl.appendMenuItem(Maintenance_menu, "Reconnect IDGs", Reset_IDG)

sasl.appendMenuSeparator(Menu_main)

-- DEBUG submenu
Menu_debug_item	= sasl.appendMenuItem (Menu_main, "Debug" )
Menu_debug	= sasl.createMenu ("", Menu_main, Menu_debug_item)
--ShowHideFBWUI	= sasl.appendMenuItem(Menu_debug, "Show/Hide FBW UI", Show_hide_FBW_UI)
ShowHidePIDUI	= sasl.appendMenuItem(Menu_debug, "Show/Hide PID UI", Show_hide_PID_UI)
ShowHideExporter	= sasl.appendMenuItem(Menu_debug, "Show/Hide Data Exporter", Show_hide_Exporter)
ShowHideADIRSDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide ADIRS Debug", Show_hide_ADIRS_debug)
ShowHideECAMDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide ECAM Debug", Show_hide_ECAM_debug)
ShowHideELECDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide ELEC Debug", Show_hide_ELEC_debug)
ShowHideENGDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide ENG Debug", Show_hide_ENG_debug)
ShowHideFMGSDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide FMGS Debug", Show_hide_FMGS_debug)
ShowHideGPWSDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide GPWS Debug", Show_hide_GPWS_Debug)
ShowHideNAVAIDsDebug= sasl.appendMenuItem(Menu_debug, "Show/Hide NAVAIDs Debug", Show_hide_NAVAIDs_Debug)
ShowHidePacksDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide PACKS Debug", Show_hide_packs_debug)
ShowHidePerfDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide PERF Debug", Show_hide_Performance_Debug)
ShowHidePressDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide PRESS Debug", Show_hide_PRESS_debug)
ShowHideWheelDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide WHEEL Debug", Show_hide_Wheel_Debug)
--ShowHideVnavDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide VNAV Debug", Show_hide_vnav_debug)
ShowHideLnavDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide LNAV Debug", Show_hide_Lnav_Debug)
ShowHideGPWSDebug	= sasl.appendMenuItem(Menu_debug, "Show/Hide MAGIC Debug", Show_hide_MAGIC_Debug)

Menu_FLT_SYS_item	= sasl.appendMenuItem (Menu_debug, "FLT SYS")
Menu_FLT_SYS = sasl.createMenu("", Menu_debug, Menu_FLT_SYS_item)

FLT_SYS_FCTL_debug_item = sasl.appendMenuItem (Menu_FLT_SYS, "F-CTL")
FLT_SYS_FCTL_debug = sasl.createMenu("", Menu_FLT_SYS, FLT_SYS_FCTL_debug_item)
FLT_SYS_FBW_debug_item = sasl.appendMenuItem (Menu_FLT_SYS, "FBW")
FLT_SYS_FBW_debug = sasl.createMenu("", Menu_FLT_SYS, FLT_SYS_FBW_debug_item)

--F-CTL debug--
sasl.appendMenuItem(FLT_SYS_FCTL_debug, "GND SPLR DEBUG", function ()
  GND_SPLR_debug_window:setIsVisible(not GND_SPLR_debug_window:isVisible())
end)

--FBW debug--
sasl.appendMenuItem(FLT_SYS_FBW_debug, "FBW PID DEBUG", function ()
  FBW_PID_debug_window:setIsVisible(not FBW_PID_debug_window:isVisible())
end)