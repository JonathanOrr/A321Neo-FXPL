----------------------------------------------------------------------------------------------------
-- Pressurization system
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (Press_manual_control_dn, 0, function(phase) manual_control_handler(phase, -1) end)
sasl.registerCommandHandler (Press_manual_control_up, 0, function(phase) manual_control_handler(phase, 1) end)

sasl.registerCommandHandler (Press_ldg_elev_dial_dn, 0, function(phase) Knob_handler_down_float(phase, Press_ldg_elev_knob_pos, -3, 14, 1) end)
sasl.registerCommandHandler (Press_ldg_elev_dial_up, 0, function(phase) Knob_handler_up_float(phase, Press_ldg_elev_knob_pos, -3, 14, 1) end)


----------------------------------------------------------------------------------------------------
-- Commands handlers
----------------------------------------------------------------------------------------------------
function manual_control_handler(phase, direction)

    if phase == SASL_COMMAND_BEGIN then
        set(Press_manual_control_lever_pos, direction)
    elseif phase == SASL_COMMAND_END then
        set(Press_manual_control_lever_pos, 0)    
    end
end
