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

    if get(L_HP_valve) == 1 then
        sasl.gl.drawWideLine(size[1]/2-204, size[2]/2-255, size[1]/2-248, size[2]/2-255, 3, eng1_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    end
    if get(R_HP_valve) == 1 then
        sasl.gl.drawWideLine(size[1]/2+206, size[2]/2-255, size[1]/2+248, size[2]/2-255, 3, eng2_bleed_ok and ECAM_GREEN or ECAM_ORANGE)
    end

    if get(L_IP_valve) == 1 then
        sasl.gl.drawWideLine(size[1]/2-249, size[2]/2-170, size[1]/2-249, size[2]/2-108, 3, ECAM_GREEN)
    end
    if get(R_IP_valve) == 1 then
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

    local bleed_1_press = math.floor(get(L_bleed_press)) - math.floor(get(L_bleed_press))%2
    local bleed_2_press = math.floor(get(R_bleed_press)) - math.floor(get(R_bleed_press))%2
    local bleed_1_press_col = (bleed_1_press > 4 and bleed_1_press < 57) and ECAM_GREEN or ECAM_ORANGE
    local bleed_2_press_col = (bleed_2_press > 4 and bleed_2_press < 57) and ECAM_GREEN or ECAM_ORANGE

    local bleed_1_temp = math.floor(get(L_bleed_temp)) - math.floor(get(L_bleed_temp))%5
    local bleed_2_temp = math.floor(get(R_bleed_temp)) - math.floor(get(R_bleed_temp))%5

    local bleed_1_temp_col = (bleed_1_temp >= 150 and bleed_1_temp < 270) and ECAM_GREEN or ECAM_ORANGE
    local bleed_2_temp_col = (bleed_2_temp >= 150 and bleed_2_temp < 270) and ECAM_GREEN or ECAM_ORANGE

    --bleed temperature & pressure--
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-55, bleed_1_press, 32, false, false, TEXT_ALIGN_CENTER, bleed_1_press_col)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-90, bleed_1_temp, 32, false, false, TEXT_ALIGN_CENTER, bleed_1_temp_col)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-55, bleed_2_press, 32, false, false, TEXT_ALIGN_CENTER, bleed_2_press_col)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-90, bleed_2_temp, 32, false, false, TEXT_ALIGN_CENTER, bleed_2_temp_col)

end

local function draw_apu_and_gas()

    if get(All_on_ground) == 1 then
        sasl.gl.drawWideLine(size[1]/2-60, size[2]/2+40, size[1]/2-50, size[2]/2+15, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2+15, size[1]/2-50, size[2]/2+15, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2+15, size[1]/2-60, size[2]/2+40, 3, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-60, size[2]/2-15, "GND", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end

    if get(Apu_master_button_state) == 0 then
        return
    end

    if get(Apu_bleed_xplane) == 1 then
        sasl.gl.drawWideLine(size[1]/2, size[2]/2-50, size[1]/2, size[2]/2+42, 3, ECAM_GREEN)
    end

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-170, "APU", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(size[1]/2, size[2]/2-140, size[1]/2, size[2]/2-100, 3, ECAM_GREEN)
end

local function draw_x_bleed()

    if get(X_bleed_valve_disp) <= 2 or get(Apu_bleed_xplane) == 1 or get(GAS_bleed_avail) == 1 then
        -- Line left displayed
        sasl.gl.drawWideLine(size[1]/2-248, size[2]/2+44, size[1]/2+55, size[2]/2+44, 3, ECAM_GREEN)
    end

    if get(X_bleed_valve_disp) <= 2 then
        -- Line right displayed
        sasl.gl.drawWideLine(size[1]/2+109, size[2]/2+44, size[1]/2+251, size[2]/2+44, 3, ECAM_GREEN)
    end


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

local function draw_needles_valves_and_mixer()
    --pre cooler needle
    SASL_draw_needle(size[1]/2-250, size[2]/2+226, 67, Math_rescale(0, 150, 1, 30, get(L_pack_byp_valve)), 3.8, ECAM_GREEN)
    SASL_draw_needle(size[1]/2+251, size[2]/2+226, 67, Math_rescale(0, 150, 1, 30, get(R_pack_byp_valve)), 3.8, ECAM_GREEN)

    --pack flow needle (displays discrete values)
    local l_pack_flow = (math.floor(get(L_pack_Flow_value)*10) - math.floor(get(L_pack_Flow_value)*10)%1) / 10
    local r_pack_flow = (math.floor(get(R_pack_Flow_value)*10) - math.floor(get(R_pack_Flow_value)*10)%1) / 10
    SASL_draw_needle_adv(size[1]/2-250, size[2]/2+118, 26, 67, Math_rescale(0, 148, 1.2, 32, l_pack_flow), 2.8, (get(L_pack_Flow_value) <= 0.01 and get(Pack_L) == 1 or get(Pack_L) == 0) and ECAM_ORANGE or ECAM_GREEN)
    SASL_draw_needle_adv(size[1]/2+252, size[2]/2+118, 26, 67, Math_rescale(0, 148, 1.2, 32, r_pack_flow), 2.8, (get(R_pack_Flow_value) <= 0.01 and get(Pack_R) == 1 or get(Pack_R) == 0) and ECAM_ORANGE or ECAM_GREEN)

    --mixer line
    SASL_draw_img_xcenter_aligned(ECAM_BLEED_mixer_img, size[1]/2+4, size[2]/2+352, 518, 62, (get(Emer_ram_air) == 0 and get(Pack_L) == 0 and get(Pack_R) == 0) and ECAM_ORANGE or ECAM_GREEN)

    --ram air
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2+0, size[2]/2+287, 180, 58, 3, get(Emer_ram_air) == 0 and 1 or 3, (get(FAILURE_BLEED_RAM_AIR_STUCK) == 1 or (get(All_on_ground) == 1 and get(Emer_ram_air) == 1)) and ECAM_ORANGE or ECAM_GREEN)

    --PACK valves
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2-249, size[2]/2+88, 180, 58, 3, get(Pack_L) == 0 and 1 or 3, get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2+253, size[2]/2+88, 180, 58, 3, get(Pack_R) == 0 and 1 or 3, get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)

    --X bleed valve
    local xbleed_valve_pos = get(X_bleed_valve_disp)
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2+82, size[2]/2+14, 180, 58, 3, xbleed_valve_pos, get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 0 and xbleed_valve_pos ~= 2  and ECAM_GREEN or ECAM_ORANGE)

    --IP valves
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2-249, size[2]/2-223, 180, 58, 3, (get(ENG_1_bleed_switch) == 0 or get(L_IP_valve) == 0) and 1 or 3, get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2+252, size[2]/2-223, 180, 58, 3, (get(ENG_2_bleed_switch) == 0 or get(R_IP_valve) == 0) and 1 or 3, get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)

    --HP valves
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2-177, size[2]/2-283, 180, 58, 3, get(L_HP_valve) == 0 and 3 or 1, get(FAILURE_BLEED_HP_1_VALVE_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2+180, size[2]/2-283, 180, 58, 3, get(R_HP_valve) == 0 and 3 or 1, get(FAILURE_BLEED_HP_2_VALVE_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)

    --APU valves
    if not (get(Apu_master_button_state) == 0 and get(FAILURE_BLEED_APU_VALVE_STUCK) == 0) then
        SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_BLEED_valves_img, size[1]/2+0, size[2]/2-105, 180, 58, 3, get(Apu_bleed_xplane) == 0 and 1 or 3, get(FAILURE_BLEED_APU_VALVE_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)
    end
end

local function fuck_my_ass(big_dick, small_dick, left_text, right_text)
    sasl.gl.drawArc (big_dick, small_dick , 56, 59 , 30 , 120 , ECAM_WHITE)
    sasl.gl.drawWideLine(big_dick, small_dick+57, big_dick, small_dick+64, 3, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, big_dick+88, small_dick+37, right_text, 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, big_dick-88, small_dick+37, left_text, 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)

    drawTextCentered(Font_ECAMfont, big_dick+52, small_dick+81, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
end

local function draw_bleed_bgd()
    drawTextCentered(Font_ECAMfont, 79, 870, "BLEED", 44, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(12, 848, 150, 848, 4, ECAM_WHITE)

    drawTextCentered(Font_ECAMfont, 346, 147, "HP", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 560, 147, "HP", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 200, 147, "IP", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 700, 147, "IP", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    drawTextCentered(Font_ECAMfont, 283, 407, "PSI", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 283, 368, "°C", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 621, 407, "PSI", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 621, 368, "°C", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    drawTextCentered(Font_ECAMfont, 450, 649, "AIR", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 450, 683, "RAM", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawWideLine(201, 432, 201, 542, 3, ECAM_GREEN)
    sasl.gl.drawWideLine(702, 432, 702, 542, 3, ECAM_GREEN)

    fuck_my_ass(702, 571,"LO","HI")
    fuck_my_ass(702, 675,"C","H")
    fuck_my_ass(198, 571,"LO","HI")
    fuck_my_ass(198, 675,"C","H")

    Sasl_DrawWideFrame(158, 344, 84, 84, 3, 0, ECAM_LINE_GREY)
    Sasl_DrawWideFrame(659, 344, 84, 84, 3, 0, ECAM_LINE_GREY)

    sasl.gl.drawTexture(ECAM_BLEED_house_img, 125, 598, 149, 204, ECAM_LINE_GREY)
    sasl.gl.drawTexture(ECAM_BLEED_house_img, 626, 598, 149, 204, ECAM_LINE_GREY)
end

function draw_bleed_page()
    draw_bleed_bgd()
    draw_apu_and_gas()
    draw_engines()    
    draw_bleed_numbers()
    draw_x_bleed()
    draw_ai()
    draw_packs()
    draw_ram_air()
    draw_needles_valves_and_mixer()
end
