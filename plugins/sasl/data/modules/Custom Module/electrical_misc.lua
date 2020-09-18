
----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local is_commercial_switch_on = false
local is_galley_switch_on = false

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ELEC_cmd_Commercial,  0, function(phase) elec_commercial_toggle(phase) end )
sasl.registerCommandHandler (ELEC_cmd_Galley,  0, function(phase) elec_galley_toggle(phase) end )

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

function elec_commercial_toggle(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    is_commercial_switch_on = not is_commercial_switch_on
end

function elec_galley_toggle(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    is_galley_switch_on = not is_galley_switch_on
end

local function update_status()
    is_galley_shed = (get(Gen_1_pwr) == 0 or get(Gen_2_pwr) == 0) and get(Gen_APU_pwr) == 0 and get(Gen_EXT_pwr) == 0

    set(Commercial_pwrd, (is_commercial_switch_on and get(AC_bus_1_pwrd) == 1) and 1 or 0)
    
    set(Gally_pwrd, (is_galley_switch_on and get(AC_bus_1_pwrd) == 1 and not is_galley_shed) and 1 or 0)

end

local function update_datarefs()
    set(Elec_light_Commercial, is_commercial_switch_on and 0 or 1)
    set(Elec_light_Galley,     (is_galley_switch_on and 0 or 1) + (get(FAILURE_ELEC_GALLEY) == 1 and 10 or 0))
end

function update_misc()

    update_status()

    update_datarefs()
end
