--sim dataref

--a32nx dataref
local groundspeed_kts = createGlobalPropertyf("a321neo/dynamics/groundspeed_kts", 0, false, true, false) --ground speed in kts

function update()
	--convert m/s to kts
	set(groundspeed_kts, get(Ground_speed_ms)*1.94384)

	if get(Aft_wheel_on_ground) == 1 then
		if get(Actual_brake_ratio) >  0 then
			math.randomseed(os.time())
			set(Left_l_brakes_temp, get(Left_l_brakes_temp) + (get(Actual_brake_ratio) * (0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
			math.randomseed(os.time())
			set(Left_r_brakes_temp, get(Left_r_brakes_temp) + (get(Actual_brake_ratio) * (0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
			math.randomseed(os.time())
			set(Right_l_brakes_temp, get(Right_l_brakes_temp) + (get(Actual_brake_ratio) * (0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
			math.randomseed(os.time())
			set(Right_r_brakes_temp, get(Right_r_brakes_temp) + (get(Actual_brake_ratio) * (0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
		end
	end

	if get(Left_l_brakes_temp) > 400 then
		set(Left_l_brakes_hot, 1)
	else
		set(Left_l_brakes_hot, 0)
	end

	if get(Left_r_brakes_temp) > 400 then
		set(Left_r_brakes_hot, 1)
	else
		set(Left_r_brakes_hot, 0)
	end

	if get(Right_l_brakes_temp) > 400 then
		set(Right_l_brakes_hot, 1)
	else
		set(Right_l_brakes_hot, 0)
	end

	if get(Right_r_brakes_temp) > 400 then
		set(Right_r_brakes_hot, 1)
	else
		set(Right_r_brakes_hot, 0)
	end
end