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


----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local antiskid_and_ns_switch = true -- Status of the ANTI-SKID and N/S switch

local brake_temps = {get(OTA), get(OTA), get(OTA), get(OTA)}

local wheel_psi_baseline = {0, 0, 0, 0}
local nose_wheel_psi_baseline = {0, 0}

--sim dataref
local Front_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[0]")
local Left_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[1]")
local Right_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[2]")

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
-- Airbus TCA support
sasl.registerCommandHandler (TCA_park_brake_set, 0, function(phase) Set_parkbrake(phase) end)

function Set_parkbrake(phase)
  if phase == SASL_COMMAND_CONTINUE then
        set(Parkbrake_switch_pos, 1)
    else
        set(Parkbrake_switch_pos, 0)
    end  
end

function Toggle_parkbrake(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Parkbrake_switch_pos, 1-get(Parkbrake_switch_pos))
    end
end

function Toggle_regular(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(Parkbrake_switch_pos) == 1 then
            set(Parkbrake_switch_pos, 0)
            brake_req_right = 0
            brake_req_left  = 0
        else
            brake_req_right = 1 - brake_req_right
            brake_req_left  = 1 - brake_req_left
        end
    end
end

function Braking_regular(phase)
    if get(Parkbrake_switch_pos) == 1 then
        set(Parkbrake_switch_pos, 0)
    end
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

local function randomize_psi_at_start()

    local random1 = math.random()
    random1 = random1 > 0.3 and 5 or (random1 > 0.7 and 10 or 0)
    local random2 = math.random()
    random2 = random2 > 0.3 and 5 or (random2 > 0.7 and 10 or 0)
    local random3 = math.random()
    random3 = random3 > 0.3 and 5 or (random3 > 0.7 and 10 or 0)
    local random4 = math.random()
    random4 = random4 > 0.3 and 5 or (random4 > 0.7 and 10 or 0)
    wheel_psi_baseline = {205 + random1, 205 + random2, 205 + random3, 205 + random4}

    local random1 = math.random()
    random1 = random1 > 0.3 and 5 or (random1 > 0.7 and 10 or 0)
    local random2 = math.random()
    random2 = random2 > 0.3 and 5 or (random2 > 0.7 and 10 or 0)
    nose_wheel_psi_baseline = {175+random1, 175+random2}

end

function onAirportLoaded()
    brake_temps[1] = get(OTA)
    brake_temps[2] = get(OTA)
    brake_temps[3] = get(OTA)
    brake_temps[4] = get(OTA)

    randomize_psi_at_start()

    -- When the aircraft is loaded in flight no park brake, otherwise, put on the park brakes :)
    if get(Capt_ra_alt_ft) > 20 then
        set(Parkbrake_switch_pos, 0)
    else
        set(Parkbrake_switch_pos, 1)
    end
end

onAirportLoaded()

----------------------------------------------------------------------------------------------------
-- Main code
----------------------------------------------------------------------------------------------------

local function update_gear_status()
    set(Either_Aft_on_ground, BoolToNum(get(Left_gear_on_ground) == 1 or get(Right_gear_on_ground) == 1))
	set(Aft_wheel_on_ground, math.floor((get(Left_gear_on_ground) + get(Right_gear_on_ground))/2))
    set(All_on_ground, math.floor((get(Front_gear_on_ground) + get(Left_gear_on_ground) + get(Right_gear_on_ground))/3))
    if get(Front_gear_on_ground) == 1 or get(Left_gear_on_ground) == 1 or get(Right_gear_on_ground) == 1 then
        set(Any_wheel_on_ground, 1)
    else
        set(Any_wheel_on_ground, 0)
    end
end

local function compute_wheel_speeds()
    local C_tire_radius = 0.38 --m
    local L_tire_radius = 0.62 --m
    local R_tire_radius = 0.62 --m

    set(Wheel_spd_kts_C, get(Wheel_rot_rate_C) * C_tire_radius * 1.944)
    set(Wheel_spd_kts_L, get(Wheel_rot_rate_L) * L_tire_radius * 1.944)
    set(Wheel_spd_kts_R, get(Wheel_rot_rate_R) * R_tire_radius * 1.944)
end

local function update_pb_lights()
	--update Brake fan button states follwing 00, 01, 10, 11
	
	pb_set(PB.mip.brk_fan, get(Brakes_fan) == 1, brake_temps[1] > 300 or brake_temps[2] > 300 or brake_temps[3] > 300 or brake_temps[4] > 300)

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

local function compute_temp_braking(speed, curr_temp, curr_braking, curr_skidding)
    local derivative = math.max(0, Math_rescale_no_lim(100, 50, 200, 100, speed)) + math.random()*20 -- in °C/s
    derivative = derivative * (curr_braking - curr_skidding)
    return curr_temp + derivative * get(DELTA_TIME)
end

local function update_brake_temp_single(i)
    local brake_fan = get(Brakes_fan) == 1
    local brake_value = i <= 2 and get(Wheel_brake_L) or get(Wheel_brake_R)
    local skid_value  = i <= 2 and get(Wheel_skidding_L) or get(Wheel_skidding_R)
    
    -- CASE 1 : On ground
    if get(Aft_wheel_on_ground) == 1 then
    
        if get(Wheel_brake_L) > 0 and get(Ground_speed_kts) > 1 then
		    brake_temps[i] = compute_temp_braking(get(Ground_speed_kts), brake_temps[i], brake_value, skid_value)
        else
            brake_temps[i] = Set_anim_value(brake_temps[i], get(OTA), -100, 1000, 0.00075 + (brake_fan and 0.01 or 0))
        end
    else
        -- In Flight
        if (get(Left_gear_deployment) + get(Right_gear_deployment)) / 2 > 0.2 then
            local speed = Math_clamp(((39/160000) * get(Ground_speed_kts)) + 0.00075 + (brake_fan and 0.01 or 0), 0.00125, 0.05)
            brake_temps[i] = Set_anim_value(brake_temps[i], get(OTA), -100, 1000, speed)
        else
            local speed = 0.00075 + (brake_fan and 0.01 or 0)
            brake_temps[i] = Set_anim_value(brake_temps[i], get(OTA), -100, 1000, speed)
        end
    end
end

local function update_brake_temps()

    update_brake_temp_single(1)
    update_brake_temp_single(2)
    update_brake_temp_single(3)
    update_brake_temp_single(4)

    set(LL_brakes_temp, brake_temps[1])
    set(L_brakes_temp, brake_temps[2])
	set(R_brakes_temp, brake_temps[3])
	set(RR_brakes_temp, brake_temps[4])

end


local function compute_psi(i)
    local press = wheel_psi_baseline[i] + brake_temps[i] / 600 * 30
    if press > 250 then
        set(FAILURE_GEAR_MAIN_TIRE, 1, i)
    end

    if get(FAILURE_GEAR_MAIN_TIRE, i) == 1 then
        return 0
    end
    return press
end

local function update_wheel_psi()

	set(LL_tire_psi, compute_psi(1))
	set(L_tire_psi,  compute_psi(2))
	set(R_tire_psi,  compute_psi(3))
	set(RR_tire_psi, compute_psi(4))

	set(NL_tire_psi, get(FAILURE_GEAR_NOSE_TIRE, 1) == 0 and nose_wheel_psi_baseline[1] or 0)
	set(NR_tire_psi, get(FAILURE_GEAR_NOSE_TIRE, 2) == 0 and nose_wheel_psi_baseline[2] or 0)
end

local function update_steering()

    set(Override_wheel_steering, 1)
    Set_dataref_linear_anim_nostop(Nosewheel_Steering_and_AS_sw, antiskid_and_ns_switch and 1 or 0, 0, 1, 10)
    set(Nosewheel_Steering_working, 0)

    local is_steering_completely_off = (not antiskid_and_ns_switch) or (get(FAILURE_GEAR_NWS) == 1)
                                     or (get(Hydraulic_Y_press) <= 10)
                                     or (not is_bscu_1_working and not is_bscu_2_working)

    if is_steering_completely_off or (not ENG.dyn[1].is_avail and not ENG.dyn[2].is_avail) then
        return -- Cannot move the wheel
    end

    -- Ok so nosewheel is ok
    set(Nosewheel_Steering_working, 1)
    
    -- If HYD Y > 1450 then we have full steering, otherwise let's compute a linear
    -- degradation of steering
    local hyd_steer_coeff = Math_clamp(Math_rescale(10, 0, 1450, 1, get(Hydraulic_Y_press)), 0, 1)
    
    local pedals_pos = get(XP_YAW)
    
    if EFB then
        if EFB.pref_get_nws() == 0 then
            pedals_pos = get(XP_CAPT_X)
        elseif EFB.pref_get_nws() == 2 then
            pedals_pos = get(Joystick_tiller)
        end
    end
    -- Update graphical positions for the rudder pedals
    pedals_pos = Math_clamp((get(RUD_TRIM_ANGLE)/30) + pedals_pos, -1, 1)
    set(Rudder_pedal_pos, pedals_pos)
    
    -- TODO: And now add the AUTOFLT component
    --pedals_pos = Math_clamp(pedals_pos + get(AUTOFLT_yaw), -1, 1)

    if get(Any_wheel_on_ground) == 0 then
        return -- Inhibition condition
    end

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
        if get(Hydraulic_G_press) >= 1450 and antiskid_and_ns_switch and at_least_one_BSCU_op and get(FAILURE_GEAR_NWS) == 0 then
            set(Brakes_mode, 1) -- Normal
        elseif get(Hydraulic_Y_press) >= 1450 and antiskid_and_ns_switch and at_least_one_BSCU_op and get(FAILURE_GEAR_NWS) == 0 then
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
    Set_dataref_linear_anim(Wheel_brake_L, L * L_temp_degradation, 0, 1, 1)
    Set_dataref_linear_anim(Wheel_brake_R, R * R_temp_degradation, 0, 1, 1)
    
    -- We need to reduce the accumulator when brake changes
    local diff = (get(Wheel_brake_L) + get(Wheel_brake_R)) - prev_brakes
    -- So a full brake leds diff = 1, and we have around 14 full brakes (per part) when accumulator 1 < x < 3,
    -- then:
    if diff > 0 and get(Wheel_better_pushback_connected) == 0 then  -- Disable the use of accumulator when pushback is in progress
                                                                    -- (BP uses aircraft brakes)
        diff = diff / 14 * 2
        set(Brakes_accumulator, get(Brakes_accumulator) - diff)
    end
end

local function brake_altn(L_temp_degradation, R_temp_degradation)
    local left_brake  = get(Joystick_toe_brakes_L)+brake_req_left
    local right_brake = get(Joystick_toe_brakes_R)+brake_req_right
    if get(Hydraulic_Y_press) >= 1450 then
        -- Ok in this case let's brake, no pressure limit, no antiskid
        
        Set_dataref_linear_anim(Wheel_brake_L, left_brake *L_temp_degradation, 0, 1, 1)
        Set_dataref_linear_anim(Wheel_brake_R, right_brake*R_temp_degradation, 0, 1, 1)
    elseif get(Brakes_accumulator) > 1 then
        -- If we don't have hydraulic, we need to use the accumulator (if any)
        brake_with_accumulator(left_brake, right_brake, L_temp_degradation, R_temp_degradation)
    else
        -- Oh no, no hyd pressure to brake
        Set_dataref_linear_anim(Wheel_brake_L, 0, 0, 1, 1)
        Set_dataref_linear_anim(Wheel_brake_R, 0, 0, 1, 1)
        set(Brakes_accumulator, math.max(0,get(Brakes_accumulator) - 0.01))
    end
end

local function update_brakes()
    set(XPlane_parkbrake_ratio, 0) -- X-Plane park brake is not used
    set(Override_wheel_gear_and_brk, 1)
    set(Wheel_better_pushback, 0)

    local L_avg_temp = (brake_temps[1] + brake_temps[2]) / 2
    local R_avg_temp = (brake_temps[3] + brake_temps[4]) / 2
    local L_temp_degradation = L_avg_temp < 550 and 1 or Math_clamp((1-(L_avg_temp - 550) / 550), 0, 1)
    local R_temp_degradation = R_avg_temp < 550 and 1 or Math_clamp((1-(R_avg_temp - 550) / 550), 0, 1)

    -- Tire blown degradation
    L_temp_degradation = L_temp_degradation / 2^(get(FAILURE_GEAR_MAIN_TIRE, 1) + get(FAILURE_GEAR_MAIN_TIRE, 2))
    R_temp_degradation = R_temp_degradation / 2^(get(FAILURE_GEAR_MAIN_TIRE, 3) + get(FAILURE_GEAR_MAIN_TIRE, 4))

    local up_limit = Math_rescale(0, 0, 2500, 1.4, 1000) -- 1000 PSI upper limit

    local left_brake_power  = get(Joystick_toe_brakes_L)+brake_req_left+get(Wheel_autobrake_braking)
    local right_brake_power = get(Joystick_toe_brakes_R)+brake_req_right+get(Wheel_autobrake_braking)

    if get(Wheel_autobrake_braking) > 0 and (brake_req_left > 0 or get(Joystick_toe_brakes_L) > 0.2 or get(Joystick_toe_brakes_R) > 0.2) then 
        -- Disable autobrake when pilot presses pedals (and autobrake actually working)
        set(Wheel_autobrake_status, 0)
    end

    if get(Brakes_mode) == 1 or get(Brakes_mode) == 2 then
        -- Normal or alternate with antiskid
        local L_brake_set = Math_clamp(left_brake_power,  0, up_limit) * L_temp_degradation
        local R_brake_set = Math_clamp(right_brake_power, 0, up_limit) * R_temp_degradation
        
        run_anti_skid(L_brake_set, R_brake_set)
        
    elseif get(Brakes_mode) == 3 then
        -- Alternate brake no antiskid
        local L_brake_set = Math_clamp(left_brake_power,  0, up_limit) * L_temp_degradation
        local R_brake_set = Math_clamp(right_brake_power, 0, up_limit) * R_temp_degradation
        
        brake_altn(L_brake_set, R_brake_set)
        
    elseif get(Brakes_mode) == 4 then
        -- Parking brake

        if get(Hydraulic_Y_press) >= 1450 or get(Hydraulic_G_press) >= 1450 then
            -- Brake with hydraulic active
            Set_dataref_linear_anim(Wheel_brake_L, 1 * L_temp_degradation, 0, 1, 2)
            Set_dataref_linear_anim(Wheel_brake_R, 1 * R_temp_degradation, 0, 1, 2)
            set(Wheel_better_pushback, 1)
        elseif get(Brakes_accumulator) > 1 then
            -- Brake on accumulator only
            brake_with_accumulator(1,1, L_temp_degradation, R_temp_degradation)     
            set(Wheel_better_pushback, 1)
        else
            -- uh oh, no hydraulic
            Set_dataref_linear_anim(Wheel_brake_L, 0, 0, 1, 2)
            Set_dataref_linear_anim(Wheel_brake_R, 0, 0, 1, 2)        
        end
    end

    if get(Brakes_mode) ~= 1 then
        set(Brakes_press_ind_L, Math_rescale(0, 0, 1, 2500, get(Wheel_brake_L)))
        set(Brakes_press_ind_R, Math_rescale(0, 0, 1, 2500, get(Wheel_brake_R)))
    else
        Set_dataref_linear_anim(Brakes_press_ind_L, 0, 0, 500, 2500)
        Set_dataref_linear_anim(Brakes_press_ind_R, 0, 0, 2500, 2500)    
    end

    if get(Hydraulic_Y_press) >= 1450 then
        Set_dataref_linear_anim(Brakes_accumulator, 3, 0, 4, 0.5)
    end

end

local function update_anim()

    Set_dataref_linear_anim_nostop(Parkbrake_switch_pos_anim, get(Parkbrake_switch_pos), 0, 1, 3)
end

function update()
    perf_measure_start("wheel:update()")
    update_computer_status_and_pwr()
    
    update_gear_status()
    compute_wheel_speeds()
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
    update_anim()
    
    perf_measure_stop("wheel:update()")
end
