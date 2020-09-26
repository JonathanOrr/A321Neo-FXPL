position= {2073, 1434,500,500}
size = {500, 500}

local TIME_TO_ALIGN_SEC = 90


-- Toggle LS
sasl.registerCommandHandler (ISIS_cmd_LS, 0, function(phase) set(ISIS_landing_system_enabled, get(ISIS_landing_system_enabled) == 1 and 0 or 1) end )

local isis_start_time = 0

function draw()

end

function update()

    if (get(IAS) > 50 and get(HOT_bus_1_pwrd) == 1) or get(DC_ess_bus_pwrd) == 1 then
        set(ISIS_powered, 1)
    else
        set(ISIS_powered, 0)
        set(ISIS_ready, 0)
        isis_start_time = 0
        return
    end
    
    if isis_start_time == 0 then
        isis_start_time = get(TIME)
    end

    if get(TIME) - isis_start_time > TIME_TO_ALIGN_SEC then
        set(ISIS_ready, 1)
    else
        set(ISIS_ready, 0)
    end

end
