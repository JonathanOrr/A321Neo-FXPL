local function ELEV_CTL(vertical_input)
    local MAX_UP_DEF = -30
    local MAX_DN_DEF = 17

    local MAX_DIR_UP = -(3.704475 + (15.8338 - 3.703375) / (1 + (Math_clamp_lower(adirs_get_avg_ias(), 0) / 252.8894)^8.89914))
    local MAX_DIR_DN =   3.759707 + (11.8902 - 3.759707) / (1 + (Math_clamp_lower(adirs_get_avg_ias(), 0) / 321.8764)^8.21922)

    --surface variables--
    local L_ELEV_TGT = 0
    local R_ELEV_TGT = 0

    --TARGET DEFECTION LOGIC--
    L_ELEV_TGT = Math_rescale(-1, MAX_DN_DEF, 0, 0, vertical_input) + Math_rescale(0, 0, 1, MAX_UP_DEF, vertical_input)
    R_ELEV_TGT = Math_rescale(-1, MAX_DN_DEF, 0, 0, vertical_input) + Math_rescale(0, 0, 1, MAX_UP_DEF, vertical_input)

    --DIRECT LAW LIMIT--
    if get(Force_full_elevator_limit) == 0 then
        if get(FBW_vertical_law) == FBW_DIRECT_LAW then
            L_ELEV_TGT = Math_clamp(L_ELEV_TGT, MAX_DIR_UP, MAX_DIR_DN)
            R_ELEV_TGT = Math_clamp(R_ELEV_TGT, MAX_DIR_UP, MAX_DIR_DN)
        end
    end

    --SURFACE CENTERING--
    if FCTL.ELEV.STAT.L.centered then L_ELEV_TGT = 0 end
    if FCTL.ELEV.STAT.R.centered then R_ELEV_TGT = 0 end

    FCTL.ELEV.ACT(L_ELEV_TGT, 1)
    FCTL.ELEV.ACT(R_ELEV_TGT, 2)
end

function update()
    ELEV_CTL(get(FBW_pitch_output))
end