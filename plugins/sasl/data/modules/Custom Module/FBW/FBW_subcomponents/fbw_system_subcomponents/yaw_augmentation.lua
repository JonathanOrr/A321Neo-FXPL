local yaw_control_var_table = {
    sideslip_input = 0,

    filtered_sideslip_err = 0,

    NRM_controller_output = 0,
    Yaw_damper_controller_output = 0,
}

local yaw_control_filter_table = {
    sideslip_err_filter_table = {
        x = get(Slide_slip_angle),
        cut_frequency = 1.5,
    },
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

local function get_curr_windshear()  -- returns [0;1] range

    local alt_0 = get(Wind_layer_1_alt)
    local alt_1 = get(Wind_layer_2_alt)
    local alt_2 = get(Wind_layer_3_alt)

    local my_altitude = get(Elevation_m)
    local windshear = 0

    if my_altitude <= alt_0 then
        -- Lower than the first layer, turbolence extends to ground
        windshear = get(Wind_layer_1_windshear)
    elseif my_altitude <= alt_1 then
        -- In the middle layer 0 and layer 1: interpolate
        windshear = Math_rescale(alt_0, get(Wind_layer_1_windshear), alt_1, get(Wind_layer_2_windshear), my_altitude)
    elseif my_altitude <= alt_2 then
        -- In the middle layer 1 and layer 2: interpolate
        windshear = Math_rescale(alt_1, get(Wind_layer_2_windshear), alt_2, get(Wind_layer_3_windshear), my_altitude)
    else
        -- Highest than the last layer, turbolence extends to space
        windshear = get(Wind_layer_3_windshear)
    end

    return windshear / 90 -- XP datarefs are on scale [0;10], we change it to [0;1]
end

local function yaw_input(x, var_table)
    local max_rudder_deflection = 30

    --blend max SI according to speed of the aircraft and the A350 FCOM
    --15 degrees of SI at 160kts to 2 degrees at VMO
    --linear interpolation is used to avoid significant change in value during circular falloff
    set(Max_SI_demand_lim, Math_rescale(160, 15, get(Fixed_VMAX), 2, FBW.filtered_sensors.IAS.filtered))

    var_table.sideslip_input = -x * get(Max_SI_demand_lim) + (-get(Rudder_trim_target_angle) / max_rudder_deflection) * get(Max_SI_demand_lim)
end

local function filter_values(var_table, filter_table)
    filter_table.sideslip_err_filter_table.x = get(Slide_slip_angle) - var_table.sideslip_input
    var_table.filtered_sideslip_err = low_pass_filter(filter_table.sideslip_err_filter_table)
end

local function yaw_controlling(var_table)
    --Yaw damper control
    var_table.Yaw_damper_controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_YAW_DAMPER_PID_array, FBW.filtered_sensors.R_err.filtered, FBW.filtered_sensors.R.filtered)
    --law reconfiguration
    if get(FBW_yaw_law) == FBW_ALT_NO_PROT_LAW then
        var_table.Yaw_damper_controller_output = Math_clamp(var_table.Yaw_damper_controller_output, -5/30, 5/30)--limit travel ability to 5 degrees of rudder
    end
    if get(FBW_yaw_law) == FBW_MECHANICAL_BACKUP_LAW or get(Yaw_damper_avail) == 0 then
        var_table.Yaw_damper_controller_output = 0
    end

    --NORMAL LAW-----------------------------------------------------------------------------------------
    --ensure bumpless transfer
    if get(FBW_lateral_flight_mode_ratio) == 0 or get(FBW_yaw_law) ~= FBW_NORMAL_LAW then
        FBW_PID_arrays.FBW_NRM_YAW_PID_array.Integral = 0
    end

    var_table.NRM_controller_output = FBW_PID_BP(FBW_PID_arrays.FBW_NRM_YAW_PID_array, var_table.filtered_sideslip_err, FBW.filtered_sensors.sideslip.filtered, get_curr_turbolence())--math.max(get_curr_turbolence(), get_curr_windshear()))

    --back propagation--
    FBW_PID_arrays.FBW_YAW_DAMPER_PID_array.Actual_output = get(Rudder) / 30
    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Actual_output = get(Rudder) / 30
end

local function FBW_yaw_mode_blending(var_table)
    set(
        FBW_yaw_output,
        Math_clamp(
            (get(Total_input_yaw) + var_table.Yaw_damper_controller_output)            * get(FBW_lateral_ground_mode_ratio) +
            (var_table.NRM_controller_output + var_table.Yaw_damper_controller_output) * get(FBW_lateral_flight_mode_ratio)
        , -get(Rudder_travel_lim) / 30, get(Rudder_travel_lim) / 30)
    )
end

function update()
    yaw_input(get(Total_input_yaw), yaw_control_var_table)
    filter_values(yaw_control_var_table, yaw_control_filter_table)
    yaw_controlling(yaw_control_var_table)
    FBW_yaw_mode_blending(yaw_control_var_table)
end