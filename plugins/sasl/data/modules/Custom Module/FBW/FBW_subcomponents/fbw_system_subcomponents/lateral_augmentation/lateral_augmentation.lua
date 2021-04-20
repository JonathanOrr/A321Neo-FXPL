local Lateral_control_var_table = {
    filtered_error = 0,
    controller_output = 0,
}

local function lateral_controlling(var_table)
    --ensure bumpless transfer--
    if get(FBW_lateral_flight_mode_ratio) == 0 or get(FBW_lateral_law) ~= FBW_NORMAL_LAW then
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Integral = 0
    end

    --OUTPUT--
    var_table.controller_output = FBW_PID_BP(
        FBW_PID_arrays.FBW_ROLL_RATE_PID_array,
        FBW.filtered_sensors.P_error.filtered,
        FBW.filtered_sensors.P.filtered,
        FBW.filtered_sensors.IAS.filtered
    )

    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Actual_output = get(FBW_roll_output)
end

local function FBW_lateral_mode_blending(var_table)
    set(
        FBW_roll_output,
        Math_clamp(
            get(Total_input_roll)       * get(FBW_lateral_ground_mode_ratio) +
            var_table.controller_output * get(FBW_lateral_flight_mode_ratio),
        -1, 1)
    )
end

function update()
    FBW.lateral.protections.bank_angle_protection()
    lateral_controlling(Lateral_control_var_table)
    FBW_lateral_mode_blending(Lateral_control_var_table)
end
