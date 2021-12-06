local RUD_FILTER_TBL = {cut_frequency = 3, x=0}

local RUD_MAX_DEF    = 25   -- in °
local MAX_STROKE_SPD = 110  -- in mm/s
local RUD_STROKE     = 110  -- in mm
local STALL_LOAD     = 4.43 -- 10kN
local RUD_CURR_SPD   = 0
local RUD_TBL = FBW.fctl.RUD.STAT
local RUD_NO_HYD_SPD = 8    -- in °/s
local NO_HYD_RECTR_TAS = 100 -- in kts

-- Cache some functions to speed-up computation
local mabs  = math.abs
local masin = math.asin
local msin  = math.sin
local mcos  = math.cos
local mrad  = math.rad

local function rud_deg2mm(deg)  -- Convert aileron deg to actuator mm
    local mm_TBL = {
        {-msin(mrad(RUD_MAX_DEF)),     RUD_STROKE},
        {0,                        RUD_STROKE / 2},
        {msin(mrad(RUD_MAX_DEF)),               0},
    }

    local mm = Table_interpolate(mm_TBL, msin(mrad(deg)))

    return mm
end

local function rud_mm2deg(mm)  -- Convert actuator mm to aileron deg
    local mm_CONVERT_TBL = {
        {0 ,              msin(mrad(RUD_MAX_DEF))},
        {RUD_STROKE / 2,                        0},
        {RUD_STROKE,     -msin(mrad(RUD_MAX_DEF))},
    }

    local rescaled_mm = Table_interpolate(mm_CONVERT_TBL, mm)

    local deg_TBL = {
        {masin(-msin(mrad(RUD_MAX_DEF))), -RUD_MAX_DEF},
        {0,                                          0},
        {masin(msin(mrad(RUD_MAX_DEF))),   RUD_MAX_DEF},
    }

    local deg = Table_interpolate(deg_TBL, masin(rescaled_mm))

    return deg
end

local function rud_spd_model(REQ_DEF, CURR_DEF) -- Compute the maximum speed depending on the Drag forces and
                                                                -- the G forces. See the document on Discord for explanation
    local TAS  = get(TAS_ms)
    local A    = CURR_DEF
    local rho  = get(Weather_Rho)
    local Cd   = 1
    local Arud = 7.17

    local DefA = Arud * msin(mrad(mabs(A)))
    local Fd = 0.5 * rho * TAS^2 * Cd * DefA

    local Ftot = 0

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

FBW.fctl.RUD.ACT = function (REQ_DEF)
    local DEF_DATAREF = Rudder_total
    local RUD_STUCK   = get(FAILURE_FCTL_RUDDER)
    local CURR_DEF    = get(DEF_DATAREF)
    local CURR_mm     = rud_deg2mm(CURR_DEF)
    local REQ_mm      = rud_deg2mm(REQ_DEF)

    -- 1: Compute the max speed
    local MAX_SPD = rud_spd_model(REQ_DEF, CURR_DEF)

    -- 2: Perform a 3 Hz filter on the max speed change
    RUD_FILTER_TBL.x = MAX_SPD
    local STROKE_SPD = mabs(low_pass_filter(RUD_FILTER_TBL))

    -- 3: Rescale speed depending on HYD availability
    local TOTAL_PRESS = RUD_TBL.total_hyd_press
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
    local A_rud = 400
    RUD_CURR_SPD = Set_linear_anim_value(RUD_CURR_SPD, TGT_SPD, -200, 200, A_rud)

    -- 7: Finally compute actuator value and set the surface position
    if RUD_TBL.controlled then
        -- Normal situation
        local ACTUATOR_VALUE = CURR_mm + RUD_CURR_SPD * (1 - RUD_STUCK) * get(DELTA_TIME)  -- DO NOT use the set_anim_linear here: the speed can be negative!
        ACTUATOR_VALUE = Math_clamp(ACTUATOR_VALUE, -RUD_STROKE, RUD_STROKE)
        set(DEF_DATAREF, Math_clamp(rud_mm2deg(ACTUATOR_VALUE), -get(Rudder_travel_lim), get(Rudder_travel_lim)))
    else
        -- No HYD at all
        local LOCAL_AIRSPD_KTS = get(TAS_ms) * 1.94384
        local ACT_NO_HYD_SPD = Math_rescale(0, 0, NO_HYD_RECTR_TAS, RUD_NO_HYD_SPD, LOCAL_AIRSPD_KTS)
        local DAMPING_DEF_TGT = get(Beta)
        Set_dataref_linear_anim(DEF_DATAREF, DAMPING_DEF_TGT, -get(Rudder_travel_lim), get(Rudder_travel_lim), ACT_NO_HYD_SPD * (1 - RUD_STUCK))
    end
end