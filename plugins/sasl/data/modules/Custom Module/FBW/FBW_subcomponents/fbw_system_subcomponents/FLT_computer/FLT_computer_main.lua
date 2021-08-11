addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/FLT_computer")

FBW.FLT_computer = {}
FBW.FLT_computer.ELAC = {
    [1] = {
        Start_timer = 0,
        Test_time = function ()
            local LONG_TEST_TIME = 8
            local SHORT_TEST_TIME = 1.5
            local TIMER_MAX = 10

            local G_press = get(Hydraulic_G_press)
            local B_press = get(Hydraulic_B_press)
            local Y_press = get(Hydraulic_Y_press)

            --find required start time (according to AMM 27-93-00-P60)--
            if G_press < 1450 and B_press < 1450 and Y_press < 1450 then
                return LONG_TEST_TIME, TIMER_MAX
            else
                return SHORT_TEST_TIME, TIMER_MAX
            end
        end,
        Button_address = PB.ovhd.flt_ctl_elac_1,
        Status_dataref = ELAC_1_status,
        Button_dataref = ELAC_1_off_button,
        Last_computer_status = 0,
        Last_button_status = 0,
        Last_power_status = 0,
        Transient_str_time = 0,
        Transient_end_time = 0,
        Transient_reset_required = false,
        Transient_reset_pending = false,
        IR_reset_required = true,
        IR_reset_pending = false,
        Failure_dataref = FAILURE_FCTL_ELAC_1,
        Power = function ()
            return get(HOT_bus_1_pwrd) == 1 or get(DC_ess_bus_pwrd) == 1
        end
    },
    [2] = {
        Start_timer = 0,
        Test_time = function ()
            local LONG_TEST_TIME = 8
            local SHORT_TEST_TIME = 1.5
            local TIMER_MAX = 10

            local G_press = get(Hydraulic_G_press)
            local B_press = get(Hydraulic_B_press)
            local Y_press = get(Hydraulic_Y_press)

            --find required start time (according to AMM 27-93-00-P60)--
            if G_press < 1450 and B_press < 1450 and Y_press < 1450 then
                return LONG_TEST_TIME, TIMER_MAX
            else
                return SHORT_TEST_TIME, TIMER_MAX
            end
        end,
        Button_address = PB.ovhd.flt_ctl_elac_2,
        Status_dataref = ELAC_2_status,
        Button_dataref = ELAC_2_off_button,
        Last_computer_status = 0,
        Last_button_status = 0,
        Last_power_status = 0,
        Transient_str_time = 0,
        Transient_end_time = 0,
        Transient_reset_required = true,
        Transient_reset_pending = false,
        IR_reset_required = true,
        IR_reset_pending = false,
        Failure_dataref = FAILURE_FCTL_ELAC_2,
        Power = function ()
            return get(HOT_bus_2_pwrd) == 1 or get(DC_bus_2_pwrd) == 1
        end
    },
}

FBW.FLT_computer.FAC = {
    [1] = {
        Start_timer = 0,
        Test_time = function ()
            local TEST_TIME = 1.5
            local TIMER_MAX = 10
            return TEST_TIME, TIMER_MAX
        end,
        Button_address = PB.ovhd.flt_ctl_fac_1,
        Status_dataref = FAC_1_status,
        Button_dataref = FAC_1_off_button,
        Last_computer_status = 0,
        Last_button_status = 0,
        Last_power_status = 0,
        Transient_str_time = 0,
        Transient_end_time = 0,
        Transient_reset_required = true,
        Transient_reset_pending = false,
        IR_reset_required = false,
        IR_reset_pending = false,
        Failure_dataref = FAILURE_FCTL_FAC_1,
        Power = function ()
            return get(DC_shed_ess_pwrd) == 1 and get(AC_ess_bus_pwrd) == 1
        end,
        MON_CHANEL_avail = function ()
            return get(DC_shed_ess_pwrd) == 1 and get(AC_ess_bus_pwrd) == 1 and get(FAILURE_FCTL_FAC_1) == 0
        end,
    },
    [2] = {
        Start_timer = 0,
        Test_time = function ()
            local TEST_TIME = 1.5
            local TIMER_MAX = 10
            return TEST_TIME, TIMER_MAX
        end,
        Button_address = PB.ovhd.flt_ctl_fac_2,
        Status_dataref = FAC_2_status,
        Button_dataref = FAC_2_off_button,
        Last_computer_status = 0,
        Last_button_status = 0,
        Last_power_status = 0,
        Transient_str_time = 0,
        Transient_end_time = 0,
        Transient_reset_required = false,
        Transient_reset_pending = false,
        IR_reset_required = false,
        IR_reset_pending = false,
        Failure_dataref = FAILURE_FCTL_FAC_2,
        Power = function ()
            return get(DC_bus_2_pwrd) == 1 and get(AC_bus_2_pwrd) == 1
        end,
        MON_CHANEL_avail = function ()
            return get(DC_bus_2_pwrd) == 1 and get(AC_bus_2_pwrd) == 1 and get(FAILURE_FCTL_FAC_2) == 0
        end,
    },
}

FBW.FLT_computer.SEC = {
    [1] = {
        Start_timer = 0,
        Test_time = function ()
            local TEST_TIME = 1.5
            local TIMER_MAX = 10
            return TEST_TIME, TIMER_MAX
        end,
        Button_address = PB.ovhd.flt_ctl_sec_1,
        Status_dataref = SEC_1_status,
        Button_dataref = SEC_1_off_button,
        Last_computer_status = 0,
        Last_button_status = 0,
        Last_power_status = 0,
        Transient_str_time = 0,
        Transient_end_time = 0,
        Transient_reset_required = false,
        Transient_reset_pending = false,
        IR_reset_required = false,
        IR_reset_pending = false,
        Failure_dataref = FAILURE_FCTL_SEC_1,
        Power = function ()
            return get(HOT_bus_1_pwrd) == 1 or get(DC_ess_bus_pwrd) == 1
        end
    },
    [2] = {
        Start_timer = 0,
        Test_time = function ()
            local TEST_TIME = 1.5
            local TIMER_MAX = 10
            return TEST_TIME, TIMER_MAX
        end,
        Button_address = PB.ovhd.flt_ctl_sec_2,
        Last_computer_status = 0,
        Status_dataref = SEC_2_status,
        Button_dataref = SEC_2_off_button,
        Last_button_status = 0,
        Last_power_status = 0,
        Transient_str_time = 0,
        Transient_end_time = 0,
        Transient_reset_required = false,
        Transient_reset_pending = false,
        IR_reset_required = false,
        IR_reset_pending = false,
        Failure_dataref = FAILURE_FCTL_SEC_2,
        Power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
    [3] = {
        Start_timer = 0,
        Test_time = function ()
            local TEST_TIME = 1.5
            local TIMER_MAX = 10
            return TEST_TIME, TIMER_MAX
        end,
        Button_address = PB.ovhd.flt_ctl_sec_3,
        Status_dataref = SEC_3_status,
        Button_dataref = SEC_3_off_button,
        Last_computer_status = 0,
        Last_button_status = 0,
        Last_power_status = 0,
        Transient_str_time = 0,
        Transient_end_time = 0,
        Transient_reset_required = false,
        Transient_reset_pending = false,
        IR_reset_required = false,
        IR_reset_pending = false,
        Failure_dataref = FAILURE_FCTL_SEC_3,
        Power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
}

FBW.FLT_computer.SFCC = {
    [1] = {
        Status_dataref = SFCC_1_status,
        Failure_dataref = FAILURE_FCTL_SFCC_1,
        Power = function ()
            return get(DC_ess_bus_pwrd) == 1
        end
    },
    [2] = {
        Status_dataref = SFCC_2_status,
        Failure_dataref = FAILURE_FCTL_SFCC_2,
        Power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
}

FBW.FLT_computer.FCDC = {
    [1] = {
        Status_dataref = FCDC_1_status,
        Failure_dataref = FAILURE_FCTL_FCDC_1,
        Power = function ()
            return get(DC_shed_ess_pwrd) == 1
        end
    },
    [2] = {
        Status_dataref = FCDC_2_status,
        Failure_dataref = FAILURE_FCTL_FCDC_2,
        Power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
}

FBW.FLT_computer.common = {
    main = {
        Startup = function (computer_table)
            for i = 1, #computer_table do
                --find power delta--
                local POWER_DELTA = BoolToNum(computer_table[i].Power()) - computer_table[i].Last_power_status
                local BUTTTON_DELTA = get(computer_table[i].Button_dataref) - computer_table[i].Last_button_status
                local COMPUTER_STATUS_DELTA = get(computer_table[i].Status_dataref) - computer_table[i].Last_computer_status
                computer_table[i].Last_power_status = BoolToNum(computer_table[i].Power())
                computer_table[i].Last_button_status = get(computer_table[i].Button_dataref)
                computer_table[i].Last_computer_status = get(computer_table[i].Status_dataref)

                --inital status--
                set(computer_table[i].Status_dataref, 0)

                --find required start time--
                local START_TIME, TIMER_MAX = computer_table[i].Test_time()

                --transient reset--
                local TRANSIENT_LENGTH = computer_table[i].Transient_end_time - computer_table[i].Transient_str_time
                if POWER_DELTA == 1 and computer_table[i].Transient_reset_required then
                    computer_table[i].Transient_end_time = get(TIME)
                end
                if POWER_DELTA == -1 and computer_table[i].Transient_reset_required then
                    computer_table[i].Transient_str_time = get(TIME)
                    if TRANSIENT_LENGTH >= 0.025 and get(Any_wheel_on_ground) == 0 then
                        computer_table[i].Transient_reset_pending = true
                    end
                end
                if BUTTTON_DELTA == -1 and computer_table[i].Transient_reset_pending then
                    computer_table[i].Transient_reset_pending = false
                end

                --IR not self detected ELAC reset--
                if computer_table[i].IR_reset_required then
                    if adirs_how_many_irs_fully_work() >= 2 and adirs_ir_disagree() then
                        computer_table[i].IR_reset_pending = true
                    end
                end
                if COMPUTER_STATUS_DELTA == - 1 then
                    computer_table[i].IR_reset_pending = false
                end

                --button set to on--
                if get(computer_table[i].Button_dataref) == 0 then
                    if computer_table[i].Start_timer < TIMER_MAX then
                        computer_table[i].Start_timer = computer_table[i].Start_timer + get(DELTA_TIME)
                    end
                end

                --turn off computer--
                if (get(computer_table[i].Button_dataref) == 1) or
                   (not computer_table[i].Power()) or
                   computer_table[i].Transient_reset_pending or
                   (get(computer_table[i].Failure_dataref) == 1) then
                    computer_table[i].Start_timer = 0
                end

                --set system status--
                if computer_table[i].Start_timer >= START_TIME then
                    set(computer_table[i].Status_dataref, 1)
                end

                if get(Print_print_main_fcc_status) == 1 then
                    print("COMPUTER " .. i .. ":")
                    print("RESTART TIME LEFT:       " .. tostring(START_TIME - computer_table[i].Start_timer))
                    print("POWERED:                 " .. tostring(computer_table[i].Power()))
                    print("TRANSIENT LENGTH:        " .. TRANSIENT_LENGTH)
                    print("PENDING TRANSIENT RESET: " .. tostring(computer_table[i].Transient_reset_pending))
                    print("PENDING IR RESET:        " .. tostring(computer_table[i].IR_reset_pending))
                end
            end
        end,

        Button_status = function (computer_table)
            for i = 1, #computer_table do
                local FAULT_status = get(computer_table[i].Status_dataref) ~= (1 - get(computer_table[i].Button_dataref)) or computer_table[i].IR_reset_pending
                local OFF_status = get(computer_table[i].Button_dataref) == 1
                pb_set(computer_table[i].Button_address, OFF_status, FAULT_status)
            end
        end
    },

    misc = {
        Startup = function (computer_table)
            for i = 1, #computer_table do
                --inital status--
                set(computer_table[i].Status_dataref, 1)

                --turn off computer--
                if (get(computer_table[i].Button_dataref) == 1) or
                   (not computer_table[i].Power()) or
                   (get(computer_table[i].Failure_dataref) == 1) then
                    set(computer_table[i].Status_dataref, 0)
                end
            end
        end,
    }
}

components = {
    FLT_computer_cmd {},
    AIL {},
    SPLR {},
    ELEV {},
    THS {},
    RUD {},
}

function update()
    updateAll(components)
    FBW.FLT_computer.common.main.Startup(FBW.FLT_computer.ELAC)
    FBW.FLT_computer.common.main.Button_status(FBW.FLT_computer.ELAC)
    FBW.FLT_computer.common.main.Startup(FBW.FLT_computer.FAC)
    FBW.FLT_computer.common.main.Button_status(FBW.FLT_computer.FAC)
    FBW.FLT_computer.common.main.Startup(FBW.FLT_computer.SEC)
    FBW.FLT_computer.common.main.Button_status(FBW.FLT_computer.SEC)

    FBW.FLT_computer.common.misc.Startup(FBW.FLT_computer.SFCC)
    FBW.FLT_computer.common.misc.Startup(FBW.FLT_computer.FCDC)
end