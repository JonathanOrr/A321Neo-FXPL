function Check_surface_avail()
    local num_of_spoilers = 5
    local l_spoilers_dataref = {Left_spoiler_1, Left_spoiler_2, Left_spoiler_3, Left_spoiler_4, Left_spoiler_5}
    local r_spoilers_dataref = {Right_spoiler_1, Right_spoiler_2, Right_spoiler_3, Right_spoiler_4, Right_spoiler_5}
    local l_spoilers_avail_dataref = {L_spoiler_1_avail, L_spoiler_2_avail, L_spoiler_3_avail, L_spoiler_4_avail, L_spoiler_5_avail}
    local r_spoilers_avail_dataref = {R_spoiler_1_avail, R_spoiler_2_avail, R_spoiler_3_avail, R_spoiler_4_avail, R_spoiler_5_avail}
    local l_spoilers_failure_dataref = {FAILURE_FCTL_LSPOIL_1, FAILURE_FCTL_LSPOIL_2, FAILURE_FCTL_LSPOIL_3, FAILURE_FCTL_LSPOIL_4, FAILURE_FCTL_LSPOIL_5}
    local r_spoilers_failure_dataref = {FAILURE_FCTL_RSPOIL_1, FAILURE_FCTL_RSPOIL_2, FAILURE_FCTL_RSPOIL_3, FAILURE_FCTL_RSPOIL_4, FAILURE_FCTL_RSPOIL_5}

    set(All_spoilers_failed, 0)
    for i = 1, num_of_spoilers do
        set(l_spoilers_avail_dataref[i], 1)
        set(r_spoilers_avail_dataref[i], 1)
    end
    set(L_aileron_avail, 1)
    set(R_aileron_avail, 1)
    set(L_elevator_avail, 1)
    set(R_elevator_avail, 1)
    set(THS_avail, 1)
    set(Yaw_damper_avail, 1)
    set(Rudder_avail, 1)
    set(Rudder_lim_avail, 1)
    set(Rudder_trim_avail, 1)

    --computer failures--
    --single failure
    if get(SEC_1_status) == 0 then
        set(l_spoilers_avail_dataref[3], 0)
        set(l_spoilers_avail_dataref[4], 0)
        set(r_spoilers_avail_dataref[3], 0)
        set(r_spoilers_avail_dataref[4], 0)
    end
    if get(SEC_2_status) == 0 then
        set(l_spoilers_avail_dataref[5], 0)
        set(r_spoilers_avail_dataref[5], 0)
    end
    if get(SEC_3_status) == 0 then
        set(l_spoilers_avail_dataref[1], 0)
        set(l_spoilers_avail_dataref[2], 0)
        set(r_spoilers_avail_dataref[1], 0)
        set(r_spoilers_avail_dataref[2], 0)
    end

    --dual failure
    if get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0 then
        set(L_aileron_avail, 0)
        set(R_aileron_avail, 0)
    end
    if get(FAC_1_status) == 0 and get(FAC_2_status) == 0 then
        set(Yaw_damper_avail, 0)
        set(Rudder_trim_avail, 0)
        set(Rudder_avail, 0)
        set(Rudder_lim_avail, 0)
    end

    --tripple failure
    if get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0 and get(SEC_1_status) == 0 and get(SEC_2_status) == 0 then
        set(L_elevator_avail, 0)
        set(R_elevator_avail, 0)
        set(THS_avail, 0)
    end

    --HYD FAILURES--
    --single system failure
    if get(Hydraulic_G_press) < 1450 then
        set(l_spoilers_avail_dataref[1], 0)
        set(l_spoilers_avail_dataref[5], 0)
        set(r_spoilers_avail_dataref[1], 0)
        set(r_spoilers_avail_dataref[5], 0)

    end
    if get(Hydraulic_B_press) < 1450 then
        set(l_spoilers_avail_dataref[3], 0)
        set(r_spoilers_avail_dataref[3], 0)
    end
    if get(Hydraulic_Y_press) < 1450 then
        set(l_spoilers_avail_dataref[2], 0)
        set(l_spoilers_avail_dataref[4], 0)
        set(r_spoilers_avail_dataref[2], 0)
        set(r_spoilers_avail_dataref[4], 0)
    end

    --double system failure
    if get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450 then
        set(L_aileron_avail, 0)
        set(R_aileron_avail, 0)
        set(L_elevator_avail, 0)
    end
    if get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450 then
        set(THS_avail, 0)
        set(Yaw_damper_avail, 0)
    end
    if get(Hydraulic_B_press) < 1450 and get(Hydraulic_Y_press) < 1450 then
        set(R_elevator_avail, 0)
    end

    --tripple system failure
    if get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450 and get(Hydraulic_Y_press) < 1450 then
        set(Rudder_avail, 0)
    end

    --rudder electrical motors failure--
    if get(DC_ess_bus_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 then
        set(Rudder_lim_avail, 0)
        set(Rudder_trim_avail, 0)
    end

    --FAILURE MANAGER--
    local number_of_spoilers_avail = 0
    for i = 1, num_of_spoilers do
        set(l_spoilers_avail_dataref[i], get(l_spoilers_avail_dataref[i]) * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i])))
        set(r_spoilers_avail_dataref[i], get(r_spoilers_avail_dataref[i]) * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i])))

        number_of_spoilers_avail = number_of_spoilers_avail + get(l_spoilers_avail_dataref[i])
        number_of_spoilers_avail = number_of_spoilers_avail + get(r_spoilers_avail_dataref[i])
    end

    if number_of_spoilers_avail == 0 then
        set(All_spoilers_failed, 1)
    end

    set(L_aileron_avail, get(L_aileron_avail) * (1 - get(FAILURE_FCTL_LAIL)))
    set(R_aileron_avail, get(R_aileron_avail) * (1 - get(FAILURE_FCTL_RAIL)))
    set(L_elevator_avail, get(L_elevator_avail) * (1 - get(FAILURE_FCTL_LELEV)))
    set(R_elevator_avail, get(R_elevator_avail) * (1 - get(FAILURE_FCTL_RELEV)))
    set(THS_avail, get(THS_avail) * (1 - get(FAILURE_FCTL_THS_MECH)))
    set(Rudder_lim_avail, get(Rudder_lim_avail) * (1 - get(FAILURE_FCTL_RUDDER_LIM)) * (1 - get(FAILURE_FCTL_RUDDER_MECH)))
    set(Rudder_trim_avail, get(Rudder_trim_avail) * (1 - get(FAILURE_FCTL_RUDDER_TRIM)) * (1 - get(FAILURE_FCTL_RUDDER_MECH)))
    set(Rudder_avail, get(Rudder_avail) * (1 - get(FAILURE_FCTL_RUDDER_MECH)))
    set(Yaw_damper_avail, get(Yaw_damper_avail) * (1 - get(FAILURE_FCTL_YAW_DAMPER)))

    --if spoilers is faulty and more than 2.5 degrees of extention then go amber
    for i = 1, num_of_spoilers do
        if get(l_spoilers_avail_dataref[i]) == 0 and get(l_spoilers_dataref[i]) >= 2.5 then
            set(l_spoilers_avail_dataref[i], -1)
        end
        if get(r_spoilers_avail_dataref[i]) == 0 and get(r_spoilers_dataref[i]) >= 2.5 then
            set(r_spoilers_avail_dataref[i], -1)
        end
    end
end