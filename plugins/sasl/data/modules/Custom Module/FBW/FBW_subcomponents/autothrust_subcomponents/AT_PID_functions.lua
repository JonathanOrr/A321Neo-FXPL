local function get_N1_target(thr_position, eng)

    local REVERSE_PERFORMANCE = 0.7

    local curr_max  = 0
    local prev_max = 0
    local thr = math.abs(thr_position)
    local N1_target = 0
    
    -- So, the throttle is linear but in each region has a different coefficient:
    -- The throttle is linear between 0 and CLB, so 0.54 means 54%
    -- then, in the MCT region the rate depends on the CLB MAX N1 and MCT MAX N1,
    -- then, in the TOGA  region the rate depends on the MCT MAX N1 and TOGA MAX N1.

    if get(Eng_N1_mode, eng) == 1 then
        curr_max = get(Eng_N1_max_detent_toga)
        prev_max = get(Eng_N1_max_detent_mct)
        N1_target =  Math_rescale(0.825, prev_max, 1, curr_max, thr)
    elseif get(Eng_N1_mode, eng) == 2 or get(Eng_N1_mode, eng) == 7 then -- MCT or SOFT GA
        curr_max = get(Eng_N1_max_detent_mct)
        prev_max = get(Eng_N1_max_detent_clb)
        N1_target =  Math_rescale(0.675, prev_max, 0.825, curr_max, thr)
    elseif get(Eng_N1_mode, eng) == 6 then -- FLEX
        curr_max = get(Eng_N1_max_detent_flex)
        prev_max = get(Eng_N1_max_detent_clb)
        N1_target =  Math_rescale(0.675, prev_max, 0.825, curr_max, thr)
    elseif get(Eng_N1_mode, eng) == 3 then -- CLB
        curr_max = get(Eng_N1_max_detent_clb)
        prev_max = get(Eng_N1_idle)
        N1_target =  Math_rescale(0, prev_max, 0.675, curr_max, thr)
    elseif get(Eng_N1_mode, eng) == 4 then -- IDLE
        curr_max = get(Eng_N1_idle)
        prev_max = get(Eng_N1_idle)
        N1_target = get(Eng_N1_idle)
    elseif get(Eng_N1_mode, eng) == 5 then -- MREV
        curr_max = get(Eng_N1_max_detent_toga) * REVERSE_PERFORMANCE
        prev_max = get(Eng_N1_idle)
        N1_target =  Math_rescale(0, prev_max, 1, curr_max, thr)
    end

    set(Eng_N1_max, curr_max)   -- This is used in EWD
    return N1_target
end

function N1_control(L_PID_array, R_PID_array, reversers)

    -- Compute the target based on the throttle position
    local N1_target_L = get_N1_target(get(Cockpit_throttle_lever_L), 1)
    local N1_target_R = get_N1_target(get(Cockpit_throttle_lever_R), 2)

    set(Throttle_blue_dot, N1_target_L, 1)
    set(Throttle_blue_dot, N1_target_R, 2)

    if get(ATHR_is_controlling) == 1 then
        N1_target_L = math.min(N1_target_L, get(ATHR_desired_N1, 1))
        N1_target_R = math.min(N1_target_R, get(ATHR_desired_N1, 2))
    end
    
    if get(ATHR_is_overriding) == 1 then
        N1_target_L = get(ATHR_desired_N1, 1)
        N1_target_R = get(ATHR_desired_N1, 2)
    end


    local sigma = get(Weather_Sigma)
    local air_density_coeff = 1
    if sigma > 1 then
        air_density_coeff = (sigma-1) ^ 2.9 + 1
    else
        air_density_coeff = -(-sigma+1) ^ 2.9 + 1
    end

    local L_error = (N1_target_L - get(Eng_1_N1)) * air_density_coeff
    local controlled_T_L = SSS_PID_BP_LIM(L_PID_array, L_error)
    
    if get(Engine_1_avail) == 1 then
        set(Override_eng_1_lever, controlled_T_L)
    else
        L_PID_array.Actual_output = 0
        set(Override_eng_1_lever, 0)
    end

    local R_error = (N1_target_R - get(Eng_2_N1)) * air_density_coeff
    local controlled_T_R = SSS_PID_BP_LIM(R_PID_array, R_error)
    
    if get(Engine_2_avail) == 1 then
        set(Override_eng_2_lever, controlled_T_R)
    else
        R_PID_array.Actual_output = 0
        set(Override_eng_2_lever, 0)
    end

end
