local function meter_alt_button(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_M_ALT, 1 - get(AUTOFLT_FCU_M_ALT))
    end
end

local function alt_increment_button(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_ALT_1000_or_100, 1 - get(AUTOFLT_FCU_ALT_1000_or_100))
    end
end

local function alt_knob_push(phase)
    if phase == SASL_COMMAND_BEGIN then
    
    end
end

local function alt_knob_pull(phase)
    if phase == SASL_COMMAND_BEGIN then
    
    end
end

local function alt_knob_rotated_cc(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_ALT_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_ALT_KNOB_CLICKS) - 1, 0, 32))

        local alt_increment = get(AUTOFLT_FCU_ALT_1000_or_100) == 0 and 1000 or 100
        set(AUTOFLT_FCU_ALT, Math_clamp_lower(math.ceil(get(AUTOFLT_FCU_ALT) / alt_increment) * alt_increment - alt_increment, 100))
    end
end

local function alt_knob_rotated_cw(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_ALT_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_ALT_KNOB_CLICKS) + 1, 0, 32))

        local alt_increment = get(AUTOFLT_FCU_ALT_1000_or_100) == 0 and 1000 or 100
        set(AUTOFLT_FCU_ALT, Math_clamp_higher(math.floor(get(AUTOFLT_FCU_ALT) / alt_increment) * alt_increment + alt_increment, 49000))
    end
end

sasl.registerCommandHandler(FCU_knob_range_toggle, 0, alt_increment_button)
sasl.registerCommandHandler(FCU_cmd_metric_alt,    0, meter_alt_button)
sasl.registerCommandHandler(FCU_knob_alt_push,     0, alt_knob_push)
sasl.registerCommandHandler(FCU_knob_alt_pull,     0, alt_knob_pull)
sasl.registerCommandHandler(FCU_knob_alt_dn,       0, alt_knob_rotated_cc)
sasl.registerCommandHandler(FCU_knob_alt_up,       0, alt_knob_rotated_cw)