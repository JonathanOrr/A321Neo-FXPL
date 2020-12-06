-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: PID.lua 
-- Short description: This file contains several functions to manage PID controllers
-------------------------------------------------------------------------------

function FBW_P_no_lim(pd_array, error)
    local last_error = pd_array.Current_error
    pd_array.Current_error = error + pd_array.Error_offset

    --Proportional--
    local correction = pd_array.Current_error * pd_array.P_gain

    --limit and rescale output range--
    correction = correction / pd_array.Max_out

    return correction
end

function FBW_PD(pd_array, error)
    local last_error = pd_array.Current_error
    pd_array.Current_error = error + pd_array.Error_offset

    --Proportional--
    local correction = pd_array.Current_error * pd_array.P_gain

    --derivative--
    correction = correction + (pd_array.Current_error - last_error) * pd_array.D_gain

    --limit and rescale output range--
    correction = Math_clamp(correction, pd_array.Min_out, pd_array.Max_out) / pd_array.Max_out

    return correction
end

function SSS_PID_NO_LIM(pid_array, error)
    local correction = 0
    local last_error = pid_array.Current_error

    if get(DELTA_TIME) ~= 0 then

        pid_array.Current_error = error

        --Proportional--
        pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral_sum + (pid_array.Current_error * get(DELTA_TIME)), pid_array.Min_out * (1 / pid_array.I_gain), pid_array.Max_out * (1 / pid_array.I_gain))
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * pid_array.I_gain, pid_array.Min_out * (1 / pid_array.I_gain), pid_array.Max_out * (1 / pid_array.I_gain))

        --derivative--
        pid_array.Derivative = ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain

        --sigma
        correction = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

    end

    return correction
end

function SSS_PID(pid_array, error)
    local last_error = pid_array.Current_error
    local lower_clamp = pid_array.Error_margin * pid_array.Min_out
    local upper_clamp = pid_array.Error_margin * pid_array.Max_out

    if get(DELTA_TIME) ~= 0 then

        if pid_array.Smooth_error == true then
            pid_array.Current_error = Set_anim_value(pid_array.Current_error, error, -1000000000000000, 1000000000000000, pid_array.Error_curve_spd)
        else
            pid_array.Current_error = error
        end

        --Proportional--
        pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

        --derivative--
        if pid_array.Smooth_derivative == true then
            pid_array.Derivative = Set_anim_value(pid_array.Derivative, ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain, -1000000000000000, 1000000000000000, pid_array.Derivative_curve_spd)
        else
            pid_array.Derivative = ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain
        end

        --integral--(clamped to stop windup)
        if pid_array.derivative_in_integral == true then
            if pid_array.I_time ~= 0 then
                if pid_array.Iimit_integration_spd == true then
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + (Math_clamp(pid_array.Current_error, -pid_array.Error_margin, pid_array.Error_margin) / pid_array.I_time * get(DELTA_TIME) + pid_array.Derivative * get(DELTA_TIME) ^ 2), lower_clamp), upper_clamp)
                else
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + (pid_array.Current_error / pid_array.I_time * get(DELTA_TIME) + pid_array.Derivative * get(DELTA_TIME) ^ 2), lower_clamp), upper_clamp)
                end
            else
                pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + 0, lower_clamp), upper_clamp)
            end
        else
            if pid_array.I_time ~= 0 then
                if pid_array.Iimit_integration_spd == true then
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + Math_clamp(pid_array.Current_error, -pid_array.Error_margin, pid_array.Error_margin) / pid_array.I_time * get(DELTA_TIME), lower_clamp), upper_clamp)
                else
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + pid_array.Current_error / pid_array.I_time * get(DELTA_TIME), lower_clamp), upper_clamp)
                end
            else
                pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + 0, lower_clamp), upper_clamp)
            end
        end

        --nil value return 0
        if pid_array.Proportional == nil then
            pid_array.Proportional = 0
        end
        if pid_array.Integral == nil then
            pid_array.Integral = 0
        end
        if pid_array.Derivative == nil then
            pid_array.Derivative = 0
        end

        --sigma
        pid_array.Output = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        pid_array.Output = Math_clamp(pid_array.Output, lower_clamp, upper_clamp) / pid_array.Error_margin

    end

    return pid_array.Output
end

function SSS_PID_DPV(pid_array, Set_Point, PV)
    local last_PV = pid_array.PV
    local lower_clamp = pid_array.Error_margin * pid_array.Min_out
    local upper_clamp = pid_array.Error_margin * pid_array.Max_out

    if get(DELTA_TIME) ~= 0 then

        if pid_array.Smooth_PV == true then
            pid_array.PV = Set_anim_value(pid_array.PV, Set_Point - PV, -1000000000000000, 1000000000000000, pid_array.PV_curve_spd)
        else
            pid_array.PV = PV
        end

        --Proportional--
        pid_array.Proportional = (Set_Point - PV) * pid_array.P_gain

        --derivative--
        if pid_array.Smooth_derivative == true then
            pid_array.Derivative = Set_anim_value(pid_array.Derivative, ((last_PV - pid_array.PV) / get(DELTA_TIME)) * pid_array.D_gain, -1000000000000000, 1000000000000000, pid_array.Derivative_curve_spd)
        else
            pid_array.Derivative = ((last_PV - pid_array.PV) / get(DELTA_TIME)) * pid_array.D_gain
        end

	    --integral--(clamped to stop windup)
        if pid_array.derivative_in_integral == true then
            if pid_array.I_time ~= 0 then
                if pid_array.Iimit_integration_spd == true then
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + (Math_clamp((Set_Point - PV), -pid_array.Error_margin, pid_array.Error_margin) / pid_array.I_time * get(DELTA_TIME) + pid_array.Derivative * get(DELTA_TIME) ^ 2), lower_clamp), upper_clamp)
                else
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + ((Set_Point - PV) / pid_array.I_time * get(DELTA_TIME) + pid_array.Derivative * get(DELTA_TIME) ^ 2), lower_clamp), upper_clamp)
                end
            else
                pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + 0, lower_clamp), upper_clamp)
            end
        else
            if pid_array.I_time ~= 0 then
                if pid_array.Iimit_integration_spd == true then
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + (Math_clamp((Set_Point - PV), -pid_array.Error_margin, pid_array.Error_margin) / pid_array.I_time * get(DELTA_TIME)), lower_clamp), upper_clamp)
                else
                    pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + ((Set_Point - PV) / pid_array.I_time * get(DELTA_TIME)), lower_clamp), upper_clamp)
                end
            else
                pid_array.Integral = Math_clamp_higher(Math_clamp_lower(pid_array.Integral + 0, lower_clamp), upper_clamp)
            end
        end

        --nil value return 0
        if pid_array.Proportional == nil then
            pid_array.Proportional = 0
        end
        if pid_array.Integral == nil then
            pid_array.Integral = 0
        end
        if pid_array.Derivative == nil then
            pid_array.Derivative = 0
        end

        --sigma
        pid_array.Output = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

	    --limit and rescale output range--
        pid_array.Output = Math_clamp(pid_array.Output, lower_clamp, upper_clamp) / pid_array.Error_margin

    end

    return pid_array.Output
end

-- A standard PID with backpropagation as anti-windup
-- You **must** set the pid_array.Actual_output outside of this PID
function SSS_PID_BP(pid_array, error)

    if get(DELTA_TIME) == 0 then
        return 0
    end

    local last_error = pid_array.Current_error
    pid_array.Current_error = error

    --Proportional--
    pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

    --integral--
    pid_array.Backpropagation = pid_array.B_gain * (pid_array.Actual_output - pid_array.Desired_output)
    local integral_input = pid_array.I_gain * pid_array.Current_error + pid_array.Backpropagation
    
    pid_array.Integral_sum = pid_array.Integral_sum + (integral_input * get(DELTA_TIME))
    pid_array.Integral = pid_array.Integral_sum

    --derivative--
    if get(DELTA_TIME) > 0 then
        pid_array.Derivative = ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain
    else
        pid_array.Derivative = 0
    end
    -- This is the output the controller wants to enforce, but it is not necessarily the real one
    pid_array.Desired_output = pid_array.Proportional + pid_array.Integral + pid_array.Derivative

    return pid_array.Desired_output
end

-- A standard PID with backpropagation as anti-windup and output limit (Actual_output is automatically updated)
function SSS_PID_BP_LIM(pid_array, error)
    local desired_u = SSS_PID_BP(pid_array, error)
    local actual_u  = Math_clamp(desired_u, pid_array.Min_out, pid_array.Max_out)
    pid_array.Actual_output = actual_u
    return actual_u
end

function FBW_PID_no_lim(pid_array, error)
    local last_error = pid_array.Current_error
    pid_array.Current_error = error + pid_array.Error_offset

    --Proportional--
    local correction = pid_array.Current_error * pid_array.P_gain

    --integral--
    pid_array.Integral = (pid_array.Integral * (pid_array.I_delay - 1) + pid_array.Current_error) / pid_array.I_delay

    --clamping the integral to minimise the delay

    pid_array.Integral = Math_clamp(pid_array.Integral, pid_array.Min_out, pid_array.Max_out)

    correction = correction + pid_array.Integral * pid_array.I_gain

    --derivative--
    correction = correction + (pid_array.Current_error - last_error) * pid_array.D_gain

    --limit and rescale output range--
    correction = correction / pid_array.Max_out

    return correction
end



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- FILTERS
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- ** Instructions **
-- Create a table with two parameters: the current x value and the cut frequency in Hz:
--
-- data = {
--    x = 0,
--    cut_frequency = 10
-- }
--
-- Then, set data.x to the proper value and call the filter (e.g. y = high_pass_filter(data)) to get
-- the filtered value (y). The next time, set again data.x and recall the filter funciton.
--
-- VERY IMPORTANT (1): the variable you pass to the filter function must be preserved across filter
--                     invocations. (The filter writes stuffs inside data!)
-- VERY IMPORTANT (2): the filter function expects data FOR EACH frame after the first invocation,
--                     otherwise garbage will be computed.


function high_pass_filter(data)
    local dt = get(DELTA_TIME)
    local RC = 1/(2*math.pi*data.cut_frequency)
    local a = RC / (RC + dt)
    
    if data.prev_x_value == nil then
        data.prev_x_value = data.x
        data.prev_y_value = data.x
        return data.x
    end
    return a * (data.prev_y_value + data.x - data.prev_x_value)
end

function low_pass_filter(data)
    local dt = get(DELTA_TIME)
    local RC = 1/(2*math.pi*data.cut_frequency)
    local a = dt / (RC + dt)
    
    if data.prev_y_value == nil then
        data.prev_y_value = a * data.x
        return a * data.x
    end
    return a * data.x + (1-a) * data.prev_y_value
end


