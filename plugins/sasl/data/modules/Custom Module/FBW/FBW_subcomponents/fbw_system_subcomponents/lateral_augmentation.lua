local Lateral_control_var_table = {
    P_input = 0,

    neutral_bank_angle = 0,
    maximum_bank_angle = 0,

    filtered_P = 0,
    filtered_error = 0,
    filtered_ias = 0,
    controller_output = 0,
}

local lateral_control_filter_table = {
    P_rate_pv_filter_table = {
        x = get(True_roll_rate),
        cut_frequency = 20,
    },
    P_err_filter_table = {
        x = get(Augmented_roll) * 15 - get(True_roll_rate),
        cut_frequency = 20,
    },
    IAS_filter_table = {
        x = adirs_get_avg_ias(),
        cut_frequency = 500,
    }
}

local function limit_input(x, bank, neutral_bank, max_bank)
    --properties
    local degrade_margin = 15
    local max_return_rate = 10
    local max_roll_rate = 15

    --inputs
    local abs_x = math.abs(x)

    --manipulations
    local max_allowable_bank = Math_rescale(0, neutral_bank, 1, max_bank, abs_x)

    --check for bank exceedence
    local l_limitation = Math_rescale(-max_allowable_bank - degrade_margin, 2, -max_allowable_bank + degrade_margin, 0, bank)
    local r_limitation = Math_rescale(max_allowable_bank - degrade_margin,  0,  max_allowable_bank + degrade_margin, 2, bank)

    --rescale input--
    local l_limit_table = {
        {0, x},
        {1, math.max(0, x)},
        {2, max_return_rate / max_roll_rate},
    }
    local x_limited = Table_interpolate(l_limit_table, l_limitation)

    local r_limit_table = {
        {0, x_limited},
        {1, math.min(x, 0)},
        {2, -max_return_rate / max_roll_rate},
    }
    x_limited = Table_interpolate(r_limit_table, r_limitation)

    return x_limited
end

local function lateral_input_and_protection(var_table)
    --properties
    local bank_angle_speed = 8

    if adirs_get_avg_aoa() > get(Aprot_AoA) then--alpha protection bank angle protection
        var_table.neutral_bank_angle = Set_linear_anim_value(var_table.neutral_bank_angle, 33, 0, 67, bank_angle_speed)
        var_table.maximum_bank_angle = Set_linear_anim_value(var_table.maximum_bank_angle, 45, 0, 67, bank_angle_speed)
    elseif adirs_get_avg_ias() > get(Fixed_VMAX) then--high speed bank angle protection
        var_table.neutral_bank_angle = Set_linear_anim_value(var_table.neutral_bank_angle, 0, 0, 67, bank_angle_speed)
        var_table.maximum_bank_angle = Set_linear_anim_value(var_table.maximum_bank_angle, 40, 0, 67, bank_angle_speed)
    else
        var_table.neutral_bank_angle = Set_linear_anim_value(var_table.neutral_bank_angle, 33, 0, 67, bank_angle_speed)
        var_table.maximum_bank_angle = Set_linear_anim_value(var_table.maximum_bank_angle, 67, 0, 67, bank_angle_speed)
    end

    --take the sidestick position
    local limited_input = limit_input(get(Augmented_roll), adirs_get_avg_roll(), var_table.neutral_bank_angle, var_table.maximum_bank_angle)

    --convert input into roll rate
    var_table.P_input = Math_rescale(-1, -15, 1, 15, limited_input)
end

local function lateral_controlling(var_table, filter_table)
    --FILTERING--
    --filter the PV
    filter_table.P_rate_pv_filter_table.x = get(True_roll_rate)
    var_table.filtered_P = low_pass_filter(filter_table.P_rate_pv_filter_table)
    --filter the error
    filter_table.P_err_filter_table.x = var_table.P_input - get(True_roll_rate)
    var_table.filtered_error = low_pass_filter(filter_table.P_err_filter_table)
    --filter the scheduling variable
    filter_table.IAS_filter_table.x = adirs_get_avg_ias()
    var_table.filtered_ias = low_pass_filter(filter_table.IAS_filter_table)

    --ensure bumpless transfer--
    if get(FBW_lateral_flight_mode_ratio) == 0 or get(FBW_lateral_law) ~= FBW_NORMAL_LAW then
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_gains = false
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array.I_gain = 0
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array.B_gain = 0
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Integral = 0
    else
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_gains = true
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array.B_gain = 1
    end

    --OUTPUT--
    var_table.controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_ROLL_RATE_PID_array, var_table.filtered_error, var_table.filtered_P, var_table.filtered_ias)
    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Actual_output = get(Roll_artstab)
end

local function FBW_lateral_mode_blending(var_table)
    set(
        Roll_artstab,
        get(Augmented_roll)         * get(FBW_lateral_ground_mode_ratio) +
        var_table.controller_output * get(FBW_lateral_flight_mode_ratio)
    )
end

function update()
    lateral_input_and_protection(Lateral_control_var_table)
    lateral_controlling(Lateral_control_var_table, lateral_control_filter_table)
    FBW_lateral_mode_blending(Lateral_control_var_table)
end
