local function spd_mach_button(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(AUTOFLT_FCU_SPD_or_MACH) == 0 then
            set(AUTOFLT_FCU_MACH, Math_clamp(Round(adirs_get_avg_mach(), 2), 0.1, 0.99))
        end

        set(AUTOFLT_FCU_SPD_or_MACH, 1 - get(AUTOFLT_FCU_SPD_or_MACH))
    end
end

local function spd_knob_push(phase)
    if phase == SASL_COMMAND_BEGIN then
    
    end
end

local function spd_knob_pull(phase)
    if phase == SASL_COMMAND_BEGIN then
    
    end
end

local function spd_knob_rotated_cc(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_SPD_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_SPD_KNOB_CLICKS) - 1, 0, 32))

        if get(AUTOFLT_FCU_SPD_or_MACH) == 0 then
            set(AUTOFLT_FCU_SPD, Math_clamp_lower(get(AUTOFLT_FCU_SPD) - 1, 100))
        end

        if get(AUTOFLT_FCU_SPD_or_MACH) == 1 then
            set(AUTOFLT_FCU_MACH, Math_clamp_lower(Round(get(AUTOFLT_FCU_MACH) - 0.01, 2), 0.1))
        end
    end
end

local function spd_knob_rotated_cw(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_SPD_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_SPD_KNOB_CLICKS) + 1, 0, 32))

        if get(AUTOFLT_FCU_SPD_or_MACH) == 0 then
            set(AUTOFLT_FCU_SPD, Math_clamp_higher(get(AUTOFLT_FCU_SPD) + 1, 399))
        end

        if get(AUTOFLT_FCU_SPD_or_MACH) == 1 then
            set(AUTOFLT_FCU_MACH, Math_clamp_higher(Round(get(AUTOFLT_FCU_MACH) + 0.01, 2), 0.99))
        end
    end
end

sasl.registerCommandHandler(FCU_cmd_spd_mach,    0, spd_mach_button)
sasl.registerCommandHandler(FCU_knob_speed_push, 0, spd_knob_push)
sasl.registerCommandHandler(FCU_knob_speed_pull, 0, spd_knob_pull)
sasl.registerCommandHandler(FCU_knob_speed_dn,   0, spd_knob_rotated_cc)
sasl.registerCommandHandler(FCU_knob_speed_up,   0, spd_knob_rotated_cw)