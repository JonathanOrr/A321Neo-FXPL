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

    if ENG.dyn[eng].n1_mode == 1 then
        curr_max = get(Eng_N1_max_detent_toga)
        prev_max = get(Eng_N1_max_detent_mct)
        N1_target =  Math_rescale(0.825, prev_max, 1, curr_max, thr)
    elseif ENG.dyn[eng].n1_mode == 2 or ENG.dyn[eng].n1_mode == 7 then -- MCT or SOFT GA
        curr_max = get(Eng_N1_max_detent_mct)
        prev_max = get(Eng_N1_max_detent_clb)
        N1_target =  Math_rescale(0.675, prev_max, 0.825, curr_max, thr)
    elseif ENG.dyn[eng].n1_mode == 6 then -- FLEX
        curr_max = get(Eng_N1_max_detent_flex)
        prev_max = get(Eng_N1_max_detent_clb)
        N1_target =  Math_rescale(0.675, prev_max, 0.825, curr_max, thr)
    elseif ENG.dyn[eng].n1_mode == 3 then -- CLB
        curr_max = get(Eng_N1_max_detent_clb)
        prev_max = ENG.dyn[eng].n1_idle
        N1_target =  Math_rescale(0, prev_max, 0.675, curr_max, thr)
    elseif ENG.dyn[eng].n1_mode == 4 then -- IDLE
        -- we have to take bleed/pack config into consideration which is eng specific in IDLE
        curr_max = ENG.dyn[eng].n1_idle
        prev_max = ENG.dyn[eng].n1_idle
        N1_target = ENG.dyn[eng].n1_idle
    elseif ENG.dyn[eng].n1_mode == 5 then -- MREV
        curr_max = get(Eng_N1_max_detent_toga) * REVERSE_PERFORMANCE
        prev_max = ENG.dyn[eng].n1_idle
        N1_target =  Math_rescale(0, prev_max, 1, curr_max, thr)
    end

    set(Eng_N1_max, curr_max)   -- This is used in EWD
    return N1_target
end


local function cap_integral_limit(n1, int_sum)
    local up_limit  =   1
    local bottom_limit  =   0

    -- plot BEFORE change these values
    bottom_limit = n1^2/9000
    bottom_limit = math.max(0.055, bottom_limit)
    up_limit = n1^2/6500+0.04
    up_limit = math.max(0.025, up_limit)
    int_sum = math.min(int_sum, up_limit)
    int_sum = math.max(int_sum, bottom_limit)
    return int_sum
end

function N1_control(L_PID_array, R_PID_array, reversers)

    -- Compute the target based on the throttle position
    local N1_target_L = get_N1_target(get(Cockpit_throttle_lever_L), 1)
    local N1_target_R = get_N1_target(get(Cockpit_throttle_lever_R), 2)

    -- TODO increase of blue circle legs behind actual N1 value indicated by gauge acc CAE FFS

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


    local L_error = (N1_target_L - ENG.dyn[1].n1)
    local controlled_T_L = SSS_PID_BP_LIM(L_PID_array, L_error)
    L_PID_array.Actual_output = controlled_T_L
    L_PID_array.Integral_sum = cap_integral_limit(ENG.dyn[1].n1, L_PID_array.Integral_sum)

    if ENG.dyn[1].is_avail then
        set(Override_eng_1_lever, controlled_T_L)
    else
        L_PID_array.Actual_output = 0
        L_PID_array.Integral_sum  = 0 -- Avoid integral bump on start
        set(Override_eng_1_lever, 0)
    end

    local R_error = (N1_target_R - ENG.dyn[2].n1)
    local controlled_T_R = SSS_PID_BP_LIM(R_PID_array, R_error)
    R_PID_array.Actual_output = controlled_T_R
    R_PID_array.Integral_sum = cap_integral_limit(ENG.dyn[2].n1, R_PID_array.Integral_sum)

    if ENG.dyn[2].is_avail then
        set(Override_eng_2_lever, controlled_T_R)
    else
        R_PID_array.Actual_output = 0
        R_PID_array.Integral_sum  = 0 -- Avoid integral bump on start
        set(Override_eng_2_lever, 0)
    end

end
