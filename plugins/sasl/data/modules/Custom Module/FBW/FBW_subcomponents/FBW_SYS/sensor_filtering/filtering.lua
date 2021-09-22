FBW.filtered_sensors = {
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
    TAS = {
        high_pass = false,
        filtered = 0,
        value = function ()
            return adirs_get_avg_tas()
        end,
        {
            x = 0,
            cut_frequency = 2,
        }
    },

    HP_NX = {
        high_pass = true,
        filtered = 0,
        value = function ()
            return get(Total_lateral_g_load)
        end,
        {
            x = 0,
            cut_frequency = 1.4,
        }
    },

    GS_TAS_DELTA = {
        high_pass = true,
        filtered = 0,
        value = function ()
            return (get(TAS_ms) * 1.94384 - get(Ground_speed_kts))
        end,
        {
            x = 0,
            cut_frequency = 10,
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