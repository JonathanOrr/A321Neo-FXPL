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
-- File: fire_cargo.lua
-- Short description: Fire/Smoke protection for cargo
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------

local test_starts_at = 0

local fire_fwd_started_at = 0
local fire_aft_started_at = 0

local time_to_dish_aft = 50 + math.random() * 10    -- This is randomized, time required to discharge the whole bottle
local time_to_dish_fwd = 50 + math.random() * 10    -- This is randomized, time required to discharge the whole bottle

local finish_discharging_fwd = false
local finish_discharging_aft = false

----------------------------------------------------------------------------------------------------
-- Command handlers
----------------------------------------------------------------------------------------------------

sasl.registerCommandHandler (FIRE_cmd_smoke_cargo_test, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then 
        test_starts_at = get(TIME)
    elseif phase == SASL_COMMAND_END then
        test_starts_at = 0
    end
end)

sasl.registerCommandHandler (FIRE_cmd_smoke_cargo_fwd, 0, function(phase)
    if get(Fire_cargo_fwd_disch_at) == 0 then
        set(Fire_cargo_fwd_disch_at, get(TIME))
    end
end)

sasl.registerCommandHandler (FIRE_cmd_smoke_cargo_aft, 0, function(phase)
    if get(Fire_cargo_aft_disch_at) == 0 then
        set(Fire_cargo_aft_disch_at, get(TIME))
    end
end)

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------


local function update_disch()
    if get(Fire_cargo_fwd_disch_at) > 0 then
        if get(TIME) - get(Fire_cargo_fwd_disch_at) > time_to_dish_fwd then
            finish_discharging_fwd = true
        end
        if get(TIME) - get(Fire_cargo_fwd_disch_at) > time_to_dish_fwd-10 then
            set(Fire_cargo_fwd_smoke_detected, 0)
        end
    end
    
    if get(Fire_cargo_aft_disch_at) > 0 then
        if get(TIME) - get(Fire_cargo_aft_disch_at) > time_to_dish_aft then
            finish_discharging_aft = true
        end
        if get(TIME) - get(Fire_cargo_aft_disch_at) > time_to_dish_aft-10 then
            set(Fire_cargo_aft_smoke_detected, 0)
        end
    end
end

local function update_pbs_test()
    local diff = get(TIME) - test_starts_at
    
    -- After 3 seconds:
    -- 1 second smoke on
    -- 1 second off
    -- 1 second smoke on
    -- continuous disch on until release
    
    pb_set(PB.ovhd.cargo_smoke_fwd, diff > 7, (diff > 3 and diff < 4) or (diff > 5 and diff < 6))
    pb_set(PB.ovhd.cargo_smoke_aft, diff > 7, (diff > 3 and diff < 4) or (diff > 5 and diff < 6))
end

local function update_pbs()

    pb_set(PB.ovhd.cargo_smoke_fwd, finish_discharging_fwd, get(Fire_cargo_fwd_smoke_detected) == 1)
    pb_set(PB.ovhd.cargo_smoke_aft, finish_discharging_aft, get(Fire_cargo_aft_smoke_detected) == 1)

end

local function update_fire_time()
    if get(FAILURE_FIRE_CARGO_FWD) == 1 then
        -- Ok we have a fire
        if fire_fwd_started_at == 0 then
            -- Just started
            fire_fwd_started_at = get(TIME)
            set(Fire_cargo_fwd_smoke_detected, 1)
        end
    else
        -- No more fire, reset variable
        fire_fwd_started_at = 0
        set(Fire_cargo_fwd_smoke_detected, 0)
    end

    if get(FAILURE_FIRE_CARGO_AFT) == 1 then
        -- Ok we have a fire
        if fire_aft_started_at == 0 then
            -- Just started
            fire_aft_started_at = get(TIME)
            set(Fire_cargo_aft_smoke_detected, 1)
        end
    else
        -- No more fire, reset variable
        fire_aft_started_at = 0
        set(Fire_cargo_aft_smoke_detected, 0)
    end

end

----------------------------------------------------------------------------------------------------
-- Main update function
----------------------------------------------------------------------------------------------------

function update()

    if test_starts_at > 0 then
        update_pbs_test()
    else
        update_pbs()
    end

    update_fire_time()
    update_disch()

end
