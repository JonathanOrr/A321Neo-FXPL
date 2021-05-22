
--toggle obj between two strings, a and b
--e.g. ("ad", "ba", "ad") -> "ba"
function mcdu_toggle(obj, str_a, str_b)
    if obj == str_a then
        return str_b
    elseif obj == str_b then
        return str_a
    end
end


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

