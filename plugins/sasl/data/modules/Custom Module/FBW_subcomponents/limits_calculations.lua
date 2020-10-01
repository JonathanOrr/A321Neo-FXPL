local yaw_limit_clamping_upper_limit = 25--normal law 25 all other laws 30
local max_speeds_kts = {
    280,
    230,
    215,
    200,
    185,
    177
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
        return (126 - 124) / 40000 * (gross_weight - 40000) + 89
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
    set(VLS, Set_anim_value(get(VLS), 1.28 * Extract_vs1g(get(Aircraft_total_weight_kgs), get(Flaps_internal_config), false), 0, get(VMAX), 0.5))
    set(F_speed, 1.26 * Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false))
    set(S_speed, 1.23 * Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false))
    set(GD, (1.5 * get(Aircraft_total_weight_kgs) / 1000 + 110) + Math_clamp_lower((get(Capt_Baro_Alt) - 20000) / 1000, 0))
    set(VSW, Set_anim_value(get(VSW), get(IAS) * (get(Alpha)/7), 0, 350, 0.4))--7 degs AoA
    set(Valpha_prot, Set_anim_value(get(Valpha_prot), get(IAS) * (get(Alpha)/8), 0, 350, 0.4))--8 degs AoA
    set(Valpha_MAX, Set_anim_value(get(Valpha_MAX), get(IAS) * (get(Alpha)/11), 0, 350, 0.8))--11 degs AoA

    --fix this chunk of crap later when you figure out how to convert Mach to kts
    if get(Flaps_travel_ratio) == 0 and (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3 == 0 then
        set(VMAX, 350)
    elseif (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3 > 0 or get(Flaps_travel_ratio) > 0 then
        set(VMAX, Math_lerp(350, max_speeds_kts[1], (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3))
        if get(Gear_handle) == 1 and get(Flaps_travel_ratio) > 0 then
            set(VMAX, Math_lerp(Math_lerp(350, max_speeds_kts[1], (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3), max_speeds_kts[3], Math_clamp(get(Flaps_travel_ratio),0, 0.25) / 0.25) +
                      Math_lerp(0, max_speeds_kts[4] - max_speeds_kts[3], (Math_clamp(get(Flaps_travel_ratio),0.25, 0.5) - 0.25) / 0.25) +
                      Math_lerp(0, max_speeds_kts[5] - max_speeds_kts[4], (Math_clamp(get(Flaps_travel_ratio),0.5, 0.75) - 0.5) / 0.25) +
                      Math_lerp(0, max_speeds_kts[5] - max_speeds_kts[4], (Math_clamp(get(Flaps_travel_ratio),0.75, 1) - 0.75) / 0.25))
        elseif get(Gear_handle) == 0 and get(Flaps_travel_ratio) > 0 then
            set(VMAX, Math_lerp(350, max_speeds_kts[3], Math_clamp(get(Flaps_travel_ratio), 0, 0.25) / 0.25) +
                      Math_lerp(0, max_speeds_kts[4] - max_speeds_kts[3], (Math_clamp(get(Flaps_travel_ratio),0.25, 0.5) - 0.25) / 0.25) +
                      Math_lerp(0, max_speeds_kts[5] - max_speeds_kts[4], (Math_clamp(get(Flaps_travel_ratio),0.5, 0.75) - 0.5) / 0.25) +
                      Math_lerp(0, max_speeds_kts[5] - max_speeds_kts[4], (Math_clamp(get(Flaps_travel_ratio),0.75, 1) - 0.75) / 0.25))
        end
    end

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