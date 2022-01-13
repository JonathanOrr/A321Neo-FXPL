FBW.FAC_COMPUTATION.FAC_1.SPD_LIM_AVAIL = function ()
    --[[local FAC_VALID = FBW.FAC_COMPUTATION.FAC_1.VALID
    local MON_AVAIL = FBW.FLT_computer.FAC[1].MON_CHANEL_avail() or FBW.FLT_computer.FAC[2].MON_CHANEL_avail()

    if get(All_on_ground) == 0 then
        return MON_AVAIL and FAC_VALID and FBW.FAC_COMPUTATION.FAC_1.ias >= 60 and FBW.FAC_COMPUTATION.FAC_1.ias <= 440
    else
        return MON_AVAIL and FAC_VALID
    end]]

    return true
end

FBW.FAC_COMPUTATION.FAC_2.SPD_LIM_AVAIL = function ()
    return true

    --[[local FAC_VALID = FBW.FAC_COMPUTATION.FAC_2.VALID
    local MON_AVAIL = FBW.FLT_computer.FAC[1].MON_CHANEL_avail() or FBW.FLT_computer.FAC[2].MON_CHANEL_avail()

    if get(All_on_ground) == 0 then
        return MON_AVAIL and FAC_VALID and FBW.FAC_COMPUTATION.FAC_2.ias >= 60 and FBW.FAC_COMPUTATION.FAC_2.ias <= 440
    else
        return MON_AVAIL and FAC_VALID
    end]]
end