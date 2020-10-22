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

function N1_control(L_PID_array, R_PID_array, reversers)
    if get(Engine_1_avail) == 1 then
        set(Override_eng_1_lever, FADEC_N1_PID(L_PID_array, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(L_sim_throttle))), get(Eng_1_N1)))
    else
        set(Override_eng_1_lever, 0)
    end

    if get(Engine_2_avail) == 1 then
        set(Override_eng_2_lever, FADEC_N1_PID(R_PID_array, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(R_sim_throttle))), get(Eng_2_N1)))
    else
        set(Override_eng_2_lever, 0)
    end

    set(L_throttle_blue_dot, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(L_sim_throttle))))
    set(R_throttle_blue_dot, Math_lerp(get(Eng_N1_idle), 101, math.abs(get(R_sim_throttle))))
end