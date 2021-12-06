FBW.fctl.RUD.STAT = {
    controlled = true,
    data_avail = true,
    total_hyd_press = 0,
    failure_dataref = FAILURE_FCTL_RUDDER_MECH,
    hyd_sys = {
        Hydraulic_G_press,
        Hydraulic_B_press,
        Hydraulic_Y_press,
    },
    computer_priority = {
        {ELAC_2_status, Hydraulic_G_press},
        {SEC_2_status,  Hydraulic_Y_press},
        {ELAC_1_status, Hydraulic_B_press},
        {SEC_1_status,  Hydraulic_B_press},
    }
}

local function COMPUTE_RUDDER_STAT(RUDDER_TABLE)
    local ACTIVE_CTL_PAIRS = 0
    local ACTIVE_COMPUTER = 0
    for i = 1, #RUDDER_TABLE.computer_priority do
        --count the number of active computers--
        if get(RUDDER_TABLE.computer_priority[i][1]) == 1 then
            ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
        end
        --count the number of active control pairs--
        if get(RUDDER_TABLE.computer_priority[i][1]) == 1 and get(RUDDER_TABLE.computer_priority[i][2]) >= 1450 then
            ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
        end
    end

    --decide if surface is controlled by any computer--
    if ACTIVE_CTL_PAIRS >= 1 and get(RUDDER_TABLE.failure_dataref) == 0 then
        RUDDER_TABLE.controlled = true
    else
        RUDDER_TABLE.controlled = false
    end

    --calculate total hydraulic pressure to the surface--
    RUDDER_TABLE.total_hyd_press = 0
    for i = 1, #RUDDER_TABLE.hyd_sys do
        RUDDER_TABLE.total_hyd_press = RUDDER_TABLE.total_hyd_press + get(RUDDER_TABLE.hyd_sys[i])
    end

    --see if data of the surface is available--
    if ACTIVE_COMPUTER >= 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
        RUDDER_TABLE.data_avail = true
    else
        RUDDER_TABLE.data_avail = false
    end

    --debugging--
    if get(Print_rud_status) == 1 then
        print("RUDDER: ")
        print("CONTROLLED:   " .. tostring(RUDDER_TABLE.controlled))
        print("DATA AVIAL:   " .. tostring(RUDDER_TABLE.data_avail))
        print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
        print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
        print("TOTAL PRESS:  " .. RUDDER_TABLE.total_hyd_press)
    end
end

function update()
    COMPUTE_RUDDER_STAT(FBW.fctl.RUD.STAT)
end