local VMAX_speeds = {
    0.82,
    350,
    280,
    243,
    225,
    215,
    195,
    186
}

local function update_VMAX_demand()
    local min_VMO = VMAX_speeds[2] + 6
    local max_VMO = VMAX_speeds[2] + 16
    local min_MMO = adirs_get_avg_ias() * (VMAX_speeds[1] + 0.006) / Math_clamp_lower(adirs_get_avg_mach(), 0.001)
    local max_MMO = adirs_get_avg_ias() * (VMAX_speeds[1] + 0.040) / Math_clamp_lower(adirs_get_avg_mach(), 0.001)

    if adirs_get_avg_alt() > 24600 then
        set(VMAX_demand, Math_rescale(-1, max_MMO, 0, min_MMO, get(Total_input_pitch)))
    else
        set(VMAX_demand, Math_rescale(-1, max_VMO, 0, min_VMO, get(Total_input_pitch)))
    end
end

local function update_VMAX_prot()
    if adirs_get_avg_alt() > 24600 then
        set(VMAX_prot, adirs_get_avg_ias() * (VMAX_speeds[1] + 0.006) / Math_clamp_lower(adirs_get_avg_mach(), 0.001))
        set(Fixed_VMAX, adirs_get_avg_ias() * VMAX_speeds[1] / Math_clamp_lower(adirs_get_avg_mach(), 0.001))
        --direct law
        if get(FBW_total_control_law) ~= FBW_NORMAL_LAW and get(FBW_total_control_law) ~= FBW_DIRECT_LAW then
            set(Fixed_VMAX, adirs_get_avg_ias() * (0.77 / Math_clamp_lower(adirs_get_avg_mach(), 0.001)))
        end
    else
        set(VMAX_prot, VMAX_speeds[2] + 6)
        set(Fixed_VMAX, VMAX_speeds[2])
        --alt law or direct law
        if get(FBW_total_control_law) ~= FBW_NORMAL_LAW then
            set(Fixed_VMAX, 320)
        end
    end
end

local function update_VMAX()
    if adirs_get_avg_alt() > 24600 then
        set(VMAX, adirs_get_avg_ias() * (VMAX_speeds[1] / Math_clamp_lower(adirs_get_avg_mach(), 0.001)))
        --direct law
        if get(FBW_total_control_law) ~= FBW_NORMAL_LAW and get(FBW_total_control_law) ~= FBW_DIRECT_LAW then
            set(VMAX, adirs_get_avg_ias() * (0.77 / Math_clamp_lower(adirs_get_avg_mach(), 0.001)))
        end
    else
        --normal law
        set(VMAX, VMAX_speeds[2])
        --alt law or direct law
        if get(FBW_total_control_law) ~= FBW_NORMAL_LAW then
            set(VMAX, 320)
        end
    end
    local gear_vmax = false
    if get(Gear_handle) == 1 then
        gear_vmax = false
        if get(Front_gear_deployment) > 0.2 or get(Left_gear_deployment) > 0.2 or get(Right_gear_deployment) > 0.2 then
            gear_vmax = true
        end
    else
        gear_vmax = true
        if get(Front_gear_deployment) < 0.8 or get(Left_gear_deployment) < 0.8 or get(Right_gear_deployment) < 0.8 then
            gear_vmax = false
        end
    end
    if gear_vmax then
        set(VMAX, VMAX_speeds[3])
    end
    if get(Flaps_internal_config) > 0 then
        set(VMAX, VMAX_speeds[get(Flaps_internal_config) + 3])
    end
end

local function update_VFE()
    if get(Flaps_internal_config) == 0 and adirs_get_avg_ias() > 100 then
        set(VFE_speed, VMAX_speeds[Math_clamp_higher(get(Flaps_internal_config), 4) + 1 + 3])
    elseif get(Flaps_internal_config) == 0 and adirs_get_avg_ias() <= 100 then
        set(VFE_speed, VMAX_speeds[Math_clamp_higher(get(Flaps_internal_config), 4) + 2 + 3])
    elseif get(Flaps_internal_config) == 1 then
        set(VFE_speed, VMAX_speeds[Math_clamp_higher(get(Flaps_internal_config), 4) + 2 + 3])
    else
        set(VFE_speed, VMAX_speeds[Math_clamp_higher(get(Flaps_internal_config), 4) + 1 + 3])
    end
end

function update()
    update_VMAX_demand()
    update_VMAX_prot()
    update_VMAX()
    update_VFE()
end