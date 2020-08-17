--sim dataref
local left_brakes_temp_no_delay = 10
local right_brakes_temp_no_delay = 10
local left_tire_psi_no_delay = 210
local right_tire_psi_no_delay = 210

--a32nx dataref
local groundspeed_kts = createGlobalPropertyf("a321neo/dynamics/groundspeed_kts", 0, false, true, false) --ground speed in kts

--resgister commands
sasl.registerCommandHandler (Toggle_brake_fan, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Brakes_fan, 1 - get(Brakes_fan))
    end
end)

sasl.registerCommandHandler (Toggle_lo_autobrake, 0, function(phase)
	if phase == SASL_COMMAND_BEGIN then
		if get(Autobrakes_sim) == 1 then
			set(Autobrakes_sim, 2)
		elseif get(Autobrakes_sim) == 2 then
			set(Autobrakes_sim, 1)
			set(Cockpit_parkbrake_ratio, 0)
		end
    end
end)

sasl.registerCommandHandler (Toggle_med_autobrake, 0, function(phase)
	if phase == SASL_COMMAND_BEGIN then
		if get(Autobrakes_sim) == 1 then
			set(Autobrakes_sim, 4)
		elseif get(Autobrakes_sim) == 4 then
			set(Autobrakes_sim, 1)
			set(Cockpit_parkbrake_ratio, 0)
		end
    end
end)

sasl.registerCommandHandler (Toggle_max_autobrake, 0, function(phase)
	if phase == SASL_COMMAND_BEGIN then
		if get(Autobrakes_sim) == 1 then
			set(Autobrakes_sim, 0)
		elseif get(Autobrakes_sim) == 0 then
			set(Autobrakes_sim, 1)
			set(Cockpit_parkbrake_ratio, 0)
		end
    end
end)

function update()
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

	--update autobrake button status follwing 00, 01, 10, 11
	if get(Autobrakes_sim) == 1 then
		set(Autobrakes_lo_button_state, 0)--00
		set(Autobrakes_med_button_state, 0)--00
		set(Autobrakes_max_button_state, 0)--00
		set(Autobrakes, 0)
	elseif get(Autobrakes_sim) == 0 then
		set(Autobrakes_max_button_state, 1)--01
		set(Autobrakes, 3)
		if get(Cockpit_parkbrake_ratio) > 0 then
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
				if get(Cockpit_parkbrake_ratio) > 0 then
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
				if get(Cockpit_parkbrake_ratio) > 0 then
					set(Autobrakes_med_button_state, 2)--10
					set(Autobrakes, 2)
				end
			else
				set(Autobrakes_med_button_state, 0)--00
				set(Autobrakes, 0)
			end
		end
	end




	--convert m/s to kts
	set(groundspeed_kts, get(Ground_speed_ms)*1.94384)

	if get(Aft_wheel_on_ground) == 1 then
		if get(Actual_brake_ratio) >  0 then
			left_brakes_temp_no_delay = left_brakes_temp_no_delay + (get(Actual_brake_ratio) * ((0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
			right_brakes_temp_no_delay = right_brakes_temp_no_delay + (get(Actual_brake_ratio) * ((0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
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