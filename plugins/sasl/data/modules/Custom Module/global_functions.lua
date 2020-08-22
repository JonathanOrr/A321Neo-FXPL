--custom functions--
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

--used to animate a value with a linear delay USE ONLY WITH FLOAT VALUES
function Set_linear_anim_value(current_value, target, min, max, speed, dead_zone)
    if target - current_value < dead_zone and target - current_value > -dead_zone then
      return Math_clamp(target, min, max)
    elseif target < current_value then
      return Math_clamp(current_value - (speed * get(DELTA_TIME)), min, max)
    elseif target > current_value then
      return Math_clamp(current_value + (speed * get(DELTA_TIME)), min, max)
    end
end
  
-- for giving datarefs linear delayed outputs by using set_linear_anim_value
function Set_dataref_linear_anim(dataref, target, min, max, speed, dead_zone)
    set(dataref, Set_linear_anim_value(get(dataref), target, min, max, speed, dead_zone))
end
  
--used for ecam automation
function Goto_ecam(page_num)
    set(Ecam_previous_page, get(Ecam_current_page))
    set(Ecam_current_page, page_num)
end

--rounding
function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
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
    correction = correction / pd_array.Max_error
  
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
    correction = Math_clamp(correction, pd_array.Min_error, pd_array.Max_error) / pd_array.Max_error
  
    return correction
end

function FBW_PD_no_lim(pd_array, error)
    local last_error = pd_array.Current_error
    pd_array.Current_error = error + pd_array.Error_offset
  
    --Proportional--
    local correction = pd_array.Current_error * pd_array.P_gain
  
    --derivative--
    correction = correction + (pd_array.Current_error - last_error) * pd_array.D_gain
  
    --limit and rescale output range--
    correction = correction / pd_array.Max_error
  
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

function FBW_PID_no_lim(pid_array, error)
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
    correction = correction / pid_array.Max_error
  
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

Mcdu_popup = {}

function MCDU_get_popup(id) return Mcdu_popup[id] end
function MCDU_set_popup(id, val) Mcdu_popup[id] = val end
  
