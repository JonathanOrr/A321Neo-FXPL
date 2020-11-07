function Check_surface_avail()
    local num_of_spoilers = 5
    local l_spoilers_dataref = {Left_spoiler_1, Left_spoiler_2, Left_spoiler_3, Left_spoiler_4, Left_spoiler_5}
    local r_spoilers_dataref = {Right_spoiler_1, Right_spoiler_2, Right_spoiler_3, Right_spoiler_4, Right_spoiler_5}
    local l_spoilers_avail_dataref = {L_spoiler_1_avail, L_spoiler_2_avail, L_spoiler_3_avail, L_spoiler_4_avail, L_spoiler_5_avail}
    local r_spoilers_avail_dataref = {R_spoiler_1_avail, R_spoiler_2_avail, R_spoiler_3_avail, R_spoiler_4_avail, R_spoiler_5_avail}

    for i = 1, num_of_spoilers do
        set(l_spoilers_avail_dataref[i], 1)
        set(r_spoilers_avail_dataref[i], 1)
    end
    set(L_aileron_avail, 1)
    set(R_aileron_avail, 1)
    set(L_elevator_avail, 1)
    set(R_elevator_avail, 1)
    set(THS_avail, 1)

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

    end

    --tripple failure
    if get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0 and get(SEC_1_status) == 0 and get(SEC_2_status) == 0 then
        set(L_elevator_avail, 0)
        set(R_elevator_avail, 0)
        set(THS_avail, 0)
    end

    --HYD failures
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
    end
    if get(Hydraulic_B_press) < 1450 and get(Hydraulic_Y_press) < 1450 then
        set(R_elevator_avail, 0)
    end

    --tripple system failure
    if get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450 and get(Hydraulic_Y_press) < 1450 then

    end

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