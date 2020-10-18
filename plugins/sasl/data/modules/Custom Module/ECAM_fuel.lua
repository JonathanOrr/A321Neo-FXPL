size = {898, 900}
include('constants.lua')

FUEL_TANK_C  = 0
FUEL_TANK_L  = 1
FUEL_TANK_R  = 2
FUEL_TANK_ACT  = 3
FUEL_TANK_RCT  = 4

local function draw_wide_frame(x1,y1,x2,y2,width,color)
        sasl.gl.drawWideLine(x1,y1-width/2,x1,y2+width/2,width,color)
        sasl.gl.drawWideLine(x1,y2,x2,y2,width,color)
        sasl.gl.drawWideLine(x2,y2+width/2,x2,y1-width/2,width,color)
        sasl.gl.drawWideLine(x2,y1,x1,y1,width,color)
end

local function draw_open_arrow_up(x,y,color)
    sasl.gl.drawWidePolyLine( {x, y, x-10, y-20, x+10, y-20, x, y }, 3, color)
end
local function draw_open_arrow_left(x,y,color)
    sasl.gl.drawWidePolyLine( {x, y, x+20, y+15, x+20, y-15, x, y }, 3, color)
end
local function draw_fill_arrow_up(x,y,color)
    sasl.gl.drawTriangle( x, y+1, x-11, y-21, x+11, y-21,color)
end
local function draw_fill_arrow_left(x,y,color)
    sasl.gl.drawTriangle( x, y, x+21, y+16, x+21, y-16, color)
end

local function draw_tank_qty()

    local fuel_C  = math.floor(get(Fuel_quantity[FUEL_TANK_C]))
    local fuel_L  = math.floor(get(Fuel_quantity[FUEL_TANK_L]))
    local fuel_R  = math.floor(get(Fuel_quantity[FUEL_TANK_R]))
    local fuel_ACT= math.floor(get(Fuel_quantity[FUEL_TANK_ACT]))
    local fuel_RCT= math.floor(get(Fuel_quantity[FUEL_TANK_RCT]))
    
    local c_pump_fail_or_off = fuel_C > 0 and (not Fuel_sys.tank_pump_and_xfr[5].status) and (not Fuel_sys.tank_pump_and_xfr[5].status)
    
    local act_pump_fail = get(FAILURE_FUEL, 7) == 1
    local rct_pump_fail = get(FAILURE_FUEL, 8) == 1

    -- Quantities per tank
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2, size[2]/2, fuel_C, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-300, size[2]/2, fuel_L, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+300, size[2]/2, fuel_R, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-100, size[2]/2-152, fuel_ACT, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+100, size[2]/2-152, fuel_RCT, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-100, size[2]/2-188, "ACT", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    draw_wide_frame(size[2]/2+40, size[2]/2-160, size[2]/2+160, size[2]/2-120, 3, act_pump_fail and ECAM_ORANGE or ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+100, size[2]/2-188, "RCT", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    draw_wide_frame(size[2]/2-40, size[2]/2-160, size[2]/2-160, size[2]/2-120, 3, rct_pump_fail and ECAM_ORANGE or ECAM_WHITE)
    
    -- Box center tank
    if c_pump_fail_or_off then
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2-10, size[1]/2+70, size[2]/2-10, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2-12, size[1]/2-70, size[2]/2+30, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2+70, size[2]/2-12, size[1]/2+70, size[2]/2+30, 3 , ECAM_ORANGE)
    end

end

local function draw_fob_qty()

    local any_failure = (math.floor(get(Fuel_quantity[FUEL_TANK_C])) > 0 and (not Fuel_sys.tank_pump_and_xfr[5].status) and (not Fuel_sys.tank_pump_and_xfr[5].status) ) or (get(FAILURE_FUEL, 7) == 1) or (get(FAILURE_FUEL, 8) == 1)

    local fob = math.floor(get(FOB))
    -- FOB
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-130, size[2]/2-310, fob, 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    -- Box FOB
    if any_failure then
        sasl.gl.drawWideLine(size[1]/2-250, size[2]/2-315, size[1]/2-120, size[2]/2-315, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-250, size[2]/2-317, size[1]/2-250, size[2]/2-280, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-120, size[2]/2-317, size[1]/2-120, size[2]/2-280, 3 , ECAM_ORANGE)
    end
end

local function draw_arrows_act_rct()

    local is_act_transfer_active = Fuel_sys.tank_pump_and_xfr[7].pressure_ok
    local is_rct_transfer_active = Fuel_sys.tank_pump_and_xfr[8].pressure_ok

    if is_act_transfer_active then
        if get(Fuel_light_pumps, 7) == 1 then
            draw_fill_arrow_up(size[2]/2-70, size[2]/2-50, ECAM_GREEN)
        else
            draw_open_arrow_up(size[2]/2-70, size[2]/2-50, ECAM_GREEN)
        end
    else
        if get(FAILURE_FUEL, 7) == 1 then
            draw_open_arrow_up(size[2]/2-70, size[2]/2-50, ECAM_ORANGE)
        else
            draw_open_arrow_up(size[2]/2-70, size[2]/2-50, ECAM_WHITE)        
        end
    end
    if is_rct_transfer_active then
        print(get(Fuel_light_pumps, 7))
        if get(Fuel_light_pumps, 8) == 1 then
            draw_fill_arrow_up(size[2]/2+70, size[2]/2-50, ECAM_GREEN)
        else
            draw_open_arrow_up(size[2]/2+70, size[2]/2-50, ECAM_GREEN)
        end
    else
        if get(FAILURE_FUEL, 8) == 1 then
            draw_open_arrow_up(size[2]/2+70, size[2]/2-50, ECAM_ORANGE)
        else
            draw_open_arrow_up(size[2]/2+70, size[2]/2-50, ECAM_WHITE)        
        end     
    end
end

local function draw_fuel_usage_and_ff()

    local fuel_usage_1 = get(Ecam_fuel_usage_1)
    local fuel_usage_2 = get(Ecam_fuel_usage_2)
    local fuel_usage_tot = fuel_usage_1 + fuel_usage_2
    
    local color = get(EWD_flight_phase) >= 2 and ECAM_GREEN or ECAM_WHITE

    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-220, size[2]-110, fuel_usage_1, 36, false, false, TEXT_ALIGN_CENTER, color)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+220, size[2]-110, fuel_usage_2, 36, false, false, TEXT_ALIGN_CENTER, color)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2, size[2]-127, fuel_usage_tot, 36, false, false, TEXT_ALIGN_CENTER, color)
    

    if get(Engine_1_master_switch) == 0 and get(Engine_2_master_switch) == 0 then
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2-120, size[2]/2-260, "xx", 36, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    else
        local total_ff = math.ceil(get(Eng_1_FF_kgm) + get(Eng_2_FF_kgm))
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2-120, size[2]/2-260, total_ff, 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end
    
    
end

local function draw_engine_nr()

    local color_1 = (get(Engine_1_avail) == 0 and get(Engine_1_master_switch) == 1) and ECAM_ORANGE or ECAM_WHITE
    local color_2 = (get(Engine_2_avail) == 0 and get(Engine_2_master_switch) == 1) and ECAM_ORANGE or ECAM_WHITE

    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-220, size[2]-65, "1", 46, false, false, TEXT_ALIGN_CENTER, color_1)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+220, size[2]-65, "2", 46, false, false, TEXT_ALIGN_CENTER, color_2)

end

local function draw_apu_legend()
    
    local apu_text_color = ECAM_WHITE
    if get(Fire_pb_APU_status) == 1
       or (get(Apu_fuel_valve) == 1 and get(Apu_master_button_state) % 2 == 0)
       or (get(Apu_fuel_valve) == 0 and get(Apu_master_button_state) % 2 == 1)  then
        apu_text_color = ECAM_ORANGE
    end
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-320, size[2]/2+200, "APU", 36, false, false, TEXT_ALIGN_CENTER, apu_text_color)
    
    if get(Apu_fuel_valve) == 0 and apu_text_color == ECAM_WHITE then
        draw_open_arrow_left(size[2]/2-280, size[2]/2+212, ECAM_WHITE)
    elseif get(Apu_fuel_valve) == 1 and apu_text_color == ECAM_WHITE  then
        draw_open_arrow_left(size[2]/2-280, size[2]/2+212, ECAM_GREEN)
        sasl.gl.drawWideLine(size[2]/2-260, size[2]/2+212, size[2]/2-220, size[2]/2+212, 3 , ECAM_GREEN)
    elseif get(Apu_fuel_valve) == 1 then
        draw_fill_arrow_left(size[2]/2-280, size[2]/2+212, ECAM_ORANGE)
        sasl.gl.drawWideLine(size[2]/2-260, size[2]/2+212, size[2]/2-220, size[2]/2+212, 3 , ECAM_ORANGE)
    end
end

local function draw_temps()
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-300, size[2]/2-80, math.ceil(get(Fuel_wing_L_temp)), 26, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-245, size[2]/2-80, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+300, size[2]/2-80, math.ceil(get(Fuel_wing_R_temp)), 26, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+345, size[2]/2-80, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE) 
end

function draw_valve_lines()
    if get(Ecam_fuel_valve_X_BLEED) == 0 or get(Ecam_fuel_valve_X_BLEED) == 1 then
        sasl.gl.drawWideLine(size[2]/2-220, size[2]/2+215, size[2]/2-40, size[2]/2+215, 3 , ECAM_GREEN)
        sasl.gl.drawWideLine(size[2]/2+220, size[2]/2+215, size[2]/2+40, size[2]/2+215, 3 , ECAM_GREEN)
    end
end

function draw_fuel_page()

    draw_tank_qty()
    draw_fob_qty()
    draw_arrows_act_rct()
    draw_fuel_usage_and_ff()
    draw_engine_nr()
    draw_apu_legend()
    draw_temps()
    draw_valve_lines()
end


function ecam_update_fuel_page()

    -- L1
    if not Fuel_sys.tank_pump_and_xfr[1].switch then
        set(Ecam_fuel_valve_L_1, 1)
    elseif not Fuel_sys.tank_pump_and_xfr[1].pressure_ok then
        set(Ecam_fuel_valve_L_1, 2)
    else
        set(Ecam_fuel_valve_L_1, 3)
    end

    -- L2
    if not Fuel_sys.tank_pump_and_xfr[2].switch then
        set(Ecam_fuel_valve_L_2, 1)
    elseif not Fuel_sys.tank_pump_and_xfr[2].pressure_ok then
        set(Ecam_fuel_valve_L_2, 2)
    else
        set(Ecam_fuel_valve_L_2, 3)
    end

    -- R1
    if not Fuel_sys.tank_pump_and_xfr[3].switch then
        set(Ecam_fuel_valve_R_1, 1)
    elseif not Fuel_sys.tank_pump_and_xfr[3].pressure_ok then
        set(Ecam_fuel_valve_R_1, 2)
    else
        set(Ecam_fuel_valve_R_1, 3)
    end

    -- R2
    if not Fuel_sys.tank_pump_and_xfr[4].switch then
        set(Ecam_fuel_valve_R_2, 1)
    elseif not Fuel_sys.tank_pump_and_xfr[4].pressure_ok then
        set(Ecam_fuel_valve_R_2, 2)
    else
        set(Ecam_fuel_valve_R_2, 3)
    end

    -- C1
    if not Fuel_sys.tank_pump_and_xfr[5].switch then
        set(Ecam_fuel_valve_C_1, 0)
    elseif not Fuel_sys.tank_pump_and_xfr[5].auto_status then
        set(Ecam_fuel_valve_C_1, 0)
    elseif not Fuel_sys.tank_pump_and_xfr[5].pressure_ok then
        set(Ecam_fuel_valve_C_1, 2)
    else
        set(Ecam_fuel_valve_C_1, 1)
    end


    -- C2
    if not Fuel_sys.tank_pump_and_xfr[6].switch then
        set(Ecam_fuel_valve_C_2, 0)
    elseif not Fuel_sys.tank_pump_and_xfr[6].auto_status then
        set(Ecam_fuel_valve_C_2, 0)
    elseif not Fuel_sys.tank_pump_and_xfr[6].pressure_ok then
        set(Ecam_fuel_valve_C_2, 2)
    else
        set(Ecam_fuel_valve_C_2, 1)
    end


end

