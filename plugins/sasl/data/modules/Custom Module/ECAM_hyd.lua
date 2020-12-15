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
-- File: ECAM_hyd.lua 
-- Short description: ECAM file for the HYD page
-------------------------------------------------------------------------------

size = {900, 900}
include('constants.lua')

local y_psi_pos = size[2]/2+265 -- Starting top point (the PSI numbers position)

local function get_color_green_blinking()
    if math.floor(get(TIME)) % 2 == 0 then
        return ECAM_GREEN
    else
        return ECAM_HIGH_GREEN
    end
end

local function draw_psi_numbers(g_psi, b_psi, y_psi)

    -- GREEN
    local g_color = g_psi >= 1450 and ECAM_GREEN or ECAM_ORANGE
    sasl.gl.drawText(Font_AirbusDUL, 160, y_psi_pos, g_psi, 36, false, false, TEXT_ALIGN_CENTER, g_color)
    sasl.gl.drawWideLine (160, y_psi_pos-20 , 160, y_psi_pos-230, 4 , g_color)

    local b_color = b_psi >= 1450 and ECAM_GREEN or ECAM_ORANGE
    sasl.gl.drawText(Font_AirbusDUL, 453, y_psi_pos, b_psi, 36, false, false, TEXT_ALIGN_CENTER, b_color)
    sasl.gl.drawWideLine (453, y_psi_pos-20 , 453, y_psi_pos-275, 4 , b_color)

    local y_color = y_psi >= 1450 and ECAM_GREEN or ECAM_ORANGE
    sasl.gl.drawText(Font_AirbusDUL, 745, y_psi_pos, y_psi, 36, false, false, TEXT_ALIGN_CENTER, y_color)
    sasl.gl.drawWideLine (745, y_psi_pos-20 , 745, y_psi_pos-230, 4 , y_color)
end

local function draw_single_square_border(x,y,rect_size,color)

    x = x - rect_size/2
    sasl.gl.drawWidePolyLine( {x, y, x+rect_size, y, x+rect_size, y+rect_size, x, y+rect_size, x, y-2}, 4, color)
end

local function draw_rectangles(g_psi, b_psi, y_psi)
    local rect_size = 60

    ----------------------
    -- GREEN Rectangle  --
    ----------------------

    -- Draw the internal of the rectangle
    local color_rectangle = ECAM_ORANGE
    if PB.ovhd.hyd_eng1.status_bottom then
        sasl.gl.drawWideLine (160-rect_size/2, y_psi_pos-290+rect_size/2 , 160+rect_size/2, y_psi_pos-290+rect_size/2, 4, ECAM_ORANGE)
    elseif g_psi >= 1450 then
        color_rectangle = ECAM_GREEN
        sasl.gl.drawWideLine (160, y_psi_pos-290, 160, y_psi_pos-290+rect_size, 4, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, 160, y_psi_pos-275, "LO", 40, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    -- Draw the rectangle external
    draw_single_square_border(160, y_psi_pos-290, rect_size, color_rectangle)

    ----------------------
    -- BLUE Rectangle   --
    ----------------------
    color_rectangle = ECAM_ORANGE
    if PB.ovhd.hyd_elec_B.status_bottom then
        sasl.gl.drawWideLine (453-rect_size/2, y_psi_pos-335+rect_size/2, 453+rect_size/2, y_psi_pos-335+rect_size/2, 4, ECAM_ORANGE)
    elseif b_psi >= 1450 then
        color_rectangle = ECAM_GREEN
        sasl.gl.drawWideLine (453, y_psi_pos-335, 453, y_psi_pos-335+rect_size, 4, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, 452, y_psi_pos-320, "LO", 40, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    -- Draw the rectangle external
    draw_single_square_border(452, y_psi_pos-335, rect_size, color_rectangle)

    ----------------------
    -- YELLOW Rectangle --
    ----------------------
    color_rectangle = ECAM_ORANGE
    if PB.ovhd.hyd_eng2.status_bottom then
        sasl.gl.drawWideLine (745-rect_size/2, y_psi_pos-290+rect_size/2 , 745+rect_size/2, y_psi_pos-290+rect_size/2, 4, ECAM_ORANGE)
    elseif y_psi >= 1450 then
        color_rectangle = ECAM_GREEN
        sasl.gl.drawWideLine (745, y_psi_pos-290, 745, y_psi_pos-290+rect_size, 4, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, 745, y_psi_pos-275, "LO", 40, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    -- Draw the rectangle external
    draw_single_square_border(745, y_psi_pos-290, rect_size, color_rectangle)

end

local function draw_engine_numbers()
    -- ENGINE 1
    local num_color = get(Engine_1_avail) == 0  and ECAM_ORANGE or ECAM_WHITE
    sasl.gl.drawText(Font_AirbusDUL, 230, y_psi_pos-290, "1", 34, false, false, TEXT_ALIGN_CENTER, num_color)

    -- ENGINE 2
    num_color = get(Engine_2_avail) == 0  and ECAM_ORANGE or ECAM_WHITE
    sasl.gl.drawText(Font_AirbusDUL, 670, y_psi_pos-290, "2", 34, false, false, TEXT_ALIGN_CENTER, num_color)

end

local function draw_quantity_bars(qty_G, qty_B, qty_Y)

    -- GREEN
    local y_top = size[2]/2-317+147 * qty_G
    local qty_color = ECAM_GREEN
    if qty_G < 0.18 then
        qty_color = ECAM_ORANGE
    elseif qty_G < 0.82 then
        qty_color = get_color_green_blinking()
    end
    
    if qty_G > 0.10 then
        sasl.gl.drawWidePolyLine( {160, size[2]/2-308, 145, size[2]/2-308, 145, y_top, 157, y_top+10, 145, y_top+20 }, 4, qty_color)
    else
        sasl.gl.drawWidePolyLine( {145, y_top, 157, y_top+10, 145, y_top+20 }, 4, qty_color)    
    end
    
    -- BLUE
    y_top = size[2]/2-317+147 * qty_B
    qty_color = ECAM_GREEN
    if qty_B < 0.31 then
        qty_color = ECAM_ORANGE
    elseif qty_B < 0.76 then
        qty_color = get_color_green_blinking()
    end
    

    if qty_B > 0.10 then
        sasl.gl.drawWidePolyLine( {453, size[2]/2-308, 453-15, size[2]/2-308, 453-15, y_top, 453-3, y_top+10, 453-15, y_top+20 }, 4, qty_color)
    else
        sasl.gl.drawWidePolyLine( {453-15, y_top, 453-3, y_top+10, 453-15, y_top+20 }, 4, qty_color)
    end
    

    -- YELLOW
    y_top = size[2]/2-317+147 * qty_Y
    qty_color = ECAM_GREEN
    if qty_Y < 0.22 then
        qty_color = ECAM_ORANGE
    elseif qty_Y < 0.8 then
        qty_color = get_color_green_blinking()
    end
    
    if qty_Y > 0.10 then
        sasl.gl.drawWidePolyLine( {745, size[2]/2-308, 730, size[2]/2-308, 730, y_top, 742, y_top+10, 730, y_top+20 }, 4, qty_color)
    else
        sasl.gl.drawWidePolyLine( {730, y_top, 742, y_top+10, 730, y_top+20 }, 4, qty_color)
    end

end

local function draw_failures()

    if get(FAILURE_HYD_G_low_air) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 250, size[2]/2-185, "LO AIR", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, 250, size[2]/2-230, "PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end        
    if get(FAILURE_HYD_G_R_overheat) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 250, size[2]/2-310, "OVHT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    if get(FAILURE_HYD_B_low_air) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 540, size[2]/2-185, "LO AIR", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, 540, size[2]/2-230, "PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_HYD_B_R_overheat) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 540, size[2]/2-310, "OVHT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    if get(FAILURE_HYD_Y_low_air) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 830, size[2]/2-185, "LO AIR", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, 830, size[2]/2-230, "PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_HYD_Y_R_overheat) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 830, size[2]/2-310, "OVHT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_extra_pumps()

    -- Yellow ELEC arrow and messages
    if PB.ovhd.hyd_elec_Y.status_bottom and PB.ovhd.hyd_elec_Y.status_top then
        sasl.gl.drawTriangle (770 , size[2]/2+95 , 795 , size[2]/2+110 , 795 , size[2]/2+80 , ECAM_ORANGE)
    elseif PB.ovhd.hyd_elec_Y.status_bottom then
        sasl.gl.drawWideLine ( 747, size[2]/2+95 , 772, size[2]/2+95, 4 , ECAM_GREEN)
        sasl.gl.drawTriangle ( 770 , size[2]/2+95 , 795 , size[2]/2+110 , 795 , size[2]/2+80 , ECAM_GREEN )
    else
        sasl.gl.drawWidePolyLine({770, size[2]/2+95, 795, size[2]/2+110, 795, size[2]/2+80, 770, size[2]/2+95}, 4, ECAM_WHITE )
    end

    local elec_color = get(AC_bus_2_pwrd) == 1 and ECAM_WHITE or ECAM_ORANGE
    sasl.gl.drawText(Font_AirbusDUL, 840, size[2]/2+100, "ELEC", 26, false, false, TEXT_ALIGN_CENTER, elec_color)

    if get(FAILURE_HYD_Y_E_overheat) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 840, size[2]/2+70, "OVHT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end


    -- BLUE ELEC pump messages
    local elec_color = get(AC_bus_1_pwrd) == 1 and ECAM_WHITE or ECAM_ORANGE
    sasl.gl.drawText(Font_AirbusDUL, 540, size[2]/2-10, "ELEC", 26, false, false, TEXT_ALIGN_CENTER, elec_color)

    if get(FAILURE_HYD_B_E_overheat) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 540, size[2]/2-40, "OVHT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    -- RAT text and arrow
    if get(Hydraulic_RAT_status) == 0 then
        sasl.gl.drawText(Font_AirbusDUL, 370, size[2]/2+85, "RAT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawWidePolyLine( {432 , size[2]/2+95 , 407 , size[2]/2+110 , 407 , size[2]/2+80, 432 , size[2]/2+95}, 4, ECAM_WHITE)
    elseif get(Hydraulic_RAT_status) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 370, size[2]/2+85, "RAT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawTriangle ( 432 , size[2]/2+95 , 407 , size[2]/2+110 , 407 , size[2]/2+80 , ECAM_GREEN )
        sasl.gl.drawWideLine ( 428, size[2]/2+95 , 453, size[2]/2+95, 4 , ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, 370, size[2]/2+85, "RAT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawTriangle ( 432 , size[2]/2+95 , 407 , size[2]/2+110 , 407 , size[2]/2+80 , ECAM_ORANGE )
    end
end

local function draw_hyd_textures()
    SASL_drawSegmentedImg_xcenter_aligned(ECAM_HYD_G_status_img, size[1]/2-290, size[2]/2+317, 192, 54, 2, get(Hydraulic_G_press) >= 1450 and 1 or 2)
    SASL_drawSegmentedImg_xcenter_aligned(ECAM_HYD_B_status_img, size[1]/2+3, size[2]/2+317, 152, 55, 2, get(Hydraulic_B_press) >= 1450 and 1 or 2)
    SASL_drawSegmentedImg_xcenter_aligned(ECAM_HYD_Y_status_img, size[1]/2+296, size[2]/2+317, 232, 55, 2, get(Hydraulic_Y_press) >= 1450 and 1 or 2)

    SASL_drawSegmentedImg_xcenter_aligned(ECAM_HYD_PTU_img, size[1]/2+3, size[2]/2+160, 2360, 43, 4, get(Hydraulic_PTU_status) + 1)

    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_HYD_fire_valve_img, size[1]/2-290, size[2]/2-158, 114, 133, 2, get(Eng_1_Firewall_valve) == 1 and 2 or 1, get(Eng_1_Firewall_valve) == 1 and ECAM_ORANGE or ECAM_GREEN)
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_HYD_fire_valve_img, size[1]/2+295, size[2]/2-158, 114, 133, 2, get(Eng_1_Firewall_valve) == 1 and 2 or 1, get(Eng_2_Firewall_valve) == 1 and ECAM_ORANGE or ECAM_GREEN)
end

function draw_hydraulic_page()

    sasl.gl.drawTexture(ECAM_HYD_bgd_img, 0, 0, 900, 900, {1,1,1})

    draw_hyd_textures()

    -- Compute the hyd pressures
    local g_psi = get(Hydraulic_G_press)
    g_psi = g_psi - g_psi % 50

    local b_psi = get(Hydraulic_B_press)
    b_psi = b_psi - b_psi % 50


    local y_psi = get(Hydraulic_Y_press)
    y_psi = y_psi - y_psi % 50

    draw_psi_numbers(g_psi, b_psi, y_psi)   -- Draw the top numbers
    draw_rectangles(g_psi, b_psi, y_psi)    -- Draw the rectangles with the pump status
    draw_engine_numbers()

    local qty_G = get(Hydraulic_G_qty)
    local qty_B = get(Hydraulic_B_qty)
    local qty_Y = get(Hydraulic_Y_qty)

    draw_quantity_bars(qty_G, qty_B, qty_Y)

    draw_extra_pumps()  -- Draw ELEC for Y and RAT for B


    draw_failures()


end
