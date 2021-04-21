FBW.yaw.controllers = {
    yaw_damper_PD = {
        output = 0,
        control = function ()
            --Yaw damper control
            FBW.yaw.controllers.yaw_damper_PD.output = FBW_PID_BP_ADV(
                FBW_PID_arrays.FBW_YAW_DAMPER_PID_array,
                0,
                get(True_yaw_rate)
            )
            --law reconfiguration
            if get(FBW_yaw_law) == FBW_ALT_NO_PROT_LAW then
                --limit travel ability to 5 degrees of rudder
                FBW.yaw.controllers.yaw_damper_PD.output = Math_clamp(FBW.yaw.controllers.yaw_damper_PD.output, -5/30, 5/30)
            end
            if get(FBW_yaw_law) == FBW_MECHANICAL_BACKUP_LAW or get(Yaw_damper_avail) == 0 then
                FBW.yaw.controllers.yaw_damper_PD.output = 0
            end
        end,
        bp = function ()
            FBW_PID_arrays.FBW_YAW_DAMPER_PID_array.Actual_output = get(Rudder) / 30
        end,
    },

    SI_demand_PID = {
        output = 0,
        bumpless_transfer = function ()
            if get(FBW_lateral_flight_mode_ratio) == 0 or get(FBW_yaw_law) ~= FBW_NORMAL_LAW then
                FBW_PID_arrays.FBW_NRM_YAW_PID_array.Integral = 0
            end
        end,
        control = function ()
            FBW.yaw.controllers.SI_demand_PID.output = FBW_PID_BP_ADV(
                FBW_PID_arrays.FBW_NRM_YAW_PID_array,
                FBW.yaw.inputs.x_to_SI(get(Total_input_yaw)),
                get(Slide_slip_angle),
                FBW.yaw.inputs.get_curr_turbolence()
            )
        end,
        bp = function ()
            FBW_PID_arrays.FBW_NRM_YAW_PID_array.Desired_output = FBW_PID_arrays.FBW_NRM_YAW_PID_array.Desired_output + FBW.yaw.controllers.yaw_damper_PD.output
            FBW_PID_arrays.FBW_NRM_YAW_PID_array.Actual_output = get(Rudder) / 30
        end
    },

    output_blending = function ()
        set(
            FBW_yaw_output,
            Math_clamp(
                (get(Total_input_yaw) + FBW.yaw.controllers.yaw_damper_PD.output)                     * get(FBW_lateral_ground_mode_ratio) +
                (FBW.yaw.controllers.SI_demand_PID.output + FBW.yaw.controllers.yaw_damper_PD.output) * get(FBW_lateral_flight_mode_ratio),
                -get(Rudder_travel_lim) / 30,
                get(Rudder_travel_lim) / 30
            )
        )
    end
}