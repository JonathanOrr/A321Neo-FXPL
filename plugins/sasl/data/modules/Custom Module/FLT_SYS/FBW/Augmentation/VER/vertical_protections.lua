FBW.vertical.protections = {
    General = {
        Pitch = {
            MAX = 30,
            MIN = -15,
            --compute upper limit
            UP_LIM = function ()
                local MAX_PITCH = 30
                local CLEAN_REDUCED_PITCH = 25
                local MAX_FULL_FLAP_PITCH = 25
                local FULL_REDUCED_PITCH = 20

                --flap & speed pitch reduction
                if get(Flaps_internal_config) < 5 then
                    MAX_PITCH = Math_rescale(
                        0,
                        MAX_PITCH,
                        20,
                        CLEAN_REDUCED_PITCH,
                        get(VLS) - FBW.filtered_sensors.IAS.filtered
                    )
                end
                if get(Flaps_internal_config) == 5 then
                    MAX_PITCH = Math_rescale(
                        0,
                        MAX_FULL_FLAP_PITCH,
                        20,
                        FULL_REDUCED_PITCH,
                        get(VLS) - FBW.filtered_sensors.IAS.filtered
                    )
                end

                --tail strike protection
                local TAILSTRIKE_PITCH = 9.7
                MAX_PITCH = Math_rescale(
                    0,
                    MAX_PITCH,
                    1,
                    --RA alt--
                    Math_rescale(
                        0,
                        --sidestick input--
                        Math_rescale(
                            3/4,
                            TAILSTRIKE_PITCH,
                            1,
                            MAX_PITCH,
                            get(Total_input_pitch)
                        ),
                        15,
                        MAX_PITCH,
                        RA_sys.all_RA_user()
                    ),
                    get(FBW_vertical_rotation_mode_ratio)
                )

                --Output computed pitch
                FBW.vertical.protections.General.Pitch.MAX = MAX_PITCH
            end,

            --general input limit
            LIM_INPUT = function (X, INIT_MARGIN, UP_RETURN, DN_RETURN, NEUTRAL_X)
                --properties
                local PITCH = adirs_get_avg_pitch()
                local MAX_PITCH = FBW.vertical.protections.General.Pitch.MAX
                local MIN_PITCH = FBW.vertical.protections.General.Pitch.MIN

                --check for pitch exceedence
                local DN_LIM = Math_rescale(MIN_PITCH - INIT_MARGIN, 2, MIN_PITCH + INIT_MARGIN, 0, PITCH)
                local UP_LIM = Math_rescale(MAX_PITCH - INIT_MARGIN, 0, MAX_PITCH + INIT_MARGIN, 2, PITCH)

                --rescale input--
                local DN_LIM_table = {
                    {0, X},
                    {1, math.max(NEUTRAL_X, X)},
                    {2, math.max(X, UP_RETURN)},
                }
                local X_limited = Table_interpolate(DN_LIM_table, DN_LIM)

                local UP_LIM_table = {
                    {0, X_limited},
                    {1, math.min(X_limited, NEUTRAL_X)},
                    {2, math.min(X_limited, DN_RETURN)},
                }
                X_limited = Table_interpolate(UP_LIM_table, UP_LIM)

                return X_limited
            end
        },

        AoA = {
            H_AOA_PROT_ACTIVE = false,
            AOA_V_SP = 0,
            AOA_SP = 0,
            COMPUTE_SP = function (X)
                local entry_margin = 1
                local time_to_move_demand = 2.5

                --set alpha/V demand target
                local target_V   = get(FMGEC_MIXED_Vaprot_VSW)
                local target_AoA = get(FMGEC_MIXED_Aprot_AoA)
                if FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE then
                    target_V   = Math_rescale(0, get(FMGEC_MIXED_Vaprot_VSW), 1, get(FMGEC_MIXED_Valpha_MAX), X)
                    target_AoA = Math_rescale(0,         get(FMGEC_MIXED_Aprot_AoA), 1,          get(FMGEC_MIXED_Amax_AoA), X)
                end

                --set output--
                FBW.vertical.protections.General.AoA.AOA_V_SP = Set_linear_anim_value(FBW.vertical.protections.General.AoA.AOA_V_SP, target_V, 0, 1000, 1 / time_to_move_demand)
                FBW.vertical.protections.General.AoA.AOA_V_SP = math.min(math.max(FBW.vertical.protections.General.AoA.AOA_V_SP, get(FMGEC_MIXED_Vaprot_VSW)), get(FMGEC_MIXED_Valpha_MAX))
                FBW.vertical.protections.General.AoA.AOA_SP   = Set_linear_anim_value(FBW.vertical.protections.General.AoA.AOA_SP, target_AoA, 0, 100, 1 / time_to_move_demand)
                FBW.vertical.protections.General.AoA.AOA_SP   = math.min(math.max(FBW.vertical.protections.General.AoA.AOA_SP, get(FMGEC_MIXED_Aprot_AoA)), get(FMGEC_MIXED_Amax_AoA))
            end,

            Q = {
                LIM = function (X, Q, CLAMP_MARGIN, MIN_Q, MAX_Q, pid_array)
                    --exit if any gears on ground--
                    if get(Any_wheel_on_ground) == 1 then
                        return Q
                    end

                    --properties
                    local ENTRY_MARGIN = 1--degs of AoA prior to aprot
                    local MAX_ALPHA_DEMAND_Q = 4--degs of AoA prior to aprot
                    local AOA_V_SP = FBW.vertical.protections.General.AoA.AOA_V_SP
                    local AOA_SP = FBW.vertical.protections.General.AoA.AOA_SP
                    local FILTERED_AOA = FBW.filtered_sensors.AoA.filtered
                    local FILTERED_IAS = FBW.filtered_sensors.IAS.filtered

                    --demand Q to reach Alpha--
                    local V_demand_Q = Math_rescale(0, 0, 30, -MAX_ALPHA_DEMAND_Q, AOA_V_SP - FILTERED_IAS)
                    local alpha_demand_Q = FBW_PID_BP(pid_array, AOA_SP, adirs_get_avg_aoa()) + V_demand_Q
                    --summing V demand into the desire for correct BP
                    if get(DELTA_TIME) ~= 0 then
                        pid_array.Desired_output = pid_array.Desired_output + V_demand_Q
                    end
                    alpha_demand_Q = Math_clamp(alpha_demand_Q, -MAX_ALPHA_DEMAND_Q, MAX_ALPHA_DEMAND_Q)

                    --blend ratio between the inputed Q and the alpha demand Q--
                    local blend_ratio = Math_rescale(get(FMGEC_MIXED_Aprot_AoA) - ENTRY_MARGIN, 0, get(FMGEC_MIXED_Aprot_AoA), 1, FILTERED_AOA)
                    blend_ratio = Math_rescale(-0.5, 0, 0, blend_ratio, X)
                    --CHECK H_AOA_PROT STATUS--
                    if blend_ratio == 0 then
                        FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE = false
                    end
                    if blend_ratio == 1 then
                        FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE = true
                    end

                    --adjust upper clamp limit [clamp the Q input before reaching aprot]
                    local UP_Q_LIM = Math_rescale(0, MIN_Q, CLAMP_MARGIN, MAX_Q, AOA_SP - FILTERED_AOA)
                    --clamped entered Q--
                    local CLAMPED_Q = Math_clamp_higher(Q, UP_Q_LIM)

                    --rescale into into Q and output--
                    return Math_rescale(0, CLAMPED_Q, 1, alpha_demand_Q, blend_ratio)
                end,
            },

            G = {
                ENTERY_RATIO = function (x)
                    local FILTERED_AOA = FBW.filtered_sensors.AoA.filtered

                    --properties
                    local ENTRY_MARGIN = 1

                    local blend_ratio = Math_rescale(get(FMGEC_MIXED_Aprot_AoA) - ENTRY_MARGIN, 0, get(FMGEC_MIXED_Aprot_AoA), 1, FILTERED_AOA)
                    blend_ratio = Math_rescale(-0.5, 0, 0, blend_ratio, x)
                    --CHECK H_AOA_PROT STATUS--
                    if blend_ratio == 0 then
                        FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE = false
                    end
                    if blend_ratio == 1 then
                        FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE = true
                    end

                    return blend_ratio
                end,
                CLAMP_INPUT = function (G, CLAMP_MARGIN, MIN_G, MAX_G)
                    local AOA_SP = FBW.vertical.protections.General.AoA.AOA_SP
                    local FILTERED_AOA = FBW.filtered_sensors.AoA.filtered

                    --adjust upper clamp limit
                    local UP_G_LIM = Math_rescale(-0.5, MIN_G, CLAMP_MARGIN, MAX_G, AOA_SP - FILTERED_AOA)
                    local CLAMPED_G = Math_clamp_higher(G, UP_G_LIM)

                    return G
                end,
                Q_DEMAND = function (pid_array)
                    local MAX_ALPHA_DEMAND_Q = 4--degs of AoA prior to aprot
                    local AOA_V_SP = FBW.vertical.protections.General.AoA.AOA_V_SP
                    local AOA_SP = FBW.vertical.protections.General.AoA.AOA_SP
                    local FILTERED_AOA = FBW.filtered_sensors.AoA.filtered
                    local FILTERED_IAS = FBW.filtered_sensors.IAS.filtered

                    --demand Q to reach Alpha--
                    local V_demand_Q = Math_rescale(0, 0, 30, -MAX_ALPHA_DEMAND_Q, AOA_V_SP - FILTERED_IAS)
                    local alpha_demand_Q = FBW_PID_BP(pid_array, AOA_SP, FILTERED_AOA) + V_demand_Q
                    --summing V demand into the desire for correct BP
                    if get(DELTA_TIME) ~= 0 then
                        pid_array.Desired_output = pid_array.Desired_output + V_demand_Q
                    end
                    alpha_demand_Q = Math_clamp(alpha_demand_Q, -MAX_ALPHA_DEMAND_Q, MAX_ALPHA_DEMAND_Q)

                    return alpha_demand_Q
                end,
            }
        },
    },

    ALT_prot = {
        VMAX = function (X)
            local UP_RATIO = Math_rescale(-0.2, X, 0, math.max(0.15, X), X)

            local PROT_X = Math_rescale(get(Fixed_VMAX), X, get(VMAX_demand) + 15, UP_RATIO, FBW.filtered_sensors.IAS.filtered)

            return PROT_X
        end,
        VSW = function (X)
            local DN_RATIO = Math_rescale(0, math.min(-0.1, X), 0.2, X, X)

            local PROT_X = Math_rescale(get(FMGEC_MIXED_Vaprot_VSW) - 10, DN_RATIO, get(FMGEC_MIXED_Vaprot_VSW), X, FBW.filtered_sensors.IAS.filtered)

            return PROT_X
        end,
    },

    Rotation = {
        Pitch = function (Q)
            local INIT_MARGIN = 8
            local UP_return_Q = 2
            local DN_return_Q = -2

            return FBW.vertical.protections.General.Pitch.LIM_INPUT(Q, INIT_MARGIN, UP_return_Q, DN_return_Q, 0)
        end,

        AoA = function (X, Q)
            local MAX_Q_LIM = 6
            local MIN_Q_LIM = 3
            local CLAMP_MARGIN = 5

            return FBW.vertical.protections.General.AoA.Q.LIM(X, Q, CLAMP_MARGIN, MIN_Q_LIM, MAX_Q_LIM, FBW_PID_arrays.FBW_ROTATION_APROT_PID)
        end
    },

    Flight = {
        Q_Pitch = function (Q)
            local INIT_MARGIN = 8
            local UP_return_Q = 2
            local DN_return_Q = -2

            return FBW.vertical.protections.General.Pitch.LIM_INPUT(Q, INIT_MARGIN, UP_return_Q, DN_return_Q, 0)
        end,

        G_Pitch = function (G)
            local INIT_MARGIN = 8
            local UP_return_G = 2.5
            local DN_return_G = 0

            return FBW.vertical.protections.General.Pitch.LIM_INPUT(G, INIT_MARGIN, UP_return_G, DN_return_G, FBW.vertical.dynamics.NEU_FLT_G())
        end,

        HSP = {
            ACTIVE = false,
            PROT = function (G)
                local UP_return_G = FBW.vertical.dynamics.NEU_FLT_G_NO_LIM() * 1.72
                local INIT_MARGIN = 10

                local HSP_G = Math_rescale(
                    get(Fixed_VMAX),
                    G,
                    get(VMAX_demand) + INIT_MARGIN,
                    math.max(UP_return_G, G),
                    FBW.filtered_sensors.IAS.filtered
                )

                --CHECK HSP STATUS--
                if FBW.filtered_sensors.IAS.filtered >= get(VMAX_prot) then
                    FBW.vertical.protections.Flight.HSP.ACTIVE = true
                end
                if FBW.filtered_sensors.IAS.filtered < get(Fixed_VMAX) then
                    FBW.vertical.protections.Flight.HSP.ACTIVE = false
                end

                return HSP_G
            end
        },

        AoA = function (G)
            local MAX_G_LIM = 2.5
            local MIN_G_LIM = FBW.vertical.dynamics.NEU_FLT_G()
            local CLAMP_MARGIN = 6

            return FBW.vertical.protections.General.AoA.G.CLAMP_INPUT(G, CLAMP_MARGIN, MIN_G_LIM, MAX_G_LIM)
        end
    },

    Flare = {
        AoA = function (X, Q)
            local MAX_Q_LIM = 3
            local MIN_Q_LIM = 1.5
            local CLAMP_MARGIN = 3

            return FBW.vertical.protections.General.AoA.Q.LIM(X, Q, CLAMP_MARGIN, MIN_Q_LIM, MAX_Q_LIM, FBW_PID_arrays.FBW_ROTATION_APROT_PID)
        end
    },
}