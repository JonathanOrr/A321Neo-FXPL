----------------------------------------------------------------------------------------------------
-- Engine parameters computation and ignition phase file
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

local MAX_EGT_OFFSET = 10  -- This is the maximum offset between one engine and the other in terms of EGT
local ENG_N1_CRANK    = 10  -- N1 used for cranking and cooling
local ENG_N1_CRANK_FF = 15  -- FF in case of wet cranking
local ENG_N1_CRANK_EGT= 95  -- Target EGT for cranking
local ENG_N1_LL_IDLE  = 18.3 -- Value to determine if parameters control should be given to X-Plane 
local MAGIC_NUMBER = 100     -- This is a magic number, which value is necessary to start the engine (see later)

local START_UP_PHASES_N2 = {
    -- n2_start: start point after which the element is considered
    -- n2_increase_per_sec: N2 is increasing this value each second
    -- fuel_flow: the fuel flow to use in this phase (static)
    -- egt: the value for EGT at the beginning of this phase (it will increase towards the next value)
    {n2_start = 0,    n2_increase_per_sec = 0.26, fuel_flow = 0,   egt=0},
    {n2_start = 10,   n2_increase_per_sec = 1.5, fuel_flow = 0,    egt=97},
    {n2_start = 16.2, n2_increase_per_sec = 1.5, fuel_flow = 120,  egt=97},
    {n2_start = 16.7, n2_increase_per_sec = 1.8, fuel_flow = 180,  egt=97},
    {n2_start = 24,   n2_increase_per_sec = 1.25, fuel_flow = 100, egt=162},
    {n2_start = 26.8, n2_increase_per_sec = 1.25, fuel_flow = 100, egt=263},
    {n2_start = 31.8, n2_increase_per_sec = 0.44, fuel_flow = 120, egt=173},
    {n2_start = 34.2, n2_increase_per_sec = 0.60, fuel_flow = 140, egt=229}
}

local START_UP_PHASES_N1 = {
    {n1_set = 2,      n1_increase_per_sec = 1, fuel_flow = 140, egt=280, stop_ign=false},
    {n1_set = 5,      n1_increase_per_sec = 0.60, fuel_flow = 140, egt=290, stop_ign=false},
    {n1_set = 6.6,    n1_increase_per_sec = 0.60, fuel_flow = 160, egt=303, stop_ign=false},
    {n1_set = 7.3,    n1_increase_per_sec = 0.20, fuel_flow = 180, egt=357, stop_ign=false},
    {n1_set = 7.8,    n1_increase_per_sec = 0.20, fuel_flow = 220, egt=393, stop_ign=false},
    {n1_set = 12.2,   n1_increase_per_sec = 0.60, fuel_flow = 260, egt=573, stop_ign=false},
    {n1_set = 14.9,   n1_increase_per_sec = 0.60, fuel_flow = 280, egt=574, stop_ign=true},
    {n1_set = 15.4,   n1_increase_per_sec = 1.16, fuel_flow = 300, egt=580, stop_ign=true},
    {n1_set = 16.3,   n1_increase_per_sec = 1.08, fuel_flow = 320, egt=592, stop_ign=true},
    {n1_set = 17.1,   n1_increase_per_sec = 0.83, fuel_flow = 340, egt=602, stop_ign=true},
    {n1_set = 17.6,   n1_increase_per_sec = 0.79, fuel_flow = 360, egt=623, stop_ign=true},
    {n1_set = 18.3,   n1_increase_per_sec = 0.24, fuel_flow = 380, egt=637, stop_ign=true},
    {n1_set = 18.3,   n1_increase_per_sec = 0.24, fuel_flow = 380, egt=637, stop_ign=true},
}

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

local egt_eng_1_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values
local egt_eng_2_offset = math.random() * MAX_EGT_OFFSET * 2 - MAX_EGT_OFFSET    -- Offset in engines to simulate realistic values

local eng_1_manual_switch = false   -- Is engine manual start enabled?
local eng_2_manual_switch = false   -- Is engine manual start enabled?

local eng_ignition_switch = globalPropertyia("sim/cockpit2/engine/actuators/ignition_key")
local eng_igniters        = globalPropertyia("sim/cockpit2/engine/actuators/igniter_on")
local starter_duration    = globalPropertyfa("sim/cockpit/engine/starter_duration")

local eng_mixture         = globalPropertyfa("sim/cockpit2/engine/actuators/mixture_ratio")
local eng_N1_enforce      = globalPropertyfa("sim/flightmodel/engine/ENGN_N1_")
local eng_N2_enforce      = globalPropertyfa("sim/flightmodel/engine/ENGN_N2_")

local eng_FF_kgs          = globalPropertyfa("sim/cockpit2/engine/indicators/fuel_flow_kg_sec")

local eng_N1_off  = {0,0}   -- N1 for startup procedure
local eng_N2_off  = {0,0}   -- N2 for startup procedure
local eng_FF_off  = {0,0}   -- FF for startup procedure
local eng_EGT_off = {get(OTA),get(OTA)}   -- EGT for startup procedure

local slow_start_time_requested = false

----------------------------------------------------------------------------------------------------
-- Functions - Commands
----------------------------------------------------------------------------------------------------
function engines_auto_slow_start(phase)
    -- When the user press Flight -> Start engines to running
    if phase == SASL_COMMAND_BEGIN then
        slow_start_time_requested = true -- Please check the function update_auto_start()
    end
    return 0
end

function engines_auto_quick_start(phase)
    if phase == SASL_COMMAND_BEGIN then
        sasl.commandOnce(FUEL_cmd_internal_qs)
    
        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
        set(Engine_mode_knob, 0)
    end
    return 1
end

function onAirportLoaded()
    -- When the aircraft is loaded in flight, let's switch on all the pumps
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        engines_auto_quick_start(SASL_COMMAND_BEGIN)
    else
        set(Engine_1_master_switch, 0)
        set(Engine_2_master_switch, 0)
        set(Engine_mode_knob, 0)
    end
end

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ENG_cmd_manual_start_1,     0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_1_manual_switch = not eng_1_manual_switch end end )
sasl.registerCommandHandler (ENG_cmd_manual_start_2,     0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_2_manual_switch = not eng_2_manual_switch end end )
sasl.registerCommandHandler (sasl.findCommand("sim/operation/auto_start"),  1, engines_auto_slow_start )
sasl.registerCommandHandler (sasl.findCommand("sim/operation/quick_start"), 1, engines_auto_quick_start )

----------------------------------------------------------------------------------------------------
-- Functions - Engine parameters
----------------------------------------------------------------------------------------------------

local function n1_to_n2(n1)
    return 50 * math.log10(n1) + (n1+50)^3/220000 + 0.64
end

local function min_n1(altitude)
    return 5.577955*math.log(0.03338352*altitude+23.66644)+1.724586
end

local function n1_to_egt(n1, outside_temperature)
    return 1067.597 + (525.8561 - 1067.597)/(1 + (n1/76.42303)^4.611082) + (outside_temperature-6) *2
end

local function update_n1_minimum()
    local curr_altitude = get(Elevation_m) * 3.28084
    local comp_min_n1 = min_n1(curr_altitude)
    local always_a_minimum = ENG_N1_LL_IDLE + 0.2
    set(Eng_N1_idle, comp_min_n1)

    -- Update ENG1 N1 minimum
    local curr_n1 = get(Eng_1_N1)    
    if curr_n1 < always_a_minimum and get(Engine_1_avail) == 1 then
        set(eng_N1_enforce, always_a_minimum, 1)
    end

    -- Update ENG2 N1 minimum
    curr_n1 = get(Eng_2_N1)
    if curr_n1 < always_a_minimum and get(Engine_2_avail) == 1 then
        set(eng_N1_enforce, always_a_minimum, 2)
    end
end

local function update_n2()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > 5 then
        set(Eng_1_N2, n1_to_n2(eng_1_n1))
    else
        set(Eng_1_N2, eng_N2_off[1])
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > 5 then
        set(Eng_2_N2, n1_to_n2(eng_2_n1))
    else
        set(Eng_2_N2, eng_N2_off[2])
    end

end


local function update_egt()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > ENG_N1_LL_IDLE then
        local computed_egt = n1_to_egt(eng_1_n1, get(OTA))
        computed_egt = computed_egt + egt_eng_1_offset + math.random()*2 -- Let's add a bit of randomness
        Set_dataref_linear_anim(Eng_1_EGT_c, computed_egt, -50, 1500, 70)
    else
        set(Eng_1_EGT_c, eng_EGT_off[1])
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > ENG_N1_LL_IDLE then
        local computed_egt = n1_to_egt(eng_2_n1, get(OTA))
        computed_egt = computed_egt + egt_eng_2_offset + math.random()*2 -- Let's add a bit of randomness
        Set_dataref_linear_anim(Eng_2_EGT_c, computed_egt, -50, 1500, 70)
    else
        set(Eng_2_EGT_c, eng_EGT_off[2])
    end

end

local function update_ff()
    local eng_1_n1 = get(Eng_1_N1)
    if eng_1_n1 > ENG_N1_LL_IDLE then
        set(Eng_1_FF_kgs, get(eng_FF_kgs,1))
    else
        set(Eng_1_FF_kgs,eng_FF_off[1])
    end

    local eng_2_n1 = get(Eng_2_N1)
    if eng_2_n1 > ENG_N1_LL_IDLE then
        set(Eng_2_FF_kgs, get(eng_FF_kgs,2))
    else
        set(Eng_2_FF_kgs,eng_FF_off[2])
    end
 
end

local function update_avail()

    -- ENG 1
    if get(Eng_1_N1) > ENG_N1_LL_IDLE and get(Engine_1_master_switch) == 1 then
        if get(Engine_1_avail) == 0 then
            set(EWD_engine_avail_ind_1_start, get(TIME))
            set(Engine_1_avail, 1)
        end
    else
        set(Engine_1_avail, 0)    
        set(EWD_engine_avail_ind_1_start, 0)
    end
    
    -- ENG 2
    if get(Eng_2_N1) > ENG_N1_LL_IDLE and get(Engine_2_master_switch) == 1 then
        if get(Engine_2_avail) == 0 then
            set(EWD_engine_avail_ind_2_start, get(TIME))
            set(Engine_2_avail, 1)
        end
    else
        set(Engine_2_avail, 0)    
        set(EWD_engine_avail_ind_2_start, 0)
    end

    
end

----------------------------------------------------------------------------------------------------
-- Functions - Ignition stuffs
----------------------------------------------------------------------------------------------------

local function perform_crank_procedure(eng, wet_cranking)
    if (eng==1 and get(Engine_1_avail) == 1) or (eng==2 and get(Engine_2_avail) == 1) then
        return  -- Crank has no sense if the engine is already running
    end

    set(eng_mixture, 0, eng)                                    -- No mixture for dry cranking

    -- Set N2 for cranking
    eng_N2_off[eng] = Set_linear_anim_value(eng_N2_off[eng], ENG_N1_CRANK, 0, 120, 0.25)
    set(eng_N2_enforce, eng_N2_off[eng], eng)
    
    -- Set WGT for cranking
    eng_EGT_off[eng] = Set_linear_anim_value(eng_EGT_off[eng], ENG_N1_CRANK_EGT, -50, 1500, 2)
    
    if wet_cranking then
        -- Wet cranking requested, let's spill a bit of fuel
        eng_FF_off[eng] = ENG_N1_CRANK_FF/3600
    else
        -- Dry cranking
        eng_FF_off[eng] = 0
    end
    
end

local function perform_starting_procedure_follow_n2(eng)
    set(eng_mixture, 0, eng) -- No mixture in this phase

    for i=1,(#START_UP_PHASES_N2-1) do
        if eng_N2_off[eng] < START_UP_PHASES_N2[i+1].n2_start then
            eng_N2_off[eng] = eng_N2_off[eng] + START_UP_PHASES_N2[i].n2_increase_per_sec * get(DELTA_TIME)
            set(eng_N2_enforce, eng_N2_off[eng], eng)
            eng_FF_off[eng] = START_UP_PHASES_N2[i].fuel_flow  / 3600
            
            perc = (eng_N2_off[eng] - START_UP_PHASES_N2[i].n2_start) / (START_UP_PHASES_N2[i+1].n2_start - START_UP_PHASES_N2[i].n2_start)
            eng_EGT_off[eng] = Math_lerp(START_UP_PHASES_N2[i].egt, START_UP_PHASES_N2[i+1].egt, perc)
            
            break
        end
    end
end

local function perform_starting_procedure_follow_n1(eng)
    set(eng_mixture, 1, eng) -- Mixture in this phase
    set(eng_igniters, 1, eng)


    for i=1,(#START_UP_PHASES_N1-1) do
        local curr_N1 = math.max(eng_N1_off[eng],2)
        if curr_N1 < START_UP_PHASES_N1[i+1].n1_set then
        
            local new_N1 = curr_N1 + START_UP_PHASES_N1[i].n1_increase_per_sec * get(DELTA_TIME)
            eng_N1_off[eng] = new_N1
            set(eng_N1_enforce, new_N1, eng)

            eng_FF_off[eng] = START_UP_PHASES_N1[i].fuel_flow  / 3600
            
            perc = (curr_N1 - START_UP_PHASES_N1[i].n1_set) / (START_UP_PHASES_N1[i+1].n1_set - START_UP_PHASES_N1[i].n1_set)
            eng_EGT_off[eng] = Math_lerp(START_UP_PHASES_N1[i].egt, START_UP_PHASES_N1[i+1].egt, perc)
            
            break
        end
    end
    
    if eng_N1_off[eng] > 12 then

        set(eng_igniters, 0, eng)
    end
end

local function perform_starting_procedure(eng)
    if eng_N2_off[eng] < 9.5 then
        -- Ok let's start by cranking the engine to start rotation
        perform_crank_procedure(eng, false)
        return
    end
    
    if eng_N2_off[eng] < START_UP_PHASES_N2[#START_UP_PHASES_N2].n2_start then

        set(starter_duration, MAGIC_NUMBER, eng)

        perform_starting_procedure_follow_n2(eng)
    elseif eng_N1_off[eng] < START_UP_PHASES_N1[#START_UP_PHASES_N1].n1_set then
        perform_starting_procedure_follow_n1(eng)
    else

    end
    
end


local function update_starter_datarefs()
    --setting integer dataref range
    set(Engine_mode_knob,Math_clamp(get(Engine_mode_knob), -1, 1))
    set(Engine_1_master_switch,Math_clamp(get(Engine_1_master_switch), 0, 1))
    set(Engine_2_master_switch,Math_clamp(get(Engine_2_master_switch), 0, 1))
end

local function update_startup()

    local require_cooldown = {true, true}

    if get(Engine_mode_knob) == 1 then      -- Ignition
        if get(Engine_1_master_switch) == 1 and get(Engine_1_avail) == 0  then
            perform_starting_procedure(1)
            require_cooldown[1] = false
        end
        if get(Engine_2_master_switch) == 1 and get(Engine_2_avail) == 0 then
            perform_starting_procedure(2)
            require_cooldown[2] = false
        end
    elseif get(Engine_mode_knob) == -1 then -- Crank
        if eng_1_manual_switch then
            perform_crank_procedure(1, get(Engine_1_master_switch) == 1)
            require_cooldown[1] = false
        end
        if eng_2_manual_switch then
            perform_crank_procedure(2, get(Engine_2_master_switch) == 1)
            require_cooldown[2] = false
        end
    end
    
    -- No ignition, engine is off of shutting down
    if get(Engine_1_avail) == 0  and require_cooldown[1] then    -- Turn off the engine
        -- Set N2 to zero
        eng_N2_off[1] = Set_linear_anim_value(eng_N2_off[1], 0, 0, 120, 1)
        set(eng_N2_enforce, eng_N2_off[1], 1)
        
        -- Set EGT and FF to zero
        eng_EGT_off[1] = Set_linear_anim_value(eng_EGT_off[1], get(OTA), -50, 1500, 1)
        eng_FF_off[1] = 0
        eng_N1_off[1] = Set_linear_anim_value(eng_N1_off[1], 0, 0, 120, 2)
        set(eng_igniters, 0, 1)
    end
    if get(Engine_2_avail) == 0 and require_cooldown[2] then    -- Turn off the engine
        -- Set N2 to zero
        eng_N2_off[2] = Set_linear_anim_value(eng_N2_off[2], 0, 0, 120, 1)
        set(eng_N2_enforce, eng_N2_off[2], 2)
        
        -- Set EGT and FF to zero
        eng_EGT_off[2] = Set_linear_anim_value(eng_EGT_off[2], get(OTA), -50, 1500, 1)
        eng_FF_off[2] = 0
        eng_N1_off[2] = Set_linear_anim_value(eng_N1_off[2], 0, 0, 120, 2)
        set(eng_igniters, 0, 2)
    end

end

local function update_auto_start()
    if not slow_start_time_requested then
        return  -- auto start not requested
    end
 
    -- Turn on the batteries immediately and start the APU   
    ELEC_sys.batteries[1].switch_status = true
    ELEC_sys.batteries[2].switch_status = true
    
    set(Apu_start_position, 2)
    set(Apu_bleed_switch, 1)

    set(eng_ignition_switch, 0, 1) 
    set(eng_ignition_switch, 0, 2) 

    if get(Apu_avail) == 1 then
        set(Engine_mode_knob,1)
        set(Engine_2_master_switch, 1)
    end

    if get(Engine_2_avail) == 1 then
        set(Engine_1_master_switch, 1)
    end

    if get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1 then
        set(Engine_mode_knob, 0)
        slow_start_time_requested = false
    end

end

function update()
    update_starter_datarefs()
    if get(FLIGHT_TIME) > 0.5 then
        update_startup()
    end

    update_n1_minimum()
    update_n2()
    update_egt()
    update_ff()
    update_avail()

    update_auto_start()

end
