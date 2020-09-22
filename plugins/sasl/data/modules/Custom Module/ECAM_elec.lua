size = {900, 900}
include('constants.lua')

local GEN_1 = 1
local GEN_2 = 2
local GEN_APU = 3
local GEN_EXT  = 4
local GEN_EMER = 5

local AC_BUS_1 = 11
local AC_BUS_2 = 12

local STATIC_INVERTER = 21

local TR_1 = 31
local TR_2 = 32
local TR_ESS = 33

local BAT_1 = 41
local BAT_2 = 42

local CROSS_TIEBAT_BUS = 98
local GEN_FAKE_BUS_TIE = 99


local GEN_ENGINE_RATED_CURR = 261    -- Maximum current provided by the engine gen (this is not enforced but used to compute the load %)
local GEN_ENGINE_APU_CURR   = 261    -- Maximum current provided by the APU gen (this is not enforced but used to compute the load %)

local UPDATE_PERIOD = 0.5

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

local loads = {
    gen = {}
}

local function draw_open_arrow_up(x,y,color)
    sasl.gl.drawWidePolyLine( {x, y, x-10, y-15, x+10, y-15, x, y }, 3, color)
end
local function draw_open_arrow_down(x,y,color)
    sasl.gl.drawWidePolyLine( {x, y, x-10, y+15, x+10, y+15, x, y }, 3, color)
end


local function update_draw_datarefs()
    set(Ecam_elec_bat_1_status, ELEC_sys.batteries[1].switch_status and 1 or 0)
    set(Ecam_elec_bat_2_status, ELEC_sys.batteries[2].switch_status and 1 or 0)

    local is_tr_ess_activable = (get(TR_1_online) == 0 or get(TR_2_online) == 0) and get(INV_online) == 0
    set(Ecam_elec_tr_ess_status, (ELEC_sys.trs[3].status and 2 or ( is_tr_ess_activable and 1 or 0 )))

    if ELEC_sys.generators[3].source_status == false then
        set(Ecam_elec_apu_gen_status, 0)
    elseif ELEC_sys.generators[3].switch_status == false then
        set(Ecam_elec_apu_gen_status, 1)
    elseif ELEC_sys.generators[3].curr_voltage > 105 and ELEC_sys.generators[3].curr_hz > 385 then
        set(Ecam_elec_apu_gen_status, 2)
    else
        set(Ecam_elec_apu_gen_status, 3)    
    end

   if ELEC_sys.generators[5].switch_status == false then
        set(Ecam_elec_rat_status, 0)
    elseif ELEC_sys.generators[5].curr_voltage > 105 and ELEC_sys.generators[5].curr_hz > 385 then
        set(Ecam_elec_rat_status, 1)
    else
        set(Ecam_elec_rat_status, 2)
    end

end

local function draw_battery_contactor(i,x)
    local is_on_bus = ELEC_sys.batteries[i].is_connected_to_dc_bus
    
    if not is_on_bus then
        return
    end    

    if i == 1 then
        x_start = 272
    else
        x_start = 556
    end
    x_end = x_start + 78
    y = size[2]/2+373
    
    local curr_amps = ELEC_sys.batteries[i].curr_source_amps-ELEC_sys.batteries[i].curr_sink_amps
    
    if curr_amps > 11 then
        sasl.gl.drawWideLine(x_start, y, x_end, y, 3, ECAM_ORANGE)
        if i == 1 then
            sasl.gl.drawTriangle (x_end-15, y+10 , x_end-15, y-10, x_end+1, y, ECAM_ORANGE)
        else
            sasl.gl.drawTriangle (x_start+15, y+10 , x_start+15, y-10, x_start-1, y, ECAM_ORANGE)
        end
    else
        sasl.gl.drawWideLine(x_start, y, x_end, y, 3, ECAM_GREEN)
    end
    
    if curr_amps < -1 then
        if i == 1 then
            sasl.gl.drawTriangle (x_start+15, y+10 , x_start+15, y-10, x_start-1, y, ECAM_GREEN)
        else
            sasl.gl.drawTriangle (x_end-15, y+10 , x_end-15, y-10, x_end+1, y, ECAM_GREEN)
        end
    end 
end

local function draw_battery(i, x)

    local curr_amps = ELEC_sys.batteries[i].curr_sink_amps-ELEC_sys.batteries[i].curr_source_amps
    local failed_bat = (i == 1 and get(FAILURE_ELEC_battery_1) == 1) or (i == 2 and get(FAILURE_ELEC_battery_2) == 1)
    local bat_1_status = (ELEC_sys.batteries[i].curr_voltage < 25 or ELEC_sys.batteries[i].curr_voltage > 31 or
                         curr_amps > 5 or failed_bat) and ELEC_sys.batteries[i].switch_status

    sasl.gl.drawText(B612MONO_regular, x, size[2]/2+395, "BAT " .. i, 26, false, false, 
                     TEXT_ALIGN_LEFT, bat_1_status and ECAM_ORANGE or ECAM_WHITE)
                     
    if ELEC_sys.batteries[i].switch_status then
        sasl.gl.drawText(B612MONO_regular, x+65, size[2]/2+360, "V", 26, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(B612MONO_regular, x+65, size[2]/2+330, "A", 26, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

        sasl.gl.drawText(B612MONO_regular, x+60, size[2]/2+360, 
                         math.floor(ELEC_sys.batteries[i].curr_voltage+0.5), 26, false, false,
                         TEXT_ALIGN_RIGHT,
                         (ELEC_sys.batteries[i].curr_voltage < 25 or ELEC_sys.batteries[i].curr_voltage > 31)
                         and ECAM_ORANGE or ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, x+60, size[2]/2+330,
                         -math.floor(curr_amps+0.5), 26, false, false, 
                         TEXT_ALIGN_RIGHT,
                         curr_amps < -5 and ECAM_ORANGE or ECAM_GREEN)
        draw_battery_contactor(i,x)
    end

end

local function draw_tr(i, x)
    local failed_tr = ELEC_sys.trs[i].curr_voltage < 25 or ELEC_sys.trs[i].curr_voltage > 31 or ELEC_sys.trs[i].curr_out_amps <= 5
    
    sasl.gl.drawText(B612MONO_regular, x+20, size[2]/2+170, "TR " .. i, 26, false, false, 
                     TEXT_ALIGN_LEFT, failed_tr and ECAM_ORANGE or ECAM_WHITE)
    
    sasl.gl.drawText(B612MONO_regular, x+60, size[2]/2+132, 
                     math.floor(ELEC_sys.trs[i].curr_voltage+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.trs[i].curr_voltage < 25 or ELEC_sys.trs[i].curr_voltage > 31)
                     and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, x+60, size[2]/2+100,
                     math.floor(ELEC_sys.trs[i].curr_out_amps+0.5), 28, false, false, 
                     TEXT_ALIGN_RIGHT,
                     ELEC_sys.trs[i].curr_out_amps <= 5 and ECAM_ORANGE or ECAM_GREEN)
    
    if ELEC_sys.trs[i].curr_voltage >= 25 then
        sasl.gl.drawWideLine(x+50, size[2]/2+201, x+50, size[2]/2+280, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(x+50, size[2]/2+92, x+50, size[2]/2+38, 3, ECAM_GREEN)
    end
    
end

local function draw_ess_tr()
    local failed_tr = ELEC_sys.trs[3].curr_voltage < 25 or ELEC_sys.trs[3].curr_voltage > 31 or ELEC_sys.trs[3].curr_out_amps <= 5
    

    if get(Ecam_elec_tr_ess_status) == 0 then
        return -- Nothing to draw it's hidden
    end
    
    sasl.gl.drawText(B612MONO_regular, 400, size[2]/2+125, 
                     math.floor(ELEC_sys.trs[3].curr_voltage+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.trs[3].curr_voltage < 25 or ELEC_sys.trs[3].curr_voltage > 31)
                     and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, 400, size[2]/2+95,
                     math.floor(-ELEC_sys.trs[3].curr_out_amps+0.5), 28, false, false, 
                     TEXT_ALIGN_RIGHT,
                     ELEC_sys.trs[3].curr_out_amps <= 5 and ECAM_ORANGE or ECAM_GREEN)
    
    sasl.gl.drawWideLine(400, size[2]/2+82, 400, size[2]/2+26, 3, ECAM_GREEN)
    
end

local function draw_apu_gen()

    if get(Ecam_elec_apu_gen_status) <= 1 then
        return  -- Nothing to do
    end

    sasl.gl.drawText(B612MONO_regular, 335, size[2]/2-182, 
                     loads.gen[3], 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (-ELEC_sys.generators[3].curr_amps > GEN_ENGINE_APU_CURR)
                     and ECAM_ORANGE or ECAM_GREEN)
    
    sasl.gl.drawText(B612MONO_regular, 335, size[2]/2-215, 
                     math.floor(ELEC_sys.generators[3].curr_voltage+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[3].curr_voltage < 110 or ELEC_sys.generators[3].curr_voltage > 120)
                     and ECAM_ORANGE or ECAM_GREEN)

    sasl.gl.drawText(B612MONO_regular, 335, size[2]/2-246, 
                     math.floor(ELEC_sys.generators[3].curr_hz+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[3].curr_hz < 390 or ELEC_sys.generators[3].curr_hz > 410)
                     and ECAM_ORANGE or ECAM_GREEN)
                     
    -- Draw lines
    if ELEC_sys.buses.ac1_powered_by == 3 then
        draw_open_arrow_up(80,size[2]/2+10,ECAM_GREEN)
        sasl.gl.drawWideLine(80, size[2]/2-40, 80, size[2]/2-5, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(320, size[2]/2-40, 80, size[2]/2-40, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(320, size[2]/2-40, 320, size[2]/2-104, 3, ECAM_GREEN)      
        draw_open_arrow_up(320,size[2]/2-104,ECAM_GREEN)  
    end
    
    if ELEC_sys.buses.ac2_powered_by == 3 then
        draw_open_arrow_up(820,size[2]/2+10,ECAM_GREEN)
        sasl.gl.drawWideLine(820, size[2]/2-40, 820, size[2]/2-5, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(320, size[2]/2-40, 820, size[2]/2-40, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(320, size[2]/2-40, 320, size[2]/2-104, 3, ECAM_GREEN)
        draw_open_arrow_up(320,size[2]/2-104,ECAM_GREEN)  
    end
end

local function draw_gen_lines(x,i)
    if (i == 1 and ELEC_sys.buses.ac1_powered_by == 1) or (i == 2 and ELEC_sys.buses.ac2_powered_by == 2) then
        draw_open_arrow_up(x-30,size[2]/2+10,ECAM_GREEN)
        sasl.gl.drawWideLine(x-30, size[2]/2-81, x-30, size[2]/2-5, 3, ECAM_GREEN)
    end
    
    if i == 1 and ELEC_sys.buses.ac2_powered_by == 99 then
        draw_open_arrow_up(820,size[2]/2+10,ECAM_GREEN)
        sasl.gl.drawWideLine(820, size[2]/2-40, 820, size[2]/2-5, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(80, size[2]/2-40, 820, size[2]/2-40, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(80, size[2]/2-40, 80, size[2]/2-81, 3, ECAM_GREEN)
    end

    if i == 2 and ELEC_sys.buses.ac1_powered_by == 99 then
        draw_open_arrow_up(80,size[2]/2+10,ECAM_GREEN)
        sasl.gl.drawWideLine(80, size[2]/2-40, 80, size[2]/2-5, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(820, size[2]/2-40, 80, size[2]/2-40, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(820, size[2]/2-40, 820, size[2]/2-81, 3, ECAM_GREEN)
    end
end

local function draw_gen(x, i)
    local color_eng_num = ECAM_ORANGE

    if ELEC_sys.generators[i].source_status then
        color_eng_num = ECAM_WHITE
    end
    
    sasl.gl.drawText(B612MONO_regular, x, size[2]/2-112, i, 26, false, false, TEXT_ALIGN_LEFT, color_eng_num)
    
    if get(ELEC_sys.generators[i].drs.pwr)==0 then
        return  -- Nothing to do
    end

    sasl.gl.drawText(B612MONO_regular, x-12, size[2]/2-145, 
                     loads.gen[i], 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (-ELEC_sys.generators[i].curr_amps > GEN_ENGINE_RATED_CURR)
                     and ECAM_ORANGE or ECAM_GREEN)
   sasl.gl.drawText(B612MONO_regular, x-12, size[2]/2-175, 
                     math.floor(ELEC_sys.generators[i].curr_voltage+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[i].curr_voltage < 110 or ELEC_sys.generators[i].curr_voltage > 120)
                     and ECAM_ORANGE or ECAM_GREEN)

    sasl.gl.drawText(B612MONO_regular, x-12, size[2]/2-208, 
                     math.floor(ELEC_sys.generators[i].curr_hz+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[i].curr_hz < 390 or ELEC_sys.generators[i].curr_hz > 410)
                     and ECAM_ORANGE or ECAM_GREEN)

    -- Draw lines if they are powering the AC bus
    draw_gen_lines(x, i)
end

local function draw_stat_inv()
    if get(INV_online) == 0 then
        return  -- Nothing to do
    end
    
    sasl.gl.drawText(B612MONO_regular, 608, size[2]/2-116, 
                     math.floor(ELEC_sys.stat_inv.curr_voltage+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.stat_inv.curr_voltage < 110 or ELEC_sys.stat_inv.curr_voltage > 120)
                     and ECAM_ORANGE or ECAM_GREEN)

    sasl.gl.drawText(B612MONO_regular, 608, size[2]/2-149, 
                     math.floor(ELEC_sys.stat_inv.curr_hz+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.stat_inv.curr_hz < 390 or ELEC_sys.stat_inv.curr_hz > 410)
                     and ECAM_ORANGE or ECAM_GREEN)
    
    draw_open_arrow_down(240,size[2]/2+301,ECAM_GREEN)
    sasl.gl.drawWideLine(240, size[2]/2+301, 240, size[2]/2-75, 3, ECAM_GREEN)
    sasl.gl.drawWideLine(240, size[2]/2-75, 525, size[2]/2-75, 3, ECAM_GREEN)
end

local function draw_emer_gen()
    if not ELEC_sys.generators[5].switch_status then
        return  -- Nothing to do
    end
    
    sasl.gl.drawText(B612MONO_regular, 585, size[2]/2+125, 
                     math.floor(ELEC_sys.generators[5].curr_voltage+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[5].curr_voltage < 110 or ELEC_sys.generators[5].curr_voltage > 120)
                     and ECAM_ORANGE or ECAM_GREEN)

    sasl.gl.drawText(B612MONO_regular, 585, size[2]/2+95, 
                     math.floor(ELEC_sys.generators[5].curr_hz+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[5].curr_hz < 390 or ELEC_sys.generators[5].curr_hz > 410)
                     and ECAM_ORANGE or ECAM_GREEN)
    
end

local function draw_ext_pwr()
    if not ELEC_sys.generators[GEN_EXT].switch_status then
        return  -- Nothing to do
    end
    
    sasl.gl.drawText(B612MONO_regular, 585, size[2]/2-218, 
                     math.floor(ELEC_sys.generators[4].curr_voltage+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[GEN_EXT].curr_voltage < 110 or ELEC_sys.generators[GEN_EXT].curr_voltage > 120)
                     and ECAM_ORANGE or ECAM_GREEN)

    sasl.gl.drawText(B612MONO_regular, 585, size[2]/2-248, 
                     math.floor(ELEC_sys.generators[GEN_EXT].curr_hz+0.5), 28, false, false,
                     TEXT_ALIGN_RIGHT,
                     (ELEC_sys.generators[GEN_EXT].curr_hz < 390 or ELEC_sys.generators[GEN_EXT].curr_hz > 410)
                     and ECAM_ORANGE or ECAM_GREEN)
    
    if ELEC_sys.buses.ac1_powered_by == GEN_EXT then
        draw_open_arrow_up(80,size[2]/2+10,ECAM_GREEN)
        sasl.gl.drawWideLine(80, size[2]/2-40, 80, size[2]/2-5, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(570, size[2]/2-40, 80, size[2]/2-40, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(570, size[2]/2-40, 570, size[2]/2-132, 3, ECAM_GREEN)
        draw_open_arrow_up(570,size[2]/2-132,ECAM_GREEN)
    end
    
    if ELEC_sys.buses.ac2_powered_by == GEN_EXT then
        draw_open_arrow_up(820,size[2]/2+10,ECAM_GREEN)
        sasl.gl.drawWideLine(820, size[2]/2-40, 820, size[2]/2-5, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(570, size[2]/2-40, 820, size[2]/2-40, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(570, size[2]/2-40, 570, size[2]/2-132, 3, ECAM_GREEN)
        draw_open_arrow_up(570,size[2]/2-132,ECAM_GREEN)
    end             
    
end

local function draw_ess_bus_lines()

    -- AC
    if ELEC_sys.buses.ac_ess_powered_by == AC_BUS_1 then
        sasl.gl.drawWideLine(211, size[2]/2+20, 355, size[2]/2+20, 3, ECAM_GREEN)
    end
    if ELEC_sys.buses.ac_ess_powered_by == AC_BUS_2 then
        sasl.gl.drawWideLine(560, size[2]/2+20, 688, size[2]/2+20, 3, ECAM_GREEN)
    end
    if ELEC_sys.buses.ac_ess_powered_by == GEN_EMER then
        draw_open_arrow_down(540, size[2]/2+27, ECAM_GREEN)
        sasl.gl.drawWideLine(540, size[2]/2+42, 540, size[2]/2+82, 3, ECAM_GREEN)
    end
    if ELEC_sys.buses.ac_ess_powered_by == STATIC_INVERTER then
        draw_open_arrow_up(550,size[2]/2-1,ECAM_GREEN)
        sasl.gl.drawWideLine(550, size[2]/2-16, 550, size[2]/2-48, 3, ECAM_GREEN)
    end

    -- DC
    if ELEC_sys.buses.dc_ess_powered_by == TR_ESS then
        sasl.gl.drawWideLine(380, size[2]/2+238, 380, size[2]/2+209, 3, ECAM_GREEN)
        draw_open_arrow_up(380, size[2]/2+209, ECAM_GREEN)  
    elseif ELEC_sys.buses.dc_ess_powered_by == TR_1 then
        sasl.gl.drawWideLine(380, size[2]/2+265, 380, size[2]/2+295, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(380, size[2]/2+295, 138, size[2]/2+295, 3, ECAM_GREEN)
    elseif ELEC_sys.buses.dc_ess_powered_by == BAT_2 then
        sasl.gl.drawWideLine(556, size[2]/2+251, 650, size[2]/2+251, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(650, size[2]/2+251, 650, size[2]/2+297, 3, ECAM_GREEN)
        draw_open_arrow_down(650, size[2]/2+297, ECAM_GREEN)    
    end

end

local function draw_shed_legends()

    if get(DC_shed_ess_pwrd) == 0 then
        sasl.gl.drawText(B612MONO_regular, 450, size[2]/2+213,
                         "SHED", 24, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE )
    
    end
    if get(AC_ess_shed_pwrd) == 0 then
        sasl.gl.drawText(B612MONO_regular, 450, size[2]/2-28, 
                         "SHED", 24, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE )
    end
    
end

local function draw_bat_dc_bus_lines()

    if ELEC_sys.buses.dc_bat_bus_powered_by == TR_1 then
        sasl.gl.drawWideLine(380, size[2]/2+359, 380, size[2]/2+295, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(380, size[2]/2+295, 138, size[2]/2+295, 3, ECAM_GREEN)
    elseif ELEC_sys.buses.dc_bat_bus_powered_by == TR_2 then
        sasl.gl.drawWideLine(530, size[2]/2+359, 530, size[2]/2+295, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(530, size[2]/2+295, 761, size[2]/2+295, 3, ECAM_GREEN)
    end
end

local function draw_idg_legends(i,x)

    local IDG_color = (ELEC_sys.generators[i].idg_status or get(ELEC_sys.generators[i].drs.idg_fail_2) == 1 or
    get(ELEC_sys.generators[i].drs.idg_fail_1) == 1) and ECAM_WHITE or ECAM_ORANGE
    sasl.gl.drawText(B612MONO_regular, x, size[2]/2-260, "IDG" .. i, 26, false, false, TEXT_ALIGN_LEFT, IDG_color )


    
    if not ELEC_sys.generators[i].idg_status then
        sasl.gl.drawText(B612MONO_regular, x, size[2]/2-300, "DISC", 26, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE )
    elseif get(ELEC_sys.generators[i].drs.idg_fail_2) == 1 then
        sasl.gl.drawText(B612MONO_regular, x, size[2]/2-300, "LO PR", 26, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    end

    sasl.gl.drawText(B612MONO_regular, x+150-200*(i==2 and 1 or 0), 
    size[2]/2-260, "°C", 26, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    local temp_color = ECAM_GREEN
    local temp_value = get(ELEC_sys.generators[i].drs.idg_temp)
    if temp_value > 185 then
        temp_color = ECAM_ORANGE
    elseif temp_value > 147 then
        if math.floor(get(TIME)%2) == 1 then
            temp_color = ECAM_HIGH_GREEN
        end
    end
    sasl.gl.drawText(B612MONO_regular, x+150-200*(i==2 and 1 or 0), 
    size[2]/2-260, math.floor(temp_value), 26, false, false, TEXT_ALIGN_RIGHT, temp_color)


end

function draw_elec_page()

    update_elec_parameters()
    update_draw_datarefs()
    
    draw_battery(1, 180)
    draw_battery(2, 642)
    
    draw_tr(1, 30)
    draw_tr(2, 770)
    draw_ess_tr()

    draw_apu_gen()
    draw_gen(110, 1)
    draw_gen(850, 2)

    draw_stat_inv()
    draw_emer_gen()
    draw_ext_pwr()

    draw_shed_legends()
    draw_ess_bus_lines()
    draw_bat_dc_bus_lines()
    
    draw_idg_legends(1,50)
    draw_idg_legends(2,790)
    
end

local last_time_update = 0

function update_elec_parameters()
    if get(TIME) - last_time_update > UPDATE_PERIOD then
        last_time_update = get(TIME)
        
        loads.gen[1] = math.floor(-ELEC_sys.generators[1].curr_amps/GEN_ENGINE_RATED_CURR*100+0.5) 
        loads.gen[2] = math.floor(-ELEC_sys.generators[2].curr_amps/GEN_ENGINE_RATED_CURR*100+0.5) 
        loads.gen[3] = math.floor(-ELEC_sys.generators[3].curr_amps/GEN_ENGINE_RATED_CURR*100+0.5) 
        
    end
end


