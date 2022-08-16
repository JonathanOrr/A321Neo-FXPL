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
                FBW.angular_rates.Phi.deg,
                FBW.filtered_sensors.IAS.filtered
            )
        end,
        bp = function ()
            local l_ail_rat_tbl = {
                {-25 + get(AIL_Droop), -1},
                {get(AIL_Droop),        0},
                {25 + get(AIL_Droop),   1},
            }
            local r_ail_rat_tbl = {
                {-25 + get(AIL_Droop),  1},
                {get(AIL_Droop),        0},
                {25 + get(AIL_Droop),  -1},
            }

            local L_AIL_OK = FCTL.AIL.STAT.L.controlled
            local R_AIL_OK = FCTL.AIL.STAT.R.controlled

            local L_LAF = get(FBW_MLA_output) + get(FBW_GLA_output)
            local R_LAF = get(FBW_MLA_output) + get(FBW_GLA_output)
            local L_AIL_WO_LAF = get(L_aileron)
            local R_AIL_WO_LAF = get(R_aileron)
            if get(FBW_LAF_DEGRADED_AIL) ~= 1 then
                L_AIL_WO_LAF = L_AIL_WO_LAF - L_LAF
                R_AIL_WO_LAF = R_AIL_WO_LAF - R_LAF
            end

            local l_ailrat = Table_interpolate(l_ail_rat_tbl, L_AIL_WO_LAF) + Math_clamp_lower(get(FBW_roll_output) - Table_interpolate(l_ail_rat_tbl, 25),  0)
            local r_ailrat = Table_interpolate(r_ail_rat_tbl, R_AIL_WO_LAF) + Math_clamp_higher(get(FBW_roll_output) - Table_interpolate(r_ail_rat_tbl, 25), 0)
            local total_ailrat = 0
            if L_AIL_OK and R_AIL_OK then
                total_ailrat = (l_ailrat + r_ailrat) / 2
            elseif L_AIL_OK and not R_AIL_OK then
                total_ailrat = l_ailrat
            elseif not L_AIL_OK and R_AIL_OK then
                total_ailrat = r_ailrat
            else
                total_ailrat = 0
            end

            FBW_PID_arrays.FBW_ROLL_RATE_PID.Actual_output = total_ailrat
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