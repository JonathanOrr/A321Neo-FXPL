local simDR_aircraft_ias = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
local simDR_aircraft_acceleration = globalProperty("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot") --kts per second
local simDR_manual_set_thro_1 = globalProperty("sim/flightmodel/engine/ENGN_thro_use[0]")
local simDR_manual_set_thro_2 = globalProperty("sim/flightmodel/engine/ENGN_thro_use[1]")
local simDR_L_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[0]")
local simDR_R_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[1]")
local simDR_override_throttle = globalProperty("sim/operation/override/override_throttles")
local DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")

local a321DR_autothrust_on = createGlobalPropertyi("a321neo/debug/auto_thrust_on", 0, false, true, false)
local a321DR_target_spd = createGlobalPropertyi("a321neo/debug/target_speed", 250, false, true, false)
local a321DR_throttle_1 = createGlobalPropertyf("a321neo/debug/throttle_1", 0, false, true, false)
local a321DR_throttle_2 = createGlobalPropertyf("a321neo/debug/throttle_2", 0, false, true, false)
local a321DR_idle_mode = createGlobalPropertyf("a321neo/debug/throttle_idle_mode", 0, false, true, false)

local a321DR_thrust_control_output = createGlobalPropertyf("a321neo/debug/thrust_control_output", 0, false, true, false)

local spd_timer = 0
local sample_time = 0
local spd_engage = 0
local spd_engage_old = 0
local setpoint1 = 0
local input1 = 0
local out_min1 = 0
local out_max1 = 0
local output1 = 0
local output1_old = 0
local i_term1 = 0
local k_term1_old = 0
local last_input1 = 0
local kp1 = 0
local ki1 = 0
local kd1 = 0

local calc_thr_target = 0
local thr1_target = 0
local thr2_target = 0
local eng1_N1_thrust_cur = 0
local eng2_N1_thrust_cur = 0
local B738DR_thrust1_leveler = 0
local B738DR_thrust2_leveler = 0

function set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
    end

end

function rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function Math_clamp(val, min, max)
    if min > max then LogWarning("Min is larger than Max invalid") end
    if val < min then
        return min
    elseif val > max then
        return max
    elseif val <= max and val >= min then
        return val
    end
end

function control_SPD6()
	
	local SPD_err = 0
	local ap_airspeed_accel = 0
	local ap_airspeed2 = 0
	local ap_accel = 0
	local max_err = 8	--a321DR_bias		--8
	local spd_prediction = 10	--10	--a321DR_predict	--10
	local err_predict = 0
	local k_term = 0
	local d_term = 0
	local lim1 = 0
	local lim2 = 0
	
	ap_airspeed2 = get(simDR_aircraft_ias)	--a321DR_ap_speed_main
	ap_accel = get(simDR_aircraft_acceleration)	--a321DR_ap_accel_main
	
	ap_airspeed_accel = ap_airspeed2 + (ap_accel * spd_prediction)
	-------------
	local err = 0
	local d_input = 0
	if spd_engage ~= spd_engage_old then
		lim1 = 1.0 --a321DR_eng1_N1_lim
		lim2 = 1.0 --a321DR_eng2_N1_lim
		out_max1 = math.max(lim1, lim2)
		
		last_input1 = ap_airspeed_accel	--input1
		i_term1 = math.max(get(simDR_manual_set_thro_1), get(simDR_manual_set_thro_2))	--output1
		output1_old = i_term1
		output1 = i_term1
		spd_timer = 0
	end
	
	spd_timer = spd_timer + get(DELTA_TIME)
	if spd_timer > sample_time then
		input1 = ap_airspeed_accel
		setpoint1 = get(a321DR_target_spd)
		
		-- kp1 = 0.018					--0.018
		-- ki1 = 0.007 * spd_timer		--0.007
		-- kd1 = 0.01 / spd_timer		--0.001
		-- spd_timer = 0
		
		-- calc output
		err = setpoint1 - input1
		local ap_accel_abs = math.abs(ap_accel)
		if err > 5 and ap_accel < -0.6 then	-- 3/-0.1
			-- max_err = max_err * 1.5
			if ap_accel < -1.4 then
				max_err = max_err * 1.5
			elseif ap_accel < -0.6 then
				max_err = max_err * rescale(0.6, 1, 1.4, 1.5, ap_accel_abs)
			end
		elseif err < -5 and ap_accel > 0.6 then		--3/0.1
			-- max_err = max_err * 1.5
			if ap_accel > 1.4 then
				max_err = max_err * 1.5
			elseif ap_accel > 0.6 then
				max_err = max_err * rescale(0.6, 1, 1.4, 1.5, ap_accel_abs)
			end
		elseif err > 5 and ap_accel > 0 then
			if ap_accel > 1.4 then
				max_err = max_err * 0.5
			else
				max_err = max_err * rescale(0, 1, 1.4, 0.5, ap_accel_abs)
			end
		elseif err < -5 and ap_accel < 0 then
			if ap_accel < -1.4 then
				max_err = max_err * 0.5
			else
				max_err = max_err * rescale(0, 1, 1.4, 0.5, ap_accel_abs)
			end
		end
		
		if ap_airspeed2 < --[[B738DR_pfd_min_speed]] 210 and setpoint1 > ap_airspeed2 then
			max_err = max_err * 2
		end
		
		if err > max_err then
			err = max_err
		elseif err < -max_err then
			err = -max_err
		end
		-- local err_abs = math.abs(err)
		local err2 = setpoint1 - ap_airspeed2
		local err_abs = math.abs(err2)
		--err_abs = math.max(err_abs, 0)
		if err_abs < 5 then
			kp1 = rescale(0, 0.011, 5, 0.014, err_abs)		-- 0.014/0.018
			if err > 0 and ap_accel > 0.9 then	--0.08
				ki1 = rescale(0, 0.0022, 5, 0.005, err_abs) * spd_timer		--0.0045/0.007
			elseif err < 0 and ap_accel < -0.9 then	-- -0.08
				ki1 = rescale(0, 0.0022, 5, 0.005, err_abs) * spd_timer		--0.0045/0.007
			elseif err_abs < 5 and ap_accel > -0.9 and ap_accel < 0.9 then	--0.08
				ki1 = rescale(0, 0.0022, 5, 0.005, err_abs) * spd_timer		--0.0045/0.007
			else
				ki1 = 0.007 * spd_timer		--0.007
			end
		else
			kp1 = 0.014					--0.018
			ki1 = 0.005 * spd_timer		--0.007
		end

		-- if err > 3 and ap_accel < -0.1 then
			-- kp1 = kp1 * 1.2
		-- elseif err < -3 and ap_accel > 0.1 then
			-- kp1 = kp1 * 1.2
		-- end
		if err2 > 5 and ap_accel < -0.6 then
			if ap_accel < -1.4 then
				kp1 = kp1 * 1.2
			elseif ap_accel < -0.6 then
				kp1 = kp1 * rescale(0.6, 1, 1.4, 1.2, ap_accel_abs)
			end
		elseif err2 < -5 and ap_accel > 0.6 then
			if ap_accel > 1.4 then
				kp1 = kp1 * 1.2
			elseif ap_accel > 0.6 then
				kp1 = kp1 * rescale(0.6, 1, 1.4, 1.2, ap_accel_abs)
			end
		end
		
		kd1 = 0.01 / spd_timer		--0.001
		spd_timer = 0
		
		if ap_airspeed2 < --[[B738DR_pfd_min_speed]] 210 and setpoint1 > ap_airspeed2 then
			kp1 = 0.014 * 2
			ki1 = 0.005 * 2
		end
		
		lim1 = 1.0 --B738DR_eng1_N1_lim
		lim2 = 1.0 --B738DR_eng2_N1_lim
		out_max1 = math.max(lim1, lim2)
		if i_term1 > out_max1 then
			i_term1 = out_max1
		elseif i_term1 < out_min1 then
			i_term1 = out_min1
		end
		
		i_term1 = i_term1 + (ki1 * err)
		if i_term1 > out_max1 then
			i_term1 = out_max1
		elseif i_term1 < out_min1 then
			i_term1 = out_min1
		end
		d_input = input1 - last_input1
		d_term = kd1 * d_input
		k_term = kp1 * err
		
		output1 = k_term + i_term1 - d_term
		if output1 > out_max1 then
			output1 = out_max1
		elseif output1 < out_min1 then
			output1 = out_min1
		end
		
		local output_max_change = math.abs(setpoint1 - ap_airspeed2)
		if k_term < 0 and ap_accel < -0.22 then
			output_max_change = 0.11 * get(DELTA_TIME)
		elseif k_term > 0 and ap_accel > 0.22 then
			output_max_change = 0.11 * get(DELTA_TIME)
		elseif output_max_change < 5 and math.abs(ap_accel) < 0.22 then
			output_max_change = 0.11 * get(DELTA_TIME)
		else
			output_max_change = 0.30 * get(DELTA_TIME)
		end
		if err > 3 and ap_accel < -0.1 then
			output_max_change = output_max_change * 1.5
		elseif err < -3 and ap_accel > 0.1 then
			output_max_change = output_max_change * 1.5
		end
		
		if ap_airspeed2 < --[[B738DR_pfd_min_speed]] 210 and setpoint1 > ap_airspeed2 then
			output_max_change = 0.90 * get(DELTA_TIME)
		end
		
		if k_term < 0 and k_term1_old >= 0 then
			if i_term1 > output1 then
				i_term1 = output1
			end
		elseif k_term > 0 and k_term1_old <= 0 then
			if i_term1 < output1 then
				i_term1 = output1
			end
		end
		k_term1_old = k_term
		
		if output1 > output1_old then
			output_max_change = output1_old + output_max_change
			if output1 > output_max_change then
				output1 = output_max_change
			end
		elseif output1 < output1_old then
			output_max_change = output1_old - output_max_change
			if output1 < output_max_change then
				output1 = output_max_change
			end
		end
		output1_old = output1
		--B738DR_pid_p = kp1 * err
		--B738DR_pid_i = i_term1
		--B738DR_pid_d = kd1 * d_input
		
		-- save last values
		last_input1 = input1
		-- B738DR_pid_out = (ap_airspeed_accel - wind_acf) + wind_acf_act
		-- B738DR_kp = wind_acf_act
	end
	
	return output1
	
end

function selected_speed()
	------------------------
	-- PID
	------------------------
	calc_thr_target = control_SPD6()
	thr1_target = math.min(1.0 --[[B738DR_eng1_N1_lim]], calc_thr_target)
	thr2_target = math.min(1.0 --[[B738DR_eng2_N1_lim]], calc_thr_target)
	if get(a321DR_idle_mode) == 1 then
		thr1_target = math.max(thr1_target, 0.051)
		thr2_target = math.max(thr2_target, 0.051)
	end
	eng1_N1_thrust_cur = set_anim_value(eng1_N1_thrust_cur, thr1_target, 0.0, 1.08, 0.5)	--2.0
    eng2_N1_thrust_cur = set_anim_value(eng2_N1_thrust_cur, thr2_target, 0.0, 1.08, 0.5)	--2.0
	------------------------
	-- END PID
	------------------------
	set(a321DR_throttle_1, rescale(0, 0, 1.08, 1, eng1_N1_thrust_cur))
    set(a321DR_throttle_2, rescale(0, 0, 1.08, 1, eng2_N1_thrust_cur))
		
	set(simDR_L_throttle, get(a321DR_throttle_1))
    set(simDR_R_throttle, get(a321DR_throttle_2))
end
--Δ=a*（t1+t）+0.5a*t2 the auto thrust equation t1> decel delay, t2> accel delay, t> full speed perior Δ> target and current speed differences

function update()
    
    if get(a321DR_autothrust_on) == 1 then
        selected_speed()
    end

    set(a321DR_thrust_control_output, control_SPD6())

end