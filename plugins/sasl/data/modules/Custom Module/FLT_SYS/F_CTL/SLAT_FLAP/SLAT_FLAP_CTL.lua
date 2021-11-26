include("ADIRS_data_source.lua")

function Slats_flaps_calc_and_control()
    local slat_ratios = {
        0,
        10,
        10,
        14,
        21,
        30
    }
    local flap_angles = {
        0,
        0,
        10,
        14,
        21,
        30,
    }

    --surface speeds
    local flaps_full_deploy_time = 20
    local slat_spd = slat_ratios[#slat_ratios] / flaps_full_deploy_time
    local flap_spd = flap_angles[#flap_angles] / flaps_full_deploy_time

    --positions--
    local slat_ratio_to_slat = {
        {0,    0},
        {10, 0.7},
        {14, 0.8},
        {21, 0.8},
        {30,   1},
    }

    --configuration logic--
    local last_flaps_handle_pos = get(Flaps_handle_position)
    set(Flaps_handle_position, Round(get(Flaps_handle_ratio) * 4))
    local flaps_handle_delta = get(Flaps_handle_position) - last_flaps_handle_pos

    if flaps_handle_delta ~= 0 then
        if last_flaps_handle_pos == 0 and flaps_handle_delta == 1 then
            if adirs_get_avg_ias() <= 100 then
                set(Flaps_internal_config, 2)-- 1+F
            else
                set(Flaps_internal_config, 1)-- 1
            end
        elseif last_flaps_handle_pos == 2 and flaps_handle_delta == -1 then
            if adirs_get_avg_ias() <= 210 then
                set(Flaps_internal_config, 2)-- 1+F
            else
                set(Flaps_internal_config, 1)-- 1
            end
        else
            if get(Flaps_handle_position) == 0 then
                set(Flaps_internal_config, 0)--0
            elseif get(Flaps_handle_position) == 2 then
                set(Flaps_internal_config, 3)--2
            elseif get(Flaps_handle_position) == 3 then
                set(Flaps_internal_config, 4)--3
            elseif get(Flaps_handle_position) == 4 then
                set(Flaps_internal_config, 5)--full
            end
        end
    else
        if get(Flaps_internal_config) == 1 and adirs_get_avg_ias() <= 100 and get(Override_flap_auto_extend_and_retract) == 0 then--go to 1+F
            set(Flaps_internal_config, 2)
        end
        if get(Flaps_internal_config) == 2 and adirs_get_avg_ias() >= 210 and get(Override_flap_auto_extend_and_retract) == 0 then--back to 1
            set(Flaps_internal_config, 1)
        end
    end

    --slat alpha/speed lock
    if last_flaps_handle_pos == 1 and flaps_handle_delta == -1 and (adirs_get_avg_aoa() > 8 or adirs_get_avg_ias() < 165) then
        set(Slat_alpha_locked, 1)
    end
    if get(Slat_alpha_locked) == 1 and (adirs_get_avg_aoa() < 7.1 or adirs_get_avg_ias() > 171) then--de-activation
        set(Slat_alpha_locked, 0)
    end
    if get(Any_wheel_on_ground) == 1 and adirs_get_avg_ias() < 60 then--inhibition
        set(Slat_alpha_locked, 0)
    end

    --make ecam slats or flaps indication yellow refer to FCOM 1.27.50 P6
    if get(All_on_ground) == 0 or (get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1) then
        if (get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
            set(Slats_ecam_amber, 1)
        else
            set(Slats_ecam_amber, 0)
        end

        if (get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
            set(Flaps_ecam_amber, 1)
        else
            set(Flaps_ecam_amber, 0)
        end
    else
        set(Slats_ecam_amber, 0)
        set(Flaps_ecam_amber, 0)
    end

    --SPEEDs logic--
    local hyd_spd = {
        {0,      0},
        {1450, 0.5},
        {2900,   1},
    }
    local sfcc_spd = {
        {0,   0},
        {1, 0.5},
        {2,   1},
    }
    slat_spd = slat_spd * Table_interpolate(hyd_spd, get(Hydraulic_G_press) + get(Hydraulic_B_press))
    slat_spd = slat_spd * Table_interpolate(sfcc_spd, get(SFCC_1_status) + get(SFCC_2_status))
    flap_spd = flap_spd * Table_interpolate(hyd_spd, get(Hydraulic_G_press) + get(Hydraulic_Y_press))
    flap_spd = flap_spd * Table_interpolate(sfcc_spd, get(SFCC_1_status) + get(SFCC_2_status))

    --slat alpha inhibit
    slat_spd = slat_spd * (1 - get(Slat_alpha_locked))

    --SLAT FLAP MOVEMENT
    local past_slats_pos = get(Slats)
    local past_flaps_angle = get(Flaps_deployed_angle)

    set(Slats_predeploy_ratio, Set_linear_anim_value(get(Slats_predeploy_ratio), slat_ratios[get(Flaps_internal_config) + 1], 0, slat_ratios[#slat_ratios], slat_spd))

    --convert flaps ratio to angle for normalised spd--
    set(Slats,                Table_interpolate(slat_ratio_to_slat,  get(Slats_predeploy_ratio)))
    set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), flap_angles[get(Flaps_internal_config) + 1], 0, flap_angles[#flap_angles], flap_spd))

    local new_slats_pos = get(Slats)
    local new_flaps_angle = get(Flaps_deployed_angle)

    set(Slats_in_transit, BoolToNum(new_slats_pos - past_slats_pos ~= 0))--slats moving
    set(Flaps_in_transit, BoolToNum(new_flaps_angle - past_flaps_angle ~= 0))--flaps moving

    set(Left_inboard_flaps,   get(Flaps_deployed_angle))
    set(Left_outboard_flaps,  get(Flaps_deployed_angle))
    set(Right_inboard_flaps,  get(Flaps_deployed_angle))
    set(Right_outboard_flaps, get(Flaps_deployed_angle))
end

function update()
    Slats_flaps_calc_and_control()
end