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

local FUEL_XFR_SPEED = 10

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local tank_pump_and_xfr = {
    [L_TK_PUMP_1] = { switch = false, status = false, has_elec_pwr = false, pressure_ok = false },
    [L_TK_PUMP_2] = { switch = false, status = false, has_elec_pwr = false, pressure_ok = false },
    [R_TK_PUMP_1] = { switch = false, status = false, has_elec_pwr = false, pressure_ok = false },
    [R_TK_PUMP_2] = { switch = false, status = false, has_elec_pwr = false, pressure_ok = false },
    [C_TK_XFR_1]  = { switch = false, status = false, auto_status = false, has_elec_pwr = false, pressure_ok = false },
    [C_TK_XFR_2]  = { switch = false, status = false, auto_status = false, has_elec_pwr = false, pressure_ok = false },
    [ACT_TK_XFR]  = { switch = false, status = false, auto_status = false, has_elec_pwr = false, pressure_ok = false },
    [RCT_TK_XFR]  = { switch = false, status = false, auto_status = false, has_elec_pwr = false, pressure_ok = false }
}

local C_tank_mode   = false -- false AUTO, true MANUAL
local C_tank_fault  = false -- This does not depend on a fault datarefs
local X_feed_mode   = false -- false CLOSED, true OPEN (command, not status)
local X_feed_status = false -- false CLOSED, true OPEN (status, not command)
local X_feed_valve_pos = 0 -- 0 closed, 1 open

local eng1_fuel_status = 0 -- 0 : no fuel, 1 : gravity left, 2 : gravity right, 3 : left, 4 : right (xfeed)
local eng2_fuel_status = 0 -- 0 : no fuel, 1 : gravity left, 2 : gravity right, 3 : left (xfeed), 4 : right

Fuel_sys.tank_pump_and_xfr = tank_pump_and_xfr

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

local function update_single_pump(x)
    if not tank_pump_and_xfr[x].has_elec_pwr then
        set(Fuel_light_pumps, 0, x)
    elseif not tank_pump_and_xfr[x].switch then
        set(Fuel_light_pumps, 1, x)
    elseif get(FAILURE_FUEL, x) == 1 then
        set(Fuel_light_pumps, 10, x)
    else
        set(Fuel_light_pumps, 0, x)
    end
end

local function update_single_extra(x)
    if not tank_pump_and_xfr[x].has_elec_pwr then
        set(Fuel_light_pumps, 0, x)
    else
        set(Fuel_light_pumps, (tank_pump_and_xfr[x].switch and 1 or 0) + (get(FAILURE_FUEL, x) == 1 and 10 or 0), x)
    end
end

local function update_lights()



    -- Fuel fumps illuminated when off
    update_single_pump(L_TK_PUMP_1)
    update_single_pump(L_TK_PUMP_2)
    update_single_pump(R_TK_PUMP_1)
    update_single_pump(R_TK_PUMP_2)
    update_single_pump(C_TK_XFR_1)
    update_single_pump(C_TK_XFR_2)

    update_single_extra(ACT_TK_XFR)
    update_single_extra(RCT_TK_XFR)

    -- X_feed and mode sel
    if get(DC_ess_bus_pwrd) == 1 then
        set(Fuel_light_mode_sel, (C_tank_mode and 1 or 0) + (C_tank_fault and 10 or 0))
        set(Fuel_light_x_feed,   (X_feed_mode and 1 or 0) + (X_feed_status and 10 or 0))
    else
        set(Fuel_light_mode_sel, 0)
        set(Fuel_light_x_feed,   0)    
    end
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
    if eng2_fuel_status == 4 or eng2_fuel_status == 2 then
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


local function update_pumps_elec() 

    -- LEFT

    local pump1_norm = get(Gen_1_line_active) == 0 and get(AC_bus_1_pwrd) == 1 and get(DC_bus_1_pwrd) == 1
    local pump1_gen  = get(Gen_1_line_active) == 1 and get(Gen_1_pwr) == 1 and (get(DC_bus_1_pwrd) == 1 or get(DC_ess_bus_pwrd) == 1)
    
    tank_pump_and_xfr[L_TK_PUMP_1].has_elec_pwr = pump1_norm or pump1_gen
    
    tank_pump_and_xfr[L_TK_PUMP_2].has_elec_pwr = get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1
    
    -- RIGHT
    local pump1_norm = get(Gen_1_line_active) == 0 and get(AC_bus_1_pwrd) == 1 and get(DC_bus_1_pwrd) == 1
    local pump1_gen  = get(Gen_1_line_active) == 1 and get(Gen_1_pwr) == 1 and (get(DC_bus_1_pwrd) == 1 or get(DC_ess_bus_pwrd) == 1)
    
    tank_pump_and_xfr[R_TK_PUMP_1].has_elec_pwr = pump1_norm or pump1_gen
    
    tank_pump_and_xfr[R_TK_PUMP_2].has_elec_pwr = get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1

    -- CENTER
    tank_pump_and_xfr[C_TK_XFR_1].has_elec_pwr = get(AC_bus_1_pwrd) == 1 and get(DC_bus_1_pwrd) == 1
    tank_pump_and_xfr[C_TK_XFR_2].has_elec_pwr = get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1
    
    -- ACT & RCT
    tank_pump_and_xfr[ACT_TK_XFR].has_elec_pwr = get(AC_bus_1_pwrd) == 1 and get(DC_bus_1_pwrd) == 1
    tank_pump_and_xfr[RCT_TK_XFR].has_elec_pwr = get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1    
    
end
local function update_logic_wing_pumps() 

    if tank_pump_and_xfr[L_TK_PUMP_1].switch and tank_pump_and_xfr[L_TK_PUMP_1].has_elec_pwr then
        if get(Gen_1_line_active) == 0 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 7, 8)   
        end
        tank_pump_and_xfr[L_TK_PUMP_1].status = true
    end
    
    if tank_pump_and_xfr[L_TK_PUMP_2].switch and tank_pump_and_xfr[L_TK_PUMP_2].has_elec_pwr then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 7, 8)     
        tank_pump_and_xfr[L_TK_PUMP_2].status = true
    end

    if tank_pump_and_xfr[R_TK_PUMP_1].switch and tank_pump_and_xfr[R_TK_PUMP_1].has_elec_pwr then
        if get(Gen_1_line_active) == 0 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 7, 8)   
        end
        tank_pump_and_xfr[R_TK_PUMP_1].status = true
    end
    
    if tank_pump_and_xfr[R_TK_PUMP_2].switch and tank_pump_and_xfr[R_TK_PUMP_2].has_elec_pwr then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 7, 8)     
        tank_pump_and_xfr[R_TK_PUMP_2].status = true
    end
    
    tank_pump_and_xfr[C_TK_XFR_1].status = tank_pump_and_xfr[C_TK_XFR_1].switch and tank_pump_and_xfr[C_TK_XFR_1].has_elec_pwr
    tank_pump_and_xfr[C_TK_XFR_2].status = tank_pump_and_xfr[C_TK_XFR_2].switch and tank_pump_and_xfr[C_TK_XFR_2].has_elec_pwr


end

function update_engine_fuel_status()
    eng1_fuel_status = 0
    eng2_fuel_status = 0

    if tank_pump_and_xfr[L_TK_PUMP_1].status or tank_pump_and_xfr[L_TK_PUMP_2].status then
        eng1_fuel_status = 3    -- Normal operation, left pumps feed the left engine
    end
    
    if tank_pump_and_xfr[R_TK_PUMP_1].status or tank_pump_and_xfr[R_TK_PUMP_2].status then
        eng2_fuel_status = 4    -- Normal operation, right pumps feed the right engine
    end
    
    if     eng1_fuel_status == 0 and eng2_fuel_status ~= 0 and X_feed_status then
        eng1_fuel_status = 4    -- Crossfeed of left side if right side ok and x bleed open
    elseif eng1_fuel_status ~= 0 and eng2_fuel_status == 0 and X_feed_status then
        eng2_fuel_status = 3    -- Crossfeed of right side if left side ok and x bleed open
    end
    
    -- If not, gravity feed
    if eng1_fuel_status == 0 and get(Total_vertical_g_load) > 0 then
        eng1_fuel_status = 1
    end
    
    if eng2_fuel_status == 0 and get(Total_vertical_g_load) > 0 then
        eng2_fuel_status = 2
    end

end

local function update_x_feed_valve()
    if get(FAILURE_FUEL_X_FEED) == 1 then
        return -- Pump failed or without elec power
    end

    X_feed_valve_pos = Set_linear_anim_value(X_feed_valve_pos, X_feed_mode and 1 or 0, 0, 1, 0.7)
    
    if X_feed_valve_pos > 0.9 then
        X_feed_status = true
    else
        X_feed_status = false    
    end
end

local function update_pumps_status()
    tank_pump_and_xfr[L_TK_PUMP_1].pressure_ok =  tank_pump_and_xfr[L_TK_PUMP_1].status and get(Fuel_quantity[tank_LEFT]) > 100
    tank_pump_and_xfr[L_TK_PUMP_2].pressure_ok =  tank_pump_and_xfr[L_TK_PUMP_2].status and get(Fuel_quantity[tank_LEFT]) > 100
    tank_pump_and_xfr[R_TK_PUMP_1].pressure_ok =  tank_pump_and_xfr[R_TK_PUMP_1].status and get(Fuel_quantity[tank_RIGHT]) > 100
    tank_pump_and_xfr[R_TK_PUMP_2].pressure_ok =  tank_pump_and_xfr[R_TK_PUMP_2].status and get(Fuel_quantity[tank_RIGHT]) > 100

    tank_pump_and_xfr[C_TK_XFR_1].pressure_ok =  tank_pump_and_xfr[C_TK_XFR_1].status and get(Fuel_quantity[tank_CENTER]) > 0
    tank_pump_and_xfr[C_TK_XFR_2].pressure_ok =  tank_pump_and_xfr[C_TK_XFR_2].status and get(Fuel_quantity[tank_CENTER]) > 0
    if not C_tank_mode then
        tank_pump_and_xfr[C_TK_XFR_1].pressure_ok = tank_pump_and_xfr[C_TK_XFR_1].pressure_ok and tank_pump_and_xfr[C_TK_XFR_1].auto_status
        tank_pump_and_xfr[C_TK_XFR_2].pressure_ok = tank_pump_and_xfr[C_TK_XFR_2].pressure_ok and tank_pump_and_xfr[C_TK_XFR_2].auto_status 
    end
end

local function update_center_tank_pumps_auto()

    if get(Fuel_quantity[tank_CENTER]) == 0 then
        tank_pump_and_xfr[C_TK_XFR_1].auto_status = false
        tank_pump_and_xfr[C_TK_XFR_2].auto_status = false
        return  -- No fuel to transfer
    end

    -- TODO Airbone logic

    -- Center pumps work as follows:
    -- - Start when the wing tank below 250 for the full
    -- - Stop when the wing tank is full    
    if tank_pump_and_xfr[C_TK_XFR_1].auto_status then
        if (FUEL_LR_MAX - 1) <= get(Fuel_quantity[tank_LEFT]) then
            tank_pump_and_xfr[C_TK_XFR_1].auto_status = false
        end
    else
        if FUEL_LR_MAX - get(Fuel_quantity[tank_LEFT]) > 250 then
            tank_pump_and_xfr[C_TK_XFR_1].auto_status = true
        end    
    end
    
    if tank_pump_and_xfr[C_TK_XFR_2].auto_status then
        if (FUEL_LR_MAX - 1) <= get(Fuel_quantity[tank_RIGHT]) then
            tank_pump_and_xfr[C_TK_XFR_2].auto_status = false
        end
    else
        if FUEL_LR_MAX - get(Fuel_quantity[tank_RIGHT]) > 250 then
            tank_pump_and_xfr[C_TK_XFR_2].auto_status = true
        end
    end

end

local function update_transfer_fuel()

    if tank_pump_and_xfr[C_TK_XFR_1].pressure_ok then
        local C_tank = get(Fuel_quantity[tank_CENTER])
        local W_tank = get(Fuel_quantity[tank_LEFT])
        
        local unit_transfer = math.min(get(DELTA_TIME) * FUEL_XFR_SPEED, C_tank)
        C_tank = C_tank - unit_transfer
        W_tank = math.min(W_tank + unit_transfer, FUEL_LR_MAX)  -- Overflow protection
        set(Fuel_quantity[tank_CENTER], C_tank)
        set(Fuel_quantity[tank_LEFT], W_tank)
        
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 7, 8)
    end

    if tank_pump_and_xfr[C_TK_XFR_2].pressure_ok then
        local C_tank = get(Fuel_quantity[tank_CENTER])
        local W_tank = get(Fuel_quantity[tank_RIGHT])
        
        local unit_transfer = math.min(get(DELTA_TIME) * FUEL_XFR_SPEED, C_tank)
        C_tank = C_tank - unit_transfer
        W_tank = math.min(W_tank + unit_transfer, FUEL_LR_MAX)  -- Overflow protection
        set(Fuel_quantity[tank_CENTER], C_tank)
        set(Fuel_quantity[tank_RIGHT], W_tank)

        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 7, 8)
    end

end

----------------------------------------------------------------------------------------------------
-- Functions - Main
----------------------------------------------------------------------------------------------------

function update()
    update_pumps_elec()
    update_logic_wing_pumps()
    update_x_feed_valve()
    update_center_tank_pumps_auto()
    update_pumps_status()

    update_engine_fuel_status()
    update_transfer_fuel()

    update_lights()
    update_pump_dr()
end

