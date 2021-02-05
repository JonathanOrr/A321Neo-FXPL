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


function Math_clamp(val, min, max)
    if min > max then 
        logWarning("Min is larger than Max, invalid")
        logWarning("Minimum was: " .. min)
        logWarning("Maximum was: " .. max)
        logWarning("Original value: " .. val .. " will be returned")
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

function BoolToNum(value)
    return value and 1 or 0
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

function Set_anim_value_linear_range(current_value, target, min, max, linear_spd, curved_spd)
    local limited_target = Math_clamp(target, min, max)

    if current_value > max then
        return max
    elseif current_value < min then
        return min
    else
        local int_linear_speed = linear_spd / curved_spd
        local adding_term = Math_clamp_lower(limited_target - current_value, -int_linear_speed)
        adding_term = Math_clamp_higher(adding_term, int_linear_speed)
        return current_value + adding_term * (curved_spd * get(DELTA_TIME))
    end
end

function Set_anim_value_no_lim(current_value, target, speed)
    return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
end

local function Set_linear_anim_value_internal(current_value, target, min, max, speed, speed_m)
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
    set(dataref, Set_linear_anim_value(get(dataref), target, min, max, speed))
end


-- for giving datarefs linear delayed outputs by using set_linear_anim_value
function Set_dataref_linear_anim_nostop(dataref, target, min, max, speed)
    set(dataref, Set_linear_anim_value_nostop(get(dataref), target, min, max, speed))
end


--rescaling a value
function Math_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function Math_rescale_lim_lower(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function Math_rescale_lim_upper(in1, out1, in2, out2, x)

    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function Math_rescale_no_lim(in1, out1, in2, out2, x)

    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

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

function Table_extrapolate(tab, x)  -- This works like Table_interpolate, but it estimates the values
                                    -- even if x < minimum value of x > maximum value according to the
                                    -- last segment available

    local a = 1
    local b = #tab

    assert(b > 1)

    if x < tab[a][1] then
        return Math_rescale_no_lim(tab[a][1], tab[a][2], tab[a+1][1], tab[a+1][2], x) 
    end
    if x > tab[b][1] then
        return Math_rescale_no_lim(tab[b][1], tab[b][2], tab[b-1][1], tab[b-1][2], x) 
    end

    return Table_interpolate(tab, x)

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

    local distance = math.acos(math.cos(math.rad(90-lat1))*math.cos(math.rad(90-lat2))+ math.sin(math.rad(90-lat1))*math.sin(math.rad(90-lat2))*math.cos(math.rad(lon1-lon2))) * (6378000/1852)

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

function Move_along_distance(origin_lat, origin_lon, distance, angle)   -- Distance in M
    local a = math.rad(90-angle);

    local lat0 = math.cos(math.pi / 180.0 * origin_lat)

    local lat = origin_lat  + (180/math.pi) * (distance / 6378137) * math.sin(a)
    local lon = origin_lon + (180/math.pi) * (distance / 6378137) / math.cos(lat0) * math.cos(a)
    return lat,lon
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
        set(dataref, Math_clamp(get(dataref) + step * get(DELTA_TIME_NO_STOP), min, max))
    elseif phase == SASL_COMMAND_CONTINUE then
        set(dataref, Math_clamp(get(dataref) + step * get(DELTA_TIME_NO_STOP), min, max))
    end
end

-- Generic handler for a float knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_down_float(phase, value_dataref, 0, 3) end)
function Knob_handler_down_float(phase, dataref, min, max, step) 
    step = step or 0.5  -- Defualt value
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) - step * get(DELTA_TIME_NO_STOP), min, max))
    elseif phase == SASL_COMMAND_CONTINUE then
        set(dataref, Math_clamp(get(dataref) - step * get(DELTA_TIME_NO_STOP), min, max))
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

function SASL_drawRoundedFrames(x, y, width, height, line_width, round_pixels, color)
    sasl.gl.drawWideLine(x - (line_width / 2) + round_pixels, y + height,           x + width + (line_width / 2) - round_pixels, y + height,                      line_width, color)
    sasl.gl.drawWideLine(x,                    y + (line_width / 2) + round_pixels - 2, x,                            y + (height - (line_width / 2)) - round_pixels + 3, line_width, color)
    sasl.gl.drawWideLine(x + width,            y + (line_width / 2) + round_pixels - 2, x + width,                    y + (height - (line_width / 2)) - round_pixels + 1, line_width, color)
    sasl.gl.drawWideLine(x - (line_width / 2) + round_pixels, y,                    x + width + (line_width / 2) - round_pixels, y,                               line_width, color)
    sasl.gl.drawArc ( x + width - round_pixels, y + (height - (line_width / 2)) - round_pixels + 1, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,0 , 90 ,color )
    sasl.gl.drawArc ( x - (line_width / 2) + round_pixels + 2, y + height - round_pixels, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,90 , 90 ,color )
    sasl.gl.drawArc ( x + round_pixels, y + round_pixels, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,180 , 90 ,color )
    sasl.gl.drawArc ( x + width + (line_width / 2) - round_pixels - 3, y + (line_width / 2) + round_pixels - 2, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,270 , 90 ,color )
end

function SASL_draw_needle(x, y, radius, angle, thickness, color)
    sasl.gl.drawWideLine(x, y, x + radius * math.cos(math.rad(angle)), y + radius * math.sin(math.rad(angle)), thickness, color)
end

function SASL_draw_needle_adv(x, y, inner_radius, outter_radius, angle, thickness, color)
    sasl.gl.drawWideLine(x + inner_radius * math.cos(math.rad(angle)), y + inner_radius * math.sin(math.rad(angle)), x + outter_radius * math.cos(math.rad(angle)), y + outter_radius * math.sin(math.rad(angle)), thickness, color)
end

--draw images
function SASL_draw_img_center_aligned(image, x, y, width, height, color)
    sasl.gl.drawTexture(image, x - width / 2, y - height / 2, width, height, color)
end
function SASL_draw_img_xcenter_aligned(image, x, y, width, height, color)
    sasl.gl.drawTexture(image, x - width / 2, y, width, height, color)
end
function SASL_draw_img_ycenter_aligned(image, x, y, width, height, color)
    sasl.gl.drawTexture(image, x, y - width / 2, width, height, color)
end

function SASL_rotated_center_img_xcenter_aligned(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_ycenter_aligned(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_center_aligned(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_xcenter_aligned_helper(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    local center_x = x + center_x_offset
    local center_y = y + center_y_offset
    local radius = math.sqrt((center_x - x)^2 + (center_y - y)^2)

    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y + center_y_offset, width, height, color)

    sasl.gl.drawCircle(x, y, radius, true, {0, 1, 0, 0.25})
    sasl.gl.drawCircle(x, y, 5, true, {1, 0, 0})
    sasl.gl.drawLine(x, y, x + radius*math.cos(-math.rad(get(TIME) * 40 + 90)), y + radius*math.sin(-math.rad(get(TIME) * 40 + 90)), {1, 0, 0})
    sasl.gl.drawRotatedTextureCenter (image, get(TIME) * 40, x, y, x - width / 2 + center_x_offset, y + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_ycenter_aligned_helper(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    local center_x = x + center_x_offset
    local center_y = y + center_y_offset
    local radius = math.sqrt((center_x - x)^2 + (center_y - y)^2)

    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x + center_x_offset, y - height / 2 + center_y_offset, width, height, color)

    sasl.gl.drawCircle(x, y, radius, true, {0, 1, 0, 0.25})
    sasl.gl.drawCircle(x, y, 5, true, {1, 0, 0})
    sasl.gl.drawLine(x, y, x + radius*math.cos(-math.rad(get(TIME) * 40 + 90)), y + radius*math.sin(-math.rad(get(TIME) * 40 + 90)), {1, 0, 0})
    sasl.gl.drawRotatedTextureCenter (image, get(TIME) * 40, x, y, x + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_center_aligned_helper(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    local center_x = x + center_x_offset
    local center_y = y + center_y_offset
    local radius = math.sqrt((center_x - x)^2 + (center_y - y)^2)

    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y - height / 2 + center_y_offset, width, height, color)

    sasl.gl.drawCircle(x, y, radius, true, {0, 1, 0, 0.25})
    sasl.gl.drawCircle(x, y, 5, true, {1, 0, 0})
    sasl.gl.drawLine(x, y, x + radius*math.cos(-math.rad(get(TIME) * 40 + 90)), y + radius*math.sin(-math.rad(get(TIME) * 40 + 90)), {1, 0, 0})
    sasl.gl.drawRotatedTextureCenter (image, get(TIME) * 40, x, y, x - width / 2 + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_drawText_rotated(id, x_offset, y_offset, x, y, angle, text, size, isBold, isItalic, alignment, color)
    sasl.gl.drawRotatedText (id, x + x_offset, y + y_offset, x, y, angle, text, size, isBold, isItalic, alignment , color)
end

function SASL_drawSegmentedImg_xcenter_aligned(image, x, y, img_width, img_height, num_positions, position)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x - img_width / num_positions / 2, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, {1, 1, 1})
end

function SASL_drawSegmentedImg(image, x, y, img_width, img_height, num_positions, position)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, {1, 1, 1})
end

function SASL_drawSegmentedImgColored(image, x, y, img_width, img_height, num_positions, position, color)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, color)
end

function SASL_drawSegmentedImgColored_xcenter_aligned(image, x, y, img_width, img_height, num_positions, position, color)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x - img_width / num_positions / 2, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, color)
end

--drawing LED/LCDs
function Draw_LCD_backlight(x, y, width, hight, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local LCD_backlight_cl = {10/255, 15/255, 25/255}

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LCD_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LCD_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LCD_backlight_cl[3], brightness)

    sasl.gl.drawRectangle(x, y, width, hight, {blacklight_R, blacklight_G, blacklight_B})
end

function Draw_green_LED_backlight(x, y, width, hight, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local green_backlight_cl = {5/255, 15/255, 10/255}

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, green_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, green_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, green_backlight_cl[3], brightness)

    sasl.gl.drawRectangle(x, y, width, hight, {blacklight_R, blacklight_G, blacklight_B})
end

function Draw_blue_LED_backlight(x, y, width, hight, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local blue_backlight_cl = {4/255, 6/255, 10/255}

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, blue_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, blue_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, blue_backlight_cl[3], brightness)

    sasl.gl.drawRectangle(x, y, width, hight, {blacklight_R, blacklight_G, blacklight_B})
end

function Draw_green_LED_num_and_letter(x, y, string, max_digits, size, alignment, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local LED_cl = {235/255, 200/255, 135/255, brightness}
    local LED_backlight_cl = {15/255, 20/255, 15/255}

    local backlight_string = ""

    for i = 1, max_digits do
        backlight_string = backlight_string .. 8
    end

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[3], brightness)

    sasl.gl.drawText(Font_7_digits, x, y, backlight_string, size, false, false, alignment, {blacklight_R, blacklight_G, blacklight_B})
    sasl.gl.drawText(Font_7_digits, x, y, string, size, false, false, alignment, LED_cl)
end

function Draw_white_LED_num_and_letter(x, y, string, max_digits, size, alignment, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local LED_cl = {255/255, 255/255, 255/255, brightness}
    local LED_backlight_cl = {15/255, 16/255, 20/255}

    local backlight_string = ""

    if max_digits == 0 then
        backlight_string = ":"
    else
        for i = 1, max_digits do
            backlight_string = backlight_string .. 8
        end
    end
    
    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[3], brightness)

    sasl.gl.drawText(Font_7_digits, x, y, backlight_string, size, false, false, alignment, {blacklight_R, blacklight_G, blacklight_B})
    sasl.gl.drawText(Font_7_digits, x, y, string, size, false, false, alignment, LED_cl)
end

--starts at right goes anti-clockwise
function Get_rotated_point_x_pos(x, radius, angle)
    return x + radius * math.cos(math.rad(angle))
end

function Get_rotated_point_y_pos(y, radius, angle)
    return y + radius * math.sin(math.rad(angle))
end

function Get_rotated_point_x_CC_pos(x, radius, angle)
    return x + radius * math.cos(math.rad(90 - angle))
end

function Get_rotated_point_y_CC_pos(y, radius, angle)
    return y + radius * math.sin(math.rad(90 - angle))
end

--starts at top goes clockwise
function Get_rotated_point_x_pos_offset(x, radius, angle, x_offset)
    local recalculated_r = math.sqrt(radius^2 + x_offset^2) * (radius >= 0 and 1 or -1)
    local offset_a = math.deg(math.atan(x_offset / radius))
    local recalculated_a = 90 - angle - offset_a

    return x + recalculated_r * math.cos(math.rad(recalculated_a))
end

function Get_rotated_point_y_pos_offset(y, radius, angle, x_offset)
    local recalculated_r = math.sqrt(radius^2 + x_offset^2) * (radius >= 0 and 1 or -1)
    local offset_a = math.deg(math.atan(x_offset / radius))
    local recalculated_a = 90 - angle - offset_a

    return y + recalculated_r * math.sin(math.rad(recalculated_a))
end

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



function MCDU_get_popup(id) return Mcdu_popup[id] end
function MCDU_set_popup(id, val) Mcdu_popup[id] = val end

function MCDU_get_lut(val) return Mcdu_popup_lut end
function MCDU_set_lut(val) Mcdu_popup_lut = val end

function MCDU_get_data(reference) 
    if Mcdu_data[reference] == nil then
        return 0
    end
    return Mcdu_data[reference] 
end
function MCDU_set_data(reference, val) 
    Mcdu_data[reference] = val 
end

--mouse functions
function Button_check_and_action(cursor_x, cursor_y, lower_x, lower_y, higher_x, higher_y, callback)
    if cursor_x >= lower_x and cursor_x <= higher_x and cursor_y >= lower_y and cursor_y <= higher_y then
        callback()
    end
end

function Cursor_texture_to_local_pos(x, y, component_width, component_height, panel_width, panel_height)
    local tex_x, tex_y = sasl.getCSPanelMousePos()

    --mouse not on the screen
    if tex_x == nil or tex_y == nil then
        return 0, 0, false
    end

    --0 --> 1 to px
    local px_x = Math_rescale(0, 0, 1, panel_width,  tex_x)
    local px_y = Math_rescale(0, 0, 1, panel_height, tex_y)

    --px --> component
    local component_x = Math_rescale(x, 0, x + component_width,  component_width,  px_x)
    local component_y = Math_rescale(y, 0, y + component_height, component_height, px_y)

    if px_x < x or px_x > x + component_width or px_y < y or px_y > y + component_height then
        return 0, 0, false
    end

    --output converted coordinates
    return component_x, component_y, true
end

function Local_magnetic_deviation()
    return get(Flightmodel_mag_heading) - get(Flightmodel_true_heading)
end


