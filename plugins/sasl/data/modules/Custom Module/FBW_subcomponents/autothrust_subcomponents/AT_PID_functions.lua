function FADEC_N1_PID(pid_array, Set_Point, PV)
    local last_PV = pid_array.PV

    if get(DELTA_TIME) ~= 0 then

        pid_array.PV = PV

        --Proportional--
        pid_array.Proportional = (Set_Point - PV) * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral_sum + ((Set_Point - PV) * get(DELTA_TIME)), pid_array.Error_margin * pid_array.Min_out * pid_array.I_time, pid_array.Error_margin * pid_array.Max_out * pid_array.I_time)
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * 1 / pid_array.I_time, pid_array.Error_margin * pid_array.Min_out, pid_array.Error_margin * pid_array.Max_out)

        --derivative--
        pid_array.Derivative = ((last_PV - pid_array.PV) / get(DELTA_TIME)) * pid_array.D_gain

        --sigma
        pid_array.Output = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        pid_array.Output = Math_clamp(pid_array.Output, pid_array.Error_margin * pid_array.Min_out, pid_array.Error_margin * pid_array.Max_out) / pid_array.Error_margin

    end

    return pid_array.Output

end

local function get_N1_target()

    local REVERSE_PERFORMANCE = 0.7

    local curr_max  = 0
    local prev_max = 0
    local thr = math.abs(get(L_sim_throttle))
    local N1_target = 0
    
    -- So, the throttle is linear but in each region has a different coefficient:
    -- The throttle is linear between 0 and CLB, so 0.54 means 54%
    -- then, in the MCT region the rate depends on the CLB MAX N1 and MCT MAX N1,
    -- then, in the TOGA  region the rate depends on the MCT MAX N1 and TOGA MAX N1.
    
    if get(Eng_N1_mode) == 1 then
        curr_max = get(Eng_N1_max_detent_toga)        
        prev_max = get(Eng_N1_max_detent_mct)
        N1_target =  Math_rescale(0.825, prev_max, 1, curr_max, thr)        
    elseif get(Eng_N1_mode) == 2 or get(Eng_N1_mode) == 6 or get(Eng_N1_mode) == 7 then -- MCT or FLEX or SOFT GA
        curr_max = get(Eng_N1_max_detent_mct)
        prev_max = get(Eng_N1_max_detent_clb)
        N1_target =  Math_rescale(0.675, prev_max, 0.825, curr_max, thr)        
    elseif get(Eng_N1_mode) == 3 then -- CLB
        curr_max = get(Eng_N1_max_detent_clb)
        prev_max = get(Eng_N1_idle)
        N1_target =  Math_rescale(0, prev_max, 0.675, curr_max, thr)        
    elseif get(Eng_N1_mode) == 4 then -- IDLE
        curr_max = get(Eng_N1_idle)
        prev_max = get(Eng_N1_idle)
        N1_target = get(Eng_N1_idle)
    elseif get(Eng_N1_mode) == 5 then -- MREV
        curr_max = get(Eng_N1_max_detent_toga) * REVERSE_PERFORMANCE
        prev_max = get(Eng_N1_idle)
        N1_target =  Math_rescale(0, prev_max, 1, curr_max, thr)        
    end  

    set(Eng_N1_max, curr_max)   -- This is used in EWD
    return N1_target
end

function N1_control(L_PID_array, R_PID_array, reversers)

    N1_target = get_N1_target()

    if get(Engine_1_avail) == 1 then
        set(Override_eng_1_lever, FADEC_N1_PID(L_PID_array, N1_target, get(Eng_1_N1)))
    else
        set(Override_eng_1_lever, 0)
    end

    if get(Engine_2_avail) == 1 then
        set(Override_eng_2_lever, FADEC_N1_PID(R_PID_array, N1_target, get(Eng_2_N1)))
    else
        set(Override_eng_2_lever, 0)
    end

    -- TODO: Blue dot is autopilot position not the manual throttle
    set(L_throttle_blue_dot, N1_target)
    set(R_throttle_blue_dot, N1_target)
end
