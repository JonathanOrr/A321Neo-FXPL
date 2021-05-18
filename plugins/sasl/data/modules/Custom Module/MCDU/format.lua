
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
local function mcdu_ctrl_dd_to_dmsd(dd, axis)
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


