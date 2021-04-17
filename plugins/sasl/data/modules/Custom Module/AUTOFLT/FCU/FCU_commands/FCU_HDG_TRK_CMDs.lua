local function hdgvs_trk_fpa_button(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(AUTOFLT_FCU_HDGVS_or_TRKFPA) == 0 then
            set(AUTOFLT_FCU_HDG_TRK, math.floor(Math_clamp(adirs_get_avg_track(), 0, 359)))
        end

        set(AUTOFLT_FCU_VS, 0)
        set(AUTOFLT_FCU_FPA, 0)

        set(AUTOFLT_FCU_HDGVS_or_TRKFPA, 1 - get(AUTOFLT_FCU_HDGVS_or_TRKFPA))
    end
end

local function hdg_trk_knob_push(phase)
    if phase == SASL_COMMAND_BEGIN then
    
    end
end

local function hdg_trk_knob_pull(phase)
    if phase == SASL_COMMAND_BEGIN then
    
    end
end

local function hdg_trk_knob_rotated_cc(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_HDG_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_HDG_KNOB_CLICKS) - 1, 0, 32))

        set(AUTOFLT_FCU_HDG_TRK, Math_cycle(get(AUTOFLT_FCU_HDG_TRK) - 1, 0, 359))
    end
end

local function hdg_trk_knob_rotated_cw(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(AUTOFLT_FCU_HDG_KNOB_CLICKS, Math_cycle(get(AUTOFLT_FCU_HDG_KNOB_CLICKS) + 1, 0, 32))

        set(AUTOFLT_FCU_HDG_TRK, Math_cycle(get(AUTOFLT_FCU_HDG_TRK) + 1, 0, 359))
    end
end

sasl.registerCommandHandler(FCU_cmd_hdg_trk,   0, hdgvs_trk_fpa_button)
sasl.registerCommandHandler(FCU_knob_hdg_push, 0, hdg_trk_knob_push)
sasl.registerCommandHandler(FCU_knob_hdg_pull, 0, hdg_trk_knob_pull)
sasl.registerCommandHandler(FCU_knob_hdg_dn,   0, hdg_trk_knob_rotated_cc)
sasl.registerCommandHandler(FCU_knob_hdg_up,   0, hdg_trk_knob_rotated_cw)