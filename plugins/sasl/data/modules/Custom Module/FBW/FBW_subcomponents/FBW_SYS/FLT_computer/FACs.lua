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