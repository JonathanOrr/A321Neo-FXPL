----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local GEN_1 = 1
local GEN_2 = 2
local GEN_APU = 3
local GEN_EXT  = 4
local GEN_EMER = 5
local GEN_FAKE_BUS_TIE = 99

local AC_BUS_1 = 11
local AC_BUS_2 = 12

local STATIC_INVERTER = 21
----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ELEC_cmd_BUS_tie,  0, function(phase) elec_bus_tie_toggle(phase) end )
sasl.registerCommandHandler (ELEC_cmd_AC_ess_feed,  0, function(phase) elec_bus_acc_ess_toggle(phase) end )

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local bus_tie_pushbutton_status = true
local ac_ess_bus_pushbutton_status = false  -- true: alternate, false: normal

buses = {
    ac1_powered_by = 0,
    ac2_powered_by = 0,
    ac_ess_powered_by = 0
}

ELEC_sys.buses = buses

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------
function elec_bus_tie_toggle(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    bus_tie_pushbutton_status = not bus_tie_pushbutton_status
end

function elec_bus_acc_ess_toggle(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    ac_ess_bus_pushbutton_status = not ac_ess_bus_pushbutton_status
end

local function update_ac_1()

    buses.ac1_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!

    if get(Gen_1_pwr) == 1 then
        buses.ac1_powered_by = GEN_1
    elseif get(Gen_EXT_pwr) == 1 then
        buses.ac1_powered_by = GEN_EXT
    elseif get(Gen_APU_pwr) == 1 then
        buses.ac1_powered_by = GEN_APU
    elseif bus_tie_pushbutton_status and get(AC_bus_2_pwrd) == 1 and buses.ac2_powered_by ~= GEN_FAKE_BUS_TIE then
        buses.ac1_powered_by = GEN_FAKE_BUS_TIE
    end

end


local function update_ac_2()

    buses.ac2_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!

    if get(Gen_2_pwr) == 1 then
        buses.ac2_powered_by = GEN_2
    elseif get(Gen_EXT_pwr) == 1 then
        buses.ac2_powered_by = GEN_EXT
    elseif get(Gen_APU_pwr) == 1 then
        buses.ac2_powered_by = GEN_APU
    elseif bus_tie_pushbutton_status and get(AC_bus_1_pwrd) == 1 and buses.ac1_powered_by ~= GEN_FAKE_BUS_TIE then
        buses.ac2_powered_by = GEN_FAKE_BUS_TIE
    end



end

local function update_ac_ess()

    if ac_ess_bus_pushbutton_status then
        buses.ac_ess_powered_by = buses.ac2_powered_by ~= 0 and AC_BUS_2 or 0
    else
        buses.ac_ess_powered_by = buses.ac1_powered_by ~= 0 and AC_BUS_1 or 0
    end
    
    if buses.ac_ess_powered_by == 0 then
        if get(Gen_EMER_pwr) == 1 then
            buses.ac_ess_powered_by = GEN_EMER
        elseif get(INV_online) == 1 then
            buses.ac_ess_powered_by = STATIC_INVERTER
        end
    end
    
end

local function update_datarefs()

    set(AC_bus_1_pwrd, buses.ac1_powered_by > 0 and 1 or 0)
    set(AC_bus_2_pwrd, buses.ac2_powered_by > 0 and 1 or 0)
    set(AC_ess_bus_pwrd, buses.ac_ess_powered_by > 0 and 1 or 0)
    
    set(Elec_light_BUS_tie, bus_tie_pushbutton_status and 0 or 1)
    set(Elec_light_AC_ess_feed, (ac_ess_bus_pushbutton_status and 1 or 0) + (buses.ac_ess_powered_by>0 and 0 or 10)) 
end

function update_buses()
    update_ac_1()
    update_ac_2()
    update_ac_ess()
    
    update_datarefs()
    
end
