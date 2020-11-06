--AILERONS--
function Ailerons_control(lateral_input ,has_florence_kit, ground_spoilers_mode)
    --hyd source B or G (1450PSI)
    --reversion of flight computers: ELAC 1 --> 2
    --surface range -25 up +25 down, 5 degrees droop with flaps(calculated by ELAC 1/2)

    --properties
    local no_hyd_recenter_ias = 80
    local no_hyd_spd = 10
    local ailerons_max_def = 25
    local ailerons_speed = 38.5

    --conditions
    local l_aileron_actual_speed = 38.5
    local r_aileron_actual_speed = 38.5

    local l_aileron_travel_target = Math_clamp(ailerons_max_def *  lateral_input + 5 * get(Flaps_deployed_angle) / 40, -25, 25)
    local r_aileron_travel_target = Math_clamp(ailerons_max_def * -lateral_input + 5 * get(Flaps_deployed_angle) / 40, -25, 25)

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
            l_aileron_actual_speed = Math_lerp(no_hyd_spd, ailerons_speed, Math_clamp(get(Hydraulic_B_press), 0, 1450) / 1450)
            r_aileron_actual_speed = Math_lerp(no_hyd_spd, ailerons_speed, Math_clamp(get(Hydraulic_B_press), 0, 1450) / 1450)

            l_aileron_travel_target = Math_lerp(Math_lerp(25 , l_aileron_travel_target, Math_clamp(get(Hydraulic_B_press), 0, 1450) / 1450), 0, Math_clamp(get(IAS) / no_hyd_recenter_ias, 0, 1))
            r_aileron_travel_target = Math_lerp(Math_lerp(25 , r_aileron_travel_target, Math_clamp(get(Hydraulic_B_press), 0, 1450) / 1450), 0, Math_clamp(get(IAS) / no_hyd_recenter_ias, 0, 1))
        elseif get(Hydraulic_B_press) < get(Hydraulic_G_press) then-- G HYD is more powerful
            l_aileron_actual_speed = Math_lerp(no_hyd_spd, ailerons_speed, Math_clamp(get(Hydraulic_G_press), 0, 1450) / 1450)
            r_aileron_actual_speed = Math_lerp(no_hyd_spd, ailerons_speed, Math_clamp(get(Hydraulic_G_press), 0, 1450) / 1450)

            l_aileron_travel_target = Math_lerp(Math_lerp(25 , l_aileron_travel_target, Math_clamp(get(Hydraulic_G_press), 0, 1450) / 1450), 0, Math_clamp(get(IAS) / no_hyd_recenter_ias, 0, 1))
            r_aileron_travel_target = Math_lerp(Math_lerp(25 , r_aileron_travel_target, Math_clamp(get(Hydraulic_G_press), 0, 1450) / 1450), 0, Math_clamp(get(IAS) / no_hyd_recenter_ias, 0, 1))
        else--any other situation(both 0 or the same as each other)
            l_aileron_actual_speed = Math_lerp(no_hyd_spd, ailerons_speed, Math_clamp((get(Hydraulic_B_press) + get(Hydraulic_G_press)) / 2, 0, 1450) / 1450)
            r_aileron_actual_speed = Math_lerp(no_hyd_spd, ailerons_speed, Math_clamp((get(Hydraulic_B_press) + get(Hydraulic_G_press)) / 2, 0, 1450) / 1450)

            l_aileron_travel_target = Math_lerp(Math_lerp(25 , l_aileron_travel_target, Math_clamp((get(Hydraulic_B_press) + get(Hydraulic_G_press)) / 2, 0, 1450) / 1450), 0, Math_clamp(get(IAS) / no_hyd_recenter_ias, 0, 1))
            r_aileron_travel_target = Math_lerp(Math_lerp(25 , r_aileron_travel_target, Math_clamp((get(Hydraulic_B_press) + get(Hydraulic_G_press)) / 2, 0, 1450) / 1450), 0, Math_clamp(get(IAS) / no_hyd_recenter_ias, 0, 1))
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

    if ground_spoilers_mode == 2 then
        if has_florence_kit == true then
            l_aileron_travel_target = -25
            r_aileron_travel_target = -25
        end
    end

    --output to the surfaces
    set(Left_aileron, Set_linear_anim_value(get(Left_aileron),   l_aileron_travel_target, -25, 25, l_aileron_actual_speed))
    set(Right_aileron, Set_linear_anim_value(get(Right_aileron), r_aileron_travel_target, -25, 25, r_aileron_actual_speed))
end

--permanent variables
Spoilers_var_table = {
    l_spoilers_spdbrk_extention = {0, 0, 0, 0, 0},
    r_spoilers_spdbrk_extention = {0, 0, 0, 0, 0},
    l_spoilers_roll_extention = {0, 0, 0, 0, 0},
    r_spoilers_roll_extention = {0, 0, 0, 0, 0}
}

--ROLL SPOILERS & SPD BRAKES--
function Spoilers_control(lateral_input, spdbrk_input, ground_spoilers_mode, in_auto_flight, var_table)
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

    --spoiler        1 2 3 4 5
    --HYDs           G Y B Y G
    --SECs           3 3 1 1 2

    --DATAREFS FOR SURFACES
    local l_spoilers_datarefs = {Left_spoiler_1, Left_spoiler_1, Left_spoiler_1, Left_spoiler_1, Left_spoiler_1}
    local r_spoilers_datarefs = {Right_spoiler_1, Right_spoiler_1, Right_spoiler_1, Right_spoiler_1, Right_spoiler_1}

    local l_spoilers_hyd_sys_dataref = {Hydraulic_G_press, Hydraulic_Y_press, Hydraulic_B_press, Hydraulic_Y_press, Hydraulic_G_press}
    local r_spoilers_hyd_sys_dataref = {Hydraulic_G_press, Hydraulic_Y_press, Hydraulic_B_press, Hydraulic_Y_press, Hydraulic_G_press}

    local l_spoilers_flt_computer_dataref = {SEC_3_status, SEC_3_status, SEC_1_status, SEC_1_status, SEC_2_status}
    local r_spoilers_flt_computer_dataref = {SEC_3_status, SEC_3_status, SEC_1_status, SEC_1_status, SEC_2_status}

    --limit input range
    spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

    --properties
    local num_of_spoils_per_wing = 5

    local roll_spoilers_threshold = {0.1, 0.1, 0.3, 0.1, 0.1}--amount of sidestick deflection needed to trigger the roll spoilers

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

        --speed up ground spoilers deflection
        l_spoilers_spdbrk_spd = {20, 20, 20, 20, 20}
        r_spoilers_spdbrk_spd = {20, 20, 20, 20, 20}

        --on ground and slightly open spoiler 1 with speedbrake handle
        l_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
        r_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
    else
        l_spoilers_roll_max_def = {0, 25, 7, 25, 25}
        r_spoilers_roll_max_def = {0, 25, 7, 25, 25}
    end

    --detect if hydraulics power is avail to the surfaces then accordingly slow down the speed
    for i = 1, num_of_spoils_per_wing do
        --speedbrkaes
        l_spoilers_spdbrk_spd[i] = Math_rescale(0, 0, 1450, l_spoilers_spdbrk_spd[i], get(l_spoilers_hyd_sys_dataref[i]))
        r_spoilers_spdbrk_spd[i] = Math_rescale(0, 0, 1450, r_spoilers_spdbrk_spd[i], get(r_spoilers_hyd_sys_dataref[i]))
        --roll spoilers
        l_spoilers_roll_spd[i] = Math_rescale(0, 0, 1450, l_spoilers_roll_spd[i], get(l_spoilers_hyd_sys_dataref[i]))
        r_spoilers_roll_spd[i] = Math_rescale(0, 0, 1450, r_spoilers_roll_spd[i], get(r_spoilers_hyd_sys_dataref[i]))
    end

    --conditions
    local l_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
    local r_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}

    local l_spoilers_roll_targets = {0, 0, 0, 0, 0}
    local r_spoilers_roll_targets = {0, 0, 0, 0, 0}

    --DEFLECTION TARGET CALCULATION--
    for i = 1, num_of_spoils_per_wing do
        --speedbrakes
        l_spoilers_spdbrk_targets[i] = l_spoilers_spdbrk_max_def[i] * spdbrk_input
        r_spoilers_spdbrk_targets[i] = r_spoilers_spdbrk_max_def[i] * spdbrk_input
        --roll spoilers
        l_spoilers_roll_targets[i] = Math_rescale(roll_spoilers_threshold[i], 0, -1, l_spoilers_roll_max_def[i], lateral_input)
        r_spoilers_roll_targets[i] = Math_rescale(roll_spoilers_threshold[i], 0,  1, r_spoilers_roll_max_def[i], lateral_input)
    end

    --GROUND SPOILERS MODE--
    --0 = NOT EXTENDED
    --1 = PARCIAL EXTENTION
    --2 = FULL EXTENTION
    if ground_spoilers_mode == 1 then
        l_spoilers_spdbrk_targets = {10, 10, 10, 10, 10}
        r_spoilers_spdbrk_targets = {10, 10, 10, 10, 10}
    elseif ground_spoilers_mode == 2 then
        l_spoilers_spdbrk_targets = {40, 40, 40, 40, 40}
        r_spoilers_spdbrk_targets = {40, 40, 40, 40, 40}
    end

    --SPEEDBRAKES INHIBITION--
    if get(SEC_1_status) == 0 and get(SEC_3_status) == 0 then
        l_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
        r_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
    elseif get(Flaps_internal_config) == 5 then
        l_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
        r_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
    --lacking above MCT/ ELEV fail(inhibites 3, 4)/ alpha protection/ upon a.prot toga
    end

    --SECs position reset--
    for i = 1, num_of_spoils_per_wing do
        --speedbrakes position reset
        l_spoilers_spdbrk_targets[i] = l_spoilers_spdbrk_targets[i] * get(l_spoilers_flt_computer_dataref[i])
        r_spoilers_spdbrk_targets[i] = r_spoilers_spdbrk_targets[i] * get(r_spoilers_flt_computer_dataref[i])
        --roll spoilers position reset
        l_spoilers_roll_targets[i] = l_spoilers_roll_targets[i] * get(l_spoilers_flt_computer_dataref[i])
        r_spoilers_roll_targets[i] = r_spoilers_roll_targets[i] * get(r_spoilers_flt_computer_dataref[i])
    end

    --PRE-EXTENTION DEFECTION VALUE CALCULATION --> OUTPUT OF CALCULATED VALUE TO THE SURFACES--
    set(Speedbrakes_ratio, math.abs(lateral_input) + spdbrk_input)
    for i = 1, num_of_spoils_per_wing do
        --speedbrakes
        var_table.l_spoilers_spdbrk_extention[i] = Set_linear_anim_value(var_table.l_spoilers_spdbrk_extention[i], l_spoilers_spdbrk_targets[i], 0, l_spoilers_total_max_def[i], l_spoilers_spdbrk_spd[i])
        var_table.r_spoilers_spdbrk_extention[i] = Set_linear_anim_value(var_table.r_spoilers_spdbrk_extention[i], r_spoilers_spdbrk_targets[i], 0, r_spoilers_total_max_def[i], r_spoilers_spdbrk_spd[i])
        --roll spoilers
        var_table.l_spoilers_roll_extention[i] = Set_linear_anim_value(var_table.l_spoilers_roll_extention[i], l_spoilers_roll_targets[i], 0, l_spoilers_total_max_def[i], l_spoilers_roll_spd[i])
        var_table.r_spoilers_roll_extention[i] = Set_linear_anim_value(var_table.r_spoilers_roll_extention[i], l_spoilers_roll_targets[i], 0, r_spoilers_total_max_def[i], r_spoilers_roll_spd[i])

        --TOTAL SPOILERS OUTPUT TO THE SURFACES--
        --if any surface exceeds the max deflection limit the othere side would reduce deflection by the exceeded amount
        set(l_spoilers_datarefs[i], Math_clamp_higher(var_table.l_spoilers_spdbrk_extention[i] + var_table.l_spoilers_roll_extention[i], l_spoilers_total_max_def[i]) - Math_clamp_lower(var_table.r_spoilers_spdbrk_extention[i] + var_table.r_spoilers_roll_extention[i] - r_spoilers_total_max_def[i], 0))
        set(r_spoilers_datarefs[i], Math_clamp_higher(var_table.r_spoilers_spdbrk_extention[i] + var_table.r_spoilers_roll_extention[i], r_spoilers_total_max_def[i]) - Math_clamp_lower(var_table.l_spoilers_spdbrk_extention[i] + var_table.l_spoilers_roll_extention[i] - l_spoilers_total_max_def[i], 0))
    end
end