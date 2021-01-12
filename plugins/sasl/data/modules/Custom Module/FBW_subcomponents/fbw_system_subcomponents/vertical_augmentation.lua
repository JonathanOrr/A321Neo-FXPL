function FBW_vertical_agmentation()
    if get(FBW_vertical_rotation_mode_ratio) == 0 and get(FBW_vertical_flare_mode_ratio) == 0 then
        FBW_PID_arrays.SSS_FBW_rotation_pitch_rate.Integral = 0
    end

    --table interpolation--
    local pitch_rate_table = {
        {-1, 3.6},
        {0,  -get(FBW_flare_mode_computed_Q)},
        {1, 3.6},
    }

    local taget_Q_table = {
        {-5, -Table_interpolate(pitch_rate_table, get(Augmented_pitch))},
        {0,  0},
        {5,  Table_interpolate(pitch_rate_table, get(Augmented_pitch))},
    }

    local rotation_mode_output = 0
    local flare_mode_output = 0
    local flare_mode_max_pitch = get(Ground_spoilers_mode) == 2 and 7 or 18
    if get(FBW_vertical_rotation_mode_ratio) > 0 then
        rotation_mode_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_rotation_pitch_rate, get(Augmented_pitch) * 6, get(True_pitch_rate))
    end
    if get(FBW_vertical_flare_mode_ratio) > 0 then
        flare_mode_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_rotation_pitch_rate, Table_interpolate(taget_Q_table, Math_clamp_higher(Math_rescale(-1, -22, 1, 18, get(Augmented_pitch)), flare_mode_max_pitch) - get(Flightmodel_pitch)), get(True_pitch_rate))
    end

    if get(Aft_wheel_on_ground) == 1 and get(FBW_vertical_rotation_mode_ratio) > 0 then
        FBW_PID_arrays.SSS_FBW_rotation_pitch_rate.Integral = Math_clamp_lower(FBW_PID_arrays.SSS_FBW_rotation_pitch_rate.Integral, -0.15)
    end


    set(
        Pitch_artstab,
        get(Augmented_pitch) * get(FBW_vertical_ground_mode_ratio)
        + rotation_mode_output * get(FBW_vertical_rotation_mode_ratio)
        + get(FBW_augmented_Pitch) * get(FBW_vertical_flight_mode_ratio)
        + flare_mode_output * get(FBW_vertical_flare_mode_ratio)
    )
end