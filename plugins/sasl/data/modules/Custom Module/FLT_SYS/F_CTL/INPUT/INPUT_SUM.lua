local function SUM_INPUT()

    --raw input handling--
    set(CAPT_SSTICK_X, get(XP_CAPT_X) * (1 - get(Capt_sidestick_disabled)))
    set(CAPT_SSTICK_Y, get(XP_CAPT_Y) * (1 - get(Capt_sidestick_disabled)))

    set(FO_SSTICK_X, get(XP_FO_X) * (1 - get(Fo_sidestick_disabled)))
    set(FO_SSTICK_Y, get(XP_FO_Y) * (1 - get(Fo_sidestick_disabled)))

    if get(Priority_left) == 0 and get(Priority_right) == 0 then
        set(TOT_SSTICK_X, get(CAPT_SSTICK_X) + get(FO_SSTICK_X))
        set(TOT_SSTICK_Y, get(CAPT_SSTICK_Y) + get(FO_SSTICK_Y))
    else
        set(TOT_SSTICK_X, get(CAPT_SSTICK_X) * get(Priority_left) + get(FO_SSTICK_X) * get(Priority_right))
        set(TOT_SSTICK_Y, get(CAPT_SSTICK_Y) * get(Priority_left) + get(FO_SSTICK_Y) * get(Priority_right))
    end

    --clamping sidestick sum--
    set(TOT_SSTICK_X, Math_clamp(get(TOT_SSTICK_X), -1, 1))
    set(TOT_SSTICK_Y, Math_clamp(get(TOT_SSTICK_Y), -1, 1))

    set(Total_input_roll,  get(TOT_SSTICK_X))
    set(Total_input_pitch, get(TOT_SSTICK_Y))

    --clamping total input sum--
    set(Total_input_roll,  Math_clamp(get(Total_input_roll), -1, 1))
    set(Total_input_pitch, Math_clamp(get(Total_input_pitch), -1, 1))
end

function update()
    SUM_INPUT()
end