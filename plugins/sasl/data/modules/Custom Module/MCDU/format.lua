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
-- File: format.lua 
-- Short description: Format functions for inputs or text output
-------------------------------------------------------------------------------

--pad a number up to a given dp
--e.g. (2.4, 3) -> 2.400
function mcdu_pad_dp(number, required_dp)
    return(string.format("%." .. required_dp .. "f", number))
end

--pad a number up to a given length
--e.g. (50, 3) -> 050
function mcdu_pad_num(number, required_length)
    local str = tostring(number)
    while #str < required_length do
        str = "0" .. str
    end
    return str
end

-- converts Decimal Degrees and Axis (lat/lon) to Degrees Minute Seconds Direction
function mcdu_ctrl_dd_to_dmsd(dd, axis)
    local p  = ""
    if axis == "lat" then
        if dd > 0 then
            p = "N"
        else
            p = "S"
        end
    else
        if dd > 0 then
            p = "E"
        else
            p = "W"
        end
    end

    local dd = math.abs(dd)
    local d = dd
    local m = d % 1 * 60
    local s = m % 1 * 60
    d = math.floor(d)
    -- if axis is longitude
    if axis ~= "lat" then
        d = mcdu_pad_num(d, 3)
    end
    return d, m, s, p
end



-- converts Degrees Minute Seconds Direction to Decimal Degrees
function mcdu_ctrl_dmsd_to_dd(d,m,s,dir)
    local p = 0
    if dir == "E" or dir == "N" then
        p = 1
    else
        p = -1
    end
    local dd = (d + m*(1/60) + s*(1/3600)) * p
    return dd
end

function mcdu_lat_lon_to_str(lat, lon)
    local aa,ab,ac,ad = mcdu_ctrl_dd_to_dmsd(lat, "lat")
    local oa,ob,oc,od = mcdu_ctrl_dd_to_dmsd(lon, "lon")

    return math.floor(aa).."°"..math.floor(ab).."."..math.floor(ac)..ad.."/"..math.floor(oa).."°"..math.floor(ob).."."..math.floor(oc)..od
end

-- converts wind speed and direction to DDD°/SSS format
function mcdu_wind_to_str(dir, speed)
    return mcdu_pad_num(math.floor(dir), 3).."°/"..mcdu_pad_num(math.floor(speed), 3)
end


function mcdu_time_beautify(time_in_sec)
    if not time_in_sec then
        return "----"
    end
    if type(time_in_sec) ~= "number" then
        assert(false, "time_in_sec should be a number but instead is:" .. tostring(time_in_sec))
    end

    -- Now, if we are in takeoff or later phase, we have to compute the UTC time
    if FMGS_get_phase() > FMGS_PHASE_PREFLIGHT then
        local time_diff = get(TIME) - FMGS_get_takeoff_time()
        local curr_sec = get(ZULU_hours)*3600 + get(ZULU_mins)* 60 + get(ZULU_secs)
        local orig_time_takeoff = (curr_sec - time_diff + 86400) % 86400

        time_in_sec = (time_in_sec + orig_time_takeoff) % 86400 
    end

    local hours   = math.floor(time_in_sec / 3600)
    local minutes = math.floor((time_in_sec-hours*3600) / 60)
    return Fwd_string_fill(hours.."", "0", 2) .. Fwd_string_fill(minutes.."", "0", 2)
end

function mcdu_format_force_to_small(text)

    if type(text) ~= "string" then
        text = tostring(text)
    end
    
    text = text:lower()

    local output = ""

    local nr_letters = #text

    for i=1,nr_letters do
        if text:sub(i, i) == "0" then
            output = output .."À"
        elseif text:sub(i, i) == "1" then
            output = output .. "Á"
        elseif text:sub(i, i) == "2" then
            output = output .. "Â"
        elseif text:sub(i, i) == "3" then
            output = output .. "Ã"
        elseif text:sub(i, i) == "4" then
            output = output .. "Ä"
        elseif text:sub(i, i) == "5" then
            output = output .. "Å"
        elseif text:sub(i, i) == "6" then
            output = output .. "Æ"
        elseif text:sub(i, i) == "7" then
            output = output .. "Ç"
        elseif text:sub(i, i) == "8" then
            output = output .. "È"
        elseif text:sub(i, i) == "9" then
            output = output .. "É"
        elseif text:sub(i, i) == "-" then
            output = output .. "Ê"
        elseif text:sub(i, i) == "." then
            output = output .. "Ë"
        elseif text:sub(i, i) == "/" then
            output = output .. "Ì"
        elseif text:sub(i, i) == "(" then
            output = output .. "Í"
        elseif text:sub(i, i) == ")" then
            output = output .. "Î"
        elseif text:sub(i, i) == "*" then
            output = output .. "Ï"
        elseif text:sub(i, i) == "+" then
            output = output .. "Ð"
        elseif text:sub(i, i) == "%" then
            output = output .. "Ñ"
        elseif text:sub(i, i) == "\"" then
            output = output .. "Ò"
        elseif text:sub(i, i) == ":" then
            output = output .. "Ó"
        elseif text:sub(i, i) == "[" then
            output = output .. "Ô"
        elseif text:sub(i, i) == "]" then
            output = output .. "Õ"
        elseif text:sub(i, i) == "°" then
            output = output .. "Ö"
        elseif text:sub(i, i) == "←" then
            output = output .. "×"
        elseif text:sub(i, i) == "↑" then
            output = output .. "Ø"
        elseif text:sub(i, i) == "→" then
            output = output .. "Ù"
        elseif text:sub(i, i) == "↓" then
            output = output .. "Ú"
        else
            output = output .. text:sub(i, i)
        end
    end

    return output
end

