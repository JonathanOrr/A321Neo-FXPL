FBW.rates ={
    Roll = {
        x = 0,
        dataref = Flightmodel_roll
    },
    Pitch = {
        x = 0,
        dataref = Flightmodel_pitch
    },
    Yaw = {
        x = 0,
        dataref = Flightmodel_true_heading
    },
    Vpath_q = {
        x = 0,
        dataref = Vpath
    }
}

local function update_rates(table)
    for key, value in pairs(table) do
        --init tables--
        if table[key].previous_value == nil then
            table[key].previous_value = get(table[key].dataref)
        end

        --check if paused--
        if get(DELTA_TIME) ~= 0 then
            --compute rates--
            table[key].x = (get(table[key].dataref) - table[key].previous_value) / get(DELTA_TIME)
        end

        --record value--
        table[key].previous_value = get(table[key].dataref)
    end
end

function update()
    update_rates(FBW.rates)
end