FBW_modes_var_table = {
    Previous_trim_reset_begin = 0,
    In_rotation_mode_duration = 0,
    On_ground_timer = 0,
    Flare_mode_past_status = 0
}

function FBW_mode_transition(table)
    --FBW mode transfers to rotation mode(NEO only) airspeed >= 70kts and THR levers higher than CLB and aft wheels on ground takes 2 seconds
    --FBW mode transfers to flight mode if in air for more than 5 seconds with rotation mode (all wheels are off ground and att > 8) or RA > 50ft takes 5 seconds
    --FBW mode transfers to flare mode if (FBW is in flight mode and RA < 100 or 50RA(depending on settings) and desending)ATT is memorised, goes into pitch demand mode in 1 second
    --FBW mode transfers back to flight mode if (FBW is in flare mode and 100 or 50RA(depending on settings)
    --FBW mode transfers to ground mode if (all wheels are on ground for 5+ seconds and att < 2.5 degrees)
    --ONLY 2 MODES CAN HAPPEN SIMUTANIOUSLY [GROUND + FLIGHT] / [FLIGHT + FLARE] / [FLARE + GROUND] ALL OTHER COMBINATIONS ARE IMPOSSIBLE


    --FBW_vertical_ground_mode_ratio
    --FBW_vertical_rotation_mode_ratio
    --FBW_vertical_flight_mode_ratio
    --FBW_vertical_flare_mode_ratio
    --FBW_lateral_ground_mode_ratio
    --FBW_lateral_flight_mode_ratio
    --FBW_flare_mode_memorised_att
    --FBW_flare_mode_computed_Q

    --properties
    local lateral_ground_mode_transition_time = 0.5
    local vertical_ground_mode_transition_time = 5

    local vertical_rotation_mode_transition_time = 2
    local rotation_mode_duration_s = 5

    local lateral_flight_mode_transition_time = get(FBW_mode_transition_version) == 0 and 2 or 0.5
    local vertical_flight_mode_transition_time = 5

    local flare_mode_transition_RA = get(FBW_mode_transition_version) == 0 and 100 or 50
    local vertical_flare_mode_transition_time = 1

    --timers--
    if get(Aft_wheel_on_ground) == 1 and table.On_ground_timer < 5 then
        table.On_ground_timer = table.On_ground_timer + 1 * get(DELTA_TIME)
    elseif get(Any_wheel_on_ground) == 0 then
        table.On_ground_timer = 0
    end
    if get(FBW_vertical_rotation_mode_ratio) == 1 and get(Any_wheel_on_ground) == 0 and table.In_rotation_mode_duration < rotation_mode_duration_s then
        table.In_rotation_mode_duration = table.In_rotation_mode_duration + 1 * get(DELTA_TIME)
    elseif get(FBW_vertical_rotation_mode_ratio) == 0 then
        table.In_rotation_mode_duration = 0
    end

    --memorise ATT--
    if BoolToNum(get(FBW_vertical_flare_mode_ratio) > 0) - table.Flare_mode_past_status == 1 then
        set(FBW_flare_mode_memorised_att, get(Flightmodel_pitch))
        set(FBW_flare_mode_computed_Q, (-2 - Math_clamp_lower(get(FBW_flare_mode_memorised_att), -2)) / 8)
    elseif BoolToNum(get(FBW_vertical_flare_mode_ratio) > 0) - table.Flare_mode_past_status == -1 then
        set(FBW_flare_mode_memorised_att, 0)
        set(FBW_flare_mode_computed_Q, 0)
    end
    table.Flare_mode_past_status = BoolToNum(get(FBW_vertical_flare_mode_ratio) > 0)

    --LATERAL MODES---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --ground mode --> flight mode
    if (get(Any_wheel_on_ground) == 0 and get(Flightmodel_pitch) > 8) or (get(Capt_ra_alt_ft) > 50 or get(Fo_ra_alt_ft) > 50) then
        set(FBW_lateral_flight_mode_ratio,  Set_linear_anim_value(get(FBW_lateral_flight_mode_ratio), 1, 0, 1, 1 / lateral_flight_mode_transition_time))
    end

    --flight mode --> ground mode
    if get(Aft_wheel_on_ground) == 1 then
        set(FBW_lateral_flight_mode_ratio,  Set_linear_anim_value(get(FBW_lateral_flight_mode_ratio), 0, 0, 1, 1 / lateral_ground_mode_transition_time))
    end

    --VERTICAL MODES--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --ground mode --> Rotation mode
    if get(FBW_vertical_ground_mode_ratio) ~= 0 and (get(L_sim_throttle) >= THR_CLB_START or get(R_sim_throttle) >= THR_CLB_START) and (get_ias(PFD_CAPT) >= 70 or get_ias(PFD_FO) >= 70) and get(FBW_vertical_ground_mode_ratio) ~= 0 then
        set(FBW_vertical_rotation_mode_ratio,  Set_linear_anim_value(get(FBW_vertical_rotation_mode_ratio), 1, 0, 1, 1 / vertical_rotation_mode_transition_time))
    end

    --Rotation mode --> ground mode
    if get(All_on_ground) == 1 and ((get(L_sim_throttle) < THR_CLB_START or get(R_sim_throttle) < THR_CLB_START) or (get_ias(PFD_CAPT) < 70 or get_ias(PFD_FO) < 70)) then
        set(FBW_vertical_rotation_mode_ratio,  Set_linear_anim_value(get(FBW_vertical_rotation_mode_ratio), 0, 0, 1, 1 / vertical_rotation_mode_transition_time))
    end

    --Rotation mode --> flight mode
    if (get(Any_wheel_on_ground) == 0 and get(Flightmodel_pitch) > 8) or (get(Capt_ra_alt_ft) > 50 or get(Fo_ra_alt_ft) > 50) then
        if table.In_rotation_mode_duration >= rotation_mode_duration_s then
            set(FBW_vertical_rotation_mode_ratio, Set_linear_anim_value(get(FBW_vertical_rotation_mode_ratio), 0, 0, 1, 1 / vertical_flight_mode_transition_time))
        end
    end

    --flight mode --> flare mode
    if (get(Capt_ra_alt_ft) < flare_mode_transition_RA or get(Fo_ra_alt_ft) < flare_mode_transition_RA) and (get_vs(PFD_CAPT) <= 0 or get_vs(PFD_FO) <= 0) and get(Any_wheel_on_ground) == 0 and get(FBW_vertical_rotation_mode_ratio) == 0 and get(FBW_vertical_flight_mode_ratio) ~= 0 then
        set(FBW_vertical_flare_mode_ratio, Set_linear_anim_value(get(FBW_vertical_flare_mode_ratio), 1, 0, 1, 1 / vertical_flare_mode_transition_time))
    end

    --flare mode --> rotation mode or flight mode
    if get(FBW_vertical_flare_mode_ratio) ~= 0 and (get(Capt_ra_alt_ft) > flare_mode_transition_RA or get(Fo_ra_alt_ft) > flare_mode_transition_RA) or (get(FBW_vertical_ground_mode_ratio) ~= 0 and (get(L_sim_throttle) >= THR_CLB_START or get(R_sim_throttle) >= THR_CLB_START)) then
        set(FBW_vertical_flare_mode_ratio, Set_linear_anim_value(get(FBW_vertical_flare_mode_ratio), 0, 0, 1, 1 / vertical_flare_mode_transition_time))
    end

    --flare mode --> ground mode
    if (get(All_on_ground) == 1 and table.On_ground_timer >= 5 and get(Flightmodel_pitch) < 2.5) then
        set(FBW_vertical_flare_mode_ratio,  Set_linear_anim_value(get(FBW_vertical_flare_mode_ratio), 0, 0, 1, 1 / vertical_ground_mode_transition_time))
    end

    --trim reset--
    local trim_reset_begin = get(FBW_vertical_ground_mode_ratio) > 0 and 1 or 0
    local trim_reset_begin_delta = trim_reset_begin - table.Previous_trim_reset_begin
    table.Previous_trim_reset_begin = trim_reset_begin
    if trim_reset_begin_delta == 1 then
        set(Augmented_pitch_trim_ratio, 0)
    end

    --ground mode calculation--
    set(FBW_lateral_ground_mode_ratio,  Math_approx_value(Math_clamp_lower(1 - get(FBW_lateral_flight_mode_ratio), 0), 0.001, 0))
    set(FBW_vertical_ground_mode_ratio, Math_approx_value(Math_clamp_lower(1 - get(FBW_vertical_rotation_mode_ratio) - get(FBW_lateral_flight_mode_ratio) - get(FBW_vertical_flare_mode_ratio), 0), 0.001, 0))
    set(FBW_vertical_flight_mode_ratio, Math_approx_value(Math_clamp_lower(1 - get(FBW_vertical_rotation_mode_ratio) - get(FBW_vertical_flare_mode_ratio) - get(FBW_vertical_ground_mode_ratio), 0), 0.001, 0))
end