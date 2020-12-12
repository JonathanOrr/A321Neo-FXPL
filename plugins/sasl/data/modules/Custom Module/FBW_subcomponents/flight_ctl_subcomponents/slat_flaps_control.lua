function Slats_flaps_calc_and_control()
    --SFCC 1/2 status
    set(SFCC_1_status, 1 * (1 - get(FAILURE_FCTL_SFCC_1)))
    set(SFCC_2_status, 1 * (1 - get(FAILURE_FCTL_SFCC_2)))

    --surface speeds
    local flaps_full_deploy_time = 15
    local slat_ratio_spd = 1 / flaps_full_deploy_time
    local flap_ratio_spd = 1 / flaps_full_deploy_time

    --positions--
    local slat_ratio = {
        0,
        0.25,
        0.25,
        0.5,
        0.75,
        1
    }
    local flap_ratio = {
        0,
        0,
        0.25,
        0.5,
        0.75,
        1
    }
    local slat_ratio_to_slat = {
        {0,    0},
        {0.25, 0.7},
        {0.5,  0.8},
        {0.75, 0.8},
        {1,    1},
    }
    local flap_ratio_to_angle = {
        {0,    0},
        {0.25, 10},
        {0.5,  14},
        {0.75, 21},
        {1,    25},
    }

    --configuration logic--
    local last_flaps_handle_pos = get(Flaps_handle_position)
    set(Flaps_handle_position, Round(get(Flaps_handle_ratio) * 4))
    local flaps_handle_delta = get(Flaps_handle_position) - last_flaps_handle_pos

    if flaps_handle_delta ~= 0 then
        if last_flaps_handle_pos == 0 and flaps_handle_delta == 1 then
            if get(Capt_IAS) <= 100 then
                set(Flaps_internal_config, 2)-- 1+F
            else
                set(Flaps_internal_config, 1)-- 1
            end
        elseif last_flaps_handle_pos == 2 and flaps_handle_delta == -1 then
            if get(Capt_IAS) <= 210 then
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
        if get(Flaps_internal_config) == 2 and get(Capt_IAS) >= 210 then--back to 1
            set(Flaps_internal_config, 1)
        end
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
    end

    --SPEEDs logic--
    slat_ratio_spd = slat_ratio_spd * ((get(Hydraulic_G_press) < 1450 or get(Hydraulic_B_press) < 1450) and 0.5 or 1)
    slat_ratio_spd = slat_ratio_spd * ((get(SFCC_1_status) == 0 or get(SFCC_2_status) == 0) and 0.5 or 1)
    flap_ratio_spd = flap_ratio_spd * ((get(Hydraulic_G_press) < 1450 or get(Hydraulic_Y_press) < 1450) and 0.5 or 1)
    flap_ratio_spd = flap_ratio_spd * ((get(SFCC_1_status) == 0 or get(SFCC_2_status) == 0) and 0.5 or 1)

    slat_ratio_spd = Math_rescale(0, 0, 1450, slat_ratio_spd, get(Hydraulic_G_press) + get(Hydraulic_B_press))
    flap_ratio_spd = Math_rescale(0, 0, 1450, flap_ratio_spd, get(Hydraulic_G_press) + get(Hydraulic_Y_press))

    --SLAT FLAP MOVEMENT
    local past_slats_pos = get(Slats)
    local past_flaps_angle = get(Flaps_deployed_angle)

    set(Slats_predeploy_ratio, Set_linear_anim_value(get(Slats_predeploy_ratio), slat_ratio[get(Flaps_internal_config) + 1], 0, 1, slat_ratio_spd))
    set(Flaps_deployed_ratio,  Set_linear_anim_value(get(Flaps_deployed_ratio),  flap_ratio[get(Flaps_internal_config) + 1], 0, 1, flap_ratio_spd))

    --convert flaps ratio to angle for normalised spd--
    set(Slats,                Table_interpolate(slat_ratio_to_slat,  get(Slats_predeploy_ratio)))
    set(Flaps_deployed_angle, Table_interpolate(flap_ratio_to_angle, get(Flaps_deployed_ratio)))

    local new_slats_pos = get(Slats)
    local new_flaps_angle = get(Flaps_deployed_angle)

    set(Slats_in_transit, BoolToNum(new_slats_pos - past_slats_pos ~= 0))--slats moving
    set(Flaps_in_transit, BoolToNum(new_flaps_angle - past_flaps_angle ~= 0))--flaps moving

    set(Left_inboard_flaps,   get(Flaps_deployed_angle))
    set(Left_outboard_flaps,  get(Flaps_deployed_angle))
    set(Right_inboard_flaps,  get(Flaps_deployed_angle))
    set(Right_outboard_flaps, get(Flaps_deployed_angle))
end