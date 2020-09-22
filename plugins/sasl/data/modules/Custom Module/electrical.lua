----------------------------------------------------------------------------------------------------
-- Electrical Logic file

include('electrical_batteries.lua')
include('electrical_buses.lua')
include('electrical_consumptions.lua')
include('electrical_generators.lua')
include('electrical_tr_and_inv.lua')
include('electrical_misc.lua')

ELEC_sys.add_power_consumption = function (bus, current_min, current_max)
    ELEC_sys.buses.pwr_consumption[bus] = ELEC_sys.buses.pwr_consumption[bus] + math.random()*(current_max-current_min) + current_min
end

function update_last_power_consumption()

    -- Perform a hard copy
    for i, x in ipairs(ELEC_sys.buses.pwr_consumption) do
        ELEC_sys.buses.pwr_consumption_last[i] = x
    end
end

reset_pwr_consumption()

function update()

    update_generators()
    update_buses()
    update_batteries()
    update_trs_and_inv()
    update_misc()
    
    update_misc_loads()
    update_trs_loads()
    update_generators_loads()
    update_stinv_loads()
    update_battery_loads()
    
    -- Let's update the power consumption vector used in drawings
    update_last_power_consumption() 
    
    reset_pwr_consumption()
    
    update_consumptions()   -- Check electical_consumptions.lua
    
    -- Just for testing
    -- ELEC_sys.add_power_consumption(ELEC_BUS_HOT_BUS_1, 10, 10)

end

function onAirportLoaded()
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        prep_misc_on_flight()
    end    
end
