----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local BAT_LOW_VOLTAGE_LIMIT = 21   -- Under this value the battery does not provide any power
local BAT_LOW_VOLTAGE_DISC  = 24   -- Under this value the battery contactors open if on ground
local BAT_TOP_VOLTAGE_LIMIT = 28.5 -- Battery when it's fully charged (it won't be charged more than this value)
local BAT_CHARGE_TRIG_AT    = 26.5 -- Charging starts when battery below this voltage
local BAT_RATED_VOLTAGE     = 24   -- Nominal battery voltage
local BAT_CAPACITY_AMPH     = 23
local BAT_LOSS_AMPS         = 0.05  -- Any battery loss some amps and discharge slooooowly
local BAT_CHARGING_CURRENT  = BAT_CAPACITY_AMPH / 5

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
batteries = {
    {
        switch_status = false, 
        curr_voltage = 0,
        curr_amps    = 0,                                          -- + Recharching - Discharging
        curr_charge  = BAT_CAPACITY_AMPH-math.random(0,10)/10,       -- In Ah (start fully charged, with a bit of noise)
        is_charging  = false,
        is_connected_to_dc_bus = false,
        drs = {
            hotbus       = HOT_bus_1_pwrd,
            failure      = FAILURE_ELEC_battery_1,
            voltage      = Elec_bat_1_V, 
            switch_light = Elec_light_battery_1
        }
    },
    {
        switch_status = false, 
        curr_voltage = 0,
        curr_amps    = 0,                                          -- + Recharching - Discharging
        curr_charge  = BAT_CAPACITY_AMPH-math.random(0,10)/10,       -- In Ah (start fully charged, with a bit of noise)
        is_charging  = false,
        is_connected_to_dc_bus = false,
        drs = {
            hotbus = HOT_bus_2_pwrd,
            failure = FAILURE_ELEC_battery_2,
            voltage = Elec_bat_2_V,
            switch_light = Elec_light_battery_2
        }
    }
}

local function update_battery_voltage(bat)

    if bat.is_charging and bat.curr_amps < 0 then
        bat.curr_amps = 0   -- This should not happen
    end
    if not bat.is_charging and bat.curr_amps > 0 then
        bat.curr_amps = 0   -- This should not happen
    end

    bat.curr_amps = bat.curr_amps - BAT_LOSS_AMPS

    bat.curr_charge = bat.curr_charge + bat.curr_amps * get(DELTA_TIME) / 3600
    
    -- Let's compute the voltage now    -- TODO Voltage is non-linear actually...
    bat.curr_voltage = math.max(0, BAT_TOP_VOLTAGE_LIMIT * (bat.curr_charge/BAT_CAPACITY_AMPH))
    
end

local function update_battery_buses(bat)

    bat.is_connected_to_dc_bus = false
    bat.is_charging  = false

    if not bat.switch_status or get(bat.drs.failure) == 1 then -- Battery switch is off or battery failed
        return
    end

    -- Connect battery to start the APU
    if get(Apu_master_button_state) == 1 and get(Apu_N1) < 95 then
        bat.is_connected_to_dc_bus = true
    end

    -- Battery recharging
    if get(DC_bat_bus_pwrd) == 1 and bat.curr_voltage < BAT_CHARGE_TRIG_AT then
        if get(All_on_ground) == 1 then
            bat.is_connected_to_dc_bus = true
            bat.is_charging  = true
        else
            -- TODO Start recharging after 30 minutes not immediately
            bat.is_connected_to_dc_bus = true
            bat.is_charging  = true
        end
    end
    
    if get(AC_bus_1_pwrd) == 0 and get(AC_bus_1_pwrd) == 0 and get(Gen_EMER_pwr) == 0 then
        -- DUAL BUS Failure + EMER GEN failure
        bat.is_connected_to_dc_bus = true
    end
end

local function update_battery_datarefs(bat)
    -- Check if there is sufficient voltage to power HOT bus
    set(bat.drs.hotbus, bat.curr_voltage > BAT_LOW_VOLTAGE_LIMIT and 1 or 0)
    
    set(bat.drs.voltage, bat.curr_voltage)
    set(bat.drs.switch_light, bat.switch_status and 0 or 1)
end

function update_batteries()

    batteries[1].switch_status = get(XP_Battery_1) == 1
    batteries[2].switch_status = get(XP_Battery_2) == 1

    update_battery_voltage(batteries[1])
    update_battery_voltage(batteries[2])

    update_battery_buses(batteries[1])
    update_battery_buses(batteries[2])

    update_battery_datarefs(batteries[1])
    update_battery_datarefs(batteries[2])
end

