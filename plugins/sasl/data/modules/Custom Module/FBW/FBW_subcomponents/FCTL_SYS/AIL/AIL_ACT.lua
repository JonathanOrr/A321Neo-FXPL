local AIL_FILTER_TBL = {
    {cut_frequency = 3, x=0},   -- L
    {cut_frequency = 3, x=0}    -- R
}

local AIL_MAX_DEF    = 25   -- in °
local MAX_STROKE_SPD = 89   -- in mm/s
local AIL_STROKE     = 43 -- in mm
local STALL_LOAD     = 4.54 -- 10kN
local AIL_CURR_SPD = {0,0}
local AIL_TBL = {FBW.fctl.AIL.STAT.L, FBW.fctl.AIL.STAT.R}
local AIL_NO_HYD_SPD = 8    -- in °/s
local NO_HYD_RECTR_TAS = 80 -- in kts

-- Cache some functions to speed-up computation
local mabs  = math.abs
local masin = math.asin
local msin  = math.sin
local mcos  = math.cos
local mrad  = math.rad

local function ail_deg2mm(deg)  -- Convert aileron deg to actuator mm
    local mm_TBL = {
        {-msin(mrad(AIL_MAX_DEF)),     AIL_STROKE},
        {0,                        AIL_STROKE / 2},
        {msin(mrad(AIL_MAX_DEF)),               0},
    }

    local mm = Table_interpolate(mm_TBL, msin(mrad(deg)))

    return mm
end

local function ail_mm2deg(mm)  -- Convert actuator mm to aileron deg
    local mm_CONVERT_TBL = {
        {0 ,              msin(mrad(AIL_MAX_DEF))},
        {AIL_STROKE / 2,                        0},
        {AIL_STROKE,     -msin(mrad(AIL_MAX_DEF))},
    }

    local rescaled_mm = Table_interpolate(mm_CONVERT_TBL, mm)

    local deg_TBL = {
        {masin(-msin(mrad(AIL_MAX_DEF))), -AIL_MAX_DEF},
        {0,                                          0},
        {masin(msin(mrad(AIL_MAX_DEF))),   AIL_MAX_DEF},
    }

    local deg = Table_interpolate(deg_TBL, masin(rescaled_mm))

    return deg
end

local function ail_spd_model(REQ_DEF, CURR_DEF) -- Compute the maximum speed depending on the Drag forces and
                                                                -- the G forces. See the document on Discord for explanation
    local TAS  = get(TAS_ms)
    local A    = CURR_DEF
    local rho  = get(Weather_Rho)
    local Cd   = 1
    local Aail = 1.016

    local DefA = Aail * msin(mrad(mabs(A)))
    local Fd = 0.5 * rho * TAS^2 * Cd * DefA

    local aero_forces = mabs(get(Flightmodel_aero_norm_forces) / 900 * Aail)

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

FBW.fctl.AIL.ACT = function (REQ_DEF, index)-- index: 1: L, 2: R
    local DEF_DATAREF = index == 1 and L_aileron or R_aileron
    local AIL_STUCK   = index == 1 and get(FAILURE_FCTL_LAIL) or get(FAILURE_FCTL_RAIL)
    local CURR_DEF    = get(DEF_DATAREF)
    local CURR_mm     = ail_deg2mm(CURR_DEF)
    local REQ_mm      = ail_deg2mm(REQ_DEF)

    -- 1: Compute the max speed
    local MAX_SPD = ail_spd_model(REQ_DEF, CURR_DEF)

    -- 2: Perform a 3 Hz filter on the max speed change
    AIL_FILTER_TBL[index].x = MAX_SPD
    local STROKE_SPD = mabs(low_pass_filter(AIL_FILTER_TBL[index]))

    -- 3: Rescale speed depending on HYD availability
    local TOTAL_PRESS = AIL_TBL[index].total_hyd_press
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
    if TGT_SPD ~= 0 and mabs(CURR_DEF - REQ_DEF) < 12 then
        TGT_SPD = TGT_SPD * mabs(CURR_DEF - REQ_DEF) / 12
    end

    --6: Smoothing the stroke speed
    local A_ail = 400
    AIL_CURR_SPD[index] = Set_linear_anim_value(AIL_CURR_SPD[index], TGT_SPD, -200, 200, A_ail)

    -- 7: Finally compute actuator value and set the surface position
    if AIL_TBL[index].controlled then
        -- Normal situation
        local ACTUATOR_VALUE = CURR_mm + AIL_CURR_SPD[index] * (1 - AIL_STUCK) * get(DELTA_TIME)  -- DO NOT use the set_anim_linear here: the speed can be negative!
        ACTUATOR_VALUE = Math_clamp(ACTUATOR_VALUE, -AIL_STROKE, AIL_STROKE)
        set(DEF_DATAREF, ail_mm2deg(ACTUATOR_VALUE))
    else
        -- No HYD at all
        local LOCAL_AIRSPD_KTS = mcos(mrad(get(Beta))) * get(TAS_ms) * 1.94384
        local DAMPING_DEF_TGT = Math_rescale(0, AIL_MAX_DEF, NO_HYD_RECTR_TAS, mcos(mrad(get(Beta))) * -get(Alpha), LOCAL_AIRSPD_KTS)
        Set_dataref_linear_anim(DEF_DATAREF, DAMPING_DEF_TGT, -AIL_MAX_DEF, AIL_MAX_DEF, AIL_NO_HYD_SPD * (1 - AIL_STUCK))
    end
end