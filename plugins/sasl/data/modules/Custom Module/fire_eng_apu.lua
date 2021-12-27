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
-- File: fire_eng_apu.lua
-- Short description: Fire protection for engines and APU
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local TIME_TO_DISCH = 2
local TIME_TO_EXTINGUISH_APU = 5 + math.random() * 10

local TIME_TO_EXTINGUISH_ENG_NO_AGENT = 3+math.random()*3 -- Time in the best case, when not agents are necessary
local TIME_TO_EXTINGUISH_ENG = 10 + math.random() * 15

-- Let's generate some random cases. The following probabilities MUST sum up to 1 !!!
local ENG_PROB_EXT_NO_AGENT = 0.05 -- Probability to exinguish the fire without the use of agents
local ENG_PROB_EXT_1_AGENT  = 0.4 -- Probability to exinguish the fire with the use of one agent only
local ENG_PROB_EXT_2_AGENTS = 0.45 -- Probability to exinguish the fire with the use of two agents
local ENG_PROB_EXT_NO_AGENT = 0.1 -- Probability of non-being able to extistguish the fire

local NO_AGENT  = 0
local AGENT_1   = 1
local AGENT_2   = 2
local NO_EXT    = 3


----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
local apu_still_on_fire = false
local apu_squib_triggered = false
local apu_squib_triggered_time = 0

local eng_pb_triggered_time = {0,0}
local eng_squib_triggered = {{false, false}, {false, false}}
local eng_squib_triggered_time = {{0, 0}, {0, 0}}

FIRE_sys.apu_block_position  = false
FIRE_sys.apu_squib_discharged = false
FIRE_sys.apu_on_test = false

FIRE_sys.eng = {{},{}}

FIRE_sys.eng[1].still_on_fire = false
FIRE_sys.eng[1].on_test = false
FIRE_sys.eng[1].squib_1_disch = false
FIRE_sys.eng[1].squib_2_disch = false
FIRE_sys.eng[1].block_position = false

FIRE_sys.eng[2].still_on_fire = false
FIRE_sys.eng[2].on_test = false
FIRE_sys.eng[2].squib_1_disch = false
FIRE_sys.eng[2].squib_2_disch = false
FIRE_sys.eng[2].block_position = false

----------------------------------------------------------------------------------------------------
-- Command handlers
----------------------------------------------------------------------------------------------------

-- Big red buttons
sasl.registerCommandHandler (FIRE_cmd_push_APU, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        local guard_dr = globalProperty ("a321neo/cockpit/overhead/guards/state/FIRE_APU")
        if get(guard_dr) == 0 then
            return  -- guard is not open
        end

        FIRE_sys.apu_block_position = not FIRE_sys.apu_block_position
    end
end)

function handler_eng_push_btn(phase, id)
    if phase == SASL_COMMAND_BEGIN then
        local guard_dr = globalProperty ("a321neo/cockpit/overhead/guards/state/FIRE_ENG" .. id)
        if get(guard_dr) == 0 then
            return  -- guard is not open
        end
        FIRE_sys.eng[id].block_position = not FIRE_sys.eng[id].block_position
        if FIRE_sys.eng[id].block_position then
            eng_pb_triggered_time[id] = get(TIME)
        else
            eng_pb_triggered_time[id] = 0
        end
    end
end

sasl.registerCommandHandler (FIRE_cmd_push_ENG_1, 0, function(phase) handler_eng_push_btn(phase,1) end)
sasl.registerCommandHandler (FIRE_cmd_push_ENG_2, 0, function(phase) handler_eng_push_btn(phase,2) end)


-- Agents

sasl.registerCommandHandler (FIRE_cmd_APU_A, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if FIRE_sys.apu_block_position and not apu_squib_triggered then
            apu_squib_triggered = true
            apu_squib_triggered_time = get(TIME)
        end
    end
end)



function handler_eng_agent_btn(phase, eng, agent)
    if phase == SASL_COMMAND_BEGIN then
        if FIRE_sys.eng[eng].block_position and not eng_squib_triggered[eng][agent] then
            eng_squib_triggered[eng][agent] = true
            eng_squib_triggered_time[eng][agent] = get(TIME)
        end
    end
end

sasl.registerCommandHandler (FIRE_cmd_ENG_1_A_1, 0, function(phase) handler_eng_agent_btn(phase, 1, 1) end)
sasl.registerCommandHandler (FIRE_cmd_ENG_1_A_2, 0, function(phase) handler_eng_agent_btn(phase, 1, 2) end)
sasl.registerCommandHandler (FIRE_cmd_ENG_2_A_1, 0, function(phase) handler_eng_agent_btn(phase, 2, 1) end)
sasl.registerCommandHandler (FIRE_cmd_ENG_2_A_2, 0, function(phase) handler_eng_agent_btn(phase, 2, 2) end)

-- TEST BUTTONS

sasl.registerCommandHandler (FIRE_cmd_test_APU, 0, function(phase)
    if phase == SASL_COMMAND_CONTINUE then
        FIRE_sys.apu_on_test = true
    else
        FIRE_sys.apu_on_test = false
    end
end)

sasl.registerCommandHandler (FIRE_cmd_test_ENG_1, 0, function(phase)
    if phase == SASL_COMMAND_CONTINUE then
        FIRE_sys.eng[1].on_test = true
    else
        FIRE_sys.eng[1].on_test = false
    end
end)

sasl.registerCommandHandler (FIRE_cmd_test_ENG_2, 0, function(phase)
    if phase == SASL_COMMAND_CONTINUE then
        FIRE_sys.eng[2].on_test = true
    else
        FIRE_sys.eng[2].on_test = false
    end
end)


----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

local function random_eng_result()
    local rnd = math.random()
    if rnd < ENG_PROB_EXT_NO_AGENT then
        return NO_AGENT
    elseif rnd < ENG_PROB_EXT_1_AGENT + ENG_PROB_EXT_NO_AGENT then
        return AGENT_1
    elseif rnd < ENG_PROB_EXT_2_AGENTS + ENG_PROB_EXT_1_AGENT + ENG_PROB_EXT_NO_AGENT then
        return AGENT_2
    else
        return NO_EXT
    end
end

local eng_fire_result = {random_eng_result(), random_eng_result()}

local function update_pbs()
    pb_set(PB.ovhd.fire_apu_block, apu_still_on_fire or FIRE_sys.apu_on_test, false)
    
    pb_set(PB.ovhd.fire_eng1_block, FIRE_sys.eng[1].still_on_fire or FIRE_sys.eng[1].on_test, false)
    pb_set(PB.ovhd.fire_eng2_block, FIRE_sys.eng[2].still_on_fire or FIRE_sys.eng[2].on_test, false)
    pb_set(PB.ped.eng_1_fire_fault, ENG.dyn[1].is_failed == 1, FIRE_sys.eng[1].still_on_fire or FIRE_sys.eng[1].on_test)
    pb_set(PB.ped.eng_2_fire_fault, ENG.dyn[2].is_failed == 1, FIRE_sys.eng[2].still_on_fire or FIRE_sys.eng[2].on_test)

    pb_set(PB.ovhd.fire_eng_1_ag_1, FIRE_sys.eng[1].squib_1_disch or FIRE_sys.eng[1].on_test, FIRE_sys.eng[1].block_position or FIRE_sys.eng[1].on_test)
    pb_set(PB.ovhd.fire_eng_1_ag_2, FIRE_sys.eng[1].squib_2_disch or FIRE_sys.eng[1].on_test, FIRE_sys.eng[1].block_position or FIRE_sys.eng[1].on_test)
    pb_set(PB.ovhd.fire_eng_2_ag_1, FIRE_sys.eng[2].squib_1_disch or FIRE_sys.eng[2].on_test, FIRE_sys.eng[2].block_position or FIRE_sys.eng[2].on_test)
    pb_set(PB.ovhd.fire_eng_2_ag_2, FIRE_sys.eng[2].squib_2_disch or FIRE_sys.eng[2].on_test, FIRE_sys.eng[2].block_position or FIRE_sys.eng[2].on_test)

    pb_set(PB.ovhd.fire_apu_ag,    FIRE_sys.apu_squib_discharged or FIRE_sys.apu_on_test, FIRE_sys.apu_block_position or FIRE_sys.apu_on_test)
end

local function update_drs()
    Set_dataref_linear_anim_nostop(Fire_pb_APU_lever, FIRE_sys.apu_block_position and 1 or 0, 0, 1, 10)
    Set_dataref_linear_anim_nostop(Fire_pb_ENG_1_lever, FIRE_sys.eng[1].block_position and 1 or 0, 0, 1, 10)
    Set_dataref_linear_anim_nostop(Fire_pb_ENG_2_lever, FIRE_sys.eng[2].block_position and 1 or 0, 0, 1, 10)
end


local function update_apu_fire()

    apu_still_on_fire = get(FAILURE_FIRE_APU) == 1

    if apu_squib_triggered_time ~= 0 then
        if get(TIME) - apu_squib_triggered_time > TIME_TO_DISCH then    
            FIRE_sys.apu_squib_discharged = true
        end
        if get(TIME) - apu_squib_triggered_time > TIME_TO_EXTINGUISH_APU then    
            apu_still_on_fire = false
        end
    end

end

local function update_eng_fire(eng)

    -- FIRE PB
    FIRE_sys.eng[eng].still_on_fire = ((eng == 1) and (get(FAILURE_FIRE_ENG_1) == 1)) or ((eng == 2) and get(FAILURE_FIRE_ENG_2) == 1)

    if FIRE_sys.eng[eng].block_position then
        set(eng == 1 and Fire_pb_ENG1_status or Fire_pb_ENG2_status, 1)  -- This is for fuel system 
        if eng_fire_result[eng] == NO_AGENT and get(TIME) - eng_pb_triggered_time[eng] > TIME_TO_EXTINGUISH_ENG_NO_AGENT then
            FIRE_sys.eng[eng].still_on_fire = false
        end
    else
        set(eng == 1 and Fire_pb_ENG1_status or Fire_pb_ENG2_status, 0)
    end

    -- AGENT 1

    if eng_squib_triggered_time[eng][1] ~= 0 then
        if get(TIME) - eng_squib_triggered_time[eng][1] > TIME_TO_DISCH then    
            FIRE_sys.eng[eng].squib_1_disch = true
        end
    end

    if FIRE_sys.eng[eng].squib_1_disch then
        set(eng == 1 and Fire_pb_ENG1_status or Fire_pb_ENG2_status, 1)  -- This is to say "if you discharged the squib, no way you can restart the engine"
        if (eng_fire_result[eng] == AGENT_1 or eng_fire_result[eng] == NO_AGENT) and get(TIME) - eng_squib_triggered_time[eng][1] > TIME_TO_EXTINGUISH_ENG then
            FIRE_sys.eng[eng].still_on_fire = false
        end
    end

    -- AGENT 2

    if eng_squib_triggered_time[eng][2] ~= 0 then
        if get(TIME) - eng_squib_triggered_time[eng][2] > TIME_TO_DISCH then    
            FIRE_sys.eng[eng].squib_2_disch = true
        end
    end

    if FIRE_sys.eng[eng].squib_2_disch then
        set(eng == 1 and Fire_pb_ENG1_status or Fire_pb_ENG2_status, 1)  -- This is to say "if you discharged the squib, no way you can restart the engine"
        if (eng_fire_result[eng] == AGENT_2 or eng_fire_result[eng] == NO_AGENT) and get(TIME) - eng_squib_triggered_time[eng][2] > TIME_TO_EXTINGUISH_ENG then
            FIRE_sys.eng[eng].still_on_fire = false
        end
    end

end

----------------------------------------------------------------------------------------------------
-- Main update function
----------------------------------------------------------------------------------------------------

function update()
    perf_measure_start("fire_eng_apu:update()")

    update_apu_fire()
    update_eng_fire(1)
    update_eng_fire(2)
    update_pbs()
    update_drs()
    
    perf_measure_stop("fire_eng_apu:update()")
end
