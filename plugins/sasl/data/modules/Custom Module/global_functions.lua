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
-- File: global_functions.lua
-- Short description: A global file containing miscellaneous functions
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- CAUTION: Global = bad. You have been warned. Rico's watching you.
-------------------------------------------------------------------------------
-- NO GLOBAL VARIABLES HERE! See `global_variables.lua`
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Basic mathematical operators
-------------------------------------------------------------------------------

function Math_clamp(val, min, max)
    if min > max then 
        logWarning("Min is larger than Max, invalid")
        logWarning("Minimum was: " .. min)
        logWarning("Maximum was: " .. max)
        logWarning("Original value: " .. val .. " will be returned")
        return val
    end

    return val <= min and min or (val >= max and max or val)
end

function Math_clamp_lower(val, min)
    return val <= min and min or val
end

function Math_clamp_higher(val, max)
    return val >= max and max or val
end

--used to cycle a value e.g. 1 --> 2 --> 3 |
--                           ^<----------<--
function Math_cycle(val, start, finish)
    if start > finish then logWarning("start is larger than finish, invalid") end

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
    return string.format("%."..numDecimalPlaces.."f", Round(num, numDecimalPlaces))
end

function Math_extract_all_decimal(num, abs)
    local output = math.abs( num ) % 1

    if abs == true then
        return output
    else
        return num >= 0 and output or -output
    end
end

function Math_extract_decimal(num, decimalPlace, abs)
    local output = math.floor( ( math.abs( num ) - math.floor( math.abs( num ) ) ) * 10 ^ decimalPlace)

    if abs == true then
        return output
    else
        return num >= 0 and output or -output
    end
end

function Math_extract_digit(num, which_digit, abs)
    local put_digit_into_decimal
    if which_digit > 0 then
        put_digit_into_decimal = num / 10 ^ which_digit
    elseif which_digit < 0 then
        put_digit_into_decimal = num / 10 ^ (which_digit + 1)
    end
    return Math_extract_decimal(put_digit_into_decimal, 1, abs)
end

--approximate a value similar to a deadzone
function Math_approx_value(num, approx_range, approx_to)
    if num >= approx_to - approx_range and num <= approx_to + approx_range then
        return approx_to
    else
        return num
    end
end

function Math_angle_diff(angle1, angle2)
    local a = angle1 - angle2
    a = (a + 180) % 360 - 180
    return a
end

function BoolToNum(value)
    return value and 1 or 0
end

-------------------------------------------------------------------------------
-- Value Animations
-------------------------------------------------------------------------------

--used to animate a value with a curve USE ONLY WITH FLOAT VALUES
function Set_anim_value(current_value, target, min, max, speed)
    assert(speed >= 0, "Anim value speed must be > 0!")

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
    end

end

function Set_anim_value_linear_range(current_value, target, min, max, linear_spd, curved_spd)
    assert(linear_spd >= 0 and curved_spd >=0, "Anim value speed must be > 0!")

    local limited_target = Math_clamp(target, min, max)

    local int_linear_speed = linear_spd / curved_spd
    local adding_term = Math_clamp_lower(limited_target - current_value, -int_linear_speed)
    adding_term = Math_clamp_higher(adding_term, int_linear_speed)
    return Math_clamp(current_value + adding_term * (curved_spd * get(DELTA_TIME)), min, max)
end

function Set_anim_value_no_lim(current_value, target, speed)
    assert(speed >= 0, "Anim value speed must be > 0!")
    return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
end

local function Set_linear_anim_value_internal(current_value, target, min, max, speed, speed_m)
    assert(speed >= 0 and speed_m >= 0, "Anim value speed must be > 0!")
    target = Math_clamp(target, min, max)
    if speed_m ~= 0 and speed ~= 0 then
        if target - current_value < (speed + (speed * 0.005)) * speed_m and target - current_value > -(speed + (speed * 0.005)) * speed_m then
          return target
        elseif target < current_value then
          return current_value - (speed * speed_m)
        elseif target > current_value then
          return current_value + (speed * speed_m)
        end
    else
        return current_value
    end
end

--used to animate a value with a linear delay USE ONLY WITH FLOAT VALUES
function Set_linear_anim_value(current_value, target, min, max, speed)
    return Set_linear_anim_value_internal(current_value, target, min, max, speed, get(DELTA_TIME))
end

--used to animate a value with a linear delay USE ONLY WITH FLOAT VALUES
function Set_linear_anim_value_nostop(current_value, target, min, max, speed)
    return Set_linear_anim_value_internal(current_value, target, min, max, speed, get(DELTA_TIME_NO_STOP))
end

-- for giving datarefs linear delayed outputs by using set_linear_anim_value
function Set_dataref_linear_anim(dataref, target, min, max, speed)
    target = target or 0
    set(dataref, Set_linear_anim_value(get(dataref), target, min, max, speed))
end


-- for giving datarefs linear delayed outputs by using set_linear_anim_value
function Set_dataref_linear_anim_nostop(dataref, target, min, max, speed)
    set(dataref, Set_linear_anim_value_nostop(get(dataref), target, min, max, speed))
end

-------------------------------------------------------------------------------
-- Interpolation and rescaling
-------------------------------------------------------------------------------

--rescaling a value
function Math_rescale_no_lim(in1, out1, in2, out2, x)

    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end

function Math_rescale_lim_lower(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    return Math_rescale_no_lim(in1, out1, in2, out2, x)
end

function Math_rescale_lim_upper(in1, out1, in2, out2, x)

    if x > in2 then return out2 end
    return Math_rescale_no_lim(in1, out1, in2, out2, x)
    
end

function Math_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return Math_rescale_no_lim(in1, out1, in2, out2, x)

end

function Table_interpolate(tab, x) --X VALUE MUST BE FROM SMALL TO BIG! OTHERWISE IT WILL BREAK!
    local a = 1
    local b = #tab
    assert(b > 1)
    if b == 2 then
        logWarning("Don't use table interpolate for just 2 values, use Math_rescale_* functions.")
    end

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

function Table_extrapolate(tab, x)  -- This works like Table_interpolate, but it estimates the values
                                    -- even if x < minimum value of x > maximum value according to the
                                    -- last segment available

    local a = 1
    local b = #tab

    assert(b > 1)
    if b == 2 then
        logWarning("Don't use table extrapolate for just 2 values, use Math_rescale_* functions.")
    end

    if x < tab[a][1] then
        return Math_rescale_no_lim(tab[a][1], tab[a][2], tab[a+1][1], tab[a+1][2], x) 
    end
    if x > tab[b][1] then
        return Math_rescale_no_lim(tab[b][1], tab[b][2], tab[b-1][1], tab[b-1][2], x) 
    end

    return Table_interpolate(tab, x)

end

function Table_interpolate_2d(x,y,z,value_x, value_y)

    local i = 1
    while i <= #x do
        if x[i] >= value_x then
            break
        end
        i = i + 1
    end

    local j = 1
    while j <= #y do
        if y[j] >= value_y then
            break
        end
        j = j +1
    end


    local temp_j = j
    if temp_j > #y then
        temp_j = #y
    end
    
    local x_comp = 0
    if i == 1 then
        x_comp = z[i][temp_j]
    elseif i > #x then
        x_comp = z[#x][temp_j]
        i = #x
    else

        x_comp = Math_rescale(x[i-1], z[i-1][temp_j], x[i], z[i][temp_j], value_x) 
    end

    local y_comp = 0
    if j == 1 then
        y_comp = z[i][j]
    elseif j > #y then
        y_comp = z[i][#y]
    else
        y_comp = Math_rescale(y[j-1], z[i][j-1], y[j], z[i][j], value_y) 
    end

    return (x_comp + y_comp) / 2
end

-------------------------------------------------------------------------------
-- String manipulation
-------------------------------------------------------------------------------

function UTF8_str_len(str)  -- Compute the string length for UTF-8 strings
    local nrm_len  = #str
    local real_len = 0
    local i=1
    while i<=nrm_len do
        local c = string.byte(str, i)
        if c <= 127 then
            i = i + 1
            real_len = real_len + 1
        elseif c <= 223 then
            i = i + 2
            real_len = real_len + 1
        elseif c <= 239 then
            i = i + 3
            real_len = real_len + 1
        else
            i = i + 4
            real_len = real_len + 1
        end
    end
    return real_len
end

--string functions--
--append string_to_fill_it_with to the front of a string to achive the length of to_what_length
function Fwd_string_fill(string_to_fill, string_to_fill_it_with, to_what_length)
    assert(type(string_to_fill) == "string", "string_to_fill is a " .. type(string_to_fill) .. "!")
    assert(type(string_to_fill_it_with) == "string", "string_to_fill_it_with is a " .. type(string_to_fill_it_with) .. "!")
    assert(type(to_what_length) == "number", "to_what_length is a " .. type(to_what_length) .. "!")
    local curr_length = UTF8_str_len(string_to_fill)
    for i = curr_length, to_what_length - 1 do
        string_to_fill = string_to_fill_it_with .. string_to_fill
    end

    return string_to_fill
end

--append string_to_fill_it_with to the end of a string to achive the length of to_what_length
function Aft_string_fill(string_to_fill, string_to_fill_it_with, to_what_length)
    assert(type(string_to_fill) == "string", "string_to_fill is a " .. type(string_to_fill) .. "!")
    assert(type(string_to_fill_it_with) == "string", "string_to_fill_it_with is a " .. type(string_to_fill_it_with) .. "!")
    assert(type(to_what_length) == "number", "to_what_length is a " .. type(to_what_length) .. "!")

    local curr_length = UTF8_str_len(string_to_fill)
    for i = curr_length, to_what_length - 1 do
        string_to_fill = string_to_fill .. string_to_fill_it_with
    end

    return string_to_fill
end

-------------------------------------------------------------------------------
-- Performance measurement
-------------------------------------------------------------------------------

function perf_measure_start(name)
    if not debug_performance_measure then
        return 
    end
    if Perf_array[name] == nil then 
        Perf_array[name] = {}
        Perf_array[name].timer = sasl.createPerformanceTimer()
        Perf_array[name].peak = 0
    end

    sasl.startTimer(Perf_array[name].timer)
end

function perf_measure_stop(name)
    if not debug_performance_measure then
        return
    end

    Perf_array[name].last_delta = sasl.getElapsedSeconds(Perf_array[name].timer)

    if Perf_array[name].last_delta > Perf_array[name].peak then
        Perf_array[name].peak = Perf_array[name].last_delta
    end 

    if Perf_array[name].mov_avg_n == nil or Perf_array[name].mov_avg_n == 50 then
        Perf_array[name].mov_avg = Perf_array[name].mov_avg_temp or 0
        Perf_array[name].mov_avg_temp = 0
        Perf_array[name].mov_avg_n = 0
    end

    Perf_array[name].mov_avg_temp = Perf_array[name].mov_avg_temp + Perf_array[name].last_delta
    Perf_array[name].mov_avg_n = Perf_array[name].mov_avg_n + 1


    sasl.pauseTimer(Perf_array[name].timer)
end

-------------------------------------------------------------------------------
-- NAV
-------------------------------------------------------------------------------
function Local_magnetic_deviation()
    return get(Flightmodel_mag_heading) - get(Flightmodel_true_heading)
end




--                             .xm*f""??T?@hc.
--                          z@"` '~((!!!!!!!?*m.
--                        z$$$K   ~~(/!!!!!!!!!Mh
--                      .f` "#$k'`~~\!!!!!!!!!!!MMc
--                     :"     f*! ~:~(!!!!!!!!!!XHMk
--                     f      " %n:~(!!!!!!!!!!!HMMM.
--                    d          X~!~(!!!!!!!X!X!SMMR
--                    M :   x::  :~~!>!!!!!!MNWXMMM@R
-- n                  E ' *  .......(!!X........RHMMM>                :.
-- E%                 E  8 ........$K!!$........M$RMM>               :"5
--z  %                3  $ 4.......$!~!*........!$MM$               :" `
--K   ":              ?> # '#.....#~!!!!TR....$R?@MME              z   R
--?     %.             5     ^"""~~~:XW!!!!T?T!XSMMM~            :^    J
-- ".    ^s             ?.       ~~d$X$NX!!!!!!M!MM             f     :~
--  '+.    #L            *c:.    .~"?!??!!!!!XX@M@~           z"    .*
--    '+     %L           #c`"!+~~~!/!!!!!!@*TM8M           z"    .~
--      ":    '%.         'C*X  .!~!~!!!!!X!!!@RF         .#     +
--        ":    ^%.        9-MX!X!!X~H!!M!N!X$MM        .#`    +"
--          #:    "n       'L'!~M~)H!M!XX!$!XMXF      .+`   .z"
--            #:    ":      R *H$@@$H$*@$@$@$%M~     z`    +"
--              %:   `*L    'k' M!~M~X!!$!@H!tF    z"    z"
--                *:   ^*L   "k ~~~!~!!!!!M!X*   z*   .+"
--                  "s   ^*L  '%:.~~~:!!!!XH"  z#   .*"
--                    #s   ^%L  ^"#4@UU@##"  z#   .*"
--                      #s   ^%L           z#   .r"
--                        #s   ^%.       u#   .r"
--                          #i   '%.   u#   .@"
--                            #s   ^%u#   .@"
--                              #s x#   .*"
--                               x#`  .@%.
--                             x#`  .d"  "%.
--                           xf~  .r" #s   "%.
--                     u   x*`  .r"     #s   "%.  x.
--                     %Mu*`  x*"         #m.  "%zX"
--                     :R(h x*              "h..*dN.
--                   u@NM5e#>                 7?dMRMh.
--                 z$@M@$#"#"                 *""*@MM$hL
--               u@@MM8*                          "*$M@Mh.
--             z$RRM8F"                             "N8@M$bL
--            5`RM$#                                  'R88f)R
--            'h.$"                                     #$x*
--
--
-- STOP ADDING FUNCTIONS TO THIS FILE
--
