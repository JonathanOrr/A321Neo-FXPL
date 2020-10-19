

local function n1_to_n2(n1)
    return 50 * math.log10(n1) + (n1+50)^3/220000 + 0.64
end

local function min_n1(altitude)
    return 5.577955*math.log(0.03338352*altitude+23.66644)+1.724586
end

local function update_n1_minimum()
    local curr_altitude = get(Elevation_m) * 3.28084
    local curr_n1 = get(Eng_1_N1)
    local comp_min_n1 = min_n1(curr_altitude)
    
    set(Eng_N1_idle, comp_min_n1)
    
    if curr_n1 < comp_min_n1 and get(Engine_1_avail) == 1 then
        set(Eng_1_N1_enforce, comp_min_n1)
    end

    curr_n1 = get(Eng_2_N1)
    if curr_n1 < comp_min_n1 and get(Engine_2_avail) == 1 then
        set(Eng_2_N1_enforce, comp_min_n1)
    end
end

local function update_n2()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > 5 then
        set(Eng_1_N2, n1_to_n2(eng_1_n1))
    else
        -- Starting or off TODO
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > 5 then
        set(Eng_2_N2, n1_to_n2(eng_2_n1))
    else
        -- Starting or off TODO
    end

end

function update()
    update_n1_minimum()
    update_n2()
    
end
