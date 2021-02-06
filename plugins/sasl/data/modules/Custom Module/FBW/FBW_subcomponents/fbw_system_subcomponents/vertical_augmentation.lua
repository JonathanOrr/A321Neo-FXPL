local vertical_control_var_table = {
    Q_input = 0,
    C_star_input = 0,

    Filtered_Q = 0,
    Filtered_Q_err = 0,
    Filtered_ias = 0,
    Filtered_AoA = 0,

    AoA_SP = 0,

    rotation_mode_controller_output = 0,
    flight_mode_controller_output = 0,
    flare_mode_controller_output = 0,

    wait_for_stability = 5,--seconds
    stability_wait_timer = 0,--seconds
}

local lateral_control_filter_table = {
    Q_pv_filter_table = {
        x = get(True_pitch_rate),
        cut_frequency = 6,
    },
    Q_err_filter_table = {
        x = 0,
        cut_frequency = 6,
    },
    IAS_filter_table = {
        x = adirs_get_avg_ias(),
        cut_frequency = 2,
    },
    AoA_filter_table = {
        x = 0,
        cut_frequency = 1,
    }
}

--FLIGHT CHARACTERISTICS------------------------------------------------------------------------------------
local function neutral_flight_G(pitch, bank)
    return math.cos(math.rad(pitch)) / math.cos(math.rad(bank))
end

local function compute_C_star(Nz, Q, ias)
    return Nz + (ias * 0.514444 * math.rad(Q)) / 9.8
end

--INPUT INTERPRETATION--------------------------------------------------------------------------------------
local input_limitations = {
    Pitch = function (Q)
        --properties
        local pitch = adirs_get_avg_pitch()
        local max_pitch = 30
        local min_pitch = -15
        local degrade_margin = get(Any_wheel_on_ground) == 1 and 2.5 or 8
        local max_return_rate = 2

        --tail strike protection
        local tailstrike_pitch = 9.7
        max_pitch = Math_rescale(0, Math_rescale(3/4, tailstrike_pitch, 1, 30, get(Augmented_pitch)), 15, 30, get(Capt_ra_alt_ft))

        --check for pitch exceedence
        local d_limitation = Math_rescale(min_pitch - degrade_margin, 2, min_pitch + degrade_margin, 0, pitch)
        local u_limitation = Math_rescale(max_pitch - degrade_margin, 0, max_pitch + degrade_margin, 2, pitch)

        --rescale input--
        local d_limit_table = {
            {0, Q},
            {1, math.max(0, Q)},
            {2, math.max(Q, max_return_rate)},
        }
        local Q_limited = Table_interpolate(d_limit_table, d_limitation)

        local u_limit_table = {
            {0, Q_limited},
            {1, math.min(Q_limited, 0)},
            {2, math.min(Q_limited, -max_return_rate)},
        }
        Q_limited = Table_interpolate(u_limit_table, u_limitation)

        return Q_limited
    end,

    AoA = function (x, Q, var_table)
        --exit if any gears on ground--
        if get(Any_wheel_on_ground) == 1 then
            return Q
        end

        --properties
        local clamping_margin = 5--starts to degrade Q limit
        local entry_margin = 1
        local time_to_move_demand = 3.5
        local max_rotation_Q = 6 * math.abs(math.cos(math.rad(adirs_get_avg_roll())))
        local max_Q = 3
        local degrade_margin = 2

        --set alpha demand target
        local target_aoa = Math_rescale(0, get(Aprot_AoA), 1, get(Amax_AoA), x)
        var_table.AoA_SP = Set_linear_anim_value(var_table.AoA_SP, target_aoa, 0, 100, 1 / time_to_move_demand)
        var_table.AoA_SP = Math_clamp(var_table.AoA_SP, get(Aprot_AoA), get(Amax_AoA))

        --demand Q to reach Alpha--
        local alpha_demand_Q = Math_rescale(-degrade_margin, -max_Q, degrade_margin, max_Q, var_table.AoA_SP - var_table.Filtered_AoA)

        --blend ratio between the inputed Q and the alpha demand Q--
        local blend_ratio = Math_rescale(get(Aprot_AoA) - entry_margin, 0, get(Aprot_AoA), 1, var_table.Filtered_AoA)
        blend_ratio = Math_rescale(-0.5, 0, 0, blend_ratio, x)

        --adjust upper clamp limit
        local upper_Q_clamp = Math_rescale(0, max_Q, clamping_margin, max_rotation_Q, var_table.AoA_SP - var_table.Filtered_AoA)
        --clamped entered Q--
        local clamped_Q = Math_clamp_higher(Q, upper_Q_clamp)

        --rescale into into Q and output--
        return Math_rescale(0, clamped_Q, 1, alpha_demand_Q, blend_ratio)
    end,

    Vmax = function (x)
        
    end,
}

--INPUT INTERPRETATION--------------------------------------------------------------------------------------
local get_vertical_input = {
    Rotation = function (x, var_table)
        --rescale input--
        local output_Q = 6 * math.abs(math.cos(math.rad(adirs_get_avg_roll()))) * x

        --AoA demand
        output_Q = input_limitations.AoA(x, output_Q, var_table)

        --pitch protection--
        output_Q = input_limitations.Pitch(output_Q)

        return output_Q
    end,

    C_star = function (x, pitch, bank)
        local clean_max_G_c_star = -606791 + (3.582054 - (-606791)) / (1 + (Math_clamp(math.abs(bank), 0, 67) / 142496.9)^1.728056)
        local clean_min_G_c_star = -1.954915 + (-2.8 - (-1.954915)) / (1 + (Math_clamp(math.abs(bank), 0, 67) / 40.50731)^1.237363)
        local flaps_max_G_c_star = Math_rescale(0,   2.8, 67, 2.0, math.abs(bank))
        local flaps_min_G_c_star = Math_rescale(0, -0.75, 67, 0.0, math.abs(bank))

        local clean_C_star_table = {
            {-1, clean_min_G_c_star},
            {0,  neutral_flight_G(pitch, Math_clamp(bank, -33, 33))},
            {1,  clean_max_G_c_star},
        }
        local flaps_C_star_table = {
            {-1, flaps_min_G_c_star},
            {0,  neutral_flight_G(pitch, Math_clamp(bank, -33, 33))},
            {1,  flaps_max_G_c_star},
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

    Flare = function (x)
        local max_Q = 3
        local pitch = adirs_get_avg_pitch()

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

        local output_Q = Table_interpolate(taget_Q_table, att_demand - pitch)

        return output_Q
    end,
}

--input swapping--------------------------------------------------------------------------------------------
local function input_handling(var_table)
    var_table.Q_input = get_vertical_input.Rotation(get(Augmented_pitch), var_table) * get(FBW_vertical_rotation_mode_ratio) + get_vertical_input.Rotation(get(Augmented_pitch), var_table) * get(FBW_vertical_flight_mode_ratio) + get_vertical_input.Flare(get(Augmented_pitch)) * get(FBW_vertical_flare_mode_ratio)
end

--FILTERING-------------------------------------------------------------------------------------------------
local function filter_values(var_table, filter_table)
    --FILTERING--
    --filter the Q PV
    filter_table.Q_pv_filter_table.x = get(True_pitch_rate)
    var_table.Filtered_Q = low_pass_filter(filter_table.Q_pv_filter_table)
    --filter the Q error
    filter_table.Q_err_filter_table.x = var_table.Q_input - get(True_pitch_rate)
    var_table.Filtered_Q_err = low_pass_filter(filter_table.Q_err_filter_table)
    --filter the scheduling variable
    filter_table.IAS_filter_table.x = adirs_get_avg_ias()
    var_table.Filtered_ias = low_pass_filter(filter_table.IAS_filter_table)
    --filter the AoA
    filter_table.AoA_filter_table.x = adirs_get_avg_aoa()
    var_table.Filtered_AoA = low_pass_filter(filter_table.AoA_filter_table)
end

--MODE AUGMENTATIONS----------------------------------------------------------------------------------------
local vertical_augmentation = {
    Rotation_mode = function (var_table)
        if get(FBW_vertical_rotation_mode_ratio) == 0 then
            var_table.rotation_mode_controller_output = 0
            return
        end

        --Rotation mode on ground with limited integration--
        if get(Front_gear_on_ground) == 1 then
            FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Integral = Math_clamp(FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Integral, 0, 0.25)
        end

        var_table.rotation_mode_controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_PITCH_RATE_PID_array, var_table.Filtered_Q_err, var_table.Filtered_Q, var_table.Filtered_ias)
    end,
    Flight_mode = function (var_table)
        if get(FBW_vertical_flight_mode_ratio) == 0 then
            var_table.flight_mode_controller_output = 0
            return
        end

        var_table.flight_mode_controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_PITCH_RATE_PID_array, var_table.Filtered_Q_err, var_table.Filtered_Q, var_table.Filtered_ias)
    end,
    Flare_mode = function (var_table)
        --not in flare mode or not in normal law
        if get(FBW_vertical_flare_mode_ratio) == 0 then
            var_table.flare_mode_controller_output = 0
            return
        end
        if get(FBW_vertical_law) == FBW_DIRECT_LAW then
            var_table.flare_mode_controller_output = get(Augmented_pitch)
            return
        end

        var_table.flare_mode_controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_PITCH_RATE_PID_array, var_table.Filtered_Q_err, var_table.Filtered_Q, var_table.Filtered_ias)
    end,
}

local function enforce_bumpless_transfers()
    --Q controller--
    if get(FBW_vertical_law) == FBW_DIRECT_LAW then
        FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Integral = 0
        return
    end
    if get(FBW_vertical_rotation_mode_ratio) == 0 and get(FBW_vertical_flight_mode_ratio) == 0 and get(FBW_vertical_flare_mode_ratio) == 0  then
        FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Integral = 0
        return
    end
end

local function FBW_vertical_mode_blending(var_table)
    set(
        Pitch_artstab,
        Math_clamp(
            get(Augmented_pitch)                        * get(FBW_vertical_ground_mode_ratio)
            + var_table.rotation_mode_controller_output * get(FBW_vertical_rotation_mode_ratio)
            + var_table.flight_mode_controller_output   * get(FBW_vertical_flight_mode_ratio)
            + var_table.flare_mode_controller_output    * get(FBW_vertical_flare_mode_ratio)
        , -1, 1)
    )

    --BP Q controller--
    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Actual_output = get(Pitch_artstab)
end

function update()
    input_handling(vertical_control_var_table)
    filter_values(vertical_control_var_table, lateral_control_filter_table)

    vertical_augmentation.Rotation_mode(vertical_control_var_table)
    vertical_augmentation.Flight_mode(vertical_control_var_table)
    vertical_augmentation.Flare_mode(vertical_control_var_table)

    enforce_bumpless_transfers()
    FBW_vertical_mode_blending(vertical_control_var_table)
end