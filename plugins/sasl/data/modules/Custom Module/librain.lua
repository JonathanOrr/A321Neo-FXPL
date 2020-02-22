-- Define datarefs for windshield
local windshieldObj = {
	obj = globalPropertys("librain/glass_0/obj/filename"),
	load = globalPropertyi("librain/glass_0/obj/load"),
	slant = globalPropertyf("librain/glass_0/slant_factor"),
	gp_x = globalPropertyf("librain/glass_0/gravity_point/x"),
	gp_y = globalPropertyf("librain/glass_0/gravity_point/y"),
	gravity_factor = globalPropertyf("librain/glass_0/gravity_factor"),
	tp_x = globalPropertyf("librain/glass_0/thrust_point/x"),
	tp_y = globalPropertyf("librain/glass_0/thrust_point/y"),
	thrust_factor = globalPropertyf("librain/glass_0/thrust_factor"),
	max_thrust = globalPropertyf("librain/glass_0/max_thrust"),
	wp_x = globalPropertyf("librain/glass_0/wind_point/x"),
	wp_y = globalPropertyf("librain/glass_0/wind_point/y"),
	wind_factor = globalPropertyf("librain/glass_0/wind_factor"),
	wind_normal = globalPropertyf("librain/glass_0/wind_normal"),
	max_tas = globalPropertyf("librain/glass_0/max_tas"),
	wiper_pivot_x = globalPropertyf("librain/glass_0/wiper_0/pivot/x"),
	wiper_pivot_y = globalPropertyf("librain/glass_0/wiper_0/pivot/y"),
	wiper_radius_outer = globalPropertyf("librain/glass_0/wiper_0/radius_outer"),
	wiper_radius_inner = globalPropertyf("librain/glass_0/wiper_0/radius_inner"),
	wiper_is_moving = globalPropertyf("librain/glass_0/wiper_0/moving"),
	wiper_angle_dr = globalPropertyfa("sim/flightmodel2/misc/wiper_angle_deg"),
	wiperAngle = globalPropertyf("librain/glass_0/wiper_0/angle"),
	wiper_speed = globalPropertyf("sim/cockpit2/switches/wiper_speed")
}

-- Define datarefs for side-window
local sideWindowObj = {
	obj = globalPropertys("librain/glass_1/obj/filename"),
	load = globalPropertyi("librain/glass_1/obj/load"),
	slant = globalPropertyf("librain/glass_1/slant_factor"),
	gp_x = globalPropertyf("librain/glass_1/gravity_point/x"),
	gp_y = globalPropertyf("librain/glass_1/gravity_point/y"),
	gravity_factor = globalPropertyf("librain/glass_1/gravity_factor"),
	tp_x = globalPropertyf("librain/glass_1/thrust_point/x"),
	tp_y = globalPropertyf("librain/glass_1/thrust_point/y"),
	thrust_factor = globalPropertyf("librain/glass_1/thrust_factor"),
	max_thrust = globalPropertyf("librain/glass_1/max_thrust"),
	wp_x = globalPropertyf("librain/glass_1/wind_point/x"),
	wp_y = globalPropertyf("librain/glass_1/wind_point/y"),
	wind_factor = globalPropertyf("librain/glass_1/wind_factor"),
	wind_normal = globalPropertyf("librain/glass_1/wind_normal"),
	max_tas = globalPropertyf("librain/glass_1/max_tas")
}

-- Define datarefs for z_depth object
local z_obj = {
	obj0_name = globalPropertys("librain/z_depth_obj_0/filename"),
	obj0_load = globalPropertyi("librain/z_depth_obj_0/load"),
	obj0_loaded = globalPropertyi("librain/z_depth_obj_0/loaded"),
}

-- Define librain properties
local rain = {
	numglass = globalPropertyi("librain/num_glass_use"),
	init = globalPropertyi("librain/initialize"),
	init_success = globalPropertyi("librain/init_success"),
	debug_draw = globalPropertyi("librain/debug_draw"),
	wipers = globalPropertyi("librain/wipers_visible"),
	verbose = globalPropertyi("librain/verbose"),
}

local rain_inited = false

function initRain()
	rain_inited = true
	local acf_folder_mod = sasl.getAircraftPath()
	local is_librain_installed = 0
	if get(rain.init) ~= nil then is_librain_installed = 1 end

	if is_librain_installed ~= 0 then
		set(rain.verbose, 1)
		set(rain.debug_draw, 0)
		set(rain.numglass, 3)
		set(rain.wipers, 0)

		set(windshieldObj.obj, acf_folder_mod.."/objects/windows frames.obj")
		set(windshieldObj.slant, 1.2)
		set(windshieldObj.gp_x, 0.5)
		set(windshieldObj.gp_y, 2.0)
		set(windshieldObj.gravity_factor, 0.7)
		set(windshieldObj.tp_x, 0.5)
		set(windshieldObj.tp_y, -1.5)
		set(windshieldObj.thrust_factor, 0.0)
		set(windshieldObj.max_thrust, 0.0)
		set(windshieldObj.wp_x, 0.5)
		set(windshieldObj.wp_y, -1.5)
		set(windshieldObj.wind_factor, 1.0)
		set(windshieldObj.wind_normal, 0.8)
		set(windshieldObj.max_tas, 60)
		set(windshieldObj.wiper_pivot_x, 0.8)
		set(windshieldObj.wiper_pivot_y, 0.38)
		set(windshieldObj.wiper_radius_inner, 0.22)
		set(windshieldObj.wiper_radius_outer, 0.55)
		set(windshieldObj.load, 1)

		set(sideWindowObj.obj, acf_folder_mod.."/objects/cockpit.obj")
		set(sideWindowObj.slant, 1)
		set(sideWindowObj.gp_x, 0.5)
		set(sideWindowObj.gp_y, 2.0)
		set(sideWindowObj.gravity_factor, 0.9)
		set(sideWindowObj.tp_x, 2)
		set(sideWindowObj.tp_y, 0.5)
		set(sideWindowObj.thrust_factor, 0)
		set(sideWindowObj.max_thrust, 0)
		set(sideWindowObj.wp_x, 0.5)
		set(sideWindowObj.wp_y, -1.5)
		set(sideWindowObj.wind_factor, 1)
		set(sideWindowObj.wind_normal, 0.8)
		set(sideWindowObj.max_tas, 60)
		set(sideWindowObj.load, 1)

		-- Object contains all elements which can obstruct the glass' view
		-- Pereferably a low-poly version
		set(z_obj.obj0_name, acf_folder_mod.."/objects/z_obj.obj")
		set(z_obj.obj0_load, 1)
	end
end

function update()
	-- This should go to onPlaneLoaded() but seems like the function is not called when the plane is loaded. Maybe a SASL3 bug?
	if (rain_inited == false) then
		initRain()
	end
	if get(rain.init_success) == 0 then
		set(rain.init, 1)
	else
		-- Calculate the wiper angle - it's preferred to use custom animation as
		-- when "sim/cockpit2/switches/wiper_speed" set to 0 and the wiper was in motion it will still return to default position
		-- However, you have to set "librain/glass_0/wiper_0/moving" to 0 to stop the "cleaning" of the window
		local wiperAngleRadians = 10
		set(windshieldObj.wiperAngle, wiperAngleRadians)
		if (get(windshieldObj.wiper_speed) > 0) then
			set(windshieldObj.wiper_is_moving, 1)
		else
			set(windshieldObj.wiper_is_moving, 0)
		end
	end
end

function onModuleDone()
	-- Unload rain plugin
	set(rain.init, 0)
end

-- Must add to main lua to prevent CTD when the plane crashes
function onPlaneCrash ()
	return 0
end
