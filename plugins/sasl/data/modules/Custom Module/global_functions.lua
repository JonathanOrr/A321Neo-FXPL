--custom functions--
function Math_clamp(val, min, max)
    if min > max then 
        print("Min is larger than Max, invalid")
        print("Minimum was: " .. min)
        print("Maximum was: " .. max)
        print("Original value: " .. val .. " will be returned")
        return val
    end
    if val < min then
        return min
    elseif val > max then
        return max
    elseif min <= val and val <= max then
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

function Math_clamp_higher(val, max)
    if val > max then
        return max
    elseif val <= max then
        return val
    end
end

--used to cycle a value e.g. 1 --> 2 --> 3 |
--                           ^<----------<--
function Math_cycle(val, start, finish)
    if start > finish then LogWarning("start is larger than finish, invalid") end
    if val < start then
        return finish
    elseif val > finish then
        return start
    elseif val <= finish and val >= start then
        return val
    end
end

--linear interpolation
function Math_lerp(pos1, pos2, perc)
    return (1-perc)*pos1 + perc*pos2 -- Linear Interpolation
end

--rounding
function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--rounding - showing leading zeros
function Round_fill(num, numDecimalPlaces)
    return string.format("%.2f", Round(num, numDecimalPlaces)) 
end


--used to animate a value with a curve USE ONLY WITH FLOAT VALUES
function Set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
    end

end

--rescaling a value
function Math_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

--used to animate a value with a linear delay USE ONLY WITH FLOAT VALUES
function Set_linear_anim_value(current_value, target, min, max, speed)
    if get(DELTA_TIME) ~= 0 and speed ~= 0 then
        if target - current_value < (speed + (speed * 0.005)) * get(DELTA_TIME) and target - current_value > -(speed + (speed * 0.005)) * get(DELTA_TIME) then
          return Math_clamp(target, min, max)
        elseif target < current_value then
          return Math_clamp(current_value - (speed * get(DELTA_TIME)), min, max)
        elseif target > current_value then
          return Math_clamp(current_value + (speed * get(DELTA_TIME)), min, max)
        end
    else
        return current_value
    end
end

-- for giving datarefs linear delayed outputs by using set_linear_anim_value
function Set_dataref_linear_anim(dataref, target, min, max, speed)
    set(dataref, Set_linear_anim_value(get(dataref), target, min, max, speed))
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

--used for ecam automation
function Goto_ecam(page_num)
    set(Ecam_previous_page, get(Ecam_current_page))
    set(Ecam_current_page, page_num)
end

function GC_distance_kt(lat1, lon1, lat2, lon2)

    --This function returns great circle distance between 2 points.
    --Found here: http://bluemm.blogspot.gr/2007/01/excel-formula-to-calculate-distance.html
    --lat1, lon1 = the coords from start position (or aircraft's) / lat2, lon2 coords of the target waypoint.
    --6371km is the mean radius of earth in meters. Since X-Plane uses 6378 km as radius, which does not makes a big difference,
    --(about 5 NM at 6000 NM), we are going to use the same.
    --Other formulas I've tested, seem to break when latitudes are in different hemisphere (west-east).

    local distance = math.acos(math.cos(math.rad(90-lat1))*math.cos(math.rad(90-lat2))+
        math.sin(math.rad(90-lat1))*math.sin(math.rad(90-lat2))*math.cos(math.rad(lon1-lon2))) * (6378000/1852)

    return distance

end

function GC_distance_km(lat1, lon1, lat2, lon2)

    --This function returns great circle distance between 2 points.
    --Found here: http://bluemm.blogspot.gr/2007/01/excel-formula-to-calculate-distance.html
    --lat1, lon1 = the coords from start position (or aircraft's) / lat2, lon2 coords of the target waypoint.
    --6371km is the mean radius of earth in meters. Since X-Plane uses 6378 km as radius, which does not makes a big difference,
    --(about 5 NM at 6000 NM), we are going to use the same.
    --Other formulas I've tested, seem to break when latitudes are in different hemisphere (west-east).

    local distance = math.acos(math.cos(math.rad(90-lat1))*math.cos(math.rad(90-lat2))+
        math.sin(math.rad(90-lat1))*math.sin(math.rad(90-lat2))*math.cos(math.rad(lon1-lon2))) * (6378000/1000)

    return distance

end

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

    if get(DELTA_TIME) ~= 0 then

        if pid_array.Smooth_error == true then
            pid_array.Current_error = Set_anim_value(pid_array.Current_error, error, -1000000000000000, 1000000000000000, pid_array.Error_curve_spd)
        else
            pid_array.Current_error = error
        end

        --Proportional--
        pid_array.Proportional = pid_array.Current_error * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral_sum + (pid_array.Current_error * get(DELTA_TIME)), pid_array.Error_margin * pid_array.Min_out * pid_array.I_time, pid_array.Error_margin * pid_array.Max_out * pid_array.I_time)
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * 1 / pid_array.I_time, pid_array.Error_margin * pid_array.Min_out, pid_array.Error_margin * pid_array.Max_out)

        --derivative--
        if pid_array.Smooth_derivative == true then
            pid_array.Derivative = Set_anim_value(pid_array.Derivative, ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain, -1000000000000000, 1000000000000000, pid_array.Derivative_curve_spd)
        else
            pid_array.Derivative = ((pid_array.Current_error - last_error) / get(DELTA_TIME)) * pid_array.D_gain
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
        pid_array.Output = Math_clamp(pid_array.Output, pid_array.Min_out * pid_array.Error_margin, pid_array.Max_out * pid_array.Error_margin) / pid_array.Error_margin

    end

    return pid_array.Output
end

function SSS_PID_DPV(pid_array, Set_Point, PV)
    local last_PV = pid_array.PV

    if get(DELTA_TIME) ~= 0 then

        if pid_array.Smooth_PV == true then
            pid_array.PV = Set_anim_value(pid_array.PV, Set_Point - PV, -1000000000000000, 1000000000000000, pid_array.PV_curve_spd)
        else
            pid_array.PV = PV
        end

        --Proportional--
        pid_array.Proportional = (Set_Point - PV) * pid_array.P_gain

	    --integral--(clamped to stop windup)
	    pid_array.Integral_sum = Math_clamp(pid_array.Integral_sum + ((Set_Point - PV) * get(DELTA_TIME)), pid_array.Error_margin * pid_array.Min_out * pid_array.I_time, pid_array.Error_margin * pid_array.Max_out * pid_array.I_time)
        pid_array.Integral = Math_clamp(pid_array.Integral_sum * 1 / pid_array.I_time, pid_array.Error_margin * pid_array.Min_out, pid_array.Error_margin * pid_array.Max_out)

        --derivative--
        if pid_array.Smooth_derivative == true then
            pid_array.Derivative = Set_anim_value(pid_array.Derivative, ((last_PV - pid_array.PV) / get(DELTA_TIME)) * pid_array.D_gain, -1000000000000000, 1000000000000000, pid_array.Derivative_curve_spd)
        else
            pid_array.Derivative = ((last_PV - pid_array.PV) / get(DELTA_TIME)) * pid_array.D_gain
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
        pid_array.Output = Math_clamp(pid_array.Output, pid_array.Min_out * pid_array.Error_margin, pid_array.Max_out * pid_array.Error_margin) / pid_array.Error_margin

    end

    return pid_array.Output
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

function Read_CSV(file)
  local result_full = {}
  local sep = ','

    for line in io.lines(file) do 
        local result = {}
        local pos = 1
        continue = true
        while continue do 
            local c = string.sub(line,pos,pos)
            if (c ~= "") then
                local startp,endp = string.find(line,sep,pos)
                if (startp) then 
                    table.insert(result,string.sub(line,pos,startp-1))
                    pos = endp + 1
                else
                    table.insert(result,string.sub(line,pos))
                    continue = false
                end 
            else
                continue = false 
            end
        end
        table.insert(result_full,result)
    end

    return result_full
end

-- Generic handler for a float knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_up_float(phase, value_dataref, 0, 3) end)
function Knob_handler_up_float(phase, dataref, min, max, step)
    step = step or 0.5  -- Defualt value
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) + step, min, max))
    elseif phase == SASL_COMMAND_CONTINUE then
        set(dataref, Math_clamp(get(dataref) + step * get(DELTA_TIME), min, max))
    end
end

-- Generic handler for a float knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_down_float(phase, value_dataref, 0, 3) end)
function Knob_handler_down_float(phase, dataref, min, max, step) 
    step = step or 0.5  -- Defualt value
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) - step, min, max))
    elseif phase == SASL_COMMAND_CONTINUE then
        set(dataref, Math_clamp(get(dataref) - step * get(DELTA_TIME), min, max))
    end
end

-- Generic handler for a integer knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_up_int(phase, value_dataref, 0, 3) end)
function Knob_handler_up_int(phase, dataref, min, max) 
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) + 1, min, max))
    end
end

-- Generic handler for a integer knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_down_int(phase, value_dataref, 0, 3) end)
function Knob_handler_down_int(phase, dataref, min, max) 
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) - 1, min, max))
    end
end

--drawing functions
function Sasl_DrawWideFrame(x, y, width, height, line_width, align_center_in_out, color)
    if align_center_in_out == 0 then--center of line
        sasl.gl.drawWideLine(x - (line_width / 2), y + height,           x + width + (line_width / 2), y + height,                      line_width, color)
        sasl.gl.drawWideLine(x,                    y + (line_width / 2), x,                            y + (height - (line_width / 2)), line_width, color)
        sasl.gl.drawWideLine(x + width,            y + (line_width / 2), x + width,                    y + (height - (line_width / 2)), line_width, color)
        sasl.gl.drawWideLine(x - (line_width / 2), y,                    x + width + (line_width / 2), y,                               line_width, color)
    elseif align_center_in_out == 1 then
        sasl.gl.drawWideLine(x - line_width,               y + height + (line_width / 2), x + width + line_width,       y + height + (line_width / 2), line_width, color)
        sasl.gl.drawWideLine(x - (line_width / 2),         y,                             x - (line_width / 2),         y + height,                    line_width, color)
        sasl.gl.drawWideLine(x + width + (line_width / 2), y,                             x + width + (line_width / 2), y + height,                    line_width, color)
        sasl.gl.drawWideLine(x - line_width,               y - (line_width / 2),          x + width + line_width,       y - (line_width / 2),          line_width, color)
    elseif align_center_in_out == 2 then
        sasl.gl.drawWideLine(x,                            y + height - (line_width / 2), x + width,                    y + height - (line_width / 2), line_width, color)
        sasl.gl.drawWideLine(x + (line_width / 2),         y + line_width,                x + (line_width / 2),         y + (height - line_width),     line_width, color)
        sasl.gl.drawWideLine(x + width - (line_width / 2), y + line_width,                x + width - (line_width / 2), y + (height - line_width),     line_width, color)
        sasl.gl.drawWideLine(x,                            y + (line_width / 2),          x + width,                    y + (line_width / 2),          line_width, color)
    end
end


ELEC_sys = {}
Fuel_sys = {}
Mcdu_popup = {}

function MCDU_get_popup(id) return Mcdu_popup[id] end
function MCDU_set_popup(id, val) Mcdu_popup[id] = val end

