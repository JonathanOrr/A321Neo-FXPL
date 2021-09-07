FBW.lateral.controllers = {
    roll_rate_PID = {
        output = 0,
        bumpless_transfer = function ()
            if get(FBW_lateral_flight_mode_ratio) == 0 or get(FBW_lateral_law) ~= FBW_NORMAL_LAW then
                FBW_PID_arrays.FBW_ROLL_RATE_PID.Integral = 0
            end
        end,
        control = function ()
            FBW.lateral.controllers.roll_rate_PID.output = FBW_PID_BP(
                FBW_PID_arrays.FBW_ROLL_RATE_PID,
                FBW.lateral.inputs.x_to_P(get(Total_input_roll), get(Flightmodel_roll)),
                FBW.rates.Roll.x,
                FBW.filtered_sensors.IAS.filtered
            )
        end,
        bp = function ()
            local l_ail_rat = {
                {-25, -1},
                {10 * get(Flaps_deployed_angle) / 30, 0},
                {25,   1},
            }
            local r_ail_rat = {
                {-25, 1},
                {10 * get(Flaps_deployed_angle) / 30, 0},
                {25, -1},
            }

            local L_AIL_OK = FBW.fctl.surfaces.ail.L.controlled
            local R_AIL_OK = FBW.fctl.surfaces.ail.R.controlled

            local L_LAF = get(FBW_MLA_output) + get(FBW_GLA_output)
            local R_LAF = get(FBW_MLA_output) + get(FBW_GLA_output)
            local L_AIL_WO_LAF = get(L_aileron)
            local R_AIL_WO_LAF = get(R_aileron)
            if get(FBW_LAF_DEGRADED_AIL) == 1 then
                L_AIL_WO_LAF = L_AIL_WO_LAF - L_LAF
                R_AIL_WO_LAF = R_AIL_WO_LAF - R_LAF
            end


            local ailrat = 0
            if L_AIL_OK and R_AIL_OK then
                ailrat = (
                    Table_interpolate(l_ail_rat, L_AIL_WO_LAF) +
                    Table_interpolate(r_ail_rat, R_AIL_WO_LAF)
                ) / 2
            elseif L_AIL_OK and not R_AIL_OK then
                ailrat = Table_interpolate(l_ail_rat, L_AIL_WO_LAF)
            elseif not L_AIL_OK and R_AIL_OK then
                ailrat = Table_interpolate(r_ail_rat, R_AIL_WO_LAF)
            else
                ailrat = 0
            end

            FBW_PID_arrays.FBW_ROLL_RATE_PID.Actual_output = ailrat
        end,
    },

    output_blending = function ()
        set(
            FBW_roll_output,
            Math_clamp(
                get(Total_input_roll)                        * get(FBW_lateral_ground_mode_ratio) +
                FBW.lateral.controllers.roll_rate_PID.output * get(FBW_lateral_flight_mode_ratio),
                -1,
                1
            )
        )
    end,
}