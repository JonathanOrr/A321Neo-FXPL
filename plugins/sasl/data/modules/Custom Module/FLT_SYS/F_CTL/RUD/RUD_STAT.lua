FBW.fctl.RUD.MOTOR_STAT = {
    TRIM = {
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
    LIMIT = {
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
FBW.fctl.RUD.TRIM_STAT = {
    controlled = true,
    data_avail = true,
    computer_priority = {
        {FBW.FLT_computer.FAC[1].MON_CHANEL_avail, FBW.fctl.RUD.MOTOR_STAT.TRIM[1]},
        {FBW.FLT_computer.FAC[2].MON_CHANEL_avail, FBW.fctl.RUD.MOTOR_STAT.TRIM[2]},
    },
}
FBW.fctl.RUD.LIM_STAT = {
    controlled = true,
    data_avail = true,
    computer_priority = {
        {FBW.FLT_computer.FAC[1].MON_CHANEL_avail, FBW.fctl.RUD.MOTOR_STAT.LIMIT[1]},
        {FBW.FLT_computer.FAC[2].MON_CHANEL_avail, FBW.fctl.RUD.MOTOR_STAT.LIMIT[2]},
    },
}
FBW.fctl.RUD.RUD_STAT = {
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
        {FBW.FLT_computer.FAC[1].MON_CHANEL_avail, Hydraulic_G_press},
        {FBW.FLT_computer.FAC[2].MON_CHANEL_avail, Hydraulic_Y_press},
    }
}

local function COMPUTE_MOTOR_STAT(fctl_table)
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

local function COMPUTE_LIM_TRIM_STAT(LIM_TRIM_table) --TODO: LIMIT FAILS WITH ADR
    local ACTIVE_CTL_PAIRS = 0
    local ACTIVE_MON = 0
    for i = 1, #LIM_TRIM_table.computer_priority do
        --count the number of active computers--
        if LIM_TRIM_table.computer_priority[i][1]() then
            ACTIVE_MON = ACTIVE_MON + 1
        end
        --count the number of active control pairs--
        if LIM_TRIM_table.computer_priority[i][1]() and LIM_TRIM_table.computer_priority[i][2].avail then
            ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
        end
    end

    --decide if SYS is available--
    if ACTIVE_CTL_PAIRS >= 1 then
        LIM_TRIM_table.controlled = true
    else
        LIM_TRIM_table.controlled = false
    end

    --see if data of the system is available--
    if ACTIVE_MON >= 1 then
        LIM_TRIM_table.data_avail = true
    else
        LIM_TRIM_table.data_avail = false
    end

    if get(Print_rud_status) == 1 then
        print("LIM TRIM:")
        print("CONTROLLED:   " .. tostring(LIM_TRIM_table.controlled))
        print("DATA AVIAL:   " .. tostring(LIM_TRIM_table.data_avail))
        print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
        print("ACT FAC MON:  " .. ACTIVE_MON)
    end
end

local function COMPUTE_RUDDER_STAT(RUDDER_TABLE)
    local ACTIVE_CTL_PAIRS = 0
    local ACTIVE_MON = 0
    for i = 1, #RUDDER_TABLE.computer_priority do
        --count the number of active computers--
        if RUDDER_TABLE.computer_priority[i][1]() then
            ACTIVE_MON = ACTIVE_MON + 1
        end
        --count the number of active control pairs--
        if RUDDER_TABLE.computer_priority[i][1]() and get(RUDDER_TABLE.computer_priority[i][2]) >= 1450 then
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
    if ACTIVE_MON >= 1 then
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
        print("ACT FAC MON:  " .. ACTIVE_MON)
        print("TOTAL PRESS:  " .. RUDDER_TABLE.total_hyd_press)
    end
end

function update()
    COMPUTE_MOTOR_STAT(FBW.fctl.RUD.MOTOR_STAT)
    COMPUTE_LIM_TRIM_STAT(FBW.fctl.RUD.LIM_STAT)
    COMPUTE_LIM_TRIM_STAT(FBW.fctl.RUD.TRIM_STAT)
    COMPUTE_RUDDER_STAT(FBW.fctl.RUD.RUD_STAT)
end