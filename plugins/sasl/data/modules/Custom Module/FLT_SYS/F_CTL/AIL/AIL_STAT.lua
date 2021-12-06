FBW.fctl.AIL.STAT = {
    L  = {
        controlled = true,
        data_avail = true,
        total_hyd_press = 0,
        failure_dataref = FAILURE_FCTL_LAIL,
        hyd_sys = {
            Hydraulic_G_press,
            Hydraulic_B_press,
        },
        computer_priority = {
            {ELAC_1_status, Hydraulic_B_press},
            {ELAC_2_status, Hydraulic_G_press},
        }
    },
    R  = {
        controlled = true,
        data_avail = true,
        total_hyd_press = 0,
        failure_dataref = FAILURE_FCTL_RAIL,
        hyd_sys = {
            Hydraulic_G_press,
            Hydraulic_B_press,
        },
        computer_priority = {
            {ELAC_1_status, Hydraulic_G_press},
            {ELAC_2_status, Hydraulic_B_press},
        }
    },
}

local function COMPUTE_AIL_STAT(fctl_table)
    for key, value in pairs(fctl_table) do
        local ACTIVE_CTL_PAIRS = 0
        local ACTIVE_COMPUTER = 0
        for i = 1, #fctl_table[key].computer_priority do
            --count the number of active computers--
            if get(fctl_table[key].computer_priority[i][1]) == 1 then
                ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
            end
            --count the number of active control pairs--
            if get(fctl_table[key].computer_priority[i][1]) == 1 and get(fctl_table[key].computer_priority[i][2]) >= 1450 then
                ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
            end
        end

        --decide if surface is controlled by any computer--
        if ACTIVE_CTL_PAIRS >= 1 and get(fctl_table[key].failure_dataref) == 0 then
            fctl_table[key].controlled = true
        else
            fctl_table[key].controlled = false
        end

        --calculate total hydraulic pressure to the surface--
        fctl_table[key].total_hyd_press = 0
        for i = 1, #fctl_table[key].hyd_sys do
            fctl_table[key].total_hyd_press = fctl_table[key].total_hyd_press + get(fctl_table[key].hyd_sys[i])
        end

        --see if data of the surface is available--
        if ACTIVE_COMPUTER >= 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
            fctl_table[key].data_avail = true
        else
            fctl_table[key].data_avail = false
        end

        --debugging--
        if get(Print_ail_status) == 1 then
            print(key .. " AIL:")
            print("CONTROLLED:   " .. tostring(fctl_table[key].controlled))
            print("DATA AVIAL:   " .. tostring(fctl_table[key].data_avail))
            print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
            print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
            print("TOTAL PRESS:  " .. fctl_table[key].total_hyd_press)
        end
    end
end

function update()
    COMPUTE_AIL_STAT(FBW.fctl.AIL.STAT)
end