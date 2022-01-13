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