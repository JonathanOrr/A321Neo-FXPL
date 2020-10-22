--variable tables
Fctl_computers_var_table = {
    restart_wait = 1.2,
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
    --ELAC 1--
    if get(ELAC_1_off_button) == 0 then
        if var_table.ELAC_1_restart_timer >= var_table.restart_wait then
            set(ELAC_1_status, 1)
        else
            set(ELAC_1_status, 0)
            var_table.ELAC_1_restart_timer = var_table.ELAC_1_restart_timer + 1 * get(DELTA_TIME)
        end
    else
        var_table.ELAC_1_restart_timer = 0
        set(ELAC_1_status, 0)
    end
    --ELAC 2--
    if get(ELAC_2_off_button) == 0 then
        if var_table.ELAC_2_restart_timer >= var_table.restart_wait then
            set(ELAC_2_status, 1)
        else
            set(ELAC_2_status, 0)
            var_table.ELAC_2_restart_timer = var_table.ELAC_2_restart_timer + 1 * get(DELTA_TIME)
        end
    else
        var_table.ELAC_2_restart_timer = 0
        set(ELAC_2_status, 0)
    end

    --FAC 1--
    if get(FAC_1_off_button) == 0 then
        if var_table.FAC_1_restart_timer >= var_table.restart_wait then
            set(FAC_1_status, 1)
        else
            set(FAC_1_status, 0)
            var_table.FAC_1_restart_timer = var_table.FAC_1_restart_timer + 1 * get(DELTA_TIME)
        end
    else
        var_table.FAC_1_restart_timer = 0
        set(FAC_1_status, 0)
    end
    --FAC 2--
    if get(FAC_2_off_button) == 0 then
        if var_table.FAC_2_restart_timer >= var_table.restart_wait then
            set(FAC_2_status, 1)
        else
            set(FAC_2_status, 0)
            var_table.FAC_2_restart_timer = var_table.FAC_2_restart_timer + 1 * get(DELTA_TIME)
        end
    else
        var_table.FAC_2_restart_timer = 0
        set(FAC_2_status, 0)
    end

    --SEC 1--
    if get(SEC_1_off_button) == 0 then
        if var_table.SEC_1_restart_timer >= var_table.restart_wait then
            set(SEC_1_status, 1)
        else
            set(SEC_1_status, 0)
            var_table.SEC_1_restart_timer = var_table.SEC_1_restart_timer + 1 * get(DELTA_TIME)
        end
    else
        var_table.SEC_1_restart_timer = 0
        set(SEC_1_status, 0)
    end
    --SEC 2--
    if get(SEC_2_off_button) == 0 then
        if var_table.SEC_2_restart_timer >= var_table.restart_wait then
            set(SEC_2_status, 1)
        else
            set(SEC_2_status, 0)
            var_table.SEC_2_restart_timer = var_table.SEC_2_restart_timer + 1 * get(DELTA_TIME)
        end
    else
        var_table.SEC_2_restart_timer = 0
        set(SEC_2_status, 0)
    end
    --SEC 3--
    if get(SEC_3_off_button) == 0 then
        if var_table.SEC_3_restart_timer >= var_table.restart_wait then
            set(SEC_3_status, 1)
        else
            set(SEC_3_status, 0)
            var_table.SEC_3_restart_timer = var_table.SEC_3_restart_timer + 1 * get(DELTA_TIME)
        end
    else
        var_table.SEC_3_restart_timer = 0
        set(SEC_3_status, 0)
    end
end