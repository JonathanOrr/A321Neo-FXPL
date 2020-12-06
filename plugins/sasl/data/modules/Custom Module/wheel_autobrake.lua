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
include('constants.lua')

local AUTOBRK_OFF = 0
local AUTOBRK_LOW = 1
local AUTOBRK_MED = 2
local AUTOBRK_MAX = 3

local LO_DECEL_MSEC  = 1.7  -- m/s^2 of deceleration to maintain
local MED_DECEL_MSEC = 3    -- m/s^2 of deceleration to maintain
local LO_DELAY_SEC   = 4    -- Delay from the spoiler deploymen to the activation of autobrake
local MED_DELAY_SEC  = 2    -- Delay from the spoiler deploymen to the activation of autobrake

local speedbrk_deployed_at = 0

local pid_array = {
            P_gain = 0.1,
            I_gain = 0.01,
            D_gain = 0,
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

local function update_ab_datarefs()
    
    pb_set(PB.mip.autobrake_LO,  get(Wheel_autobrake_status) == AUTOBRK_LOW, false)
    pb_set(PB.mip.autobrake_MED, get(Wheel_autobrake_status) == AUTOBRK_MED, false)
    pb_set(PB.mip.autobrake_MAX, get(Wheel_autobrake_status) == AUTOBRK_MAX, false)

end

local function is_autobrake_braking()

    if get(SEC_1_status) + get(SEC_2_status) + get(SEC_3_status) < 2 then
        return false    -- Cannot autobrake if at least 2 sec available
    end
    
    if get(Wheel_autobrake_status) == AUTOBRK_MAX then
        return get(All_on_ground) == 1 and get(IAS) > 40 and get(Speedbrakes_ratio) > 0.5
    end
    
    if get(All_on_ground) == 1 and speedbrk_deployed_at == 0 and get(Speedbrakes_ratio) > 0.5 then
        speedbrk_deployed_at = get(TIME)
    elseif get(Speedbrakes_ratio) < 0.5 then
        speedbrk_deployed_at = 0
    end
    
    if get(Wheel_autobrake_status) == AUTOBRK_MED then
        return get(All_on_ground) == 1 and get(IAS) > 0.1 and speedbrk_deployed_at ~=0 and get(TIME) - speedbrk_deployed_at > MED_DELAY_SEC
    end

    if get(Wheel_autobrake_status) == AUTOBRK_LOW then
        return get(All_on_ground) == 1 and get(IAS) > 0.1 and speedbrk_deployed_at ~=0 and get(TIME) - speedbrk_deployed_at > LOW_DELAY_SEC
    end
    
    return false -- This should not happen
end

local function brake_pid(force)

    local set_point = force == AUTOBRK_MID and MED_DECEL_MSEC or LO_DECEL_MSEC
    

end

function update_autobrake_actuator()

    set(Wheel_autobrake_braking, 0)

    if is_autobrake_braking() then
        if get(Wheel_autobrake_status) == AUTOBRK_MAX then
            set(Wheel_autobrake_braking, 1)
        elseif get(Wheel_autobrake_status) == AUTOBRK_MID then
            set(Wheel_autobrake_braking, brake_pid(AUTOBRK_MID))
        elseif get(Wheel_autobrake_status) == AUTOBRK_LOW then
            set(Wheel_autobrake_braking, brake_pid(AUTOBRK_LOW))
        end
    end

end

function update_autobrake()

    update_ab_datarefs()
    update_autobrake_actuator()

end
