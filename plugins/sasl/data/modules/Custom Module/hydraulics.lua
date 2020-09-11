----------------------------------------------------------------------------------------------------
-- Hydraulics Logic file

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

local PSI_STEP            = 50      -- Average incremental step for reaching target pressure

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local g_sys = nil
local b_sys = nil
local y_sys = nil

local last_press_update = 0
local last_press_target_update = 0

local last_PTU_change_status = 0    -- To save the last time we changed the status of PTU

local status_buttons = {
    eng1pump  = true,
    eng2pump  = true,
    elecBpump = true,
    elecYpump = false,
    PTU       = true
}

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (HYD_cmd_Eng1Pump,     0, function(phase) hyd_toggle_button(phase, 1) end )
sasl.registerCommandHandler (HYD_cmd_Eng2Pump,     0, function(phase) hyd_toggle_button(phase, 2) end )
sasl.registerCommandHandler (HYD_cmd_B_ElecPump,   0, function(phase) hyd_toggle_button(phase, 3) end )
sasl.registerCommandHandler (HYD_cmd_Y_ElecPump,   0, function(phase) hyd_toggle_button(phase, 4) end )
sasl.registerCommandHandler (HYD_cmd_PTU,          0, function(phase) hyd_toggle_button(phase, 5) end )
sasl.registerCommandHandler (HYD_cmd_RAT_man_on,   0, function(phase) if phase == SASL_COMMAND_BEGIN then set(is_RAT_out, 1) end end )



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
    end
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

    press_curr        = 0,
    press_max         = 0,      -- Maximum allowed pressure (used in computation only)
    press_target      = 0,      -- Target pressure, press_curr will reach this pressure at some point in time

    qty_low_limit     = 0,      -- Under this value a caution is triggered
    qty_norm_limit    = 0,      -- Under this value an advisory is triggered
    qty_high_limit    = 0,      -- Under this value normal conditions occur
    qty_curr          = 0,
    
    is_bleed_ok       = false,  -- Is bleed air provided to the hyd system? (bleed availability + failure)
    is_temperature_ok = false,   -- is the temperature ok? (failure dataref)
    
    ptu_is_increasing = true   -- Internal use, to check if ptu pressure is increasing or descrising, do not set manually
}

-- Constructor for the class
function HydSystem:create (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function HydSystem:update_press()

    if self.is_engine_pump_on then
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

function HydSystem:update_curr_press()

    if self.press_target == self.press_curr then
        return
    end
    
    local var = (self.press_target - self.press_curr) / 10
    if var > 0 and var > PSI_STEP then
        var = PSI_STEP
        var = var + math.random(-5,5)
    elseif var < 0 and var < -PSI_STEP then
        var = -PSI_STEP
        var = var + math.random(-5,5)
    end
    
    self.press_curr = self.press_curr + var

end

function HydSystem:update_qty()

    if self.qty_curr == 0 then
        self.qty_curr = math.random()*(self.qty_high_limit - self.qty_norm_limit) + self.qty_norm_limit
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
    return status_buttons.PTU -- TODO
end

local function update_sys_status()

    -- TODO Add failures + Electrical
    g_sys.is_engine_pump_on = status_buttons.eng1pump
    y_sys.is_engine_pump_on = status_buttons.eng2pump
    b_sys.is_elec_pump_on = status_buttons.elecBpump
    y_sys.is_elec_pump_on = status_buttons.elecYpump


    if is_ptu_enabled() then
        if y_sys.press_curr - g_sys.press_curr > 500 or (g_sys.is_ptu_on and y_sys.press_curr - g_sys.press_curr > 150) then
            g_sys.is_ptu_on = true  -- Y is feeding the G system
            y_sys.is_ptu_on = false
        elseif g_sys.press_curr - y_sys.press_curr > 500 or (y_sys.is_ptu_on and g_sys.press_curr - y_sys.press_curr > 150) then
            y_sys.is_ptu_on = true  -- G is feeding the Y system
            g_sys.is_ptu_on = false
        else
            g_sys.is_ptu_on = false
            y_sys.is_ptu_on = false
        end
    else
        g_sys.is_ptu_on = false
        y_sys.is_ptu_on = false    
    end

    if status_buttons.PTU then  -- TODO Add PTU failure
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
        b_sys.is_rat_pump_on = true
    end

end

local function update_datarefs() 

    set(Hydraulic_G_press, g_sys.press_curr)
    set(Hydraulic_B_press, b_sys.press_curr)
    set(Hydraulic_Y_press, y_sys.press_curr)
    
    set(Hydraulic_G_qty, g_sys.qty_curr / g_sys.qty_high_limit)
    set(Hydraulic_B_qty, b_sys.qty_curr / b_sys.qty_high_limit)
    set(Hydraulic_Y_qty, y_sys.qty_curr / y_sys.qty_high_limit)
    
    -- TODO Add faults to buttons
    set(Hyd_light_Eng1Pump, status_buttons.eng1pump and 0 or 1)
    set(Hyd_light_Eng2Pump, status_buttons.eng2pump and 0 or 1)
    set(Hyd_light_PTU, status_buttons.PTU and 0 or 1)
    set(Hyd_light_B_ElecPump, status_buttons.elecBpump and 0 or 1)
    set(Hyd_light_Y_ElecPump, status_buttons.elecYpump and 1 or 0)
    
end

function update()

    local curr_time = get(TIME) * 1000

    update_sys_status()

    if curr_time - last_press_target_update > 1000 then -- Update the pressure target every 1000ms
        last_press_target_update = curr_time
        
        g_sys:update_press()
        b_sys:update_press()
        y_sys:update_press()
    end

    if curr_time - last_press_update > 100 then -- Update the pressure and qty every 100ms
        last_press_update = curr_time
        
        g_sys:update_curr_press()
        b_sys:update_curr_press()
        y_sys:update_curr_press()
        
        g_sys:update_qty()
        b_sys:update_qty()
        y_sys:update_qty()
        
        update_datarefs()
    end


end


