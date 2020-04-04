--sim datarefs
local efis_range = globalProperty("sim/cockpit2/EFIS/map_range")


--custom function
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

function update()
    set(efis_range, Math_clamp(get(efis_range), 1 , 6))
end