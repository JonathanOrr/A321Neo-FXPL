size = {900, 900}
include('constants.lua')

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
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
    sasl.gl.drawText(B612MONO_regular, 160, y_psi_pos, g_psi, 36, false, false, TEXT_ALIGN_CENTER, g_color)
    sasl.gl.drawWideLine (160, y_psi_pos-20 , 160, y_psi_pos-230, 4 , g_color)

    local b_color = b_psi >= 1450 and ECAM_GREEN or ECAM_ORANGE
    sasl.gl.drawText(B612MONO_regular, 453, y_psi_pos, b_psi, 36, false, false, TEXT_ALIGN_CENTER, b_color)
    sasl.gl.drawWideLine (453, y_psi_pos-20 , 453, y_psi_pos-275, 4 , b_color)
        
    local y_color = y_psi >= 1450 and ECAM_GREEN or ECAM_ORANGE
    sasl.gl.drawText(B612MONO_regular, 745, y_psi_pos, y_psi, 36, false, false, TEXT_ALIGN_CENTER, y_color)
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
    if get(Hyd_light_Eng1Pump) % 10 == 1 then
        sasl.gl.drawWideLine (160-rect_size/2, y_psi_pos-290+rect_size/2 , 160+rect_size/2, y_psi_pos-290+rect_size/2, 4, ECAM_ORANGE)
    elseif g_psi >= 1450 then
        color_rectangle = ECAM_GREEN
        sasl.gl.drawWideLine (160, y_psi_pos-290, 160, y_psi_pos-290+rect_size, 4, ECAM_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, 160, y_psi_pos-275, "LO", 40, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    -- Draw the rectangle external
    draw_single_square_border(160, y_psi_pos-290, rect_size, color_rectangle)

    ----------------------
    -- BLUE Rectangle   --
    ----------------------
    color_rectangle = ECAM_ORANGE
    if get(Hyd_light_B_ElecPump) % 10 == 1 then
        sasl.gl.drawWideLine (453-rect_size/2, y_psi_pos-335+rect_size/2, 453+rect_size/2, y_psi_pos-335+rect_size/2, 4, ECAM_ORANGE)
    elseif b_psi >= 1450 then
        color_rectangle = ECAM_GREEN
        sasl.gl.drawWideLine (453, y_psi_pos-335, 453, y_psi_pos-335+rect_size, 4, ECAM_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, 452, y_psi_pos-320, "LO", 40, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    -- Draw the rectangle external
    draw_single_square_border(452, y_psi_pos-335, rect_size, color_rectangle)

    ----------------------
    -- YELLOW Rectangle --
    ----------------------
    color_rectangle = ECAM_ORANGE
    if get(Hyd_light_Eng2Pump) % 10 == 1 then
        sasl.gl.drawWideLine (745-rect_size/2, y_psi_pos-290+rect_size/2 , 745+rect_size/2, y_psi_pos-290+rect_size/2, 4, ECAM_ORANGE)
    elseif y_psi >= 1450 then
        color_rectangle = ECAM_GREEN
        sasl.gl.drawWideLine (745, y_psi_pos-290, 745, y_psi_pos-290+rect_size, 4, ECAM_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, 745, y_psi_pos-275, "LO", 40, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    -- Draw the rectangle external
    draw_single_square_border(745, y_psi_pos-290, rect_size, color_rectangle)
    
end

local function draw_engine_numbers()
    -- ENGINE 1
    local num_color = get(Engine_1_avail) == 0  and ECAM_ORANGE or ECAM_WHITE    
    sasl.gl.drawText(B612MONO_regular, 230, y_psi_pos-290, "1", 34, false, false, TEXT_ALIGN_CENTER, num_color)

    -- ENGINE 2
    num_color = get(Engine_2_avail) == 0  and ECAM_ORANGE or ECAM_WHITE    
    sasl.gl.drawText(B612MONO_regular, 670, y_psi_pos-290, "2", 34, false, false, TEXT_ALIGN_CENTER, num_color)

end

local function draw_quantity_bars(qty_G, qty_B, qty_Y)

    -- GREEN
    y_top = size[2]/2-310+140 * get(Hydraulic_G_qty)
    local qty_color = ECAM_GREEN
    if get(Hydraulic_G_qty) < 0.18 then
        qty_color = ECAM_ORANGE
    elseif  get(Hydraulic_G_qty) < 0.83 then
        qty_color = get_color_green_blinking()
    end
    sasl.gl.drawWidePolyLine( {160, size[2]/2-308, 145, size[2]/2-308, 145, y_top, 157, y_top+10, 145, y_top+20 }, 4, qty_color)

    -- BLUE
    y_top = size[2]/2-310+140 * get(Hydraulic_B_qty)
    local qty_color = ECAM_GREEN
    if get(Hydraulic_B_qty) < 0.31 then
        qty_color = ECAM_ORANGE
    elseif  get(Hydraulic_B_qty) < 0.8 then
        qty_color = get_color_green_blinking()
    end
    sasl.gl.drawWidePolyLine( {453, size[2]/2-308, 453-15, size[2]/2-308, 453-15, y_top, 453-3, y_top+10, 453-15, y_top+20 }, 4, qty_color)

    -- YELLOW
    y_top = size[2]/2-310+140 * get(Hydraulic_Y_qty)
    local qty_color = ECAM_GREEN
    if get(Hydraulic_Y_qty) < 0.22 then
        qty_color = ECAM_ORANGE
    elseif  get(Hydraulic_Y_qty) < 0.81 then
        qty_color = get_color_green_blinking()
    end
    sasl.gl.drawWidePolyLine( {745, size[2]/2-308, 730, size[2]/2-308, 730, y_top, 742, y_top+10, 730, y_top+20 }, 4, qty_color)


end

local function draw_failures()

    if get(FAILURE_HYD_G_low_air) == 1 then
        sasl.gl.drawText(B612MONO_regular, 250, size[2]/2-185, "LO AIR", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 250, size[2]/2-230, "PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end        
    if get(FAILURE_HYD_G_R_overheat) == 1 then
        sasl.gl.drawText(B612MONO_regular, 250, size[2]/2-310, "OVHT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    if get(FAILURE_HYD_B_low_air) == 1 then
        sasl.gl.drawText(B612MONO_regular, 540, size[2]/2-185, "LO AIR", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 540, size[2]/2-230, "PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_HYD_B_R_overheat) == 1 then
        sasl.gl.drawText(B612MONO_regular, 540, size[2]/2-310, "OVHT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    
    if get(FAILURE_HYD_Y_low_air) == 1 then
        sasl.gl.drawText(B612MONO_regular, 830, size[2]/2-185, "LO AIR", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 830, size[2]/2-230, "PRESS", 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_HYD_Y_R_overheat) == 1 then
        sasl.gl.drawText(B612MONO_regular, 830, size[2]/2-310, "OVHT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_extra_pumps()

    -- Yellow ELEC arrow and messages
    if get(Hyd_light_Y_ElecPump) == 11 then
        sasl.gl.drawTriangle (770 , size[2]/2+95 , 795 , size[2]/2+110 , 795 , size[2]/2+80 , ECAM_ORANGE)
    elseif get(Hyd_light_Y_ElecPump) == 1 then
        sasl.gl.drawWideLine ( 747, size[2]/2+95 , 772, size[2]/2+95, 4 , ECAM_GREEN)
        sasl.gl.drawTriangle ( 770 , size[2]/2+95 , 795 , size[2]/2+110 , 795 , size[2]/2+80 , ECAM_GREEN )
    else
        sasl.gl.drawWidePolyLine({770, size[2]/2+95, 795, size[2]/2+110, 795, size[2]/2+80, 770, size[2]/2+95}, 4, ECAM_WHITE )
    end
    
    local elec_color = get(AC_bus_2_pwrd) == 1 and ECAM_WHITE or ECAM_ORANGE
    sasl.gl.drawText(B612MONO_regular, 840, size[2]/2+100, "ELEC", 26, false, false, TEXT_ALIGN_CENTER, elec_color)
    
    if get(FAILURE_HYD_Y_E_overheat) == 1 then
        sasl.gl.drawText(B612MONO_regular, 840, size[2]/2+70, "OVHT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end    

    
    -- BLUE ELEC pump messages
    local elec_color = get(AC_bus_1_pwrd) == 1 and ECAM_WHITE or ECAM_ORANGE
    sasl.gl.drawText(B612MONO_regular, 540, size[2]/2-10, "ELEC", 26, false, false, TEXT_ALIGN_CENTER, elec_color)
    
    if get(FAILURE_HYD_B_E_overheat) == 1 then
        sasl.gl.drawText(B612MONO_regular, 540, size[2]/2-40, "OVHT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end    

    -- RAT text and arrow
    if get(Hydraulic_RAT_status) == 0 then
        sasl.gl.drawText(B612MONO_regular, 370, size[2]/2+85, "RAT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawWidePolyLine( {432 , size[2]/2+95 , 407 , size[2]/2+110 , 407 , size[2]/2+80, 432 , size[2]/2+95}, 4, ECAM_WHITE)
    elseif get(Hydraulic_RAT_status) == 1 then
        sasl.gl.drawText(B612MONO_regular, 370, size[2]/2+85, "RAT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawTriangle ( 432 , size[2]/2+95 , 407 , size[2]/2+110 , 407 , size[2]/2+80 , ECAM_GREEN )
        sasl.gl.drawWideLine ( 428, size[2]/2+95 , 453, size[2]/2+95, 4 , ECAM_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, 370, size[2]/2+85, "RAT", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawTriangle ( 432 , size[2]/2+95 , 407 , size[2]/2+110 , 407 , size[2]/2+80 , ECAM_ORANGE )
    end
end

function draw_hydraulic_page()

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
