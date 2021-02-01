include("FBW_subcomponents/flight_ctl_subcomponents/lateral_ctl.lua")
include("ADIRS_data_source.lua")

local in_air_timer = 0
local alpha_speed_update_time_s = 0.15
local alpha_speed_update_timer = 0
local vls_reduced = 0
local vls_reduced_ratio = 0
local last_flap_lever_pos = 0

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

local alpha0s = {
    -1.83,
    -1.88,
    -6.5,
    -7.45,
    -9.75,
    -10.75
}

local vsw_aprot_alphas = {
    8.5,
    13,
    13,
    12,
    12,
    11.5
}

local alpha_floor_alphas = {
    9.5,
    14,
    14,
    13,
    13,
    12.5
}

local alpha_max_alphas = {
    10.5,
    16.5,
    16.5,
    16.5,
    16.0,
    16.0
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

local function update_VMAX_prot()
    if adirs_get_avg_alt() > 24600 then
        set(VMAX_prot, adirs_get_avg_ias() * (VMAX_speeds[1] + 0.006) / Math_clamp_lower(adirs_get_avg_mach(), 0.001))
        set(Fixed_VMAX, adirs_get_avg_ias() * VMAX_speeds[1] / adirs_get_avg_mach())
    else
        set(VMAX_prot, VMAX_speeds[2] + 6)
        set(Fixed_VMAX, VMAX_speeds[2])
    end
end

local function update_VMAX()
    if adirs_get_avg_alt() > 24600 then
        set(VMAX, adirs_get_avg_ias() * (VMAX_speeds[1] / Math_clamp_lower(adirs_get_avg_mach(), 0.001)))
    else
        set(VMAX, VMAX_speeds[2])
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

local function update_VLS()
    local VLS_flaps_spd_lerp_table = {
        {0.0 + 0,  1.28 * Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false)},
        {0.7 + 0,  Math_rescale(0, 1.23, 1, 1.13, vls_reduced_ratio) * Extract_vs1g(get(Aircraft_total_weight_kgs), 1, false)},
        {0.7 + 10, Math_rescale(0, 1.23, 1, 1.13, vls_reduced_ratio) * Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false)},
        {0.8 + 14, Math_rescale(0, 1.23, 1, 1.13, vls_reduced_ratio) * Extract_vs1g(get(Aircraft_total_weight_kgs), 3, false)},
        {0.8 + 21, Math_rescale(0, 1.23, 1, 1.13, vls_reduced_ratio) * Math_rescale(0, Extract_vs1g(get(Aircraft_total_weight_kgs), 4, false), 1, Extract_vs1g(get(Aircraft_total_weight_kgs), 4, true), (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3)},
        {1.0 + 25, Math_rescale(0, 1.23, 1, 1.13, vls_reduced_ratio) * Extract_vs1g(get(Aircraft_total_weight_kgs), 5, false)},
    }
    local VLS_spdbrake_fx_lerp_table = {
        {0.0 + 0,  20},
        {0.7 + 0,  10},
        {0.7 + 10, 6},
        {0.8 + 14, 6},
        {0.8 + 21, 6},
        {1.0 + 25, 6},
    }

    --reduced VLS in TO or TAG
    if get(Any_wheel_on_ground) == 1 and get(Flaps_internal_config) ~= 0 then
        vls_reduced = 1
    end

    --delta lever--
    local flap_lever_delta = get(Flaps_handle_position) - last_flap_lever_pos
    last_flap_lever_pos = get(Flaps_handle_position)

    if flap_lever_delta == -1 or get(Flaps_internal_config) == 0 then
        vls_reduced = 0
    end

    vls_reduced_ratio = Set_linear_anim_value(vls_reduced_ratio, vls_reduced, 0, 1, 1/2.5)

    set(
        VLS,
        Table_interpolate(VLS_flaps_spd_lerp_table, get(Slats) + get(Flaps_deployed_angle))
        + Math_rescale(0, 0, Spoilers_obj.Get_cmded_spdbrk_def(1), Table_interpolate(VLS_spdbrake_fx_lerp_table, get(Slats) + get(Flaps_deployed_angle)), Spoilers_obj.Get_curr_spdbrk_def())
    )
end

local function get_aoa_upper_limit(flap_config, weight)
    --flap_config: 0 = clean, 1 = 1, 2 = 1+f, 3 = 2, 4 = 3, 5 = full
    --weight in kgs

    if flap_config == 0 then
        return -0.02201805 - 0.00002414911*weight + 4.270643e-10 * weight*weight
    elseif flap_config == 1 then
        return 0.00007789286*weight - 1.635864
    elseif flap_config == 2 then
        return 0.00009326967*weight - 5.928373
    elseif flap_config == 3 then
        return 0.00009150578*weight - 7.425183
    elseif flap_config == 4 then
        return 0.0001139397*weight - 10.10557
    else
        return 0.0001179734*weight - 10.32372
    end
end

local function BUSS_compute_VMAX_AoA()
    local BUSS_VMAX_alphas = {
        {0.0 + 0,  get_aoa_upper_limit(0, get(Aircraft_total_weight_kgs))},
        {0.7 + 0,  get_aoa_upper_limit(1, get(Aircraft_total_weight_kgs))},
        {0.7 + 10, get_aoa_upper_limit(2, get(Aircraft_total_weight_kgs))},
        {0.8 + 14, get_aoa_upper_limit(3, get(Aircraft_total_weight_kgs))},
        {0.8 + 21, get_aoa_upper_limit(4, get(Aircraft_total_weight_kgs))},
        {1.0 + 25, get_aoa_upper_limit(5, get(Aircraft_total_weight_kgs))},
    }

    set(BUSS_VFE_red_AoA,  Table_interpolate(BUSS_VMAX_alphas, get(Slats) + get(Flaps_deployed_angle)) - 2)
    set(BUSS_VFE_norm_AoA, Table_interpolate(BUSS_VMAX_alphas, get(Slats) + get(Flaps_deployed_angle)))
end

local function BUSS_compute_VLS_AoA()
    local BUSS_VLS_alphas = {
        {0.0 + 0,  5.4},
        {0.7 + 0,  9},
        {0.7 + 10, 7.2},
        {0.8 + 14, 7.2},
        {0.8 + 21, 5.8},
        {1.0 + 25, 6.6},
    }

    set(BUSS_VLS_AoA, Table_interpolate(BUSS_VLS_alphas, get(Slats) + get(Flaps_deployed_angle)))
end

local function BUSS_compute_VSW_AoA()
    local BUSS_VSW_alphas = {
        {0.0 + 0,  vsw_aprot_alphas[1]},
        {0.7 + 0,  vsw_aprot_alphas[2]},
        {0.7 + 10, vsw_aprot_alphas[3]},
        {0.8 + 14, vsw_aprot_alphas[4]},
        {0.8 + 21, vsw_aprot_alphas[5]},
        {1.0 + 25, vsw_aprot_alphas[6]},
    }

    set(BUSS_VSW_AoA, Table_interpolate(BUSS_VSW_alphas, get(Slats) + get(Flaps_deployed_angle)))
end

local function compute_aprot_vsw_amax_alphas()
    local a0_alphas = {
        {0.0 + 0,  alpha0s[1]},
        {0.7 + 0,  alpha0s[2]},
        {0.7 + 10, alpha0s[3]},
        {0.8 + 14, alpha0s[4]},
        {0.8 + 21, alpha0s[5]},
        {1.0 + 25, alpha0s[6]},
    }
    local aprot_alphas = {
        {0.0 + 0,  vsw_aprot_alphas[1]},
        {0.7 + 0,  vsw_aprot_alphas[2]},
        {0.7 + 10, vsw_aprot_alphas[3]},
        {0.8 + 14, vsw_aprot_alphas[4]},
        {0.8 + 21, vsw_aprot_alphas[5]},
        {1.0 + 25, vsw_aprot_alphas[6]},
    }
    local afloor_alphas = {
        {0.0 + 0,  alpha_floor_alphas[1]},
        {0.7 + 0,  alpha_floor_alphas[2]},
        {0.7 + 10, alpha_floor_alphas[3]},
        {0.8 + 14, alpha_floor_alphas[4]},
        {0.8 + 21, alpha_floor_alphas[5]},
        {1.0 + 25, alpha_floor_alphas[6]},
    }
    local amax_alphas = {
        {0.0 + 0,  alpha_max_alphas[1]},
        {0.7 + 0,  alpha_max_alphas[2]},
        {0.7 + 10, alpha_max_alphas[3]},
        {0.8 + 14, alpha_max_alphas[4]},
        {0.8 + 21, alpha_max_alphas[5]},
        {1.0 + 25, alpha_max_alphas[6]},
    }

    set(A0_AoA,     Table_interpolate(a0_alphas,     get(Slats) + get(Flaps_deployed_angle)))
    set(Aprot_AoA,  Table_interpolate(aprot_alphas,  get(Slats) + get(Flaps_deployed_angle)))
    set(Afloor_AoA, Table_interpolate(afloor_alphas, get(Slats) + get(Flaps_deployed_angle)))
    set(Amax_AoA,   Table_interpolate(amax_alphas,   get(Slats) + get(Flaps_deployed_angle)))
end

local function SPEED_SPEED_SPEED()
    set(GPWS_mode_speed, 0)

    if get(FBW_total_control_law) ~= FBW_NORMAL_LAW or
       get(Flaps_internal_config) <= 2 or
       get(Capt_ra_alt_ft) < 100 or get(Fo_ra_alt_ft) < 100 or
       get(Capt_ra_alt_ft) > 2000 or get(Fo_ra_alt_ft) > 2000 or
       get(Cockpit_throttle_lever_L) >= THR_TOGA_START or get(Cockpit_throttle_lever_R) >= THR_TOGA_START or
       adirs_get_avg_ias() > get(VLS) and adirs_get_avg_ias_trend() >= 0 then--missing AFLOOR
        return
    end

    local delta_vls = 0

    delta_vls = (adirs_get_avg_pitch() - adirs_get_avg_aoa()) * -6 + 26 / Math_clamp_higher(adirs_get_avg_ias_trend(), 0)
    delta_vls = Math_clamp(delta_vls, -10, 10)

    if adirs_get_avg_ias() < (get(VLS) + delta_vls) then
        set(GPWS_mode_speed, 1)
    end
end

local function STALL_STALL()
    set(GPWS_mode_stall, 0)
    --stall warning (needls to be further comfirmed)
    if get(FBW_total_control_law) == FBW_NORMAL_LAW or
       get(Any_wheel_on_ground) == 1 or
       get(FAC_1_status) == 0 and get(FAC_2_status) == 0 then
        return
    end

    if adirs_get_avg_aoa() > get(Aprot_AoA) - 0.5 then
        set(GPWS_mode_stall, 1)
    end
end

--calculate flight characteristics values
function update()
    update_VMAX_prot()
    update_VMAX()
    update_VFE()

    set(S_speed, 1.23 * Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false))
    set(F_speed, 1.22 * Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false))
    set(GD, (1.5 * get(Aircraft_total_weight_kgs) / 1000 + 110) + Math_clamp_lower((adirs_get_avg_alt() - 20000) / 1000, 0))

    BUSS_compute_VMAX_AoA()
    BUSS_compute_VLS_AoA()
    BUSS_compute_VSW_AoA()
    compute_aprot_vsw_amax_alphas()
    SPEED_SPEED_SPEED()
    STALL_STALL()

    --update timer
    if get(Any_wheel_on_ground) == 1 then
        in_air_timer = 0
    end
    if in_air_timer < 10 and get(Any_wheel_on_ground) == 0 then
        in_air_timer = in_air_timer + get(DELTA_TIME)
    end

    --VLS & alpha speeds update timer(accirding to video at 25fps updates every 3 <-> 4 frames: https://www.youtube.com/watch?v=3Suxhj9wQio&ab_channel=a321trainingteam)
    alpha_speed_update_timer = alpha_speed_update_timer + get(DELTA_TIME)

    --VLS & stall speeds(configuration dependent)
    --on liftoff for 5 seconds the Aprot value is the same as Amax(FCOM 1.27.20.P4 or DSC 27-20-10-20 P4/6)
    if alpha_speed_update_timer >= alpha_speed_update_time_s then
        update_VLS()

        if in_air_timer >= 5 then
            set(Vaprot_vsw, Math_clamp_higher(adirs_get_avg_ias() * math.sqrt(Math_clamp_lower((get(Alpha) - get(A0_AoA)) / (get(Aprot_AoA) - get(A0_AoA)), 0)), get(VMAX)))
        else
            set(Vaprot_vsw, Math_clamp_higher(adirs_get_avg_ias() * math.sqrt(Math_clamp_lower((get(Alpha) - get(A0_AoA)) / (get(Amax_AoA) - get(A0_AoA)), 0)), get(VMAX)))
        end
        set(Valpha_MAX, Math_clamp_higher(adirs_get_avg_ias() * math.sqrt(Math_clamp_lower((get(Alpha) - get(A0_AoA)) / (get(Amax_AoA) - get(A0_AoA)), 0)), get(VMAX)))

        --reset timer
        alpha_speed_update_timer = 0
    end
end
