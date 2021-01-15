function FBW_lateral_agmentation()
    if get(FBW_lateral_flight_mode_ratio) == 0 then
        FBW_PID_arrays.SSS_FBW_roll_rate.Integral = 0
    end

    if get(FBW_kill_switch) == 0 then
        set(
            Roll_artstab,
            get(Augmented_roll) * get(FBW_lateral_ground_mode_ratio)
            + get(FBW_augmented_Roll) * get(FBW_lateral_flight_mode_ratio)
        )
    end
end