local function XP_trim_up(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if get(THS_trim_range_limited) == 1 and get(Elev_trim_ratio) >= get(THS_trim_limit_ratio) then
            set(Human_pitch_trim, 0)
        else
            set(Human_pitch_trim, 1)
        end
    end

    return 0--inhibites the x-plane original command
end
local function XP_trim_dn(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Human_pitch_trim, -1)
    end

    return 0--inhibites the x-plane original command
end
sasl.registerCommandHandler(Trim_up, 1, XP_trim_up)
sasl.registerCommandHandler(Trim_dn, 1, XP_trim_dn)
sasl.registerCommandHandler(Trim_up_mechanical, 1, XP_trim_up)
sasl.registerCommandHandler(Trim_dn_mechanical, 1, XP_trim_dn)

FBW.fctl.control.THS = function (THS_input_dataref, human_input_dataref)
    --input processing--
    local input = Math_clamp(get(THS_input_dataref), -1, 1)

    --properties--
    local THS_clean_pitch_rate = 0.3
    local THS_flaps_pitch_rate = 0.7
    local Human_trim_wheel_pitch_rate = 0.2
    local max_ths_up = get(Max_THS_up)
    local max_ths_dn = -get(Max_THS_dn)

    --calulated speeds
    local caculated_trim_speed = 0
    local caculated_human_trim_speed = 0

    --THS pitch rate to trim ratio conversion
    if get(Flaps_internal_config) > 0 then
        if get(Elev_trim_ratio) >= 0 then
            caculated_trim_speed = THS_flaps_pitch_rate / max_ths_up
            caculated_human_trim_speed = Human_trim_wheel_pitch_rate / max_ths_up
        else
            caculated_trim_speed = THS_flaps_pitch_rate / -max_ths_dn
            caculated_human_trim_speed = Human_trim_wheel_pitch_rate / -max_ths_dn
        end
    else
        if get(Elev_trim_ratio) >= 0 then
            caculated_trim_speed = THS_clean_pitch_rate / max_ths_up
            caculated_human_trim_speed = Human_trim_wheel_pitch_rate / max_ths_up
        else
            caculated_trim_speed = THS_clean_pitch_rate / -max_ths_dn
            caculated_human_trim_speed = Human_trim_wheel_pitch_rate / -max_ths_dn
        end
    end

    --logics
    local THS_target = input
    local max_upwards_trim_ratio = get(THS_trim_range_limited) == 1 and get(THS_trim_limit_ratio) or 1

    --Trim speed logic--
    caculated_human_trim_speed = FBW.fctl.surfaces.THS.THS.mechanical and caculated_human_trim_speed or 0
    caculated_trim_speed = FBW.fctl.surfaces.THS.THS.controlled and caculated_trim_speed or 0
    set(human_input_dataref, FBW.fctl.surfaces.THS.THS.mechanical and get(human_input_dataref) or 0)

    if get(human_input_dataref) ~= 0 then
        set(Elev_trim_ratio, Math_clamp(get(Elev_trim_ratio) + get(human_input_dataref) * caculated_human_trim_speed * get(DELTA_TIME), -1, 1))
        set(THS_input_dataref, get(Elev_trim_ratio))
        set(human_input_dataref, 0)
    else
        set(Elev_trim_ratio, Set_linear_anim_value(get(Elev_trim_ratio), THS_target, -1, max_upwards_trim_ratio, caculated_trim_speed))
    end
end

function update()
    FBW.fctl.control.THS(Augmented_pitch_trim_ratio, Human_pitch_trim)
end