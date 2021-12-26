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
-- File: engines_debug.lua
-- Short description: Engine debug window
-------------------------------------------------------------------------------

size = {500, 500}


local Font_B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local xp_avail_1 = globalProperty("sim/flightmodel/engine/ENGN_running[0]")
local xp_avail_2 = globalProperty("sim/flightmodel/engine/ENGN_running[1]")

local Eng_1_N2_XP = globalProperty("sim/flightmodel2/engines/N2_percent[0]")
local Eng_2_N2_XP = globalProperty("sim/flightmodel2/engines/N2_percent[1]")

local Eng_1_EGT_XP = globalProperty("sim/cockpit2/engine/indicators/EGT_deg_C[0]")
local Eng_2_EGT_XP = globalProperty("sim/cockpit2/engine/indicators/EGT_deg_C[1]")

local eng_FF_kgs          = globalPropertyfa("sim/cockpit2/engine/indicators/fuel_flow_kg_sec")

local eng_ignition_switch = globalPropertyia("sim/cockpit2/engine/actuators/ignition_key")
local eng_mixture         = globalPropertyfa("sim/cockpit2/engine/actuators/mixture_ratio")
local eng_igniters        = globalPropertyia("sim/cockpit2/engine/actuators/igniter_on")

local starter_duration    = globalPropertyfa("sim/cockpit/engine/starter_duration")

function draw()

    sasl.gl.drawText(Font_B612MONO_regular, 120, 400, "ENGINE 1", 28, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]-120, 400, "ENGINE 2", 28, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawLine(size[1]/2, 430, size[1]/2, 20, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 20, 480, "Computed N1 IDLE value: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 210, 480, Round(get(Eng_N1_idle),2), 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, 460, "Engine mode: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    text = get(Engine_mode_knob) == 0 and "NORMAL" or (get(Engine_mode_knob) == 1 and "IGN" or "CRANK")
    sasl.gl.drawText(Font_B612MONO_regular, 120, 460, text, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, 440, "Sim Time: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, 440, Round(get(TIME),1), 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)


    -- AVAIL ENG1
    text  = ENG.dyn[1].is_avail and "AVAIL" or "NOT AVAIL"
    color = ENG.dyn[1].is_avail and UI_GREEN or UI_LIGHT_RED
    sasl.gl.drawText(Font_B612MONO_regular, 70, 375, text, 12, false, false, TEXT_ALIGN_CENTER, color)
    sasl.gl.drawFrame(30,370,80,20,color)

    text  = get(xp_avail_1) == 1 and "XP AVAIL" or "XP NOT AVAIL"
    color = get(xp_avail_1) == 1 and UI_GREEN or UI_LIGHT_RED
    sasl.gl.drawText(Font_B612MONO_regular, 180, 375, text, 12, false, false, TEXT_ALIGN_CENTER, color)
    sasl.gl.drawFrame(130,370,100,20,color)

    -- AVAIL ENG2
    text  = ENG.dyn[2].is_avail and "AVAIL" or "NOT AVAIL"
    color = ENG.dyn[2].is_avail and UI_GREEN or UI_LIGHT_RED
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+70, 375, text, 12, false, false, TEXT_ALIGN_CENTER, color)
    sasl.gl.drawFrame(size[1]/2+30,370,80,20,color)

    text  = get(xp_avail_2) == 1 and "XP AVAIL" or "XP NOT AVAIL"
    color = get(xp_avail_2) == 1 and UI_GREEN or UI_LIGHT_RED
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+180, 375, text, 12, false, false, TEXT_ALIGN_CENTER, color)
    sasl.gl.drawFrame(size[1]/2+130,370,100,20,color)

    
    -- FIREWALL Valves
    sasl.gl.drawText(Font_B612MONO_regular, 20, 350, "Firewall valve: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    text  = get(Eng_1_Firewall_valve) == 0 and "OPEN" or (get(Eng_1_Firewall_valve) == 1 and "CLOSE" or "TRANSIT")
    color = get(Eng_1_Firewall_valve) == 0 and UI_GREEN or (get(Eng_1_Firewall_valve) == 1 and UI_LIGHT_RED or UI_YELLOW)
    sasl.gl.drawText(Font_B612MONO_regular, 150, 350, text, 12, false, false, TEXT_ALIGN_LEFT, color)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20, 350, "Firewall valve: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    text  = get(Eng_2_Firewall_valve) == 0 and "OPEN" or (get(Eng_2_Firewall_valve) == 1 and "CLOSE" or "TRANSIT")
    color = get(Eng_2_Firewall_valve) == 0 and UI_GREEN or (get(Eng_2_Firewall_valve) == 1 and UI_LIGHT_RED or UI_YELLOW)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+150, 350, text, 12, false, false, TEXT_ALIGN_LEFT, color)

    -- Master Switches
    sasl.gl.drawText(Font_B612MONO_regular, 20, 330, "Master switch: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    text  = get(Engine_1_master_switch) == 1 and "ON" or "OFF"
    color = get(Engine_1_master_switch) == 1 and UI_GREEN or UI_LIGHT_RED
    sasl.gl.drawText(Font_B612MONO_regular, 150, 330, text, 12, false, false, TEXT_ALIGN_LEFT, color)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20, 330, "Master switch: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    text  = get(Engine_2_master_switch) == 1 and "ON" or "OFF"
    color = get(Engine_2_master_switch) == 1 and UI_GREEN or UI_LIGHT_RED
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+150, 330, text, 12, false, false, TEXT_ALIGN_LEFT, color)
    
    -- Mixture
    sasl.gl.drawText(Font_B612MONO_regular, 20, 310, "Mixture (XP): ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 170, 310, math.floor(get(eng_mixture,1)*100) .. "%", 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20, 310, "Mixture (XP): ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+170, 310, math.floor(get(eng_mixture,2)*100) .. "%", 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    -- Ignition key
    sasl.gl.drawText(Font_B612MONO_regular, 20, 290, "Ignition key (XP): ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 170, 290, get(eng_ignition_switch, 1) == 4 and "STARTING" or "-", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20, 290, "Ignition key (XP): ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+170, 290, get(eng_ignition_switch, 2) == 4 and "STARTING" or "-", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    -- Igniters
    sasl.gl.drawText(Font_B612MONO_regular, 20, 270, "Igniter: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    text  = get(eng_igniters, 1) == 1 and "ON" or "OFF"
    color = get(eng_igniters, 1) == 1 and UI_LIGHT_BLUE or UI_DARK_BLUE
    sasl.gl.drawText(Font_B612MONO_regular, 100, 270, text, 12, false, false, TEXT_ALIGN_LEFT, color)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20, 270, "Igniter: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    text  = get(eng_igniters, 2) == 1 and "ON" or "OFF"
    color = get(eng_igniters, 2) == 1 and UI_LIGHT_BLUE or UI_DARK_BLUE
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+100, 270, text, 12, false, false, TEXT_ALIGN_LEFT, color)

    -- Throttle valve
    sasl.gl.drawText(Font_B612MONO_regular, 20, 250, "Starter duration: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 220, 250, Round(get(starter_duration,1),2) , 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20, 250, "Starter duration: ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+220, 250, Round(get(starter_duration,2),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    -- Throttle valve
    sasl.gl.drawText(Font_B612MONO_regular, 20, 230, "Throttle (XP): ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 170, 230, math.floor(get(Override_eng_1_lever)*100) .. "%" , 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20, 230, "Throttle (XP): ", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+170, 230, math.floor(get(Override_eng_2_lever)*100) .. "%" , 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    
   
    
    -- Parameters
    param_y = 200
    sasl.gl.drawText(Font_B612MONO_regular, 20,  param_y, "Parameter", 12, true, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 130, param_y, "XP", 12, true, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 190, param_y, "Our", 12, true, false, TEXT_ALIGN_LEFT, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 30,  param_y-20, "N1", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 155, param_y-20, Round_fill(get(Eng_1_N1), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 210, param_y-20, "=", 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 30,  param_y-40, "N2", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 155, param_y-40, Round_fill(get(Eng_1_N2_XP), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 210, param_y-40, Round_fill(get(Eng_1_N2), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 30,  param_y-60, "EGT", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 155, param_y-60, Round_fill(get(Eng_1_EGT_XP), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 210, param_y-60, Round_fill(get(Eng_1_EGT_c), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 30,  param_y-80, "FF", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 155, param_y-80, Round_fill(get(eng_FF_kgs, 1), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 210, param_y-80, Round_fill(get(Eng_1_FF_kgs), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    
    
    -- Parameters
    param_y = 200
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+20,  param_y, "Parameter", 12, true, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+130, param_y, "XP", 12, true, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+190, param_y, "Our", 12, true, false, TEXT_ALIGN_LEFT, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+30,  param_y-20, "N1", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+155, param_y-20, Round_fill(get(Eng_2_N1), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+210, param_y-20, "=", 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+30,  param_y-40, "N2", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+155, param_y-40, Round_fill(get(Eng_2_N2_XP), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+210, param_y-40, Round_fill(get(Eng_2_N2), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+30,  param_y-60, "EGT", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+155, param_y-60, Round_fill(get(Eng_2_EGT_XP), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+210, param_y-60, Round_fill(get(Eng_2_EGT_c), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+30,  param_y-80, "FF", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+155, param_y-80, Round_fill(get(eng_FF_kgs, 2), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]/2+210, param_y-80, Round_fill(get(Eng_2_FF_kgs), 2), 12, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    
end
