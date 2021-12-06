FBW.fctl.ELEV.STAT = {
    L  = {
        controlled = true,
        centered = false,
        data_avail = true,
        total_hyd_press = 0,
        failure_dataref = FAILURE_FCTL_LELEV,
        hyd_sys = {
            Hydraulic_G_press,
            Hydraulic_B_press,
        },
        computer_priority = {
            {ELAC_2_status, {Hydraulic_G_press, Hydraulic_Y_press}},
            {ELAC_2_status, {Hydraulic_G_press}},
            {ELAC_1_status, {Hydraulic_B_press}},
            {SEC_2_status,  {Hydraulic_G_press}},
            {SEC_1_status,  {Hydraulic_B_press}},
        }
    },
    R  = {
        controlled = true,
        centered = false,
        data_avail = true,
        total_hyd_press = 0,
        failure_dataref = FAILURE_FCTL_RELEV,
        hyd_sys = {
            Hydraulic_B_press,
            Hydraulic_Y_press,
        },
        computer_priority = {
            {ELAC_2_status, {Hydraulic_G_press, Hydraulic_Y_press}},
            {ELAC_2_status, {Hydraulic_Y_press}},
            {ELAC_1_status, {Hydraulic_B_press}},
            {SEC_2_status,  {Hydraulic_Y_press}},
            {SEC_1_status,  {Hydraulic_B_press}},
        }
    },
}

local function COMPUTE_ELEV_STAT(fctl_table)
    local elev_sides = {
        {"L", "R"},
        {"R", "L"},
    }

    for i = 1, #elev_sides do
        local THIS_SIDE = elev_sides[i][1]
        local OPPO_SIDE = elev_sides[i][2]
        local ACTIVE_CTL_PAIRS = 0
        local ACTIVE_COMPUTER = 0
        for j = 1, #fctl_table[THIS_SIDE].computer_priority do
            --count the number of active computers--
            if get(fctl_table[THIS_SIDE].computer_priority[j][1]) == 1 then
                ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
            end
            --count the number of active control pairs--
            if get(fctl_table[THIS_SIDE].computer_priority[j][1]) == 1 then
                --see if all paired HYD systems are working--
                local ALL_HYD_ACTIVE = true
                for k = 1, #fctl_table[THIS_SIDE].computer_priority[j][2] do
                    if get(fctl_table[THIS_SIDE].computer_priority[j][2][k]) < 1450 then
                        ALL_HYD_ACTIVE = false
                    end
                end

                if ALL_HYD_ACTIVE then
                    ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
                end
            end
        end

        --decide if surface is controlled by any computer--
        if ACTIVE_CTL_PAIRS >= 1 and get(fctl_table[THIS_SIDE].failure_dataref) == 0 then
            fctl_table[THIS_SIDE].controlled = true
        else
            fctl_table[THIS_SIDE].controlled = false
        end

        --calculate total hydraulic pressure to the surface--
        fctl_table[THIS_SIDE].total_hyd_press = 0
        for j = 1, #fctl_table[THIS_SIDE].hyd_sys do
            fctl_table[THIS_SIDE].total_hyd_press = fctl_table[THIS_SIDE].total_hyd_press + get(fctl_table[THIS_SIDE].hyd_sys[j])
        end

        --see if data of the surface is available--
        if ACTIVE_COMPUTER >= 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
            fctl_table[THIS_SIDE].data_avail = true
        else
            fctl_table[THIS_SIDE].data_avail = false
        end

        --debugging--
        if get(Print_elev_status) == 1 then
            print(THIS_SIDE .. " ELEV:")
            print("CONTROLLED:   " .. tostring(fctl_table[THIS_SIDE].controlled))
            print("CENTERED:     " .. tostring(fctl_table[THIS_SIDE].centered))
            print("DATA AVIAL:   " .. tostring(fctl_table[THIS_SIDE].data_avail))
            print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
            print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
            print("TOTAL PRESS:  " .. fctl_table[THIS_SIDE].total_hyd_press)
        end
    end

    for i = 1, #elev_sides do
        local THIS_SIDE = elev_sides[i][1]
        local OPPO_SIDE = elev_sides[i][2]

        --both side no control but have hydraulics, center surfaces--
        fctl_table[THIS_SIDE].centered = false
        if not fctl_table[THIS_SIDE].controlled and not fctl_table[OPPO_SIDE].controlled then
            if fctl_table[THIS_SIDE].total_hyd_press >= 1450 and fctl_table[OPPO_SIDE].total_hyd_press >= 1450 then
                fctl_table[THIS_SIDE].centered = true
            end
        end
    end
end

function update()
    COMPUTE_ELEV_STAT(FBW.fctl.ELEV.STAT)
end
