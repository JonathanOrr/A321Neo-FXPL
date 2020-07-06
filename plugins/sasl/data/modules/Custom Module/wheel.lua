--sim dataref
local left_brakes_temp_no_delay = 10
local right_brakes_temp_no_delay = 10
local left_tire_psi_no_delay = 210
local right_tire_psi_no_delay = 210

--a32nx dataref
local groundspeed_kts = createGlobalPropertyf("a321neo/dynamics/groundspeed_kts", 0, false, true, false) --ground speed in kts

function update()
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
		if get(Brakes_fan) == 1 then
			--fan cooled
			left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((39/160000) * get(IAS)) + 0.00125, 0.00125, 0.05))
			right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((39/160000) * get(IAS)) + 0.00125, 0.00125, 0.05))
		else
			--natural cool down
			left_brakes_temp_no_delay = Set_anim_value(left_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((197/800000) * get(IAS)) + 0.00075, 0.00125, 0.05))
			right_brakes_temp_no_delay = Set_anim_value(right_brakes_temp_no_delay, 10, -100, 1000, Math_clamp(((197/800000) * get(IAS)) + 0.00075, 0.00125, 0.05))
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