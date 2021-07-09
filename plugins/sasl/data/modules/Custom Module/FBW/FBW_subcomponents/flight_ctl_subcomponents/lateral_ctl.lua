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
local aileron_filter_data = {
    {cut_frequency = 3, x=0},   -- LEFT
    {cut_frequency = 3, x=0}    -- RIGHT
}

local ailerons_max_def = 25        -- in °/s
local ailerons_max_actuator = 21.5 -- in mm
local sin_ailerons_max_def = math.sin(math.rad(ailerons_max_def))
local aileron_curr_spd = {0,0}

-- Cache some functions to speed-up computation
local mabs  = math.abs
local masin = math.asin
local msin  = math.sin
local mdeg  = math.deg
local mexp  = math.exp
local mrad  = math.rad

local function aileron_model_deg_to_mm(deg)  -- Convert aileron deg to actuator mm
    deg = Math_clamp(deg, -ailerons_max_def, ailerons_max_def)
    return msin(mrad(deg)) / sin_ailerons_max_def * ailerons_max_actuator
end

local function aileron_model_mm_to_deg(mm)  -- Convert actuator mm to aileron deg
    mm = Math_clamp(mm, -ailerons_max_actuator, ailerons_max_actuator)
    return mdeg(masin(sin_ailerons_max_def * mm / ailerons_max_actuator))
end


local function aileron_model_spd(mm_target, mm_actual, ail_pos) -- Compute the maximum speed depending on the Drag forces and
                                                                -- the G forces. See the document on Discord for explanation
    local IAS = get(IAS)
    local A   = ail_pos
    local rho = get(Weather_Rho)
    local Cd  = 1
    local Aail= 1.016

    local Ad = Aail * msin(mrad(mabs(A)))
    local Fd = 0.5*rho * (IAS*0.514444)^2 * Cd * Ad

    local aero_forces = mabs(get(Flightmodel_aero_norm_forces) / 900 * Aail)

    local Ftot = aero_forces / 1e4

    if mabs(mm_target) > mabs(mm_actual) then   -- Add the drag forces in this case
        Ftot = Ftot + Fd / 1e4
    end

    local max_speed = 83.93358 - (2.031154/-0.8271113)*(1 - mexp(0.8271113*Ftot))

    return max_speed
end


local function compute_acceleration_space(vnow, vtarget, acceleration)  -- distance where to start decelerating
    local delta_time = (vtarget - vnow) / acceleration
    return (vnow + vtarget) / (2 * delta_time)
end

local function aileron_actuation(request_pos, which_one)   -- which one: 1: LEFT, 2: RIGHT

    local curr_pos    = which_one == 1 and get(Left_aileron) or get(Right_aileron)
    local curr_pos_mm = aileron_model_deg_to_mm(curr_pos)
    local req_pos_mm  = aileron_model_deg_to_mm(request_pos)
    
    -- 1: Compute the max speed
    local max_speed = aileron_model_spd(req_pos_mm, curr_pos_mm, curr_pos)

    -- 2: Perform a 3 Hz filter on the max speed change
    aileron_filter_data[which_one].x = max_speed
    local target_max_speed = mabs(low_pass_filter(aileron_filter_data[which_one]))

    -- 3: Rescale speed depending on HYD availability
    local max_hyd = math.max(get(Hydraulic_B_press), get(Hydraulic_G_press))
    local max_spd_aft_hyd = Math_rescale(0, 0, 3000, 89, max_hyd)

    -- 4: So, corrently compute pos/neg speed depending on the direction we have to go
    if curr_pos < request_pos then
        target_speed = math.min(max_spd_aft_hyd, target_max_speed)
    elseif curr_pos > request_pos then
        target_speed = -math.min(max_spd_aft_hyd, target_max_speed)
    else
        target_speed = 0
    end

    -- 5: Slow down the actuator near the target
    if target_speed ~= 0 and mabs(curr_pos-request_pos) < 10 then
        target_speed = target_speed * mabs(curr_pos-request_pos)/10
    end

    -- 6: Dampening if both systems avail
    if (get(Hydraulic_B_press) < 1400 or get(Hydraulic_G_press) < 1400) then
        -- If (at least) one actuator is failed, then we don't have dampening
        aileron_curr_spd[which_one] = target_speed
    else
        local A_aileron = 400
        aileron_curr_spd[which_one] = Set_linear_anim_value(aileron_curr_spd[which_one], target_speed, -100, 100, A_aileron)
    end
    
    -- 7: Failures (stuck)
     aileron_curr_spd[which_one] = aileron_curr_spd[which_one] * (1 - get(which_one == 1 and FAILURE_FCTL_LAIL or FAILURE_FCTL_RAIL))

    local ail_dataref = which_one == 1 and Left_aileron or Right_aileron

    -- 8: Finally compute actuator value and set the surface position
    if (get(Hydraulic_B_press) < 1400 and get(Hydraulic_G_press) < 1400) then
        -- No HYD at all
        -- Return to neutral depending on IAS (no hyd system)
        local pos = Math_rescale(0, ailerons_max_def, 100, 0, get(IAS))
        Set_dataref_linear_anim(ail_dataref, pos, -ailerons_max_def, ailerons_max_def, 20)
    else
        -- Normal situation
        local actuator_value = curr_pos_mm + aileron_curr_spd[which_one] * get(DELTA_TIME)  -- DO NOT use the set_anim_linear here: the speed can be negative!
        actuator_value = Math_clamp(actuator_value, -ailerons_max_actuator, ailerons_max_actuator)
        set(ail_dataref, aileron_model_mm_to_deg(actuator_value))
    end
end


function Ailerons_control(lateral_input, has_florence_kit, ground_spoilers_mode)
    --hyd source B or G (1450PSI)
    --reversion of flight computers: ELAC 1 --> 2
    --surface range -25 up +25 down, 10 degrees droop with flaps(calculated by ELAC 1/2)

    --properties

    local l_aileron_def_table = {
        {-1, -ailerons_max_def},
        {0,   10 * get(Flaps_deployed_angle) / 30},
        {1,   ailerons_max_def},
    }
    local r_aileron_def_table = {
        {-1,  ailerons_max_def},
        {0,   10 * get(Flaps_deployed_angle) / 30},
        {1,  -ailerons_max_def},
    }

    local l_aileron_travel_target = Table_interpolate(l_aileron_def_table, lateral_input)
    local r_aileron_travel_target = Table_interpolate(r_aileron_def_table, lateral_input)

    --TRAVEL TARGETS CALTULATION
    --ground spoilers
    if ground_spoilers_mode == 2 and get(FBW_total_control_law) == FBW_NORMAL_LAW then
        if has_florence_kit == true and get(Flaps_internal_config) ~= 0 and adirs_get_avg_pitch() < 2.5 then
            l_aileron_travel_target = -ailerons_max_def
            r_aileron_travel_target = -ailerons_max_def
        end
    end

    --detect ELAC failures and revert accordingly 1 --> 2
    if get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0 then
        l_aileron_travel_target = 0
        r_aileron_travel_target = 0
    end

    --output to the surfaces
    aileron_actuation(l_aileron_travel_target, 1)
    aileron_actuation(r_aileron_travel_target, 2)

end

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
        if get(L_elevator_avail) == 0 or get(R_elevator_avail) == 0 then
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
    if get(FBW_lateral_law) == FBW_DIRECT_LAW and (get(L_aileron_avail) == 1 or get(R_aileron_avail) == 1) then
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
