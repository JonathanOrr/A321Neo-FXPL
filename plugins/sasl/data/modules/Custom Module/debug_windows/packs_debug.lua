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
-- File: packs_debug.lua 
-- Short description: BLEED & PACKS system debug window
-------------------------------------------------------------------------------

include('constants.lua')

--sim datarefs

--a32nx datarefs

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local BLACK = {0.0, 0.0, 0.0}
local eng_1_bleed_cl = ECAM_ORANGE
local apugpu_bleed_cl = ECAM_ORANGE
local eng_2_bleed_cl = ECAM_ORANGE
local left_bleed_cl = ECAM_ORANGE
local mid_bleed_cl = ECAM_ORANGE
local right_bleed_cl = ECAM_ORANGE
local left_pack_cl = ECAM_ORANGE
local mid_pack_cl = ECAM_ORANGE
local right_pack_cl = ECAM_ORANGE
local sim_left_iso_cl = ECAM_GREEN
local sim_right_iso_cl = ECAM_GREEN

--valve positions
local sim_l_iso_line_xy = {size[1]/2 - size[1]/4 - 65, size[2]/2+110, size[1]/2 - size[1]/4 - 35, size[2]/2+110}
local sim_r_iso_line_xy = {size[1]/2 - size[1]/4 + 35, size[2]/2+110, size[1]/2 - size[1]/4 + 65, size[2]/2+110}


function update()
    --change menu item state
    if Packs_debug_window:isVisible() == true then
        sasl.setMenuItemState(Menu_debug, ShowHidePacksDebug, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_debug, ShowHidePacksDebug, MENU_UNCHECKED)
    end

    if get(ENG_1_bleed_switch) == 1 then
        eng_1_bleed_cl = ECAM_GREEN
    else
        eng_1_bleed_cl = ECAM_ORANGE
    end

    if get(Apu_bleed_switch) == 1 then
        apugpu_bleed_cl = ECAM_GREEN
    else
        apugpu_bleed_cl = ECAM_ORANGE
    end

    if get(ENG_2_bleed_switch) == 1 then
        eng_2_bleed_cl = ECAM_GREEN
    else
        eng_2_bleed_cl = ECAM_ORANGE
    end

    if get(Left_bleed_avil) > 0.1 then
        left_bleed_cl = ECAM_GREEN
    else
        left_bleed_cl = ECAM_ORANGE
    end

    if get(Mid_bleed_avil) > 0.1 then
        mid_bleed_cl = ECAM_GREEN
    else
        mid_bleed_cl = ECAM_ORANGE
    end

    if get(Right_bleed_avil) > 0.1 then
        right_bleed_cl = ECAM_GREEN
    else
        right_bleed_cl = ECAM_ORANGE
    end

    if get(Pack_L) == 1 and get(Left_bleed_avil) > 0.1 then
        left_pack_cl = ECAM_GREEN
    else
        left_pack_cl = ECAM_ORANGE
    end

    if get(Pack_M) == 1 and get(Mid_bleed_avil) > 0.1 then
        mid_pack_cl = ECAM_GREEN
    else
        mid_pack_cl = ECAM_ORANGE
    end

    if get(Pack_R) == 1 and get(Right_bleed_avil) > 0.1  then
        right_pack_cl = ECAM_GREEN
    else
        right_pack_cl = ECAM_ORANGE
    end

    if get(Left_pack_iso_valve) == 1 then
        if get(Left_bleed_avil) > 0.1 and get(Mid_bleed_avil) > 0.1 then
            sim_left_iso_cl = ECAM_GREEN
        else
            sim_left_iso_cl = ECAM_ORANGE
        end
        sim_l_iso_line_xy = {size[1]/2 - size[1]/4 - 65, size[2]/2+80, size[1]/2 - size[1]/4 - 35, size[2]/2+80}
    else
        sim_left_iso_cl = ECAM_ORANGE
        sim_l_iso_line_xy = {size[1]/2 - size[1]/4 - 50, size[2]/2+95, size[1]/2 - size[1]/4 - 50, size[2]/2+65}
    end

    if get(Right_pack_iso_valve) == 1 then
        if get(Mid_bleed_avil) > 0.1 and get(Right_bleed_avil) > 0.1 then
            sim_right_iso_cl = ECAM_GREEN
        else
            sim_left_iso_cl = ECAM_ORANGE
        end
        sim_r_iso_line_xy = {size[1]/2 - size[1]/4 + 35, size[2]/2+80, size[1]/2 - size[1]/4 + 65, size[2]/2+80}
    else
        sim_right_iso_cl = ECAM_ORANGE
        sim_r_iso_line_xy = {size[1]/2 - size[1]/4 + 50, size[2]/2+95, size[1]/2 - size[1]/4 + 50, size[2]/2+65}
    end
end

local function draw_xplane_part()

    --x plane pack system diagram--
    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4, 520, "X-PLANE PACKS", 15,false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    --direct bleed feeds--


    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4 - 100, size[2]/2-150, "ENG 1 BLEED", 10,false, false, TEXT_ALIGN_CENTER, eng_1_bleed_cl)
    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4      , size[2]/2-150, "APU BLEED", 10,false, false, TEXT_ALIGN_CENTER, apugpu_bleed_cl)
    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4      , size[2]/2-170, "GPU BLEED", 10,false, false, TEXT_ALIGN_CENTER, get(Gpu_bleed_switch) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4 + 100, size[2]/2-150, "ENG 2 BLEED", 10,false, false, TEXT_ALIGN_CENTER, eng_2_bleed_cl)
    sasl.gl.drawWideLine(size[1]/2 - size[1]/4 - 100, size[2]/2-140, size[1]/2 - size[1]/4 - 100, size[2]/2+80, 2, left_bleed_cl)
    sasl.gl.drawWideLine(size[1]/2 - size[1]/4      , size[2]/2-140, size[1]/2 - size[1]/4      , size[2]/2+80, 2, mid_bleed_cl)
    sasl.gl.drawWideLine(size[1]/2 - size[1]/4 + 100, size[2]/2-140, size[1]/2 - size[1]/4 + 100, size[2]/2+80, 2, right_bleed_cl)
    --briding and x bleeds--
    sasl.gl.drawWideLine(size[1]/2 - size[1]/4 - 100, size[2]/2+80, size[1]/2 - size[1]/4 - 65,  size[2]/2+80, 2, left_bleed_cl)
    sasl.gl.drawWideLine(size[1]/2 - size[1]/4 - 35 , size[2]/2+80, size[1]/2 - size[1]/4     ,  size[2]/2+80, 2, mid_bleed_cl)
    sasl.gl.drawWideLine(size[1]/2 - size[1]/4      , size[2]/2+80, size[1]/2 - size[1]/4 + 35,  size[2]/2+80, 2, mid_bleed_cl)
    sasl.gl.drawWideLine(size[1]/2 - size[1]/4 + 65 , size[2]/2+80, size[1]/2 - size[1]/4 + 100, size[2]/2+80, 2, right_bleed_cl)
    --ISO valves--
    sasl.gl.drawArc(size[1]/2 - size[1]/4 - 50,  size[2]/2+80, 13, 15, 0, 360, sim_left_iso_cl)
    sasl.gl.drawArc(size[1]/2 - size[1]/4 + 50,  size[2]/2+80, 13, 15, 0, 360, sim_right_iso_cl)
    --ISO valve lines--
    sasl.gl.drawWideLine(sim_l_iso_line_xy[1], sim_l_iso_line_xy[2], sim_l_iso_line_xy[3], sim_l_iso_line_xy[4], 2, sim_left_iso_cl)
    sasl.gl.drawWideLine(sim_r_iso_line_xy[1], sim_r_iso_line_xy[2], sim_r_iso_line_xy[3], sim_r_iso_line_xy[4], 2, sim_right_iso_cl)
    --packs--
    sasl.gl.drawRectangle(size[1]/2 - size[1]/4 - 110, size[2]/2 + 100, 20, 15, left_pack_cl)
    sasl.gl.drawRectangle(size[1]/2 - size[1]/4 - 10 , size[2]/2 + 100, 20, 15, mid_pack_cl)
    sasl.gl.drawRectangle(size[1]/2 - size[1]/4 + 90 , size[2]/2 + 100, 20, 15, right_pack_cl)
    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4 - 100, size[2]/2+120, "L PACK", 10,false, false, TEXT_ALIGN_CENTER, left_pack_cl)
    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4      , size[2]/2+120, "M PACK", 10,false, false, TEXT_ALIGN_CENTER, mid_pack_cl)
    sasl.gl.drawText(B612MONO_regular, size[1]/2 - size[1]/4 + 100, size[2]/2+120, "R PACK", 10,false, false, TEXT_ALIGN_CENTER, right_pack_cl)
end

local function draw_valve_v(x,y,status)
    sasl.gl.drawArc(x, y, 9, 10, 0, 360, status and ECAM_GREEN or ECAM_ORANGE)
    if status then
        sasl.gl.drawLine(x, y-10, x, y+10, ECAM_GREEN)
    else
        sasl.gl.drawLine(x-10, y, x+10, y, ECAM_ORANGE)    
    end
end

local function draw_valve_h(x,y,status)
    sasl.gl.drawArc(x, y, 9, 10, 0, 360, status and ECAM_GREEN or ECAM_ORANGE)
    if status then
        sasl.gl.drawLine(x-10, y, x+10, y, ECAM_GREEN)    
    else
        sasl.gl.drawLine(x, y-10, x, y+10, ECAM_ORANGE)
    end
end

local function flow_to_text(dr) 
    if get(dr) == 0 then return "OFF" end
    if get(dr) == 1 then return "LOW" end
    if get(dr) == 2 then return "NORM" end
    if get(dr) == 3 then return "HIGH" end
end

local function draw_a32nx_part()
    width_start = size[1]/2
    width_end   = size[1]
    --a320 pack system diagram--
    sasl.gl.drawText(B612MONO_regular, size[1]/2 + size[1]/4, 520, "A32NX PACKS", 15,false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    
    -- Lower part - engines bleed
    
    sasl.gl.drawFrame(width_start+25 , 10, 50, 30, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+50 , 20, "ENG 1", 10,false, false, TEXT_ALIGN_CENTER, get(Engine_1_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(B612MONO_regular, width_start+60 , 45, "IP", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawLine(width_start+50, 40, width_start+50, 100, ECAM_WHITE)
    sasl.gl.drawLine(width_start+75, 25, width_start+100, 25, ECAM_WHITE)
    sasl.gl.drawLine(width_start+100, 25, width_start+100, 55, ECAM_WHITE)
    sasl.gl.drawLine(width_start+100, 75, width_start+100, 90, ECAM_WHITE)
    sasl.gl.drawLine(width_start+100, 90, width_start+50, 90, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+90 , 30, "HP", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawLine(width_start+100, 40, width_start+130, 40, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+135, 40, "HYD\nRSVR", 8, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    draw_valve_v(width_start+50, 110, get(ENG_1_bleed_switch) == 1)
    draw_valve_v(width_start+100, 65, get(L_HP_valve) == 1)
        
    sasl.gl.drawFrame(width_end-75 , 10, 50, 30, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-50 , 20, "ENG 2", 10,false, false, TEXT_ALIGN_CENTER, get(Engine_2_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(B612MONO_regular, width_end-60 , 45, "IP", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawLine(width_end-50, 40, width_end-50, 100, ECAM_WHITE)
    sasl.gl.drawLine(width_end-75, 25, width_end-100, 25, ECAM_WHITE)
    sasl.gl.drawLine(width_end-100, 25, width_end-100, 55, ECAM_WHITE)
    sasl.gl.drawLine(width_end-100, 75, width_end-100, 90, ECAM_WHITE)
    sasl.gl.drawLine(width_end-100, 90, width_end-50, 90, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-90 , 30, "HP", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
    draw_valve_v(width_end-50, 110, get(ENG_2_bleed_switch) == 1)
    draw_valve_v(width_end-100, 65, get(R_HP_valve) == 1)

    sasl.gl.drawLine(width_start+50, 120, width_start+50, 200, ECAM_WHITE)    
    sasl.gl.drawLine(width_end-50, 120, width_end-50, 200, ECAM_WHITE)
    sasl.gl.drawLine(width_start+50, 130, width_start+40, 130, ECAM_WHITE)    
    sasl.gl.drawLine(width_end-50, 130, width_end-40, 130, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-40, 130, "ENG2\nSTARTER", 8, false, false, TEXT_ALIGN_LEFT, get(Eng_is_spooling_up, 2) == 1 and ECAM_GREEN or ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+40, 130, "ENG1\nSTARTER", 8, false, false, TEXT_ALIGN_RIGHT, get(Eng_is_spooling_up, 1) == 1 and ECAM_GREEN or ECAM_WHITE)

    -- BLEED L/R status
    sasl.gl.drawText(B612MONO_regular, width_start+10, 290, "BLEED L", 10, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawFrame(width_start+10, 235, 50, 50, UI_DARK_BLUE)
    sasl.gl.drawLine(width_start+50, 200, width_start+50, 235, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 275, "TEMP", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 265, math.ceil(get(L_bleed_temp)) .. " C", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 250, "PRESS", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 240, math.ceil(get(L_bleed_press)) .. " PSI", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(B612MONO_regular, width_end-60, 290, "BLEED R", 10, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawFrame(width_end-60, 235, 50, 50, UI_DARK_BLUE)
    sasl.gl.drawLine(width_end-50, 200, width_end-50, 235, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 275, "TEMP", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 265, math.ceil(get(R_bleed_temp)) .. " C", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 250, "PRESS", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 240, math.ceil(get(R_bleed_press)) .. " PSI", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    -- main bleed lined
    sasl.gl.drawText(B612MONO_regular, (width_end+width_start)/2, 180, "X BLEED", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    draw_valve_h((width_end+width_start)/2, 200, get(X_bleed_valve) == 1)
    sasl.gl.drawLine((width_end+width_start)/2+10, 200, width_end-50, 200, ECAM_WHITE)
    sasl.gl.drawLine((width_end+width_start)/2-10, 200, width_start+50, 200, ECAM_WHITE)
    
    -- APU
    sasl.gl.drawLine(width_start+150, 200, width_start+150, 150, ECAM_WHITE)
    draw_valve_v(width_start+150, 140, get(Apu_bleed_switch) == 1)
    sasl.gl.drawLine(width_start+150, 130, width_start+150, 90, ECAM_WHITE)
    sasl.gl.drawLine(width_start+150, 90, width_start+145, 85, ECAM_WHITE)
    sasl.gl.drawLine(width_start+150, 90, width_start+155, 85, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+150, 75, "APU", 10, false, false, TEXT_ALIGN_CENTER, get(Apu_avail) == 0 and ECAM_ORANGE or ECAM_GREEN)
    
    -- GAS
    sasl.gl.drawLine(width_start+100, 200, width_start+100, 150, ECAM_WHITE)
    sasl.gl.drawLine(width_start+100, 150, width_start+105, 145, ECAM_WHITE)
    sasl.gl.drawLine(width_start+100, 150, width_start+95, 145, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+100, 135, "GND\nAIR", 10, false, false, TEXT_ALIGN_CENTER, get(GAS_bleed_avail) == 0 and ECAM_ORANGE or ECAM_GREEN)

    -- APU BLEED
    sasl.gl.drawText(B612MONO_regular, width_start+175, 135, "APU BLEED", 10, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawFrame(width_start+180, 105, 50, 25, UI_DARK_BLUE)
    sasl.gl.drawLine(width_start+150, 110, width_start+180, 110, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+185, 120, "PRESS", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+185, 110, math.ceil(get(Apu_bleed_psi)) .. " PSI", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)    

    -- top lines
    sasl.gl.drawLine(width_start+80, 200, width_start+80, 220,ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+80, 235, " WING\nA. ICE", 8, false, false, TEXT_ALIGN_CENTER, get(AI_wing_L_operating) == 1 and ECAM_GREEN or ECAM_WHITE)
    sasl.gl.drawLine(width_start+140, 200, width_start+140, 220, ECAM_WHITE)
    sasl.gl.drawFrame(width_start+126, 221, 30, 18, ECAM_MAGENTA)
    sasl.gl.drawText(B612MONO_regular, width_start+140, 227, "CARGO", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawLine(width_end-80, 200, width_end-80, 220,ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-80, 235, " WING\nA. ICE", 8, false, false, TEXT_ALIGN_CENTER, get(AI_wing_R_operating) == 1 and ECAM_GREEN or ECAM_WHITE)

    -- bridge xbleed
    sasl.gl.drawLine(width_start+165, 200, width_start+165, 230, ECAM_WHITE)
    sasl.gl.drawLine(width_end-165, 200, width_end-165, 230, ECAM_WHITE)
    sasl.gl.drawLine(width_start+165, 230, width_end-165, 230, ECAM_WHITE)
    sasl.gl.drawLine(width_start+175, 230, width_start+175, 240, ECAM_WHITE)
    sasl.gl.drawLine(width_end-175, 230, width_end-175, 240, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+170, 255, "HYD\nRSVR", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-170, 255, "WATER\nTANKS", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
    -- PACKS
    draw_valve_v(width_start+120, 260, get(Pack_L) == 1)
    sasl.gl.drawText(B612MONO_regular, width_start+95, 270, "PACK 1", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawLine(width_start+120, 200, width_start+120, 250, ECAM_WHITE)
    draw_valve_v(width_end-120, 260, get(Pack_R) == 1)
    sasl.gl.drawText(B612MONO_regular, width_end-95, 270, "PACK 2", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawLine(width_end-120, 200, width_end-120, 250, ECAM_WHITE)
 
    -- Mixer
    sasl.gl.drawFrame((width_end+width_start)/2-100, 350, 200, 20, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, (width_end+width_start)/2, 355, "MIXER", 12, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, (width_end+width_start)/2+75, 357, math.floor(get(Aircond_mixer_temp)) .. " C", 8, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    
    
    
    sasl.gl.drawLine(width_end-120, 270, width_end-120, 350, ECAM_WHITE)
    sasl.gl.drawLine(width_start+120, 270, width_start+120, 350, ECAM_WHITE)
    sasl.gl.drawLine(width_end-130, 370, width_end-130, 400, ECAM_WHITE)
    sasl.gl.drawLine(width_start+150, 335, width_start+150, 350, ECAM_WHITE)
    draw_valve_v(width_start+150, 325, get(Emer_ram_air) == 1)
    sasl.gl.drawLine(width_start+150, 315, width_start+150, 305, ECAM_WHITE)
    sasl.gl.drawLine(width_start+150, 305, width_start+145, 300, ECAM_WHITE)
    sasl.gl.drawLine(width_start+150, 305, width_start+155, 300, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular,width_start+170, 325, "RAM\nAIR", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
    sasl.gl.drawLine((width_end+width_start)/2, 370, (width_end+width_start)/2, 400, ECAM_WHITE)
    sasl.gl.drawLine(width_start+130, 370, width_start+130, 400, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+130, 405, "CKPT", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, (width_end+width_start)/2, 405, "FWD", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-130, 405, "AFT", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
    -- Hot air
    draw_valve_v(width_end-160, 315, get(Hot_air_valve_pos) == 1)
    sasl.gl.drawLine(width_end-120, 290, width_end-160, 290, ECAM_WHITE)
    sasl.gl.drawLine(width_end-160, 305, width_end-160, 290, ECAM_WHITE)
    sasl.gl.drawLine(width_start+120, 290, width_end-160, 290, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-138, 315, "HOT\nAIR", 8, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-130, 330, math.floor(get(Hot_air_temp)).. " C", 8, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_RED)
    sasl.gl.drawLine(width_end-160, 325,width_end-160, 340, UI_LIGHT_RED)
    sasl.gl.drawLine(width_end-160, 340, width_end-80, 340, UI_LIGHT_RED)
    sasl.gl.drawLine(width_end-80, 340, width_end-80, 395, UI_LIGHT_RED)
    sasl.gl.drawLine(width_end-130, 395, width_end-80, 395, UI_LIGHT_RED)
    sasl.gl.drawLine((width_end+width_start)/2, 387, width_end-80, 387, UI_LIGHT_RED)
    sasl.gl.drawLine(width_start+130, 379, width_end-80, 379, UI_LIGHT_RED)
    
    -- Pack temp & airflow
    sasl.gl.drawText(B612MONO_regular, width_start+10, 400, "PACK 1", 10, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawFrame(width_start+10, 320, 55, 75, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 385, "OUT TEMP", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 375, math.ceil(get(L_pack_temp)) .. " C", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 360, "FLOW", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 350, flow_to_text(L_pack_Flow), 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 335, "CMP TEMP", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 325, math.ceil(get(L_compressor_temp)) .. " C", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawLine(width_start+65, 330, width_start+120, 330, UI_DARK_BLUE)
    
    -- Pack temp & airflow
    sasl.gl.drawText(B612MONO_regular, width_end-60, 400, "PACK 2", 10, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawFrame(width_end-60, 320, 55, 75, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 385, "OUT TEMP", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 375, math.ceil(get(R_pack_temp)) .. " C", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 360, "FLOW", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 350, flow_to_text(R_pack_Flow), 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 335, "CMP TEMP", 9, false, false, TEXT_ALIGN_LEFT, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, width_end-55, 325, math.ceil(get(R_compressor_temp)) .. " C", 9, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawLine(width_end-60, 330, width_end-120, 330, UI_DARK_BLUE)
    
    -- Cargo
    sasl.gl.drawFrame(width_start+30, 440, 100, 60, ECAM_MAGENTA)
    sasl.gl.drawText(B612MONO_regular, width_start+100, 505, "CARGO", 12, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawLine(width_start+75, 445, width_start+75, 430, ECAM_WHITE)
    draw_valve_v(width_start+75, 455, get(Hot_air_valve_pos_cargo) == 1)
    sasl.gl.drawLine(width_start+75, 465, width_start+75, 475, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+105, 455, "C.HOT\nAIR", 9, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+70, 465, math.floor(get(Hot_air_temp_cargo)).. " C", 8, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_RED)
    draw_valve_h(width_start+45, 485, get(Cargo_isol_in_valve) == 1)
    draw_valve_h(width_start+115, 485, get(Cargo_isol_out_valve) == 1)
    sasl.gl.drawLine(width_start+20, 485, width_start+35, 485, ECAM_WHITE)
    sasl.gl.drawLine(width_start+15, 490, width_start+20, 485, ECAM_WHITE)
    sasl.gl.drawLine(width_start+15, 480, width_start+20, 485, ECAM_WHITE)
    sasl.gl.drawLine(width_start+125, 485, width_start+140, 485, ECAM_WHITE)
    sasl.gl.drawLine(width_start+135, 490, width_start+140, 485, ECAM_WHITE)
    sasl.gl.drawLine(width_start+135, 480, width_start+140, 485, ECAM_WHITE)
    sasl.gl.drawFrame(width_start+68, 475, 25, 18, ECAM_WHITE)
    sasl.gl.drawLine(width_start+55, 485, width_start+68, 485, ECAM_WHITE)
    sasl.gl.drawLine(width_start+92, 485, width_start+105, 485, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+80, 480, "MIX", 9, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+15, 495, "INLET", 9, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_start+150, 495, "OUTLET", 9, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    -- Temperature table
    sasl.gl.drawText(B612MONO_regular, width_end-165, 485, "CKPT", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-165, 470, "FWD", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-165, 455, "AFT", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-165, 430, "CARGO", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-120, 500, "SP", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-75, 500, "ACTUAL", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, width_end-30, 500, "INFLOW", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    
    sasl.gl.drawText(B612MONO_regular, width_end-120, 485, math.floor(get(Cockpit_temp_req)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-75, 485, math.floor(get(Cockpit_temp)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-30, 485, math.floor(get(Aircond_injected_flow_temp,1)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, {1,1,0})
    
    sasl.gl.drawText(B612MONO_regular, width_end-120, 470, math.floor(get(Front_cab_temp_req)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-75, 470, math.floor(get(Front_cab_temp)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-30, 470, math.floor(get(Aircond_injected_flow_temp,2)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, {1,1,0})
    
    sasl.gl.drawText(B612MONO_regular, width_end-120, 455, math.floor(get(Aft_cab_temp_req)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-75, 455, math.floor(get(Aft_cab_temp)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-30, 455, math.floor(get(Aircond_injected_flow_temp,3)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, {1,1,0})
    
    sasl.gl.drawText(B612MONO_regular, width_end-120, 430, math.floor(get(Aft_cargo_temp_req)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-75, 430, math.floor(get(Aft_cargo_temp)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, width_end-30, 430, math.floor(get(Aircond_injected_flow_temp,4)) .. " C", 9, false, false, TEXT_ALIGN_RIGHT, {1,1,0})

end


function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], BLACK)
    sasl.gl.drawLine(size[1]/2-5, 0, size[1]/2-5, size[2], ECAM_BLUE)
    sasl.gl.drawLine(size[1]/2+20, 420, size[1]-20, 420, UI_LIGHT_GREY)
    sasl.gl.drawLine(size[1]/2+175, 430, size[1]/2+175, 510, UI_LIGHT_GREY)
    
    draw_xplane_part()
    draw_a32nx_part()
end
