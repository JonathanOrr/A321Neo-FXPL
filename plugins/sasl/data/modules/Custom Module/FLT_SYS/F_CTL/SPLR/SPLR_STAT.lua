FBW.fctl.SPLR.STAT = {
    L ={
        [1]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_LSPOIL_1,
            hyd_sys = Hydraulic_G_press,
            computer = SEC_3_status,
        },
        [2]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_LSPOIL_2,
            hyd_sys = Hydraulic_Y_press,
            computer = SEC_3_status,
        },
        [3]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_LSPOIL_3,
            hyd_sys = Hydraulic_B_press,
            computer = SEC_1_status,
        },
        [4]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_LSPOIL_4,
            hyd_sys = Hydraulic_Y_press,
            computer = SEC_1_status,
        },
        [5]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_LSPOIL_5,
            hyd_sys = Hydraulic_G_press,
            computer = SEC_2_status,
        },
    },
    R ={
        [1]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_RSPOIL_1,
            hyd_sys = Hydraulic_G_press,
            computer = SEC_3_status,
        },
        [2]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_RSPOIL_2,
            hyd_sys = Hydraulic_Y_press,
            computer = SEC_3_status,
        },
        [3]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_RSPOIL_3,
            hyd_sys = Hydraulic_B_press,
            computer = SEC_1_status,
        },
        [4]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_RSPOIL_4,
            hyd_sys = Hydraulic_Y_press,
            computer = SEC_1_status,
        },
        [5]  = {
            controlled = true,
            data_avail = true,
            total_hyd_press = 0,
            failure_dataref = FAILURE_FCTL_RSPOIL_5,
            hyd_sys = Hydraulic_G_press,
            computer = SEC_2_status,
        },
    }
}

FBW.fctl.SPLR.COMPUTE_STAT = function (fctl_table)
    local splr_sides = {
        {"L", "R"},
        {"R", "L"},
    }

    for i = 1, #splr_sides do
        local THIS_SIDE = splr_sides[i][1]
        local OPPO_SIDE = splr_sides[i][2]
        for j = 1, #fctl_table[THIS_SIDE] do
            --decide if surface is controlled by any computer--
            fctl_table[THIS_SIDE][j].controlled = false
            if get(fctl_table[THIS_SIDE][j].computer) == 1 and
               get(fctl_table[THIS_SIDE][j].hyd_sys) >= 1450 and
               get(fctl_table[THIS_SIDE][j].failure_dataref) == 0 then
                fctl_table[THIS_SIDE][j].controlled = true
            end

            --calculate total hydraulic pressure to the surface--
            fctl_table[THIS_SIDE][j].total_hyd_press = 0
            fctl_table[THIS_SIDE][j].total_hyd_press = get(fctl_table[THIS_SIDE][j].hyd_sys)

            --see if data of the surface is available--
            if get(fctl_table[THIS_SIDE][j].computer) == 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
                fctl_table[THIS_SIDE][j].data_avail = true
            else
                fctl_table[THIS_SIDE][j].data_avail = false
            end
        end
    end

    --check for symmetrical inhibitions--
    for i = 1, #splr_sides do
        local THIS_SIDE = splr_sides[i][1]
        local OPPO_SIDE = splr_sides[i][2]
        for j = 1, #fctl_table[THIS_SIDE] do
            if not fctl_table[OPPO_SIDE][j].controlled then
                fctl_table[THIS_SIDE][j].controlled = false
            end

            --debugging--
            if get(Print_splr_status) == 1 then
                print(THIS_SIDE .. " SIDE " .. j .. " SPLR:")
                print("CONTROLLED:   " .. tostring(fctl_table[THIS_SIDE][j].controlled))
                print("DATA AVIAL:   " .. tostring(fctl_table[THIS_SIDE][j].data_avail))
                print("SEC AVAIL:    " .. get(fctl_table[THIS_SIDE][j].computer))
                print("TOTAL PRESS:  " .. fctl_table[THIS_SIDE][j].total_hyd_press)
            end
        end
    end
end

function update()
    FBW.fctl.SPLR.COMPUTE_STAT(FBW.fctl.SPLR.STAT)
end