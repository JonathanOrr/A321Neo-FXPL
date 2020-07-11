--PID and PD array
--array format PD_array = {P_gain, D_gain, Current_error, Min_error, Max_error, Error_offset}
--array format PID_array = {P_gain, I_gain, D_gain, I_delay, Integral, Current_error, Min_error, Max_error, Error_offset}
local A32nx_FBW_roll_left =  {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_right = {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_left_no_stick =  {P_gain = 1, D_gain = 25, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_roll_right_no_stick = {P_gain = 1, D_gain = 25, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_pitch_up =   {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_pitch_down = {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_pitch_rate_up =   {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -5.5, Max_error = 5.5, Error_offset = 0}
local A32nx_FBW_pitch_rate_down =   {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -5.5, Max_error = 5.5, Error_offset = 0}
local A32nx_FBW_roll_rate_command = {P_gain = 10, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_1G_command = {P_gain = 1, I_gain = 1, D_gain = 1.5, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -0.25, Max_error = 0.25, Error_offset = 0}
local A32nx_FBW_G_command = {P_gain = 1.5, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -2.5, Max_error = 2.5, Error_offset = 0}
local A32nx_FBW_AOA_protection = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_MAX_spd_protection = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}

local A32nx_FBW_elev_trim = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -35, Max_error = 35, Error_offset = 0}

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

--initialise FBW
set(Override_artstab, 1)
set(Override_control_surfaces, 1)

function onPlaneLoaded()
    set(Override_artstab, 1)
    set(Override_control_surfaces, 1)
end

function onAirportLoaded()
    set(Override_artstab, 1)
    set(Override_control_surfaces, 1)
end

function update()
    set(Override_artstab, 1)

    if get(Flight_director_1_mode) == 2 or get(Flight_director_2_mode) == 2 then
        if get(Roll) + get(Servo_roll) > 0.1 then
            set(Roll_rate_command, 15 * (get(Roll) + get(Servo_roll)))
        elseif get(Roll) + get(Servo_roll) < -0.1 then
            set(Roll_rate_command, 15 * (get(Roll) + get(Servo_roll)))
        else
            set(Roll_rate_command, 0)
        end

        if get(flaps_handle_ratio) < 0.1 then--
            if get(Pitch) + get(Servo_pitch) > 0.1 then
                set(G_load_command, 1.5 * (get(Pitch) + get(Servo_pitch)) + 1)
            elseif get(Pitch) < -0.1 then
                set(G_load_command, 2 * (get(Pitch) + get(Servo_pitch)) + 1)
            else
                set(G_load_command, 1)
            end
        else
            if get(Pitch) + get(Servo_pitch) > 0.1 then
                set(G_load_command, (get(Pitch) + get(Servo_pitch)) + 1)
            elseif get(Pitch) < -0.1 then
                set(G_load_command, (get(Pitch) + get(Servo_pitch)) + 1)
            else
                set(G_load_command, 1)
            end
        end
    else
        if get(Roll) > 0.1 then
            set(Roll_rate_command, 15 * get(Roll))
        elseif get(Roll) < -0.1 then
            set(Roll_rate_command, 15 * get(Roll))
        else
            set(Roll_rate_command, 0)
        end

        if get(flaps_handle_ratio) < 0.1 then--
            if get(Pitch) > 0.1 then
                set(G_load_command, 1.5 * get(Pitch) + 1)
            elseif get(Pitch) < -0.1 then
                set(G_load_command, 2 * get(Pitch) + 1)
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
    end

    --15 degrees dive and command G load
    set(Pitch_d_lim, FBW_PD(A32nx_FBW_pitch_down, -15 - get(Flightmodel_pitch)))
    --30 degrees climb and command G load
    set(Pitch_u_lim, FBW_PD(A32nx_FBW_pitch_up,  30 - get(Flightmodel_pitch)))

    --5.5 deg/s up pitch rate
    set(Pitch_rate_u_lim, FBW_PD(A32nx_FBW_pitch_rate_up,  5.5 - get(Pitch_rate)))
    --5.5 deg/s down pitch rate
    set(Pitch_rate_d_lim, FBW_PD(A32nx_FBW_pitch_rate_down,  -5.5 - get(Pitch_rate)))

    --AOA 13 degrees near stall protection
    set(AOA_lim, FBW_PD(A32nx_FBW_AOA_protection,  13 - get(Alpha)))

    --Max speed protection MAX + 10
    set(MAX_spd_lim, FBW_PD(A32nx_FBW_MAX_spd_protection,  310 - get(IAS)))

    if get(G_load_command) == 1 then
        --command 1G
        set(G_output, FBW_PID(A32nx_FBW_1G_command,  1 - get(Total_vertical_g_load)))
    else
        --G command
        set(G_output, FBW_PD(A32nx_FBW_G_command,  get(G_load_command) - get(Total_vertical_g_load)))
    end

    --command roll rate
    set(Roll_rate_output, FBW_PD(A32nx_FBW_roll_rate_command,  get(Roll_rate_command) - get(Roll_rate)))

    if get(Roll) + get(Servo_roll) > 0.1 or get(Roll) + get(Servo_roll) < -0.1 then
        --67 degrees roll left
        set(Roll_l_lim, FBW_PD(A32nx_FBW_roll_left, - 67 - get(Flightmodel_roll)))
        --67 degrees roll right
        set(Roll_r_lim, FBW_PD(A32nx_FBW_roll_right, 67 - get(Flightmodel_roll)))
    else
        --30 degrees roll left
        set(Roll_l_lim, FBW_PD(A32nx_FBW_roll_left_no_stick,  - 33 - get(Flightmodel_roll)))
        --30 degrees roll right
        set(Roll_r_lim, FBW_PD(A32nx_FBW_roll_right_no_stick,   33 - get(Flightmodel_roll)))
    end

    if get(FBW_on) == 1 then
        set(Roll_artstab, get(Roll_l_lim) + get(Roll_r_lim) + get(Roll_rate_output))
        --if get(Pitch) > 0.1 or get(Pitch) < -0.1 then
            set(Pitch_artstab, (get(Pitch_d_lim) + get(Pitch_u_lim)) + (get(Pitch_rate_d_lim) + get(Pitch_rate_u_lim)) + get(G_output) + (get(AOA_lim) - 1))
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
