local yaw_control_var_table = {
    sideslip_input = 0,

    controller_output = 0,
}

local function yaw_input(x, var_table)
    local max_sideslip = 20

    var_table.sideslip_input = -x * max_sideslip
end

local function yaw_controlling(var_table)
    var_table.controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_YAW_DAMPER_PID_array, get(Slide_slip_angle) - var_table.sideslip_input, -get(Slide_slip_angle))
    var_table.controller_output = Math_clamp(var_table.controller_output, -get(Rudder_travel_lim) / 30, get(Rudder_travel_lim) / 30)
    FBW_PID_arrays.FBW_YAW_DAMPER_PID_array.Actual_output = get(Yaw_artstab)
end

local function FBW_yaw_mode_blending(var_table)
    set(
        Yaw_artstab,
        get(Yaw)                    * get(FBW_lateral_ground_mode_ratio) +
        var_table.controller_output * get(FBW_lateral_flight_mode_ratio)
    )
end

function update()
    yaw_input(get(Yaw), yaw_control_var_table)
    yaw_controlling(yaw_control_var_table)
    FBW_yaw_mode_blending(yaw_control_var_table)
end