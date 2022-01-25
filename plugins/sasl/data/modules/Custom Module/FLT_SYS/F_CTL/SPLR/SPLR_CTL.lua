--PROPERTIES--
local SPLR_PER_WING = 5
local L_SPLR_DATAREFS = {L_SPLR_1, L_SPLR_2, L_SPLR_3, L_SPLR_4, L_SPLR_5}
local R_SPLR_DATAREFS = {L_SPLR_1, L_SPLR_2, L_SPLR_3, L_SPLR_4, L_SPLR_5}

local SPDBRK_HIGHSPD_AIR_SPD = {1, 1, 1, 1, 1}

-------------------------------------------------------------------------------
-- ROLL SPOILERS & SPD BRAKES
-------------------------------------------------------------------------------
local function SPLR_CTL(lateral_input, spdbrk_input, ground_spoilers_mode, in_auto_flight)
    --during a touch and go one of the thrust levers has to be advanced beyond 20 degrees to disarm the spoilers

    local L_SPLR_CONTROLLED = {
        FCTL.SPLR.STAT.L[1].controlled,
        FCTL.SPLR.STAT.L[2].controlled,
        FCTL.SPLR.STAT.L[3].controlled,
        FCTL.SPLR.STAT.L[4].controlled,
        FCTL.SPLR.STAT.L[5].controlled,
    }
    local R_SPLR_CONTROLLED = {
        FCTL.SPLR.STAT.R[1].controlled,
        FCTL.SPLR.STAT.R[2].controlled,
        FCTL.SPLR.STAT.R[3].controlled,
        FCTL.SPLR.STAT.R[4].controlled,
        FCTL.SPLR.STAT.R[5].controlled,
    }

    --limit input range
    spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

    --properties
    local ROLL_SPLR_THRESHOLD = {0.1, 0.1, 0.3, 0.1, 0.1}--amount of sidestick deflection needed to trigger the roll spoilers

    --constant speeds--
    local SPLR_TOTAL_MAX_DEF = {50, 50, 50, 50, 50}
    local SPLR_ROLL_MAX_DEF = {0, 35, 7, 35, 35}
    local SPLR_SPDBRK_MAX_DEF = FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_DEF

    --actual speeds--
    local L_SPLR_SPDBRK_SPD = {
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[1],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[2],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[3],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[4],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[5],
    }
    local R_SPLR_SPDBRK_SPD = {
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[1],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[2],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[3],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[4],
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD[5],
    }

    --targets--
    local L_SPLR_SPDBRK_TGT = {0, 0, 0, 0, 0}
    local R_SPLR_SPDBRK_TGT = {0, 0, 0, 0, 0}
    local L_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}
    local R_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}

    --SPOILERS & SPDBRAKES SPD CALCULATION---------------------------------------------------------------------------
    --reduce speedbrakes retraction speeds in high speed conditions
    if (adirs_get_avg_ias()>= 315 or adirs_get_avg_mach() >= 0.75) and in_auto_flight then
        --check if any spoilers are retracting and slow down accordingly
        for i = 1, SPLR_PER_WING do
            if L_SPLR_SPDBRK_TGT[i] < get(L_SPLR_DATAREFS[i]) then
                L_SPLR_SPDBRK_SPD[i] = SPDBRK_HIGHSPD_AIR_SPD[i]
            end
            if R_SPLR_SPDBRK_TGT[i] < get(R_SPLR_DATAREFS[i])then
                R_SPLR_SPDBRK_SPD[i] = SPDBRK_HIGHSPD_AIR_SPD[i]
            end
        end
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

    --GLA------------------------------------------------------------------------------------------------------------
    local L_SPLR_4_TOTAL_TGT = L_SPLR_SPDBRK_TGT[4] + L_SPLR_ROLL_TGT[4]
    local R_SPLR_4_TOTAL_TGT = R_SPLR_SPDBRK_TGT[4] + R_SPLR_ROLL_TGT[4]
    local L_SPLR_5_TOTAL_TGT = L_SPLR_SPDBRK_TGT[5] + L_SPLR_ROLL_TGT[5]
    local R_SPLR_5_TOTAL_TGT = R_SPLR_SPDBRK_TGT[5] + R_SPLR_ROLL_TGT[5]

    --get how much travel is left in actuator--
    local L_SPLR_4_TRAVEL_LEFT = SPLR_TOTAL_MAX_DEF[4] - math.min(L_SPLR_4_TOTAL_TGT, SPLR_TOTAL_MAX_DEF[4])
    local R_SPLR_4_TRAVEL_LEFT = SPLR_TOTAL_MAX_DEF[4] - math.min(R_SPLR_4_TOTAL_TGT, SPLR_TOTAL_MAX_DEF[4])
    local L_SPLR_5_TRAVEL_LEFT = SPLR_TOTAL_MAX_DEF[5] - math.min(L_SPLR_5_TOTAL_TGT, SPLR_TOTAL_MAX_DEF[5])
    local R_SPLR_5_TRAVEL_LEFT = SPLR_TOTAL_MAX_DEF[5] - math.min(R_SPLR_5_TOTAL_TGT, SPLR_TOTAL_MAX_DEF[5])

    if L_SPLR_CONTROLLED[4] and R_SPLR_CONTROLLED[4] then
        L_SPLR_ROLL_TGT[4] = L_SPLR_ROLL_TGT[4] + Math_clamp_higher(get(FBW_GLA_output), L_SPLR_4_TRAVEL_LEFT)
        R_SPLR_ROLL_TGT[4] = R_SPLR_ROLL_TGT[4] + Math_clamp_higher(get(FBW_GLA_output), R_SPLR_4_TRAVEL_LEFT)
    end
    if L_SPLR_CONTROLLED[5] and R_SPLR_CONTROLLED[5] then
        L_SPLR_ROLL_TGT[5] = L_SPLR_ROLL_TGT[5] + Math_clamp_higher(get(FBW_GLA_output), L_SPLR_5_TRAVEL_LEFT)
        R_SPLR_ROLL_TGT[5] = R_SPLR_ROLL_TGT[5] + Math_clamp_higher(get(FBW_GLA_output), R_SPLR_5_TRAVEL_LEFT)
    end

    --SPEEDBRAKES INHIBITION-----------------------------------------------------------------------------------------
    if get(SPDBRK_HANDLE_RATIO) >= 0 and get(SPDBRK_HANDLE_RATIO) <= 0.1 then
        set(Speedbrakes_inhibited, 0)
    end

    --lacking upon a.prot toga [and restoring speedbrake avail by reseting the lever position]
    if get(Bypass_speedbrakes_inhibition) ~= 1 then
        if get(SEC_1_status) == 0 and get(SEC_2_status) == 0 then
            set(Speedbrakes_inhibited, 1)
        end
        if not FCTL.ELEV.STAT.L.controlled or not FCTL.ELEV.STAT.R.controlled then
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

    --GROUND SPOILERS MODE-------------------------------------------------------------------------------------------
    --0 = NOT EXTENDED
    --1 = PARCIAL EXTENTION
    --2 = FULL EXTENTION
    if get(Ground_spoilers_mode) == 1 then
        L_SPLR_SPDBRK_TGT = {10, 10, 10, 10, 10}
        R_SPLR_SPDBRK_TGT = {10, 10, 10, 10, 10}
    elseif get(Ground_spoilers_mode) == 2 then
        L_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}
        R_SPLR_ROLL_TGT = {0, 0, 0, 0, 0}
        L_SPLR_SPDBRK_TGT = {50, 50, 50, 50, 50}
        R_SPLR_SPDBRK_TGT = {50, 50, 50, 50, 50}
    end

    --ROLL DIRECT LAW------------------------------------------------------------------------------------------------
    if get(FBW_lateral_law) == FBW_DIRECT_LAW and (FCTL.AIL.STAT.L.controlled or FCTL.AIL.STAT.R.controlled) then
        if FCTL.SPLR.STAT.L[4].controlled then
            L_SPLR_ROLL_TGT[1] = 0
            L_SPLR_ROLL_TGT[2] = 0
            L_SPLR_ROLL_TGT[3] = 0
        else
            L_SPLR_ROLL_TGT[1] = 0
            L_SPLR_ROLL_TGT[2] = 0
            L_SPLR_ROLL_TGT[4] = 0
        end
        if FCTL.SPLR.STAT.R[4].controlled then
            R_SPLR_ROLL_TGT[1] = 0
            R_SPLR_ROLL_TGT[2] = 0
            R_SPLR_ROLL_TGT[3] = 0
        else
            R_SPLR_ROLL_TGT[1] = 0
            R_SPLR_ROLL_TGT[2] = 0
            R_SPLR_ROLL_TGT[4] = 0
        end
    end

    --UNCONTROLLED RESET TO 0----------------------------------------------------------------------------------------
    for i = 1, SPLR_PER_WING do
        --speedbrakes position reset
        if not L_SPLR_CONTROLLED[i] then
            L_SPLR_ROLL_TGT[i] = 0
            L_SPLR_SPDBRK_TGT[i] = 0
        end
        if not R_SPLR_CONTROLLED[i] then
            R_SPLR_ROLL_TGT[i] = 0
            R_SPLR_SPDBRK_TGT[i] = 0
        end
    end

    --PRE-EXTENTION DEFECTION VALUE CALCULATION --> OUTPUT OF CALCULATED VALUE TO THE SURFACES-----------------------
    local TEMP_TOTAL_SPDBRK_EXTENSION = 0
    local TEMP_TOTAL_ROLL_SPLR_EXTENSION = 0
    set(Speedbrakes_ratio, math.abs(lateral_input) + spdbrk_input)
    for i = 1, SPLR_PER_WING do
        --speedbrakes
        set(L_SPDBRK_EXTENSION, Set_linear_anim_value(get(L_SPDBRK_EXTENSION, i), L_SPLR_SPDBRK_TGT[i], 0, SPLR_TOTAL_MAX_DEF[i], L_SPLR_SPDBRK_SPD[i]), i)
        set(R_SPDBRK_EXTENSION, Set_linear_anim_value(get(R_SPDBRK_EXTENSION, i), R_SPLR_SPDBRK_TGT[i], 0, SPLR_TOTAL_MAX_DEF[i], R_SPLR_SPDBRK_SPD[i]), i)
        --roll spoilers
        set(L_ROLL_SPLR_EXTENSION, L_SPLR_ROLL_TGT[i], i)
        set(R_ROLL_SPLR_EXTENSION, R_SPLR_ROLL_TGT[i], i)

        --sum outputs for total deflection datarefs--
        TEMP_TOTAL_SPDBRK_EXTENSION    = TEMP_TOTAL_SPDBRK_EXTENSION    + get(L_SPDBRK_EXTENSION, i)    + get(R_SPDBRK_EXTENSION, i)
        TEMP_TOTAL_ROLL_SPLR_EXTENSION = TEMP_TOTAL_ROLL_SPLR_EXTENSION + get(L_ROLL_SPLR_EXTENSION, i) + get(R_ROLL_SPLR_EXTENSION, i)

        --TOTAL SPOILERS OUTPUT TO THE SURFACES--
        --if any surface exceeds the max deflection limit the othere side would reduce deflection by the exceeded amount
        FCTL.SPLR.ACT(Math_clamp_higher(get(L_SPDBRK_EXTENSION, i) + get(L_ROLL_SPLR_EXTENSION, i), SPLR_TOTAL_MAX_DEF[i]) - Math_clamp_lower(get(R_SPDBRK_EXTENSION, i) + get(R_ROLL_SPLR_EXTENSION, i) - SPLR_TOTAL_MAX_DEF[i], 0), "L", i)
        FCTL.SPLR.ACT(Math_clamp_higher(get(R_SPDBRK_EXTENSION, i) + get(R_ROLL_SPLR_EXTENSION, i), SPLR_TOTAL_MAX_DEF[i]) - Math_clamp_lower(get(L_SPDBRK_EXTENSION, i) + get(L_ROLL_SPLR_EXTENSION, i) - SPLR_TOTAL_MAX_DEF[i], 0), "R", i)
    end

    set(TOTAL_SPDBRK_EXTENSION, TEMP_TOTAL_SPDBRK_EXTENSION)
    set(TOTAL_ROLL_SPLR_EXTENSION, TEMP_TOTAL_ROLL_SPLR_EXTENSION)
end

function update()
    SPLR_CTL(get(FBW_roll_output), get(SPDBRK_HANDLE_RATIO), false)
end