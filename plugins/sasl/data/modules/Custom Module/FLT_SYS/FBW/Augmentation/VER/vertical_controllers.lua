local function ELEV_BP()
    local elev_rat_table = {
        {-30,  1},
        {0,    0},
        {17,  -1},
    }

    local L_ELEV_OK = FCTL.ELEV.STAT.L.controlled
    local R_ELEV_OK = FCTL.ELEV.STAT.R.controlled

    local elev_rat = 0

    if L_ELEV_OK and R_ELEV_OK then
        elev_rat = (
            Table_interpolate(elev_rat_table, get(L_elevator)) +
            Table_interpolate(elev_rat_table, get(R_elevator))
        ) / 2
    elseif L_ELEV_OK and not R_ELEV_OK then
        elev_rat = Table_interpolate(elev_rat_table, get(L_elevator))
    elseif not L_ELEV_OK and R_ELEV_OK then
        elev_rat = Table_interpolate(elev_rat_table, get(R_elevator))
    else
        elev_rat = (
            Table_interpolate(elev_rat_table, get(L_elevator)) +
            Table_interpolate(elev_rat_table, get(R_elevator))
        ) / 2
    end

    return elev_rat
end

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
                FBW.angular_rates.Theta.deg,
                FBW.filtered_sensors.IAS.filtered
            )
        end,
        bp = function ()
            FBW_PID_arrays.FBW_PITCH_RATE_PID.Actual_output = ELEV_BP()
        end,
    },

    Flight_PID = {
        Q_OUTPUT = 0,
        CSTART_OUTPUT = 0,
        output = 0,
        gain_scheduling = function ()
            local CURR_GW_T   = Math_clamp_lower(get(Gross_weight) / 1000, 60)
            local CURR_TAS    = FBW.filtered_sensors.TAS.filtered
            local VS1G_TAS    = get(Current_VS1G) * math.sqrt(1 / math.max(0.001, get(Weather_Sigma)))
            local CLEAN_TAS = Math_clamp(FBW.filtered_sensors.TAS.filtered, VS1G_TAS, 650)
            local FLAPS_TAS = Math_clamp(FBW.filtered_sensors.TAS.filtered, VS1G_TAS, 360)

            -----------------C* controller------------------
            local CLEAN = {
                P_MASS_K = function (MASS)
                    return -1.0000E-04 * MASS^2 + 3.1000E-02 * MASS - 5.0000E-01
                end,
                I_MASS_K = function (MASS)
                    return -4.2857E-05 * MASS^2 + 1.5857E-02 * MASS + 2.0229E-01
                end,
                D_MASS_K = function (MASS)
                    return -2.4286E-04 * MASS^2 + 5.9257E-02 * MASS - 1.6797E+00
                end,
                P = function (TAS)
                    return 1.7123E-11 * TAS^4 - 3.1191E-08 * TAS^3 + 2.0583E-05 * TAS^2 - 6.0785E-03 * TAS + 8.0815E-01
                end,
                I = function (TAS)
                    return 1.5767E-11 * TAS^4 - 2.9252E-08 * TAS^3 + 1.9797E-05 * TAS^2 - 6.0573E-03 * TAS + 8.7224E-01
                end,
                D = function (TAS)
                    return 4.8509E-12 * TAS^4 - 9.2272E-09 * TAS^3 + 6.2206E-06 * TAS^2 - 1.9643E-03 * TAS + 3.3176E-01
                end,

                FF_STABILITY_MASS_K = function (MASS)
                    return -1.0714E-04 * MASS^2 + 2.8643E-02 * MASS - 3.3229E-01
                end,
                FF_STABILITY = function (TAS)
                    return -2.6267E-09 * TAS^3 + 4.8873E-06 * TAS^2 - 3.7138E-03 * TAS + 1.6902E+00
                end,

                FF_FLAPS = function (FLAP_DEF)
                    if 0 <= FLAP_DEF and FLAP_DEF < 10 then
                        return 0.046
                    elseif 10 <= FLAP_DEF and FLAP_DEF < 14 then
                        return 0.047
                    elseif 14 <= FLAP_DEF and FLAP_DEF < 21 then
                        return 0.049
                    elseif 21 <= FLAP_DEF and FLAP_DEF <= 34 then
                        return 0.028
                    end
                end,
            }

            local FLAPS = {
                P_MASS_K = function (MASS)
                    return -5.7143E-05 * MASS^2 + 2.5343E-02 * MASS - 3.1429E-01
                end,
                I_MASS_K = function (MASS)
                    return -2.1429E-05 * MASS^2 + 1.3529E-02 * MASS + 2.6314E-01
                end,
                D_MASS_K = function (MASS)
                    return -6.4286E-05 * MASS^2 + 3.1386E-02 * MASS - 6.4857E-01
                end,
                P = function (TAS)
                    return 1.9568E-08 * TAS^3 - 1.1205E-05 * TAS^2 + 4.0228E-04 * TAS + 5.1876E-01
                end,
                I = function (TAS)
                    return 2.0265E-08 * TAS^3 - 1.1262E-05 * TAS^2 + 3.6100E-04 * TAS + 5.4884E-01
                end,
                D = function (TAS)
                    return 1.6341E-08 * TAS^3 - 7.4554E-06 * TAS^2 - 6.8971E-04 * TAS + 5.3366E-01
                end,

                FF_STABILITY_MASS_K = function (MASS)
                    return 5.3571E-04 * MASS^2 - 5.6214E-02 * MASS + 2.4514E+00
                end,
                FF_STABILITY = function (TAS)
                    return -1.6574E-07 * TAS^3 + 1.3705E-04 * TAS^2 - 4.3401E-02 * TAS + 6.2287E+00
                end,
            }

            -----------------C* CTL-------------------------
            FBW_PID_arrays.FBW_CSTAR_PID.P_gain = Math_rescale(
                0,
                Math_rescale(650, CLEAN.P(CLEAN_TAS), 850, 0, CURR_TAS) * CLEAN.P_MASS_K(CURR_GW_T),
                10,
                Math_rescale(360, FLAPS.P(FLAPS_TAS), 850, 0, CURR_TAS) * FLAPS.P_MASS_K(CURR_GW_T),
                get(Flaps_deployed_angle)
            )
            FBW_PID_arrays.FBW_CSTAR_PID.I_gain = Math_rescale(
                0,
                Math_rescale(650, CLEAN.I(CLEAN_TAS), 850, 0, CURR_TAS) * CLEAN.I_MASS_K(CURR_GW_T),
                10,
                Math_rescale(360, FLAPS.I(FLAPS_TAS), 850, 0, CURR_TAS) * FLAPS.I_MASS_K(CURR_GW_T),
                get(Flaps_deployed_angle)
            )
            FBW_PID_arrays.FBW_CSTAR_PID.D_gain = Math_rescale(
                0,
                Math_rescale(650, CLEAN.D(CLEAN_TAS), 850, 0, CURR_TAS) * CLEAN.D_MASS_K(CURR_GW_T),
                10,
                Math_rescale(360, FLAPS.D(FLAPS_TAS), 850, 0, CURR_TAS) * FLAPS.D_MASS_K(CURR_GW_T),
                get(Flaps_deployed_angle)
            )
            ------------------------------------------------

            -----------------STABILITY FEEDFWD--------------
            FBW_PID_arrays.CSTAR_STABILITY_FF.FF_gain = Math_rescale(
                0,
                Math_rescale(650, CLEAN.FF_STABILITY(CLEAN_TAS), 850, 0, CURR_TAS) * CLEAN.FF_STABILITY_MASS_K(CURR_GW_T),
                10,
                Math_rescale(360, FLAPS.FF_STABILITY(FLAPS_TAS), 850, 0, CURR_TAS) * FLAPS.FF_STABILITY_MASS_K(CURR_GW_T),
                get(Flaps_deployed_angle)
            )
            ------------------------------------------------

            -----------------FLAPS FEEDFWD------------------
            FBW_PID_arrays.CSTAR_FLAPS_FF.FF_gain = Math_rescale(
                650,
                CLEAN.FF_FLAPS(get(Flaps_deployed_angle)),
                850,
                0,
                CURR_TAS
            )
            ------------------------------------------------
        end,
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

            --[[FBW.vertical.controllers.Flight_PID.Q_OUTPUT = FBW_PID_BP(
                FBW_PID_arrays.FBW_PITCH_RATE_PID,
                FBW.vertical.inputs.Flight.Q_INPUT(),
                FBW.angular_rates.Theta.deg,
                FBW.filtered_sensors.IAS.filtered
            )]]

            -----------------------------------------------AoA CTL----------------------------------------------------
            PID_COMPUTE (
                FBW_PID_arrays.FBW_AoA_PID,
                Math_rescale(0, get(FMGEC_MIXED_Aprot_AoA), 1, get(FMGEC_MIXED_Amax_AoA), get(Total_input_pitch)),
                get(Alpha)
            )

            --[[PID_FF (
                FBW_PID_arrays.AoA_STABILITY_FF,
                FBW_PID_arrays.FBW_AoA_PID,
                get(IAS)
            )]]

            FBW.vertical.controllers.Flight_PID.Q_OUTPUT = PID_OUTPUT_FF(FBW_PID_arrays.FBW_AoA_PID)

            ------------------------------------------------C* CTL----------------------------------------------------
            PID_COMPUTE (
                FBW_PID_arrays.FBW_CSTAR_PID,
                FBW.vertical.inputs.Flight.CSTAR_INPUT(get(Total_input_pitch)),
                FBW.vertical.dynamics.GET_CSTAR(FBW.vertical.dynamics.Path_Load_Factor("z"), get(Flightmodel_q))
            )

            PID_FF (
                FBW_PID_arrays.CSTAR_STABILITY_FF,
                FBW_PID_arrays.FBW_CSTAR_PID,
                (FBW.vertical.dynamics.Path_Load_Factor("z") < 0.9 or FBW.vertical.dynamics.Path_Load_Factor("z") > 1.2) -- only while maneuvering
                and (FBW.vertical.dynamics.GET_MANEUVER_Q(FBW.vertical.dynamics.Path_Load_Factor("z")) - get(Flightmodel_q))
                or 0
            )

            PID_FF (
                FBW_PID_arrays.CSTAR_FLAPS_FF,
                FBW_PID_arrays.FBW_CSTAR_PID,
                get(Flaps_deployed_angle)
            )

            FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT = PID_OUTPUT_FF (FBW_PID_arrays.FBW_CSTAR_PID)
            ----------------------------------------------------------------------------------------------------------

            --[[print("SP AoA " .. Round_fill(Math_rescale(0, get(FMGEC_MIXED_Aprot_AoA), 1, get(FMGEC_MIXED_Amax_AoA), get(Total_input_pitch)), 2))

            print("C* " .. Round_fill(FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT, 2), "AoA " .. Round_fill(FBW.vertical.controllers.Flight_PID.Q_OUTPUT, 2))

            if FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT > FBW.vertical.controllers.Flight_PID.Q_OUTPUT then
                print("AoA")
            else
                print("C*")
            end]]

            if get(FBW_vertical_law) == FBW_NORMAL_LAW then
                FBW.vertical.controllers.Flight_PID.output = math.min(
                    FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT,
                    FBW.vertical.controllers.Flight_PID.Q_OUTPUT
                )
            else
                FBW.vertical.controllers.Flight_PID.output = FBW.vertical.controllers.Flight_PID.CSTART_OUTPUT
            end
        end,
        bp = function ()
            FBW_PID_arrays.FBW_CSTAR_PID.Actual_output = ELEV_BP()
            FBW_PID_arrays.FBW_AoA_PID.Actual_output = ELEV_BP()
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

            if get(FBW_vertical_law) ~= FBW_NORMAL_LAW and get(FBW_vertical_law) ~= FBW_ABNORMAL_LAW then--alt law <-> direct law
                FBW.vertical.controllers.Flare_PID.output = get(Total_input_pitch)
                return
            end

            FBW.vertical.controllers.Flare_PID.output = FBW_PID_BP(
                FBW_PID_arrays.FBW_PITCH_RATE_PID,
                FBW.vertical.inputs.Flare.INPUT(get(Total_input_pitch)),
                FBW.angular_rates.Theta.deg,
                FBW.filtered_sensors.IAS.filtered
            )
        end,
        bp = function ()
            FBW_PID_arrays.FBW_PITCH_RATE_PID.Actual_output = ELEV_BP()
        end,
    },

    AUTOTRIM_PID = {
        output = 0,
        bumpless_transfer = function ()
            --FBW_PID_arrays.FBW_CSTAR_PID.Integral = 0
        end,
        elevator_pos = function ()
            local L_ELEV_OK = FCTL.ELEV.STAT.L.controlled
            local R_ELEV_OK = FCTL.ELEV.STAT.R.controlled

            local EVEL_DEF = 0

            if L_ELEV_OK and R_ELEV_OK then
                EVEL_DEF = (get(L_elevator) + get(R_elevator)) / 2
            elseif L_ELEV_OK and not R_ELEV_OK then
                EVEL_DEF = get(L_elevator)
            elseif not L_ELEV_OK and R_ELEV_OK then
                EVEL_DEF = get(R_elevator)
            else
                EVEL_DEF = (get(L_elevator) + get(R_elevator)) / 2
            end

            return EVEL_DEF
        end,
        control = function ()
            if math.abs(adirs_get_avg_roll()) > 33 or
               get(Human_pitch_trim) ~= 0 or
               get(FBW_vertical_flight_mode_ratio) ~= 1 or
               FBW.filtered_sensors.IAS.filtered > get(Fixed_VMAX) or
               get(Total_vertical_g_load) < 0.5 or
               (get(FBW_vertical_law) ~= FBW_NORMAL_LAW and FBW.filtered_sensors.IAS.filtered < get(VLS)) or
               get(FBW_ABN_LAW_TRIM_INHIB) == 1 then
                return
            end

            --enter limited trim range modes
            local LAST_TRIM_LIM_STATUS = get(THS_range_limited)
            set(THS_range_limited, 0)
            if get(FBW_vertical_law) == FBW_NORMAL_LAW then
                if FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE then
                    set(THS_range_limited, 1)
                elseif get(Total_vertical_g_load) > 1.25 then
                    set(THS_range_limited, 1)
                end
            end

            --memorise entry position
            if get(THS_range_limited) - LAST_TRIM_LIM_STATUS == 1 then
                set(THS_limit_def, get(THS_DEF))
            end

            --pulse THS--
            local ELEV_INPUT = FBW.vertical.controllers.AUTOTRIM_PID.elevator_pos()
            if math.abs(ELEV_INPUT) <= 0.38 then
                ELEV_INPUT = 0
            end

            ------------------------------------------------AUTO TRIM-------------------------------------------------
            PID_COMPUTE (
                FBW_PID_arrays.FBW_AUTOTRIM_PID,
                0,
                ELEV_INPUT
            )

            FBW.vertical.controllers.AUTOTRIM_PID.output = PID_OUTPUT_NRM(FBW_PID_arrays.FBW_AUTOTRIM_PID)
            ----------------------------------------------------------------------------------------------------------

            --stop the THS--
            if ELEV_INPUT == 0 then
                set(Digital_THS_def_tgt, get(THS_DEF))
            else
                set(Digital_THS_def_tgt, FBW.vertical.controllers.AUTOTRIM_PID.output)
            end
        end,
        bp = function ()
            FBW_PID_arrays.FBW_AUTOTRIM_PID.Actual_output = get(THS_DEF)
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