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

reset_pwr_consumption()

function update()

    update_generators()
    update_buses()
    update_batteries()
    update_trs_and_inv()
    update_misc()
    
    reset_pwr_consumption()
    
    update_consumptions()
    
    -- Just for testing
    -- ELEC_sys.add_power_consumption(ELEC_BUS_HOT_BUS_1, 10, 10)

    
end
