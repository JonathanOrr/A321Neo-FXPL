
----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local is_galley_switch_on = false

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ELEC_cmd_Galley,  0, function(phase) elec_galley_toggle(phase) end )
sasl.registerCommandHandler (ELEC_cmd_EMER_GEN_TEST, 0, function(phase) elec_gen_test_press(phase) end)


----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

function elec_gen_test_press(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Gen_TEST_pressed, 1)
    elseif phase == SASL_COMMAND_END then
        set(Gen_TEST_pressed, 0)    
    end
end

function elec_galley_toggle(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    is_galley_switch_on = not is_galley_switch_on
end

local function update_status()
    local galley_flight_conditions = get(All_on_ground) == 0 and (get(Gen_1_pwr) + get(Gen_2_pwr) + get(Gen_APU_pwr) >= 2)
    local galley_ground_conditions = get(All_on_ground) == 1 and (get(Gen_1_pwr) + get(Gen_2_pwr) == 2 or get(Gen_APU_pwr) == 1 or get(Gen_EXT_pwr) == 1)
    
    is_galley_shed = not (galley_flight_conditions or galley_ground_conditions)
    
    set(Gally_pwrd, (is_galley_switch_on and get(AC_bus_2_pwrd) == 1 and not is_galley_shed) and 1 or 0)

end

local function update_datarefs()
    set(Elec_light_Galley,     get(OVHR_elec_panel_pwrd) * ((is_galley_switch_on and 0 or 1) + (get(FAILURE_ELEC_GALLEY) == 1 and 10 or 0)))
end

function update_misc()

    update_status()

    update_datarefs()
end

function update_misc_loads()
    if get(Gally_pwrd) == 1 then
        -- Galley is on
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 50, 60)   -- 6000W ?
    end
end

function prep_misc_on_flight()
    is_galley_switch_on = true
end
