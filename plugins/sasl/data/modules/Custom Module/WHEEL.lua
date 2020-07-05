local left_brake_ratio = globalProperty("sim/flightmodel/controls/l_brake_add")
local right_brake_ratio = globalProperty("sim/flightmodel/controls/r_brake_add")
local groundspeed = globalProperty("sim/flightmodel/position/groundspeed")

local left_gear_temp = createGlobalPropertyf("a321neo/cockpit/wheel/left_gear_temp", 0, false, true, false) --left gear temperature
local right_gear_temp = createGlobalPropertyf("a321neo/cockpit/wheel/right_gear_temp", 0, false, true, false) --right gear temperature
local hot_brakes = createGlobalPropertyi("a321neo/cockpit/wheel/hot_brakes", 0, false, true, false) --brake temp >300

local function brakes()
	if  sim/flightmodel/controls/l_brake_add > 0 
		set(left_gear_temp, get(left_gear_temp) + (get (left_brake_ratio)* (0.08 * get (groundspeed))^2.25))
	end
	if  sim/flightmodel/controls/r_brake_add > 0 
		set(right_gear_temp, get(left_gear_temp) + (get right_brake_ratio)* (0.08 * get (groundspeed))^2.25))
	end
	if get(left_gear_temp) >= 300 or (right_gear_temp) >= 300 then
            set(hot_brakes, 1)
	end
end