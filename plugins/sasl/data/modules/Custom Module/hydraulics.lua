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
-- File: hydraulics.lua 
-- Short description: Hydraulics Logic file
-------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local G = 1
local B = 2
local Y = 3

local PSI_AVG_ENGINE_PUMP = 3000    -- Average PSI when engine pump is active (normal conditions)
local PSI_AVG_ELEC_PUMP   = 2950    -- Average PSI when electric pump is active (normal conditions)
local PSI_VAR_EE_PUMP     = 50      -- +/- variation PSI when engine or electric pump is active (normal conditions)
local PSI_AVG_PTU_PUMP    = 2600    -- Average PSI when PTU pump is active (sink system)
local PSI_VAR_PTU_PUMP    = 200     -- +/- variation PSI when PTU pump is active (sink system)
local PSI_AVG_RAT_PUMP    = 2500    -- Average PSI when RAT pump is active and speed is good
local PSI_VAR_RAT_PUMP    = 100     -- +/- variation PSI when RAT pump is active and speed is good
local PSI_RAT_MIN_SPD     = 140     -- Minimum speed such that RAT is provided good hyd

local PSI_SPEED           = 350     -- Rate of pressure change (B hyd is 0.7 times this value)

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local g_sys = nil
local b_sys = nil
local y_sys = nil

local last_qty_update = 0
local last_press_target_update = 0

local last_PTU_change_status = 0    -- To save the last time we changed the status of PTU

local lost_elec_rat_time = 0

local status_buttons = {
    eng1pump  = true,
    eng2pump  = true,
    elecBpump = true,
    elecYpump = false,
    PTU       = true,
    overrideBpump = false
}

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (HYD_cmd_Eng1Pump,     0, function(phase) hyd_toggle_button(phase, 1) end )
sasl.registerCommandHandler (HYD_cmd_Eng2Pump,     0, function(phase) hyd_toggle_button(phase, 2) end )
sasl.registerCommandHandler (HYD_cmd_B_ElecPump,   0, function(phase) hyd_toggle_button(phase, 3) end )
sasl.registerCommandHandler (HYD_cmd_Y_ElecPump,   0, function(phase) hyd_toggle_button(phase, 4) end )
sasl.registerCommandHandler (HYD_cmd_PTU,          0, function(phase) hyd_toggle_button(phase, 5) end )
sasl.registerCommandHandler (HYD_cmd_RAT_man_on,   0, function(phase) if phase == SASL_COMMAND_BEGIN and get(HOT_bus_2_pwrd) == 1 then set(is_RAT_out, 1) end end )

sasl.registerCommandHandler (HYD_reset_systems,    0, function(phase) hyd_reset_systems(phase) end )
sasl.registerCommandHandler (MNTN_HYD_BLUE_override, 0, function(phase) hyd_toggle_button(phase, 6) end )
sasl.registerCommandHandler (MNTN_HYD_G_valve,   0, function(phase) if phase == SASL_COMMAND_BEGIN then g_sys.is_valve_on_test = not g_sys.is_valve_on_test end end )
sasl.registerCommandHandler (MNTN_HYD_B_valve,   0, function(phase) if phase == SASL_COMMAND_BEGIN then b_sys.is_valve_on_test = not b_sys.is_valve_on_test end end )
sasl.registerCommandHandler (MNTN_HYD_Y_valve,   0, function(phase) if phase == SASL_COMMAND_BEGIN then y_sys.is_valve_on_test = not y_sys.is_valve_on_test end end )

function hyd_reset_systems(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(FAILURE_HYD_G_leak, 0)
        set(FAILURE_HYD_B_leak, 0)
        set(FAILURE_HYD_Y_leak, 0)

        g_sys.qty_initialized = false
        b_sys.qty_initialized = false
        y_sys.qty_initialized = false
    end
end

function hyd_toggle_button(phase, id)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    if id == 1 then
        status_buttons.eng1pump = not status_buttons.eng1pump
    elseif id == 2 then
        status_buttons.eng2pump = not status_buttons.eng2pump
    elseif id == 3 then
        status_buttons.elecBpump = not status_buttons.elecBpump
    elseif id == 4 then
        status_buttons.elecYpump = not status_buttons.elecYpump
    elseif id == 5 then
        status_buttons.PTU = not status_buttons.PTU
    elseif id == 6 then
        status_buttons.overrideBpump = not status_buttons.overrideBpump
    end
end

local function is_any_cargo_door_operating()
    return (get(Cargo_1_ratio) > 0 and get(Cargo_1_ratio) < 1) or (get(Cargo_2_ratio) > 0 and get(Cargo_2_ratio) < 1) 
end

----------------------------------------------------------------------------------------------------
-- Classes
----------------------------------------------------------------------------------------------------

-- Let's create a class for a generic hyd system
HydSystem = {

    id = 0,

    is_engine_pump_on = false,  -- Is engine pump providing pressure?
    is_elec_pump_on   = false,  -- Is electric pump providing pressure?
    is_ptu_on         = false,  -- *Incoming* PTU
    is_rat_pump_on    = false,  -- Is RAT pump providing pressure?

    is_valve_on_test  = false,  -- Valve is closed because someone pressed the related button in the mntn panel

    press_curr        = 0,
    press_max         = 0,      -- Maximum allowed pressure (used in computation only)
    press_target      = 0,      -- Target pressure, press_curr will reach this pressure at some point in time

    qty_low_limit     = 0,      -- Under this value a caution is triggered
    qty_norm_limit    = 0,      -- Under this value an advisory is triggered
    qty_high_limit    = 0,      -- Under this value normal conditions occur
    qty_curr          = 0,
    
    ptu_is_increasing = true,   -- Internal use, to check if ptu pressure is increasing or descrising, do not set manually
    qty_initialized   = false  -- Internal use, to check if qty has been already initialized
}

-- Constructor for the class
function HydSystem:create (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function HydSystem:update_press()

    if self.id == Y then
        if is_any_cargo_door_operating() then
            -- In this case we must disable the Y system
            self.press_target = 0
            return
        end
        set(Hydraulic_Y_elec_status, self.is_elec_pump_on and 1 or 0)
    end

    if self.is_valve_on_test then
        self.press_target = 0
    elseif self.is_engine_pump_on then
        -- Ok engine pump is ON, this is the best, no matter about the others pumps
        self.press_target = math.random(PSI_AVG_ENGINE_PUMP - PSI_VAR_EE_PUMP, PSI_AVG_ENGINE_PUMP + PSI_VAR_EE_PUMP)
    elseif self.is_elec_pump_on then
        self.press_target = math.random(PSI_AVG_ELEC_PUMP - PSI_VAR_EE_PUMP, PSI_AVG_ELEC_PUMP + PSI_VAR_EE_PUMP)
    elseif self.is_ptu_on then
        -- PTU should oscillate, not just random. So, let's take a random variation number from 10 to 200
        local variation = math.random(50, 400)

        -- If we are in the increasing phase, let's add this number to the current target pressure
        if self.ptu_is_increasing then
            self.press_target = self.press_target + variation
        else    -- otherwise, let's subtract that
            self.press_target = self.press_target - variation        
        end

        -- Pressure target hits the upper limit, let's decrease now
        if self.press_target > PSI_AVG_PTU_PUMP + PSI_VAR_PTU_PUMP then
            self.ptu_is_increasing = false
            self.press_target = PSI_AVG_PTU_PUMP + PSI_VAR_PTU_PUMP
        end

        -- Pressure target hits the lower limit, let's decrease now
        if self.press_target < PSI_AVG_PTU_PUMP - PSI_VAR_PTU_PUMP then
            self.ptu_is_increasing = true
            self.press_target = PSI_AVG_PTU_PUMP - PSI_VAR_PTU_PUMP
        end

    elseif self.is_rat_pump_on then
        if get(IAS) >= 140 then
            self.press_target = math.random(PSI_AVG_RAT_PUMP - PSI_VAR_RAT_PUMP, PSI_AVG_RAT_PUMP + PSI_VAR_RAT_PUMP) 
        elseif get(IAS) < 40 then
            self.press_target = 0
        else
            -- Let's compute a linear regression + noise for the RAT pump under 140 kias
            avg_press = get(IAS)/140 * PSI_AVG_RAT_PUMP
            var_press = get(IAS)/140 * PSI_VAR_RAT_PUMP
            self.press_target = math.random(avg_press - var_press, avg_press + var_press)      
        end
    else
        -- No pressure system
        self.press_target = 0
    end

end

function HydSystem:update_elec()
    -- Source for pwr consumption: https://www.eaton.com/ecm/idcplg?IdcService=GET_FILE&allowInterrupt=1&RevisionSelectionMethod=LatestReleased&noSaveAs=0&Rendition=Primary&dDocName=CT_194574
    if (not self.is_engine_pump_on) and self.is_elec_pump_on then
        if self.id == Y then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 40, 45)
        elseif  self.id == B then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 40, 45)
        end
    end
    if self.is_ptu_on then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0, 1) -- The PTU power consumption is almost null
    end
end

function HydSystem:update_curr_press()

    if self.press_target == self.press_curr then
        return
    end
    
    speed = self.id == B and 0.7*PSI_SPEED or PSI_SPEED  -- Blue is a little slower
    
    self.press_curr = Set_linear_anim_value(self.press_curr, self.press_target, 0, 3500, speed)

end

function HydSystem:update_qty()

    if self.qty_initialized == false then
        self.qty_initialized = true
        self.qty_curr = math.random()*(self.qty_high_limit - self.qty_norm_limit - 0.1) + self.qty_norm_limit +0.1
    end
    
    if self.qty_curr > 0 then   -- LEAK failures
        if self.id == G and get(FAILURE_HYD_G_leak) == 1 then
            self.qty_curr = math.max(0, self.qty_curr - math.random()*0.1)
        end
        if self.id == B and get(FAILURE_HYD_B_leak) == 1 then
            self.qty_curr = math.max(0,self.qty_curr - math.random()*0.1)
        end
        if self.id == Y and get(FAILURE_HYD_Y_leak) == 1 then
            self.qty_curr = math.max(0,self.qty_curr - math.random()*0.1)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

local function init_hyd_systems()
    g_sys = HydSystem:create{id=G, press_max=3200, qty_low_limit=3.5, qty_norm_limit=12.0, qty_high_limit=14.5}
    b_sys = HydSystem:create{id=B, press_max=3200, qty_low_limit=2.4, qty_norm_limit=5.0,  qty_high_limit=6.5}
    y_sys = HydSystem:create{id=Y, press_max=3200, qty_low_limit=3.5, qty_norm_limit=10.0, qty_high_limit=12.5}
end

init_hyd_systems()


local function is_ptu_enabled()

    if not status_buttons.PTU then
        return false
    end

    -- PTU has a complex activation logic:
    local first_and = get(Parkbrake_switch_pos) == 0  and get(Wheel_better_pushback_connected) == 0

    -- Engines Both OFF or both ON
    local engines_both_off_or_on = get(Engine_1_master_switch) + get(Engine_2_master_switch) ~= 1
    local the_or = first_and or engines_both_off_or_on or get(All_on_ground) == 0
    local second_and = the_or and (math.abs(g_sys.press_curr - y_sys.press_curr) > 500 or (g_sys.is_ptu_on and y_sys.press_curr - g_sys.press_curr > 150) or (y_sys.is_ptu_on and g_sys.press_curr - y_sys.press_curr > 150))
    local inibith = (not status_buttons.elecYpump) and is_any_cargo_door_operating()

    return second_and and (not inibith)
end

local function update_sys_status()

    g_sys.is_engine_pump_on = status_buttons.eng1pump and ENG.dyn[1].is_avail and get(FAILURE_HYD_G_pump) == 0 and get(Hydraulic_G_qty) > 0
    y_sys.is_engine_pump_on = status_buttons.eng2pump and ENG.dyn[2].is_avail and get(FAILURE_HYD_Y_pump) == 0 and get(Hydraulic_Y_qty) > 0
    b_sys.is_elec_pump_on = status_buttons.elecBpump and (ENG.dyn[1].is_avail or  ENG.dyn[2].is_avail) and get(FAILURE_HYD_B_pump) == 0 and get(AC_bus_1_pwrd) == 1 and get(Hydraulic_B_qty) > 0
    b_sys.is_elec_pump_on = b_sys.is_elec_pump_on or (get(AC_bus_1_pwrd) == 1 and status_buttons.overrideBpump and get(Hydraulic_B_qty) > 0)
    y_sys.is_elec_pump_on = status_buttons.elecYpump and get(FAILURE_HYD_Y_E_pump) == 0 and get(Hydraulic_Y_qty) > 0 and get(AC_bus_2_pwrd) == 1


    if is_ptu_enabled() and get(FAILURE_HYD_PTU) == 0 and get(DC_bus_2_pwrd) == 1 then
        if y_sys.press_curr - g_sys.press_curr > 500 or (g_sys.is_ptu_on and y_sys.press_curr - g_sys.press_curr > 150) then
            g_sys.is_ptu_on = true  and get(Hydraulic_G_qty) > 0 -- Y is feeding the G system
            y_sys.is_ptu_on = false
        elseif g_sys.press_curr - y_sys.press_curr > 500 or (y_sys.is_ptu_on and g_sys.press_curr - y_sys.press_curr > 150) then
            y_sys.is_ptu_on = true  and get(Hydraulic_Y_qty) > 0 -- G is feeding the Y system
            g_sys.is_ptu_on = false
        else
            g_sys.is_ptu_on = false
            y_sys.is_ptu_on = false
        end
    else
        g_sys.is_ptu_on = false
        y_sys.is_ptu_on = false
    end

    if status_buttons.PTU and get(FAILURE_HYD_PTU) == 0 and get(DC_bus_2_pwrd) == 1 then
        if y_sys.is_ptu_on then
            set(Hydraulic_PTU_status, 3)
        elseif g_sys.is_ptu_on then
            set(Hydraulic_PTU_status, 2)
        else
            set(Hydraulic_PTU_status, 1)
        end
    else
            set(Hydraulic_PTU_status, 0)
    end

    
    if get(is_RAT_out) == 1 then
        b_sys.is_rat_pump_on = get(FAILURE_HYD_RAT) == 0 and get(Hydraulic_B_qty) > 0
    
        if get(FAILURE_HYD_RAT) == 1 or get(Hydraulic_B_qty) == 0 then
            set(Hydraulic_RAT_status, 2)
        elseif get(IAS) < 140 then
            set(Hydraulic_RAT_status, 2)
        else
            set(Hydraulic_RAT_status, 1)
        end
    else
        b_sys.is_rat_pump_on = false
        set(Hydraulic_RAT_status, 0)
    end

end

local function update_rat()
    if get(All_on_ground) == 0 and get(AC_bus_1_pwrd) == 0 and get(AC_bus_2_pwrd) == 0 then
        if lost_elec_rat_time == 0 then
            lost_elec_rat_time = get(TIME)
        end
        if get(TIME) - lost_elec_rat_time > 2 then
            set(is_RAT_out, 1)
        end
    else
        lost_elec_rat_time = 0
    end
end

local function update_datarefs() 

    set(Hydraulic_G_press, g_sys.press_curr)
    set(Hydraulic_B_press, b_sys.press_curr)
    set(Hydraulic_Y_press, y_sys.press_curr)
    
    set(Hydraulic_G_qty, g_sys.qty_curr / g_sys.qty_high_limit)
    set(Hydraulic_B_qty, b_sys.qty_curr / b_sys.qty_high_limit)
    set(Hydraulic_Y_qty, y_sys.qty_curr / y_sys.qty_high_limit)
    
    pb_set(PB.ovhd.hyd_eng1, not status_buttons.eng1pump, get(FAILURE_HYD_G_pump) == 1)
    pb_set(PB.ovhd.hyd_eng2, not status_buttons.eng2pump, get(FAILURE_HYD_Y_pump) == 1)
    pb_set(PB.ovhd.hyd_PTU,  not status_buttons.PTU, get(FAILURE_HYD_PTU) == 1)
    pb_set(PB.ovhd.hyd_elec_B, not status_buttons.elecBpump, get(FAILURE_HYD_B_pump) == 1)
    pb_set(PB.ovhd.hyd_elec_Y, not is_any_cargo_door_operating() and status_buttons.elecYpump, get(FAILURE_HYD_Y_E_pump) == 1)
    pb_set(PB.ovhd.mntn_hyd_blue_on, status_buttons.overrideBpump, false)
    pb_set(PB.ovhd.mntn_hyd_v_G, g_sys.is_valve_on_test, false)
    pb_set(PB.ovhd.mntn_hyd_v_B, b_sys.is_valve_on_test, false)
    pb_set(PB.ovhd.mntn_hyd_v_Y, y_sys.is_valve_on_test, false)
end

function update()
    perf_measure_start("hydraulics:update()")

    local curr_time = get(TIME) * 1000

    update_sys_status()
    update_rat()

    if curr_time - last_press_target_update > 1000 then -- Update the pressure target every 1000ms
        last_press_target_update = curr_time
        
        g_sys:update_press()
        b_sys:update_press()
        y_sys:update_press()
    end

        
    g_sys:update_curr_press()
    b_sys:update_curr_press()
    y_sys:update_curr_press()

    if curr_time - last_qty_update > 100 then -- Update the pressure and qty every 100ms
        last_qty_update = curr_time
        
        g_sys:update_qty()
        b_sys:update_qty()
        y_sys:update_qty()
        
        update_datarefs()
    end

    -- Update power consumption
    b_sys:update_elec()
    y_sys:update_elec()

    perf_measure_stop("hydraulics:update()")
end

function onAirportLoaded()
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        g_sys.press_curr = 2900
        b_sys.press_curr = 2900
        y_sys.press_curr = 2900
    end
end

onAirportLoaded() -- Ensure if sasl has been reboot to check the already running condition

