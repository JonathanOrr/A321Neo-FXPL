--PROPERTIES--
local MAX_RUD_DEF = 25
local RUD_TRIM_SPD = 1
local RUD_TRIM_RST_SPD = 1.5

local function RUD_PEDAL_CTL()
    --set rudder pedal center
    local rudder_pedal_anim = {
        {-MAX_RUD_DEF, -20},
        {0,              0},
        {MAX_RUD_DEF,   20},
    }
    set(Rudder_pedal_angle, Table_interpolate(rudder_pedal_anim, get(Total_input_yaw)))
end

local function RUD_TRIM_CTL(trim_input, resetting_trim)
    --rudder trim
    if resetting_trim == 1 then
        if trim_input ~= 0 then
            set(Resetting_rudder_trim, 0)
        elseif get(RUD_TRIM_TGT_ANGLE) == 0 then
            set(Resetting_rudder_trim, 0)
        end
    end

    --IF RUDDER IS ELECTRICALLY CONTROLLED--
    if FCTL.RUDTRIM.STAT.controlled then
        if resetting_trim == 0 then--apply human input
            set(RUD_TRIM_TGT_ANGLE, Math_clamp(get(RUD_TRIM_TGT_ANGLE) + trim_input * RUD_TRIM_SPD * get(DELTA_TIME), -20, 20))
            set(Human_rudder_trim, 0)
        else--reset rudder trim
            set(RUD_TRIM_TGT_ANGLE, Set_linear_anim_value(get(RUD_TRIM_TGT_ANGLE), 0, -20, 20, RUD_TRIM_RST_SPD))
            set(Human_rudder_trim, 0)
        end

        set(RUD_TRIM_ACT_ANGLE, Set_linear_anim_value(get(RUD_TRIM_ACT_ANGLE), get(RUD_TRIM_TGT_ANGLE), -get(Rudder_travel_lim), get(Rudder_travel_lim), RUD_TRIM_RST_SPD))
    end
end

local function RUD_TRV_LIM_CTL()
    --Travel limit target
    local TRV_LIM_TGT = -22.1 * math.sqrt(1 - ( (Math_clamp(adirs_get_avg_ias(), 160, 380) - 380) / 220)^2 ) + 25

    if get(Force_full_rudder_limit) ~= 1 and FCTL.RUD.STAT.controlled then
        if get(Slats) > 0 then
            set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), MAX_RUD_DEF, 0, MAX_RUD_DEF, RUD_TRIM_SPD))
        else
            set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), TRV_LIM_TGT, 0, MAX_RUD_DEF, RUD_TRIM_SPD))
        end
    end

    if get(Force_full_rudder_limit) == 1 then
        set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), MAX_RUD_DEF, 0, MAX_RUD_DEF, RUD_TRIM_SPD))
    end
end

local function COMPUTE_HUMAN_RUD_INPUT()
    --the pedals are not limited, hence at higher speed you'll reach the limit with less deflection
    local RUD_TGT = get(XP_YAW) * (MAX_RUD_DEF + math.abs(get(RUD_TRIM_ACT_ANGLE))) + get(RUD_TRIM_ACT_ANGLE)

    set(Total_input_yaw, RUD_TGT)

    set(Total_input_yaw, Math_clamp(get(Total_input_yaw), -MAX_RUD_DEF, MAX_RUD_DEF))
end

local function RUD_CTL()
    FCTL.RUD.ACT(get(FBW_yaw_output))
    set(Rudder_top, get(Rudder_total))
    set(Rudder_btm, get(Rudder_total))
end


function update()
    RUD_PEDAL_CTL()
    RUD_TRIM_CTL(get(Human_rudder_trim), get(Resetting_rudder_trim))
    RUD_TRV_LIM_CTL()
    COMPUTE_HUMAN_RUD_INPUT()
    RUD_CTL()
end