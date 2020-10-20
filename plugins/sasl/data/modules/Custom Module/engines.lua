----------------------------------------------------------------------------------------------------
-- Engine parameters computation and ignition phase file
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')


START_UP_PHASES_N2 = {
    {n2_start = 0,    n2_increase_per_sec = 0.26, fuel_flow = 0,   stop=false},
    {n2_start = 10,   n2_increase_per_sec = 1.5, fuel_flow = 0,    stop=false},
    {n2_start = 16.2, n2_increase_per_sec = 1.5, fuel_flow = 120,  stop=false},
    {n2_start = 16.7, n2_increase_per_sec = 1.8, fuel_flow = 180,  stop=false},
    {n2_start = 24,   n2_increase_per_sec = 1.25, fuel_flow = 100, stop=false},
    {n2_start = 31.8, n2_increase_per_sec = 0.44, fuel_flow = 120, stop=false},
    {n2_start = 36.3, n2_increase_per_sec = 0.60, fuel_flow = 140, stop=true},
}
START_UP_PHASES_N1 = {
    {n1_set = 6.6,    n1_increase_per_sec = 0.60, fuel_flow = 160},
}

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

local eng_starting_phase = {0, 0}

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------

-- TODO

----------------------------------------------------------------------------------------------------
-- Functions - Commands
----------------------------------------------------------------------------------------------------

-- TODO

----------------------------------------------------------------------------------------------------
-- Functions - Engine parameters
----------------------------------------------------------------------------------------------------

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

local function update_avail()
    if get(Eng_1_N1) > 18.4 and get(Engine_1_master_switch) == 1 then
        if get(Engine_1_avail) == 0 then
            set(EWD_engine_avail_ind_1_start, get(TIME))
            set(Engine_1_avail, 1)
        end
    else
        set(Engine_1_avail, 0)    
        set(EWD_engine_avail_ind_1_start, 0)
    end
    if get(Eng_2_N1) > 18.4 and get(Engine_2_master_switch) == 1 then
        if get(Engine_2_avail) == 0 then
            set(EWD_engine_avail_ind_2_start, get(TIME))
            set(Engine_2_avail, 1)
        end
    else
        set(Engine_2_avail, 0)    
        set(EWD_engine_avail_ind_2_start, 0)
    end

    
end

local function perform_starting_procedure(eng)

end

function update()

    perform_starting_procedure()

    update_n1_minimum()
    update_n2()
    update_avail() 
end
