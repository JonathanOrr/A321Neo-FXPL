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
-- File: wheel_autobrake.lua 
-- Short description: Autobrake logic
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('PID.lua')

local AUTOBRK_OFF = 0
local AUTOBRK_LOW = 1
local AUTOBRK_MED = 2
local AUTOBRK_MAX = 3

local LO_DECEL_MSEC  = 1.7  -- m/s^2 of deceleration to maintain
local MED_DECEL_MSEC = 3    -- m/s^2 of deceleration to maintain
local LO_DELAY_SEC   = 4    -- Delay from the spoiler deploymen to the activation of autobrake
local MED_DELAY_SEC  = 2    -- Delay from the spoiler deploymen to the activation of autobrake

local speedbrk_deployed_at = 0

local avg_gload        = 0
local avg_gload_n      = 0
local avg_gload_stable = 0

local prev_speed = 0
local curr_decel = 0

local after_takeoff_cond = false
local touched_down = false

local i_was_braking = false

local pid_array = {
            P_gain = 0.005,
            I_gain = 0.06,
            D_gain = 0.0001,
            B_gain = 1,
            Actual_output = 0,
            Desired_output = 0,
            Integral_sum = 0,
            Current_error = 0,
            Min_out = 0,
            Max_out = 1
    }

----------------------------------------------------------------------------------------------------
-- Command registering and handlers
----------------------------------------------------------------------------------------------------

sasl.registerCommandHandler (Toggle_lo_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_LOW)  end)
sasl.registerCommandHandler (Toggle_med_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_MED) end)
sasl.registerCommandHandler (Toggle_max_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_MAX) end)
-- Airbus TCA support
sasl.registerCommandHandler (TCA_disable_autobrake, 0, function(phase) set(Wheel_autobrake_status, AUTOBRK_OFF) end)


function Toggle_autobrake(phase, value)
	if phase == SASL_COMMAND_BEGIN then
		if get(Wheel_autobrake_status) ~= value then
		    if value ~= AUTOBRK_MAX or get(All_on_ground) == 1 then -- MAX can be set only on ground
    			set(Wheel_autobrake_status, value)
            end
		else
			set(Wheel_autobrake_status, AUTOBRK_OFF)
		end
    end
end

local function update_deleceration()
    if get(DELTA_TIME) == 0 then
        return
    end
    curr_decel = (prev_speed - get(Ground_speed_ms)) / get(DELTA_TIME)
    prev_speed = get(Ground_speed_ms)
end

local function update_ab_datarefs()
    
    avg_gload        = avg_gload + curr_decel
    avg_gload_n      = avg_gload_n + 1
    
    if avg_gload_n == 10 then
        avg_gload_stable = avg_gload / avg_gload_n
        avg_gload = 0
        avg_gload_n = 0
    end

    if get(Either_Aft_on_ground) == 1 then
        touched_down = true
    end

    if touched_down and get(Capt_ra_alt_ft) > 100 then
        if not after_takeoff_cond then
            after_takeoff_cond = true
            set(Wheel_autobrake_status, AUTOBRK_OFF)
        end
        touched_down = false
    else
        after_takeoff_cond = false
    end
    
    local lo_decel_cond = get(Wheel_autobrake_status) == AUTOBRK_LOW and get(Wheel_autobrake_braking) > 0 and avg_gload_stable > 0.8 * LO_DECEL_MSEC
    pb_set(PB.mip.autobrake_LO,  get(Wheel_autobrake_status) == AUTOBRK_LOW, lo_decel_cond)

    local med_decel_cond = get(Wheel_autobrake_status) == AUTOBRK_MED and get(Wheel_autobrake_braking) > 0 and avg_gload_stable > 0.8 * MED_DECEL_MSEC
    pb_set(PB.mip.autobrake_MED, get(Wheel_autobrake_status) == AUTOBRK_MED, med_decel_cond)

    local max_decel_cond = get(Wheel_autobrake_status) == AUTOBRK_MAX and (get(Wheel_autobrake_braking) >= 0.8*0.56)
    pb_set(PB.mip.autobrake_MAX, get(Wheel_autobrake_status) == AUTOBRK_MAX, max_decel_cond)

    set(Wheel_autobrake_is_in_decel, (lo_decel_cond or med_decel_cond or max_decel_cond) and 1 or 0)

end

local function is_autobrake_braking()

    if get(SEC_1_status) + get(SEC_2_status) < 2 then
        return false    -- Cannot autobrake if at least 2 sec available
    end
    
    if get(FAILURE_GEAR_AUTOBRAKES) == 1 then
        return false -- Cannot autobrake if failure occurred
    end
    
    if get(Brakes_mode) > 1 then
        return false
    end
    
    if get(Wheel_autobrake_status) == AUTOBRK_MAX then
        return get(Either_Aft_on_ground) == 1 and get(Ground_speed_kts) > 40 and get(Ground_spoilers_mode) > 0
    end
    
    if get(Either_Aft_on_ground) == 1 and speedbrk_deployed_at == 0 and get(Ground_spoilers_mode) > 0 then
        speedbrk_deployed_at = get(TIME)
    elseif get(Ground_spoilers_mode) == 0 then
        speedbrk_deployed_at = 0
    end
    
    if get(Wheel_autobrake_status) == AUTOBRK_MED then
        return get(Either_Aft_on_ground) == 1 and get(Ground_speed_kts) > 5 and speedbrk_deployed_at ~=0 and get(TIME) - speedbrk_deployed_at > MED_DELAY_SEC
    end

    if get(Wheel_autobrake_status) == AUTOBRK_LOW then
        return get(Either_Aft_on_ground) == 1 and get(Ground_speed_kts) > 5 and speedbrk_deployed_at ~=0 and get(TIME) - speedbrk_deployed_at > LO_DELAY_SEC
    end
   
    return false -- This should not happen
end

local function brake_pid(force)

    local set_point = force == AUTOBRK_MED and MED_DECEL_MSEC or LO_DECEL_MSEC
    
    local curr_err  = set_point - curr_decel
    local u = SSS_PID_BP(pid_array, curr_err)
    pid_array.Actual_output = Math_clamp(u, 0, 0.56)

    return pid_array.Actual_output
    
end

function update_autobrake_actuator()

    if is_autobrake_braking() then
        i_was_braking = true
        if get(Wheel_autobrake_status) == AUTOBRK_MAX then
            set(Wheel_autobrake_braking, 1)
        elseif get(Wheel_autobrake_status) == AUTOBRK_MED then
            set(Wheel_autobrake_braking, brake_pid(AUTOBRK_MED))
        elseif get(Wheel_autobrake_status) == AUTOBRK_LOW then
            set(Wheel_autobrake_braking, brake_pid(AUTOBRK_LOW))
        end
    elseif i_was_braking then
        set(Wheel_autobrake_status, AUTOBRK_OFF) 
        i_was_braking = false
    else
        Set_dataref_linear_anim(Wheel_autobrake_braking, 0, 0, 1, 1)
    end

end

function update_autobrake()

    update_deleceration()
    update_ab_datarefs()
    update_autobrake_actuator()

end
