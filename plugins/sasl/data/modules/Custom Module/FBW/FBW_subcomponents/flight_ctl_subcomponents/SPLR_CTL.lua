FBW.fctl.control.SPLR_COMMON = {
    SPLR_PER_WING = 5,
    SPLR_SPDBRK_MAX_GRD_DEF = {6, 20, 40, 40, 0},
    SPLR_SPDBRK_MAX_AIR_DEF = {0, 25, 25, 25, 0},
    SPLR_SPDBRK_GRD_SPD = {15, 15, 15, 15, 15},
    SPLR_SPDBRK_AIR_SPD = {5, 5, 5, 5, 5},
    SPLR_SPDBRK_HIGHSPD_AIR_SPD = {1, 1, 1, 1, 1},
    NO_HYD_SPD = 4,
    NO_HYD_RECENTER_TAS = 80,
    L_SPLR_DATAREFS = {L_SPLR_1, L_SPLR_2, L_SPLR_3, L_SPLR_4, L_SPLR_5},
    R_SPLR_DATAREFS = {R_SPLR_1, R_SPLR_2, R_SPLR_3, R_SPLR_4, R_SPLR_5},

    SPLR_SPDBRK_MAX_DEF = {6, 20, 40, 40, 0},
    SPLR_SPDBRK_MAX_SPD = {6, 20, 40, 40, 0},

    COMPUTE_SPDBRK_MAX_DEF = function ()
        if get(Aft_wheel_on_ground) == 1 then
            --speed up ground spoilers deflection
            FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD = FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_GRD_SPD

            --on ground and slightly open spoiler 1 with speedbrake handle
            FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_DEF = FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_GRD_DEF
        else
            --slow down the spoilers for flight
            FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD = FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_AIR_SPD

            --adujust max in air deflection of the speedbrakes
            FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_DEF = FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_AIR_DEF
        end
    end,

    Get_cmded_spdbrk_def = function (spdbrk_input)
        spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

        local total_cmded_def = 0
        for i = 1, FBW.fctl.control.SPLR_COMMON.SPLR_PER_WING do
            total_cmded_def = total_cmded_def + FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_DEF[i] * spdbrk_input * 2
        end

        return total_cmded_def
    end,
}

-------------------------------------------------------------------------------
-- ROLL SPOILERS & SPD BRAKES
-------------------------------------------------------------------------------
FBW.fctl.control.SPLR = function (lateral_input, spdbrk_input, ground_spoilers_mode, in_auto_flight)
    --during a touch and go one of the thrust levers has to be advanced beyond 20 degrees to disarm the spoilers

    --DATAREFS FOR SURFACES
    local SPLR_PER_WING = FBW.fctl.control.SPLR_COMMON.SPLR_PER_WING
    local L_SPLR_DATAREFS = FBW.fctl.control.SPLR_COMMON.L_SPLR_DATAREFS
    local R_SPLR_DATAREFS = FBW.fctl.control.SPLR_COMMON.R_SPLR_DATAREFS

    local L_SPLR_HYD_PRESS = {
        FBW.fctl.surfaces.splr.L[1].total_hyd_press,
        FBW.fctl.surfaces.splr.L[2].total_hyd_press,
        FBW.fctl.surfaces.splr.L[3].total_hyd_press,
        FBW.fctl.surfaces.splr.L[4].total_hyd_press,
        FBW.fctl.surfaces.splr.L[5].total_hyd_press,
    }
    local R_SPLR_HYD_PRESS = {
        FBW.fctl.surfaces.splr.R[1].total_hyd_press,
        FBW.fctl.surfaces.splr.R[2].total_hyd_press,
        FBW.fctl.surfaces.splr.R[3].total_hyd_press,
        FBW.fctl.surfaces.splr.R[4].total_hyd_press,
        FBW.fctl.surfaces.splr.R[5].total_hyd_press,
    }

    local L_SPLR_CONTROLLED = {
        FBW.fctl.surfaces.splr.L[1].controlled,
        FBW.fctl.surfaces.splr.L[2].controlled,
        FBW.fctl.surfaces.splr.L[3].controlled,
        FBW.fctl.surfaces.splr.L[4].controlled,
        FBW.fctl.surfaces.splr.L[5].controlled,
    }
    local R_SPLR_CONTROLLED = {
        FBW.fctl.surfaces.splr.R[1].controlled,
        FBW.fctl.surfaces.splr.R[2].controlled,
        FBW.fctl.surfaces.splr.R[3].controlled,
        FBW.fctl.surfaces.splr.R[4].controlled,
        FBW.fctl.surfaces.splr.R[5].controlled,
    }

    local L_SPLR_FAIL = {
        FAILURE_FCTL_LSPOIL_1,
        FAILURE_FCTL_LSPOIL_2,
        FAILURE_FCTL_LSPOIL_3,
        FAILURE_FCTL_LSPOIL_4,
        FAILURE_FCTL_LSPOIL_5
    }
    local R_SPLR_FAIL = {
        FAILURE_FCTL_RSPOIL_1,
        FAILURE_FCTL_RSPOIL_2,
        FAILURE_FCTL_RSPOIL_3,
        FAILURE_FCTL_RSPOIL_4,
        FAILURE_FCTL_RSPOIL_5
    }

    --limit input range
    spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

    --properties
    local ROLL_SPLR_THRESHOLD = {0.1, 0.1, 0.3, 0.1, 0.1}--amount of sidestick deflection needed to trigger the roll spoilers

    --constant speeds--
    local SPLR_TOTAL_MAX_DEF = {40, 40, 40, 40, 40}
    local SPLR_ROLL_MAX_DEF = {0, 35, 7, 35, 35}
    local SPLR_SPDBRK_MAX_DEF = FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_DEF

    --actual speeds--
    local L_SPLR_SPDBRK_SPD = {
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[1],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[2],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[3],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[4],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[5],
    }
    local R_SPLR_SPDBRK_SPD = {
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[1],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[2],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[3],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[4],
        FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_MAX_SPD[5],
    }
    local L_SPLR_ROLL_SPD = {0, 40, 40, 40, 40}
    local R_SPLR_ROLL_SPD = {0, 40, 40, 40, 40}

    local LOCAL_AIRSPD_KTS = get(TAS_ms) * 1.94384
    local NO_HYD_SPD = Math_rescale(0, 0, FBW.fctl.control.SPLR_COMMON.NO_HYD_RECENTER_TAS, FBW.fctl.control.SPLR_COMMON.NO_HYD_SPD, LOCAL_AIRSPD_KTS)

    --targets--
    local L_SPLR_SPDBRK_TGT = {0, 0, 0, 0, 0}
    local R_SPLR_SPDBRK_TGT = {0, 0, 0, 0, 0}
    local L_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}
    local R_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}

    --SPOILERS & SPDBRAKES SPD CALCULATION------------------------------------------------------------------------
    --reduce speedbrakes retraction speeds in high speed conditions
    if (adirs_get_avg_ias()>= 315 or adirs_get_avg_mach() >= 0.75) and in_auto_flight then
        --check if any spoilers are retracting and slow down accordingly
        for i = 1, SPLR_PER_WING do
            if L_SPLR_SPDBRK_TGT[i] < get(L_SPLR_DATAREFS[i]) then
                L_SPLR_SPDBRK_SPD[i] = FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_HIGHSPD_AIR_SPD[i]
            end
            if R_SPLR_SPDBRK_TGT[i] < get(R_SPLR_DATAREFS[i])then
                R_SPLR_SPDBRK_SPD[i] = FBW.fctl.control.SPLR_COMMON.SPLR_SPDBRK_HIGHSPD_AIR_SPD[i]
            end
        end
    end

    --detect if hydraulics power is avail to the surfaces then accordingly slow down the speed
    for i = 1, SPLR_PER_WING do
        --speedbrkaes
        L_SPLR_SPDBRK_SPD[i] = L_SPLR_HYD_PRESS[i] >= 1450 and L_SPLR_SPDBRK_SPD[i] or NO_HYD_SPD
        R_SPLR_SPDBRK_SPD[i] = R_SPLR_HYD_PRESS[i] >= 1450 and R_SPLR_SPDBRK_SPD[i] or NO_HYD_SPD
        --roll spoilers
        L_SPLR_ROLL_SPD[i] = L_SPLR_HYD_PRESS[i] >= 1450 and L_SPLR_ROLL_SPD[i] or 0
        R_SPLR_ROLL_SPD[i] = R_SPLR_HYD_PRESS[i] >= 1450 and R_SPLR_ROLL_SPD[i] or 0
    end

    --JAMMING--
    for i = 1, SPLR_PER_WING do
        L_SPLR_SPDBRK_SPD[i] = L_SPLR_SPDBRK_SPD[i] * (1 - get(L_SPLR_FAIL[i]))
        R_SPLR_SPDBRK_SPD[i] = R_SPLR_SPDBRK_SPD[i] * (1 - get(R_SPLR_FAIL[i]))
        L_SPLR_ROLL_SPD[i] = L_SPLR_ROLL_SPD[i] * (1 - get(L_SPLR_FAIL[i]))
        R_SPLR_ROLL_SPD[i] = R_SPLR_ROLL_SPD[i] * (1 - get(R_SPLR_FAIL[i]))
    end

    --SPOILERS & SPDBRAKES TARGET CALCULATION------------------------------------------------------------------------
    --DEFLECTION TARGET CALCULATION--
    for i = 1, SPLR_PER_WING do
        --speedbrakes
        L_SPLR_SPDBRK_TGT[i] = SPLR_SPDBRK_MAX_DEF[i] * spdbrk_input
        R_SPLR_SPDBRK_TGT[i] = SPLR_SPDBRK_MAX_DEF[i] * spdbrk_input
        --roll spoilers
        L_SPLR_ROLL_TGT[i] = Math_rescale(-1, SPLR_ROLL_MAX_DEF[i], -ROLL_SPLR_THRESHOLD[i], 0, lateral_input)
        R_SPLR_ROLL_TGT[i] = Math_rescale( ROLL_SPLR_THRESHOLD[i], 0,  1, SPLR_ROLL_MAX_DEF[i], lateral_input)
    end

    --SPEEDBRAKES INHIBITION--
    if get(Speedbrake_handle_ratio) >= 0 and get(Speedbrake_handle_ratio) <= 0.1 then
        set(Speedbrakes_inhibited, 0)
    end

    --lacking upon a.prot toga [and restoring speedbrake avail by reseting the lever position]
    if get(Bypass_speedbrakes_inhibition) ~= 1 then
        if get(SEC_1_status) == 0 and get(SEC_3_status) == 0 then
            set(Speedbrakes_inhibited, 1)
        end
        if not FBW.fctl.surfaces.elev.L.controlled or not FBW.fctl.surfaces.elev.R.controlled then
            set(Speedbrakes_inhibited, 1)
        end
        if FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE then
            set(Speedbrakes_inhibited, 1)
        end
        if get(Flaps_internal_config) >= 4 then
            set(Speedbrakes_inhibited, 1)
        end
        if get(Cockpit_throttle_lever_L) >= THR_MCT_START or get(Cockpit_throttle_lever_R) >= THR_MCT_START then
            set(Speedbrakes_inhibited, 1)
        end
    end

    if get(Speedbrakes_inhibited) == 1 and get(Bypass_speedbrakes_inhibition) ~= 1 then
        L_SPLR_SPDBRK_TGT = {0, 0, 0, 0, 0}
        R_SPLR_SPDBRK_TGT = {0, 0, 0, 0, 0}
    end

    --GROUND SPOILERS MODE--
    --0 = NOT EXTENDED
    --1 = PARCIAL EXTENTION
    --2 = FULL EXTENTION
    if ground_spoilers_mode == 1 then
        L_SPLR_SPDBRK_TGT = {10, 10, 10, 10, 10}
        R_SPLR_SPDBRK_TGT = {10, 10, 10, 10, 10}
    elseif ground_spoilers_mode == 2 then
        L_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}
        R_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}
        L_SPLR_SPDBRK_TGT = {40, 40, 40, 40, 40}
        R_SPLR_SPDBRK_TGT = {40, 40, 40, 40, 40}
    end

    --if the aircraft is in roll direct law change the roll spoiler deflections to limit roll rate
    if get(FBW_lateral_law) == FBW_DIRECT_LAW and (FBW.fctl.surfaces.ail.L.controlled or FBW.fctl.surfaces.ail.R.controlled) then
        if FBW.fctl.surfaces.splr.L[4].controlled then
            L_SPLR_ROLL_TGT[1] = 0
            L_SPLR_ROLL_TGT[2] = 0
            L_SPLR_ROLL_TGT[3] = 0
        else
            L_SPLR_ROLL_TGT[1] = 0
            L_SPLR_ROLL_TGT[2] = 0
            L_SPLR_ROLL_TGT[4] = 0
        end
        if FBW.fctl.surfaces.splr.R[4].controlled then
            R_SPLR_ROLL_TGT[1] = 0
            R_SPLR_ROLL_TGT[2] = 0
            R_SPLR_ROLL_TGT[3] = 0
        else
            R_SPLR_ROLL_TGT[1] = 0
            R_SPLR_ROLL_TGT[2] = 0
            R_SPLR_ROLL_TGT[4] = 0
        end
    end

    --RESET TO 0 OR FLAP AROUND--
    for i = 1, SPLR_PER_WING do
        --speedbrakes position reset
        if not L_SPLR_CONTROLLED[i] then
            if L_SPLR_HYD_PRESS[i] >= 1450 then--reset
                L_SPLR_ROLL_TGT[i] = 0
                L_SPLR_SPDBRK_TGT[i] = 0
            else--damp
                L_SPLR_ROLL_TGT[i] = 0
                L_SPLR_SPDBRK_TGT[i] = Math_clamp(get(Alpha), 0, SPLR_TOTAL_MAX_DEF[i])
            end
        end
        if not R_SPLR_CONTROLLED[i] then
            if R_SPLR_HYD_PRESS[i] >= 1450 then--reset
                R_SPLR_ROLL_TGT[i] = 0
                R_SPLR_SPDBRK_TGT[i] = 0
            else--damp
                R_SPLR_ROLL_TGT[i] = 0
                R_SPLR_SPDBRK_TGT[i] = Math_clamp(get(Alpha), 0, SPLR_TOTAL_MAX_DEF[i])
            end
        end
    end

    --PRE-EXTENTION DEFECTION VALUE CALCULATION --> OUTPUT OF CALCULATED VALUE TO THE SURFACES--
    set(TOTAL_SPDBRK_EXTENSION, 0)
    set(TOTAL_ROLL_SPLR_EXTENSION, 0)
    set(Speedbrakes_ratio, math.abs(lateral_input) + spdbrk_input)
    for i = 1, SPLR_PER_WING do
        --speedbrakes
        set(L_SPDBRK_EXTENSION, Set_anim_value_linear_range(get(L_SPDBRK_EXTENSION, i), L_SPLR_SPDBRK_TGT[i], 0, SPLR_TOTAL_MAX_DEF[i], L_SPLR_SPDBRK_SPD[i], 5), i)
        set(R_SPDBRK_EXTENSION, Set_anim_value_linear_range(get(R_SPDBRK_EXTENSION, i), R_SPLR_SPDBRK_TGT[i], 0, SPLR_TOTAL_MAX_DEF[i], R_SPLR_SPDBRK_SPD[i], 5), i)
        --roll spoilers
        set(L_ROLL_SPLR_EXTENSION, Set_anim_value_linear_range(get(L_ROLL_SPLR_EXTENSION, i), L_SPLR_ROLL_TGT[i], 0, SPLR_TOTAL_MAX_DEF[i], L_SPLR_ROLL_SPD[i], 5), i)
        set(R_ROLL_SPLR_EXTENSION, Set_anim_value_linear_range(get(R_ROLL_SPLR_EXTENSION, i), R_SPLR_ROLL_TGT[i], 0, SPLR_TOTAL_MAX_DEF[i], R_SPLR_ROLL_SPD[i], 5), i)

        --sum outputs for total deflection datarefs--
        set(TOTAL_SPDBRK_EXTENSION, get(TOTAL_ROLL_SPLR_EXTENSION) + get(L_SPDBRK_EXTENSION, i) + get(R_SPDBRK_EXTENSION, i))
        set(TOTAL_ROLL_SPLR_EXTENSION, get(TOTAL_ROLL_SPLR_EXTENSION) + get(L_ROLL_SPLR_EXTENSION, i) + get(R_ROLL_SPLR_EXTENSION, i))

        --TOTAL SPOILERS OUTPUT TO THE SURFACES--
        --if any surface exceeds the max deflection limit the othere side would reduce deflection by the exceeded amount
        set(L_SPLR_DATAREFS[i], Math_clamp_higher(get(L_SPDBRK_EXTENSION, i) + get(L_ROLL_SPLR_EXTENSION, i), SPLR_TOTAL_MAX_DEF[i]) - Math_clamp_lower(get(R_SPDBRK_EXTENSION, i) + get(R_ROLL_SPLR_EXTENSION, i) - SPLR_TOTAL_MAX_DEF[i], 0))
        set(R_SPLR_DATAREFS[i], Math_clamp_higher(get(R_SPDBRK_EXTENSION, i) + get(R_ROLL_SPLR_EXTENSION, i), SPLR_TOTAL_MAX_DEF[i]) - Math_clamp_lower(get(L_SPDBRK_EXTENSION, i) + get(L_ROLL_SPLR_EXTENSION, i) - SPLR_TOTAL_MAX_DEF[i], 0))
    end
end

function update()
    FBW.fctl.control.SPLR_COMMON.COMPUTE_SPDBRK_MAX_DEF()
    FBW.fctl.control.SPLR(get(FBW_roll_output), get(Speedbrake_handle_ratio), Ground_spoilers_output(Ground_spoilers_var_table), false)
end