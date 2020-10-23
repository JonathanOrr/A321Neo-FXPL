----------------------------------------------------------------------------------------------------
-- APU management file
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

FLAP_OPEN_TIME_SEC = 20


----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local master_switch_status  = false
local master_switch_enabled_time = 0
local start_requested = false

local random_egt_apu = 0
local random_egt_apu_last_update = 0
----------------------------------------------------------------------------------------------------
-- Init
----------------------------------------------------------------------------------------------------
set(Apu_bleed_switch, 0)
set(APU_EGT, get(OTA))

----------------------------------------------------------------------------------------------------
-- Command handlers
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler ( APU_cmd_master, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if master_switch_status then
            master_switch_status = false
        else
            master_switch_status = true
            master_switch_enabled_time = get(TIME)
        end
    end
end)

sasl.registerCommandHandler ( APU_cmd_start, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if master_switch_status then
            start_requested = true
        end
    end
    return 1
end)


function update_egt()

    if get(TIME) - random_egt_apu_last_update > 2 then
        random_egt_apu = math.random() * 6 - 3
        random_egt_apu_last_update = get(TIME)
    end

    local apu_n1 = get(Apu_N1)

    if master_switch_status then
        if apu_n1 < 1 then
            Set_dataref_linear_anim(APU_EGT, get(OTA), -50, 1000, 1)
        elseif apu_n1 <= 25 then
             local target_egt = Math_rescale(0, get(OTA), 25, 900+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        elseif apu_n1 <= 50 then
            local target_egt = Math_rescale(25, 900, 50,  800+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        elseif apu_n1 > 50 then
            local target_egt = Math_rescale(50, 800, 100, 400+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        end
    else
        Set_dataref_linear_anim(APU_EGT, get(OTA), -50, 1000, 3)
    end
end

local function update_button_datarefs()
    -- TODO FAILURE
    set(Apu_master_button_state, master_switch_status and 1 or 0)

    set(Apu_start_button_state, (start_requested and 1 or 0) + (get(Apu_avail) == 1 and 10 or 0))

end

local function update_apu_flap()
    if master_switch_status and get(TIME) - master_switch_enabled_time > FLAP_OPEN_TIME_SEC then
        set(APU_flap, 1)
    else
        set(APU_flap, 0)
    end
end

local function update_start()
    if master_switch_status then 
        if start_requested and get(APU_flap) == 1 and get(Apu_avail) == 0  and get(Apu_fuel_source) > 0 then
            set(Apu_start_position, 2)
        elseif get(Apu_avail) == 1 then
            set(Apu_start_position, 1)
            start_requested = false
        else
            set(Apu_start_position, 0)
        end
    else
        set(Apu_start_position, 0)
        start_requested = false
    end
end

function update()

    --apu availability
    if get(Apu_N1) > 95 then
        set(Apu_avail, 1)
    elseif get(Apu_N1) < 100 then
        set(Apu_avail, 0)
    end

    update_egt()
    update_button_datarefs()
    update_apu_flap()
    update_start()

    --apu (ecam) bleed states
    if get(Apu_avail) == 0 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 0, 0, 39, 0.85))
        set(Apu_bleed_state, 0)
    elseif get(Apu_avail) == 1 and get(Apu_bleed_switch) == 0 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 0, 0, 39, 0.85))
        set(Apu_bleed_state, 1)
    elseif get(Apu_avail) == 1 and get(Apu_bleed_switch) == 1 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 39, 0, 39, 0.85))
        set(Apu_bleed_state, 2)
    end

end
