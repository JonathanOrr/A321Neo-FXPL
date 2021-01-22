local yaw_control_var_table = {
    sideslip_input = 0,

    NRM_controller_output = 0,
    ALT_controller_output = 0,
}

local function get_curr_turbolence()  -- returns [0;1] range

    local alt_0 = get(Wind_layer_1_alt)
    local alt_1 = get(Wind_layer_2_alt)
    local alt_2 = get(Wind_layer_3_alt)

    local my_altitude = get(Elevation_m)
    local wind_turb = 0

    if my_altitude <= alt_0 then
        -- Lower than the first layer, turbolence extends to ground
        wind_turb = get(Wind_layer_1_turbulence)
    elseif my_altitude <= alt_1 then
        -- In the middle layer 0 and layer 1: interpolate
        wind_turb = Math_rescale(alt_0, get(Wind_layer_1_turbulence), alt_1, get(Wind_layer_2_turbulence), my_altitude)
    elseif my_altitude <= alt_2 then
        -- In the middle layer 1 and layer 2: interpolate
        wind_turb = Math_rescale(alt_1, get(Wind_layer_2_turbulence), alt_2, get(Wind_layer_3_turbulence), my_altitude)
    else
        -- Highest than the last layer, turbolence extends to space
        wind_turb = get(Wind_layer_3_turbulence)
    end

    return wind_turb / 10 -- XP datarefs are on scale [0;10], we change it to [0;1]
end

local function yaw_input(x, var_table)
    local max_rudder_deflection = 30
    local max_sideslip = 20

    var_table.sideslip_input = -x * max_sideslip + (-get(Rudder_trim_angle) / max_rudder_deflection) * max_sideslip
end

local function yaw_controlling(var_table)
    --ALTERNATE LAW-----------------------------------------------------------------------------------------
    if get(FBW_yaw_law) == FBW_ALT_NO_PROT_LAW then
        var_table.ALT_controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_ALT_YAW_PID_array, get(Slide_slip_angle), -get(Slide_slip_angle), get_curr_turbolence())
        var_table.ALT_controller_output = Math_clamp(var_table.ALT_controller_output, -5/30, 5/30)--limit travel ability to 5 degrees of rudder
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.Actual_output = get(Yaw_artstab)
    else
        var_table.ALT_controller_output = 0
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.Actual_output = get(Yaw_artstab)
    end

    --NORMAL LAW-----------------------------------------------------------------------------------------
    --ensure bumpless transfer
    if get(FBW_lateral_flight_mode_ratio) == 0 or get(FBW_yaw_law) ~= FBW_NORMAL_LAW then
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_gains = false
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.I_gain = 0
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.B_gain = 0
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.Integral = 0
    else
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_gains = true
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.Integral = Math_rescale(0, 0, 1, FBW_PID_arrays.FBW_NRM_YAW_PID_array.Integral, get(FBW_lateral_flight_mode_ratio))--on ground switch to PD
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.B_gain = 1
    end

    var_table.NRM_controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_NRM_YAW_PID_array, get(Slide_slip_angle) - var_table.sideslip_input, -get(Slide_slip_angle), get_curr_turbolence())
    var_table.NRM_controller_output = Math_clamp(var_table.NRM_controller_output, -get(Rudder_travel_lim) / 30, get(Rudder_travel_lim) / 30)
    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Actual_output = get(Yaw_artstab)
end

local function FBW_yaw_mode_blending(var_table)
    set(
        Yaw_artstab,
        (get(Yaw) + var_table.NRM_controller_output + var_table.ALT_controller_output) * get(FBW_lateral_ground_mode_ratio) +
        (var_table.NRM_controller_output + var_table.ALT_controller_output)            * get(FBW_lateral_flight_mode_ratio)
    )
end

function update()
    yaw_input(get(Yaw), yaw_control_var_table)
    yaw_controlling(yaw_control_var_table)
    FBW_yaw_mode_blending(yaw_control_var_table)
end