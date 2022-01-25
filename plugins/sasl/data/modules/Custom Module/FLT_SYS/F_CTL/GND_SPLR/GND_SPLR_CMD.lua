local LVR_POS = {
    0,
    0.25,
    0.5,
    0.75,
    1
}

local function More_speedbrakes(phase)
    local LVR_POS_KEY = Round(get(SPDBRK_HANDLE_RATIO) * 4) + 1

    if phase == SASL_COMMAND_BEGIN then
        if get(SPDBRK_HANDLE_RATIO) < 0 then
            set(SPDBRK_HANDLE_RATIO, 0)
        else
            set(SPDBRK_HANDLE_RATIO, LVR_POS[Math_clamp_higher(LVR_POS_KEY + 1, 5)])
        end
    end

    return 0--inhibites the x-plane original command
end

local function Less_speedbrakes(phase)
    local LVR_POS_KEY = Round(get(SPDBRK_HANDLE_RATIO) * 4) + 1

    if phase == SASL_COMMAND_BEGIN then
        if get(SPDBRK_HANDLE_RATIO) <= 0 then
            set(SPDBRK_HANDLE_RATIO, -0.5)
        elseif get(SPDBRK_HANDLE_RATIO) > 0 then
            set(SPDBRK_HANDLE_RATIO, LVR_POS[Math_clamp_lower(LVR_POS_KEY - 1, 1)])
        end
    end

    return 0--inhibites the x-plane original command
end

local function Max_speedbrakes(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(SPDBRK_HANDLE_RATIO, 1)
    end

    return 0--inhibites the x-plane original command
end

local function Min_speedbrakes(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(SPDBRK_HANDLE_RATIO, 0)
    end

    return 0--inhibites the x-plane original command
end

--modify xplane functions
sasl.registerCommandHandler(XP_min_speedbrakes,  1, Min_speedbrakes)
sasl.registerCommandHandler(XP_max_speedbrakes,  1, Max_speedbrakes)
sasl.registerCommandHandler(XP_less_speedbrakes, 1, Less_speedbrakes)
sasl.registerCommandHandler(XP_more_speedbrakes, 1, More_speedbrakes)