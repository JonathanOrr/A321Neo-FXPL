--PID and PD array
--array format PD_array = {P_gain, D_gain, Current_error, Min_error, Max_error, Error_offset}
--array format PID_array = {P_gain, I_gain, D_gain, I_delay, Integral, Current_error, Min_error, Max_error, Error_offset}
local A32nx_FBW_roll_left =  {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_right = {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_left_no_stick =  {P_gain = 1, D_gain = 25, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_roll_right_no_stick = {P_gain = 1, D_gain = 25, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_pitch_up =   {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_pitch_down = {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_pitch_rate_up =   {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -0.5, Max_error = 0.5, Error_offset = 0}
local A32nx_FBW_pitch_rate_down =   {P_gain = 1, D_gain = 10, Current_error = 0, Min_error = -0.5, Max_error = 0.5, Error_offset = 0}
local A32nx_FBW_roll_rate_command = {P_gain = 0.8, I_gain = 1, D_gain = 2, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -1, Max_error = 1, Error_offset = 0}
--local A32nx_FBW_1G_command = {P_gain = 1, I_gain = 1, D_gain = 1.5, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -0.25, Max_error = 0.25, Error_offset = 0}
local A32nx_FBW_1G_command = {P_gain = 1.5, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_G_command = {P_gain = 0.16, I_gain = 1, D_gain = 7.5, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -0.15, Max_error = 0.15, Error_offset = 0}
local A32nx_FBW_AOA_protection = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}
local A32nx_FBW_MAX_spd_protection = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}

local A32nx_FBW_elev_trim = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -0.5, Max_error = 0.5, Error_offset = 0}

--[[establishing the FBW laws:
    NORMAL LAW: 30 UP, 15 DOWN, stick active: 67 LEFT & RIGHT, not active 30 LEFT & RIGHT, 14 degrees alpha, OVERSPEED protection, roll rate of 30, 2.5G to -1G in normal flight,2G to 0G if flaps down envelop, always CWS
    ALT 1: NORMAL LAW, but without vertical constraints
    ALT 2: NORMAL LAW, but without horizontal constraints, and can without both constraints but still has CWS
    DIRECT: NO constraints, NO CWS
]]

--variables--
local FBW_alt_law_gear_extended = 0 --FBW supposed to be in alt law and gear is extended puting it into direct law
local FBW_restart_required = 0 --not in normal law require restart to restore
local ground_mode_transition_timer = 0 --(3.5) for delayed transition
local flare_mode_transition_timer = 0 --(2.5) for delayed transition

--sim datarefs

--a32nx datarefs

--a32nx commands
local toggle_ELAC_1 = sasl.createCommand("a321neo/FBW/toggle_ELAC_1", "toggle ELAC 1")
local toggle_ELAC_2 = sasl.createCommand("a321neo/FBW/toggle_ELAC_2", "toggle ELAC 1")
local toggle_FAC_1 = sasl.createCommand("a321neo/FBW/toggle_FAC_1", "toggle FAC 1")
local toggle_FAC_2 = sasl.createCommand("a321neo/FBW/toggle_FAC_2", "toggle FAC 2")

--a32nx command handler
sasl.registerCommandHandler (toggle_ELAC_1, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ELAC_1, 1 - get(ELAC_1))

        if get(ELAC_1) == 0 and FBW_restart_required == 1 then
            FBW_restart_required = 0
        end
    end
end)

sasl.registerCommandHandler (toggle_ELAC_2, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ELAC_2, 1 - get(ELAC_2))

        if get(ELAC_2) == 0 and FBW_restart_required == 1 then
            FBW_restart_required = 0
        end
    end
end)

sasl.registerCommandHandler (toggle_FAC_1, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(FAC_1, 1 - get(FAC_1))

        if get(FAC_1) == 0 and FBW_restart_required == 1 then
            FBW_restart_required = 0
        end
    end
end)

sasl.registerCommandHandler (toggle_FAC_2, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(FAC_2, 1 - get(FAC_2))

        if get(FAC_2) == 0 and FBW_restart_required == 1 and Is_in_flight_envelop() == true then
            FBW_restart_required = 0
            print("restarted")
        end
    end
end)

--custom functions
function Is_in_flight_envelop()
    if get(Flightmodel_roll) > -70 and get(Flightmodel_roll) < 70 and
       get(Flightmodel_pitch) > -17 and get(Flightmodel_pitch) < 33 and
       get(Roll_rate) > -16 and get(Roll_rate) < 16 and 
       get(Pitch_rate) > -10 and get(Pitch_rate) < 8 and 
       get(Total_vertical_g_load) > -1 and get(Total_vertical_g_load) < 2.5 and
       get(Alpha) < 10 and get(IAS) < get(Max_speed) + 10 then--all of normal law's envelop achieved
        if get(Roll) > -0.05 and get(Roll) < 0.05 then--if stick is not giving roll input
            if get(Flightmodel_roll) > -35 and get(Flightmodel_roll) < 35 then--then if within 33 degrees of bank
                if get(Flaps_handle_ratio) > 0 then--then if the flaps is deployed
                    if get(Total_vertical_g_load) > 0 and get(Total_vertical_g_load) < 2 then--then if G load within flaps limits
                        return true --in envelop
                    else--G load not in flap limits
                        return false --not in envelop
                    end
                else-- flaps not deployed
                    return true
                end
            else-- more than 33 degrees of bank
                return false
            end
        else--stick is active giving roll input
            if get(Flaps_handle_ratio) > 0 then--then if the flaps is deployed
                if get(Total_vertical_g_load) > 0 and get(Total_vertical_g_load) < 2 then--then if G load within flaps limits
                    return true --in envelop
                else--G load not in flap limits
                    return false --not in envelop
                end
            else-- flaps not deployed
                return true
            end
        end
    else--not inside all normal law envelop
        return false
    end
end

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

    --ground mode detection--
    if get(Aft_wheel_on_ground) == 1 then
        ground_mode_transition_timer = 3.5
        if flare_mode_transition_timer < 0 then
            set(FBW_ground_mode, 1)
        end
    else
        if ground_mode_transition_timer < 0 then
            set(FBW_ground_mode, 0)
        else
            ground_mode_transition_timer = ground_mode_transition_timer - 1 * get(DELTA_TIME)
        end
    end

    if get(Flaps_handle_ratio) > 0.5 and get(Capt_ra_alt_ft) < 100 and get(VVI) < 0 and get(VVI) > -4000 and get(Aft_wheel_on_ground) == 0 then
        set(FBW_flare_mode, 1)
        flare_mode_transition_timer = 2.5
    else
        if flare_mode_transition_timer < 0 then
            set(FBW_flare_mode, 0)
        else
            flare_mode_transition_timer = flare_mode_transition_timer - 1 * get(DELTA_TIME)
        end
    end

    --input interpretation--
    if get(Flight_director_1_mode) == 2 or get(Flight_director_2_mode) == 2 then
        if get(Roll) + get(Servo_roll) > 0.05 then
            set(Roll_rate_command, 15 * (get(Roll) + get(Servo_roll)))
        elseif get(Roll) + get(Servo_roll) < -0.05 then
            set(Roll_rate_command, 15 * (get(Roll) + get(Servo_roll)))
        else
            set(Roll_rate_command, 0)
        end

        if get(Flaps_handle_ratio) < 0.1 then--
            if get(Pitch) + get(Servo_pitch) > 0.05 then
                set(G_load_command, 1.5 * (get(Pitch) + get(Servo_pitch)) + 1)
            elseif get(Pitch) + get(Servo_pitch) < -0.05 then
                set(G_load_command, 2 * (get(Pitch) + get(Servo_pitch)) + 1)
            else
                set(G_load_command, 1)
            end
        else
            if get(Pitch) + get(Servo_pitch) > 0.05 then
                set(G_load_command, (get(Pitch) + get(Servo_pitch)) + 1)
            elseif get(Pitch) + get(Servo_pitch) < -0.05 then
                set(G_load_command, (get(Pitch) + get(Servo_pitch)) + 1)
            else
                set(G_load_command, 1)
            end
        end
    else
        if get(Roll) > 0.05 then
            set(Roll_rate_command, 15 * get(Roll))
        elseif get(Roll) < -0.05 then
            set(Roll_rate_command, 15 * get(Roll))
        else
            set(Roll_rate_command, 0)
        end

        if get(Flaps_handle_ratio) < 0.1 then--
            if get(Pitch) > 0.05 then
                set(G_load_command, 1.5 * get(Pitch) + 1)
            elseif get(Pitch) < -0.05 then
                set(G_load_command, 2 * get(Pitch) + 1)
            else
                set(G_load_command, 1)
            end
        else
            if get(Pitch) > 0.05 then
                set(G_load_command, get(Pitch) + 1)
            elseif get(Pitch) < -0.05 then
                set(G_load_command, get(Pitch) + 1)
            else
                set(G_load_command, 1)
            end
        end
    end

    --FBW laws constraints--
    --15 degrees dive and command G load
    set(Pitch_d_lim, FBW_PD(A32nx_FBW_pitch_down, -15 - get(Flightmodel_pitch)))
    --30 degrees climb and command G load
    set(Pitch_u_lim, FBW_PD(A32nx_FBW_pitch_up,  30 - get(Flightmodel_pitch)))

    --5.5 deg/s up pitch rate
    set(Pitch_rate_u_lim, FBW_PD(A32nx_FBW_pitch_rate_up,  7.5 - get(Pitch_rate)))
    --5.5 deg/s down pitch rate
    set(Pitch_rate_d_lim, FBW_PD(A32nx_FBW_pitch_rate_down,  -9.5 - get(Pitch_rate)))

    --AOA 9 degrees slightly above stall protection
    set(AOA_lim, Math_clamp(FBW_PD(A32nx_FBW_AOA_protection,  9 - get(Alpha)), -1, 0))

    --Max speed protection MAX + 10
    set(MAX_spd_lim, -Math_clamp(FBW_PD(A32nx_FBW_MAX_spd_protection,  (get(Max_speed) + 10) - get(IAS)), -1, 0))

    if get(G_load_command) == 1 then
        if get(FBW_status) == 2 then
            --command 0 pitch rate clamped to stop integral build up
            set(G_output, Set_anim_value(get(G_output), Math_clamp(FBW_PID(A32nx_FBW_1G_command, 0 - get(Pitch_rate)), get(Pitch_d_lim), get(Pitch_u_lim)), -1, 1, 0.5))
        else
            --command 0 pitch rate
            set(G_output, Set_anim_value(get(G_output), FBW_PID(A32nx_FBW_1G_command, 0 - get(Pitch_rate)), -1, 1, 0.5))
        end
    else
        if get(FBW_status) == 2 then
            --G command clamped to stop integral build up
            set(G_output, Set_anim_value(get(G_output), Math_clamp(FBW_PD(A32nx_FBW_G_command, get(G_load_command) - get(Total_vertical_g_load)), get(Pitch_d_lim), get(Pitch_u_lim)), -1, 1, 0.8))
        else
            --G command
            set(G_output, Set_anim_value(get(G_output), FBW_PD(A32nx_FBW_G_command, get(G_load_command) - get(Total_vertical_g_load)), -1, 1, 0.8))
        end
    end

    --command roll rate
    set(Roll_rate_output, Set_anim_value(get(Roll_rate_output), Math_clamp(FBW_PD(A32nx_FBW_roll_rate_command,  get(Roll_rate_command) - get(Roll_rate)), get(Roll_l_lim), get(Roll_r_lim)), -1, 1, 1.2))

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

    --apply the laws to the surfaces--
    if get(FBW_status) == 2 then--normal law
        --set(Roll_artstab, get(Roll_l_lim) + get(Roll_r_lim) + get(Roll_rate_output))
        --set(Pitch_artstab, (get(Pitch_d_lim) + get(Pitch_u_lim)) + (get(Pitch_rate_d_lim) + get(Pitch_rate_u_lim)) + get(G_output) + get(AOA_lim) + get(MAX_spd_lim))

        if get(FBW_ground_mode) == 0 then
            set(Roll_artstab, get(Roll_rate_output))
            set(Pitch_artstab, get(G_output) + get(AOA_lim) + get(MAX_spd_lim))
        else
            set(Roll_artstab, get(Roll_l_lim) + get(Roll_r_lim) + get(Roll))
            set(Pitch_artstab, (get(Pitch_d_lim) + get(Pitch_u_lim)) + (get(Pitch_rate_d_lim) + get(Pitch_rate_u_lim)) + get(Pitch))
        end

        if get(Flight_director_1_mode) ~= 2 and get(Flight_director_2_mode) ~= 2 then
            --CWS trimming--
            if get(FBW_ground_mode) == 0 then
                if get(FBW_flare_mode) == 0 then--flare mode
                    set(FBW_flaring, 0)
                    set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(Pitch_artstab) + (0 - get(Pitch_rate))), -1, 1, 0.1))
                    if get(Pitch) > 0.05 then
                        set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(G_load_command) - get(Total_vertical_g_load)), -1, 1, 0.08))
                    elseif get(Pitch) < -0.05 then
                        set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(G_load_command) - get(Total_vertical_g_load)), -1, 1, 0.08))
                    end
                else
                    if get(Capt_ra_alt_ft) < 35 then
                        --pitch down slightly
                        set(FBW_flaring, 1)
                        set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(Pitch_artstab) + (-1.5 - get(Pitch_rate))), -1, 1, 0.1))
                        if get(Pitch) > 0.05 then
                            set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, (-1.5 - get(Pitch_rate)) + (get(G_load_command) - get(Total_vertical_g_load))), -1, 1, 0.08))
                        elseif get(Pitch) < -0.05 then
                            set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, (-1.5 - get(Pitch_rate)) + (get(G_load_command) - get(Total_vertical_g_load))), -1, 1, 0.08))
                        end
                    else--not below 35 ft
                        set(FBW_flaring, 0)
                        --normal trim
                        set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(Pitch_artstab) + (0 - get(Pitch_rate))), -1, 1, 0.1))
                        if get(Pitch) > 0.05 then
                            set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(G_load_command) - get(Total_vertical_g_load)), -1, 1, 0.08))
                        elseif get(Pitch) < -0.05 then
                            set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(G_load_command) - get(Total_vertical_g_load)), -1, 1, 0.08))
                        end
                    end
                end
            else--in ground mode
                set(FBW_flaring, 0)
            end
        end
    elseif get(FBW_status) == 1 then--ALT 2 law(no roll)
        set(Roll_artstab, get(Roll))
        --if get(Pitch) > 0.1 or get(Pitch) < -0.1 then
        set(Pitch_artstab,  get(G_output))

        if get(Flight_director_1_mode) ~= 2 and get(Flight_director_2_mode) ~= 2 then
            --CWS trimming--
            if get(Pitch) > 0.05 then
                set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(G_load_command) - get(Total_vertical_g_load)), -1, 1, 0.08))
            elseif get(Pitch) < -0.05 then
                set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(G_load_command) - get(Total_vertical_g_load)), -1, 1, 0.08))
            else
                set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), FBW_PID(A32nx_FBW_elev_trim, get(Pitch_artstab) + (0 - get(Pitch_rate))), -1, 1, 0.1))
            end
        end

        --set(Horizontal_stabilizer_pitch, Set_linear_anim_value(get(Horizontal_stabilizer_pitch), FBW_PD(A32nx_FBW_elev_trim, 1 - get(Total_vertical_g_load)), -3.5, 11, 10, 0.01))
    else--direct law
        set(Roll_artstab, get(Roll))
        set(Pitch_artstab, get(Pitch))
    end
end
