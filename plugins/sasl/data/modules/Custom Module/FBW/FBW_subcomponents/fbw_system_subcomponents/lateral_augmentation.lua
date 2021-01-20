local Lateral_control_var_table = {
    filtered_P = 0,
    filtered_error = 0,
    filtered_ias = 0,
    controller_output = 0,
}

local lateral_control_filter_table = {
    P_rate_pv_filter_table = {
        x = get(True_roll_rate),
        cut_frequency = 22,
    },
    P_err_filter_table = {
        x = get(Augmented_roll) * 15 - get(True_roll_rate),
        cut_frequency = 22,
    },
    IAS_filter_table = {
        x = adirs_get_avg_ias(),
        cut_frequency = 500,
    }
}

local function lateral_controlling(var_table, filter_table)
    --filter the PV and Error of the controller before feeding it in
    filter_table.P_rate_pv_filter_table.x = get(True_roll_rate)
    var_table.filtered_P = low_pass_filter(filter_table.P_rate_pv_filter_table)
    filter_table.P_err_filter_table.x = get(Augmented_roll) * 15 - get(True_roll_rate)
    var_table.filtered_error = low_pass_filter(filter_table.P_err_filter_table)
    filter_table.IAS_filter_table.x = adirs_get_avg_ias()
    var_table.filtered_ias = low_pass_filter(filter_table.IAS_filter_table)

    --print(var_table.filtered_ias)

    --augment the controls and outputs and BP
    var_table.controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_test_PID_array, var_table.filtered_error, var_table.filtered_P, var_table.filtered_ias)
    FBW_PID_arrays.FBW_test_PID_array.Actual_output = get(Roll_artstab)
end

local function FBW_lateral_mode_blending(var_table)
    set(
        Roll_artstab,
        get(Augmented_roll)         * get(FBW_lateral_ground_mode_ratio) +
        var_table.controller_output * get(FBW_lateral_flight_mode_ratio)
    )
end

function update()
    lateral_controlling(Lateral_control_var_table, lateral_control_filter_table)
    FBW_lateral_mode_blending(Lateral_control_var_table)
end
