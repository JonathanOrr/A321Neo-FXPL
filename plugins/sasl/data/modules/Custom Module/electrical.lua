----------------------------------------------------------------------------------------------------
-- Electrical Logic file

include('electrical_batteries.lua')
include('electrical_buses.lua')
include('electrical_consumptions.lua')
include('electrical_generators.lua')
include('electrical_tr_and_inv.lua')
include('electrical_misc.lua')

local avionics = globalProperty("sim/cockpit2/switches/avionics_power_on")

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

local function set_overheadl_pwrd()

    -- Any DC source can power the overhead elec panel
    local condition = get(XP_Battery_1) == 1 or get(XP_Battery_2) == 1 
                      or get(DC_bus_1_pwrd) == 1 or get(DC_bus_2_pwrd) == 1
                      or get(DC_ess_bus_pwrd) == 1

    set(OVHR_elec_panel_pwrd, condition and 1 or 0)    

end

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
    
    if get(XP_Battery_1) == 1 or get(XP_Battery_2) == 1 then
        set(avionics, 1)
    else
        set(avionics, 0)
    end
    set_overheadl_pwrd()
end

function onAirportLoaded()
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        prep_misc_on_flight()
    end    
end
