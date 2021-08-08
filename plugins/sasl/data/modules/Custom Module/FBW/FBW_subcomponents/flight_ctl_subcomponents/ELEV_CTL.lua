FBW.fctl.control.elev = function (vertical_input)
    local no_hyd_recenter_ias = 80
    local elev_no_hyd_spd = 8
    local elevators_speed = 24 --degrees per second

    local max_up_deflection = -30
    local max_dn_deflection = 17

    local max_direct_law_up = -(3.704475 + (15.8338 - 3.703375) / (1 + (Math_clamp_lower(adirs_get_avg_ias(), 0) / 252.8894)^8.89914))
    local max_direct_law_dn = 3.759707 + (11.8902 - 3.759707) / (1 + (Math_clamp_lower(adirs_get_avg_ias(), 0) / 321.8764)^8.21922)

    --surface variables--
    local l_elev_spd = 24
    local r_elev_spd = 24

    local l_elev_target = 0
    local r_elev_target = 0

    if not FBW.fctl.surfaces.elev.L.controlled and not FBW.fctl.surfaces.elev.L.centered then
        if FBW.fctl.surfaces.elev.L.total_hyd_press >= 1450 then--ELECTRICALLY CHANGE SPEED TO DAMPING--
            l_elev_spd = elev_no_hyd_spd
        else--LOSS OF HYDRAULICS DAMPING--
            l_elev_spd = Math_rescale(0, elev_no_hyd_spd, 1450, elevators_speed, FBW.fctl.surfaces.elev.L.total_hyd_press)
        end
    end
    if not FBW.fctl.surfaces.elev.R.controlled and not FBW.fctl.surfaces.elev.R.centered and FBW.fctl.surfaces.elev.R.total_hyd_press >= 1450 then
        if FBW.fctl.surfaces.elev.R.total_hyd_press >= 1450 then--ELECTRICALLY CHANGE SPEED TO DAMPING--
            r_elev_spd = elev_no_hyd_spd
        else--LOSS OF HYDRAULICS DAMPING--
            r_elev_spd = Math_rescale(0, elev_no_hyd_spd, 1450, elevators_speed, FBW.fctl.surfaces.elev.R.total_hyd_press)
        end
    end

    --JAM THE SURFACE--
    l_elev_spd = l_elev_spd * (1 - get(FAILURE_FCTL_LELEV))
    r_elev_spd = r_elev_spd * (1 - get(FAILURE_FCTL_RELEV))

    --TARGET DEFECTION LOGIC--
    l_elev_target = Math_rescale(-1, max_dn_deflection, 0, 0, vertical_input) + Math_rescale(0, 0, 1, max_up_deflection, vertical_input)
    r_elev_target = Math_rescale(-1, max_dn_deflection, 0, 0, vertical_input) + Math_rescale(0, 0, 1, max_up_deflection, vertical_input)

    --DIRECT LAW LIMIT--
    if get(Force_full_elevator_limit) == 0 then
        if get(FBW_vertical_law) == FBW_DIRECT_LAW then
            l_elev_target = Math_clamp(l_elev_target, max_direct_law_up, max_direct_law_dn)
            r_elev_target = Math_clamp(r_elev_target, max_direct_law_up, max_direct_law_dn)
        end
    end

    --SURFACE CENTERING--
    if FBW.fctl.surfaces.elev.L.centered then l_elev_target = 0 end
    if FBW.fctl.surfaces.elev.R.centered then r_elev_target = 0 end

    --DROOP TARGET--
    local l_elev_droop_target = Math_rescale(0, max_dn_deflection, no_hyd_recenter_ias, -get(Alpha) - get(Horizontal_stabilizer_deflection), get(IAS))
    local r_elev_droop_target = Math_rescale(0, max_dn_deflection, no_hyd_recenter_ias, -get(Alpha) - get(Horizontal_stabilizer_deflection), get(IAS))

    --SURFACE DAMPING (with hyd power)--
    if not FBW.fctl.surfaces.elev.L.controlled and not FBW.fctl.surfaces.elev.L.centered then
        l_elev_target = l_elev_droop_target
    end
    if not FBW.fctl.surfaces.elev.R.controlled and not FBW.fctl.surfaces.elev.R.centered then
        r_elev_target = r_elev_droop_target
    end

    set(L_elevator, Set_linear_anim_value(get(L_elevator), l_elev_target, max_up_deflection, max_dn_deflection, l_elev_spd))
    set(R_elevator, Set_linear_anim_value(get(R_elevator), r_elev_target, max_up_deflection, max_dn_deflection, r_elev_spd))
end

function update()
    FBW.fctl.control.elev(get(FBW_pitch_output))
end