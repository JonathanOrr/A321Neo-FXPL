local yaw_limit_clamping_upper_limit = 25--normal law 25 all other laws 30

local VMAX_speeds = {
    0.82,
    350,
    280,
    230,
    215,
    200,
    185,
    177
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
        return (175 - 124) / 40000 * (gross_weight - 40000) + 124
    elseif config == 1 then--1
        return (142 - 102) / 40000 * (gross_weight - 40000) + 102
    elseif config == 2 then--1+f
        return (130 - 93) / 40000 * (gross_weight - 40000) + 93
    elseif config == 3 then--2
        return (126 - 89) / 40000 * (gross_weight - 40000) + 89
    elseif config == 4 then--3
        if gear_down == false then
            return (125 - 89) / 40000 * (gross_weight - 40000) + 89
        else
            return (123 - 86) / 40000 * (gross_weight - 40000) + 86
        end
    elseif config == 5 then--full
        return (117 - 84) / 40000 * (gross_weight - 40000) + 84
    end
end


--calculate flight characteristics values
function update()
    if get(PFD_Capt_Baro_Altitude) > 24600 then
        set(Capt_VMAX, get(PFD_Capt_IAS) * (VMAX_speeds[1] / get(Capt_Mach)))
        set(Max_speed, get(PFD_Capt_IAS) * (VMAX_speeds[1] / get(Capt_Mach)))
    else
        set(Capt_VMAX, VMAX_speeds[2])
    end
    if get(PFD_Fo_Baro_Altitude) > 24600 then
        set(Fo_VMAX, get(PFD_Fo_IAS) * (VMAX_speeds[1] / get(Fo_Mach)))
    else
        set(Fo_VMAX, VMAX_speeds[2])
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

    if get(Gear_handle) ~= 0 and (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3 > 0 then
        set(VLS, Set_anim_value(get(VLS), 1.28 * Extract_vs1g(get(Aircraft_total_weight_kgs), get(Flaps_internal_config), true), 0, 350, 0.3))
    else
        set(VLS, Set_anim_value(get(VLS), 1.28 * Extract_vs1g(get(Aircraft_total_weight_kgs), get(Flaps_internal_config), false), 0, 350, 0.3))
    end
    set(S_speed, 1.23 * Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false))
    set(F_speed, 1.26 * Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false))
    set(Capt_GD, (1.5 * get(Aircraft_total_weight_kgs) / 1000 + 110) + Math_clamp_lower((get(PFD_Capt_Baro_Altitude) - 20000) / 1000, 0))
    set(Fo_GD,   (1.5 * get(Aircraft_total_weight_kgs) / 1000 + 110) + Math_clamp_lower((get(PFD_Fo_Baro_Altitude)   - 20000) / 1000, 0))
    --stall speeds(configuration dependent)
    set(Capt_VSW,         Set_anim_value(get(Capt_VSW),         get(PFD_Capt_IAS) * (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))
    set(Fo_VSW,           Set_anim_value(get(Fo_VSW),           get(PFD_Fo_IAS)   * (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))
    set(Capt_Valpha_prot, Set_anim_value(get(Capt_Valpha_prot), get(PFD_Capt_IAS) * (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))
    set(Fo_Valpha_prot,   Set_anim_value(get(Fo_Valpha_prot),   get(PFD_Fo_IAS)   * (get(Alpha) / vsw_aprot_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))
    set(Capt_Vtoga_prot,  Set_anim_value(get(Capt_Vtoga_prot),  get(PFD_Capt_IAS) * (get(Alpha) / toga_prot_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))
    set(Fo_Vtoga_prot,    Set_anim_value(get(Fo_Vtoga_prot),    get(PFD_Fo_IAS)   * (get(Alpha) / toga_prot_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))
    set(Capt_Valpha_MAX,  Set_anim_value(get(Capt_Valpha_MAX),  get(PFD_Capt_IAS) * (get(Alpha) / alpha_max_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))
    set(Fo_Valpha_MAX,    Set_anim_value(get(Fo_Valpha_MAX),    get(PFD_Fo_IAS)   * (get(Alpha) / alpha_max_alphas[get(Flaps_internal_config) + 1]), 0, 350, 0.5))


    if get(FBW_status) == 2 then
        yaw_limit_clamping_upper_limit = Set_anim_value(yaw_limit_clamping_upper_limit, 25, 25, 30, 31 * get(DELTA_TIME))
    else
        yaw_limit_clamping_upper_limit = Set_anim_value(yaw_limit_clamping_upper_limit, 30, 25, 30, 31 * get(DELTA_TIME))
    end

    if get(IAS) <= 140 then
        set(Yaw_lim, Math_clamp(30, 3.4, yaw_limit_clamping_upper_limit))
    else
        set(Yaw_lim, Math_clamp(-26.6 * math.sqrt(1 - ((Math_clamp(get(IAS), 140, 380) - 380)^2) / 57600) + 30, 3.4, yaw_limit_clamping_upper_limit))
    end
end