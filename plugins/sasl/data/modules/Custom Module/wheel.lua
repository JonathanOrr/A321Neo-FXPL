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

include('wheel_autobrake.lua')

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')


----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local antiskid_and_ns_switch = true -- Status of the ANTI-SKID and N/S switch

local left_brakes_temp_no_delay = get(OTA)
local right_brakes_temp_no_delay = get(OTA)
local left_tire_psi_no_delay = 210
local right_tire_psi_no_delay = 210

--sim dataref
local front_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[0]")
local left_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[1]")
local right_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[2]")

-- Computer status
local is_lgciu_1_working = false
local is_lgciu_2_working = false
local is_bscu_1_working = false
local is_bscu_2_working = false
local is_abcu_working = false
local is_tpiu_working = false

-- No joystick variables (commanded with keys)
local brake_req_right = 0
local brake_req_left  = 0

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

sasl.registerCommandHandler (Toggle_park_brake, 0, function(phase) Toggle_parkbrake(phase) end)
sasl.registerCommandHandler (Toggle_park_brake_XP, 0, function(phase) Toggle_parkbrake(phase) end)
sasl.registerCommandHandler (Toggle_brake_regular_XP, 0, function(phase) Toggle_regular(phase) end)
sasl.registerCommandHandler (Push_brake_regular_XP, 0, function(phase) Braking_regular(phase) end)


function Toggle_parkbrake(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Parkbrake_switch_pos, 1-get(Parkbrake_switch_pos))
    end
end

function Toggle_regular(phase)
    if phase == SASL_COMMAND_BEGIN then
        brake_req_right = 1 - brake_req_right
        brake_req_left  = 1 - brake_req_left
    end
end

function Braking_regular(phase)
    if phase == SASL_COMMAND_BEGIN then
        brake_req_right = 1
        brake_req_left = 1
    elseif phase == SASL_COMMAND_END then
        brake_req_right = 0
        brake_req_left = 0
    end
end

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

function onAirportLoaded()
    -- When the aircraft is loaded in flight no park brake, otherwise, put on the park brakes :)
    if get(Capt_ra_alt_ft) > 20 then
        set(Parkbrake_switch_pos, 0)
    else
        set(Parkbrake_switch_pos, 1)
    end
end

----------------------------------------------------------------------------------------------------
-- Main code
----------------------------------------------------------------------------------------------------

local function update_gear_status()
    set(Either_Aft_on_ground, BoolToNum(get(left_gear_on_ground) == 1 or get(right_gear_on_ground) == 1))
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
	
	pb_set(PB.mip.brk_fan, get(Brakes_fan) == 1, get(Left_brakes_temp) > 400 or get(Right_brakes_temp) > 400)

	if is_lgciu_1_working then
	    pb_set(PB.mip.ldg_gear_C, get(Front_gear_deployment) == 1, get(Front_gear_deployment) ~= get(Gear_handle))
	    pb_set(PB.mip.ldg_gear_L, get(Left_gear_deployment) == 1, get(Left_gear_deployment) ~= get(Gear_handle))
	    pb_set(PB.mip.ldg_gear_R, get(Right_gear_deployment) == 1, get(Right_gear_deployment) ~= get(Gear_handle))
	else
	    pb_set(PB.mip.ldg_gear_C, false, false)
	    pb_set(PB.mip.ldg_gear_L, false, false)
	    pb_set(PB.mip.ldg_gear_R, false, false)
    end
	
end

local function update_brake_temps()

    local brake_fan = get(Brakes_fan)

	if get(Aft_wheel_on_ground) == 1 then

		if get(Wheel_brake_L) > 0 then
			left_brakes_temp_no_delay = left_brakes_temp_no_delay + (get(Wheel_brake_L) * ((0.10 * get(Ground_speed_kts)) ^ 1.975) * get(DELTA_TIME))
        else
            left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, get(OTA), -100, 1000, 0.00075 + brake_fan * 0.00075)
        end

        if get(Wheel_brake_R) > 0 then
			right_brakes_temp_no_delay = right_brakes_temp_no_delay + (get(Wheel_brake_R) * ((0.10 * get(Ground_speed_kts)) ^ 1.975) * get(DELTA_TIME))
        else
			right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, get(OTA), -100, 1000, 0.00075 + brake_fan * 0.00075)
		end
	else
		if (get(Left_gear_deployment) + get(Right_gear_deployment)) / 2 > 0.2 then
			if brake_fan == 1 then
				--fan cooled
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, get(OTA), -100, 1000, Math_clamp(((39/160000) * get(IAS)) + 0.00125, 0.00125, 0.05))
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, get(OTA), -100, 1000, Math_clamp(((39/160000) * get(IAS)) + 0.00125, 0.00125, 0.05))
			else
				--natural cool down
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, get(OTA), -100, 1000, Math_clamp(((197/800000) * get(IAS)) + 0.00075, 0.00125, 0.05))
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, get(OTA), -100, 1000, Math_clamp(((197/800000) * get(IAS)) + 0.00075, 0.00125, 0.05))
			end
		else
			if brake_fan == 1 then
				--fan cooled
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, get(OTA), -100, 1000, 0.00125)
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, get(OTA), -100, 1000, 0.00125)
			else
				--natural cool down
				left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, get(OTA), -100, 1000, 0.00075)
				right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, get(OTA), -100, 1000, 0.00075)
			end
		end
	end
	
    set(Left_brakes_temp, Set_anim_value(get(Left_brakes_temp), left_brakes_temp_no_delay, -100, 1000, 0.5))
	set(Right_brakes_temp, Set_anim_value(get(Right_brakes_temp), right_brakes_temp_no_delay, -100, 1000, 0.5))

end

local function update_wheel_psi()

	left_tire_psi_no_delay = 5/39 * (left_brakes_temp_no_delay - 10) + 210
	right_tire_psi_no_delay = 5/39 * (right_brakes_temp_no_delay - 10) + 210

	set(Left_tire_psi,  Set_anim_value(get(Left_tire_psi), left_tire_psi_no_delay, -100, 1000, 0.5))
	set(Right_tire_psi, Set_anim_value(get(Right_tire_psi), left_tire_psi_no_delay, -100, 1000, 0.5))
end

local function update_steering()

    set(Override_wheel_steering, 1)
    set(Nosewheel_Steering_and_AS_sw, antiskid_and_ns_switch and 1 or 0)
    set(Nosewheel_Steering_working, 0)

    local is_steering_completely_off = (not antiskid_and_ns_switch) or (get(FAILURE_GEAR_NWS) == 1)
                                     or (get(Hydraulic_Y_press) <= 10)
                                     or (not is_bscu_1_working and not is_bscu_2_working)

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

    set(Nosewheel_Steering_limit, steer_limit)

    local actual_steer = pedals_pos * steer_limit * hyd_steer_coeff

    if get(Joystick_connected) == 0 then
        -- When the use has mouse only, the rudder ratio is limited to [-0.2;0.2]
        actual_steer = actual_steer * 5
    end

    set(Steer_ratio_setpoint, actual_steer) 
    Set_dataref_linear_anim(Steer_ratio_actual, get(Steer_ratio_setpoint), -75, 75, 50)
end

local function update_brake_mode()

    local at_least_one_BSCU_op = is_bscu_1_working or is_bscu_2_working

    if get(Parkbrake_switch_pos) == 0 then
        if get(Hydraulic_G_press) >= 1450 and antiskid_and_ns_switch and at_least_one_BSCU_op then
            set(Brakes_mode, 1) -- Normal
        elseif get(Hydraulic_Y_press) >= 1450 and antiskid_and_ns_switch and at_least_one_BSCU_op then
            set(Brakes_mode, 2) -- ALTN with anti skid
        else
            set(Brakes_mode, 3) -- ALTN without anti skid
        end
    else
        set(Brakes_mode, 4)
    end
end

local function update_computer_status_and_pwr()
    -- BSCUx: Brake and Steering Control Unit
    is_bscu_1_working = get(FAILURE_GEAR_BSCU1) == 0 and get(DC_bus_1_pwrd) == 1 and get(AC_bus_1_pwrd) == 1
    is_bscu_2_working = get(FAILURE_GEAR_BSCU2) == 0 and get(DC_bus_2_pwrd) == 1 and get(AC_bus_2_pwrd) == 1
    if is_bscu_1_working then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 0.5, 0.5)
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_1, 1, 1)
    end
    if is_bscu_2_working then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.5, 0.5)
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 1, 1)
    end

    -- ABCU: Alternate Braking Control Unit
    is_abcu_working = get(FAILURE_GEAR_ABCU) == 0 and get(DC_ess_bus_pwrd) == 1 and (get(HOT_bus_1_pwrd) == 1 or get(HOT_bus_2_pwrd) == 1)
    if is_abcu_working then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 0.5, 0.5)
        if get(HOT_bus_1_pwrd) == 1 then ELEC_sys.add_power_consumption(ELEC_BUS_HOT_BUS_1, 0.1, 0.1) end
        if get(HOT_bus_2_pwrd) == 1 then ELEC_sys.add_power_consumption(ELEC_BUS_HOT_BUS_2, 0.1, 0.1) end
    end
    
    is_lgciu_1_working = get(FAILURE_GEAR_LGIU1) == 0 and (get(DC_ess_bus_pwrd) == 1 or get(DC_bus_1_pwrd) == 1)
    is_lgciu_2_working = get(FAILURE_GEAR_LGIU2) == 0 and get(DC_bus_2_pwrd) == 1
    if is_lgciu_1_working and get(DC_ess_bus_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 1, 1)
    elseif is_lgciu_1_working then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_1, 1, 1)
    end

    if is_lgciu_2_working then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 1, 1)
    end

    is_tpiu_working = get(FAILURE_GEAR_TPIU) == 0 and get(DC_bus_1_pwrd) == 1
    if is_tpiu_working then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_1, 0.5, 0.5)
    end

    set(Wheel_status_BSCU_1, is_bscu_1_working and 1 or 0)
    set(Wheel_status_BSCU_2, is_bscu_2_working and 1 or 0)
    set(Wheel_status_LGCIU_1, is_lgciu_1_working and 1 or 0)
    set(Wheel_status_LGCIU_2, is_lgciu_2_working and 1 or 0)
    set(Wheel_status_ABCU,   is_abcu_working and 1 or 0)
    set(Wheel_status_TPIU,   is_tpiu_working and 1 or 0)
    
end

local function update_skidding_values()

    -- X-Plane skid ratio looks wrong, let's compute it

    local skid_ratio_C = get(Wheel_skid_speed_C) / get(Ground_speed_ms)
    local skid_ratio_L = get(Wheel_skid_speed_L) / get(Ground_speed_ms)
    local skid_ratio_R = get(Wheel_skid_speed_R) / get(Ground_speed_ms)

    set(Wheel_skidding_C, skid_ratio_C)
    set(Wheel_skidding_L, skid_ratio_L)
    set(Wheel_skidding_R, skid_ratio_R)
 
end

local function run_anti_skid(brake_value_L, brake_value_R)

    if get(Wheel_skidding_L) > 0.11 then
        set(Ecam_wheel_release_R, 1)
        Set_dataref_linear_anim(Wheel_brake_L, 0, 0, 1, 1)
    else
        set(Ecam_wheel_release_L, 0)
        Set_dataref_linear_anim(Wheel_brake_L, brake_value_L, 0, 1, 0.5)
    end
    
    if get(Wheel_skidding_R) > 0.11 then
        set(Ecam_wheel_release_R, 1)
        Set_dataref_linear_anim(Wheel_brake_R, 0, 0, 1, 1)
    else
        set(Ecam_wheel_release_R, 0)
        Set_dataref_linear_anim(Wheel_brake_R, brake_value_R, 0, 1, 0.5)
    end
end

local function brake_with_accumulator(L,R, L_temp_degradation, R_temp_degradation)

    local prev_brakes = get(Wheel_brake_L) + get(Wheel_brake_R)
    Set_dataref_linear_anim(Wheel_brake_L, L * L_temp_degradation, 0, 1, 0.5)
    Set_dataref_linear_anim(Wheel_brake_R, R * R_temp_degradation, 0, 1, 0.5)
    
    -- We need to reduce the accumulator when brake changes
    local diff = (get(Wheel_brake_L) + get(Wheel_brake_R)) - prev_brakes
    -- So a full brake leds diff = 1, and we have around 14 full brakes (per part) when accumulator 1 < x < 3,
    -- then:
    if diff > 0 then
        diff = diff / 14 * 2
        set(Brakes_accumulator, get(Brakes_accumulator) - diff)
    end
end

local function brake_altn(L_temp_degradation, R_temp_degradation)
    if get(Hydraulic_Y_press) >= 1450 then
        -- Ok in this case let's brake, no pressure limit, no antiskid
        Set_dataref_linear_anim(Wheel_brake_L, (get(Joystick_toe_brakes_L)+brake_req_left)*L_temp_degradation, 0, 1, 0.5)
        Set_dataref_linear_anim(Wheel_brake_R, (get(Joystick_toe_brakes_R)+brake_req_right)*R_temp_degradation, 0, 1, 0.5)
    elseif get(Brakes_accumulator) > 1 then
        -- If we don't have hydraulic, we need to use the accumulator (if any)
        brake_with_accumulator(get(Joystick_toe_brakes_L)+brake_req_left, get(Joystick_toe_brakes_R)+brake_req_right, L_temp_degradation, R_temp_degradation)
    else
        -- Oh no, no hyd pressure to brake
        Set_dataref_linear_anim(Wheel_brake_L, 0, 0, 1, 0.5)
        Set_dataref_linear_anim(Wheel_brake_R, 0, 0, 1, 0.5)
        set(Brakes_accumulator, math.max(0,get(Brakes_accumulator) - 0.01))
    end
end

local function update_brakes()
    set(XPlane_parkbrake_ratio, 0) -- X-Plane park brake is not used
    set(Override_wheel_gear_and_brk, 1)

    local L_temp_degradation = get(Left_brakes_temp) < 550 and 1 or Math_clamp((1-(get(Left_brakes_temp) - 550) / 550), 0, 1)
    local R_temp_degradation = get(Right_brakes_temp) < 550 and 1 or Math_clamp((1-(get(Left_brakes_temp) - 550) / 550), 0, 1)

    local up_limit = Math_rescale(0, 0, 2500, 1.4, 1000) -- 1000 PSI upper limit


    if get(Brakes_mode) == 1 or get(Brakes_mode) == 2 then
        -- Normal or alternate with antiskid
        local L_brake_set = Math_clamp(get(Joystick_toe_brakes_L)+brake_req_left, 0, up_limit) * L_temp_degradation
        local R_brake_set = Math_clamp(get(Joystick_toe_brakes_R)+brake_req_right, 0, up_limit) * R_temp_degradation
        
        run_anti_skid(L_brake_set, R_brake_set)
        
    elseif get(Brakes_mode) == 3 then
        -- Alternate brake no antiskid
        
        brake_altn(L_temp_degradation, R_temp_degradation)
        
    elseif get(Brakes_mode) == 4 then
        -- Parking brake

        if get(Hydraulic_Y_press) >= 1450 or get(Hydraulic_G_press) >= 1450 then
            Set_dataref_linear_anim(Wheel_brake_L, 1 * L_temp_degradation, 0, 1, 1)
            Set_dataref_linear_anim(Wheel_brake_R, 1 * R_temp_degradation, 0, 1, 1)
        elseif get(Brakes_accumulator) > 1 then
            brake_with_accumulator(1,1, L_temp_degradation, R_temp_degradation)     
        else
            Set_dataref_linear_anim(Wheel_brake_L, 0, 0, 1, 1)
            Set_dataref_linear_anim(Wheel_brake_R, 0, 0, 1, 1)        
        end
    end

    if get(Brakes_mode) ~= 1 then
        set(Brakes_press_ind_L, Math_rescale(0, 0, 1, 2500, get(Wheel_brake_L)))
        set(Brakes_press_ind_R, Math_rescale(0, 0, 1, 2500, get(Wheel_brake_R)))
    end

    if get(Hydraulic_Y_press) >= 1450 then
        Set_dataref_linear_anim(Brakes_accumulator, 3, 0, 4, 0.5)
    end

end

function update()
    perf_measure_start("wheel:update()")
    update_computer_status_and_pwr()
    
    update_gear_status()
    update_pb_lights()

	--convert m/s to kts
	set(Ground_speed_kts, get(Ground_speed_ms)*1.94384)

    update_skidding_values()
    update_steering()
    update_brake_mode()
    update_brakes()
   
    update_brake_temps()
    update_wheel_psi()
    
    update_autobrake()
    
    perf_measure_stop("wheel:update()")
end
