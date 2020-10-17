----------------------------------------------------------------------------------------------------
-- Fuel system Logic file
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

-- Pumps and XFR ids
local L_TK_PUMP_1  = 1
local L_TK_PUMP_2  = 2
local R_TK_PUMP_1  = 3
local R_TK_PUMP_2  = 4
local C_TK_XFR_1   = 5
local C_TK_XFR_2   = 6
local ACT_TK_XFR = 7
local RCT_TK_XFR = 8

-- Tanks
local tank_LEFT  = 1
local tank_RIGHT = 2
local tank_CENTER= 0
local tank_ACT   = 3
local tank_RCT   = 4

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local tank_pump_and_xfr = {
    [L_TK_PUMP_1] = { switch = false, status = false },
    [L_TK_PUMP_2] = { switch = false, status = false },
    [R_TK_PUMP_1] = { switch = false, status = false },
    [R_TK_PUMP_2] = { switch = false, status = false },
    [C_TK_XFR_1]  = { switch = false, status = false },
    [C_TK_XFR_2]  = { switch = false, status = false },
    [ACT_TK_XFR]  = { switch = false, status = false },
    [RCT_TK_XFR]  = { switch = false, status = false }
}

local C_tank_mode   = false -- false AUTO, true MANUAL
local X_feed_mode   = false -- false CLOSED, true OPEN (command, not status)
local X_feed_status = false -- false CLOSED, true OPEN (command, not status)

local eng1_fuel_status = 0 -- 0 : no fuel, 1 : gravity left, 2 : gravity right, 3 : left, 4 : right (xfeed)
local eng2_fuel_status = 0 -- 0 : no fuel, 1 : gravity left, 2 : gravity right, 3 : left (xfeed), 4 : right

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (FUEL_cmd_L_TK_pump_1,     0, function(phase) fuel_toggle_pump_xfr(phase, L_TK_PUMP_1) end )
sasl.registerCommandHandler (FUEL_cmd_L_TK_pump_2,     0, function(phase) fuel_toggle_pump_xfr(phase, L_TK_PUMP_2) end )
sasl.registerCommandHandler (FUEL_cmd_R_TK_pump_1,     0, function(phase) fuel_toggle_pump_xfr(phase, R_TK_PUMP_1) end )
sasl.registerCommandHandler (FUEL_cmd_R_TK_pump_2,     0, function(phase) fuel_toggle_pump_xfr(phase, R_TK_PUMP_2) end )
sasl.registerCommandHandler (FUEL_cmd_C_TK_XFR_1,      0, function(phase) fuel_toggle_pump_xfr(phase, C_TK_XFR_1) end )
sasl.registerCommandHandler (FUEL_cmd_C_TK_XFR_2,      0, function(phase) fuel_toggle_pump_xfr(phase, C_TK_XFR_2) end )
sasl.registerCommandHandler (FUEL_cmd_ACT_TK_XFR,      0, function(phase) fuel_toggle_pump_xfr(phase, ACT_TK_XFR) end )
sasl.registerCommandHandler (FUEL_cmd_RCT_TK_XFR,      0, function(phase) fuel_toggle_pump_xfr(phase, RCT_TK_XFR) end )

sasl.registerCommandHandler (FUEL_cmd_C_TK_mode,      0, function(phase) fuel_toggle_tank_mode(phase) end )
sasl.registerCommandHandler (FUEL_cmd_X_FEED,         0, function(phase) fuel_toggle_x_feed_mode(phase) end )

----------------------------------------------------------------------------------------------------
-- Functions - Commands
----------------------------------------------------------------------------------------------------

function fuel_toggle_pump_xfr(phase, tank)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    tank_pump_and_xfr[tank].switch = not tank_pump_and_xfr[tank].switch
end

function fuel_toggle_tank_mode(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    C_tank_mode = not C_tank_mode
end

function fuel_toggle_x_feed_mode(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    X_feed_mode = not X_feed_mode
end

----------------------------------------------------------------------------------------------------
-- Functions - Logic
----------------------------------------------------------------------------------------------------

local function update_lights()

    -- TODO Add AC bus lights

    -- Fuel fumps illuminated when off
    set(Fuel_light_pumps, (tank_pump_and_xfr[L_TK_PUMP_1].switch and 0 or 1) +
                          (get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and 10 or 0), L_TK_PUMP_1)
    set(Fuel_light_pumps, (tank_pump_and_xfr[L_TK_PUMP_1].switch and 0 or 1) +
                          (get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and 10 or 0), L_TK_PUMP_2)
    set(Fuel_light_pumps, (tank_pump_and_xfr[L_TK_PUMP_1].switch and 0 or 1) +
                          (get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and 10 or 0), R_TK_PUMP_1)
    set(Fuel_light_pumps, (tank_pump_and_xfr[L_TK_PUMP_1].switch and 0 or 1) +
                          (get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and 10 or 0), R_TK_PUMP_2)

    set(Fuel_light_pumps, (tank_pump_and_xfr[C_TK_XFR_1].switch and 0 or 1) +
                          (get(FAILURE_FUEL, C_TK_XFR_1) == 1 and 10 or 0), C_TK_XFR_1)

    set(Fuel_light_pumps, (tank_pump_and_xfr[C_TK_XFR_2].switch and 0 or 1) +
                          (get(FAILURE_FUEL, C_TK_XFR_2) == 1 and 10 or 0), C_TK_XFR_2)

    -- ACT and RCT have the opposite light behaviour, illuminated when on
    set(Fuel_light_pumps, (tank_pump_and_xfr[ACT_TK_XFR].switch and 1 or 0) +
                          (get(FAILURE_FUEL, ACT_TK_XFR) == 1 and 10 or 0), ACT_TK_XFR)
                          
    set(Fuel_light_pumps, (tank_pump_and_xfr[RCT_TK_XFR].switch and 1 or 0) +
                          (get(FAILURE_FUEL, RCT_TK_XFR) == 1 and 10 or 0), RCT_TK_XFR)


end

local function update_pump_dr()
    set(Fuel_pump_on[tank_CENTER], 0) -- It should never be turned on because it does't feed engine
    set(Fuel_pump_on[tank_ACT],    0) -- It should never be turned on because it does't feed engine
    set(Fuel_pump_on[tank_RCT],    0) -- It should never be turned on because it does't feed engine


    -- ENG1 - LEFT
    set(Fuel_pump_on[tank_LEFT], 0)
    if eng1_fuel_status == 3 or eng1_fuel_status == 1 then
        -- Direct feed or gravity feed
        set(Fuel_pump_on[tank_LEFT], 1)
        set(Fuel_tank_selector_eng_1, 1)
    elseif eng1_fuel_status == 4 then
        -- Cross feed
        set(Fuel_tank_selector_eng_1, 4)
    else
        set(Fuel_tank_selector_eng_1, 0)
    end

    -- ENG2 - RIGHT
    set(Fuel_pump_on[tank_RIGHT], 0)
    if eng2_fuel_status == 4 then
        -- Direct feed or gravity feed
        set(Fuel_pump_on[tank_RIGHT], 1)
        set(Fuel_tank_selector_eng_2, 1)
    elseif eng2_fuel_status == 3 then
        -- Cross feed
        set(Fuel_tank_selector_eng_2, 4)
    else
        set(Fuel_tank_selector_eng_2, 0)
    end

end

-- This function tells you if ACT or RCT (and which one) is going to transfer to the CTR tank
-- depending on the fuel quantity. This has been programmed similar to how ACTs logic works
local function next_aux_fuel_tank()
    if fuel_percentage(tank_ACT) > 50 then
        return ACT
    elseif fuel_percentage(tank_RCT) > 75 then
        return RCT
    elseif fuel_percentage(tank_ACT) > 0 then
        return ACT
    elseif fuel_percentage(tank_RCT) > 0 then
        return RCT
    else
        return nil
    end
end

----------------------------------------------------------------------------------------------------
-- Functions - Main
----------------------------------------------------------------------------------------------------

function update()
    update_lights()
    update_pump_dr()
end

