function FBW_input_handling()
    set(Total_sidestick_roll,  get(Roll))
    set(Total_sidestick_pitch, get(Pitch))

    set(Total_input_roll,  get(Total_sidestick_roll) + get(AUTOFLT_roll))
    set(Total_input_pitch, get(Total_sidestick_pitch) + get(AUTOFLT_pitch))
    set(Total_input_yaw,   get(Yaw) + get(AUTOFLT_yaw))
end