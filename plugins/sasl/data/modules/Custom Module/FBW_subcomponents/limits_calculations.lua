local yaw_limit_clamping_upper_limit = 25--normal law 25 all other laws 30

local VMAX_speeds = {
    0.82,
    350,
    280,
    230,
    215,
    215,
    195,
    190
}

local vsw_aprot_alphas = {
    7,
    13,
    13,
    14,
    13,
    12
}

local toga_prot_alphas = {
    9.5,
    15,
    15,
    15,
    14,
    13
}

local alpha_max_alphas = {
    11,
    16,
    16,
    17,
    16,
    16
}

--custom functions
function Extract_vs1g(gross_weight, config, gear_down)
    if config == 0 then--clean
        return 274.5826 + (79.54455 - 274.5826) / (1 + ((gross_weight / 1000) / 86.96515)^1.689565)
    elseif config == 1 then--1
        return 274.5653 + (43.15795 - 274.5653) / (1 + ((gross_weight / 1000) / 96.95092)^1.192485)
    elseif config == 2 then--1+f
        return 260.859 + (54.7645 - 260.859) / (1 + ((gross_weight / 1000) / 115.5867)^1.348778)
    elseif config == 3 then--2
        return 233.8 + (36.12623 - 233.8) / (1 + ((gross_weight / 1000) / 94.59888)^1.174251)
    elseif config == 4 then--3
        if gear_down == false then
            return 205941.1 + (0.3060642 - 205941.1) / (1 + ((gross_weight / 1000) / 295196500)^0.4922088)
        else
            return 3406261 + (31.05773 - 3406261) / (1 + ((gross_weight / 1000) / 434075700)^0.6790985)
        end
    elseif config == 5 then--full
        return 227.5873 + (39.04142 - 227.5873) / (1 + ((gross_weight / 1000) / 104.9039)^1.237619)
    end
end


--calculate flight characteristics values
function update()
    if get(PFD_Capt_Baro_Altitude) > 24600 then
        set(Capt_VMAX, get(PFD_Capt_IAS) * (VMAX_speeds[1] / get(Capt_Mach)))
        set(Capt_VMAX_prot, get(PFD_Capt_IAS) * (VMAX_speeds[1] + 0.006) / get(Capt_Mach))
    else
        set(Capt_VMAX, VMAX_speeds[2])
        set(Capt_VMAX_prot, VMAX_speeds[2] + 6)
    end
    if get(PFD_Fo_Baro_Altitude) > 24600 then
        set(Fo_VMAX, get(PFD_Fo_IAS) * (VMAX_speeds[1] / get(Fo_Mach)))
        set(Fo_VMAX_prot, get(PFD_Fo_IAS) * (VMAX_speeds[1] + 0.006) / get(Fo_Mach))
    else
        set(Fo_VMAX, VMAX_speeds[2])
        set(Fo_VMAX_prot, VMAX_speeds[2] + 6)
    end
    if get(Gear_handle) == 1 or get(Flaps_internal_config) > 0 then
        if (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3 > 0 then
            set(Capt_VMAX, VMAX_speeds[3])
            set(Fo_VMAX, VMAX_speeds[3])
        end
        if get(Flaps_internal_config) > 0 then
            set(Capt_VMAX, VMAX_speeds[get(Flaps_internal_config) + 3])
            set(Fo_VMAX, VMAX_speeds[get(Flaps_internal_config) + 3])
        end
    end

    set(VFE_speed, VMAX_speeds[Math_clamp_higher(get(Flaps_internal_config), 4) + 1 + 3])

    set(VLS, Set_anim_value(get(VLS), (get(Flaps_internal_config) == 0 and 1.28 or 1.23) * Extract_vs1g(get(Aircraft_total_weight_kgs), get(Flaps_internal_config), get(Gear_handle) ~= 0), 0, 350, 0.3))

    set(S_speed, 1.23 * Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false))
    set(F_speed, 1.22 * Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false))
    set(Capt_GD, (1.5 * get(Aircraft_total_weight_kgs) / 1000 + 110) + Math_clamp_lower((get(PFD_Capt_Baro_Altitude) - 20000) / 1000, 0))
    set(Fo_GD,   (1.5 * get(Aircraft_total_weight_kgs) / 1000 + 110) + Math_clamp_lower((get(PFD_Fo_Baro_Altitude)   - 20000) / 1000, 0))
    --stall speeds(configuration dependent)
    set(Capt_VSW,         Set_anim_value(get(Capt_VSW),         get(PFD_Capt_IAS) -  (get(PFD_Capt_IAS) * (1 - (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 0.6))
    set(Fo_VSW,           Set_anim_value(get(Fo_VSW),           get(PFD_Fo_IAS)   -  (get(PFD_Fo_IAS)   * (1 - (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 0.6))
    set(Capt_Valpha_prot, Set_anim_value(get(Capt_Valpha_prot), get(PFD_Capt_IAS) -  (get(PFD_Capt_IAS) * (1 - (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 0.6))
    set(Fo_Valpha_prot,   Set_anim_value(get(Fo_Valpha_prot),   get(PFD_Fo_IAS)   -  (get(PFD_Fo_IAS)   * (1 - (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 0.6))
    set(Capt_Vtoga_prot,  Set_anim_value(get(Capt_Vtoga_prot),  get(PFD_Capt_IAS) -  (get(PFD_Capt_IAS) * (1 - (get(Alpha) / toga_prot_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 0.6))
    set(Fo_Vtoga_prot,    Set_anim_value(get(Fo_Vtoga_prot),    get(PFD_Fo_IAS)   -  (get(PFD_Fo_IAS)   * (1 - (get(Alpha) / toga_prot_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 0.6))
    set(Capt_Valpha_MAX,  Set_anim_value(get(Capt_Valpha_MAX),  get(PFD_Capt_IAS) -  (get(PFD_Capt_IAS) * (1 - (get(Alpha) / alpha_max_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 1))
    set(Fo_Valpha_MAX,    Set_anim_value(get(Fo_Valpha_MAX),    get(PFD_Fo_IAS)   -  (get(PFD_Fo_IAS)   * (1 - (get(Alpha) / alpha_max_alphas[get(Flaps_internal_config) + 1]))) / 2, 0, 350, 1))

    --calculate_value_delta
    set(Capt_VMAX_prot_delta,   get(PFD_Capt_IAS) - get(Capt_VMAX_prot))
    set(Fo_VMAX_prot_delta,     get(PFD_Fo_IAS)   - get(Fo_VMAX_prot))
    set(Capt_VMAX_delta,        get(PFD_Capt_IAS) - get(Capt_VMAX))
    set(Fo_VMAX_delta,          get(PFD_Fo_IAS)   - get(Fo_VMAX))
    set(Capt_S_speed_delta,     get(PFD_Capt_IAS) - get(S_speed))
    set(Fo_S_speed_delta,       get(PFD_Fo_IAS)   - get(S_speed))
    set(Capt_F_speed_delta,     get(PFD_Capt_IAS) - get(F_speed))
    set(Fo_F_speed_delta,       get(PFD_Fo_IAS)   - get(F_speed))
    set(Capt_VFE_speed_delta,   get(PFD_Capt_IAS) - get(VFE_speed))
    set(Fo_VFE_speed_delta,     get(PFD_Fo_IAS)   - get(VFE_speed))
    set(Capt_VLS_delta,         get(PFD_Capt_IAS) - get(VLS))
    set(Fo_VLS_delta,           get(PFD_Fo_IAS)   - get(VLS))
    set(Capt_GD_delta,          get(PFD_Capt_IAS) - get(Capt_GD))
    set(Fo_GD_delta,            get(PFD_Fo_IAS)   - get(Fo_GD))
    set(Capt_VSW_delta,         get(PFD_Capt_IAS) - get(Capt_VSW))
    set(Fo_VSW_delta,           get(PFD_Fo_IAS)   - get(Fo_VSW))
    set(Capt_Valpha_prot_delta, get(PFD_Capt_IAS) - get(Capt_Valpha_prot))
    set(Fo_Valpha_prot_delta,   get(PFD_Fo_IAS)   - get(Fo_Valpha_prot))
    set(Capt_Vtoga_prot_delta,  get(PFD_Capt_IAS) - get(Capt_Vtoga_prot))
    set(Fo_Vtoga_prot_delta,    get(PFD_Fo_IAS)   - get(Fo_Vtoga_prot))
    set(Capt_Valpha_MAX_delta,  get(PFD_Capt_IAS) - get(Capt_Valpha_MAX))
    set(Fo_Valpha_MAX_delta,    get(PFD_Fo_IAS)   - get(Fo_Valpha_MAX))
end