local function THS_CTL(REQ_DEF)
    local MAX_UP_TRIM_LIM = get(THS_range_limited) == 1 and get(THS_limit_def) or get(Max_THS_up)
    REQ_DEF = Math_clamp(REQ_DEF, -get(Max_THS_dn), MAX_UP_TRIM_LIM)

    FBW.fctl.THS.ACT(REQ_DEF)
end

function update()
    THS_CTL(get(Digital_THS_def_tgt))
end