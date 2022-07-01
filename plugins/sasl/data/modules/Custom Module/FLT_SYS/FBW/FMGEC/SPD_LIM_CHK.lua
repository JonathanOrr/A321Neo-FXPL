include('FMGS/functions.lua')

FBW.FMGEC.FMGEC_1.SPD_LIM_AVAIL = function ()
    local FMGEC_VALID = FBW.FMGEC.FMGEC_1.VALID
    local FMGEC_AVAIL = FMGC_get_single_status(1) or FMGC_get_single_status(2)

    if get(All_on_ground) == 0 then
        return FMGEC_AVAIL and FMGEC_VALID and FBW.FMGEC.FMGEC_1.ias >= 60 and FBW.FMGEC.FMGEC_1.ias <= 440
    else
        return FMGEC_AVAIL and FMGEC_VALID
    end

    return true
end

FBW.FMGEC.FMGEC_2.SPD_LIM_AVAIL = function ()
    local FMGEC_VALID = FBW.FMGEC.FMGEC_2.VALID
    local FMGEC_AVAIL = FMGC_get_single_status(1) or FMGC_get_single_status(2)

    if get(All_on_ground) == 0 then
        return FMGEC_AVAIL and FMGEC_VALID and FBW.FMGEC.FMGEC_2.ias >= 60 and FBW.FMGEC.FMGEC_2.ias <= 440
    else
        return FMGEC_AVAIL and FMGEC_VALID
    end
end