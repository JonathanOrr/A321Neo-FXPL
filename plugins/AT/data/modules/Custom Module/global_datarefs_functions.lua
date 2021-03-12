--[[A32NX Adaptive Auto Throttle
Copyright (C) 2020 Jonathan Orr

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.]]

--global dataref variable from the Sim
SimDR_aircraft_ias = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
SimDR_aircraft_acceleration = globalProperty("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot") --kts per second
SimDR_manual_set_thro = globalProperty("sim/flightmodel/engine/ENGN_thro_use[0]")
SimDR_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio_all")
SimDR_override_throttle = globalProperty("sim/operation/override/override_throttles")
SimDR_override_artstab = globalProperty("sim/operation/override/override_artstab")
DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")

--global a32nx datarefs
A32nx_autothrust_on = createGlobalPropertyi("a32nx/debug/auto_thrust_on", 0, false, true, false)
A32nx_target_spd = createGlobalPropertyi("a32nx/debug/target_speed", 180, false, true, false)
A32nx_thrust_control_output = createGlobalPropertyf("a32nx/debug/thrust_control_output", 0, false, true, false)

--flight controls
Roll = globalProperty("sim/joystick/yoke_roll_ratio")
Pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
Yaw = globalProperty("sim/joystick/yoke_heading_ratio")
Roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
Pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
Yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")
Servo_roll = globalProperty("sim/joystick/servo_roll_ratio")
Servo_pitch = globalProperty("sim/joystick/servo_pitch_ratio")
Servo_yaw = globalProperty("sim/joystick/servo_heading_ratio")
Speedbrake_handle_ratio = globalProperty("sim/cockpit2/controls/speedbrake_ratio")
Flaps_handle_ratio = globalProperty("sim/cockpit2/controls/flap_ratio")
Flaps_handle_deploy_ratio = globalProperty("sim/cockpit2/controls/flap_handle_deploy_ratio")

Total_vertical_g_load = globalProperty("sim/flightmodel/forces/g_nrml")
Vpath = globalProperty("sim/flightmodel/position/vpath")
Alpha = globalProperty("sim/flightmodel/position/alpha")

Capt_IAS     = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
Fo_IAS       = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_copilot")
Capt_Baro_Alt= globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
Fo_Baro_Alt  = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_copilot")
Capt_TAT = globalProperty("sim/cockpit2/gauges/indicators/true_airspeed_kts_pilot")
Ground_speed_ms = globalProperty("sim/flightmodel/position/groundspeed")
Gear_handle = globalProperty("sim/cockpit2/controls/gear_handle_down")
Aircraft_total_weight_kgs = globalProperty("sim/flightmodel/weight/m_total")
Flightmodel_roll = globalProperty("sim/flightmodel/position/true_phi")
Flightmodel_pitch = globalProperty("sim/flightmodel/position/true_theta")
Roll_rate = globalProperty("sim/flightmodel/position/P")
Pitch_rate = globalProperty("sim/flightmodel/position/Q")

Elev_trim_ratio = globalProperty("sim/cockpit2/controls/elevator_trim")
Rudder_trim_ratio = globalProperty("sim/cockpit2/controls/rudder_trim")
Horizontal_stabilizer_pitch = globalProperty("sim/flightmodel2/controls/stabilizer_deflection_degrees")

Override_artstab = globalProperty("sim/operation/override/override_artstab")
Override_control_surfaces = globalProperty("sim/operation/override/override_control_surfaces")


--global pid array
Bank_angle_PID_array = {
    P_gain = 1.250,
    I_gain = 0.000,
    D_gain = 0.002,
    B_gain = 0,
    Schedule_gains = false,
    Schedule_table = {
        P = {
            {000, 0.000},
        },
        I = {
            {000, 0.000},
        },
        D = {
            {000, 0.000},
        },
    },
    Limited_integral = true,
    min_integral = -25,
    max_integral = 25,
    Min_out = -25,
    Max_out = 25,
    PV = 0,
    Error = 0,
    Proportional = 0,
    Integral = 0,
    Derivative = 0,
    Backpropagation = 0,
    Desired_output = 0,
    Actual_output = 0,
}
Pitch_PID_array = {
    P_gain = 0.0018,
    I_gain = 0.0020,
    D_gain = 0.0001,
    B_gain = 1,
    Schedule_gains = false,
    Schedule_table = {
        P = {
            {000, 0.000},
        },
        I = {
            {000, 0.000},
        },
        D = {
            {000, 0.000},
        },
    },
    Limited_integral = true,
    min_integral = -25,
    max_integral = 25,
    Min_out = -25,
    Max_out = 25,
    PV = 0,
    Error = 0,
    Proportional = 0,
    Integral = 0,
    Derivative = 0,
    Backpropagation = 0,
    Desired_output = 0,
    Actual_output = 0,
}

A32nx_auto_thrust = {P_gain = 1.6, I_time = 5, D_gain = 4.5, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, PV = 0, Min_out = 0, Max_out = 1, Error_margin = 15}
A32nx_FD_roll = {P_gain = 1, I_gain = 0, D_gain = 0.32, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Current_error = 0, Min_error = -15, Max_error = 15}
A32nx_FD_pitch = {P_gain = 1, I_gain = 1/3, D_gain = 0.35, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Current_error = 0, Min_error = -12000, Max_error = 12000}
A32nx_rwy_roll = {P_gain = 1, I_gain = 0, D_gain = 2, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Current_error = 0, Min_error = -30, Max_error = 30}
A32nx_stick_roll = {P_gain = 1, I_gain = 0, D_gain = 2, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Current_error = 0, Min_error = -30, Max_error = 30}
A32nx_stick_pitch = {P_gain = 4, I_gain = 0.5, D_gain = 6, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Current_error = 0, Min_error = -30, Max_error = 30}

Autothrust_output = 0
Smoothed_PV = 0

--linear interpolation
function Math_lerp(pos1, pos2, perc)
    return (1-perc)*pos1 + perc*pos2 -- Linear Interpolation
end

--rounding
function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
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

function Math_clamp_lower(val, min)
    if val < min then
        return min
    elseif val >= min then
        return val
    end
end

function Math_clamp_higer(val, max)
    if val > max then
        return max
    elseif val <= max then
        return val
    end
end

--string functions--
--append string_to_fill_it_with to the front of a string to achive the length of to_what_length
function Fwd_string_fill(string_to_fill, string_to_fill_it_with, to_what_length)
    for i = #string_to_fill, to_what_length - 1 do
        string_to_fill = string_to_fill_it_with .. string_to_fill
    end

    return string_to_fill
end

--append string_to_fill_it_with to the end of a string to achive the length of to_what_length
function Aft_string_fill(string_to_fill, string_to_fill_it_with, to_what_length)
    for i = #string_to_fill, to_what_length - 1 do
        string_to_fill = string_to_fill .. string_to_fill_it_with
    end

    return string_to_fill
end

function Set_dataref_linear_anim(dataref, target, min, max, speed)
    set(dataref, Set_linear_anim_value(get(dataref), target, min, max, speed))
end

function Table_interpolate(tab, x)
    local a = 1
    local b = #tab
    assert(b > 1)

    -- Simple cases
    if x <= tab[a][1] then
        return tab[a][2]
    end
    if x >= tab[b][1] then
        return tab[b][2]
    end

    local middle = 1

    while b-a > 1 do
        middle = math.floor((b+a)/2)
        local val = tab[middle][1]
        if val == x then
            break
        elseif val < x then
            a = middle
        else
            b = middle
        end
    end

    if x == tab[middle][1] then
        -- Found a perfect value
        return tab[middle][2]
    else
        -- (y-y0) / (y1-y0) = (x-x0) / (x1-x0)
        return tab[a][2] + ((x-tab[a][1])*(tab[b][2]-tab[a][2]))/(tab[b][1]-tab[a][1])
    end
end

--global functions

--[[historical PID versions
function A32nx_PID(pid_array, error)
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
	--print((pid_array.Current_error - last_error) * pid_array.D_gain)

	correction = correction + (pid_array.Current_error - last_error) * pid_array.D_gain

	--limit and rescale output range--
	correction = Math_clamp(Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error , 0, 1)

	return correction
end

function A32nx_PID_time_indep(pid_array, error)
    local last_error = pid_array.Current_error

    if get(DELTA_TIME) ~= 0 then
        pid_array.Current_error = error

	    --Proportional--
	    local correction = pid_array.Current_error * pid_array.P_gain

	    --integral--
	    pid_array.Integral = (pid_array.Integral * (pid_array.I_delay - 1) + pid_array.Current_error * get(DELTA_TIME)) / pid_array.I_delay

	    --clamping the integral to minimise the delay
	    pid_array.Integral = Math_clamp(pid_array.Integral, pid_array.Min_error, pid_array.Max_error)

	    correction = correction + pid_array.Integral * pid_array.I_gain

	    --derivative--
	    correction = correction + (((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain )

	    --limit and rescale output range--
        correction = Math_clamp(Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error , 0, 1)

	    return correction

    end

end]]

--new PID with improved integral calculation
function NEW_PID(pid_array, Set_Point, PV)
    local correction = 0
    local last_PV = pid_array.PV

    if get(DELTA_TIME) ~= 0 then

        pid_array.PV = PV

        --Proportional--
        pid_array.Proportional = (Set_Point - PV) * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral_sum + ((Set_Point - PV) * get(DELTA_TIME)), pid_array.Error_margin * pid_array.Min_out * pid_array.I_time, pid_array.Error_margin * pid_array.Max_out * pid_array.I_time)
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * 1 / pid_array.I_time, pid_array.Error_margin * pid_array.Min_out, pid_array.Error_margin * pid_array.Max_out)

        --derivative--
        pid_array.Derivative = ((last_PV - pid_array.PV) / get(DELTA_TIME)) * pid_array.D_gain

        --sigma
        correction = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        correction = Math_clamp(correction, pid_array.Error_margin * pid_array.Min_out, pid_array.Error_margin * pid_array.Max_out) / pid_array.Error_margin

    end

    return correction

end

function A32nx_PID_new_neg_avail(pid_array, error)
    local correction = 0
    local last_error = pid_array.Current_error

    if get(DELTA_TIME) ~= 0 then

        pid_array.Current_error = error

        --Proportional--
        pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral_sum + (pid_array.Current_error * get(DELTA_TIME)), pid_array.Min_error * (1 / pid_array.I_gain), pid_array.Max_error * (1 / pid_array.I_gain))
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * pid_array.I_gain, pid_array.Min_error * (1 / pid_array.I_gain), pid_array.Max_error * (1 / pid_array.I_gain))

        --derivative--
        pid_array.Derivative = ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain

        --sigma
        correction = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        correction = Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error

    end

    return correction

end

function FBW_PID_BP(pid_array, Error, PV, Scheduling_variable)
    --sim paused no need to control
    if get(DELTA_TIME) == 0 then
        return 0
    end

    --gain scheduling
    if pid_array.Schedule_gains == true then
        pid_array.P_gain = Table_interpolate(pid_array.Schedule_table.P, Scheduling_variable)
        pid_array.I_gain = Table_interpolate(pid_array.Schedule_table.I, Scheduling_variable)
        pid_array.D_gain = Table_interpolate(pid_array.Schedule_table.D, Scheduling_variable)
    end

    --Properties--
    local last_PV = pid_array.PV

    --inputs--
    pid_array.PV = PV
    pid_array.Error = Error

    --Proportional--
    pid_array.Proportional = pid_array.Error * pid_array.P_gain

    --Back Propagation--
    pid_array.Backpropagation = pid_array.B_gain * (pid_array.Actual_output - pid_array.Desired_output)

    --Integral--
    local intergal_to_add = pid_array.I_gain * pid_array.Error + pid_array.Backpropagation
    pid_array.Integral = pid_array.Integral + intergal_to_add * get(DELTA_TIME)

    if pid_array.Limited_integral then
        pid_array.Integral = Math_clamp(pid_array.Integral, pid_array.min_integral, pid_array.max_integral)
    end

    --Derivative
    pid_array.Derivative = ((last_PV - pid_array.PV) / get(DELTA_TIME)) * pid_array.D_gain

    --Sigma
    pid_array.Desired_output = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

    --Output--
    return Math_clamp(pid_array.Desired_output, pid_array.Min_out, pid_array.Max_out)
end

function Set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
    end

end

function Rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function Set_linear_anim_value(current_value, target, min, max, speed)
    if get(DELTA_TIME) ~= 0 then
        if target - current_value < (speed + (speed * 0.005)) * get(DELTA_TIME) and target - current_value > -(speed + (speed * 0.005)) * get(DELTA_TIME) then
            return Math_clamp(target, min, max)
        elseif target < current_value then
            return Math_clamp(current_value - (speed * get(DELTA_TIME)), min, max)
        elseif target > current_value then
            return Math_clamp(current_value + (speed * get(DELTA_TIME)), min, max)
        end
    end
end