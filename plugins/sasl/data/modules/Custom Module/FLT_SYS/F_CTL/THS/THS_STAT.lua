FBW.fctl.THS_MOTOR.STAT = {
    [1] = {
        avail = true,
        failure_dataref = FAILURE_FCTL_THS_MOT_1,
        power = function ()
            return get(HOT_bus_2_pwrd) == 1 or get(DC_bus_2_pwrd) == 1
        end
    },
    [2] = {
        avail = true,
        failure_dataref = FAILURE_FCTL_THS_MOT_2,
        power = function ()
            return get(DC_shed_ess_pwrd) == 1
        end
    },
    [3] = {
        avail = true,
        failure_dataref = FAILURE_FCTL_THS_MOT_3,
        power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
}
FBW.fctl.THS.STAT = {
    controlled = true,
    mechanical = true,
    data_avail = true,
    total_hyd_press = 0,
    failure_dataref = FAILURE_FCTL_THS_MECH,
    last_ELAC_1_STAT = 0,
    motor = {
        FBW.fctl.THS_MOTOR.STAT[1],
        FBW.fctl.THS_MOTOR.STAT[2],
        FBW.fctl.THS_MOTOR.STAT[3],
    },
    hyd_sys = {
        Hydraulic_G_press,
        Hydraulic_Y_press,
    },
    computer_priority = {
        {ELAC_2_status, FBW.fctl.THS_MOTOR.STAT[1]},
        {ELAC_1_status, FBW.fctl.THS_MOTOR.STAT[2]},
        {SEC_2_status,  FBW.fctl.THS_MOTOR.STAT[3]},
        {SEC_1_status,  FBW.fctl.THS_MOTOR.STAT[2]},
    }
}

FBW.fctl.THS_MOTOR.COMPUTE_STAT = function (fctl_table)
    if get(Print_ths_status) == 1 then
        print(" ")
        print("MOTORS:")
    end
    for i = 1, #fctl_table do
        if fctl_table[i].power() and get(fctl_table[i].failure_dataref) == 0 then
            fctl_table[i].avail = true
        else
            fctl_table[i].avail = false
        end

        if get(Print_ths_status) == 1 then
            print(i .. " AVAIL: " .. tostring(fctl_table[i].avail))
        end
    end
end

FBW.fctl.THS.COMPUTE_STAT = function (THS_table, ELEV_table)
    local ACTIVE_CTL_PAIRS = 0
    local ACTIVE_COMPUTER = 0
    local ACTIVE_MOTOR = 0
    --count the number of active motors--
    for i = 1, #THS_table.motor do
        if THS_table.motor[i].avail then
            ACTIVE_MOTOR = ACTIVE_MOTOR + 1
        end
    end
    for i = 1, #THS_table.computer_priority do
        --count the number of active computers--
        if get(THS_table.computer_priority[i][1]) == 1 then
            ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
        end
        --count the number of active control pairs--
        if get(THS_table.computer_priority[i][1]) == 1 and THS_table.computer_priority[i][2].avail then
            ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
        end
    end

    --calculate total hydraulic pressure to the surface--
    THS_table.total_hyd_press = 0
    for j = 1, #THS_table.hyd_sys do
        THS_table.total_hyd_press = THS_table.total_hyd_press + get(THS_table.hyd_sys[j])
    end

    --decide if THS is controlled by any computer--
    if ACTIVE_CTL_PAIRS >= 1 and THS_table.total_hyd_press >= 1450 and get(THS_table.failure_dataref) == 0 then
        THS_table.controlled = true
    else
        THS_table.controlled = false
    end
    --decide if THS is mechanically controllable--
    if ACTIVE_MOTOR > 0 and THS_table.total_hyd_press >= 1450 and get(THS_table.failure_dataref) == 0 then
        THS_table.mechanical = true
    else
        THS_table.mechanical = false
    end

    --see if data of the surface is available--
    if ACTIVE_COMPUTER >= 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
        THS_table.data_avail = true
    else
        THS_table.data_avail = false
    end

    --fail electrical control if both elevator failed (nothing to trim for)--
    local elev_sides = {
        {"L", "R"},
        {"R", "L"},
    }
    for i = 1, #elev_sides do
        local THIS_SIDE = elev_sides[i][1]
        local OPPO_SIDE = elev_sides[i][2]
        if not ELEV_table[THIS_SIDE].controlled and not ELEV_table[OPPO_SIDE].controlled then
            THS_table.controlled = false
        end
    end

    --debugging--
    if get(Print_ths_status) == 1 then
        print("THS: ")
        print("CONTROLLED:   " .. tostring(THS_table.controlled))
        print("MECHANICAL:   " .. tostring(THS_table.mechanical))
        print("DATA AVIAL:   " .. tostring(THS_table.data_avail))
        print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
        print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
        print("ACT MOTOR:    " .. ACTIVE_MOTOR)
        print("TOTAL PRESS:  " .. THS_table.total_hyd_press)
    end
end

--ELAC 1 reset on ground, THS set to 0--
FBW.fctl.THS.REST = function (THS_table, THS_POS_DATAREF)
    if get(ELAC_1_status) - THS_table.last_ELAC_1_STAT == 1 then
        if get(All_on_ground) == 1 then
            set(THS_POS_DATAREF, 0)
        end
    end
    THS_table.last_ELAC_1_STAT = get(ELAC_1_status)
end

function update()
    FBW.fctl.THS_MOTOR.COMPUTE_STAT(FBW.fctl.THS_MOTOR.STAT)
    FBW.fctl.THS.COMPUTE_STAT(FBW.fctl.THS.STAT, FBW.fctl.ELEV.STAT)
    FBW.fctl.THS.REST(FBW.fctl.THS.STAT, Digital_THS_def_tgt)
end