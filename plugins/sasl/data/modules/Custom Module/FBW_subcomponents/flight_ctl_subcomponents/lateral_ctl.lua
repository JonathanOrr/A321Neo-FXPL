--AILERONS--
function Ailerons_control(lateral_input ,has_florence_kit)
    --hyd source B or G (1450PSI)
    --reversion of flight computers: ELAC 1 --> 2
    --surface range -25 up +25 down, 5 degrees droop with flaps(calculated by ELAC 1/2)

    --properties
    local ailerons_max_def = 25
    local ailerons_speed = 38.5

    --conditions
    local l_aileron_actual_speed = 38.5
    local r_aileron_actual_speed = 38.5

    local l_aileron_travel_target = ailerons_max_def *  lateral_input
    local r_aileron_travel_target = ailerons_max_def * -lateral_input

    --hydralics power detection
    if get(Hydraulic_B_press) >= 1450 or get(Hydraulic_G_press) >= 1450 then--both hyds working
        l_aileron_actual_speed = ailerons_speed
        r_aileron_actual_speed = ailerons_speed
    elseif get(Hydraulic_B_press) < 1450 and get(Hydraulic_G_press) >= 1450 then--B HYD working
        l_aileron_actual_speed = ailerons_speed
        r_aileron_actual_speed = ailerons_speed
    elseif get(Hydraulic_B_press) >= 1450 and get(Hydraulic_G_press) < 1450 then--G HYD working
        l_aileron_actual_speed = ailerons_speed
        r_aileron_actual_speed = ailerons_speed
    elseif get(Hydraulic_B_press) < 1450 and get(Hydraulic_G_press) < 1450 then--Both HYD not fully/ not working
        if get(Hydraulic_B_press) > get(Hydraulic_G_press) then-- B HYD is more powerful
            l_aileron_actual_speed = Math_lerp(0, ailerons_speed, Math_clamp(get(Hydraulic_B_press), 0, 1450) / 1450)
            r_aileron_actual_speed = Math_lerp(0, ailerons_speed, Math_clamp(get(Hydraulic_B_press), 0, 1450) / 1450)
        elseif get(Hydraulic_B_press) < get(Hydraulic_G_press) then-- G HYD is more powerful
            l_aileron_actual_speed = Math_lerp(0, ailerons_speed, Math_clamp(get(Hydraulic_G_press), 0, 1450) / 1450)
            r_aileron_actual_speed = Math_lerp(0, ailerons_speed, Math_clamp(get(Hydraulic_G_press), 0, 1450) / 1450)
        else--any other situation(both 0 or the same as each other)
            l_aileron_actual_speed = Math_lerp(0, ailerons_speed, Math_clamp((get(Hydraulic_B_press) + get(Hydraulic_G_press)) / 2, 0, 1450) / 1450)
            r_aileron_actual_speed = Math_lerp(0, ailerons_speed, Math_clamp((get(Hydraulic_B_press) + get(Hydraulic_G_press)) / 2, 0, 1450) / 1450)
        end
    end

    --detect ELAC failures and revert accordingly 1 --> 2
    if get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0 then
        l_aileron_travel_target = 0
        r_aileron_travel_target = 0
    end

    --detect HYD failures
    if get(FAILURE_FCTL_LAIL) == 1 then
        l_aileron_actual_speed = 0
    end
    if get(FAILURE_FCTL_RAIL) == 1 then
        r_aileron_actual_speed = 0
    end

    --FLORENCE KIT MISSING--
    --********************--
    --output to the surfaces
    set(Left_aileron, Set_linear_anim_value(get(Left_aileron),   l_aileron_travel_target, -25, 25, l_aileron_actual_speed))
    set(Right_aileron, Set_linear_anim_value(get(Right_aileron), r_aileron_travel_target, -25, 25, r_aileron_actual_speed))
end

--ROLL SPOILERS & SPD BRAKES--
function Spoilers_control(lateral_input, spdbrk_input, in_auto_flight)
    --spoilers 2 3 4 are speedbrakes(still rolls with ailerons, manual flight deflection is 20/ 40/ 40, autoflight is 12.5/ 25/ 25 [full deployment with half handle], [on ground spoiler 1 can be open up to 6 degreess for maintainance with the spdbrk handle])
    --spoilers 2 3 4 5 are roll spoilers(can roll up to 35 degrees, on ground full roll is 35/ 7/ 35/ 35, in air is 25/ 7/ 25/ 25 [although this rarely happens unless on ground])
    --spoilers 1 2 3 4 5 are all ground spoilers(deploys to 40 degrees)
    --ground spoiler partially extends(10 degrees) if one of the main gear is on the ground while one of the reversers is selected and the other throttle is at or near idle(this will lead to a full extention)
    --ground spoiler is deployed(40 degrees) if during takeoff airspeed is higher than 72kts and levers are moved to idle(if armed)
    --also during touchdown if the throttle is idle or one of the throttle in reverse(other level must be idle) if the spoilers are not armed

    --if the spoilers are armed then the spoilers will be retracted when the handle is disarmed
    --if the spoilers are not armed then when the thrust levers goes back to idle the spoilers will retract
    --if the aircraft bounced during the landing the spoilers will still be extented until disarmed

    --during a touch and go one of the thrust levers has to be advanced beyond 20 degrees to disarm the spoilers

    --spoiler config 1 2 3 4 5
    --HYDs           G Y B Y G
    --SECs           3 3 1 1 2

    --properties
    local roll_spoiler_spd = 40
    local ground_spoiler_spd = 8

    local l_spoilers_total_max_def = {40, 40, 40, 40, 40}
    local r_spoilers_total_max_def = {40, 40, 40, 40, 40}

    local l_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
    local r_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}

    local l_spoilers_roll_max_def = {0, 35, 7, 35, 35}
    local r_spoilers_roll_max_def = {0, 35, 7, 35, 35}

    local l_spoilers_spdbrk_spd = {8, 8, 8, 8, 8}
    local r_spoilers_spdbrk_spd = {8, 8, 8, 8, 8}
    local l_spoilers_roll_spd = {0, 40, 40, 40, 40}
    local r_spoilers_roll_spd = {0, 40, 40, 40, 40}

    if in_auto_flight == true then
        l_spoilers_spdbrk_max_def = {0, 12.5, 25, 25, 0}
        r_spoilers_spdbrk_max_def = {0, 12.5, 25, 25, 0}
    else
        l_spoilers_spdbrk_max_def = {0, 20, 40, 40, 0}
        r_spoilers_spdbrk_max_def = {0, 20, 40, 40, 0}
    end

    if get(Aft_wheel_on_ground) == 1 then
        l_spoilers_roll_max_def = {0, 35, 7, 35, 35}
        r_spoilers_roll_max_def = {0, 35, 7, 35, 35}

        --on ground and slightly open spoiler 1 with speedbrake handle
        l_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
        r_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
    else
        l_spoilers_roll_max_def = {0, 25, 7, 25, 25}
        r_spoilers_roll_max_def = {0, 25, 7, 25, 25}
    end

    --conditions
    local l_spoilers_actual_spdbrk_spd = {0, 40, 40, 40, 40}
    local r_spoilers_actual_spdbrk_spd = {0, 40, 40, 40, 40}

    local l_spoilers_actual_roll_spd = {0, 40, 40, 40, 40}
    local r_spoilers_actual_roll_spd = {0, 40, 40, 40, 40}

    local l_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
    local r_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}

    local l_spoilers_roll_targets = {0, 0, 0, 0, 0}
    local r_spoilers_roll_targets = {0, 0, 0, 0, 0}

    local l_spoilers_spdbrk_extention = {0, 0, 0, 0, 0}
    local r_spoilers_spdbrk_extention = {0, 0, 0, 0, 0}

    local l_spoilers_roll_extention = {0, 0, 0, 0, 0}
    local r_spoilers_roll_extention = {0, 0, 0, 0, 0}

    --left speedbrakes input translation
    l_spoilers_spdbrk_targets = {
        l_spoilers_spdbrk_max_def[1] * math.abs(Math_clamp_higher(spdbrk_input, 0)),
        l_spoilers_spdbrk_max_def[2] * math.abs(Math_clamp_higher(spdbrk_input, 0)),
        l_spoilers_spdbrk_max_def[3] * math.abs(Math_clamp_higher(spdbrk_input, 0)),
        l_spoilers_spdbrk_max_def[4] * math.abs(Math_clamp_higher(spdbrk_input, 0)),
        l_spoilers_spdbrk_max_def[5] * math.abs(Math_clamp_higher(spdbrk_input, 0)),
    }
    --right speedbrakes input translation
    r_spoilers_spdbrk_targets = {
        r_spoilers_spdbrk_max_def[1] * math.abs(Math_clamp_lower(spdbrk_input, 0)),
        r_spoilers_spdbrk_max_def[2] * math.abs(Math_clamp_lower(spdbrk_input, 0)),
        r_spoilers_spdbrk_max_def[3] * math.abs(Math_clamp_lower(spdbrk_input, 0)),
        r_spoilers_spdbrk_max_def[4] * math.abs(Math_clamp_lower(spdbrk_input, 0)),
        r_spoilers_spdbrk_max_def[5] * math.abs(Math_clamp_lower(spdbrk_input, 0)),
    }

    --left roll spoilers input translation
    l_spoilers_roll_targets = {
        l_spoilers_roll_max_def[1] * math.abs(Math_clamp_higher(lateral_input, 0)),
        l_spoilers_roll_max_def[2] * math.abs(Math_clamp_higher(lateral_input, 0)),
        l_spoilers_roll_max_def[3] * math.abs(Math_clamp_higher(lateral_input, 0)),
        l_spoilers_roll_max_def[4] * math.abs(Math_clamp_higher(lateral_input, 0)),
        l_spoilers_roll_max_def[5] * math.abs(Math_clamp_higher(lateral_input, 0)),
    }
    --right roll spoilers input translation
    r_spoilers_roll_targets = {
        r_spoilers_roll_max_def[1] * math.abs(Math_clamp_lower(lateral_input, 0)),
        r_spoilers_roll_max_def[2] * math.abs(Math_clamp_lower(lateral_input, 0)),
        r_spoilers_roll_max_def[3] * math.abs(Math_clamp_lower(lateral_input, 0)),
        r_spoilers_roll_max_def[4] * math.abs(Math_clamp_lower(lateral_input, 0)),
        r_spoilers_roll_max_def[5] * math.abs(Math_clamp_lower(lateral_input, 0)),
    }

    --left speedbrakes extention
    l_spoilers_spdbrk_extention = {
        Set_linear_anim_value(l_spoilers_spdbrk_extention[1], l_spoilers_spdbrk_targets[1], 0, 40, l_spoilers_actual_spdbrk_spd[1]),
        Set_linear_anim_value(l_spoilers_spdbrk_extention[2], l_spoilers_spdbrk_targets[2], 0, 40, l_spoilers_actual_spdbrk_spd[2]),
        Set_linear_anim_value(l_spoilers_spdbrk_extention[3], l_spoilers_spdbrk_targets[3], 0, 40, l_spoilers_actual_spdbrk_spd[3]),
        Set_linear_anim_value(l_spoilers_spdbrk_extention[4], l_spoilers_spdbrk_targets[4], 0, 40, l_spoilers_actual_spdbrk_spd[4]),
        Set_linear_anim_value(l_spoilers_spdbrk_extention[5], l_spoilers_spdbrk_targets[5], 0, 40, l_spoilers_actual_spdbrk_spd[5]),
    }
    --right speedbrakes extention
    r_spoilers_spdbrk_extention = {
        Set_linear_anim_value(r_spoilers_spdbrk_extention[1], r_spoilers_spdbrk_targets[1], 0, 40, r_spoilers_actual_spdbrk_spd[1]),
        Set_linear_anim_value(r_spoilers_spdbrk_extention[2], r_spoilers_spdbrk_targets[2], 0, 40, r_spoilers_actual_spdbrk_spd[2]),
        Set_linear_anim_value(r_spoilers_spdbrk_extention[3], r_spoilers_spdbrk_targets[3], 0, 40, r_spoilers_actual_spdbrk_spd[3]),
        Set_linear_anim_value(r_spoilers_spdbrk_extention[4], r_spoilers_spdbrk_targets[4], 0, 40, r_spoilers_actual_spdbrk_spd[4]),
        Set_linear_anim_value(r_spoilers_spdbrk_extention[5], r_spoilers_spdbrk_targets[5], 0, 40, r_spoilers_actual_spdbrk_spd[5]),
    }

    --left roll spoilers extention
    l_spoilers_roll_extention = {
        Set_linear_anim_value(l_spoilers_roll_extention[1], l_spoilers_roll_targets[1], 0, 40, l_spoilers_actual_roll_spd[1]),
        Set_linear_anim_value(l_spoilers_roll_extention[2], l_spoilers_roll_targets[2], 0, 40, l_spoilers_actual_roll_spd[2]),
        Set_linear_anim_value(l_spoilers_roll_extention[3], l_spoilers_roll_targets[3], 0, 40, l_spoilers_actual_roll_spd[3]),
        Set_linear_anim_value(l_spoilers_roll_extention[4], l_spoilers_roll_targets[4], 0, 40, l_spoilers_actual_roll_spd[4]),
        Set_linear_anim_value(l_spoilers_roll_extention[5], l_spoilers_roll_targets[5], 0, 40, l_spoilers_actual_roll_spd[5]),
    }
    --right roll spoilers extention
    r_spoilers_roll_extention = {
        Set_linear_anim_value(r_spoilers_roll_extention[1], r_spoilers_roll_targets[1], 0, 40, r_spoilers_actual_roll_spd[1]),
        Set_linear_anim_value(r_spoilers_roll_extention[2], r_spoilers_roll_targets[2], 0, 40, r_spoilers_actual_roll_spd[2]),
        Set_linear_anim_value(r_spoilers_roll_extention[3], r_spoilers_roll_targets[3], 0, 40, r_spoilers_actual_roll_spd[3]),
        Set_linear_anim_value(r_spoilers_roll_extention[4], r_spoilers_roll_targets[4], 0, 40, r_spoilers_actual_roll_spd[4]),
        Set_linear_anim_value(r_spoilers_roll_extention[5], r_spoilers_roll_targets[5], 0, 40, r_spoilers_actual_roll_spd[5]),
    }

    --TOTAL SPOILERS OUTPUT TO THE SURFACES--
    --if any surface exceeds the max deflection limit the othere side would reduce deflection by the exceeded amount
    --left spoilers output
    set(Left_spoiler_1, Math_clamp_higher(l_spoilers_spdbrk_extention[1] + l_spoilers_roll_extention[1], l_spoilers_total_max_def[1]) - Math_clamp_lower(r_spoilers_spdbrk_extention[1] + r_spoilers_roll_extention[1] - r_spoilers_total_max_def[1], 0))
    set(Left_spoiler_2, Math_clamp_higher(l_spoilers_spdbrk_extention[2] + l_spoilers_roll_extention[2], l_spoilers_total_max_def[2]) - Math_clamp_lower(r_spoilers_spdbrk_extention[2] + r_spoilers_roll_extention[2] - r_spoilers_total_max_def[2], 0))
    set(Left_spoiler_3, Math_clamp_higher(l_spoilers_spdbrk_extention[3] + l_spoilers_roll_extention[3], l_spoilers_total_max_def[3]) - Math_clamp_lower(r_spoilers_spdbrk_extention[3] + r_spoilers_roll_extention[3] - r_spoilers_total_max_def[3], 0))
    set(Left_spoiler_4, Math_clamp_higher(l_spoilers_spdbrk_extention[4] + l_spoilers_roll_extention[4], l_spoilers_total_max_def[4]) - Math_clamp_lower(r_spoilers_spdbrk_extention[4] + r_spoilers_roll_extention[4] - r_spoilers_total_max_def[4], 0))
    set(Left_spoiler_5, Math_clamp_higher(l_spoilers_spdbrk_extention[5] + l_spoilers_roll_extention[5], l_spoilers_total_max_def[5]) - Math_clamp_lower(r_spoilers_spdbrk_extention[5] + r_spoilers_roll_extention[5] - r_spoilers_total_max_def[5], 0))
    --right spoilers output
    set(Left_spoiler_1, Math_clamp_higher(r_spoilers_spdbrk_extention[1] + r_spoilers_roll_extention[1], r_spoilers_total_max_def[1]) - Math_clamp_lower(l_spoilers_spdbrk_extention[1] + l_spoilers_roll_extention[1] - l_spoilers_total_max_def[1], 0))
    set(Left_spoiler_2, Math_clamp_higher(r_spoilers_spdbrk_extention[2] + r_spoilers_roll_extention[2], r_spoilers_total_max_def[2]) - Math_clamp_lower(l_spoilers_spdbrk_extention[2] + l_spoilers_roll_extention[2] - l_spoilers_total_max_def[2], 0))
    set(Left_spoiler_3, Math_clamp_higher(r_spoilers_spdbrk_extention[3] + r_spoilers_roll_extention[3], r_spoilers_total_max_def[3]) - Math_clamp_lower(l_spoilers_spdbrk_extention[3] + l_spoilers_roll_extention[3] - l_spoilers_total_max_def[3], 0))
    set(Left_spoiler_4, Math_clamp_higher(r_spoilers_spdbrk_extention[4] + r_spoilers_roll_extention[4], r_spoilers_total_max_def[4]) - Math_clamp_lower(l_spoilers_spdbrk_extention[4] + l_spoilers_roll_extention[4] - l_spoilers_total_max_def[4], 0))
    set(Left_spoiler_5, Math_clamp_higher(r_spoilers_spdbrk_extention[5] + r_spoilers_roll_extention[5], r_spoilers_total_max_def[5]) - Math_clamp_lower(l_spoilers_spdbrk_extention[5] + l_spoilers_roll_extention[5] - l_spoilers_total_max_def[5], 0))
end