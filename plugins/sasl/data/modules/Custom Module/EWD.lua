position= {2279,539,900,900}
size = {900, 900}

include('constants.lua')

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local last_params_update = 0

local params = {
    eng1_n1 = 0,
    eng2_n1 = 0,
    eng1_n2 = 0,
    eng2_n2 = 0,
    eng1_egt = 0,
    eng2_egt = 0,
    eng1_ff = 0,
    eng2_ff = 0,
    last_update = 0
}

local eng_idle_start = 0  -- When the engines went to IDLE

local match_msg_colors = {}
match_msg_colors[0] = ECAM_WHITE
match_msg_colors[1] = ECAM_RED
match_msg_colors[2] = ECAM_MAGENTA
match_msg_colors[3] = ECAM_ORANGE
match_msg_colors[4] = ECAM_GREEN
match_msg_colors[5] = ECAM_WHITE
match_msg_colors[6] = ECAM_BLUE
match_msg_colors[7] = ECAM_GREEN -- Blinking

local time_blinking = sasl.createTimer()
sasl.startTimer(time_blinking)

local function update_reverse_indication()
    -- ENG1 Reverse
    if get(Eng_1_reverser_deployment) > 0.01 then
        if get(EWD_flight_phase) >= 5 and get(EWD_flight_phase) <= 7 then
            -- Blink
            set(EWD_engine_1_rev_ind, (math.floor(get(TIME)*2) / 10 % 2) == 1 and 2 or 1)
        elseif get(Eng_1_reverser_deployment) > 0.98 then
            set(EWD_engine_1_rev_ind, 3)    -- Green
        else
            set(EWD_engine_1_rev_ind, 2)    -- Amber
        end
    else
        set(EWD_engine_1_rev_ind, 0)    -- No reverse indication
    end

    -- ENG2 Reverse    
    if get(Eng_2_reverser_deployment) > 0.01 then
        if get(EWD_flight_phase) >= 5 and get(EWD_flight_phase) <= 7 then
            -- Blink
            set(EWD_engine_2_rev_ind, (math.floor(get(TIME)*2) % 2) == 1 and 2 or 1)
        elseif get(Eng_2_reverser_deployment) > 0.98 then
            set(EWD_engine_2_rev_ind, 3)    -- Green
        else
            set(EWD_engine_2_rev_ind, 2)    -- Amber
        end
    else
        set(EWD_engine_2_rev_ind, 0)    -- No reverse indication
    end
end

function update()

    -- Update the parameter every PARAM_DELAY seconds
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_n1 = get(Eng_1_N1)
        params.eng2_n1 = get(Eng_2_N1)
        params.eng1_n2 = get(Eng_1_N2)
        params.eng2_n2 = get(Eng_2_N2)
        if params.eng1_n1 < 5 then params.eng1_n1 = 0 end
        if params.eng2_n1 < 5 then params.eng2_n1 = 0 end
        
        params.eng1_egt = math.floor(get(Eng_1_EGT_c))
        params.eng2_egt = math.floor(get(Eng_2_EGT_c))

        params.eng1_ff = math.floor(get(Eng_1_FF_kgs)*360)*10
        params.eng2_ff = math.floor(get(Eng_2_FF_kgs)*360)*10 

        
        params.last_update = get(TIME)
    end
    
    if params.eng1_n1 < get(Eng_N1_idle) + 2 and params.eng2_n1 < get(Eng_N1_idle) + 2 and get(Any_wheel_on_ground) == 0 then
        if eng_idle_start == 0 then
            eng_idle_start = get(TIME)
        end
    else
        eng_idle_start = 0
    end
    
    update_reverse_indication()

end


function draw_extra_indication()

    if get(EWD_flight_phase) == PHASE_1ST_ENG_ON and (get(Pack_L) == 1 or get(Pack_R) == 1) then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+70, size[2]-30, "PACKS", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end
end


local function draw_engines()

    -- N2 background box --
    if get(Engine_1_master_switch) == 1 and get(Engine_1_avail) == 0 then
          sasl.gl.drawRectangle(size[1]/2-210, size[2]/2+70, 85, 32, {0.2,0.2,0.2})
    end
    if get(Engine_2_master_switch) == 1 and get(Engine_2_avail) == 0 then
          sasl.gl.drawRectangle(size[1]/2+115, size[2]/2+70, 85, 32, {0.2,0.2,0.2})
    end

    --N1--    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-115, size[2]/2+280, math.floor(params.eng1_n1) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-100, size[2]/2+280, math.floor((params.eng1_n1%1)*10)  , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, size[2]/2+280, math.floor(params.eng2_n1) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2+280, math.floor((params.eng2_n1%1)*10)  , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    --EGT--
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-140, size[2]/2+150, params.eng1_egt, 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+210, size[2]/2+150, params.eng2_egt, 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    --N2--
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-145, size[2]/2+75, math.floor(params.eng1_n2) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-130, size[2]/2+75, math.floor((params.eng1_n2%1)*10) , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+180, size[2]/2+75, math.floor(params.eng2_n2) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+195, size[2]/2+75, math.floor((params.eng2_n2%1)*10) , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    
    --FF--
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-130, size[2]/2+3, params.eng1_ff, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+195, size[2]/2+3, params.eng2_ff, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)



    -- AVAIL box --
    if get(EWD_engine_avail_ind_1_start) ~= 0 and get(TIME) - get(EWD_engine_avail_ind_1_start) < 10 then
        set(EWD_engine_avail_ind_1, 1)
    else
        set(EWD_engine_avail_ind_1, 0)
    end

    if get(EWD_engine_avail_ind_2_start) ~= 0 and get(TIME) - get(EWD_engine_avail_ind_2_start) < 10 then
        set(EWD_engine_avail_ind_2, 1)
    else
        set(EWD_engine_avail_ind_2, 0)
    end
    
    -- IDLE indication
    if eng_idle_start ~= 0 then
        color = ECAM_GREEN
        if get(TIME) - eng_idle_start < 10 then
            if (math.floor(get(TIME)*2)) % 2 == 1 then -- Blinking
                color = ECAM_HIGH_GREEN
            end
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+380, "IDLE" , 30, false, false, TEXT_ALIGN_CENTER, color)        
    end
end

local function draw_left_memo()
    local distance = 38

    for i=0,6 do
        if get(EWD_left_memo_group_colors[i]) > 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-430, size[2]/2-200-distance*i, get(EWD_left_memo_group[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_left_memo_group_colors[i])])
            
            -- Print the underline
            width, height = sasl.gl.measureText(Font_AirbusDUL, get(EWD_left_memo_group[i]), 30, false, false)
            sasl.gl.drawWideLine(size[1]/2-430 + 1, size[2]/2-200-distance*i - 5, size[1]/2-430 + width + 2, size[2]/2-200-distance*i - 5, 3, match_msg_colors[get(EWD_left_memo_group_colors[i])])
        end

        if get(EWD_left_memo_colors[i]) > 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-430, size[2]/2-200-distance*i, get(EWD_left_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_left_memo_colors[i])])
        end
    end

end

local function draw_right_memo()
    local distance = 38

    for i=0,6 do
        if get(EWD_right_memo_colors[i]) > 0 then
            if get(EWD_right_memo_colors[i]) ~= 7 or get(TIME) % 2 > 1 then -- If color is COL_INDICATION_BLINKING we blink for 1 second every 2 seconds.
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2+160, size[2]/2-200-distance*i, get(EWD_right_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_right_memo_colors[i])])
            else
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2+160, size[2]/2-200-distance*i, get(EWD_right_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, ECAM_HIGH_GREEN)            
            end
        end
    end
end

local function draw_extras()

    -- STS BOX
    if get(EWD_box_sts) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+88, size[2]/2-440, "STS", 30, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-442, 62, 28 , ECAM_WHITE)
    end 

    -- ADV BOX
    if get(EWD_box_adv) == 1 then
        local color = ECAM_WHITE
        
        -- Blinking the ADV box with a period of 2 seconds (1 second WHITE, 1 second gray)
        if math.floor(sasl.getElapsedSeconds(time_blinking)) % 2 == 0 then
            color = ECAM_HIGH_GREY
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+88, size[2]/2-165, "ADV", 30, false, false, TEXT_ALIGN_LEFT, color)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-167, 62, 28 , color)
    end 
    
    -- overflow arrow (this is not visible if STS box is visible)
    if get(EWD_box_sts) == 0 and get(EWD_arrow_overflow) == 1 then
        sasl.gl.drawWideLine ( size[1]/2+118, size[2]/2-410 , size[1]/2+118 , size[2]/2-425 , 5 , ECAM_GREEN )
        sasl.gl.drawTriangle ( size[1]/2+106, size[2]/2-425 , size[1]/2+119 , size[2]/2-446 , size[1]/2+130, size[2]/2-425 , ECAM_GREEN )
    end 
end

local function draw_fuel_stuffs()
    local fuel_on_board = math.floor(get(FOB))
    
    -- Check ECAM_fuel.lua to understand the following computation
    local not_all_fuel_available = (math.floor(get(Fuel_quantity[0])) > 0
                                    and (not Fuel_sys.tank_pump_and_xfr[5].status)
                                    and (not Fuel_sys.tank_pump_and_xfr[5].status) ) 
                                        or (get(FAILURE_FUEL, 7) == 1) or (get(FAILURE_FUEL, 8) == 1)
                                        
    sasl.gl.drawText(Font_AirbusDUL, 240, size[2]/2-120, fuel_on_board, 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    if not_all_fuel_available then
        sasl.gl.drawWideLine(120, size[2]/2-125, 250, size[2]/2-125, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(120, size[2]/2-125, 120, size[2]/2-100, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(250, size[2]/2-125, 250, size[2]/2-100, 3 , ECAM_ORANGE)
    end
end

function draw()

    if get(AC_ess_bus_pwrd) == 0 then   -- TODO This should be fixed when screens move around
        return -- Bus is not powered on, this component cannot work
    end
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 0.43, 0.43)   -- 50W (just hypothesis)

    draw_engines()
    draw_left_memo()
    draw_right_memo()
    draw_extras()
    draw_fuel_stuffs()
    draw_extra_indication()
end

