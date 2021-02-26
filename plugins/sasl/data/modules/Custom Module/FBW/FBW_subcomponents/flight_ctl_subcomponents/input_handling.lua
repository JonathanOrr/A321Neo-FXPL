local Capt_priority_timer = 0
local Fo_priority_timer = 0

local Capt_enable_timer = 0
local Fo_enable_timer = 0

local Capt_green_light_timer = 0
local Fo_green_light_timer = 0

local last_priority_left = 0
local last_priority_right = 0

local priority_left_delta = 0
local priority_right_delta = 0

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
        if get(Capt_sidestick_disabled) == 0 and Capt_priority_timer < 2 then
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
        if Fo_priority_timer < 40 then
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

local function priority_indications()
    set(Sidesitck_dual_input, BoolToNum(get(Priority_left) + get(Priority_right) == 0 and get(Capt_sidestick_roll) + get(Capt_sidestick_pitch) ~= 0 and get(Fo_sidestick_roll) + get(Fo_sidestick_pitch) ~= 0))

    --update timers--
    if ((get(Fo_sidestick_disabled) == 1 or get(Priority_left) == 1) and get(Fo_sidestick_roll) + get(Fo_sidestick_pitch) ~= 0) or get(Sidesitck_dual_input) == 1 then
        Capt_green_light_timer = Math_cycle(Capt_green_light_timer + get(DELTA_TIME), 0, 1)
    else
        Capt_green_light_timer = 0
    end
    if ((get(Capt_sidestick_disabled) == 1 or get(Priority_right) == 1) and get(Capt_sidestick_roll) + get(Capt_sidestick_pitch) ~= 0) or get(Sidesitck_dual_input) == 1 then
        Fo_green_light_timer = Math_cycle(Fo_green_light_timer + get(DELTA_TIME), 0, 1)
    else
        Fo_green_light_timer = 0
    end

    pb_set(PB.glare.priority_capt, Round(Capt_green_light_timer) == 1, get(Capt_sidestick_disabled) == 1 or get(Priority_right) == 1)
    pb_set(PB.glare.priority_fo,   Round(Fo_green_light_timer) == 1,   get(Fo_sidestick_disabled) == 1 or get(Priority_left) == 1)
end

local function priority_warnings()
    set(GPWS_mode_dual_input,     get(Sidesitck_dual_input))
    set(GPWS_mode_priority_left,  0)
    set(GPWS_mode_priority_right, 0)

    priority_left_delta =  get(Priority_left) - last_priority_left
    priority_right_delta = get(Priority_right) - last_priority_right
    last_priority_left =  get(Priority_left)
    last_priority_right = get(Priority_right)

    if priority_left_delta == 1 then
        set(GPWS_mode_priority_left, 1)
    end
    if priority_right_delta == 1 then
        set(GPWS_mode_priority_right, 1)
    end
end

function FBW_input_handling()
    priority_indications()
    priority_warnings()

    --raw input handling--
    set(Capt_sidestick_roll,  get(Capt_Roll)  * (1 - get(Capt_sidestick_disabled)))
    set(Capt_sidestick_pitch, get(Capt_Pitch) * (1 - get(Capt_sidestick_disabled)))

    set(Fo_sidestick_roll,  get(Fo_Roll)  * (1 - get(Fo_sidestick_disabled)))
    set(Fo_sidestick_pitch, get(Fo_Pitch) * (1 - get(Fo_sidestick_disabled)))

    if get(Priority_left) == 0 and get(Priority_right) == 0 then
        set(Total_sidestick_roll,  get(Capt_sidestick_roll)  + get(Fo_sidestick_roll))
        set(Total_sidestick_pitch, get(Capt_sidestick_pitch) + get(Fo_sidestick_pitch))
    else
        set(Total_sidestick_roll,  get(Capt_sidestick_roll)  * get(Priority_left) + get(Fo_sidestick_roll)  * get(Priority_right))
        set(Total_sidestick_pitch, get(Capt_sidestick_pitch) * get(Priority_left) + get(Fo_sidestick_pitch) * get(Priority_right))
    end

    --clamping sidestick sum--
    set(Total_sidestick_roll,  Math_clamp(get(Total_sidestick_roll), -1, 1))
    set(Total_sidestick_pitch, Math_clamp(get(Total_sidestick_pitch), -1, 1))

    set(Total_input_roll,  get(Total_sidestick_roll) + get(AUTOFLT_roll))
    set(Total_input_pitch, get(Total_sidestick_pitch) + get(AUTOFLT_pitch))
    set(Total_input_yaw,   get(Yaw) + get(AUTOFLT_yaw))

    --clamping total input sum--
    set(Total_input_roll,  Math_clamp(get(Total_input_roll), -1, 1))
    set(Total_input_pitch, Math_clamp(get(Total_input_pitch), -1, 1))
    set(Total_input_yaw,   Math_clamp(get(Total_input_yaw), -1, 1))
end