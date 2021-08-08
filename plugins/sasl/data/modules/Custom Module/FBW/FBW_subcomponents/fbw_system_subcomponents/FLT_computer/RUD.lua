FBW.fctl.surfaces.rud = {}
FBW.fctl.surfaces.rud.motor = {
    trim = {
        [1] = {
            avail = true,
            failure_dataref = FAILURE_FCTL_RUDDER_TRIM_MOT_1,
            power = function ()
                return get(DC_shed_ess_pwrd) == 1
            end
        },
        [2] = {
            avail = true,
            failure_dataref = FAILURE_FCTL_RUDDER_TRIM_MOT_2,
            power = function ()
                return get(DC_bus_2_pwrd) == 1
            end
        },
    },
    limit = {
        [1] = {
            avail = true,
            failure_dataref = FAILURE_FCTL_RUDDER_LIM_MOT_1,
            power = function ()
                return get(DC_shed_ess_pwrd) == 1
            end
        },
        [2] = {
            avail = true,
            failure_dataref = FAILURE_FCTL_RUDDER_LIM_MOT_2,
            power = function ()
                return get(DC_bus_2_pwrd) == 1
            end
        },
    }
}
FBW.fctl.surfaces.rud.trim = {
    controlled = true,
    data_avail = true,
    total_hyd_press = 0,
    hyd_sys = {
        Hydraulic_G_press,
        Hydraulic_B_press,
        Hydraulic_Y_press,
    },
    computer_priority = {
        {FAC_1_status, FBW.fctl.surfaces.rud.motor.trim[1]},
        {FAC_2_status, FBW.fctl.surfaces.rud.motor.trim[2]},
    },
}
FBW.fctl.surfaces.rud.lim = {
    controlled = true,
    data_avail = true,
    total_hyd_press = 0,
    hyd_sys = {
        Hydraulic_G_press,
        Hydraulic_B_press,
        Hydraulic_Y_press,
    },
    computer_priority = {
        {FAC_1_status, FBW.fctl.surfaces.rud.motor.limit[1]},
        {FAC_2_status, FBW.fctl.surfaces.rud.motor.limit[2]},
    },
}
FBW.fctl.surfaces.rud.rud = {
    controlled = true,
    mechanical = true,
    data_avail = true,
    total_hyd_press = 0,
    failure_dataref = FAILURE_FCTL_RUDDER_MECH,
    hyd_sys = {
        Hydraulic_G_press,
        Hydraulic_B_press,
        Hydraulic_Y_press,
    },
    computer_priority = {
        {FAC_1_status, Hydraulic_G_press},
        {FAC_2_status, Hydraulic_Y_press},
    }
}

FBW.fctl.status.RUDDER_MOTOR = function (fctl_table)
    for key, value in pairs(fctl_table) do
        if get(Print_rud_status) == 1 then
            print(key .. " MOT:")
        end

        for i = 1, #fctl_table[key] do
            if fctl_table[key][i].power() and get(fctl_table[key][i].failure_dataref) == 0 then
                fctl_table[key][i].avail = true
            else
                fctl_table[key][i].avail = false
            end

            if get(Print_rud_status) == 1 then
                print(i .. " AVAIL: " .. tostring(fctl_table[key][i].avail))
            end
        end
    end
end

FBW.fctl.status.RUDDER_LIM_TRIM = function (LIM_TRIM_table)
    local ACTIVE_CTL_PAIRS = 0
    local ACTIVE_COMPUTER = 0
    for i = 1, #LIM_TRIM_table.computer_priority do
        --count the number of active computers--
        if get(LIM_TRIM_table.computer_priority[i][1]) == 1 then
            ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
        end
        --count the number of active control pairs--
        if get(LIM_TRIM_table.computer_priority[i][1]) == 1 and LIM_TRIM_table.computer_priority[i][2].avail then
            ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
        end
    end

    --calculate total hydraulic pressure to the system--
    LIM_TRIM_table.total_hyd_press = 0
    for i = 1, #LIM_TRIM_table.hyd_sys do
        LIM_TRIM_table.total_hyd_press = LIM_TRIM_table.total_hyd_press + get(LIM_TRIM_table.hyd_sys[i])
    end

    --decide if SYS is available--
    if ACTIVE_CTL_PAIRS >= 1 and LIM_TRIM_table.total_hyd_press >= 1450 then
        LIM_TRIM_table.controlled = true
    else
        LIM_TRIM_table.controlled = false
    end

    --see if data of the system is available--
    if ACTIVE_COMPUTER >= 1 then
        LIM_TRIM_table.data_avail = true
    else
        LIM_TRIM_table.data_avail = false
    end

    if get(Print_rud_status) == 1 then
        print("LIM TRIM:")
        print("CONTROLLED:   " .. tostring(LIM_TRIM_table.controlled))
        print("DATA AVIAL:   " .. tostring(LIM_TRIM_table.data_avail))
        print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
        print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
        print("TOTAL PRESS:  " .. LIM_TRIM_table.total_hyd_press)
    end
end

FBW.fctl.status.RUDDER = function (RUDDER_TABLE)
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

    --calculate total hydraulic pressure to the surface--
    RUDDER_TABLE.total_hyd_press = 0
    for j = 1, #RUDDER_TABLE.hyd_sys do
        RUDDER_TABLE.total_hyd_press = RUDDER_TABLE.total_hyd_press + get(RUDDER_TABLE.hyd_sys[j])
    end

    --decide if RUDDER is controlled by any computer--
    if ACTIVE_CTL_PAIRS >= 1 and get(RUDDER_TABLE.failure_dataref) == 0 then
        RUDDER_TABLE.controlled = true
    else
        RUDDER_TABLE.controlled = false
    end
    --decide if RUDDER is mechanically controllable--
    if RUDDER_TABLE.total_hyd_press >= 1450 and get(RUDDER_TABLE.failure_dataref) == 0 then
        RUDDER_TABLE.mechanical = true
    else
        RUDDER_TABLE.mechanical = false
    end

    --see if data of the surface is available--
    if ACTIVE_COMPUTER >= 1 then
        RUDDER_TABLE.data_avail = true
    else
        RUDDER_TABLE.data_avail = false
    end

    --debugging--
    if get(Print_rud_status) == 1 then
        print("RUDDER: ")
        print("CONTROLLED:   " .. tostring(RUDDER_TABLE.controlled))
        print("MECHANICAL:   " .. tostring(RUDDER_TABLE.mechanical))
        print("DATA AVIAL:   " .. tostring(RUDDER_TABLE.data_avail))
        print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
        print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
        print("TOTAL PRESS:  " .. RUDDER_TABLE.total_hyd_press)
    end
end

function update()
    FBW.fctl.status.RUDDER_MOTOR(FBW.fctl.surfaces.rud.motor)
    FBW.fctl.status.RUDDER_LIM_TRIM(FBW.fctl.surfaces.rud.lim)
    FBW.fctl.status.RUDDER_LIM_TRIM(FBW.fctl.surfaces.rud.trim)
    FBW.fctl.status.RUDDER(FBW.fctl.surfaces.rud.rud)
end