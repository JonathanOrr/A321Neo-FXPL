local Capt_green_light_timer = 0
local Fo_green_light_timer = 0

local last_priority_left = 0
local last_priority_right = 0

local priority_left_delta = 0
local priority_right_delta = 0

local function priority_indications()
    set(Sidesitck_dual_input, BoolToNum(get(Priority_left) + get(Priority_right) == 0 and get(CAPT_SSTICK_X) + get(CAPT_SSTICK_Y) ~= 0 and get(FO_SSTICK_X) + get(FO_SSTICK_Y) ~= 0))

    --update timers--
    if ((get(Fo_sidestick_disabled) == 1 or get(Priority_left) == 1) and get(FO_SSTICK_X) + get(FO_SSTICK_Y) ~= 0) or get(Sidesitck_dual_input) == 1 then
        Capt_green_light_timer = Math_cycle(Capt_green_light_timer + get(DELTA_TIME), 0, 1)
    else
        Capt_green_light_timer = 0
    end
    if ((get(Capt_sidestick_disabled) == 1 or get(Priority_right) == 1) and get(CAPT_SSTICK_X) + get(CAPT_SSTICK_Y) ~= 0) or get(Sidesitck_dual_input) == 1 then
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

function update()
    priority_indications()
    priority_warnings()
end