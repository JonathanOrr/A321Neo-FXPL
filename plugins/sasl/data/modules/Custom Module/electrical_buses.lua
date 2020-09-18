----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local GEN_1 = 1
local GEN_2 = 2
local GEN_APU = 3
local GEN_EXT  = 4
local GEN_EMER = 5
local GEN_FAKE_BUS_TIE = 99

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ELEC_cmd_BUS_tie,  0, function(phase) elec_bus_tie_toggle(phase) end )

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local bus_tie_pushbutton_status = true

buses = {
    ac1_powered_by = 0,
    ac2_powered_by = 0
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

local function update_datarefs()
    set(Elec_light_BUS_tie, bus_tie_pushbutton_status and 0 or 1)
    set(AC_bus_1_pwrd, buses.ac1_powered_by > 0 and 1 or 0)
    set(AC_bus_2_pwrd, buses.ac2_powered_by > 0 and 1 or 0)
end

function update_buses()
    update_ac_1()
    update_ac_2()
    
    update_datarefs()
    
end
