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
}