SSS_FADEC_L_N1 = {name = "FADEC L N1", P_gain = 1, I_gain = 1, D_gain = 0.18, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Current_error = 0, Min_error = -100, Max_error = 100}
SSS_FADEC_R_N1 = {name = "FADEC R N1", P_gain = 1, I_gain = 1, D_gain = 0.18, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Current_error = 0, Min_error = -100, Max_error = 100}

function FADEC_N1_PID(pid_array, Set_Point, PV)
    local correction = 0
    local last_PV = PV

    if get(DELTA_TIME) ~= 0 then

        pid_array.Current_error = Set_Point - PV

        --Proportional--
        pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral_sum + (pid_array.Current_error * get(DELTA_TIME)), pid_array.Min_error * (1 / pid_array.I_gain), pid_array.Max_error * (1 / pid_array.I_gain))
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * pid_array.I_gain, pid_array.Min_error * (1 / pid_array.I_gain), pid_array.Max_error * (1 / pid_array.I_gain))

        --derivative--
        pid_array.Derivative = ((PV - last_PV) / get(DELTA_TIME)) * pid_array.D_gain

        --sigma
        correction = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        correction = ((Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error) + 1) / 2

    end

    return correction

end

function N1_control()
    if get(Engine_1_avail) == 1 then
        set(Override_eng_1_lever, FADEC_N1_PID(SSS_FADEC_L_N1, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(L_sim_throttle))), get(Eng_1_N1)))
    else
        set(Override_eng_1_lever, 0)
    end

    if get(Engine_2_avail) == 1 then
        set(Override_eng_2_lever, FADEC_N1_PID(SSS_FADEC_R_N1, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(R_sim_throttle))), get(Eng_2_N1)))
    else
        set(Override_eng_2_lever, 0)
    end

    set(L_throttle_blue_dot, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(L_sim_throttle))))
    set(R_throttle_blue_dot, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(R_sim_throttle))))
end