--example_array = {P_gain, I_time, D_gain, Proportional, Integral_sum, Integral, Derivative, Current_error, Min_error, Max_error}
AT_PID_arrays = {
    -- L=4.3, T=4.8
    SSS_L_N1 = {
        P_gain = 0.0026,
        I_gain = 0.0083,
        D_gain = 0.0000,
        B_gain = 1,
        Actual_output = 0,
        Desired_output = 0,
        Integral_sum = 0,
        Current_error = 0,
        Min_out = 0.05,
        Max_out = 1
    },
    SSS_R_N1 = {
        P_gain = 0.0026,
        I_gain = 0.0083,
        D_gain = 0.0000,
        B_gain = 1,
        Actual_output = 0,
        Desired_output = 0,
        Integral_sum = 0,
        Current_error = 0,
        Min_out = 0.05,
        Max_out = 1.0
    },
}

FBW_PID_arrays = {
    FBW_ROLL_RATE_PID = {
        P_gain = 0.032,
        I_gain = 0.055,
        D_gain = 0.0001,
        B_gain = 1,
        Schedule_gains = true,
        Schedule_table = {
            P = {
                {110, 0.064},
                {130, 0.044},
                {160, 0.040},
                {180, 0.032},
                {220, 0.029},
                {280, 0.025},
                {345, 0.020},
            },
            I = {
                {110, 0.088},
                {130, 0.088},
                {160, 0.065},
                {180, 0.055},
                {220, 0.050},
                {280, 0.050},
                {345, 0.050},
            },
            D = {
                {110, 0.0001},
                {130, 0.0001},
                {160, 0.0001},
                {180, 0.0001},
                {220, 0.0001},
                {280, 0.0001},
                {345, 0.0001},
            },
        },
        Limited_integral = false,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        error_freq = 10,
        dpvdt_freq = 10,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },

    FBW_ROTATION_APROT_PID = {
        P_gain = 1.100,
        I_gain = 0.450,
        D_gain = 0.000,
        B_gain = 1,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {000, 0.000},
            },
            I = {
                {000, 0.000},
            },
            D = {
                {000, 0.000},
            },
        },
        Limited_integral = true,
        Min_out = -4,
        Max_out = 4,
        filter_inputs = true,
        error_freq = 0.25,
        dpvdt_freq = 0.25,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },
    FBW_FLIGHT_APROT_PID = {
        P_gain = 1.000,
        I_gain = 0.450,
        D_gain = 0.000,
        B_gain = 1,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {000, 0.000},
            },
            I = {
                {000, 0.000},
            },
            D = {
                {000, 0.000},
            },
        },
        Limited_integral = true,
        Min_out = -4,
        Max_out = 4,
        filter_inputs = true,
        error_freq = 0.25,
        dpvdt_freq = 0.25,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },
    FBW_FLARE_APROT_PID = {
        P_gain = 1.100,
        I_gain = 0.450,
        D_gain = 0.000,
        B_gain = 1,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {000, 0.000},
            },
            I = {
                {000, 0.000},
            },
            D = {
                {000, 0.000},
            },
        },
        Limited_integral = true,
        Min_out = -4,
        Max_out = 4,
        filter_inputs = true,
        error_freq = 0.25,
        dpvdt_freq = 0.25,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },

    FBW_PITCH_RATE_PID = {
        P_gain = 0.055,
        I_gain = 0.150,
        D_gain = 0.000,
        B_gain = 3,
        Schedule_gains = true,
        Schedule_table = {
            P = {
                {150, 0.072},
                {180, 0.058},
                {250, 0.055},
                {350, 0.050},
                {410, 0.042},
                {500, 0.042},
            },
            I = {
                {150, 0.165},
                {180, 0.150},
                {250, 0.148},
                {350, 0.130},
                {410, 0.118},
                {500, 0.118},
            },
            D = {
                {160, 0.000},
                {180, 0.000},
                {250, 0.000},
                {350, 0.000},
                {410, 0.000},
                {500, 0.000},
            },
        },
        Limited_integral = true,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        error_freq = 6,
        dpvdt_freq = 6,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },

    FBW_CSTAR_PID = {
        P_gain  = 0.154,
        I_gain  = 0.182,
        D_gain  = 0.090,
        B_gain  = 1.000,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {000, 0.000},
            },
            I = {
                {000, 0.000},
            },
            D = {
                {000, 0.000},
            },
        },
        Limited_integral = true,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        error_freq = 0.35,
        dpvdt_freq = 0.35,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        feedfwd = 0,
        Desired_output = 0,
        Actual_output = 0,
    },
    CSTAR_STABILITY_FF = {
        FF_gain          = 0.000,
        derive_feedfwd   = false,
        filter_feedfwd   = true,
        feedfwd_freq     = 0.35,
        highpass_feedfwd = false,
        feedfwd_pv       = 0,
        feedfwd          = 0,
    },
    CSTAR_THS_FF = {
        FF_gain          = 0.000,
        derive_feedfwd   = true,
        filter_feedfwd   = true,
        feedfwd_freq     = 0.35,
        highpass_feedfwd = false,
        feedfwd_pv       = 0,
        feedfwd          = 0,
    },
    CSTAR_FLAPS_FF = {
        FF_gain          = 0.000,
        derive_feedfwd   = true,
        filter_feedfwd   = true,
        feedfwd_freq     = 0.35,
        highpass_feedfwd = false,
        feedfwd_pv       = 0,
        feedfwd          = 0,
    },

    FBW_YAW_DAMPER_PID = {
        P_gain = 0.040,
        I_gain = 0.000,
        D_gain = 0.000,
        B_gain = 0,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {0.00, 0.000},
            },
            I = {
                {0.00, 0.000},
            },
            D = {
                {0.00, 0.000},
            },
        },
        Limited_integral = false,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        error_freq = 2,
        dpvdt_freq = 2,
        highpass_inputs = true,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },
    FBW_NRM_YAW_PID = {
        P_gain = 0.038,
        I_gain = 0.046,
        D_gain = 0.016,
        B_gain = 1,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {0.00, 0.012},
            },
            I = {
                {0.00, 0.020},
            },
            D = {
                {0.00, 0.0100},
            },
        },
        Limited_integral = true,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        error_freq = 0.12,
        dpvdt_freq = 0.12,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },

    FBW_AUTOTRIM_PID = {
        P_gain = 0.100,
        I_gain = 0.050,
        D_gain = 0.000,
        B_gain = 1,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {000, 0.000},
            },
            I = {
                {000, 0.000},
            },
            D = {
                {000, 0.000},
            },
        },
        Limited_integral = true,
        Min_out = -4,
        Max_out = 13.5,
        filter_inputs = true,
        error_freq = 0.2,
        dpvdt_freq = 0.2,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        feedfwd = 0,
        Desired_output = 0,
        Actual_output = 0,
    },

    FBW_MLA_PID = {
        P_gain = -6.25,
        I_gain = 0.000,
        D_gain = 0.000,
        B_gain = 0,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {0.00, 0.000},
            },
            I = {
                {0.00, 0.000},
            },
            D = {
                {0.00, 0.000},
            },
        },
        Limited_integral = false,
        Min_out = -5,
        Max_out = 5,
        filter_inputs = true,
        error_freq = 0.25,
        dpvdt_freq = 0.25,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },
    FBW_GLA_PID = {
        P_gain = -8.50,
        I_gain = 0.000,
        D_gain = 0.000,
        B_gain = 0,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {0.00, 0.000},
            },
            I = {
                {0.00, 0.000},
            },
            D = {
                {0.00, 0.000},
            },
        },
        Limited_integral = false,
        Min_out = -5,
        Max_out = 5,
        filter_inputs = true,
        error_freq = 2,
        dpvdt_freq = 2,
        highpass_inputs = false,
        PV = 0,
        Error = 0,
        Proportional = 0,
        Integral = 0,
        Derivative = 0,
        Backpropagation = 0,
        Desired_output = 0,
        Actual_output = 0,
    },
}

