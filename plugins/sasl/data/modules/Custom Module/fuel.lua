----------------------------------------------------------------------------------------------------
-- Fuel system Logic file
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')


-- Tanks
local tank_LEFT  = 1
local tank_RIGHT = 2
local tank_CENTER= 0
local tank_ACT   = 3
local tank_RCT   = 4

local FUEL_XFR_SPEED = 10
local FUEL_LEAK_SPEED = 1

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

-- Legend:
-- - switch: position of the overhead panel switch
-- - status: true if the pump CAN run, false otherwise
-- - auto_status: true if the auto-system asked the pump to run
-- - has_elec_pwr: is the pump electrically powered?
-- - pressure_ok: is the pump actually delivering/transferring fuel?

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

local eng_1_fw_valve_position = 0   -- Firewall valve position (used internally, use the dataref for external use)
local eng_2_fw_valve_position = 0   -- Firewall valve position (used internally, use the dataref for external use)

-- Initially, the temperature of the fuel corresponds to the external one
set(Fuel_wing_L_temp, get(TAT))
set(Fuel_wing_R_temp, get(TAT))
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

sasl.registerCommandHandler (FUEL_cmd_internal_qs,    0, function(phase) fuel_quick_start(phase) end )

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

function fuel_quick_start(phase)
    if phase == SASL_COMMAND_BEGIN then
        tank_pump_and_xfr[L_TK_PUMP_1].switch = true
        tank_pump_and_xfr[L_TK_PUMP_2].switch = true
        tank_pump_and_xfr[R_TK_PUMP_1].switch = true
        tank_pump_and_xfr[R_TK_PUMP_2].switch = true
        tank_pump_and_xfr[C_TK_XFR_1].switch = true
        tank_pump_and_xfr[C_TK_XFR_2].switch = true
        tank_pump_and_xfr[ACT_TK_XFR].switch = false
        tank_pump_and_xfr[RCT_TK_XFR].switch = false
        C_tank_mode   = false
        X_feed_mode   = false
    end
end

function onAirportLoaded()
    -- When the aircraft is loaded in flight, let's switch on all the pumps
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        fuel_quick_start(SASL_COMMAND_BEGIN)
    end
end


----------------------------------------------------------------------------------------------------
-- Functions - Button light updates
----------------------------------------------------------------------------------------------------

-- This function updates the button lights related to LEFT and RIGHT pumps
local function update_single_pump_LR(x)
    -- Note: FAULT + [OFF] can't occur with this button

    if not tank_pump_and_xfr[x].has_elec_pwr then
        set(Fuel_light_pumps, 0, x) -- No light
    elseif not tank_pump_and_xfr[x].switch then
        set(Fuel_light_pumps, 1, x) -- [OFF]
    elseif not tank_pump_and_xfr[x].pressure_ok then
        set(Fuel_light_pumps, 10, x) -- Fault
    else
        set(Fuel_light_pumps, 0, x) -- No light
    end
end

-- This function updates the button lights related to CENTER pumps
local function update_single_pump_C(x)
    -- Note: FAULT + [OFF] can't occur with this button

    if not tank_pump_and_xfr[x].has_elec_pwr then
        set(Fuel_light_pumps, 0, x) -- No light
    elseif not tank_pump_and_xfr[x].switch then
        set(Fuel_light_pumps, 1, x) -- [OFF]
    elseif not tank_pump_and_xfr[x].status then
        set(Fuel_light_pumps, 10, x) -- Fault
    else
        set(Fuel_light_pumps, 0, x)  -- No light
    end
end

-- This function updates the button lights related to ACT and RCT pumps
local function update_single_extra(x)
    set(Fuel_light_pumps, (tank_pump_and_xfr[x].switch and 1 or 0) + (tank_pump_and_xfr[x].pressure_ok and 0 or 10), x)
end

local function update_lights()

    C_tank_fault = get(Fuel_quantity[tank_CENTER]) > 250 and (get(Fuel_quantity[tank_RIGHT]) < 5000 or get(Fuel_quantity[tank_LEFT]) < 5000)

    -- Fuel fumps illuminated when off
    update_single_pump_LR(L_TK_PUMP_1)
    update_single_pump_LR(L_TK_PUMP_2)
    update_single_pump_LR(R_TK_PUMP_1)
    update_single_pump_LR(R_TK_PUMP_2)
    update_single_pump_C(C_TK_XFR_1)
    update_single_pump_C(C_TK_XFR_2)

    -- ACT and RCT illuminated when ON!
    update_single_extra(ACT_TK_XFR)
    update_single_extra(RCT_TK_XFR)

    -- X_feed and mode sel
    if get(DC_ess_bus_pwrd) == 1 then
        -- The lights are on only if DC ESS is on
        set(Fuel_light_mode_sel, (C_tank_mode and 1 or 0) + (C_tank_fault and 10 or 0))
        set(Fuel_light_x_feed,   (X_feed_mode and 1 or 0) + (X_feed_status and 10 or 0))
    else
        set(Fuel_light_mode_sel, 0)
        set(Fuel_light_x_feed,   0)    
    end
end

----------------------------------------------------------------------------------------------------
-- Functions - X-Plane dataref
----------------------------------------------------------------------------------------------------

local function update_pump_dr()
    set(Fuel_pump_on[tank_CENTER], 0) -- It should never be turned on because it does't feed engine
    set(Fuel_pump_on[tank_ACT],    0) -- It should never be turned on because it does't feed engine
    set(Fuel_pump_on[tank_RCT],    0) -- It should never be turned on because it does't feed engine

    -- This function is a trick to map our logic on the X-Plane logic.
    -- Only L1, L2, R1, R2 can feed the engines
    -- X-Plane doesn't distinguish among L1 and L2 (or among R1 an R2), so from the standpoint of
    -- X-Plane we have only 1 pump per tank.

    -- ENG1 - LEFT
    set(Fuel_pump_on[tank_LEFT], 0)
    if eng1_fuel_status == 3 or eng1_fuel_status == 1 then
        -- Direct feed or gravity feed
        set(Fuel_pump_on[tank_LEFT], 1)
        set(Fuel_tank_selector_eng_1, 1)    -- This tells X-Plane to take fuel from the LEFT side
    elseif eng1_fuel_status == 4 then
        -- Cross feed
        set(Fuel_tank_selector_eng_1, 4)    -- This tells X-Plane to take fuel from the ALL (RIGHT) side
    else
        set(Fuel_tank_selector_eng_1, 0)    -- Ops, no fuel
    end

    -- ENG2 - RIGHT
    set(Fuel_pump_on[tank_RIGHT], 0)
    if eng2_fuel_status == 4 or eng2_fuel_status == 2 then
        -- Direct feed or gravity feed
        set(Fuel_pump_on[tank_RIGHT], 1)
        set(Fuel_tank_selector_eng_2, 3)    -- This tells X-Plane to take fuel from the RIGHT side
    elseif eng2_fuel_status == 3 then
        -- Cross feed
        set(Fuel_tank_selector_eng_2, 4)    -- This tells X-Plane to take fuel from the ALL (LEFT) side
    else
        set(Fuel_tank_selector_eng_2, 0)
    end
    
end

----------------------------------------------------------------------------------------------------
-- Functions - Logic
----------------------------------------------------------------------------------------------------

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
local function update_logic_pumps() 

    if tank_pump_and_xfr[L_TK_PUMP_1].switch and tank_pump_and_xfr[L_TK_PUMP_1].has_elec_pwr and get(FAILURE_FUEL, L_TK_PUMP_1) == 0 then
        if get(Gen_1_line_active) == 0 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 7, 8)   
        end
        tank_pump_and_xfr[L_TK_PUMP_1].status = true
    else
        tank_pump_and_xfr[L_TK_PUMP_1].status = false
    end
    
    if tank_pump_and_xfr[L_TK_PUMP_2].switch and tank_pump_and_xfr[L_TK_PUMP_2].has_elec_pwr and get(FAILURE_FUEL, L_TK_PUMP_2) == 0 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 7, 8)
        tank_pump_and_xfr[L_TK_PUMP_2].status = true
    else
        tank_pump_and_xfr[L_TK_PUMP_2].status = false    
    end

    if tank_pump_and_xfr[R_TK_PUMP_1].switch and tank_pump_and_xfr[R_TK_PUMP_1].has_elec_pwr and get(FAILURE_FUEL, R_TK_PUMP_1) == 0 then
        if get(Gen_1_line_active) == 0 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 7, 8)   
        end
        tank_pump_and_xfr[R_TK_PUMP_1].status = true
    else
        tank_pump_and_xfr[R_TK_PUMP_1].status = false    
    end
    
    if tank_pump_and_xfr[R_TK_PUMP_2].switch and tank_pump_and_xfr[R_TK_PUMP_2].has_elec_pwr and get(FAILURE_FUEL, R_TK_PUMP_2) == 0 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 7, 8)     
        tank_pump_and_xfr[R_TK_PUMP_2].status = true
    else
        tank_pump_and_xfr[R_TK_PUMP_2].status = false
    end
    
    tank_pump_and_xfr[C_TK_XFR_1].status = tank_pump_and_xfr[C_TK_XFR_1].switch and tank_pump_and_xfr[C_TK_XFR_1].has_elec_pwr and get(FAILURE_FUEL, C_TK_XFR_1) == 0
    tank_pump_and_xfr[C_TK_XFR_2].status = tank_pump_and_xfr[C_TK_XFR_2].switch and tank_pump_and_xfr[C_TK_XFR_2].has_elec_pwr and get(FAILURE_FUEL, C_TK_XFR_2) == 0

    tank_pump_and_xfr[ACT_TK_XFR].status = (get(L_bleed_press) > 1 or tank_pump_and_xfr[ACT_TK_XFR].has_elec_pwr) and get(FAILURE_FUEL, ACT_TK_XFR) == 0
    tank_pump_and_xfr[RCT_TK_XFR].status = (get(R_bleed_press) > 1 or tank_pump_and_xfr[RCT_TK_XFR].has_elec_pwr) and get(FAILURE_FUEL, RCT_TK_XFR) == 0

end

function update_engine_fuel_status()
    eng1_fuel_status = 0
    eng2_fuel_status = 0

    if tank_pump_and_xfr[L_TK_PUMP_1].pressure_ok or tank_pump_and_xfr[L_TK_PUMP_2].pressure_ok then
        eng1_fuel_status = 3    -- Normal operation, left pumps feed the left engine
    end
    
    if tank_pump_and_xfr[R_TK_PUMP_1].pressure_ok or tank_pump_and_xfr[R_TK_PUMP_2].pressure_ok then
        eng2_fuel_status = 4    -- Normal operation, right pumps feed the right engine
    end
    
    if     eng1_fuel_status == 0 and eng2_fuel_status ~= 0 and X_feed_status then
        eng1_fuel_status = 4    -- Crossfeed of left side if right side ok and x bleed open
    elseif eng1_fuel_status ~= 0 and eng2_fuel_status == 0 and X_feed_status then
        eng2_fuel_status = 3    -- Crossfeed of right side if left side ok and x bleed open
    end
    
    -- If not, gravity feed
    if eng1_fuel_status == 0 and get(Total_vertical_g_load) > 0 and get(Fuel_quantity[tank_LEFT]) > 0 then
        eng1_fuel_status = 1
    end
    
    if eng2_fuel_status == 0 and get(Total_vertical_g_load) > 0 and get(Fuel_quantity[tank_RIGHT]) > 0 then
        eng2_fuel_status = 2
    end

end

local function update_x_feed_valve()
    if get(FAILURE_FUEL_X_FEED) == 1 then
        if X_feed_status ~= X_feed_mode then
            set(Ecam_fuel_valve_X_BLEED, 4)
        elseif X_feed_status then
            set(Ecam_fuel_valve_X_BLEED, 1)
        else
            set(Ecam_fuel_valve_X_BLEED, 3)
        end
        return -- Valve failed or without elec power
    end

    X_feed_valve_pos = Set_linear_anim_value(X_feed_valve_pos, X_feed_mode and 1 or 0, 0, 1, 0.7)
    
    if X_feed_valve_pos > 0.9 then
        X_feed_status = true
        set(Ecam_fuel_valve_X_BLEED, 0)
    else
        X_feed_status = false
        if X_feed_valve_pos < 0.1 then
            set(Ecam_fuel_valve_X_BLEED, 2)
        else
            set(Ecam_fuel_valve_X_BLEED, 4)        
        end
    end
end

local function update_pumps_status()
    tank_pump_and_xfr[L_TK_PUMP_1].pressure_ok = tank_pump_and_xfr[L_TK_PUMP_1].status and get(Fuel_quantity[tank_LEFT]) > 100
    tank_pump_and_xfr[L_TK_PUMP_2].pressure_ok = tank_pump_and_xfr[L_TK_PUMP_2].status and get(Fuel_quantity[tank_LEFT]) > 100
    tank_pump_and_xfr[R_TK_PUMP_1].pressure_ok = tank_pump_and_xfr[R_TK_PUMP_1].status and get(Fuel_quantity[tank_RIGHT]) > 100
    tank_pump_and_xfr[R_TK_PUMP_2].pressure_ok = tank_pump_and_xfr[R_TK_PUMP_2].status and get(Fuel_quantity[tank_RIGHT]) > 100

    tank_pump_and_xfr[C_TK_XFR_1].pressure_ok =  tank_pump_and_xfr[C_TK_XFR_1].status and get(Fuel_quantity[tank_CENTER]) > 0
    tank_pump_and_xfr[C_TK_XFR_2].pressure_ok =  tank_pump_and_xfr[C_TK_XFR_2].status and get(Fuel_quantity[tank_CENTER]) > 0
    if not C_tank_mode then -- If the CTR tank is in auto mode
        -- The tank is activated only if auto_status is requiring that
        tank_pump_and_xfr[C_TK_XFR_1].pressure_ok = tank_pump_and_xfr[C_TK_XFR_1].pressure_ok and tank_pump_and_xfr[C_TK_XFR_1].auto_status
        tank_pump_and_xfr[C_TK_XFR_2].pressure_ok = tank_pump_and_xfr[C_TK_XFR_2].pressure_ok and tank_pump_and_xfr[C_TK_XFR_2].auto_status 
    end
    
    tank_pump_and_xfr[ACT_TK_XFR].pressure_ok = tank_pump_and_xfr[ACT_TK_XFR].status and get(Fuel_quantity[tank_ACT]) > 0
    tank_pump_and_xfr[RCT_TK_XFR].pressure_ok = tank_pump_and_xfr[RCT_TK_XFR].status and get(Fuel_quantity[tank_RCT]) > 0
    tank_pump_and_xfr[ACT_TK_XFR].pressure_ok = tank_pump_and_xfr[ACT_TK_XFR].pressure_ok and (tank_pump_and_xfr[ACT_TK_XFR].auto_status or tank_pump_and_xfr[ACT_TK_XFR].switch)
    tank_pump_and_xfr[RCT_TK_XFR].pressure_ok = tank_pump_and_xfr[RCT_TK_XFR].pressure_ok and (tank_pump_and_xfr[RCT_TK_XFR].auto_status or tank_pump_and_xfr[RCT_TK_XFR].switch)

end

local function update_center_tank_pumps_auto()

    if get(Fuel_quantity[tank_CENTER]) == 0 then
        tank_pump_and_xfr[C_TK_XFR_1].auto_status = false
        tank_pump_and_xfr[C_TK_XFR_2].auto_status = false
        return  -- No fuel to transfer
    end
    
    if get(Flaps_internal_config) >= 1 then
        return  -- No transfer from CTR to Wings when slats extended
    end
    
    if get(EWD_flight_phase) < PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF then
        return -- No fuel transfer when on groudn and engines are off (transfer in these phases
               -- should not happen in any case if the aircraft is correctly refueled)
    end

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


-- This function tells you if ACT or RCT (and which one) is going to transfer to the CTR tank
-- depending on the fuel quantity. This has been programmed similar to how ACTs logic works
local function next_aux_fuel_tank()
    act_percentage = get(Fuel_quantity[tank_ACT]) / FUEL_ACT_MAX
    rct_percentage = get(Fuel_quantity[tank_RCT]) / FUEL_RCT_MAX

    if act_percentage > 0.5 then
        return ACT_TK_XFR
    elseif rct_percentage > 0.75 then
        return RCT_TK_XFR
    elseif act_percentage > 0 then
        return ACT_TK_XFR
    elseif rct_percentage > 0 then
        return RCT_TK_XFR
    else
        return 0
    end
end

local function update_act_rct_tank_pumps_auto()
    tank_pump_and_xfr[ACT_TK_XFR].auto_status = false
    tank_pump_and_xfr[RCT_TK_XFR].auto_status = false

    if get(Flaps_internal_config) >= 1 then
        return  -- No transfer from ACT/RCT to CTR when slats extended
    end
    
    if get(EWD_flight_phase) < PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF then
        return -- No fuel transfer when on groudn and engines are off (transfer in these phases
               -- should not happen in any case if the aircraft is correctly refueled)
    end

    local next_tank = next_aux_fuel_tank()
    if next_tank == 0 then
        return -- No fuel in ACT nor in RCT
    end

    -- ACT/RCT pumps work as follows:
    -- - Start when the center tank quantity is below 5 000 kg
    -- - Stop when the center tank quantity reaches 5 750 kg
    if tank_pump_and_xfr[next_tank].auto_status then
        if get(Fuel_quantity[tank_CENTER]) >= 5750 then
            tank_pump_and_xfr[next_tank].auto_status = false
        end
    else
        if get(Fuel_quantity[tank_CENTER]) < 5000 then
            tank_pump_and_xfr[next_tank].auto_status = true
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

        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 5, 6)
    end
    
    if tank_pump_and_xfr[ACT_TK_XFR].pressure_ok then
        local ACT_tank = get(Fuel_quantity[tank_ACT])
        local C_tank = get(Fuel_quantity[tank_CENTER])
        
        local unit_transfer = math.min(get(DELTA_TIME) * FUEL_XFR_SPEED, ACT_tank)
        ACT_tank = ACT_tank - unit_transfer
        C_tank = math.min(C_tank + unit_transfer, FUEL_C_MAX)  -- Overflow protection
        set(Fuel_quantity[tank_ACT], ACT_tank)
        set(Fuel_quantity[tank_CENTER], C_tank)

        if get(L_bleed_press) < 1 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 5, 6)
        end
    end
    
    if tank_pump_and_xfr[RCT_TK_XFR].pressure_ok then
        local RCT_tank = get(Fuel_quantity[tank_RCT])
        local C_tank = get(Fuel_quantity[tank_CENTER])
        
        local unit_transfer = math.min(get(DELTA_TIME) * FUEL_XFR_SPEED, RCT_tank)
        RCT_tank = RCT_tank - unit_transfer
        C_tank = math.min(C_tank + unit_transfer, FUEL_C_MAX)  -- Overflow protection
        set(Fuel_quantity[tank_RCT], RCT_tank)
        set(Fuel_quantity[tank_CENTER], C_tank)

        if get(R_bleed_press) < 1 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 5, 6)
        end
    end
    

end

-- Update fuel temperature datarefs
local function update_temps()

    -- Temperature of the tank fuel depends on the external temperature on the slat edge.
    -- The temperature of the fuel changes faster if the tank is near empty, while it takes
    -- a lot of time to change the fuel temperature if the tank is full.

    local speed_increase_L = (1.0 - get(Fuel_quantity[tank_LEFT])/FUEL_LR_MAX)*0.25
    local speed_increase_R = (1.0 - get(Fuel_quantity[tank_RIGHT])/FUEL_LR_MAX)*0.25
    Set_dataref_linear_anim(Fuel_wing_L_temp, get(TAT), -50, 50, 0.1 + speed_increase_L )
    Set_dataref_linear_anim(Fuel_wing_R_temp, get(TAT), -50, 50, 0.1 + speed_increase_R )
end

-- Update fuel usage datarefs for using in ECAM
local function update_fuel_usage()
    
    if get(EWD_flight_phase) == PHASE_2ND_ENG_OFF then
        -- The counter is reset during the last phase of flight
        set(Ecam_fuel_usage_1, 0)
        set(Ecam_fuel_usage_2, 0)
        return
    end
    
    local prev_eng1 = get(Ecam_fuel_usage_1)
    local prev_eng2 = get(Ecam_fuel_usage_2)
    local curr_flow_per_sec_1 = get(Eng_1_FF_kgs)
    local curr_flow_per_sec_2 = get(Eng_2_FF_kgs)

    set(Ecam_fuel_usage_1, prev_eng1 + curr_flow_per_sec_1 * get(DELTA_TIME))
    set(Ecam_fuel_usage_2, prev_eng2 + curr_flow_per_sec_2 * get(DELTA_TIME))
    
end

-- Helper function to move apu fuel valve
local function set_apu_fuel_valve(is_open)
    if get(FAILURE_FUEL_APU_VALVE_STUCK) == 0 then
        set(Apu_fuel_valve, is_open and 1 or 0)
    end
end

-- Update the APU valve status
local function update_apu()

    if get(Apu_master_button_state) % 2 == 0 then
        -- APU master switch button is off
        set(Apu_fuel_source, 0)
        set_apu_fuel_valve(false)
        return
    end

    set_apu_fuel_valve(true)
    
    -- APU cannot work by gravity, need fuel pressure or the APU pump
    -- APU is connected to ENG1 line, so we can exploit the previous variable to know the status    

    if eng1_fuel_status == 3 then   -- Ok normal, left side
        set(Apu_fuel_source, 1)
    elseif eng1_fuel_status == 4 then   -- Ok crossfeed, from right side
        set(Apu_fuel_source, 2)
    elseif eng1_fuel_status == 1 and get(FAILURE_FUEL_APU_PUMP_FAIL) == 0 then   -- Mh, only if the apu pump is ok
        set(Apu_fuel_source, 1)
        if get(AC_ess_shed_pwrd) == 1 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS_SHED, 2, 3)
        elseif get(AC_STAT_INV_pwrd) == 1 then
            ELEC_sys.add_power_consumption(ELEC_BUS_STAT_INV, 2, 3)
        else
            set(Apu_fuel_source, 0)
            -- TODO
            --assert(false)   -- This should not happen: the APU must be flagged as failed if we are in this condition.
        end
    end
    

end

local function update_eng_1_valve()
    if get(FAILURE_FUEL_ENG1_VALVE_STUCK) == 1 then
        return -- Valve stuck, cannot change position
    end
    
    if get(Engine_1_master_switch) == 1 and get(Fire_pb_ENG1_status) == 0 then
        eng_1_fw_valve_position = Set_linear_anim_value(eng_1_fw_valve_position, 1, 0, 1, 0.9)
    end
    
    if get(Engine_1_master_switch) == 0 or get(Fire_pb_ENG1_status) == 1 then
        eng_1_fw_valve_position = Set_linear_anim_value(eng_1_fw_valve_position, 0, 0, 1, 0.9)
    end

    set(Eng_1_Firewall_valve, eng_1_fw_valve_position == 1 and 0 or (eng_1_fw_valve_position == 0 and 1 or 2))
end

local function update_eng_2_valve()
    if get(FAILURE_FUEL_ENG2_VALVE_STUCK) == 1 then
        return -- Valve stuck, cannot change position
    end
    
    if get(Engine_2_master_switch) == 1 and get(Fire_pb_ENG2_status) == 0 then
        eng_2_fw_valve_position = Set_linear_anim_value(eng_2_fw_valve_position, 1, 0, 1, 0.95)
    end
    
    if get(Engine_2_master_switch) == 0 or get(Fire_pb_ENG2_status) == 1 then
        eng_2_fw_valve_position = Set_linear_anim_value(eng_2_fw_valve_position, 0, 0, 1, 0.95)
    end

    set(Eng_2_Firewall_valve, eng_2_fw_valve_position == 1 and 0 or (eng_2_fw_valve_position == 0 and 1 or 2))
end

local function update_fuel_leaks()
    for i=1,5 do
        if get(FAILURE_FUEL_LEAK, i) == 1 then
            local leak_compute = get(DELTA_TIME) * FUEL_LEAK_SPEED
            set(Fuel_quantity[i-1], math.max(0, get(Fuel_quantity[i-1]) - leak_compute))
        end
    end

end

----------------------------------------------------------------------------------------------------
-- Functions - Main
----------------------------------------------------------------------------------------------------

function update()

    -- Step 1 : update the pump statuses
    update_pumps_elec()
    update_logic_pumps()
    update_x_feed_valve()
    update_center_tank_pumps_auto()
    update_act_rct_tank_pumps_auto()
    update_pumps_status()

    -- Step 2 : deliver or transfer fuel
    update_engine_fuel_status()
    update_transfer_fuel()

    -- Step 3 : dataref updates
    update_lights()
    update_pump_dr()

    -- Step 4 : misc stuffs to update    
    update_temps()
    update_fuel_usage()
    update_apu()
    update_eng_1_valve()
    update_eng_2_valve()

    -- Step 5 : bad things
    update_fuel_leaks()
end

