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
    else
        data.prev_y_value = a * (data.prev_y_value + data.x - data.prev_x_value)
        data.prev_x_value = data.x
    end

    return data.prev_y_value
end

function low_pass_filter(data)
    local dt = get(DELTA_TIME)
    local RC = 1/(2*math.pi*data.cut_frequency)
    local a = dt / (RC + dt)

    if data.prev_y_value == nil then
        data.prev_y_value = a * data.x
    else
        data.prev_y_value = a * data.x + (1-a) * data.prev_y_value
    end

    return data.prev_y_value
end

----------------------------------------FBW PID----------------------------------------
function FBW_PID_BP(PID, SP, PV, Scheduling_variable)
    --filtering--
    if PID.filter_inputs == true then
        if PID.er_filter_table == nil then
            PID.er_filter_table = {
                x = 0,
                cut_frequency = PID.error_freq,
            }
        end
        if PID.pv_filter_table == nil then
            PID.pv_filter_table = {
                x = 0,
                cut_frequency = PID.dpvdt_freq,
            }
        end
    end

    --sim paused no need to control
    if get(DELTA_TIME) == 0 then
        return 0
    end

    --gain scheduling
    if PID.Schedule_gains == true then
        PID.P_gain = Table_interpolate(PID.Schedule_table.P, Scheduling_variable)
        PID.I_gain = Table_interpolate(PID.Schedule_table.I, Scheduling_variable)
        PID.D_gain = Table_interpolate(PID.Schedule_table.D, Scheduling_variable)
    end

    --Properties--
    local last_PV = PID.PV

    --inputs--
    if PID.filter_inputs == true then
        PID.er_filter_table.x = SP - PV
        PID.pv_filter_table.x = PV
        if PID.highpass_inputs == true then
            PID.Error = high_pass_filter(PID.er_filter_table)
            PID.PV = high_pass_filter(PID.pv_filter_table)
        else
            PID.Error = low_pass_filter(PID.er_filter_table)
            PID.PV = low_pass_filter(PID.pv_filter_table)
        end
    else
        PID.Error = SP - PV
        PID.PV = PV
    end

    --Proportional--
    PID.Proportional = PID.Error * PID.P_gain

    --Back Propagation--
    PID.Backpropagation = PID.B_gain * (PID.Actual_output - PID.Desired_output)

    --Integral--
    local intergal_to_add = PID.I_gain * PID.Error + PID.Backpropagation
    PID.Integral = PID.Integral + intergal_to_add * get(DELTA_TIME)

    if PID.Limited_integral then
        PID.Integral = Math_clamp(PID.Integral, PID.Min_out, PID.Max_out)
    end

    --Derivative
    PID.Derivative = ((last_PV - PID.PV) / get(DELTA_TIME)) * PID.D_gain

    --Sigma
    PID.Desired_output = PID.Proportional + PID.Integral + PID.Derivative

    --[SPECIAL CASE WITH LIMITED INTEGRALS]--
    if PID.Limited_integral then
        PID.Desired_output = Math_clamp(PID.Desired_output, PID.Min_out, PID.Max_out)
        return PID.Desired_output
    else
        return Math_clamp(PID.Desired_output, PID.Min_out, PID.Max_out)
    end
end

local PID_INTERNALS = {
    INIT_PID = function (PID)
        if not PID.filter_inputs then return end

        --INIT FILTER TABLE--
        if PID.er_filter_table == nil then
            PID.er_filter_table = {
                x = 0,
                cut_frequency = PID.error_freq,
            }
        end
        if PID.pv_filter_table == nil then
            PID.pv_filter_table = {
                x = 0,
                cut_frequency = PID.dpvdt_freq,
            }
        end
    end,
    INIT_FEEDFWD = function (FF_PID, PID)
        if PID.feedfwd == nil then
            PID.feedfwd = 0
        end

        --INIT FEED-FORWARD FILTER TABLE--
        if FF_PID.filter_feedfwd then
            if FF_PID.feedfwd_filter_table == nil then
                FF_PID.feedfwd_filter_table = {
                    x = 0,
                    cut_frequency = FF_PID.feedfwd_freq,
                }
            end
        end
    end,
    GAIN_SCHEDULING = function (PID, SCHED_VAR)
        if not PID.Schedule_gains then return end

        PID.P_gain = Table_interpolate(PID.Schedule_table.P, SCHED_VAR)
        PID.I_gain = Table_interpolate(PID.Schedule_table.I, SCHED_VAR)
        PID.D_gain = Table_interpolate(PID.Schedule_table.D, SCHED_VAR)
    end,
    BP = function (PID)
        PID.Backpropagation = PID.B_gain * (PID.Actual_output - PID.Desired_output)
    end,
    PID = function (PID, SP, PV)
        if get(DELTA_TIME) == 0 then return end

        local last_PV = PID.PV

        --INPUTS--
        if PID.filter_inputs == true then
            PID.er_filter_table.x = SP - PV
            PID.pv_filter_table.x = PV
            if PID.highpass_inputs == true then
                PID.Error = high_pass_filter(PID.er_filter_table)
                PID.PV = high_pass_filter(PID.pv_filter_table)
            else
                PID.Error = low_pass_filter(PID.er_filter_table)
                PID.PV = low_pass_filter(PID.pv_filter_table)
            end
        else
            PID.Error = SP - PV
            PID.PV = PV
        end

        --Proportional--
        PID.Proportional = PID.Error * PID.P_gain

        --Integral--
        local intergal_to_add = PID.I_gain * PID.Error + PID.Backpropagation
        PID.Integral = PID.Integral + intergal_to_add * get(DELTA_TIME)

        if PID.Limited_integral then
            PID.Integral = Math_clamp(PID.Integral, PID.Min_out, PID.Max_out)
        end

        --Derivative
        PID.Derivative = ((last_PV - PID.PV) / get(DELTA_TIME)) * PID.D_gain
    end,
    FEED_FWD = function (FF_PID, PID, FF_PV)
        if get(DELTA_TIME) == 0 then return end

        local LAST_PV = FF_PID.feedfwd_pv

        --INPUT--
        if FF_PID.filter_feedfwd == true then
            FF_PID.feedfwd_filter_table.x = FF_PV
            if FF_PID.highpass_inputs == true then
                FF_PID.feedfwd_pv = high_pass_filter(FF_PID.feedfwd_filter_table)
            else
                FF_PID.feedfwd_pv = low_pass_filter(FF_PID.feedfwd_filter_table)
            end
        else
            FF_PID.feedfwd_pv = FF_PV
        end

        --FEED-FORWARD--
        if FF_PID.derive_feedfwd then
            FF_PID.feedfwd = ((LAST_PV - FF_PID.feedfwd_pv) / get(DELTA_TIME)) * FF_PID.FF_gain
        else
            FF_PID.feedfwd = FF_PID.feedfwd_pv * FF_PID.FF_gain
        end

        --SUM FF to the main PID--
        PID.feedfwd = PID.feedfwd + FF_PID.feedfwd
    end,
    OUTPUT_NRM = function (PID)
        --Sigma
        PID.Desired_output = PID.Proportional + PID.Integral + PID.Derivative

        --[SPECIAL CASE WITH LIMITED INTEGRALS]--
        if PID.Limited_integral then
            PID.Desired_output = Math_clamp(PID.Desired_output, PID.Min_out, PID.Max_out)
        end

        return Math_clamp(PID.Desired_output, PID.Min_out, PID.Max_out)
    end,
    OUTPUT_FF = function (PID)
        --Sigma
        PID.Desired_output = PID.Proportional + PID.Integral + PID.Derivative

        --[SPECIAL CASE WITH LIMITED INTEGRALS]--
        if PID.Limited_integral then
            PID.Desired_output = Math_clamp(PID.Desired_output, PID.Min_out, PID.Max_out)
        end

        local PID_OUTPUT = Math_clamp(PID.Desired_output + PID.feedfwd, PID.Min_out, PID.Max_out)

        --clear FF for the next loop--
        PID.feedfwd = 0

        return PID_OUTPUT
    end
}

function PID_COMPUTE (PID, SP, PV, SCHED_VAR)
    PID_INTERNALS.INIT_PID(PID)
    PID_INTERNALS.GAIN_SCHEDULING(PID, SCHED_VAR)
    PID_INTERNALS.BP(PID)
    PID_INTERNALS.PID(PID, SP, PV)
end

function PID_FF (FF_PID, PID, FF_PV)
    PID_INTERNALS.INIT_FEEDFWD(FF_PID, PID)
    PID_INTERNALS.FEED_FWD(FF_PID, PID, FF_PV)
end

function PID_OUTPUT_FF (PID)
    local PID_OUTPUT = PID_INTERNALS.OUTPUT_FF(PID)

    return PID_OUTPUT
end

function PID_OUTPUT_NRM (PID)
    local PID_OUTPUT = PID_INTERNALS.OUTPUT_NRM(PID)

    return PID_OUTPUT
end