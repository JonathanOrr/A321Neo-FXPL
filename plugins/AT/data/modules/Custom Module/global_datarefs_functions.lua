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
DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")

--global a32nx datarefs
A32nx_autothrust_on = createGlobalPropertyi("a32nx/debug/auto_thrust_on", 0, false, true, false)
A32nx_target_spd = createGlobalPropertyi("a32nx/debug/target_speed", 225, false, true, false)
A32nx_thrust_control_output = createGlobalPropertyf("a32nx/debug/thrust_control_output", 0, false, true, false)

--global pid array
A32nx_auto_thrust = {P_gain = 0.55, I_gain = 10, D_gain = 0.75, I_delay = 100, Integral = 0, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 5}
A32nx_auto_thrust_trim = {P_gain = 0.55, I_gain = 10, D_gain = 0.75, I_delay = 100, Integral = 0, Current_error = 0, Min_error = -5, Max_error = 5, Error_offset = 0}

Autothrust_output = 0
Smoothed_error = 0


--experimental
D_value = 0

--global functions
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
        pid_array.Current_error = error + pid_array.Error_offset

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

        D_value = (((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain )
	    return correction

    end

end

function set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
    end

end

function rescale(in1, out1, in2, out2, x)

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