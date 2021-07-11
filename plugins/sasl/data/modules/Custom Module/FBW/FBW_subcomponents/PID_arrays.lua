--example_array = {P_gain, I_time, D_gain, Proportional, Integral_sum, Integral, Derivative, Current_error, Min_error, Max_error}
AT_PID_arrays = {
    SSS_L_N1 = {
        P_gain = 0.001,
        I_gain = 0.00425,
        D_gain = 0.0001,
        B_gain = 1,
        Actual_output = 0,
        Desired_output = 0,
        Integral_sum = 0,
        Current_error = 0,
        Min_out = 0.095,
        Max_out = 1.2
    },
    SSS_R_N1 = {
        P_gain = 0.001,
        I_gain = 0.00425,
        D_gain = 0.0001,
        B_gain = 1,
        Actual_output = 0,
        Desired_output = 0,
        Integral_sum = 0,
        Current_error = 0,
        Min_out = 0.095,
        Max_out = 1.2
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
        min_integral = -1,
        max_integral = 1,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        filter_freq = 10,
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
        min_integral = -4,
        max_integral = 4,
        Min_out = -4,
        Max_out = 4,
        filter_inputs = true,
        filter_freq = 0.25,
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
        min_integral = -4,
        max_integral = 4,
        Min_out = -4,
        Max_out = 4,
        filter_inputs = true,
        filter_freq = 0.25,
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
        min_integral = -4,
        max_integral = 4,
        Min_out = -4,
        Max_out = 4,
        filter_inputs = true,
        filter_freq = 0.25,
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
        min_integral = -1,
        max_integral = 1,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        filter_freq = 6,
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
        P_gain = 0.081,
        I_gain = 0.134,
        D_gain = 0.037,
        B_gain = 1,
        Schedule_gains = true,
        Schedule_table = {
            P = {
                {130, 0.098},
                {140, 0.096},
                {160, 0.094},
                {180, 0.092},
                {200, 0.088},
                {250, 0.081},
                {280, 0.078},
                {300, 0.074},
                {340, 0.072},
                {380, 0.070},
                {380, 0.069},
            },
            I = {
                {130, 0.155},
                {140, 0.149},
                {160, 0.145},
                {180, 0.142},
                {200, 0.137},
                {250, 0.134},
                {280, 0.123},
                {300, 0.120},
                {340, 0.118},
                {380, 0.117},
                {440, 0.115},
            },
            D = {
                {130, 0.064},
                {140, 0.058},
                {160, 0.054},
                {180, 0.052},
                {200, 0.047},
                {250, 0.037},
                {280, 0.035},
                {300, 0.032},
                {340, 0.029},
                {380, 0.028},
                {440, 0.027},
            },
        },
        Limited_integral = true,
        min_integral = -1,
        max_integral = 1,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        filter_freq = 0.75,
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

    FBW_YAW_DAMPER_PID = {
        P_gain = 1.200,
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
        min_integral = -1,
        max_integral = 1,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        filter_freq = 100,
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
        P_gain = 0.007,
        I_gain = 0.011,
        D_gain = 0.002,
        B_gain = 1,
        Schedule_gains = false,
        Schedule_table = {
            P = {
                {0.00, 0.012},
                {0.03, 0.010},
                {0.10, 0.008},
                {0.20, 0.006},
                {0.60, 0.003},
                {1.00, 0.002},
            },
            I = {
                {0.00, 0.020},
                {0.03, 0.015},
                {0.10, 0.014},
                {0.20, 0.012},
                {0.60, 0.010},
                {1.00, 0.008},
            },
            D = {
                {0.00, 0.0100},
                {0.03, 0.0025},
                {0.10, 0.0020},
                {0.20, 0.0012},
                {0.60, 0.0004},
                {1.00, 0.0002},
            },
        },
        Limited_integral = true,
        min_integral = -1,
        max_integral = 1,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        filter_freq = 0.35,
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
        P_gain = 0.250,
        I_gain = 0.160,
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
        min_integral = -1,
        max_integral = 1,
        Min_out = -1,
        Max_out = 1,
        filter_inputs = true,
        filter_freq = 0.2,
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

