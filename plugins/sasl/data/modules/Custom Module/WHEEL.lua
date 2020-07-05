--sim dataref

--a32nx dataref
local groundspeed_kts = createGlobalPropertyf("a321neo/dynamics/groundspeed_kts", 0, false, true, false) --ground speed in kts

function update()
	--convert m/s to kts
	set(groundspeed_kts, get(Ground_speed_ms)*1.94384)

	if get(Aft_wheel_on_ground) == 1 then
		set(Left_brakes_temp, get(Left_brakes_temp) + (get(Actual_brake_ratio) * (0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
		set(Right_brakes_temp, get(Right_brakes_temp) + (get(Actual_brake_ratio) * (0.05 * get(groundspeed_kts)) ^ 1.975) * get(DELTA_TIME))
	end

	if get(Right_brakes_temp) > 380 then
		set(Left_brakes_hot, 1)
	else
		set(Left_brakes_hot, 0)
	end

	if get(Left_brakes_temp) > 380 then
		set(Right_brakes_hot, 1)
	else
		set(Right_brakes_hot, 0)
	end
end