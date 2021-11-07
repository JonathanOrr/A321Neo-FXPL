local aoa_filtering_table = {
    CA_ALPHA = {
        x = 0,
        cut_frequency = 0.25,
    },
    FO_ALPHA = {
        x = 0,
        cut_frequency = 0.25,
    },
    FAC_1_ALPHA = {
        x = 0,
        cut_frequency = 0.25,
    },
    FAC_2_ALPHA = {
        x = 0,
        cut_frequency = 0.25,
    },
    MIXED_ALPHA = {
        x = 0,
        cut_frequency = 0.25,
    },
}

local ALPHA_SPD_update_time_s = 0.15
local ALPHA_SPD_update_timer = 0

local alpha0s = {
    -3.15,
    -3.52,
    -7.93,
    -9.72,
    -12.17,
    -13.70
}

local vsw_aprot_alphas = {
    8.5,
    14,
    14,
    13,
    12,
    11
}

local alpha_floor_alphas = {
    9.5,
    15,
    15,
    15,
    14,
    13
}

local alpha_max_alphas = {
    10.5,
    16,
    16,
    16,
    15,
    14
}

local function FILTER_ALPHA()--to smooth out the AoA so that the info is usable
    --filter display AoA for readable purposes
    aoa_filtering_table.CA_ALPHA.x = adirs_get_aoa(PFD_CAPT)
    aoa_filtering_table.FO_ALPHA.x = adirs_get_aoa(PFD_FO)
    aoa_filtering_table.FAC_1_ALPHA.x = FBW.FAC_COMPUTATION.FAC_1.aoa
    aoa_filtering_table.FAC_2_ALPHA.x = FBW.FAC_COMPUTATION.FAC_2.aoa
    aoa_filtering_table.MIXED_ALPHA.x = FBW.FAC_COMPUTATION.MIXED.aoa
    set(Filtered_CA_AoA,        low_pass_filter(aoa_filtering_table.CA_ALPHA))
    set(Filtered_FO_AoA,        low_pass_filter(aoa_filtering_table.FO_ALPHA))
    set(Filtered_FAC_1_AoA,     low_pass_filter(aoa_filtering_table.FAC_1_ALPHA))
    set(Filtered_FAC_2_AoA,     low_pass_filter(aoa_filtering_table.FAC_2_ALPHA))
    set(Filtered_FAC_MIXED_AoA, low_pass_filter(aoa_filtering_table.MIXED_ALPHA))
end

local function GET_MAX_ALPHA_LIM(flap_config, weight)
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

local function COMPUTE_BUSS_ALPHA()
    local BUSS_VMAX_alphas = {
        {0.0*27 + 0,  GET_MAX_ALPHA_LIM(0, get(Aircraft_total_weight_kgs))},
        {0.7*27 + 0,  GET_MAX_ALPHA_LIM(1, get(Aircraft_total_weight_kgs))},
        {0.7*27 + 10, GET_MAX_ALPHA_LIM(2, get(Aircraft_total_weight_kgs))},
        {0.8*27 + 14, GET_MAX_ALPHA_LIM(3, get(Aircraft_total_weight_kgs))},
        {0.8*27 + 21, GET_MAX_ALPHA_LIM(4, get(Aircraft_total_weight_kgs))},
        {1.0*27 + 30, GET_MAX_ALPHA_LIM(5, get(Aircraft_total_weight_kgs))},
    }
    local BUSS_VLS_alphas = {
        {0.0*27 + 0,  5.4},
        {0.7*27 + 0,  9},
        {0.7*27 + 10, 7.2},
        {0.8*27 + 14, 7.2},
        {0.8*27 + 21, 5.8},
        {1.0*27 + 30, 6.6},
    }
    local BUSS_VSW_alphas = {
        {0.0*27 + 0,  vsw_aprot_alphas[1]},
        {0.7*27 + 0,  vsw_aprot_alphas[2]},
        {0.7*27 + 10, vsw_aprot_alphas[3]},
        {0.8*27 + 14, vsw_aprot_alphas[4]},
        {0.8*27 + 21, vsw_aprot_alphas[5]},
        {1.0*27 + 30, vsw_aprot_alphas[6]},
    }

    set(BUSS_VFE_red_AoA,  Table_interpolate(BUSS_VMAX_alphas, get(Slats)*27 + get(Flaps_deployed_angle)))
    set(BUSS_VFE_norm_AoA, Table_interpolate(BUSS_VMAX_alphas, get(Slats)*27 + get(Flaps_deployed_angle)))
    set(BUSS_VLS_AoA,      Table_interpolate(BUSS_VLS_alphas,  get(Slats)*27 + get(Flaps_deployed_angle)))
    set(BUSS_VSW_AoA,      Table_interpolate(BUSS_VSW_alphas,  get(Slats)*27 + get(Flaps_deployed_angle)))
end

local function COMPUTE_A0_AFLOOR()
    local a0_alphas = {
        {0.0*27 + 0,  alpha0s[1]},
        {0.7*27 + 0,  alpha0s[2]},
        {0.7*27 + 10, alpha0s[3]},
        {0.8*27 + 14, alpha0s[4]},
        {0.8*27 + 21, alpha0s[5]},
        {1.0*27 + 30, alpha0s[6]},
    }
    local afloor_alphas = {
        {0.0*27 + 0,  alpha_floor_alphas[1]},
        {0.7*27 + 0,  alpha_floor_alphas[2]},
        {0.7*27 + 10, alpha_floor_alphas[3]},
        {0.8*27 + 14, alpha_floor_alphas[4]},
        {0.8*27 + 21, alpha_floor_alphas[5]},
        {1.0*27 + 30, alpha_floor_alphas[6]},
    }

    set(A0_AoA,     Table_interpolate(a0_alphas,     get(Slats)*27 + get(Flaps_deployed_angle)))
    set(Afloor_AoA, Table_interpolate(afloor_alphas, get(Slats)*27 + get(Flaps_deployed_angle)))
end

local function COMPUTE_APROT_AMAX(aprot_dataref, amax_dataref, MACH)
    local CLEAN_APROT_ALPHA = Math_rescale(0.5, vsw_aprot_alphas[1], 0.75, 3.5, MACH)
    local CLEAN_AMAX_ALPHA =  Math_rescale(0.5, alpha_max_alphas[1], 0.75, 5.5, MACH)
    local aprot_alphas = {
        {0.0*27 + 0,  CLEAN_APROT_ALPHA},
        {0.7*27 + 0,  vsw_aprot_alphas[2]},
        {0.7*27 + 10, vsw_aprot_alphas[3]},
        {0.8*27 + 14, vsw_aprot_alphas[4]},
        {0.8*27 + 21, vsw_aprot_alphas[5]},
        {1.0*27 + 30, vsw_aprot_alphas[6]},
    }
    local amax_alphas = {
        {0.0*27 + 0,  CLEAN_AMAX_ALPHA},
        {0.7*27 + 0,  alpha_max_alphas[2]},
        {0.7*27 + 10, alpha_max_alphas[3]},
        {0.8*27 + 14, alpha_max_alphas[4]},
        {0.8*27 + 21, alpha_max_alphas[5]},
        {1.0*27 + 30, alpha_max_alphas[6]},
    }

    set(aprot_dataref, Table_interpolate(aprot_alphas, get(Slats)*27 + get(Flaps_deployed_angle)))
    set(amax_dataref,  Table_interpolate(amax_alphas,  get(Slats)*27 + get(Flaps_deployed_angle)))
end

local function COMPUTE_SMOOTH_VALPHAs(VAPROT_dataref, VAMAX_dataref, IAS, APROT_ALPHA_dataref, AMAX_ALPHA_dataref, ALPHA_dataref)
    set(VAPROT_dataref, Math_clamp_higher(IAS * math.sqrt(Math_clamp_lower((get(ALPHA_dataref) - get(A0_AoA)) / (get(APROT_ALPHA_dataref) - get(A0_AoA)), 0)), get(VMAX)))
    set(VAMAX_dataref,  Math_clamp_higher(IAS * math.sqrt(Math_clamp_lower((get(ALPHA_dataref) - get(A0_AoA)) / (get(AMAX_ALPHA_dataref)  - get(A0_AoA)), 0)), get(VMAX)))
end

function update()
    FILTER_ALPHA()

    COMPUTE_BUSS_ALPHA()
    COMPUTE_A0_AFLOOR()
    COMPUTE_APROT_AMAX(FAC_1_Aprot_AoA,     FAC_1_Amax_AoA,     FBW.FAC_COMPUTATION.FAC_1.mach)
    COMPUTE_APROT_AMAX(FAC_2_Aprot_AoA,     FAC_2_Amax_AoA,     FBW.FAC_COMPUTATION.FAC_2.mach)
    COMPUTE_APROT_AMAX(FAC_MIXED_Aprot_AoA, FAC_MIXED_Amax_AoA, FBW.FAC_COMPUTATION.MIXED.mach)

    --update smooth values of alpha speeds
    COMPUTE_SMOOTH_VALPHAs(FAC_1_Vaprot_VSW,     FAC_1_Valpha_MAX,     FBW.FAC_COMPUTATION.FAC_1.ias, FAC_1_Aprot_AoA,     FAC_1_Amax_AoA,     Filtered_FAC_1_AoA)
    COMPUTE_SMOOTH_VALPHAs(FAC_2_Vaprot_VSW,     FAC_2_Valpha_MAX,     FBW.FAC_COMPUTATION.FAC_2.ias, FAC_2_Aprot_AoA,     FAC_2_Amax_AoA,     Filtered_FAC_2_AoA)
    COMPUTE_SMOOTH_VALPHAs(FAC_MIXED_Vaprot_VSW, FAC_MIXED_Valpha_MAX, FBW.FAC_COMPUTATION.MIXED.ias, FAC_MIXED_Aprot_AoA, FAC_MIXED_Amax_AoA, Filtered_FAC_MIXED_AoA)

    --VLS & alpha speeds update timer(accirding to video at 25fps updates every 3 <-> 4 frames: https://www.youtube.com/watch?v=3Suxhj9wQio&ab_channel=a321trainingteam)
    ALPHA_SPD_update_timer = ALPHA_SPD_update_timer + get(DELTA_TIME)

    --VLS & stall speeds(configuration dependent)
    --on liftoff for 5 seconds the Aprot value is the same as Amax(FCOM 1.27.20.P4 or DSC 27-20-10-20 P4/6)
    if ALPHA_SPD_update_timer >= ALPHA_SPD_update_time_s then
        --update the delayed speeds
        local FAC_1_MON_AVAIL = FBW.FLT_computer.FAC[1].MON_CHANEL_avail()
        local FAC_2_MON_AVAIL = FBW.FLT_computer.FAC[2].MON_CHANEL_avail()

        if FAC_1_MON_AVAIL and FAC_2_MON_AVAIL then
            set(CA_Vaprot_VSW, get(FAC_1_Vaprot_VSW))
            set(CA_Valpha_MAX, get(FAC_1_Valpha_MAX))
            set(FO_Vaprot_VSW, get(FAC_2_Vaprot_VSW))
            set(FO_Valpha_MAX, get(FAC_2_Valpha_MAX))
        elseif FAC_1_MON_AVAIL and not FAC_2_MON_AVAIL then
            set(CA_Vaprot_VSW, get(FAC_1_Vaprot_VSW))
            set(CA_Valpha_MAX, get(FAC_1_Valpha_MAX))
            set(FO_Vaprot_VSW, get(FAC_1_Vaprot_VSW))
            set(FO_Valpha_MAX, get(FAC_1_Valpha_MAX))
        elseif not FAC_1_MON_AVAIL and FAC_2_MON_AVAIL then
            set(CA_Vaprot_VSW, get(FAC_2_Vaprot_VSW))
            set(CA_Valpha_MAX, get(FAC_2_Valpha_MAX))
            set(FO_Vaprot_VSW, get(FAC_2_Vaprot_VSW))
            set(FO_Valpha_MAX, get(FAC_2_Valpha_MAX))
        else
            set(CA_Vaprot_VSW, 0)
            set(CA_Valpha_MAX, 0)
            set(FO_Vaprot_VSW, 0)
            set(FO_Valpha_MAX, 0)
        end

        --reset timer
        ALPHA_SPD_update_timer = 0
    end
end