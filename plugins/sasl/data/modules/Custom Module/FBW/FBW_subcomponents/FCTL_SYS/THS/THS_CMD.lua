local function MAN_TRIM_UP(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if get(THS_range_limited) == 1 and get(THS_DEF) >= get(THS_limit_def) then
            set(Human_pitch_trim, 0)
        else
            set(Human_pitch_trim, 1)
        end
    end

    return 0--inhibites the x-plane original command
end
local function MAN_TRIM_DN(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        set(Human_pitch_trim, -1)
    end

    return 0--inhibites the x-plane original command
end
sasl.registerCommandHandler(XP_trim_up, 1, MAN_TRIM_UP)
sasl.registerCommandHandler(XP_trim_dn, 1, MAN_TRIM_DN)
sasl.registerCommandHandler(XP_trim_up_mech, 1, MAN_TRIM_UP)
sasl.registerCommandHandler(XP_trim_dn_mech, 1, MAN_TRIM_DN)