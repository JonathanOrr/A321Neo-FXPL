local function Rudder_trim_left(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Rudder_trim_knob_pos, -1)

        if FBW.fctl.RUD.STAT.controlled then
            set(Human_rudder_trim, -1)
        end
    end

    if phase == SASL_COMMAND_END then
        set(Rudder_trim_knob_pos, 0)
    end
end
local function Rudder_trim_right(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Rudder_trim_knob_pos, 1)

        if FBW.fctl.RUD.STAT.controlled then
            set(Human_rudder_trim, 1)
        end
    end

    if phase == SASL_COMMAND_END then
        set(Rudder_trim_knob_pos, 0)
    end
end
local function Reset_rudder_trim(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if FBW.fctl.RUD.STAT.controlled then
            set(Resetting_rudder_trim, 1)
        end
    end
end
sasl.registerCommandHandler(Rudd_trim_L, 1, Rudder_trim_left)
sasl.registerCommandHandler(Rudd_trim_R, 1, Rudder_trim_right)
sasl.registerCommandHandler(Rudd_trim_reset, 1, Reset_rudder_trim)