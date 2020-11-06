function Elevator_control(vertical_input)
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
    l_elev_target = Math_rescale(0, Math_rescale(0, max_dn_deflection, 1450, l_elev_target, get(Hydraulic_G_press) + get(Hydraulic_B_press)), no_hyd_recenter_ias, 0, get(IAS))
    r_elev_target = Math_rescale(0, Math_rescale(0, max_dn_deflection, 1450, r_elev_target, get(Hydraulic_Y_press) + get(Hydraulic_B_press)), no_hyd_recenter_ias, 0, get(IAS))

    set(Elevators_hstab_1, Set_linear_anim_value(get(Elevators_hstab_1), l_elev_target, max_up_deflection, max_dn_deflection, l_elev_spd))
    set(Elevators_hstab_2, Set_linear_anim_value(get(Elevators_hstab_2), r_elev_target, max_up_deflection, max_dn_deflection, r_elev_spd))
end