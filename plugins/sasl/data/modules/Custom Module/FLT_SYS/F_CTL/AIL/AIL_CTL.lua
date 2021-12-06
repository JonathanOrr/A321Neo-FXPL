local function AIL_CTL(lateral_input)
    --surface range -25 up +25 down, 10 degrees droop with flaps(calculated by ELAC 1/2)
    local MAX_DEF = 25

    --properties
    local L_AIL_DEF_TBL = {
        {-1, -MAX_DEF},
        {0,   10 * get(Flaps_deployed_angle) / 30},
        {1,   MAX_DEF},
    }
    local R_AIL_DEF_TBL = {
        {-1,  MAX_DEF},
        {0,   10 * get(Flaps_deployed_angle) / 30},
        {1,  -MAX_DEF},
    }

    local L_AIL_TGT = Table_interpolate(L_AIL_DEF_TBL, lateral_input)
    local R_AIL_TGT = Table_interpolate(R_AIL_DEF_TBL, lateral_input)

    --ADD MLA & GLA--
    if FBW.fctl.AIL.STAT.L.controlled and FBW.fctl.AIL.STAT.R.controlled then
        L_AIL_TGT = Math_clamp_lower(L_AIL_TGT - get(FBW_MLA_output), -MAX_DEF)
        R_AIL_TGT = Math_clamp_lower(R_AIL_TGT - get(FBW_MLA_output), -MAX_DEF)
        L_AIL_TGT = Math_clamp_lower(L_AIL_TGT - get(FBW_GLA_output), -MAX_DEF)
        R_AIL_TGT = Math_clamp_lower(R_AIL_TGT - get(FBW_GLA_output), -MAX_DEF)
    end

    --TRAVEL TARGETS CALTULATION--
    --aileron anti droop
    if get(Ground_spoilers_mode) == 2 and
       get(FBW_total_control_law) == FBW_NORMAL_LAW and
       get(Flaps_internal_config) > 1 and
       adirs_get_avg_pitch() < 2.5 then
        L_AIL_TGT = -MAX_DEF
        R_AIL_TGT = -MAX_DEF
    end

    --output to the surfaces
    FBW.fctl.AIL.ACT(L_AIL_TGT, 1)
    FBW.fctl.AIL.ACT(R_AIL_TGT, 2)
end

function update()
    AIL_CTL(get(FBW_roll_output))
end