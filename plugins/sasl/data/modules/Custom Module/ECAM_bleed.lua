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
-- File: ECAM_bleed.lua 
-- Short description: ECAM file for the BLEED page 
-------------------------------------------------------------------------------

include('constants.lua')

local ground_open_start = 0

local function draw_engines()

    -- Numbers
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-350, size[2]/2-200, "1", 50, false, false, 
                     TEXT_ALIGN_CENTER, get(Engine_1_avail) == 1 and ECAM_WHITE or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+350, size[2]/2-200, "2", 50, false, false,
                     TEXT_ALIGN_CENTER, get(Engine_2_avail) == 1 and ECAM_WHITE or ECAM_ORANGE)

    eng1_bleed_ok = get(L_Eng_LP_press) > 4
    eng2_bleed_ok = get(R_Eng_LP_press) > 4

    -- IP Lines
    sasl.gl.drawWideLine(size[1]/2-249, size[2]/2-222, size[1]/2-249, size[2]/2-282, 3, eng1_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawWideLine(size[1]/2+251, size[2]/2-222, size[1]/2+251, size[2]/2-282, 3, eng2_bleed_ok and ECAM_GREEN or ECAM_ORANGE)

    -- HP Lines
    sasl.gl.drawWideLine(size[1]/2-104, size[2]/2-255, size[1]/2-104, size[2]/2-282, 3, eng1_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawWideLine(size[1]/2-104, size[2]/2-255, size[1]/2-150, size[2]/2-255, 3, eng1_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawWideLine(size[1]/2+110, size[2]/2-255, size[1]/2+110, size[2]/2-282, 3, eng2_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawWideLine(size[1]/2+110, size[2]/2-255, size[1]/2+152, size[2]/2-255, 3, eng2_bleed_ok and ECAM_GREEN or ECAM_ORANGE)

    if get(Ecam_bleed_hp_valve_L) >= 2 then
        sasl.gl.drawWideLine(size[1]/2-204, size[2]/2-255, size[1]/2-248, size[2]/2-255, 3, eng1_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    end
    if get(Ecam_bleed_hp_valve_R) >= 2 then
        sasl.gl.drawWideLine(size[1]/2+206, size[2]/2-255, size[1]/2+248, size[2]/2-255, 3, eng2_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    end

    if get(Ecam_bleed_ip_valve_L) >= 2 then
        sasl.gl.drawWideLine(size[1]/2-249, size[2]/2-170, size[1]/2-249, size[2]/2-108, 3, ECAM_GREEN)
    end
    if get(Ecam_bleed_ip_valve_R) >= 2 then
        sasl.gl.drawWideLine(size[1]/2+251, size[2]/2-170, size[1]/2+251, size[2]/2-108, 3, ECAM_GREEN)
    end

end

local function draw_bleed_numbers()

    if get(FAILURE_BLEED_BMC_1) == 1 and get(FAILURE_BLEED_BMC_2) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-55, "XX", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-90, "XX", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-55, "XX", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-90, "XX", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        return 
    end

    bleed_1_press_col = (get(L_bleed_press) > 4 and get(L_bleed_press) < 57) and ECAM_GREEN or ECAM_ORANGE
    bleed_2_press_col = (get(R_bleed_press) > 4 and get(R_bleed_press) < 57) and ECAM_GREEN or ECAM_ORANGE

    bleed_1_temp = math.floor(get(L_bleed_temp)) - math.floor(get(L_bleed_temp))%5
    bleed_2_temp = math.floor(get(R_bleed_temp)) - math.floor(get(R_bleed_temp))%5

    bleed_1_temp_col = (bleed_1_temp >= 150 and bleed_1_temp < 270) and ECAM_GREEN or ECAM_ORANGE
    bleed_2_temp_col = (bleed_2_temp >= 150 and bleed_2_temp < 270) and ECAM_GREEN or ECAM_ORANGE

    --bleed temperature & pressure--
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-55, math.floor(get(L_bleed_press)), 32, false, false, TEXT_ALIGN_CENTER, bleed_1_press_col)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-90, bleed_1_temp, 32, false, false, TEXT_ALIGN_CENTER, bleed_1_temp_col)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-55, math.floor(get(R_bleed_press)), 32, false, false, TEXT_ALIGN_CENTER, bleed_2_press_col)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-90, bleed_2_temp, 32, false, false, TEXT_ALIGN_CENTER, bleed_2_temp_col)

end

local function draw_apu_and_gas()

    if get(All_on_ground) == 1 then
        sasl.gl.drawWideLine(size[1]/2-60, size[2]/2+40, size[1]/2-50, size[2]/2+15, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2+15, size[1]/2-50, size[2]/2+15, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2+15, size[1]/2-60, size[2]/2+40, 3, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-60, size[2]/2-15, "GND", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end

    if get(Apu_master_button_state) % 2 == 0 then
        return
    end

    if get(Apu_bleed_switch) == 1 then
        sasl.gl.drawWideLine(size[1]/2+3, size[2]/2-50, size[1]/2+3, size[2]/2+40, 3, ECAM_GREEN)
    end
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+3, size[2]/2-170, "APU", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(size[1]/2+3, size[2]/2-140, size[1]/2+3, size[2]/2-100, 3, ECAM_GREEN)
end

local function draw_x_bleed()

    if get(X_bleed_valve) == 1 or get(Apu_bleed_switch) == 1 or get(GAS_bleed_avail) == 1 then
        -- Line left displayed
        sasl.gl.drawWideLine(size[1]/2-248, size[2]/2+44, size[1]/2+55, size[2]/2+44, 3, ECAM_GREEN)
    end
   
    if get(X_bleed_valve) == 1 then
        -- Line right displayed
        sasl.gl.drawWideLine(size[1]/2+109, size[2]/2+44, size[1]/2+251, size[2]/2+44, 3, ECAM_GREEN)
    end


end

local function update_valves_dr()

    -- IP and HP
    set(Ecam_bleed_hp_valve_L, get(L_HP_valve) * 2 + get(FAILURE_BLEED_HP_1_VALVE_STUCK))
    set(Ecam_bleed_hp_valve_R, get(R_HP_valve) * 2 + get(FAILURE_BLEED_HP_2_VALVE_STUCK))
    set(Ecam_bleed_ip_valve_L, get(ENG_1_bleed_switch) * 2 + get(FAILURE_BLEED_IP_1_VALVE_STUCK))
    set(Ecam_bleed_ip_valve_R, get(ENG_2_bleed_switch) * 2 + get(FAILURE_BLEED_IP_2_VALVE_STUCK))
    
    -- X BLEED
    set(Ecam_bleed_xbleed_valve, get(X_bleed_valve) * 2 + get(FAILURE_BLEED_XBLEED_VALVE_STUCK))
    
    -- Packs
    set(Ecam_bleed_pack_valve_L, get(Pack_L) * 2 + get(FAILURE_BLEED_PACK_1_VALVE_STUCK))
    set(Ecam_bleed_pack_valve_R, get(Pack_R) * 2 + get(FAILURE_BLEED_PACK_2_VALVE_STUCK))

    -- RAM AIR
    if get(FAILURE_BLEED_RAM_AIR_STUCK) == 0 then
        if get(Emer_ram_air) == 0 then
            set(Ecam_bleed_ram_air, 0)
        elseif get(All_on_ground) == 1 then
            set(Ecam_bleed_ram_air, 3)
        else
            set(Ecam_bleed_ram_air, 2)    
        end
    else
        set(Ecam_bleed_ram_air, 1 + 2*get(Emer_ram_air))
    end
    -- TOP Line
    set(Ecam_bleed_top_mix_line, (get(Emer_ram_air) == 0 and get(Pack_L) == 0 and get(Pack_R) == 0) and 0 or 1)
    
end

local function draw_packs()
    --compressor temperature--
    comp_1_temp = math.floor(get(L_compressor_temp)) - math.floor(get(L_compressor_temp))%5
    comp_2_temp = math.floor(get(R_compressor_temp)) - math.floor(get(R_compressor_temp))%5
    comp1_color = comp_1_temp > 230 and ECAM_GREEN or ECAM_ORANGE
    comp2_color = comp_2_temp > 230 and ECAM_GREEN or ECAM_ORANGE
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2+193, comp_1_temp, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2+193, comp_2_temp, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    --pre-cooler temperature--
    pack1_color = get(L_pack_temp) < 90 and ECAM_GREEN or ECAM_ORANGE
    pack2_color = get(R_pack_temp) < 90 and ECAM_GREEN or ECAM_ORANGE
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2+300, math.floor(get(L_pack_temp)), 36, false, false, TEXT_ALIGN_CENTER, pack1_color)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2+300, math.floor(get(R_pack_temp)), 36, false, false, TEXT_ALIGN_CENTER, pack2_color)
end

local function draw_ram_air()
    if get(Emer_ram_air) == 1 then
        sasl.gl.drawWideLine(size[1]/2, size[2]/2+343, size[1]/2, size[2]/2+375, 3, ECAM_GREEN)
    end
    sasl.gl.drawWideLine(size[1]/2, size[2]/2+290, size[1]/2, size[2]/2+250, 3, ECAM_GREEN)
end 

local function draw_triangle_left(x,y,color)
    sasl.gl.drawWidePolyLine( {x, y, x+25, y+15, x+25, y-15, x, y }, 3, color)
end

local function draw_triangle_right(x,y,color)
    sasl.gl.drawWidePolyLine( {x, y, x-25, y+15, x-25, y-15, x, y }, 3, color)
end


local function draw_ai()

    if PB.ovhd.antiice_wings.status_bottom then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-340, size[2]/2+50, "ANTI\nICE", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+345, size[2]/2+50, "ANTI\n ICE", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)   -- The extra space on the second line is correct!
    end

    if PB.ovhd.antiice_wings.status_bottom and get(Any_wheel_on_ground) == 1 then
        if ground_open_start == 0 then
            ground_open_start = get(TIME)
        end
    else
        ground_open_start = 0
    end
    
    if AI_sys.comp[ANTIICE_WING_L].valve_status then
        if get(AI_wing_L_operating) == 1 and (get(Any_wheel_on_ground) == 0 or (get(TIME) - ground_open_start < 10)) then
            draw_triangle_left(size[1]/2-285, size[2]/2+40, ECAM_GREEN)
        else
            draw_triangle_left(size[1]/2-285, size[2]/2+40, ECAM_ORANGE)
        end
    end

    if AI_sys.comp[ANTIICE_WING_R].valve_status then
        if get(AI_wing_R_operating) == 1 and (get(Any_wheel_on_ground) == 0 or (get(TIME) - ground_open_start < 10)) then
            draw_triangle_right(size[1]/2+290, size[2]/2+40, ECAM_GREEN)
        else
            draw_triangle_right(size[1]/2+290, size[2]/2+40, ECAM_ORANGE)
        end
    end
    
end

function draw_bleed_page()

    draw_apu_and_gas()
    draw_engines()    
    draw_bleed_numbers()
    draw_x_bleed()
    draw_ai()
    draw_packs()
    draw_ram_air()

end


function ecam_update_bleed_page()
    update_valves_dr()
end
