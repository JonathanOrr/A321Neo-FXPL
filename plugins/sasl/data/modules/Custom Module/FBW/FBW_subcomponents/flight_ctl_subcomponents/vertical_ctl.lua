function XP_trim_up(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if get(THS_trim_range_limited) == 1 and get(Elev_trim_ratio) >= get(THS_trim_limit_ratio) then
            set(Human_pitch_trim, 0)
        else
            set(Human_pitch_trim, 1)
        end
    end

    return 0--inhibites the x-plane original command
end

function XP_trim_dn(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Human_pitch_trim, -1)
    end

    return 0--inhibites the x-plane original command
end

function THS_control(THS_input_dataref, human_input)
    --hydraulics system
    --G <--> Y
    --flt computer reversion
    --ELAC 2 --> ELAC 1 --> SEC 2 --> SEC 1
    --flight computer THS motor relation
    --MOTOR 1 <--> MOTOR 2 <--> MOTOR 3
    --ELECTRICAL --> MECHANICAL

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
    caculated_human_trim_speed = Math_rescale(0, 0, 1450, caculated_human_trim_speed, get(Hydraulic_G_press) + get(Hydraulic_Y_press))
    caculated_trim_speed = Math_rescale(0, 0, 1450, caculated_trim_speed, get(Hydraulic_G_press) + get(Hydraulic_Y_press))
    caculated_trim_speed = caculated_trim_speed * BoolToNum(get(ELAC_2_status) == 1 or get(ELAC_1_status) == 1 or get(SEC_2_status) == 1 or get(SEC_1_status) == 1)
    caculated_trim_speed = caculated_trim_speed * (1 - get(FAILURE_FCTL_THS))

    if human_input ~= 0 then
        set(Elev_trim_ratio, Math_clamp(get(Elev_trim_ratio) + human_input * caculated_human_trim_speed * get(DELTA_TIME) * (1 - get(FAILURE_FCTL_THS_MECH)), -1, 1))
        set(THS_input_dataref, get(Elev_trim_ratio))
        set(Human_pitch_trim, 0)
    else
        set(Elev_trim_ratio, Set_linear_anim_value(get(Elev_trim_ratio), THS_target, -1, max_upwards_trim_ratio, caculated_trim_speed))
    end
end
