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

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local tank_pump_xfr_switches = {
    [L_TK_PUMP_1] = { switch = false, status = false },
    [L_TK_PUMP_2] = { switch = false, status = false },
    [R_TK_PUMP_1] = { switch = false, status = false },
    [R_TK_PUMP_2] = { switch = false, status = false },
    [C_TK_XFR_1]  = { switch = false, status = false },
    [C_TK_XFR_2]  = { switch = false, status = false },
    [ACT_TK_XFR]  = { switch = false, status = false },
    [RCT_TK_XFR]  = { switch = false, status = false }
}

local C_tank_mode = false -- false AUTO, true MANUAL
local X_feed_mode = false -- false CLOSED, true OPEN (command, not status)

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
-- Functions
----------------------------------------------------------------------------------------------------

function fuel_toggle_pump_xfr(phase, tank)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    print(tank)
    tank_pump_xfr_switches[tank].switch = not tank_pump_xfr_switches[tank].switch
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


local function update_lights()

    for key,value in ipairs(tank_pump_xfr_switches) do
        dr_write = (value.switch and 0 or 1) + (get(FAILURE_FUEL, key) == 1 and 10 or 0)
        set(Fuel_light_pumps, dr_write, key)
    end

end

function update()
    update_lights()
end

