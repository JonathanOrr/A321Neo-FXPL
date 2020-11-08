--variable tables
Fctl_computers_var_table = {
    ELAC_1_restart_timer = 1.2,
    ELAC_2_restart_timer = 1.2,
    FAC_1_restart_timer = 1.2,
    FAC_2_restart_timer = 1.2,
    SEC_1_restart_timer = 1.2,
    SEC_2_restart_timer = 1.2,
    SEC_3_restart_timer = 1.2,
}

--command buttons callback functions
Toggle_elac_1_callback = function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ELAC_1_off_button, 1 - get(ELAC_1_off_button))
    end
end
Toggle_elac_2_callback = function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ELAC_2_off_button, 1 - get(ELAC_2_off_button))
    end
end

Toggle_fac_1_callback = function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(FAC_1_off_button, 1 - get(FAC_1_off_button))
    end
end
Toggle_fac_2_callback = function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(FAC_2_off_button, 1 - get(FAC_2_off_button))
    end
end

Toggle_sec_1_callback = function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(SEC_1_off_button, 1 - get(SEC_1_off_button))
    end
end
Toggle_sec_2_callback = function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(SEC_2_off_button, 1 - get(SEC_2_off_button))
    end
end
Toggle_sec_3_callback = function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(SEC_3_off_button, 1 - get(SEC_3_off_button))
    end
end

--compute buttons lights states
function Compute_fctl_button_states()
    --ELAC 1 button
    if get(ELAC_1_off_button) == 0 and get(ELAC_1_status) == 1 then
        set(ELAC_1_button_state, 00)
    elseif get(ELAC_1_off_button) == 1 and get(ELAC_1_status) == 0 then
        set(ELAC_1_button_state, 01)
    elseif get(ELAC_1_off_button) == 0 and get(ELAC_1_status) == 0 then
        set(ELAC_1_button_state, 10)
    elseif get(ELAC_1_off_button) == 1 and get(ELAC_1_status) == 1 then--this should not happen
        set(ELAC_1_button_state, 11)
    end
    --ELAC 2 button
    if get(ELAC_2_off_button) == 0 and get(ELAC_2_status) == 1 then
        set(ELAC_2_button_state, 00)
    elseif get(ELAC_2_off_button) == 1 and get(ELAC_2_status) == 0 then
        set(ELAC_2_button_state, 01)
    elseif get(ELAC_2_off_button) == 0 and get(ELAC_2_status) == 0 then
        set(ELAC_2_button_state, 10)
    elseif get(ELAC_2_off_button) == 1 and get(ELAC_2_status) == 1 then--this should not happen
        set(ELAC_2_button_state, 11)
    end

    --FAC 1 button
    if get(FAC_1_off_button) == 0 and get(FAC_1_status) == 1 then
        set(FAC_1_button_state, 00)
    elseif get(FAC_1_off_button) == 1 and get(FAC_1_status) == 0 then
        set(FAC_1_button_state, 01)
    elseif get(FAC_1_off_button) == 0 and get(FAC_1_status) == 0 then
        set(FAC_1_button_state, 10)
    elseif get(FAC_1_off_button) == 1 and get(FAC_1_status) == 1 then--this should not happen
        set(FAC_1_button_state, 11)
    end
    --FAC 2 button
    if get(FAC_2_off_button) == 0 and get(FAC_2_status) == 1 then
        set(FAC_2_button_state, 00)
    elseif get(FAC_2_off_button) == 1 and get(FAC_2_status) == 0 then
        set(FAC_2_button_state, 01)
    elseif get(FAC_2_off_button) == 0 and get(FAC_2_status) == 0 then
        set(FAC_2_button_state, 10)
    elseif get(FAC_2_off_button) == 1 and get(FAC_2_status) == 1 then--this should not happen
        set(FAC_2_button_state, 11)
    end

    --SEC 1 button
    if get(SEC_1_off_button) == 0 and get(SEC_1_status) == 1 then
        set(SEC_1_button_state, 00)
    elseif get(SEC_1_off_button) == 1 and get(SEC_1_status) == 0 then
        set(SEC_1_button_state, 01)
    elseif get(SEC_1_off_button) == 0 and get(SEC_1_status) == 0 then
        set(SEC_1_button_state, 10)
    elseif get(SEC_1_off_button) == 1 and get(SEC_1_status) == 1 then--this should not happen
        set(SEC_1_button_state, 11)
    end
    --SEC 2 button
    if get(SEC_2_off_button) == 0 and get(SEC_2_status) == 1 then
        set(SEC_2_button_state, 00)
    elseif get(SEC_2_off_button) == 1 and get(SEC_2_status) == 0 then
        set(SEC_2_button_state, 01)
    elseif get(SEC_2_off_button) == 0 and get(SEC_2_status) == 0 then
        set(SEC_2_button_state, 10)
    elseif get(SEC_2_off_button) == 1 and get(SEC_2_status) == 1 then--this should not happen
        set(SEC_2_button_state, 11)
    end
    --SEC 3 button
    if get(SEC_3_off_button) == 0 and get(SEC_3_status) == 1 then
        set(SEC_3_button_state, 00)
    elseif get(SEC_3_off_button) == 1 and get(SEC_3_status) == 0 then
        set(SEC_3_button_state, 01)
    elseif get(SEC_3_off_button) == 0 and get(SEC_3_status) == 0 then
        set(SEC_3_button_state, 10)
    elseif get(SEC_3_off_button) == 1 and get(SEC_3_status) == 1 then--this should not happen
        set(SEC_3_button_state, 11)
    end
end

function Fctl_computuers_status_computation(var_table)
    --properties--
    local restart_wait = 1.2

    --ELAC 1--
    set(ELAC_1_status, 1 * (1 - get(ELAC_1_off_button)) * BoolToNum(var_table.ELAC_1_restart_timer >= restart_wait))
    var_table.ELAC_1_restart_timer = Math_clamp_higher((var_table.ELAC_1_restart_timer + 1 * get(DELTA_TIME)) * (1 - get(ELAC_1_off_button)), restart_wait)
    --ELAC 2--
    set(ELAC_2_status, 1 * (1 - get(ELAC_2_off_button)) * BoolToNum(var_table.ELAC_2_restart_timer >= restart_wait))
    var_table.ELAC_2_restart_timer = Math_clamp_higher((var_table.ELAC_2_restart_timer + 1 * get(DELTA_TIME)) * (1 - get(ELAC_2_off_button)), restart_wait)

    --FAC 1--
    set(FAC_1_status, 1 * (1 - get(FAC_1_off_button)) * BoolToNum(var_table.FAC_1_restart_timer >= restart_wait))
    var_table.FAC_1_restart_timer = Math_clamp_higher((var_table.FAC_1_restart_timer + 1 * get(DELTA_TIME)) * (1 - get(FAC_1_off_button)), restart_wait)
    --FAC 2--
    set(FAC_2_status, 1 * (1 - get(FAC_2_off_button)) * BoolToNum(var_table.FAC_2_restart_timer >= restart_wait))
    var_table.FAC_2_restart_timer = Math_clamp_higher((var_table.FAC_2_restart_timer + 1 * get(DELTA_TIME)) * (1 - get(FAC_2_off_button)), restart_wait)

    --SEC 1--
    set(SEC_1_status, 1 * (1 - get(SEC_1_off_button)) * BoolToNum(var_table.SEC_1_restart_timer >= restart_wait))
    var_table.SEC_1_restart_timer = Math_clamp_higher((var_table.SEC_1_restart_timer + 1 * get(DELTA_TIME)) * (1 - get(SEC_1_off_button)), restart_wait)
    --SEC 2--
    set(SEC_2_status, 1 * (1 - get(SEC_2_off_button)) * BoolToNum(var_table.SEC_2_restart_timer >= restart_wait))
    var_table.SEC_2_restart_timer = Math_clamp_higher((var_table.SEC_2_restart_timer + 1 * get(DELTA_TIME)) * (1 - get(SEC_2_off_button)), restart_wait)
    --SEC 3--
    set(SEC_3_status, 1 * (1 - get(SEC_3_off_button)) * BoolToNum(var_table.SEC_3_restart_timer >= restart_wait))
    var_table.SEC_3_restart_timer = Math_clamp_higher((var_table.SEC_3_restart_timer + 1 * get(DELTA_TIME)) * (1 - get(SEC_3_off_button)), restart_wait)

    --TODO electrical config


    --FAILURE MANAGER--
    local flight_computers = {
        ELAC_1_status,
        ELAC_2_status,
        FAC_1_status,
        FAC_2_status,
        SEC_1_status,
        SEC_2_status,
        SEC_3_status,
    }

    local flight_computer_failure_datarefs = {
        FAILURE_FCTL_ELAC_1,
        FAILURE_FCTL_ELAC_2,
        FAILURE_FCTL_FAC_1,
        FAILURE_FCTL_FAC_2,
        FAILURE_FCTL_SEC_1,
        FAILURE_FCTL_SEC_2,
        FAILURE_FCTL_SEC_3,
    }

    for i = 1, #flight_computers do
        set(flight_computers[i], get(flight_computers[i]) * (1 - get(flight_computer_failure_datarefs[i])))
    end

    var_table.ELAC_1_restart_timer = var_table.ELAC_1_restart_timer * (1 - get(flight_computer_failure_datarefs[1]))
    var_table.ELAC_2_restart_timer = var_table.ELAC_2_restart_timer * (1 - get(flight_computer_failure_datarefs[2]))
    var_table.FAC_1_restart_timer = var_table.FAC_1_restart_timer * (1 - get(flight_computer_failure_datarefs[3]))
    var_table.FAC_2_restart_timer = var_table.FAC_2_restart_timer * (1 - get(flight_computer_failure_datarefs[4]))
    var_table.SEC_1_restart_timer = var_table.SEC_1_restart_timer * (1 - get(flight_computer_failure_datarefs[5]))
    var_table.SEC_2_restart_timer = var_table.SEC_2_restart_timer * (1 - get(flight_computer_failure_datarefs[6]))
    var_table.SEC_3_restart_timer = var_table.SEC_3_restart_timer * (1 - get(flight_computer_failure_datarefs[7]))
end