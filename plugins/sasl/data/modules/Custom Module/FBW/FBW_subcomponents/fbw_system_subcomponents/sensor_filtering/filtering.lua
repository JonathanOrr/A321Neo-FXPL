FBW.filtered_sensors = {
    Q = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return FBW.rates.Yaw.x
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
            return FBW.rates.Yaw.x
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
            return FBW.rates.Yaw.x
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
            return FBW.rates.Yaw.x
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