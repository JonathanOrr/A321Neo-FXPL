FBW.vertical.controllers = {
    Rotation_PID = {
        output = 0,
        bumpless_transfer = function ()
            if get(FBW_vertical_rotation_mode_ratio) == 0 and
               get(FBW_vertical_flight_mode_ratio) == 0 and
               get(FBW_vertical_flare_mode_ratio) == 0 then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Integral = 0
            end
            if get(FBW_vertical_law) == FBW_DIRECT_LAW then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Integral = 0
            end
            if get(FBW_vertical_rotation_mode_ratio) == 0 then
                FBW_PID_arrays.FBW_ROTATION_APROT_PID.Integral = 0
            end
        end,
        control = function ()
            if get(FBW_vertical_rotation_mode_ratio) == 0 then
                return
            end

            --Rotation mode on ground with limited integration--
            if get(Front_gear_on_ground) == 1 then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Integral = Math_clamp(FBW_PID_arrays.FBW_PITCH_RATE_PID.Integral, 0, 0.25)
            end

            FBW.vertical.controllers.Rotation_PID.output = FBW_PID_BP(
                FBW_PID_arrays.FBW_PITCH_RATE_PID,
                FBW.vertical.inputs.Rotation.INPUT(get(Total_input_pitch)),
                FBW.rates.Pitch.x,
                FBW.filtered_sensors.IAS.filtered
            )
        end,
        bp = function ()
            local elev_rat = {
                {-30,  1},
                {0,    0},
                {17,  -1},
            }

            local elevs_avail = get(L_elevator_avail) + get(R_elevator_avail)

            if elevs_avail ~= 0 then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Actual_output = (
                    Table_interpolate(elev_rat, get(L_elevator)) * get(L_elevator_avail) +
                    Table_interpolate(elev_rat, get(R_elevator)) * get(R_elevator_avail)
                ) / elevs_avail
            else
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Actual_output = (
                    Table_interpolate(elev_rat, get(L_elevator)) +
                    Table_interpolate(elev_rat, get(R_elevator))
                ) / 2
            end
        end,
    },

    Flight_PID = {
        Q_OUTPUT = 0,
        CSTART_OUTPUT = 0,
        output = 0,
        bumpless_transfer = function ()
            if get(FBW_vertical_rotation_mode_ratio) == 0 and
               get(FBW_vertical_flight_mode_ratio) == 0 and
               get(FBW_vertical_flare_mode_ratio) == 0 then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Integral = 0
            end
            if get(FBW_vertical_law) == FBW_DIRECT_LAW then
                FBW_PID_arrays.FBW_CSTAR_PID.Integral = 0
            end
            if get(FBW_vertical_flight_mode_ratio) == 0 then
                FBW_PID_arrays.FBW_CSTAR_PID.Integral = 0
                FBW_PID_arrays.FBW_FLIGHT_APROT_PID.Integral = 0
            end
        end,
        control = function ()
            if get(FBW_vertical_flight_mode_ratio) == 0 then
                return
            end

            FBW.vertical.controllers.Flight_PID.Q_OUTPUT = FBW_PID_BP(
                FBW_PID_arrays.FBW_PITCH_RATE_PID,
                FBW.vertical.inputs.Flight.Q_INPUT(),
                FBW.rates.Pitch.x,
                FBW.filtered_sensors.IAS.filtered
            )

            FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT = FBW_PID_BP(
                FBW_PID_arrays.FBW_CSTAR_PID,
                FBW.vertical.inputs.Flight.CSTAR_INPUT(get(Total_input_pitch)),
                FBW.vertical.dynamics.GET_CSTAR(get(Total_vertical_g_load), FBW.rates.Pitch.x),
                FBW.filtered_sensors.IAS.filtered
            )

            if get(FBW_vertical_law) == FBW_NORMAL_LAW then
                FBW.vertical.controllers.Flight_PID.output = Math_rescale(
                    0, FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT,
                    1, FBW.vertical.controllers.Flight_PID.Q_OUTPUT,
                    FBW.vertical.protections.General.AoA.G.ENTERY_RATIO(get(Total_input_pitch))
                )
            else
                FBW.vertical.controllers.Flight_PID.output = FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT
            end
        end,
        bp = function ()
            local elev_rat = {
                {-30,  1},
                {0,    0},
                {17,  -1},
            }

            local elevs_avail = get(L_elevator_avail) + get(R_elevator_avail)

            if elevs_avail ~= 0 then
                FBW_PID_arrays.FBW_CSTAR_PID.Actual_output = (
                    Table_interpolate(elev_rat, get(L_elevator)) * get(L_elevator_avail) +
                    Table_interpolate(elev_rat, get(R_elevator)) * get(R_elevator_avail)
                ) / elevs_avail
            else
                FBW_PID_arrays.FBW_CSTAR_PID.Actual_output = (
                    Table_interpolate(elev_rat, get(L_elevator)) +
                    Table_interpolate(elev_rat, get(R_elevator))
                ) / 2
            end
        end,
    },

    Flare_PID = {
        output = 0,
        bumpless_transfer = function ()
            if get(FBW_vertical_rotation_mode_ratio) == 0 and
               get(FBW_vertical_flight_mode_ratio) == 0 and
               get(FBW_vertical_flare_mode_ratio) == 0 then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Integral = 0
            end
            if get(FBW_vertical_law) == FBW_DIRECT_LAW then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Integral = 0
            end
            if get(FBW_vertical_flare_mode_ratio) == 0 then
                FBW_PID_arrays.FBW_FLARE_APROT_PID.Integral = 0
            end
        end,
        control = function ()
            if get(FBW_vertical_flare_mode_ratio) == 0 then
                return
            end

            if get(FBW_vertical_law) ~= FBW_NORMAL_LAW then--alt law <-> direct law
                FBW.vertical.controllers.Flare_PID.output = get(Total_input_pitch)
                return
            end

            FBW.vertical.controllers.Flare_PID.output = FBW_PID_BP(
                FBW_PID_arrays.FBW_PITCH_RATE_PID,
                FBW.vertical.inputs.Flare.INPUT(get(Total_input_pitch)),
                FBW.rates.Pitch.x,
                FBW.filtered_sensors.IAS.filtered
            )
        end,
        bp = function ()
            local elev_rat = {
                {-30,  1},
                {0,    0},
                {17,  -1},
            }

            local elevs_avail = get(L_elevator_avail) + get(R_elevator_avail)

            if elevs_avail ~= 0 then
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Actual_output = (
                    Table_interpolate(elev_rat, get(L_elevator)) * get(L_elevator_avail) +
                    Table_interpolate(elev_rat, get(R_elevator)) * get(R_elevator_avail)
                ) / elevs_avail
            else
                FBW_PID_arrays.FBW_PITCH_RATE_PID.Actual_output = (
                    Table_interpolate(elev_rat, get(L_elevator)) +
                    Table_interpolate(elev_rat, get(R_elevator))
                ) / 2
            end
        end,
    },

    AUTOTRIM_PID = {
        output = 0,
        bumpless_transfer = function ()
            --FBW_PID_arrays.FBW_CSTAR_PID.Integral = 0
        end,
        control = function ()
            if math.abs(adirs_get_avg_roll()) > 33 or
               get(Human_pitch_trim) ~= 0 or
               get(FBW_vertical_flight_mode_ratio) ~= 1 or
               FBW.filtered_sensors.IAS.filtered > get(Fixed_VMAX) or
               get(Total_vertical_g_load) < 0.5 or
               get(FBW_vertical_law) ~= FBW_NORMAL_LAW and FBW.filtered_sensors.IAS.filtered < get(VLS) then
                return
            end

            --enter limited trim range modes
            local LAST_TRIM_LIM_STATUS = get(THS_trim_range_limited)
            set(THS_trim_range_limited, 0)
            if get(FBW_vertical_law) == FBW_NORMAL_LAW then
                if adirs_get_avg_aoa() > get(Aprot_AoA) - 1 then
                    set(THS_trim_range_limited, 1)
                elseif get(Total_vertical_g_load) > 1.25 then
                    set(THS_trim_range_limited, 1)
                end
            end

            --memorise entry position
            if get(THS_trim_range_limited) - LAST_TRIM_LIM_STATUS == 1 then
                set(THS_trim_limit_ratio, get(Elev_trim_ratio))
            end

            FBW.vertical.controllers.AUTOTRIM_PID.output =
            FBW_PID_BP(
                FBW_PID_arrays.FBW_AUTOTRIM_PID,
                0,
                -get(FBW_pitch_output)
            )

            set(Augmented_pitch_trim_ratio, FBW.vertical.controllers.AUTOTRIM_PID.output)
        end,
        bp = function ()
            FBW_PID_arrays.FBW_AUTOTRIM_PID.Actual_output = get(Elev_trim_ratio)
        end,
    },

    output_blending = function ()
        set(
            FBW_pitch_output,
            Math_clamp(
                get(Total_input_pitch)                         * get(FBW_vertical_ground_mode_ratio)
                + FBW.vertical.controllers.Rotation_PID.output * get(FBW_vertical_rotation_mode_ratio)
                + FBW.vertical.controllers.Flight_PID.output   * get(FBW_vertical_flight_mode_ratio)
                + FBW.vertical.controllers.Flare_PID.output    * get(FBW_vertical_flare_mode_ratio),
                -1,
                1
            )
        )
    end,
}