size = {340,500}

--PID array
local A32nx_FBW = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 120, Integral = 0, Current_error = 0, Min_error = -35, Max_error = 35, Error_offset = 5}
local A32nx_FBW_roll_left =  {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 5, Integral = 0, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_roll_right = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 5, Integral = 0, Current_error = 0, Min_error = -15, Max_error = 15, Error_offset = 0}
local A32nx_FBW_pitch_up =   {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 5, Integral = 0, Current_error = 0, Min_error = -10, Max_error = 10, Error_offset = 0}
local A32nx_FBW_pitch_down = {P_gain = 1, I_gain = 1, D_gain = 10, I_delay = 5, Integral = 0, Current_error = 0, Min_error = -10, Max_error = 10, Error_offset = 0}

--variables
local roll_l_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_l_lim", 0, false, true, false)
local roll_r_lim = createGlobalPropertyf("a321neo/dynamics/FBW/roll_r_lim", 0, false, true, false)
local pitch_u_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_u_lim", 0, false, true, false)
local pitch_d_lim = createGlobalPropertyf("a321neo/dynamics/FBW/pitch_d_lim", 0, false, true, false)

function FBW_PD(pd_array, error)
    local last_error = pd_array.Current_error
	pd_array.Current_error = error + pd_array.Error_offset

	--Proportional--
	local correction = pd_array.Current_error * pd_array.P_gain

	--derivative--
	correction = correction + (pd_array.Current_error - last_error) * pd_array.D_gain

	--limit and rescale output range--
	correction = Math_clamp(correction, pd_array.Min_error, pd_array.Max_error) / pd_array.Max_error

	return correction
end

function FBW_PID(pid_array, error)
    local last_error = pid_array.Current_error
	pid_array.Current_error = error + pid_array.Error_offset

	--Proportional--
	local correction = pid_array.Current_error * pid_array.P_gain

	--integral--
	pid_array.Integral = (pid_array.Integral * (pid_array.I_delay - 1) + pid_array.Current_error) / pid_array.I_delay

	--clamping the integral to minimise the delay
	pid_array.Integral = Math_clamp(pid_array.Integral, pid_array.Min_error, pid_array.Max_error)

	correction = correction + pid_array.Integral * pid_array.I_gain

	--derivative--
	correction = correction + (pid_array.Current_error - last_error) * pid_array.D_gain

	--limit and rescale output range--
	correction = Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error

	return correction
end

--sim datarefs
local roll = globalProperty("sim/joystick/yoke_roll_ratio")
local pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
local yaw = globalProperty("sim/joystick/yoke_heading_ratio")

local roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
local pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
local yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")

local override_artstab = globalProperty("sim/operation/override/override_artstab")

SimDR_roll = globalProperty("sim/flightmodel/position/true_phi")
SimDR_pitch = globalProperty("sim/flightmodel/position/true_theta")
SimDR_yoke_roll = globalProperty("sim/joystick/yoke_roll_ratio")
SimDR_yoke_pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
SimDR_stab_roll = globalProperty("sim/joystick/artstab_roll_ratio")

local elev_trim_ratio = globalProperty("sim/cockpit2/controls/elevator_trim")

--colors--
local FBW_BLACK = {0,0,0}
local FBW_WHITE = {1.0, 1.0, 1.0}
local FBW_BLUE = {0.004, 1.0, 1.0}
local FBW_BLUE_ALPHA = {0.004, 1.0, 1.0, 0.5}
local FBW_GREEN = {0.184, 0.733, 0.219}
local FBW_ORANGE = {0.725, 0.521, 0.18}
local FBW_RED = {1, 0.0, 0.0}
local FBW_ORANGE_ALPHA = {0.725, 0.521, 0.18, 0.5}

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

function update()
    --change menu item state
    if Vnav_debug_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHidePacksDebug, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHidePacksDebug, MENU_UNCHECKED)
    end

    set(pitch_d_lim, FBW_PD(A32nx_FBW_pitch_down, -15 - get(SimDR_pitch)))
    --30 degrees climb
    set(pitch_u_lim, FBW_PD(A32nx_FBW_pitch_up,    30 - get(SimDR_pitch)))
    if get(roll) > 0.1 or get(roll) < -0.1 then
        --67 degrees roll left
        set(roll_l_lim, FBW_PD(A32nx_FBW_roll_left,  - 67 - get(SimDR_roll)))
        --67 degrees roll right
        set(roll_r_lim, FBW_PD(A32nx_FBW_roll_right,   67 - get(SimDR_roll)))
    else
        --30 degrees roll left
        set(roll_l_lim, FBW_PD(A32nx_FBW_roll_left,  - 30 - get(SimDR_roll)))
        --30 degrees roll right
        set(roll_r_lim, FBW_PD(A32nx_FBW_roll_right,   30 - get(SimDR_roll)))
    end

    if get(FBW_on) == 1 then
        set(override_artstab, 1)
        set(roll_artstab, get(roll_l_lim) + get(roll_r_lim))
        set(pitch_artstab, get(pitch_d_lim) + get(pitch_u_lim))

        print("down limit" .. get(pitch_d_lim))
        print("up limit" .. get(pitch_u_lim))
        print(get(pitch_d_lim) + get(pitch_u_lim))
    else
        set(override_artstab, 1)
    end
end

function draw()
    sasl.gl.drawRectangle(0,0,size[1],size[2], FBW_BLACK)
    sasl.gl.drawFrame (20, 20, 300, 300, FBW_WHITE)

    sasl.gl.drawText(B612MONO_regular, 20, 460, "YOU ARE IN:", 28, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    if get(FBW_on) == 1 then
        sasl.gl.drawText(B612MONO_regular, 20, 400, "NORMAL LAW", 40, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, 20, 400, "DIRECT LAW", 40, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
    end
    sasl.gl.drawCircle(size[1]/2 + 150 * get(roll), (size[2]/2-80) - 150 * get(pitch), 10, true, FBW_BLUE_ALPHA)
    sasl.gl.drawRectangle(size[1]/2-10 + 150 * get(roll_artstab), (size[2]/2-90) - 150 * get(pitch_artstab), 20, 20, FBW_ORANGE_ALPHA)
    sasl.gl.drawCircle(size[1]/2 + 150 * 0, (size[2]/2-80) - 150 * get(pitch_d_lim), 10, true, FBW_RED)
    sasl.gl.drawCircle(size[1]/2 + 150 * 0, (size[2]/2-80) - 150 * get(pitch_u_lim), 10, true, FBW_RED)
    sasl.gl.drawCircle(size[1]/2 + 150 * get(roll_l_lim), (size[2]/2-80) - 150 * 0, 10, true, FBW_RED)
    sasl.gl.drawCircle(size[1]/2 + 150 * get(roll_r_lim), (size[2]/2-80) - 150 * 0, 10, true, FBW_RED)

    sasl.gl.drawRectangle(300, 405, 20, 75 * get(elev_trim_ratio), FBW_GREEN)
    sasl.gl.drawFrame (300, 330, 20, 150, FBW_WHITE)
end