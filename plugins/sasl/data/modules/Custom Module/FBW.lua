--PID and PD array
--array format PD_array = {P_gain, D_gain, Current_error, Min_error, Max_error, Error_offset}
--array format PID_array = {P_gain, I_gain, D_gain, I_delay, Integral, Current_error, Min_error, Max_error, Error_offset}
local A32nx_FBW_roll_left =  {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_right = {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_left_no_stick =  {P_gain = 1, D_gain = 25, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_right_no_stick = {P_gain = 1, D_gain = 25, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_pitch_up =   {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -10, Max_error = 10, Error_offset = 0}
local A32nx_FBW_pitch_down = {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -10, Max_error = 10, Error_offset = 0}
local A32nx_FBW_G_command_up = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -10, Max_error = 10, Error_offset = 0}
local A32nx_FBW_G_command_down = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -10, Max_error = 10, Error_offset = 0}

local A32nx_FBW_elev_trim = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -35, Max_error = 35, Error_offset = 0}

--PID funtions--
function FBW_PD(pd_array, error)
    local last_error = pd_array.Current_error
	pd_array.Current_error = error + pd_array.Error_offset

	--Proportional--
	local correction = pd_array.Current_error * pd_array.P_gain

	--derivative--
	correction = correction + (pd_array.Current_error - last_error) * pd_array.D_gain

	--limit and rescale output range--
	correction = Math_clamp(correction, pd_array.Min_error, pd_array.Max_error) / pd_array.Max_error

	return correction
end

function FBW_PID(pid_array, error)
    local last_error = pid_array.Current_error
	pid_array.Current_error = error + pid_array.Error_offset

	--Proportional--
	local correction = pid_array.Current_error * pid_array.P_gain

	--integral--
	pid_array.Integral = (pid_array.Integral * (pid_array.I_delay - 1) + pid_array.Current_error) / pid_array.I_delay

	--clamping the integral to minimise the delay
	pid_array.Integral = Math_clamp(pid_array.Integral, pid_array.Min_error, pid_array.Max_error)

	correction = correction + pid_array.Integral * pid_array.I_gain

	--derivative--
	correction = correction + (pid_array.Current_error - last_error) * pid_array.D_gain

	--limit and rescale output range--
	correction = Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error

	return correction
end

--[[establishing the FBW laws:
    NORMAL LAW: 30 UP, 15 DOWN, stick active: 67 LEFT & RIGHT, not active 30 LEFT & RIGHT, 14 degrees alpha, OVERSPEED protection, roll rate of 30, 2.5G to -1G in normal flight,2G to 0G if flaps down envelop, always CWS
    ALT 1: NORMAL LAW, but without vertical constraints
    ALT 2: NORMAL LAW, but without horizontal constraints, and can without both constraints but still has CWS
    DIRECT: NO constraints, NO CWS
]]

--variables--

--sim datarefs
local flaps_handle_ratio = globalProperty("sim/cockpit2/controls/flap_ratio")
--a32nx datarefs

function update()
    set(Override_artstab, 1)

    if get(flaps_handle_ratio) < 0.1 then
        if get(Pitch) > 0.1 then
            set(G_load_command, 1.5 * get(Pitch) + 1)
        elseif get(Pitch) < -0.1 then
            set(G_load_command, 1.5 * get(Pitch) + 1)
        else
            set(G_load_command, 1)
        end
    else
        if get(Pitch) > 0.1 then
            set(G_load_command, get(Pitch) + 1)
        elseif get(Pitch) < -0.1 then
            set(G_load_command, get(Pitch) + 1)
        else
            set(G_load_command, 1)
        end
    end

    --15 degrees dive and command G load
    set(Pitch_d_lim, FBW_PD(A32nx_FBW_pitch_down, -15 - get(Flightmodel_pitch)))
    --command downwards G command
    set(Pitch_G_down, FBW_PID(A32nx_FBW_G_command_down, get(G_load_command) - get(Total_vertical_g_load)))
    --30 degrees climb and command G load
    set(Pitch_u_lim, FBW_PD(A32nx_FBW_pitch_up,  30 - get(Flightmodel_pitch)))
    --command upwards G command
    set(Pitch_G_up, FBW_PID(A32nx_FBW_G_command_up,  - get(G_load_command) - get(Total_vertical_g_load)))

    if get(Roll) + get(Servo_roll) > 0.1 or get(Roll) + get(Servo_roll) < -0.1 then
        --67 degrees roll left
        set(Roll_l_lim, FBW_PD(A32nx_FBW_roll_left, (-30 - get(Roll_rate)) + (- 67 - get(Flightmodel_roll))))
        --67 degrees roll right
        set(Roll_r_lim, FBW_PD(A32nx_FBW_roll_right, (30 - get(Roll_rate)) + (67 - get(Flightmodel_roll))))
    else
        --30 degrees roll left
        set(Roll_l_lim, FBW_PD(A32nx_FBW_roll_left_no_stick,  - 30 - get(Flightmodel_roll)))
        --30 degrees roll right
        set(Roll_r_lim, FBW_PD(A32nx_FBW_roll_right_no_stick,   30 - get(Flightmodel_roll)))
    end

    if get(FBW_on) == 1 then
        set(Roll_artstab, get(Roll_l_lim) + get(Roll_r_lim))
        --if get(Pitch) > 0.1 or get(Pitch) < -0.1 then
            set(Pitch_artstab, (get(Pitch_d_lim) + get(Pitch_u_lim)) + (get(Pitch_G_down) + get(Pitch_G_up)))
        --else
        --    set(Pitch_artstab, (get(Pitch_d_lim) + get(Pitch_u_lim)))
        --end

        --set(Elev_trim_ratio, FBW_PD(A32nx_FBW_elev_trim, 0 - get(Flightmodel_pitch)))
        --set(Horizontal_stabilizer_pitch, FBW_PD(A32nx_FBW_elev_trim, 0 + get(Flightmodel_pitch)))
    else
        set(Roll_artstab, 0)
        set(Pitch_artstab, 0)
    end
end
