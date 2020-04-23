--custom datarefs
local cabin_screen_page = createGlobalPropertyi("a321neo/cabin/screen_page", 0, false, true, false)

--custom functions
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
    set(cabin_screen_page, Math_clamp(get(cabin_screen_page), 0, 2))

    set(Distance_traveled_km, get(Distance_traveled_m) / 10)
    set(Groudn_speed_kmh, get(Ground_speed_ms) * 3.6)

    if get(Engine_1_master_switch) == 0 or get(Engine_2_master_switch) == 0 then
        set(cabin_screen_page, 0)
    elseif get(Engine_1_master_switch) == 1 and get(Engine_2_master_switch) == 1 then
        set(cabin_screen_page, 1)
    end
end