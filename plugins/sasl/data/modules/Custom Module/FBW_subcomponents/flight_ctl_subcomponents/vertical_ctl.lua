function Elevator_control(vertical_input, in_direct_law)
    --HYD reversion
    --left  G --> B
    --right Y --> B
    --flt computer reversion
    --ELAC 2 --> ELAC 1 --> SEC 2 --> SEC 1
    --flight computer THS motor relation
    --MOTOR 1(ELAC 2)
    --MOTOR 2(ELAC 1 | SEC 1)
    --MOTOR 3(SEC 2)

    local no_hyd_recenter_ias = 80
    local elev_no_hyd_spd = 10
    local elevators_speed = 45 --degrees per second

    local max_up_deflection = -30
    local max_dn_deflection = 17

    local max_direct_law_up = -(3.704475 + (15.8338 - 3.703375) / (1 + (get(IAS) / 252.8894)^8.89914))
    local max_direct_law_dn = 3.759707 + (11.8902 - 3.759707) / (1 + (get(IAS) / 321.8764)^8.21922)

    --surface variables--
    local l_elev_spd = 45
    local r_elev_spd = 45

    local l_elev_target = 0
    local r_elev_target = 0

    --SURFACE SPEEDS LOGIC--
    --left  G --> B
    --right Y --> B
    l_elev_spd = Math_rescale(0, elev_no_hyd_spd, 1450, elevators_speed, get(Hydraulic_G_press) + get(Hydraulic_B_press))
    r_elev_spd = Math_rescale(0, elev_no_hyd_spd, 1450, elevators_speed, get(Hydraulic_Y_press) + get(Hydraulic_B_press))

    l_elev_spd = l_elev_spd * (1 - get(FAILURE_FCTL_LELEV))
    r_elev_spd = r_elev_spd * (1 - get(FAILURE_FCTL_RELEV))

    --TARGET DEFECTION LOGIC--
    l_elev_target = Math_rescale(-1, max_dn_deflection, 0, 0, vertical_input) + Math_rescale(0, 0, 1, max_up_deflection, vertical_input)
    r_elev_target = Math_rescale(-1, max_dn_deflection, 0, 0, vertical_input) + Math_rescale(0, 0, 1, max_up_deflection, vertical_input)

    --if no elecrical control on both elevators then go to centering mode
    --if no hydraulics control on both systems then go to damping mode
    if get(ELAC_2_status) == 0 and get(ELAC_1_status) == 0 and get(SEC_2_status) == 0 and get(SEC_1_status) == 0 then
        l_elev_target = 0
        r_elev_target = 0
    end

    --surface droop
    l_elev_target = Math_rescale(0, Math_rescale(0, max_dn_deflection, no_hyd_recenter_ias, -get(Alpha) - get(Horizontal_stabilizer_deflection), get(IAS)), 1450, l_elev_target, get(Hydraulic_G_press) + get(Hydraulic_B_press))
    r_elev_target = Math_rescale(0, Math_rescale(0, max_dn_deflection, no_hyd_recenter_ias, -get(Alpha) - get(Horizontal_stabilizer_deflection), get(IAS)), 1450, r_elev_target, get(Hydraulic_Y_press) + get(Hydraulic_B_press))

    if get(FBW_vertical_law) ~= FBW_DIRECT_LAW then
        set(Elevators_hstab_1, Set_linear_anim_value(get(Elevators_hstab_1), l_elev_target, max_up_deflection, max_dn_deflection, l_elev_spd))
        set(Elevators_hstab_2, Set_linear_anim_value(get(Elevators_hstab_2), r_elev_target, max_up_deflection, max_dn_deflection, r_elev_spd))
    else
        set(Elevators_hstab_1, Set_linear_anim_value(get(Elevators_hstab_1), l_elev_target, max_direct_law_up, max_direct_law_dn, l_elev_spd))
        set(Elevators_hstab_2, Set_linear_anim_value(get(Elevators_hstab_2), r_elev_target, max_direct_law_up, max_direct_law_dn, r_elev_spd))
    end
end

function XP_trim_up(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Human_pitch_trim, 1)
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
        set(Elev_trim_ratio, Set_linear_anim_value(get(Elev_trim_ratio), THS_target, -1, 1, caculated_trim_speed))
    end
end