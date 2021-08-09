FBW.vertical.inputs = {
    X_to_G = function (x)
        local max_G = get(Flaps_internal_config) > 1 and 2 or 2.5
        local min_G = get(Flaps_internal_config) > 1 and 0 or -1

        local G_load_input_table = {
            {-1, min_G},
            {0,  FBW.vertical.dynamics.neutral_flight_G()},
            {1,  max_G},
        }

        return Table_interpolate(G_load_input_table, x)
    end,

    G_to_CSTAR = function (G)
        local max_G = get(Flaps_internal_config) > 1 and 2 or 2.5
        local min_G = get(Flaps_internal_config) > 1 and 0 or -1

        local neutral_nz = FBW.vertical.dynamics.neutral_flight_G()

        local C_star_input_table = {
            {min_G,      FBW.vertical.dynamics.MIN_CSTAR()},
            {neutral_nz,                        neutral_nz},
            {max_G,      FBW.vertical.dynamics.MAX_CSTAR()},
        }

        local C_STAR_OUTPUT = Table_interpolate(C_star_input_table, G)

        --ALT LAW LIMIT Q to 5 deg/s (AMM)--
        local LO_ALT_Q_LIM = FBW.vertical.dynamics.GET_CSTAR(get(Total_vertical_g_load), -5)
        local HI_ALT_Q_LIM = FBW.vertical.dynamics.GET_CSTAR(get(Total_vertical_g_load),  5)
        if get(FBW_total_control_law) ~= FBW_NORMAL_LAW then
            C_STAR_OUTPUT = math.max(math.min(C_STAR_OUTPUT, HI_ALT_Q_LIM), LO_ALT_Q_LIM)
        end

        return C_STAR_OUTPUT
    end,

    Rotation = {
        INPUT = function (X)
            local MAX_Q = 6
            local OUT_Q = MAX_Q * math.abs(math.cos(math.rad(adirs_get_avg_roll()))) * X

            --PROT--
            if get(FBW_total_control_law) ~= FBW_ABNORMAL_LAW then
                OUT_Q = FBW.vertical.protections.Rotation.AoA(X, OUT_Q)
                OUT_Q = FBW.vertical.protections.Rotation.Pitch(OUT_Q)
            end

            --BP AoA Q demand PID
            FBW_PID_arrays.FBW_ROTATION_APROT_PID.Actual_output = FBW.rates.Pitch.x

            return OUT_Q
        end
    },

    Flight = {
        Q_INPUT = function ()
            --PROT--
            local Q = FBW.vertical.protections.General.AoA.G.Q_DEMAND(FBW_PID_arrays.FBW_FLIGHT_APROT_PID)
            Q = FBW.vertical.protections.Flight.Q_Pitch(Q)

            --BP AoA Q demand PID
            FBW_PID_arrays.FBW_FLIGHT_APROT_PID.Actual_output = FBW.rates.Pitch.x

            return Q
        end,
        CSTAR_INPUT = function (X)
            local INPUT_X = X

            --REDUCED PROT--
            if get(FBW_vertical_law) == FBW_ALT_REDUCED_PROT_LAW then
                INPUT_X = FBW.vertical.protections.ALT_prot.VMAX(INPUT_X)
                INPUT_X = FBW.vertical.protections.ALT_prot.VLS(INPUT_X)
            end

            --convert sidestick to G load
            local INPUT_G = FBW.vertical.inputs.X_to_G(INPUT_X)

            --NRM PROT--
            if get(FBW_vertical_law) == FBW_NORMAL_LAW then
                INPUT_G = FBW.vertical.protections.Flight.HSP.PROT(INPUT_G)
                INPUT_G = FBW.vertical.protections.Flight.AoA(INPUT_G)
                INPUT_G = FBW.vertical.protections.Flight.G_Pitch(INPUT_G)
            end

            return FBW.vertical.inputs.G_to_CSTAR(INPUT_G)
        end,
    },

    Flare = {
        INPUT = function (X)
            local MAX_Q = 3
            local PITCH = adirs_get_avg_pitch()

            --Q demand blending
            local Q_table = {
                {-1, MAX_Q},
                {0,  -get(FBW_flare_mode_computed_Q)},
                {1,  MAX_Q},
            }

            --the threshold for max pitch rate demand to happen to snap back to the demanded ATT
            local Q_SP_table = {
                {-5, -Table_interpolate(Q_table, X)},
                {0,  0},
                {5,   Table_interpolate(Q_table, X)},
            }

            --ATT demand
            local ATT_SP_table = {
                {-1, -22},
                {0,   -2},
                {1,   get(Ground_spoilers_mode) == 2 and 7 or 18},
            }
            local ATT_SP = Table_interpolate(ATT_SP_table, X)
            --Q demand
            local OUT_Q = Table_interpolate(Q_SP_table, ATT_SP - PITCH)

            --PROT--
            if get(FBW_total_control_law) ~= FBW_ABNORMAL_LAW then
                OUT_Q = FBW.vertical.protections.Flare.AoA(X, OUT_Q)
            end

            --BP AoA Q demand PID
            FBW_PID_arrays.FBW_FLARE_APROT_PID.Actual_output = FBW.rates.Pitch.x

            return OUT_Q
        end
    }
}