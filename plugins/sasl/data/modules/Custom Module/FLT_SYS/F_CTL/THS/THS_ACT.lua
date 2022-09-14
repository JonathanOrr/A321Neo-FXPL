local THS_CLEAN_SPD   = 0.3   -- in deg/s
local THS_FLAP_SPD    = 0.7   -- in deg/s
local HUMAN_WHEEL_SPD = 0.4   -- in deg/s
local THS_DECAL_ZONE  = 0.085 -- in degs
local MAX_THS_UP      = get(Max_THS_up)-- in degs
local MAX_THS_DN      = get(Max_THS_dn)-- in degs

local mabs = math.abs

local function Compute_HUMAN_TRIM_SPD()
    local TRIM_WHEEL_SPD = HUMAN_WHEEL_SPD

    TRIM_WHEEL_SPD = Math_rescale(0, 0, 3000, TRIM_WHEEL_SPD, FCTL.THS.STAT.total_hyd_press)
    TRIM_WHEEL_SPD = FCTL.THS.STAT.mechanical and TRIM_WHEEL_SPD or 0
    set(Human_pitch_trim, FCTL.THS.STAT.mechanical and get(Human_pitch_trim) or 0)

    return TRIM_WHEEL_SPD
end

local function Compute_THS_HYD_SPD()
    local HYD_SPD = 0

    --THS pitch rate to trim ratio conversion
    if get(Flaps_internal_config) > 1 then
        HYD_SPD = THS_FLAP_SPD
    else
        HYD_SPD = THS_CLEAN_SPD
    end

    HYD_SPD = Math_rescale(0, 0, 3000, HYD_SPD, FCTL.THS.STAT.total_hyd_press)
    HYD_SPD = FCTL.THS.STAT.controlled and HYD_SPD or 0

    return HYD_SPD
end

FCTL.THS.ACT = function (REQ_DEF)
    local TGT_SPD = 0
    local DEF_DATAREF = THS_DEF
    local CURR_DEF = get(DEF_DATAREF)
    local STUCK = get(FAILURE_FCTL_THS_MECH)

    --if human input occuring--
    if get(Human_pitch_trim) ~= 0 then
        TGT_SPD = Compute_HUMAN_TRIM_SPD() * get(Human_pitch_trim)
        set(THS_CURR_SPD, TGT_SPD)
    else
        if REQ_DEF > CURR_DEF then
            TGT_SPD = Compute_THS_HYD_SPD()
        elseif REQ_DEF < CURR_DEF then
            TGT_SPD = -Compute_THS_HYD_SPD()
        end

        --DECEL CLOSE TO TARGET--
        if TGT_SPD ~= 0 and mabs(CURR_DEF - REQ_DEF) < THS_DECAL_ZONE then
            TGT_SPD = TGT_SPD * mabs(CURR_DEF - REQ_DEF) / THS_DECAL_ZONE
        end

        --ACCELERATE THE ACTUATOR TO TARGET SPD--
        local A_THS = 10
        set(THS_CURR_SPD, Set_linear_anim_value(get(THS_CURR_SPD), TGT_SPD, -1, 1, A_THS))
    end

    --ACTUATE--
    set(DEF_DATAREF, Math_clamp(CURR_DEF + get(THS_CURR_SPD) * (1 - STUCK) * get(DELTA_TIME), -MAX_THS_UP, MAX_THS_DN))
    set(XP_THS_DEF, -get(DEF_DATAREF))

    if get(Human_pitch_trim) ~= 0 then
        set(THS_CURR_SPD, 0)
        set(Digital_THS_def_tgt, get(DEF_DATAREF))
        set(Human_pitch_trim, 0)
    end
end