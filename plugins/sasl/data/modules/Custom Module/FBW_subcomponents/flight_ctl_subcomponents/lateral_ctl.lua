--AILERONS--
function Ailerons_control(lateral_input, has_florence_kit, ground_spoilers_mode)
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

    local l_aileron_travel_target = Math_clamp(ailerons_max_def *  lateral_input + 5 * get(Flaps_deployed_angle) / 40, -ailerons_max_def, ailerons_max_def)
    local r_aileron_travel_target = Math_clamp(ailerons_max_def * -lateral_input + 5 * get(Flaps_deployed_angle) / 40, -ailerons_max_def, ailerons_max_def)

    --SURFACE SPEED LOGIC--
    --hydralics power detection
    l_aileron_actual_speed = Math_rescale(0, no_hyd_spd, 1450, ailerons_speed, get(Hydraulic_B_press) + get(Hydraulic_G_press))
    r_aileron_actual_speed = Math_rescale(0, no_hyd_spd, 1450, ailerons_speed, get(Hydraulic_B_press) + get(Hydraulic_G_press))

    --detect surface failures
    l_aileron_actual_speed = l_aileron_actual_speed * (1 - get(FAILURE_FCTL_LAIL))
    r_aileron_actual_speed = r_aileron_actual_speed * (1 - get(FAILURE_FCTL_RAIL))

    --TRAVEL TARGETS CALTULATION
    --ground spoilers
    if ground_spoilers_mode == 2 then
        if has_florence_kit == true then
            l_aileron_travel_target = -ailerons_max_def
            r_aileron_travel_target = -ailerons_max_def
        end
    end

    --detect ELAC failures and revert accordingly 1 --> 2
    if get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0 then
        l_aileron_travel_target = 0
        r_aileron_travel_target = 0
    end

    --hydralics power detection-Both HYD not fully/ not working
    l_aileron_travel_target = Math_rescale(0, Math_rescale(0, ailerons_max_def, no_hyd_recenter_ias, -get(Alpha), get(IAS)), 1450, l_aileron_travel_target, get(Hydraulic_B_press) + get(Hydraulic_G_press))
    r_aileron_travel_target = Math_rescale(0, Math_rescale(0, ailerons_max_def, no_hyd_recenter_ias, -get(Alpha), get(IAS)), 1450, r_aileron_travel_target, get(Hydraulic_B_press) + get(Hydraulic_G_press))

    --output to the surfaces
    set(Left_aileron,  Set_linear_anim_value(get(Left_aileron),  l_aileron_travel_target, -ailerons_max_def, ailerons_max_def, l_aileron_actual_speed))
    set(Right_aileron, Set_linear_anim_value(get(Right_aileron), r_aileron_travel_target, -ailerons_max_def, ailerons_max_def, r_aileron_actual_speed))
end

--permanent variables
Spoilers_var_table = {
    l_spoilers_spdbrk_extention = {0, 0, 0, 0, 0},
    r_spoilers_spdbrk_extention = {0, 0, 0, 0, 0},
    l_spoilers_roll_extention = {0, 0, 0, 0, 0},
    r_spoilers_roll_extention = {0, 0, 0, 0, 0}
}

--ROLL SPOILERS & SPD BRAKES--
function Spoilers_control(lateral_input, spdbrk_input, ground_spoilers_mode, in_auto_flight, roll_in_direct_law, var_table)
    --spoilers 2 3 4 are speedbrakes(still rolls with ailerons, deflection is 25/ 25/ 25, [on ground spoiler 1 can be open up to 6 degreess for maintainance with the spdbrk handle])
    --spoilers 2 3 4 5 are roll spoilers(can roll up to 35 degrees, on ground full roll is 35/ 7/ 35/ 35, in air is 25/ 7/ 25/ 25 [although this rarely happens unless on ground])
    --spoilers 3 4 5 are roll spoilers if in direct law(in air max deflection is 7/ 25/ 25[if spoiler 4 has failed spoiler 3 takes over the roll])
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
    local l_spoilers_datarefs = {Left_spoiler_1, Left_spoiler_2, Left_spoiler_3, Left_spoiler_4, Left_spoiler_5}
    local r_spoilers_datarefs = {Right_spoiler_1, Right_spoiler_2, Right_spoiler_3, Right_spoiler_4, Right_spoiler_5}

    local l_spoilers_hyd_sys_dataref = {Hydraulic_G_press, Hydraulic_Y_press, Hydraulic_B_press, Hydraulic_Y_press, Hydraulic_G_press}
    local r_spoilers_hyd_sys_dataref = {Hydraulic_G_press, Hydraulic_Y_press, Hydraulic_B_press, Hydraulic_Y_press, Hydraulic_G_press}

    local l_spoilers_flt_computer_dataref = {SEC_3_status, SEC_3_status, SEC_1_status, SEC_1_status, SEC_2_status}
    local r_spoilers_flt_computer_dataref = {SEC_3_status, SEC_3_status, SEC_1_status, SEC_1_status, SEC_2_status}

    local l_spoilers_failure_dataref = {FAILURE_FCTL_LSPOIL_1, FAILURE_FCTL_LSPOIL_2, FAILURE_FCTL_LSPOIL_3, FAILURE_FCTL_LSPOIL_4, FAILURE_FCTL_LSPOIL_5}
    local r_spoilers_failure_dataref = {FAILURE_FCTL_RSPOIL_1, FAILURE_FCTL_RSPOIL_2, FAILURE_FCTL_RSPOIL_3, FAILURE_FCTL_RSPOIL_4, FAILURE_FCTL_RSPOIL_5}

    --limit input range
    spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

    --properties
    local num_of_spoils_per_wing = 5

    local roll_spoilers_threshold = {0.1, 0.1, 0.3, 0.1, 0.1}--amount of sidestick deflection needed to trigger the roll spoilers

    --speeds--
    local l_spoilers_total_max_def = {40, 40, 40, 40, 40}
    local r_spoilers_total_max_def = {40, 40, 40, 40, 40}
    local l_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
    local r_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
    local l_spoilers_roll_max_def = {0, 35, 7, 35, 35}
    local r_spoilers_roll_max_def = {0, 35, 7, 35, 35}

    local l_spoilers_spdbrk_max_ground_def = {6, 20, 40, 40, 0}
    local r_spoilers_spdbrk_max_ground_def = {6, 20, 40, 40, 0}
    local l_spoilers_spdbrk_max_air_def = {0, 25, 25, 25, 0}
    local r_spoilers_spdbrk_max_air_def = {0, 25, 25, 25, 0}

    local l_spoilers_spdbrk_spd = {5, 5, 5, 5, 5}
    local r_spoilers_spdbrk_spd = {5, 5, 5, 5, 5}
    local l_spoilers_roll_spd = {0, 40, 40, 40, 40}
    local r_spoilers_roll_spd = {0, 40, 40, 40, 40}

    local l_spoilers_spdbrk_ground_spd = {20, 20, 20, 20, 20}
    local r_spoilers_spdbrk_ground_spd = {20, 20, 20, 20, 20}
    local l_spoilers_spdbrk_air_spd = {5, 5, 5, 5, 5}
    local r_spoilers_spdbrk_air_spd = {5, 5, 5, 5, 5}
    local l_spoilers_spdbrk_high_spd_air_spd = {1, 1, 1, 1, 1}
    local r_spoilers_spdbrk_high_spd_air_spd = {1, 1, 1, 1, 1}

    --targets--
    local l_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
    local r_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}

    local l_spoilers_roll_targets = {0, 0, 0, 0, 0}
    local r_spoilers_roll_targets = {0, 0, 0, 0, 0}

    --SPOILERS & SPDBRAKES SPD CALCULATION------------------------------------------------------------------------
    if get(Aft_wheel_on_ground) == 1 then
        --speed up ground spoilers deflection
        l_spoilers_spdbrk_spd = l_spoilers_spdbrk_ground_spd
        r_spoilers_spdbrk_spd = r_spoilers_spdbrk_ground_spd

        --on ground and slightly open spoiler 1 with speedbrake handle
        l_spoilers_spdbrk_max_def = l_spoilers_spdbrk_max_ground_def
        r_spoilers_spdbrk_max_def = r_spoilers_spdbrk_max_ground_def
    else
        --slow down the spoilers for flight
        l_spoilers_spdbrk_spd = l_spoilers_spdbrk_air_spd
        r_spoilers_spdbrk_spd = r_spoilers_spdbrk_air_spd

        --adujust max in air deflection of the speedbrakes
        l_spoilers_spdbrk_max_def = l_spoilers_spdbrk_max_air_def
        r_spoilers_spdbrk_max_def = r_spoilers_spdbrk_max_air_def
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

    --FAILURE MANAGER--
    for i = 1, num_of_spoils_per_wing do
        l_spoilers_spdbrk_spd[i] = l_spoilers_spdbrk_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
        r_spoilers_spdbrk_spd[i] = r_spoilers_spdbrk_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
        l_spoilers_roll_spd[i] = l_spoilers_roll_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
        r_spoilers_roll_spd[i] = r_spoilers_roll_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
    end

    --SPOILERS & SPDBRAKES TARGET CALCULATION------------------------------------------------------------------------
    --DEFLECTION TARGET CALCULATION--
    for i = 1, num_of_spoils_per_wing do
        --speedbrakes
        l_spoilers_spdbrk_targets[i] = l_spoilers_spdbrk_max_def[i] * spdbrk_input
        r_spoilers_spdbrk_targets[i] = r_spoilers_spdbrk_max_def[i] * spdbrk_input
        --roll spoilers
        l_spoilers_roll_targets[i] = Math_rescale(-1, l_spoilers_roll_max_def[i], -roll_spoilers_threshold[i], 0, lateral_input)
        r_spoilers_roll_targets[i] = Math_rescale( roll_spoilers_threshold[i], 0,  1, r_spoilers_roll_max_def[i], lateral_input)
    end

    --SPEEDBRAKES INHIBITION--
    if get(Speedbrake_handle_ratio) >= 0 and get(Speedbrake_handle_ratio) <= 0.1 then
        set(Speedbrakes_inhibited, 0)
    end

    if get(Bypass_speedbrakes_inhibition) ~= 1 then
        if get(SEC_1_status) == 0 and get(SEC_3_status) == 0 then
            set(Speedbrakes_inhibited, 1)
        elseif get(Flaps_internal_config) == 4 or get(Flaps_internal_config) == 5 then
            set(Speedbrakes_inhibited, 1)
            --lacking above MCT/ ELEV fail(inhibites 3, 4)/ alpha protection/ upon a.prot toga [and restoring speedbrake avail by reseting the lever position]
        end
    end

    if get(Speedbrakes_inhibited) == 1 and get(Bypass_speedbrakes_inhibition) ~= 1 then
        l_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
        r_spoilers_spdbrk_targets = {0, 0, 0, 0, 0}
    end

    --GROUND SPOILERS MODE--
    --0 = NOT EXTENDED
    --1 = PARCIAL EXTENTION
    --2 = FULL EXTENTION
    if ground_spoilers_mode == 1 then
        l_spoilers_spdbrk_targets = {10, 10, 10, 10, 10}
        r_spoilers_spdbrk_targets = {10, 10, 10, 10, 10}
    elseif ground_spoilers_mode == 2 then
        l_spoilers_roll_targets = {0, 0, 0, 0, 0}
        r_spoilers_roll_targets = {0, 0, 0, 0, 0}
        l_spoilers_spdbrk_targets = {40, 40, 40, 40, 40}
        r_spoilers_spdbrk_targets = {40, 40, 40, 40, 40}
    end

    --if the aircraft is in roll direct law change the roll spoiler deflections to limit roll rate
    if roll_in_direct_law then
        if get(L_spoiler_4_avail) == 1 then
            l_spoilers_roll_targets[1] = 0
            l_spoilers_roll_targets[2] = 0
            l_spoilers_roll_targets[3] = 0
        else
            l_spoilers_roll_targets[1] = 0
            l_spoilers_roll_targets[2] = 0
            l_spoilers_roll_targets[4] = 0
        end
        if get(R_spoiler_4_avail) == 1 then
            r_spoilers_roll_targets[1] = 0
            r_spoilers_roll_targets[2] = 0
            r_spoilers_roll_targets[3] = 0
        else
            r_spoilers_roll_targets[1] = 0
            r_spoilers_roll_targets[2] = 0
            r_spoilers_roll_targets[4] = 0
        end
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

    --reduce speedbrakes retraction speeds in high speed conditions
    if (get(PFD_Capt_IAS) >= 315 or get(PFD_Fo_IAS) >= 315 or get(Capt_Mach) >= 0.75 or get(Fo_Mach) >= 0.75) and in_auto_flight then
        --check if any spoilers are retracting and slow down accordingly
        for i = 1, num_of_spoils_per_wing do
            if l_spoilers_spdbrk_targets[i] < get(l_spoilers_datarefs[i]) then
                r_spoilers_spdbrk_spd[i] = l_spoilers_spdbrk_high_spd_air_spd[i]
            end
            if r_spoilers_spdbrk_targets[i] < get(r_spoilers_datarefs[i])then
                r_spoilers_spdbrk_spd[i] = r_spoilers_spdbrk_high_spd_air_spd[i]
            end
        end
    end

    --PRE-EXTENTION DEFECTION VALUE CALCULATION --> OUTPUT OF CALCULATED VALUE TO THE SURFACES--
    set(Speedbrakes_ratio, math.abs(lateral_input) + spdbrk_input)
    for i = 1, num_of_spoils_per_wing do
        --speedbrakes
        var_table.l_spoilers_spdbrk_extention[i] = Set_linear_anim_value(var_table.l_spoilers_spdbrk_extention[i], l_spoilers_spdbrk_targets[i], 0, l_spoilers_total_max_def[i], l_spoilers_spdbrk_spd[i])
        var_table.r_spoilers_spdbrk_extention[i] = Set_linear_anim_value(var_table.r_spoilers_spdbrk_extention[i], r_spoilers_spdbrk_targets[i], 0, r_spoilers_total_max_def[i], r_spoilers_spdbrk_spd[i])
        --roll spoilers
        var_table.l_spoilers_roll_extention[i] = Set_linear_anim_value(var_table.l_spoilers_roll_extention[i], l_spoilers_roll_targets[i], 0, l_spoilers_total_max_def[i], l_spoilers_roll_spd[i])
        var_table.r_spoilers_roll_extention[i] = Set_linear_anim_value(var_table.r_spoilers_roll_extention[i], r_spoilers_roll_targets[i], 0, r_spoilers_total_max_def[i], r_spoilers_roll_spd[i])

        --TOTAL SPOILERS OUTPUT TO THE SURFACES--
        --if any surface exceeds the max deflection limit the othere side would reduce deflection by the exceeded amount
        set(l_spoilers_datarefs[i], Math_clamp_higher(var_table.l_spoilers_spdbrk_extention[i] + var_table.l_spoilers_roll_extention[i], l_spoilers_total_max_def[i]) - Math_clamp_lower(var_table.r_spoilers_spdbrk_extention[i] + var_table.r_spoilers_roll_extention[i] - r_spoilers_total_max_def[i], 0))
        set(r_spoilers_datarefs[i], Math_clamp_higher(var_table.r_spoilers_spdbrk_extention[i] + var_table.r_spoilers_roll_extention[i], r_spoilers_total_max_def[i]) - Math_clamp_lower(var_table.l_spoilers_spdbrk_extention[i] + var_table.l_spoilers_roll_extention[i] - l_spoilers_total_max_def[i], 0))
    end
end