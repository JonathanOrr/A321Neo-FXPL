local vertical_control_var_table = {
    Q_rate_input = 0,
    C_star_input = 0,
    Theta_input = 0,

    rotation_mode_controller_output = 0,
    flight_mode_controller_output = 0,
    flare_mode_controller_output = 0,
}

local vmax_prot_activation_ratio = 0
local vmax_prot_output = 0

local wait_for_v_stability = 5--seconds
local v_stability_wait_timer = 0--seconds
local G_output = 0
local pitch_rate_correction = 0

--test--
local cws_desired = 0
local cws_actual = 0

local lvl_flt_load_constant = math.cos(math.rad(get(Flightmodel_pitch))) / math.cos(math.rad(Math_clamp(get(Flightmodel_roll), -33, 33)))

local function neutral_flight_G(pitch, bank)
    return math.cos(math.rad(pitch)) / math.cos(math.rad(bank))
end

local function compute_C_star(Nz, Q, ias)
    return Nz + (ias * 0.514444 * math.rad(Q)) / 9.8
end

local get_vertical_input = {
    Rotation = function (x, max_Q)
        return Math_rescale(-1, -max_Q, 1, max_Q, x)
    end,

    C_star = function (x, pitch, bank)
        local clean_max_G_c_star = -606791 + (3.582054 - (-606791)) / (1 + (Math_clamp(math.abs(bank), 0, 67) / 142496.9)^1.728056)
        local clean_min_G_c_star = -1.954915 + (-2.8 - (-1.954915)) / (1 + (Math_clamp(math.abs(bank), 0, 67) / 40.50731)^1.237363)

        local clean_C_star_table = {
            {-1, clean_min_G_c_star},
            {0,  neutral_flight_G(pitch, Math_clamp(bank, -33, 33))},
            {1,  clean_max_G_c_star},
        }
        local flaps_C_star_table = {
            {-1, Math_rescale(0, -0.75, 67, 0.0, math.abs(bank))},
            {0,  neutral_flight_G(pitch, Math_clamp(bank, -33, 33))},
            {1,  Math_rescale(0,   2.8, 67, 2.0, math.abs(bank))},
        }
        return get(Flaps_internal_config) ~= 0 and Table_interpolate(flaps_C_star_table, x) or Table_interpolate(clean_C_star_table, x)
    end,

    G_load = function (x, pitch, bank)
        local clean_G_table = {
            {-1, -1},
            {0,  neutral_flight_G(pitch, Math_clamp(bank, -33, 33))},
            {1,  2.5},
        }
        local flaps_G_table = {
            {-1, 0},
            {0,  neutral_flight_G(pitch, Math_clamp(bank, -33, 33))},
            {1,  2},
        }
        return get(Flaps_internal_config) ~= 0 and Table_interpolate(flaps_G_table, x) or Table_interpolate(clean_G_table, x)
    end,

    AoA = function (x)
        return Math_rescale(0, get(Aprot_AoA), 1, get(Amax_AoA), x)
    end,

    High_speed = function (x)
        
    end,

    Flare = function (x, pitch, max_Q)
        --pitch rate demand blending
        local pitch_rate_table = {
            {-1, max_Q},
            {0,  -get(FBW_flare_mode_computed_Q)},
            {1,  max_Q},
        }

        --the threshold for max pitch rate demand to happen to snap back to the demanded ATT
        local taget_Q_table = {
            {-5, -Table_interpolate(pitch_rate_table, x)},
            {0,  0},
            {5,  Table_interpolate(pitch_rate_table, x)},
        }

        --pitch ATT demand
        local target_att_table = {
            {-1, -22},
            {0,   -2},
            {1,   get(Ground_spoilers_mode) == 2 and 7 or 18},
        }
        local att_demand = Table_interpolate(target_att_table, x)

        return Table_interpolate(taget_Q_table, att_demand - pitch)
    end,
}

local function vertical_rotation_mode_augmentation(var_table)

end

local function vertical_flight_augmentation(var_table)
    if get(DELTA_TIME) ~= 0 then
        if get(FBW_vertical_flight_mode_ratio) == 0 then
            FBW_PID_arrays.SSS_FBW_G_load_pitch.Integral = 0
            FBW_PID_arrays.SSS_FBW_pitch_rate.Integral = 0
        end

        local stick_moving_vertically = false
        if math.abs(get(Augmented_pitch)) > 0.05 then
            stick_moving_vertically = true
        end

        if stick_moving_vertically == true then
            v_stability_wait_timer = 0
        else
            if v_stability_wait_timer < wait_for_v_stability then
                v_stability_wait_timer = Math_clamp(v_stability_wait_timer + 1 * get(DELTA_TIME), 0, wait_for_v_stability)
            end
        end

        if get(FBW_kill_switch) == 0 then
            --CASCADE: SIDESTICK --> G LOAD PID --> PITCH RATE PID --> CODED STABILITY / FILTERING --> ELEVATOR
            --slowly start to enable the pitch for vmax protection as the speed overshoots vmax and heads towards vmax prot
            vmax_prot_activation_ratio = Math_clamp((adirs_get_avg_ias() - get(VMAX)) / (get(VMAX_prot) - get(Fixed_VMAX)), 0, 1)
            vmax_prot_output = Math_lerp(-1, SSS_PID(FBW_PID_arrays.SSS_FBW_vmax_prot_pitch, adirs_get_avg_ias() - get(VMAX_prot)), vmax_prot_activation_ratio)
            FBW_PID_arrays.SSS_FBW_G_load_pitch.Min_out = Math_clamp_lower(vmax_prot_output, SSS_PID(FBW_PID_arrays.SSS_FBW_pitch_down_limit, -15 - get(Flightmodel_pitch)))
            FBW_PID_arrays.SSS_FBW_G_load_pitch.Max_out = Math_clamp_higher(SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_stall_prot_pitch, 1000000, get(Alpha)), SSS_PID(FBW_PID_arrays.SSS_FBW_pitch_up_limit, 30 - get(Flightmodel_pitch)))
            --pitch rate stability[used to temperarily guard the G load before overshoot stops]

            G_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_G_load_pitch, get_vertical_input.G_load(get(Augmented_pitch), adirs_get_avg_pitch(), adirs_get_avg_roll()), get(Total_vertical_g_load)) * 10

            --gain scheduling--
            FBW_PID_arrays.SSS_FBW_pitch_rate.P_gain = Math_rescale(245, 0.24, 310, 0.2, get(IAS))
            FBW_PID_arrays.SSS_FBW_pitch_rate.I_time = Math_rescale(245, 2.2, 310, 2.2, get(IAS))
            FBW_PID_arrays.SSS_FBW_pitch_rate.D_gain = Math_rescale(245, 0.12, 310, 0.1, get(IAS))
            if stick_moving_vertically == true then
                pitch_rate_correction = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_pitch_rate, G_output, get(True_pitch_rate))
            else
                pitch_rate_correction = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_pitch_rate, Math_lerp(0, G_output, v_stability_wait_timer / wait_for_v_stability), get(True_pitch_rate))
            end
        end

        if get(FBW_kill_switch) == 0 then
            var_table.flight_mode_controller_output = Set_anim_value(var_table.flight_mode_controller_output, pitch_rate_correction, -1, 1, adirs_get_avg_ias() > 160 and (adirs_get_avg_ias() > 200 and 1.15 or 1.85) or 2.25)

            --test BP
            cws_desired = FBW_PID_arrays.SSS_FBW_CWS_trim.Proportional + FBW_PID_arrays.SSS_FBW_CWS_trim.Integral + FBW_PID_arrays.SSS_FBW_CWS_trim.Derivative
            cws_actual = get(Augmented_pitch_trim_ratio)
            local cws_bp = cws_actual - cws_desired
            FBW_PID_arrays.SSS_FBW_CWS_trim.Integral = FBW_PID_arrays.SSS_FBW_CWS_trim.Integral + cws_bp * get(DELTA_TIME)

            if get(FBW_vertical_flight_mode_ratio) == 1 then
                set(Augmented_pitch_trim_ratio, Set_anim_value(get(Augmented_pitch_trim_ratio), SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_CWS_trim, 0, - get(Pitch_artstab)), -1, 1, 1))
            end
        end

    end
end

local function vertical_flare_mode_augmentation(var_table)

end

function FBW_vertical_agmentation(var_table)
    if get(FBW_vertical_rotation_mode_ratio) == 0 and get(FBW_vertical_flare_mode_ratio) == 0 then
        FBW_PID_arrays.SSS_FBW_rotation_pitch_rate.Integral = 0
    end

    if get(FBW_vertical_rotation_mode_ratio) > 0 then
        var_table.rotation_mode_controller_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_rotation_pitch_rate, get_vertical_input.Rotation(get(Augmented_pitch), 6), get(True_pitch_rate))
    end
    if get(FBW_vertical_flare_mode_ratio) > 0 then
        var_table.flare_mode_controller_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_rotation_pitch_rate, get_vertical_input.Flare(get(Augmented_pitch), adirs_get_avg_pitch(), 2.5), get(True_pitch_rate))
    end

    if get(Aft_wheel_on_ground) == 1 and get(FBW_vertical_rotation_mode_ratio) > 0 then
        FBW_PID_arrays.SSS_FBW_rotation_pitch_rate.Integral = Math_clamp_lower(FBW_PID_arrays.SSS_FBW_rotation_pitch_rate.Integral, -0.15)
    end
end

local function FBW_vertical_mode_blending(var_table)
    print(compute_C_star(get(Total_vertical_g_load), get(True_pitch_rate), adirs_get_avg_ias()))

    set(
        Pitch_artstab,
        get(Augmented_pitch)                        * get(FBW_vertical_ground_mode_ratio)
        + var_table.rotation_mode_controller_output * get(FBW_vertical_rotation_mode_ratio)
        + var_table.flight_mode_controller_output   * get(FBW_vertical_flight_mode_ratio)
        + var_table.flare_mode_controller_output    * get(FBW_vertical_flare_mode_ratio)
    )
end

function update()
    vertical_flight_augmentation(vertical_control_var_table)
    FBW_vertical_agmentation(vertical_control_var_table)
    FBW_vertical_mode_blending(vertical_control_var_table)
end