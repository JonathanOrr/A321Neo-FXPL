FBW.filtered_sensors = {
    P = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(True_roll_rate)
        end,
        {
            x = 0,
            cut_frequency = 10,
        },
    },
    --[[P_error = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(Total_input_roll) * 15 - get(True_roll_rate)
        end,
        {
            x = 0,
            cut_frequency = 10,
        },
    },]]

    Q = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(True_yaw_rate)
        end,
        {
            x = 0,
            cut_frequency = 6,
        },

    },
    --[[Q_err = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(True_yaw_rate)
        end,
        {
            x = 0,
            cut_frequency = 6,
        },
    },

    C_STAR = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(True_yaw_rate)
        end,
        {
            x = 0,
            cut_frequency = 16,
        },
    },
    C_STAR_err = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(True_yaw_rate)
        end,
        {
            x = 0,
            cut_frequency = 16,
        },
    },]]

    AoA = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return adirs_get_avg_aoa()
        end,
        {
            x = 0,
            cut_frequency = 0.25,
        },
    },
    pitch_artstab = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(FBW_pitch_output)
        end,
        {
            x = 0,
            cut_frequency = 1,
        },
    },

    R = {
        high_pass = true,
        filtered = 0,
        value = function ()
            return get(True_yaw_rate)
        end,
        {
            x = 0,
            cut_frequency = 200,
        },
    },
    R_err = {
        high_pass = true,
        filtered = 0,
        value = function ()
            return -get(True_yaw_rate)
        end,
        {
            x = 0,
            cut_frequency = 200,
        },
    },

    sideslip = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return -get(Slide_slip_angle)
        end,
        {
            x = 0,
            cut_frequency = 1.5,
        },
    },
    --[[sideslip_err = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return get(Slide_slip_angle)
        end,
        {
            x = 0,
            cut_frequency = 1.5,
        },
    },]]

    IAS = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return adirs_get_avg_ias()
        end,
        {
            x = 0,
            cut_frequency = 2,
        }
    },
}

local function filter_all_values(filter_table)
    for key, table in pairs(filter_table) do
        if get(DELTA_TIME) == 0 then return end

        table[1].x = table.value()
        if table.high_pass == false then
            table.filtered = low_pass_filter(table[1])
        else
            table.filtered = high_pass_filter(table[1])
        end
    end
end

function update()
    filter_all_values(FBW.filtered_sensors)
end