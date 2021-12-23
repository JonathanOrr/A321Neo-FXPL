local VLS_reduced = 0
local VLS_reduced_ratio = 0
local last_flap_lever_pos = 0
local VLS_update_timer = 0
local VLS_update_time_s = 0.15

FBW.FAC_COMPUTATION.COMPUTE_VLS = function()
    local VLS_flaps_spd_lerp_table = {
        {0.0*27 + 0,  1.28 * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false)},
        {0.7*27 + 0,  Math_rescale(0, 1.23, 1, 1.13, VLS_reduced_ratio) * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 1, false)},
        {0.7*27 + 10, Math_rescale(0, 1.23, 1, 1.13, VLS_reduced_ratio) * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false)},
        {0.8*27 + 14, Math_rescale(0, 1.23, 1, 1.13, VLS_reduced_ratio) * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 3, false)},
        {0.8*27 + 21, Math_rescale(0, 1.23, 1, 1.13, VLS_reduced_ratio) * Math_rescale(0, FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 4, false), 1, FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 4, true), (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3)},
        {1.0*27 + 30, Math_rescale(0, 1.23, 1, 1.13, VLS_reduced_ratio) * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 5, false)},
    }
    local VLS_spdbrake_fx_lerp_table = {
        {0.0*27 + 0,  20},
        {0.7*27 + 0,  10},
        {0.7*27 + 10, 6},
        {0.8*27 + 14, 6},
        {0.8*27 + 21, 6},
        {1.0*27 + 30, 6},
    }

    --reduced VLS in TO or TAG
    if get(Any_wheel_on_ground) == 1 and get(Flaps_internal_config) ~= 0 then
        VLS_reduced = 1
    end

    --delta lever--
    local flap_lever_delta = get(Flaps_handle_position) - last_flap_lever_pos
    last_flap_lever_pos = get(Flaps_handle_position)

    if flap_lever_delta == -1 or get(Flaps_internal_config) == 0 then
        VLS_reduced = 0
    end

    VLS_reduced_ratio = Set_linear_anim_value(VLS_reduced_ratio, VLS_reduced, 0, 1, 1/2.5)

    set(
        VLS,
        Table_interpolate(VLS_flaps_spd_lerp_table, get(Slats)*27 + get(Flaps_deployed_angle)) +
        Math_rescale(
            0,
            0,
            FCTL.SPLR.COMMON.Get_cmded_spdbrk_def(1),
            Table_interpolate(VLS_spdbrake_fx_lerp_table, get(Slats)*27 + get(Flaps_deployed_angle)),
            get(TOTAL_SPDBRK_EXTENSION)
        )
    )
end

function update()
    --VLS & alpha speeds update timer(accirding to video at 25fps updates every 3 <-> 4 frames: https://www.youtube.com/watch?v=3Suxhj9wQio&ab_channel=a321trainingteam)
    VLS_update_timer = VLS_update_timer + get(DELTA_TIME)

    --VLS & stall speeds(configuration dependent)
    if VLS_update_timer >= VLS_update_time_s then
        FBW.FAC_COMPUTATION.COMPUTE_VLS()

        --reset timer
        VLS_update_timer = 0
    end
end