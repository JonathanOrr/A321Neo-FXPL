local SPLR_FILTER_TBL = {
    L = {
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
    },
    R = {
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
        {cut_frequency = 3, x=0},
    },
}

local SPLR_TBL = {
    L = {
        FBW.fctl.SPLR.STAT.L[1],
        FBW.fctl.SPLR.STAT.L[2],
        FBW.fctl.SPLR.STAT.L[3],
        FBW.fctl.SPLR.STAT.L[4],
        FBW.fctl.SPLR.STAT.L[5],
    },
    R = {
        FBW.fctl.SPLR.STAT.R[1],
        FBW.fctl.SPLR.STAT.R[2],
        FBW.fctl.SPLR.STAT.R[3],
        FBW.fctl.SPLR.STAT.R[4],
        FBW.fctl.SPLR.STAT.R[5],
    },
}
local SPLR_DATAREF_TBL = {
    L = {
        L_SPLR_1,
        L_SPLR_2,
        L_SPLR_3,
        L_SPLR_4,
        L_SPLR_5,
    },
    R = {
        R_SPLR_1,
        R_SPLR_2,
        R_SPLR_3,
        R_SPLR_4,
        R_SPLR_5,
    },
}
local SPLR_FAIL_DATAREF_TBL = {
    L = {
        FAILURE_FCTL_LSPOIL_1,
        FAILURE_FCTL_LSPOIL_2,
        FAILURE_FCTL_LSPOIL_3,
        FAILURE_FCTL_LSPOIL_4,
        FAILURE_FCTL_LSPOIL_5,
    },
    R = {
        FAILURE_FCTL_RSPOIL_1,
        FAILURE_FCTL_RSPOIL_2,
        FAILURE_FCTL_RSPOIL_3,
        FAILURE_FCTL_RSPOIL_4,
        FAILURE_FCTL_RSPOIL_5,
    },
}
local SPLR_MAX_DEF   = 50   -- in °
local MAX_STROKE_SPD = 99   -- in mm
local SPLR_STROKE    = 84   -- in mm
local STALL_LOAD     = 4.54 -- 10kN
local SPLR_CURR_SPD = {
    L = {0,0,0,0,0},
    R = {0,0,0,0,0},
}
local SPLR_NO_HYD_SPD  = 2  -- in °/s
local NO_HYD_RECTR_TAS = 80 -- in kts

-- Cache some functions to speed-up computation
local mabs  = math.abs
local masin = math.asin
local msin  = math.sin
local mcos  = math.cos
local mrad  = math.rad

local function ail_deg2mm(deg)  -- Convert aileron deg to actuator mm
    local mm = Math_rescale(
        0,                                  0,
        msin(mrad(SPLR_MAX_DEF)), SPLR_STROKE,
        msin(mrad(deg))
    )

    return mm
end

local function ail_mm2deg(mm)  -- Convert actuator mm to aileron deg
    local rescaled_mm = Math_rescale(
        0 ,                                 0,
        SPLR_STROKE, msin(mrad(SPLR_MAX_DEF)),
        mm
    )

    local deg = Math_rescale(
        0,                                          0,
        masin(msin(mrad(SPLR_MAX_DEF))), SPLR_MAX_DEF,
        masin(rescaled_mm)
    )

    return deg
end

local function ail_spd_model(REQ_DEF, CURR_DEF) -- Compute the maximum speed depending on the Drag forces and
                                                                -- the G forces. See the document on Discord for explanation
    local TAS   = get(TAS_ms)
    local A     = CURR_DEF
    local rho   = get(Weather_Rho)
    local Cd    = 1
    local Asplr = 1

    local DefA = Asplr * msin(mrad(mabs(A)))
    local Fd = 0.5 * rho * TAS^2 * Cd * DefA

    local aero_forces = mabs(get(Flightmodel_aero_norm_forces) / 900 * Asplr)

    local Ftot = aero_forces / 1e4

    --if requested and current are in the same direction
    if REQ_DEF >= 0 and CURR_DEF >= 0 then
        if mabs(REQ_DEF) > mabs(CURR_DEF) then--add resisance
            Ftot = Ftot + Fd / 1e4
        end
    elseif REQ_DEF <= 0 and CURR_DEF <= 0 then
        if mabs(REQ_DEF) > mabs(CURR_DEF) then--add resisance
            Ftot = Ftot + Fd / 1e4
        end
    end

    local MAX_SPD = (MAX_STROKE_SPD / STALL_LOAD^(1/2.2)) * (STALL_LOAD - Math_clamp(Ftot, 0, STALL_LOAD))^(1/2.2)

    return MAX_SPD
end

FBW.fctl.SPLR.ACT = function (REQ_DEF, side, index)
    local DEF_DATAREF = SPLR_DATAREF_TBL[side][index]
    local SPLR_STUCK  = get(SPLR_FAIL_DATAREF_TBL[side][index])
    local CURR_DEF    = get(DEF_DATAREF)
    local CURR_mm     = ail_deg2mm(CURR_DEF)
    local REQ_mm      = ail_deg2mm(REQ_DEF)

    -- 1: Compute the max speed
    local MAX_SPD = ail_spd_model(REQ_DEF, CURR_DEF)

    -- 2: Perform a 3 Hz filter on the max speed change
    SPLR_FILTER_TBL[side][index].x = MAX_SPD
    local STROKE_SPD = mabs(low_pass_filter(SPLR_FILTER_TBL[side][index]))

    -- 3: Rescale speed depending on HYD availability
    local TOTAL_PRESS = SPLR_TBL[side][index].total_hyd_press
    local HYD_MAX_SPD  = Math_rescale(0, 0, 3000, STROKE_SPD, TOTAL_PRESS)

    -- 4: So, corrently compute pos/neg speed depending on the direction we have to go
    local TGT_SPD = 0
    if CURR_mm < REQ_mm then
        TGT_SPD = math.min(HYD_MAX_SPD, STROKE_SPD)
    elseif CURR_mm > REQ_mm then
        TGT_SPD = -math.min(HYD_MAX_SPD, STROKE_SPD)
    else
        TGT_SPD = 0
    end

    -- 5: Slow down the actuator near the target
    if TGT_SPD ~= 0 and mabs(CURR_DEF - REQ_DEF) < 8 then
        TGT_SPD = TGT_SPD * mabs(CURR_DEF - REQ_DEF) / 8
    end

    --6: Smoothing the stroke speed
    local A_splr = 550
    SPLR_CURR_SPD[side][index] = Set_linear_anim_value(SPLR_CURR_SPD[side][index], TGT_SPD, -200, 200, A_splr)

    -- 7: Finally compute actuator value and set the surface position
    if SPLR_TBL[side][index].controlled or TOTAL_PRESS ~= 0 then
        -- Normal situation
        local ACTUATOR_VALUE = CURR_mm + SPLR_CURR_SPD[side][index] * (1 - SPLR_STUCK) * get(DELTA_TIME)  -- DO NOT use the set_anim_linear here: the speed can be negative!
        ACTUATOR_VALUE = Math_clamp(ACTUATOR_VALUE, 0, SPLR_STROKE)
        set(DEF_DATAREF, ail_mm2deg(ACTUATOR_VALUE))
    else
        -- No HYD at all
        local LOCAL_AIRSPD_KTS = mcos(mrad(get(Beta))) * get(TAS_ms) * 1.94384
        local ACT_NO_HYD_SPD = Math_rescale(0, 0, NO_HYD_RECTR_TAS, SPLR_NO_HYD_SPD, LOCAL_AIRSPD_KTS)
        local DAMPING_DEF_TGT = Math_clamp(mcos(mrad(get(Beta))) * get(Alpha), 0, CURR_DEF)
        Set_dataref_linear_anim(DEF_DATAREF, DAMPING_DEF_TGT, 0, SPLR_MAX_DEF, ACT_NO_HYD_SPD * (1 - SPLR_STUCK))
    end
end