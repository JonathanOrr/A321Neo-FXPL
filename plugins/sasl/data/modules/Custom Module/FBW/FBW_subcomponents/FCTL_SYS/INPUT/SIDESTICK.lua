local Capt_priority_timer = 0
local Fo_priority_timer = 0

local Capt_enable_timer = 0
local Fo_enable_timer = 0

local function Capt_sidestick_bp_callback(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Last_one_to_takover, CAPT_SIDESTICK)
    end

    if phase == SASL_COMMAND_CONTINUE then
        --re-enable sidestick--
        if get(Capt_sidestick_disabled) == 1 and Capt_enable_timer < 2 then
            Capt_enable_timer = Capt_enable_timer + get(DELTA_TIME)
        end

        if Capt_enable_timer >= 2 then
            set(Capt_sidestick_disabled, 0)
            Capt_enable_timer = 0
        end

        --takeover the priority--
        if get(Capt_sidestick_disabled) == 0 and Capt_priority_timer < 40 then
            Capt_priority_timer = Capt_priority_timer + get(DELTA_TIME)
        end

        if get(Last_one_to_takover) == CAPT_SIDESTICK and Capt_priority_timer >= 2 then
            set(Priority_left, 1)
            set(Priority_right, 0)
        end

        --disable opposite sidestick--
        if get(Last_one_to_takover) == CAPT_SIDESTICK and Capt_priority_timer >= 40 then
            set(Fo_sidestick_disabled, 1)
        end
    end

    if phase == SASL_COMMAND_END then
        Capt_enable_timer = 0
        Capt_priority_timer = 0
        set(Priority_left, 0)
    end

    return 0--inhibites the x-plane original command
end
local function Fo_sidestick_bp_callback(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Last_one_to_takover, FO_SIDESTICK)
    end

    if phase == SASL_COMMAND_CONTINUE then
        --re-enable sidestick--
        if get(Fo_sidestick_disabled) == 1 and Fo_enable_timer < 2 then
            Fo_enable_timer = Fo_enable_timer + get(DELTA_TIME)
        end

        if Fo_enable_timer >= 2 then
            set(Fo_sidestick_disabled, 0)
            Fo_enable_timer = 0
        end

        --takeover the priority--
        if get(Fo_sidestick_disabled) == 0 and Fo_priority_timer < 40 then
            Fo_priority_timer = Fo_priority_timer + get(DELTA_TIME)
        end

        if get(Last_one_to_takover) == FO_SIDESTICK and Fo_priority_timer >= 2 then
            set(Priority_left, 0)
            set(Priority_right, 1)
        end

        --disable opposite sidestick--
        if get(Last_one_to_takover) == FO_SIDESTICK and Fo_priority_timer >= 40 then
            set(Capt_sidestick_disabled, 1)
        end
    end

    if phase == SASL_COMMAND_END then
        Fo_enable_timer = 0
        Fo_priority_timer = 0
        set(Priority_right, 0)
    end
end

--register commands
sasl.registerCommandHandler(XP_Capt_sidestick_pb, 1, Capt_sidestick_bp_callback)
sasl.registerCommandHandler(Capt_sidestick_pb,    1, Capt_sidestick_bp_callback)
sasl.registerCommandHandler(Fo_sidestick_pb,      1, Fo_sidestick_bp_callback)