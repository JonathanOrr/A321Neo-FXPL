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
-- File: wheel.lua 
-- Short description: Wheels and brakes management
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local AUTOBRK_MAX = 0
local AUTOBRK_OFF = 1
local AUTOBRK_LOW = 2
local AUTOBRK_MID = 4

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local antiskid_and_ns_switch = true -- Status of the ANTI-SKID and N/S switch

local left_brakes_temp_no_delay = 10
local right_brakes_temp_no_delay = 10
local left_tire_psi_no_delay = 210
local right_tire_psi_no_delay = 210

--sim dataref
local front_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[0]")
local left_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[1]")
local right_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[2]")

----------------------------------------------------------------------------------------------------
-- Command registering and handlers
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (Toggle_brake_fan, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Brakes_fan, 1 - get(Brakes_fan))
    end
end)

sasl.registerCommandHandler (Toggle_antiskid_ns, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        antiskid_and_ns_switch = not antiskid_and_ns_switch
    end
end)

sasl.registerCommandHandler (Toggle_lo_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_MIN)  end)

sasl.registerCommandHandler (Toggle_med_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_MED) end)

sasl.registerCommandHandler (Toggle_max_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_MAX) end)

function Toggle_autobrake(phase, value)
	if phase == SASL_COMMAND_BEGIN then
		if get(Autobrakes_sim) ~= value then
		    if value ~= AUTOBRK_MAX or get(All_on_ground) == 1 then -- MAX can be set only on ground
    			set(Autobrakes_sim, value)
            end
		else
			set(Autobrakes_sim, 1)
			if get(IAS) > 55 then
				set(Cockpit_parkbrake_ratio, 0)
			end
		end
    end
end

----------------------------------------------------------------------------------------------------
-- Main code
----------------------------------------------------------------------------------------------------

local function update_gear_status()
	set(Aft_wheel_on_ground, math.floor((get(left_gear_on_ground) + get(right_gear_on_ground))/2))
    set(All_on_ground, math.floor((get(front_gear_on_ground) + get(left_gear_on_ground) + get(right_gear_on_ground))/3))
    if get(front_gear_on_ground) == 1 or get(left_gear_on_ground) == 1 or get(right_gear_on_ground) == 1 then
        set(Any_wheel_on_ground, 1)
    else
        set(Any_wheel_on_ground, 0)
    end
end

local function update_pb_lights()
	--update Brake fan button states follwing 00, 01, 10, 11
	if get(Brakes_fan) == 0 then
		if (get(Left_brakes_temp) + get(Right_brakes_temp)) / 2 < 400 then
			set(Brake_fan_button_state, 0)--00
		else
			set(Brake_fan_button_state, 2)--10
		end
	else
		if (get(Left_brakes_temp) + get(Right_brakes_temp)) / 2 < 400 then
			set(Brake_fan_button_state, 1)--01
		else
			set(Brake_fan_button_state, 3)--11
		end
	end

	set(Autobrakes_lo_button_state, 0) --00
	set(Autobrakes_med_button_state, 0)--00
	set(Autobrakes_max_button_state, 0)--00
	set(Autobrakes, 0)
	
	--update autobrake button status follwing 00, 01, 10, 11
	if get(Autobrakes_sim) == AUTOBRK_MAX then
		set(Autobrakes_max_button_state, 1)--01
		set(Autobrakes, 3)
		if get(Cockpit_parkbrake_ratio) > 0 and get(IAS) > 55 and get(Any_wheel_on_ground) == 1 then
			set(Autobrakes_lo_button_state, 2)--10
			set(Autobrakes, 3)
		end
	else
		if get(Autobrakes_sim) > 1 then
			set(Autobrakes_max_button_state, 0)--00
			--lo autobrake states
			if get(Autobrakes_sim) == 2 then
				set(Autobrakes_lo_button_state, 1)--01
				set(Autobrakes, 1)
				if get(Cockpit_parkbrake_ratio) > 0 and get(IAS) > 55 and get(Any_wheel_on_ground) == 1 then
					set(Autobrakes_lo_button_state, 2)--10
					set(Autobrakes, 1)
				end
			else
				set(Autobrakes_lo_button_state, 0)--00
				set(Autobrakes, 0)
			end
			--med autobrake states
			if get(Autobrakes_sim) == 4 then
				set(Autobrakes_med_button_state, 1)--01
				set(Autobrakes, 2)
				if get(Cockpit_parkbrake_ratio) > 0 and get(IAS) > 55 and get(Any_wheel_on_ground) == 1 then
					set(Autobrakes_med_button_state, 2)--10
					set(Autobrakes, 2)
				end
			else
				set(Autobrakes_med_button_state, 0)--00
				set(Autobrakes, 0)
			end
		else
			set(Autobrakes_lo_button_state, 0)--00
			set(Autobrakes_med_button_state, 0)--00
		end
	end
	
end

local function update_brake_temps()

	if get(Aft_wheel_on_ground) == 1 then
		if get(Actual_brake_ratio) >  0 then
			left_brakes_temp_no_delay = left_brakes_temp_no_delay + (get(Actual_brake_ratio) * ((0.05 * get(Ground_speed_kts)) ^ 1.975) * get(DELTA_TIME))
			right_brakes_temp_no_delay = right_brakes_temp_no_delay + (get(Actual_brake_ratio) * ((0.05 * get(Ground_speed_kts)) ^ 1.975) * get(DELTA_TIME))
		end

		if get(Brakes_fan) == 1 then
			--fan cooled
			left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, 0.00125)
			right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, 0.00125)
		else
			--natural cool down
			left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, 0.00075)
			right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, 0.00075)
		end
	else
		if (get(Left_gear_deployment) + get(Right_gear_deployment)) / 2 > 0.2 then
			if get(Brakes_fan) == 1 then
				--fan cooled
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((39/160000) * get(IAS)) + 0.00125, 0.00125, 0.05))
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((39/160000) * get(IAS)) + 0.00125, 0.00125, 0.05))
			else
				--natural cool down
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((197/800000) * get(IAS)) + 0.00075, 0.00125, 0.05))
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((197/800000) * get(IAS)) + 0.00075, 0.00125, 0.05))
			end
		else
			if get(Brakes_fan) == 1 then
				--fan cooled
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, 0.00125)
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, 0.00125)
			else
				--natural cool down
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, 0.00075)
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, 0.00075)
			end
		end
	end
end

local function update_wheel_psi()

	left_tire_psi_no_delay = 5/39 * (left_brakes_temp_no_delay - 10) + 210
	right_tire_psi_no_delay = 5/39 * (right_brakes_temp_no_delay - 10) + 210

	--set(Left_brakes_temp, left_brakes_temp_no_delay)
	--set(Right_brakes_temp, right_brakes_temp_no_delay)

	--set(Left_tire_psi,  left_tire_psi_no_delay)
	--set(Right_tire_psi, left_tire_psi_no_delay)

	set(Left_brakes_temp, Set_anim_value(get(Left_brakes_temp), left_brakes_temp_no_delay, -100, 1000, 0.5))
	set(Right_brakes_temp, Set_anim_value(get(Left_brakes_temp), right_brakes_temp_no_delay, -100, 1000, 0.5))

	set(Left_tire_psi,  Set_anim_value(get(Left_tire_psi), left_tire_psi_no_delay, -100, 1000, 0.5))
	set(Right_tire_psi, Set_anim_value(get(Left_tire_psi), left_tire_psi_no_delay, -100, 1000, 0.5))
end

local function update_steering()

    set(Override_wheel_steering, 1)
    set(Nosewheel_Steering_and_AS_sw, antiskid_and_ns_switch and 1 or 0)
    set(Nosewheel_Steering_working, 0)

    local is_steering_completely_off = (not antiskid_and_ns_switch) or (get(FAILURE_GEAR_NWS) == 1)
                                     or (get(Hydraulic_Y_press) <= 10)
                                     or (get(FAILURE_GEAR_BSCU1) == 1 and get(FAILURE_GEAR_BSCU2) == 1)

    if is_steering_completely_off or (get(Engine_1_avail) == 0 and get(Engine_2_avail) == 0) then
        return -- Cannot move the wheel
    end

    -- Ok so nosewheel is ok
    set(Nosewheel_Steering_working, 1)
    
    if get(Any_wheel_on_ground) == 0 then
        return -- Inhibition condition
    end
    
    -- If HYD Y > 1450 then we have full steering, otherwise let's compute a linear
    -- degradation of steering
    local hyd_steer_coeff = Math_clamp(Math_rescale(10, 0, 1450, 1, get(Hydraulic_Y_press)), 0, 1)
    
    local pedals_pos = get(Yaw)    -- TODO Add also autopilot effect on wheels
    
    local speed = get(Ground_speed_kts)
    local steer_limit = 0
    
    if speed <= 20 then
        steer_limit = 75
    elseif speed <= 40 then
        steer_limit = Math_rescale(20, 75, 40, 37.5, speed)
    elseif speed <= 80 then
        steer_limit = Math_rescale(40, 37.5, 80, 6, speed)
    elseif speed <= 130 then
        steer_limit = Math_rescale(80, 6, 130, 0, speed)
    end

    local actual_steer = pedals_pos * steer_limit * hyd_steer_coeff

    if get(No_joystick_connected) == 1 then
        -- When the use has mouse only, the rudder ratio is limited to [-0.2;0.2]
        actual_steer = actual_steer * 5
    end

    set(Steer_ratio, actual_steer, 1)
end

function update()
    perf_measure_start("wheel:update()")
    update_gear_status()
    update_pb_lights()



	--convert m/s to kts
	set(Ground_speed_kts, get(Ground_speed_ms)*1.94384)

    update_steering()

    update_brake_temps()
    update_wheel_psi()
    perf_measure_stop("wheel:update()")
end
