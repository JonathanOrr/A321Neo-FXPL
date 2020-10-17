function Slats_flaps_calc_and_control()
    --SFCC 1/2 status
    if get(FAILURE_FCTL_SFCC_1) == 1 then
        set(SFCC_1_status, 0)
    else
        set(SFCC_1_status, 1)
    end
    if get(FAILURE_FCTL_SFCC_2) == 1 then
        set(SFCC_2_status, 0)
    else
        set(SFCC_2_status, 1)
    end

    --surface speeds
    local slats_speed = 0.0625
    local flaps_speed = 2.5

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

    --speed and inhibition
    --slats
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_B_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        slats_speed = 0.0625
        set(Slats_ecam_amber, 0)
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        slats_speed = 0
        --make ecame slats indication yellow refer to FCOM 1.27.50 P6
        if get(All_on_ground) == 1 and get(Engine_1_avail) == 0 and get(Engine_2_avail) == 0 then
            set(Slats_ecam_amber, 0)
        else
            set(Slats_ecam_amber, 1)
        end
    else
        slats_speed = 0.0625 / 2
        set(Slats_ecam_amber, 0)
    end
    --flaps
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_Y_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        flaps_speed = 2.5
        set(Flaps_ecam_amber, 0)
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        flaps_speed = 0
        --make ecame flaps indication yellow refer to FCOM 1.27.50 P6
        if get(All_on_ground) == 1 and get(Engine_1_avail) == 0 and get(Engine_2_avail) == 0 then
            set(Flaps_ecam_amber, 0)
        else
            set(Flaps_ecam_amber, 1)
        end
    else
        flaps_speed = 2.5 / 2
        set(Flaps_ecam_amber, 0)
    end

    local past_slats_pos = get(Slats)
    local past_flaps_angle = get(Flaps_deployed_angle)

    if get(Flaps_internal_config) == 0 then--0
        set(Slats, Set_linear_anim_value(get(Slats), 0, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 0, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 1 then--1
        set(Slats, Set_linear_anim_value(get(Slats), 0.7, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 0, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 2 then--1+f
        set(Slats, Set_linear_anim_value(get(Slats), 0.7, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 10, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 3 then--2
        set(Slats, Set_linear_anim_value(get(Slats), 0.8, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 15, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 4 then--3
        set(Slats, Set_linear_anim_value(get(Slats), 0.8, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 20, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 5 then--full
        set(Slats, Set_linear_anim_value(get(Slats), 1, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 40, 0, 40, flaps_speed))
    end

    local new_slats_pos = get(Slats)
    local new_flaps_angle = get(Flaps_deployed_angle)

    if new_slats_pos - past_slats_pos ~= 0 then--flaps moving
        set(Slats_in_transit, 1)
    else
        set(Slats_in_transit, 0)
    end

    if new_flaps_angle - past_flaps_angle ~= 0 then--flaps moving
        set(Flaps_in_transit, 1)
    else
        set(Flaps_in_transit, 0)
    end

    set(Left_inboard_flaps, get(Flaps_deployed_angle))
    set(Left_outboard_flaps, get(Flaps_deployed_angle))
    set(Right_inboard_flaps, get(Flaps_deployed_angle))
    set(Right_outboard_flaps, get(Flaps_deployed_angle))
end