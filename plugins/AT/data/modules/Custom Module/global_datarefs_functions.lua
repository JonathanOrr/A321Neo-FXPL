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

--global pid array
A32nx_auto_thrust = {P_gain = 1.1, I_gain = 1, D_gain = 3.5, I_time = 5, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Integral_min = -15, Integral_max = 15, Current_error = 0, Min_error = -15, Max_error = 15}
A32nx_FD_roll = {P_gain = 1, I_gain = 0, D_gain = 0.32, I_time = 1, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Integral_min = -10, Integral_max = 10, Current_error = 0, Min_error = -15, Max_error = 15}
A32nx_FD_pitch = {P_gain = 1, I_gain = 1, D_gain = 1, I_time = 3, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Integral_min = -12000, Integral_max = 12000, Current_error = 0, Min_error = -12000, Max_error = 12000}
A32nx_rwy_roll = {P_gain = 1, I_gain = 0, D_gain = 2, I_time = 1, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Integral_min = -30, Integral_max = 30, Current_error = 0, Min_error = -30, Max_error = 30}
A32nx_stick_roll = {P_gain = 1, I_gain = 0, D_gain = 2, I_time = 1, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Integral_min = -30, Integral_max = 30, Current_error = 0, Min_error = -30, Max_error = 30}
A32nx_stick_pitch = {P_gain = 4, I_gain = 1, D_gain = 6, I_time = 2, Proportional = 0, Integral_sum = 0, Integral = 0, Derivative = 0, Integral_min = -30, Integral_max = 30, Current_error = 0, Min_error = -30, Max_error = 30}

Autothrust_output = 0
Smoothed_error = 0

--rounding
function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
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
function A32nx_PID_new(pid_array, error)
    local correction = 0
    local last_error = pid_array.Current_error
    pid_array.Current_error = error

    if get(DELTA_TIME) ~= 0 then

        --Proportional--
        pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral + (pid_array.Current_error * get(DELTA_TIME)) / pid_array.I_time, pid_array.Integral_min, pid_array.Integral_max)
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * pid_array.I_gain, pid_array.Integral_min, pid_array.Integral_max)

        --derivative--
        pid_array.Derivative = ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain

        --sigma
        correction = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        correction = Math_clamp(Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error , 0, 1)

	    return correction

    end

end

function A32nx_PID_new_neg_avail(pid_array, error)
    local correction = 0
    local last_error = pid_array.Current_error
    pid_array.Current_error = error

    if get(DELTA_TIME) ~= 0 then

        --Proportional--
        pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral + (pid_array.Current_error * get(DELTA_TIME)) / pid_array.I_time, pid_array.Integral_min, pid_array.Integral_max)
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * pid_array.I_gain, pid_array.Integral_min, pid_array.Integral_max)

        --derivative--
        pid_array.Derivative = ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain

        --sigma
        correction = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        correction = Math_clamp(correction, pid_array.Min_error, pid_array.Max_error) / pid_array.Max_error

	    return correction

    end

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