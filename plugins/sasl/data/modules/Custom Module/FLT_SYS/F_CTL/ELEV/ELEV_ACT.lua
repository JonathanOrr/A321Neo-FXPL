local ELEV_FILTER_TBL = {
    {cut_frequency = 3, x=0},   -- L
    {cut_frequency = 3, x=0}    -- R
}

local ELEV_MAX_UP    = 30   -- in °
local ELEV_MAX_DN    = 17   -- in °
local MAX_STROKE_SPD = 60   -- in mm/s
local ELEV_STOKE     = 60   -- in mm
local STALL_LOAD     = 2.77 -- 10kN
local ELEV_CURR_SPD = {0,0}
local ELEV_TBL = {FCTL.ELEV.STAT.L, FCTL.ELEV.STAT.R}
local DAMPING_CONST = 0.058
local ELEV_NO_HYD_SPD = 1   -- in °/s
local NO_HYD_RECTR_TAS = 80 -- in kts

-- Cache some functions to speed-up computation
local mabs  = math.abs
local masin = math.asin
local msin  = math.sin
local mcos  = math.cos
local mrad  = math.rad
local mexp  = math.exp

local function elev_deg2mm(deg)  -- Convert aileron deg to actuator mm
    local mm_TBL = {
        {-msin(mrad(ELEV_MAX_UP)),                                                                                 ELEV_STOKE},
        {0,                        msin(mrad(ELEV_MAX_DN)) / (msin(mrad(ELEV_MAX_DN)) + msin(mrad(ELEV_MAX_UP))) * ELEV_STOKE},
        {msin(mrad(ELEV_MAX_DN)),                                                                                           0},
    }

    local mm = Table_interpolate(mm_TBL, msin(mrad(deg)))

    return mm
end

local function elev_mm2deg(mm)  -- Convert actuator mm to aileron deg
    local mm_CONVERT_TBL = {
        {0 ,                                                                                          msin(mrad(ELEV_MAX_DN))},
        {msin(mrad(ELEV_MAX_DN)) / (msin(mrad(ELEV_MAX_DN)) + msin(mrad(ELEV_MAX_UP))) * ELEV_STOKE,                        0},
        {ELEV_STOKE,                                                                                 -msin(mrad(ELEV_MAX_UP))},
    }

    local rescaled_mm = Table_interpolate(mm_CONVERT_TBL, mm)

    local deg_TBL = {
        {masin(-msin(mrad(ELEV_MAX_UP))), -ELEV_MAX_UP},
        {0,                                          0},
        {masin(msin(mrad(ELEV_MAX_DN))),   ELEV_MAX_DN},
    }

    local deg = Table_interpolate(deg_TBL, masin(rescaled_mm))

    return deg
end

local function elev_spd_model(REQ_DEF, CURR_DEF) -- Compute the maximum speed depending on the Drag forces and
                                                                -- the G forces. See the document on Discord for explanation
    local TAS   = get(TAS_ms)
    local A     = CURR_DEF
    local rho   = get(Weather_Rho)
    local Cd    = 1
    local Aelev = 7

    local DefA = Aelev * msin(mrad(mabs(A)))
    local Fd = 0.5 * rho * TAS^2 * Cd * DefA

    local aero_forces = mabs(get(Flightmodel_aero_norm_forces) / 900 * Aelev)

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

FCTL.ELEV.ACT = function (REQ_DEF, index)-- index: 1: L, 2: R
    local DEF_DATAREF = index == 1 and L_elevator or R_elevator
    local ELEV_STUCK  = index == 1 and get(FAILURE_FCTL_LELEV) or get(FAILURE_FCTL_RELEV)
    local CURR_DEF    = get(DEF_DATAREF)
    local CURR_mm     = elev_deg2mm(CURR_DEF)
    local REQ_mm      = elev_deg2mm(REQ_DEF)

    -- 1: Compute the max speed
    local MAX_SPD = elev_spd_model(REQ_DEF, CURR_DEF)

    -- 2: Perform a 3 Hz filter on the max speed change
    ELEV_FILTER_TBL[index].x = MAX_SPD
    local STROKE_SPD = mabs(low_pass_filter(ELEV_FILTER_TBL[index]))

    -- 3: Rescale speed depending on HYD availability
    local TOTAL_PRESS = ELEV_TBL[index].total_hyd_press
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
    local A_elev = 400
    ELEV_CURR_SPD[index] = Set_linear_anim_value(ELEV_CURR_SPD[index], TGT_SPD, -200, 200, A_elev)

    -- 7: Finally compute actuator value and set the surface position
    if ELEV_TBL[index].controlled or ELEV_TBL[index].centered then
        -- Normal situation
        local ACTUATOR_VALUE = CURR_mm + ELEV_CURR_SPD[index] * (1 - ELEV_STUCK) * get(DELTA_TIME)  -- DO NOT use the set_anim_linear here: the speed can be negative!
        ACTUATOR_VALUE = Math_clamp(ACTUATOR_VALUE, 0, ELEV_STOKE)
        set(DEF_DATAREF, elev_mm2deg(ACTUATOR_VALUE))
    else
        -- No HYD at all
        local LOCAL_AIRSPD_KTS = mcos(mrad(get(Beta))) * get(TAS_ms) * 1.94384
        local DAMPING_ANGLE = mcos(mrad(get(Beta))) * ((ELEV_MAX_UP * 2) / (1 + mexp(-DAMPING_CONST * -get(Alpha))) - ELEV_MAX_UP) - get(THS_DEF)
        local DAMPING_DEF_TGT = Math_rescale(0, ELEV_MAX_DN, NO_HYD_RECTR_TAS, DAMPING_ANGLE, LOCAL_AIRSPD_KTS)
        Set_dataref_linear_anim(DEF_DATAREF, DAMPING_DEF_TGT, -ELEV_MAX_UP, ELEV_MAX_DN, ELEV_NO_HYD_SPD * (1 - ELEV_STUCK))
    end
end