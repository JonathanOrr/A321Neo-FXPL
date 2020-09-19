size = {900, 900}
include('constants.lua')

local GEN_ENGINE_RATED_CURR = 261    -- Maximum current provided by the engine gen (this is not enforced but used to compute the load %)
local GEN_ENGINE_APU_CURR   = 261    -- Maximum current provided by the APU gen (this is not enforced but used to compute the load %)

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

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

   if ELEC_sys.generators[5].source_status == false then
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
    
    if ELEC_sys.batteries[i].curr_amps < -1 then
        sasl.gl.drawWideLine(x_start, y, x_end, y, 3, ECAM_AMBER)
        if i == 1 then
            sasl.gl.drawTriangle (x_end-15, y+10 , x_end-15, y-10, x_end+1, y, ECAM_AMBER)
        else
            sasl.gl.drawTriangle (x_start+15, y+10 , x_start+15, y-10, x_start-1, y, ECAM_AMBER)
        end
    else
        sasl.gl.drawWideLine(x_start, y, x_end, y, 3, ECAM_GREEN)
    end
    
    if ELEC_sys.batteries[i].curr_amps > 1 then
        if i == 1 then
            sasl.gl.drawTriangle (x_start+15, y+10 , x_start+15, y-10, x_start-1, y, ECAM_GREEN)
        else
            sasl.gl.drawTriangle (x_end-15, y+10 , x_end-15, y-10, x_end+1, y, ECAM_GREEN)
        end
    end 
end

local function draw_battery(i, x)
    local failed_bat = (i == 1 and get(FAILURE_ELEC_battery_1) == 1) or (i == 2 and get(FAILURE_ELEC_battery_2) == 1)
    local bat_1_status = (ELEC_sys.batteries[i].curr_voltage < 25 or ELEC_sys.batteries[i].curr_voltage > 31 or
                         ELEC_sys.batteries[i].curr_amps < -5 or failed_bat) and ELEC_sys.batteries[i].switch_status

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
                         math.floor(-ELEC_sys.batteries[i].curr_amps+0.5), 26, false, false, 
                         TEXT_ALIGN_RIGHT,
                         ELEC_sys.batteries[i].curr_amps < -5 and ECAM_ORANGE or ECAM_GREEN)
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
                     math.floor(-ELEC_sys.trs[i].curr_out_amps+0.5), 28, false, false, 
                     TEXT_ALIGN_RIGHT,
                     ELEC_sys.trs[i].curr_out_amps <= 5 and ECAM_ORANGE or ECAM_GREEN)
    
    if ELEC_sys.trs[i].curr_voltage >= 25 then
        sasl.gl.drawWideLine(x+55, size[2]/2+201, x+55, size[2]/2+280, 3, ECAM_GREEN)
        sasl.gl.drawWideLine(x+55, size[2]/2+92, x+55, size[2]/2+38, 3, ECAM_GREEN)
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
    
    
end

local function draw_apu_gen()
    if get(Ecam_elec_apu_gen_status) <= 1 then
        return  -- Nothing to do
    end

    sasl.gl.drawText(B612MONO_regular, 335, size[2]/2-182, 
                     math.floor(-ELEC_sys.generators[3].curr_amps/GEN_ENGINE_APU_CURR*100+0.5), 28, false, false,
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
                     math.floor(-ELEC_sys.generators[i].curr_amps/GEN_ENGINE_RATED_CURR*100+0.5), 28, false, false,
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
    
end

function draw_elec_page()

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


end
