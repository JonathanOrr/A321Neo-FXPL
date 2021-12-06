local function SUM_INPUT()

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

function update()
    SUM_INPUT()
end