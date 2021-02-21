function Rudder_trim_left(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Rudder_trim_knob_pos, -1)

        if get(Rudder_trim_avail) == 1 then
            set(Human_rudder_trim, -1)
        end
    end

    if phase == SASL_COMMAND_END then
        set(Rudder_trim_knob_pos, 0)
    end
end

function Rudder_trim_right(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Rudder_trim_knob_pos, 1)

        if get(Rudder_trim_avail) == 1 then
            set(Human_rudder_trim, 1)
        end
    end

    if phase == SASL_COMMAND_END then
        set(Rudder_trim_knob_pos, 0)
    end
end

function Reset_rudder_trim(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if get(Rudder_trim_avail) == 1 then
            set(Resetting_rudder_trim, 1)
        end
    end
end

function Rudder_control(yaw_input, fbw_current_law, is_in_auto_flight, trim_input, resetting_trim)
    --[[in auto flight the rudder trim is controlled by the FMGC, otherwise the pilot can change the value by using the knob on the center pedestal

    reversions
    flight computers FAC 1 --> FAC 2
    hyd(rudder)      G | B | Y
    hyd(damper)      G | Y
    mech             full mechanical link
    ]]

    --FBW law constants--
    --2 = NORMAL LAW
    --1 = ALT LAW
    --0 = DIRECT LAW

    --PROPERTIES--
    local rudder_speed = 21.5
    local rudder_trim_speed = 1
    --the proportion is the same no matter the limits, hence at higher speed you'll reach the limit with less deflection
    local rudder_travel_target = yaw_input * 30

    --RUDDER LIMITS--
    if get(Force_full_rudder_limit) ~= 1 then
        if get(Rudder_lim_avail) == 1 and get(Slats) == 0 then
            set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), -22.1 * math.sqrt(1 - ( (Math_clamp(adirs_get_avg_ias(), 160, 380) - 380) / 220)^2 ) + 25, 0, 30, rudder_trim_speed))
        end
        if get(Slats) > 0 and get(Rudder_lim_avail) == 1 then
            set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), 25, 0, 30, rudder_trim_speed))
        end
    end

    if get(Force_full_rudder_limit) == 1 then
        set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), 30, 0, 30, rudder_trim_speed))
    end

    --rudder trim
    if resetting_trim == 1 then
        if get(trim_input) ~= 0 then
            set(Resetting_rudder_trim, 0)
        elseif get(Rudder_trim_target_angle) == 0 then
            set(Resetting_rudder_trim, 0)
        end
    end

    --if the FACs are working and the electrical motors are working
    if get(Rudder_trim_avail) == 1 then
        if resetting_trim == 0 then--apply human input
            set(Rudder_trim_target_angle, Math_clamp(Math_clamp(get(Rudder_trim_target_angle) + trim_input * rudder_trim_speed * get(DELTA_TIME), -20, 20), -get(Rudder_travel_lim), get(Rudder_travel_lim)))
            set(Human_rudder_trim, 0)
        else--reset rudder trim
            set(Rudder_trim_target_angle, Set_linear_anim_value(get(Rudder_trim_target_angle), 0, -20, 20, rudder_trim_speed))
            set(Human_rudder_trim, 0)
        end

        --as normal law uses SI demand, it is needed to always center the trim, and let the controller determine the postition of the rudder
        if get(FBW_yaw_law) ~= FBW_NORMAL_LAW or get(All_on_ground) == 1 then
            set(Rudder_trim_actual_angle, Set_linear_anim_value(get(Rudder_trim_actual_angle), get(Rudder_trim_target_angle), -20, 20, rudder_trim_speed))
        else
            set(Rudder_trim_actual_angle, Set_linear_anim_value(get(Rudder_trim_actual_angle), 0, -20, 20, rudder_trim_speed))
        end
    end

    --rudder failure--
    rudder_speed = Math_rescale(0, 0, 1450, rudder_speed, get(Hydraulic_G_press) + get(Hydraulic_B_press) + get(Hydraulic_Y_press)) * (1 - get(FAILURE_FCTL_RUDDER_MECH))

    --limit rudder travel target--
    rudder_travel_target = Math_clamp(rudder_travel_target, -get(Rudder_travel_lim) - get(Rudder_trim_actual_angle), get(Rudder_travel_lim) - get(Rudder_trim_actual_angle))

    --rudder position calculation--
    set(Augmented_rudder_angle, Set_anim_value_linear_range(get(Augmented_rudder_angle), rudder_travel_target, -30, 30, rudder_speed, 5))
    set(Rudder, Math_clamp(get(Rudder_trim_actual_angle) + get(Augmented_rudder_angle), -get(Rudder_travel_lim), get(Rudder_travel_lim)))
end
