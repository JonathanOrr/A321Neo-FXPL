local vertical_control_var_table = {
    Q_input = 0,
    C_star_input = 0,

    Filtered_Q = 0,
    Filtered_Q_err = 0,
    Filtered_ias = 0,
    Filtered_AoA = 0,

    AoA_V_SP = 0,
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
        cut_frequency = 0.25,
    }
}

--FLIGHT CHARACTERISTICS------------------------------------------------------------------------------------
local function neutral_flight_G(pitch, bank)
    return math.cos(math.rad(pitch)) / math.cos(math.rad(bank))
end

local function compute_C_star(Nz, Q)
    --we define that 210kts as the crossoever V
    return Nz + (210 * 0.514444 * math.rad(Q)) / 9.8
end

local function Max_C_STAR()
    local max_G = get(Flaps_internal_config) ~= 0 and 2 or 2.5

    local rad_pitch = math.rad(adirs_get_avg_pitch())
    local rad_bank  = math.rad(adirs_get_avg_roll())

    local nz_trim = math.cos(rad_pitch) * math.cos(rad_bank)
    local delta_nz_turn = math.cos(rad_pitch) * (math.sin(math.rad(33))^2 / math.cos(math.rad(33)))

    local U_offset = (2 * (max_G - math.cos(rad_pitch) * math.cos(math.rad(67))) - delta_nz_turn) - (-2 * (max_G - math.cos(rad_pitch)) - delta_nz_turn)

    local upper_C_star_lim = -(1 - 1 + 2) * (max_G - nz_trim) - delta_nz_turn + U_offset --TODO cross over speed

    return upper_C_star_lim
end

local function Min_C_STAR()
    local min_G = get(Flaps_internal_config) ~= 0 and 0 or -1

    local rad_pitch = math.rad(adirs_get_avg_pitch())
    local rad_bank  = math.rad(adirs_get_avg_roll())

    local nz_trim = math.cos(rad_pitch) * math.cos(rad_bank)

    local U_offset = (2 * (min_G - math.cos(rad_pitch) * math.cos(math.rad(67)))) - (-2 * (min_G - math.cos(rad_pitch)))

    local lower_C_star_lim = -(1 - 1 + 2) * (min_G - nz_trim) + U_offset --TODO cross over speed

    return lower_C_star_lim
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


    Q_AoA = function (x, Q, clamping_margin, min_Q, max_Q, var_table, pid_array)
        --exit if any gears on ground--
        if get(Any_wheel_on_ground) == 1 then
            return Q
        end

        --properties
        local entry_margin = 1
        local time_to_move_demand = 3.5

        --set alpha/V demand target
        local target_V =     Math_rescale(0, get(Vaprot_vsw_smooth), 1, get(Valpha_MAX_smooth), x)
        local target_aoa =   Math_rescale(0, get(Aprot_AoA), 1, get(Amax_AoA), x)
        var_table.AoA_V_SP = Set_linear_anim_value(var_table.AoA_V_SP, target_V, 0, 1000, 1 / time_to_move_demand)
        var_table.AoA_V_SP = Math_clamp(var_table.AoA_V_SP, get(Valpha_MAX_smooth), get(Vaprot_vsw_smooth))
        var_table.AoA_SP =   Set_linear_anim_value(var_table.AoA_SP, target_aoa, 0, 100, 1 / time_to_move_demand)
        var_table.AoA_SP =   Math_clamp(var_table.AoA_SP, get(Aprot_AoA), get(Amax_AoA))

        --demand Q to reach Alpha--
        local V_demand_Q = Math_rescale(0, 0, 25, -4, var_table.AoA_V_SP - var_table.Filtered_ias)
        local alpha_demand_Q = FBW_PID_BP(pid_array, var_table.AoA_SP - var_table.Filtered_AoA, var_table.Filtered_AoA) + V_demand_Q
        alpha_demand_Q = Math_clamp(alpha_demand_Q, -4, 4)

        --blend ratio between the inputed Q and the alpha demand Q--
        local blend_ratio = Math_rescale(get(Aprot_AoA) - entry_margin, 0, get(Aprot_AoA), 1, var_table.Filtered_AoA)
        blend_ratio = Math_rescale(-0.5, 0, 0, blend_ratio, x)

        --adjust upper clamp limit
        local upper_Q_clamp = Math_rescale(0, min_Q, clamping_margin, max_Q, var_table.AoA_SP - var_table.Filtered_AoA)
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
    X_to_G = function (x)
        local max_G = get(Flaps_internal_config) ~= 0 and 2 or 2.5
        local min_G = get(Flaps_internal_config) ~= 0 and 0 or -1

        local pitch = adirs_get_avg_pitch()
        local bank  = adirs_get_avg_roll()

        local G_load_input_table = {
            {-1, min_G},
            {0,  neutral_flight_G(pitch, Math_clamp(bank, -33, 33))},
            {1,  max_G},
        }

        return Table_interpolate(G_load_input_table, x)
    end,

    G_to_Cstar = function (G)
        local max_G = get(Flaps_internal_config) ~= 0 and 2 or 2.5
        local min_G = get(Flaps_internal_config) ~= 0 and 0 or -1

        local pitch = adirs_get_avg_pitch()
        local bank  = adirs_get_avg_roll()

        local neutral_nz = neutral_flight_G(pitch, Math_clamp(bank, -33, 33))

        local C_star_input_table = {
            {min_G, Min_C_STAR()},
            {neutral_nz, neutral_nz},
            {max_G, Max_C_STAR()},
        }

        return Table_interpolate(C_star_input_table, G)
    end,

    Rotation = function (x, var_table)
        --rescale input--
        local output_Q = 6 * math.abs(math.cos(math.rad(adirs_get_avg_roll()))) * x

        --AoA demand
        output_Q = input_limitations.Q_AoA(x, output_Q, 5, 3, 6, var_table, FBW_PID_arrays.FBW_ROTATION_APROT_PID_array)

        --pitch protection--
        output_Q = input_limitations.Pitch(output_Q)

        --BP the AoA demand PID
        FBW_PID_arrays.FBW_ROTATION_APROT_PID_array.Actual_output = var_table.Q_input

        return output_Q
    end,

    Flare = function (x, var_table)
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

        --alpha protection
        output_Q = input_limitations.Q_AoA(x, output_Q, 3, 1.5, 3, var_table, FBW_PID_arrays.FBW_FLARE_APROT_PID_array)

        --BP the AoA demand PID
        FBW_PID_arrays.FBW_FLARE_APROT_PID_array.Actual_output = var_table.Q_input

        return output_Q
    end,
}

--input swapping--------------------------------------------------------------------------------------------
local function input_handling(var_table)
    local rotation_mode_input = get_vertical_input.Rotation(get(Augmented_pitch), var_table)
    local flare_mode_input = get_vertical_input.Flare(get(Augmented_pitch), var_table)

    var_table.Q_input = rotation_mode_input * get(FBW_vertical_rotation_mode_ratio) + rotation_mode_input * get(FBW_vertical_flight_mode_ratio) + flare_mode_input * get(FBW_vertical_flare_mode_ratio)
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
        if get(FBW_vertical_law) == FBW_DIRECT_LAW or
           (get(FBW_vertical_law) ~= FBW_NORMAL_LAW and get(FBW_vertical_law) ~= FBW_DIRECT_LAW and get(FBW_vertical_flare_mode_ratio) > 0) then--alt law --> direct law
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
    end
    if get(FBW_vertical_rotation_mode_ratio) == 0 and get(FBW_vertical_flight_mode_ratio) == 0 and get(FBW_vertical_flare_mode_ratio) == 0  then
        FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Integral = 0
    end
    if get(FBW_vertical_rotation_mode_ratio) == 0 and get(FBW_vertical_flight_mode_ratio) == 0 then
        FBW_PID_arrays.FBW_ROTATION_APROT_PID_array.Integral = 0
    end
    if get(FBW_vertical_flare_mode_ratio) == 0  then
        FBW_PID_arrays.FBW_FLARE_APROT_PID_array.Integral = 0
    end
end

local function BP_elevator_position()
    local elevator_ratio_table = {
        {-30, 1},
        {0,   0},
        {17, -1},
    }

    local num_of_elev_avail = get(L_elevator_avail) + get(R_elevator_avail)

    if num_of_elev_avail == 2 then
        --BP Q controller--
        FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Actual_output = (
            Table_interpolate(elevator_ratio_table, get(Elevators_hstab_1)) +
            Table_interpolate(elevator_ratio_table, get(Elevators_hstab_2))
        ) / 2
    elseif num_of_elev_avail == 1 then
        if get(L_elevator_avail) == 1 and get(R_elevator_avail) == 0 then
            --BP Q controller--
            FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Actual_output = Table_interpolate(elevator_ratio_table, get(Elevators_hstab_1))
        elseif get(L_elevator_avail) == 0 and get(R_elevator_avail) == 1 then
            --BP Q controller--
            FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Actual_output = Table_interpolate(elevator_ratio_table, get(Elevators_hstab_2))
        end
    else
        --BP Q controller--
        FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Actual_output = 0
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
end

function update()
    input_handling(vertical_control_var_table)
    filter_values(vertical_control_var_table, lateral_control_filter_table)

    vertical_augmentation.Rotation_mode(vertical_control_var_table)
    vertical_augmentation.Flight_mode(vertical_control_var_table)
    vertical_augmentation.Flare_mode(vertical_control_var_table)

    enforce_bumpless_transfers()
    FBW_vertical_mode_blending(vertical_control_var_table)
    BP_elevator_position()
end