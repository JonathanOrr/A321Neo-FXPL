-- librain.lua

-- check if librain.plugin is present, otherwise bail out
-- in both case send message to log file
if findPluginBySignature("skiselkov.librain") == NO_PLUGIN_ID then
	logInfo("librain.plugin by Saso Kiselkov not found, disabling rain effects")
	return
end
logInfo("librain.plugin by Saso Kiselkov found")

-- prefix for objects used by librain
local obj_path	= getAircraftPath() .. "/objects/"

-- pairs of dataref/value
local drf	= {
	"librain/verbose"			, 1,
	"librain/debug_draw"		, 0,
	"librain/wipers_visible"	, 0,

	"librain/glass_0/slant_factor"		,  1.0,
	"librain/glass_0/thrust_point/x"	,  0.7,
	"librain/glass_0/thrust_point/y"	, -0.45,
	"librain/glass_0/thrust_factor"		,  0.5,
	"librain/glass_0/max_thrust"		, 1500,
	"librain/glass_0/gravity_point/x"	, 0.7,
	"librain/glass_0/gravity_point/y"	, 0.85,
	"librain/glass_0/gravity_factor"	, 0.8,
	"librain/glass_0/wind_point/x"		,  0.0,
	"librain/glass_0/wind_point/y"		, 0.0,
	"librain/glass_0/wind_factor"		,  1.0,
	"librain/glass_0/wind_normal"		,  1.0,
	"librain/glass_0/max_tas"			, 80,
	"librain/glass_0/obj/filename"		, obj_path .. "windows/cockpit outter windows.obj",
	"librain/glass_0/obj/pos_offset/x"	,  0,
	"librain/glass_0/obj/pos_offset/y"	,  -0.00,
	"librain/glass_0/obj/pos_offset/z"	, 0.0,
	"librain/glass_0/obj/load"			, 1,

	"librain/z_depth_obj_0/filename"	, obj_path .. "cockpit.obj",
	"librain/z_depth_obj_0/pos_offset/x",  0,
	"librain/z_depth_obj_0/pos_offset/y",  0,
	"librain/z_depth_obj_0/pos_offset/z", 0.0,
	"librain/z_depth_obj_0/load"		,  1,

	-- "librain/z_depth_obj_1/filename"	, obj_path .. "fuselage.obj",
	-- "librain/z_depth_obj_1/pos_offset/x",  0,
	-- "librain/z_depth_obj_1/pos_offset/y",  0,
	-- "librain/z_depth_obj_1/pos_offset/z", 0.0,
	-- "librain/z_depth_obj_1/load"		,  1,


	"librain/num_glass_use"				,  1,
	"librain/initialize"				,  1,
}

local done = false
function update()
	-- do the initialization on first frame only
	if done then return end
	done = true

	-- populate datarefs, last one being initialize
	for i = 1, #drf, 2 do
		set(globalProperty(drf[i]), drf[i+1])
	end
	logInfo("librain initialization complete")
end
