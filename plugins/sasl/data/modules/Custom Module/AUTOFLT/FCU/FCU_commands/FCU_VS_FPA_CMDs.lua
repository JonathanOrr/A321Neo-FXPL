local function vs_fpa_knob_push(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_VS, 0)
        set(AUTOFLT_FCU_FPA, 0)

    end
end

local function vs_fpa_knob_pull(phase)
    if phase == SASL_COMMAND_BEGIN then
    
    end
end

local function vs_fpa_knob_rotated_cc(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_ALT_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_ALT_KNOB_CLICKS) - 1, 0, 32))

        if get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 0 then
            set(AUTOFLT_FCU_VS, Math_clamp_lower(get(AUTOFLT_FCU_VS) - 100, -6000))
        end
        if get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 1 then
            set(AUTOFLT_FCU_FPA, Math_clamp_lower(Round(get(AUTOFLT_FCU_FPA) - 0.1, 1), -9.9))
        end
    end
end

local function vs_fpa_knob_rotated_cw(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_ALT_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_ALT_KNOB_CLICKS) + 1, 0, 32))

        if get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 0 then
            set(AUTOFLT_FCU_VS, Math_clamp_higher(get(AUTOFLT_FCU_VS) + 100, 6000))
        end
        if get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 1 then
            set(AUTOFLT_FCU_FPA, Math_clamp_higher(Round(get(AUTOFLT_FCU_FPA) + 0.1, 1), 9.9))
        end
    end
end

sasl.registerCommandHandler(FCU_knob_vs_push, 0, vs_fpa_knob_push)
sasl.registerCommandHandler(FCU_knob_vs_pull, 0, vs_fpa_knob_pull)
sasl.registerCommandHandler(FCU_knob_vs_dn,   0, vs_fpa_knob_rotated_cc)
sasl.registerCommandHandler(FCU_knob_vs_up,   0, vs_fpa_knob_rotated_cw)