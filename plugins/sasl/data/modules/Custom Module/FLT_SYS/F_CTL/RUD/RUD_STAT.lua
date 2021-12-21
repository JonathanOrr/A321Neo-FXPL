FCTL.RUD.STAT = {
    controlled = true,
    bkup_ctl   = true,
    data_avail = true,
    total_hyd_press = 0,
    failure_dataref = FAILURE_FCTL_RUDDER,
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
        {BCM_status,    Hydraulic_Y_press},
    }
}
FCTL.RUDTRIM_MOTOR.STAT = {
    [1] = {
        avail = true,
        failure_dataref = FAILURE_FCTL_RUDTRIM_MOT_1,
        power = function ()
            return get(DC_ess_bus_pwrd) == 1
        end
    },
    [2] = {
        avail = true,
        failure_dataref = FAILURE_FCTL_RUDTRIM_MOT_2,
        power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
}
FCTL.RUDTRIM.STAT = {
    controlled = true,
    data_avail = true,
    computer_priority = {
        {SEC_1_status, FCTL.RUDTRIM_MOTOR.STAT[1]},
        {SEC_2_status, FCTL.RUDTRIM_MOTOR.STAT[2]},
    }
}

local function COMPUTE_RUDTRIM_MOTOR_STAT(fctl_tbl)
    if get(Print_rud_status) == 1 then
        print(" ")
        print("MOTORS:")
    end
    for i = 1, #fctl_tbl do
        if fctl_tbl[i].power() and get(fctl_tbl[i].failure_dataref) == 0 then
            fctl_tbl[i].avail = true
        else
            fctl_tbl[i].avail = false
        end

        if get(Print_rud_status) == 1 then
            print(i .. " AVAIL: " .. tostring(fctl_tbl[i].avail))
        end
    end
end

local function COMPUTE_RUDTRIM_STAT(fctl_tbl)
    local ACTIVE_CTL_PAIRS = 0
    local ACTIVE_COMPUTER = 0
    for i = 1, #fctl_tbl.computer_priority do
        --count the number of active computers--
        if get(fctl_tbl.computer_priority[i][1]) == 1 then
            ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
        end
        --count the number of active control pairs--
        if get(fctl_tbl.computer_priority[i][1]) == 1 and fctl_tbl.computer_priority[i][2].avail then
            ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
        end
    end

    if ACTIVE_CTL_PAIRS >= 1 then
        fctl_tbl.controlled = true
    else
        fctl_tbl.controlled = false
    end

    --see if data is available--
    if ACTIVE_COMPUTER >= 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
        fctl_tbl.data_avail = true
    else
        fctl_tbl.data_avail = false
    end

    if get(Print_rud_status) == 1 then
        print("TRIM:")
        print("CONTROLLED:   " .. tostring(fctl_tbl.controlled))
        print("DATA AVIAL:   " .. tostring(fctl_tbl.data_avail))
        print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
        print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
    end
end

local function COMPUTE_RUDDER_STAT(fctl_tbl)
    local ACTIVE_CTL_PAIRS = 0
    local ACTIVE_COMPUTER = 0
    for i = 1, #fctl_tbl.computer_priority do
        --count the number of active computers--
        if get(fctl_tbl.computer_priority[i][1]) == 1 then
            ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
        end
        --count the number of active control pairs--
        if get(fctl_tbl.computer_priority[i][1]) == 1 and get(fctl_tbl.computer_priority[i][2]) >= 1450 then
            ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
        end
    end

    --decide if surface is controlled by any computer--
    if ACTIVE_CTL_PAIRS >= 1 and get(fctl_tbl.failure_dataref) == 0 then
        fctl_tbl.controlled = true
    else
        fctl_tbl.controlled = false
    end

    --calculate total hydraulic pressure to the surface--
    fctl_tbl.total_hyd_press = 0
    for i = 1, #fctl_tbl.hyd_sys do
        fctl_tbl.total_hyd_press = fctl_tbl.total_hyd_press + get(fctl_tbl.hyd_sys[i])
    end

    --compute backup control status--
    if ACTIVE_CTL_PAIRS == 1 and
       get(fctl_tbl.computer_priority[#fctl_tbl.computer_priority][1]) == 1 and
       get(fctl_tbl.computer_priority[#fctl_tbl.computer_priority][2]) >= 1450 then
        fctl_tbl.bkup_ctl = true
    else
        fctl_tbl.bkup_ctl = false
    end

    --see if data of the surface is available--
    if ACTIVE_COMPUTER >= 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
        fctl_tbl.data_avail = true
    else
        fctl_tbl.data_avail = false
    end

    --debugging--
    if get(Print_rud_status) == 1 then
        print("RUDDER: ")
        print("CONTROLLED:   " .. tostring(fctl_tbl.controlled))
        print("BKUP CTL:     " .. tostring(fctl_tbl.bkup_ctl))
        print("DATA AVIAL:   " .. tostring(fctl_tbl.data_avail))
        print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
        print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
        print("TOTAL PRESS:  " .. fctl_tbl.total_hyd_press)
    end
end

function update()
    COMPUTE_RUDTRIM_MOTOR_STAT(FCTL.RUDTRIM_MOTOR.STAT)
    COMPUTE_RUDTRIM_STAT(FCTL.RUDTRIM.STAT)
    COMPUTE_RUDDER_STAT(FCTL.RUD.STAT)
end