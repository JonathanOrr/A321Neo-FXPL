-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: lateral_ctl.lua
-- Short description: Lateral control functions
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- AILERONS
-------------------------------------------------------------------------------

--permanent variables
Spoilers_obj = {
    num_of_spoils_per_wing = 5,
    l_spoilers_spdbrk_max_air_def = {0, 25, 25, 25, 0},
    r_spoilers_spdbrk_max_air_def = {0, 25, 25, 25, 0},
    l_spoilers_spdbrk_max_ground_def = {6, 20, 40, 40, 0},
    r_spoilers_spdbrk_max_ground_def = {6, 20, 40, 40, 0},
    l_spoilers_datarefs = {Left_spoiler_1,  Left_spoiler_2,  Left_spoiler_3,  Left_spoiler_4,  Left_spoiler_5},
    r_spoilers_datarefs = {Right_spoiler_1, Right_spoiler_2, Right_spoiler_3, Right_spoiler_4, Right_spoiler_5},

    Get_cmded_spdbrk_def = function (spdbrk_input)
        local l_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
        local r_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
        spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

        if get(Aft_wheel_on_ground) == 1 then
            --on ground and slightly open spoiler 1 with speedbrake handle
            l_spoilers_spdbrk_max_def = Spoilers_obj.l_spoilers_spdbrk_max_ground_def
            r_spoilers_spdbrk_max_def = Spoilers_obj.r_spoilers_spdbrk_max_ground_def
        else
            --adujust max in air deflection of the speedbrakes
            l_spoilers_spdbrk_max_def = Spoilers_obj.l_spoilers_spdbrk_max_air_def
            r_spoilers_spdbrk_max_def = Spoilers_obj.r_spoilers_spdbrk_max_air_def
        end

        local total_cmded_def = 0
        for i = 1, Spoilers_obj.num_of_spoils_per_wing do
            total_cmded_def = total_cmded_def + l_spoilers_spdbrk_max_def[i] * spdbrk_input
            total_cmded_def = total_cmded_def + r_spoilers_spdbrk_max_def[i] * spdbrk_input
        end

        return total_cmded_def
    end,

    Get_curr_spdbrk_def = function ()
        local total_curr_def = 0
        for i = 1, Spoilers_obj.num_of_spoils_per_wing do
            total_curr_def = total_curr_def + get(L_speed_brakes_extension, i)
            total_curr_def = total_curr_def + get(R_speed_brakes_extension, i)
        end

        return total_curr_def
    end,
}

-------------------------------------------------------------------------------
-- ROLL SPOILERS & SPD BRAKES
-------------------------------------------------------------------------------
function Spoilers_control(lateral_input, spdbrk_input, ground_spoilers_mode, in_auto_flight, var_table)
    --during a touch and go one of the thrust levers has to be advanced beyond 20 degrees to disarm the spoilers

    --spoiler 1 2 3 4 5
    --HYD     G Y B Y G
    --SEC     3 3 1 1 2

    --DATAREFS FOR SURFACES
    local l_spoilers_hyd_sys_dataref = {Hydraulic_G_press, Hydraulic_Y_press, Hydraulic_B_press, Hydraulic_Y_press, Hydraulic_G_press}
    local r_spoilers_hyd_sys_dataref = {Hydraulic_G_press, Hydraulic_Y_press, Hydraulic_B_press, Hydraulic_Y_press, Hydraulic_G_press}

    local l_spoilers_flt_computer_dataref = {SEC_3_status, SEC_3_status, SEC_1_status, SEC_1_status, SEC_2_status}
    local r_spoilers_flt_computer_dataref = {SEC_3_status, SEC_3_status, SEC_1_status, SEC_1_status, SEC_2_status}

    local l_spoilers_failure_dataref = {FAILURE_FCTL_LSPOIL_1, FAILURE_FCTL_LSPOIL_2, FAILURE_FCTL_LSPOIL_3, FAILURE_FCTL_LSPOIL_4, FAILURE_FCTL_LSPOIL_5}
    local r_spoilers_failure_dataref = {FAILURE_FCTL_RSPOIL_1, FAILURE_FCTL_RSPOIL_2, FAILURE_FCTL_RSPOIL_3, FAILURE_FCTL_RSPOIL_4, FAILURE_FCTL_RSPOIL_5}

    --limit input range
    spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

    --properties
    local roll_spoilers_threshold = {0.1, 0.1, 0.3, 0.1, 0.1}--amount of sidestick deflection needed to trigger the roll spoilers

    --speeds--
    local l_spoilers_total_max_def = {40, 40, 40, 40, 40}
    local r_spoilers_total_max_def = {40, 40, 40, 40, 40}
    local l_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
    local r_spoilers_spdbrk_max_def = {6, 20, 40, 40, 0}
    local l_spoilers_roll_max_def = {0, 35, 7, 35, 35}
    local r_spoilers_roll_max_def = {0, 35, 7, 35, 35}


    local l_spoilers_spdbrk_spd = {5, 5, 5, 5, 5}
    local r_spoilers_spdbrk_spd = {5, 5, 5, 5, 5}
    local l_spoilers_roll_spd = {0, 40, 40, 40, 40}
    local r_spoilers_roll_spd = {0, 40, 40, 40, 40}

    local l_spoilers_spdbrk_ground_spd = {15, 15, 15, 15, 15}
    local r_spoilers_spdbrk_ground_spd = {15, 15, 15, 15, 15}
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
        l_spoilers_spdbrk_max_def = var_table.l_spoilers_spdbrk_max_ground_def
        r_spoilers_spdbrk_max_def = var_table.r_spoilers_spdbrk_max_ground_def
    else
        --slow down the spoilers for flight
        l_spoilers_spdbrk_spd = l_spoilers_spdbrk_air_spd
        r_spoilers_spdbrk_spd = r_spoilers_spdbrk_air_spd

        --adujust max in air deflection of the speedbrakes
        l_spoilers_spdbrk_max_def = var_table.l_spoilers_spdbrk_max_air_def
        r_spoilers_spdbrk_max_def = var_table.r_spoilers_spdbrk_max_air_def
    end

    --detect if hydraulics power is avail to the surfaces then accordingly slow down the speed
    for i = 1, var_table.num_of_spoils_per_wing do
        --speedbrkaes
        l_spoilers_spdbrk_spd[i] = Math_rescale(0, 0, 1450, l_spoilers_spdbrk_spd[i], get(l_spoilers_hyd_sys_dataref[i]))
        r_spoilers_spdbrk_spd[i] = Math_rescale(0, 0, 1450, r_spoilers_spdbrk_spd[i], get(r_spoilers_hyd_sys_dataref[i]))
        --roll spoilers
        l_spoilers_roll_spd[i] = Math_rescale(0, 0, 1450, l_spoilers_roll_spd[i], get(l_spoilers_hyd_sys_dataref[i]))
        r_spoilers_roll_spd[i] = Math_rescale(0, 0, 1450, r_spoilers_roll_spd[i], get(r_spoilers_hyd_sys_dataref[i]))
    end

    --FAILURE MANAGER--
    for i = 1, var_table.num_of_spoils_per_wing do
        l_spoilers_spdbrk_spd[i] = l_spoilers_spdbrk_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
        r_spoilers_spdbrk_spd[i] = r_spoilers_spdbrk_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
        l_spoilers_roll_spd[i] = l_spoilers_roll_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
        r_spoilers_roll_spd[i] = r_spoilers_roll_spd[i] * (1 - get(l_spoilers_failure_dataref[i])) * (1 - get(r_spoilers_failure_dataref[i]))
    end

    --SPOILERS & SPDBRAKES TARGET CALCULATION------------------------------------------------------------------------
    --DEFLECTION TARGET CALCULATION--
    for i = 1, var_table.num_of_spoils_per_wing do
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

    --lacking upon a.prot toga [and restoring speedbrake avail by reseting the lever position]
    if get(Bypass_speedbrakes_inhibition) ~= 1 then
        if get(SEC_1_status) == 0 and get(SEC_3_status) == 0 then
            set(Speedbrakes_inhibited, 1)
        end
        if not FBW.fctl.surfaces.elev.L.controlled or not FBW.fctl.surfaces.elev.R.controlled then
            set(Speedbrakes_inhibited, 1)
        end
        if get(FBW_lateral_law) == FBW_NORMAL_LAW and adirs_get_avg_aoa() > get(Aprot_AoA) - 1 then
            set(Speedbrakes_inhibited, 1)
        end
        if get(Flaps_internal_config) >= 4 then
            set(Speedbrakes_inhibited, 1)
        end
        if get(Cockpit_throttle_lever_L) >= THR_MCT_START or get(Cockpit_throttle_lever_R) >= THR_MCT_START then
            set(Speedbrakes_inhibited, 1)
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
    if get(FBW_lateral_law) == FBW_DIRECT_LAW and (FBW.fctl.surfaces.ail.L.controlled or FBW.fctl.surfaces.ail.R.controlled) then
        if FBW.fctl.surfaces.splr.L[4].controlled then
            l_spoilers_roll_targets[1] = 0
            l_spoilers_roll_targets[2] = 0
            l_spoilers_roll_targets[3] = 0
        else
            l_spoilers_roll_targets[1] = 0
            l_spoilers_roll_targets[2] = 0
            l_spoilers_roll_targets[4] = 0
        end
        if FBW.fctl.surfaces.splr.R[4].controlled then
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
    for i = 1, var_table.num_of_spoils_per_wing do
        --speedbrakes position reset
        l_spoilers_spdbrk_targets[i] = l_spoilers_spdbrk_targets[i] * get(l_spoilers_flt_computer_dataref[i])
        r_spoilers_spdbrk_targets[i] = r_spoilers_spdbrk_targets[i] * get(r_spoilers_flt_computer_dataref[i])
        --roll spoilers position reset
        l_spoilers_roll_targets[i] = l_spoilers_roll_targets[i] * get(l_spoilers_flt_computer_dataref[i])
        r_spoilers_roll_targets[i] = r_spoilers_roll_targets[i] * get(r_spoilers_flt_computer_dataref[i])
    end

    --reduce speedbrakes retraction speeds in high speed conditions
    if (adirs_get_avg_ias()>= 315 or adirs_get_avg_mach() >= 0.75) and in_auto_flight then
        --check if any spoilers are retracting and slow down accordingly
        for i = 1, var_table.num_of_spoils_per_wing do
            if l_spoilers_spdbrk_targets[i] < get(var_table.l_spoilers_datarefs[i]) then
                r_spoilers_spdbrk_spd[i] = l_spoilers_spdbrk_high_spd_air_spd[i]
            end
            if r_spoilers_spdbrk_targets[i] < get(var_table.r_spoilers_datarefs[i])then
                r_spoilers_spdbrk_spd[i] = r_spoilers_spdbrk_high_spd_air_spd[i]
            end
        end
    end

    --PRE-EXTENTION DEFECTION VALUE CALCULATION --> OUTPUT OF CALCULATED VALUE TO THE SURFACES--
    set(Speedbrakes_ratio, math.abs(lateral_input) + spdbrk_input)
    for i = 1, var_table.num_of_spoils_per_wing do
        --speedbrakes
        set(L_speed_brakes_extension, Set_anim_value_linear_range(get(L_speed_brakes_extension, i), l_spoilers_spdbrk_targets[i], 0, l_spoilers_total_max_def[i], l_spoilers_spdbrk_spd[i], 5), i)
        set(R_speed_brakes_extension, Set_anim_value_linear_range(get(R_speed_brakes_extension, i), r_spoilers_spdbrk_targets[i], 0, r_spoilers_total_max_def[i], r_spoilers_spdbrk_spd[i], 5), i)
        --roll spoilers
        set(L_roll_spoiler_extension, Set_anim_value_linear_range(get(L_roll_spoiler_extension, i), l_spoilers_roll_targets[i], 0, l_spoilers_total_max_def[i], l_spoilers_roll_spd[i], 5), i)
        set(R_roll_spoiler_extension, Set_anim_value_linear_range(get(R_roll_spoiler_extension, i), r_spoilers_roll_targets[i], 0, r_spoilers_total_max_def[i], r_spoilers_roll_spd[i], 5), i)

        --TOTAL SPOILERS OUTPUT TO THE SURFACES--
        --if any surface exceeds the max deflection limit the othere side would reduce deflection by the exceeded amount
        set(var_table.l_spoilers_datarefs[i], Math_clamp_higher(get(L_speed_brakes_extension, i) + get(L_roll_spoiler_extension, i), l_spoilers_total_max_def[i]) - Math_clamp_lower(get(R_speed_brakes_extension, i) + get(R_roll_spoiler_extension, i) - r_spoilers_total_max_def[i], 0))
        set(var_table.r_spoilers_datarefs[i], Math_clamp_higher(get(R_speed_brakes_extension, i) + get(R_roll_spoiler_extension, i), r_spoilers_total_max_def[i]) - Math_clamp_lower(get(L_speed_brakes_extension, i) + get(L_roll_spoiler_extension, i) - l_spoilers_total_max_def[i], 0))
    end
end
