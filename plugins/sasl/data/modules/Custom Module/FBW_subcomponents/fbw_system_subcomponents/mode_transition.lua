FBW_modes_var_table = {
    Previous_trim_reset_begin = 0,
    On_ground_timer = 0,
    Flare_mode_past_status = 0
}

function FBW_mode_transition(table)
    --FBW mode transfers to flight mode if (all wheels are off ground and att > 8) or RA > 50ft
    --FBW mode transfers to flare mode if (FBW is in flight mode and RA < 50ft) and at 50ft RA the ATT is memorised, at 30ft RA pitch demand mode kicks in
    --FBW mode transfers back to flight mode if (FBW is in flare mode and RA > 50ft)
    --FBW mode transfers to ground mode if (all wheels are on ground for 5+ seconds and att < 2.5 degrees)
    --ONLY 2 MODES CAN HAPPEN SIMUTANIOUSLY [GROUND + FLIGHT] / [FLIGHT + FLARE] / [FLARE + GROUND] ALL OTHER COMBINATIONS ARE IMPOSSIBLE

    --properties
    local lateral_ground_mode_transition_time = 0.5
    local vertical_ground_mode_transition_time = 5

    local vertical_flare_mode_transition_time = 1

    --timers--
    if get(All_on_ground) == 1 and table.On_ground_timer < 5 then
        table.On_ground_timer = table.On_ground_timer + 1 * get(DELTA_TIME)
    elseif get(Any_wheel_on_ground) == 0 then
        table.On_ground_timer = 0
    end

    --memorise ATT--
    if BoolToNum(get(FBW_vertical_flare_mode_ratio) > 0) - table.Flare_mode_past_status == 1 then
        set(FBW_flare_mode_memorised_att, get(Flightmodel_pitch))
        set(FBW_flare_mode_computed_Q, (-2 - get(FBW_flare_mode_memorised_att)) / 8)
    elseif BoolToNum(get(FBW_vertical_flare_mode_ratio) > 0) - table.Flare_mode_past_status == -1 then
        set(FBW_flare_mode_memorised_att, 0)
        set(FBW_flare_mode_computed_Q, 0)
    end
    table.Flare_mode_past_status = BoolToNum(get(FBW_vertical_flare_mode_ratio) > 0)

    --ground mode --> flight mode
    if (get(Any_wheel_on_ground) == 0 and get(Flightmodel_pitch) > 8) or (get(Capt_ra_alt_ft) > 50 or get(Fo_ra_alt_ft) > 50) then
        set(FBW_lateral_ground_mode_ratio,  Set_linear_anim_value(get(FBW_lateral_ground_mode_ratio),  0, 0, 1, 1 / lateral_ground_mode_transition_time))
        set(FBW_vertical_ground_mode_ratio, Set_linear_anim_value(get(FBW_vertical_ground_mode_ratio), 0, 0, 1, 1 / vertical_ground_mode_transition_time))
    end

    --flight mode --> flare mode
    if (get(Capt_ra_alt_ft) < 50 or get(Fo_ra_alt_ft) < 50) and (get(PFD_Capt_VS) <= 0 or get(PFD_Fo_VS) <= 0) then
        set(FBW_vertical_flare_mode_ratio, Set_linear_anim_value(get(FBW_vertical_flare_mode_ratio), 1, 0, 1, 1 / vertical_flare_mode_transition_time))
    end

    --flare mode --> flight mode
    if get(FBW_vertical_flare_mode_ratio) ~= 0 and (get(Capt_ra_alt_ft) > 50 or get(Fo_ra_alt_ft) > 50) then
        set(FBW_vertical_flare_mode_ratio, Set_linear_anim_value(get(FBW_vertical_flare_mode_ratio), 0, 0, 1, 1 / vertical_flare_mode_transition_time))
    end

    --flare mode --> ground mode
    if get(All_on_ground) == 1 and table.On_ground_timer >= 5 and get(Flightmodel_pitch) < 2.5 then
        set(FBW_lateral_ground_mode_ratio,  Set_linear_anim_value(get(FBW_lateral_ground_mode_ratio),  1, 0, 1, 1 / lateral_ground_mode_transition_time))
        set(FBW_vertical_ground_mode_ratio, Set_linear_anim_value(get(FBW_vertical_ground_mode_ratio), 1, 0, 1, 1 / vertical_ground_mode_transition_time))
        set(FBW_vertical_flare_mode_ratio,  1 - get(FBW_vertical_ground_mode_ratio))
    end

    --trim reset--
    local trim_reset_begin = get(FBW_lateral_ground_mode_ratio) > 0 and 1 or 0
    local trim_reset_begin_delta = trim_reset_begin - table.Previous_trim_reset_begin
    table.Previous_trim_reset_begin = trim_reset_begin
    if trim_reset_begin_delta == 1 then
        set(Augmented_pitch_trim_ratio, 0)
    end

    --mode detection--
    set(FBW_in_ground_mode,BoolToNum(get(FBW_lateral_ground_mode_ratio) == 1 and get(FBW_vertical_ground_mode_ratio) == 1))
    set(FBW_in_flare_mode, BoolToNum(get(FBW_vertical_flare_mode_ratio) == 1))
    set(FBW_in_flight_mode, BoolToNum(get(FBW_lateral_ground_mode_ratio) == 0 and get(FBW_vertical_ground_mode_ratio) == 0 and get(FBW_vertical_flare_mode_ratio) == 0))
end