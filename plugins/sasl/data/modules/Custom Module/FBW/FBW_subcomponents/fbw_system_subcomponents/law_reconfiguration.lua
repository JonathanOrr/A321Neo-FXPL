FBW_law_var_table = {
    in_air_timer = 0,
    ABNRM_TO_NORM_TIME = 0,
    ABN_LAW_WAS_ACTIVE = false,
}

function FBW_law_reconfiguration(var_table)
    local ALL_SPLR_FAIL = not FBW.fctl.surfaces.splr.L[1].controlled and
                          not FBW.fctl.surfaces.splr.L[2].controlled and
                          not FBW.fctl.surfaces.splr.L[3].controlled and
                          not FBW.fctl.surfaces.splr.L[4].controlled and
                          not FBW.fctl.surfaces.splr.L[5].controlled and
                          not FBW.fctl.surfaces.splr.R[1].controlled and
                          not FBW.fctl.surfaces.splr.R[2].controlled and
                          not FBW.fctl.surfaces.splr.R[3].controlled and
                          not FBW.fctl.surfaces.splr.R[4].controlled and
                          not FBW.fctl.surfaces.splr.R[5].controlled


    local reconfiguration_conditions = {
        --ALT(NO PROTECTION), DIRECT, ALT
        {
            {adirs_how_many_adr_params_disagree() == 3, "AIR DATA (IAS/MACH) DISAGREE ALT LAW PROT IMPOSSIBLE"},
            {adirs_how_many_adrs_work() == 0, "TRIPLE ADR FAILURE"},
            {get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0, "DOUBLE SFCC FAILURE"},
            {get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450, "GREEN AND BLUE HYDRAULIC FAILURE"},
        },

        --ALT(REDUCED PROTECTION), DIRECT, ALT
        {
            {adirs_how_many_adrs_work() == 1, "DOUBLE SELF DETECTED ADR FAILURE"},
            {adirs_how_many_aoa_disagree() == 3 or adirs_how_many_aoa_failed() == 3, "AOA DISAGREEMENT/FAILURE NRM LAW PROT IMPOSSIBLE"},
            {get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0, "DOUBLE ELAC FAILURE"},
            {not FBW.fctl.surfaces.ail.L.controlled and not FBW.fctl.surfaces.ail.R.controlled, "DOUBLE AILERON FAILURE"},
            {not FBW.fctl.surfaces.THS.THS.controlled and not FBW.fctl.surfaces.THS.THS.mechanical, "THS JAMMED"},
            {get(ELAC_2_status) == 0 and get(Hydraulic_B_press) < 1450, "ELAC 2 AND BLUE HYDRAULIC FAILURE"},
            {get(ELAC_1_status) == 0 and get(Hydraulic_G_press) < 1450, "ELAC 1 AND GREEN HYDRAULIC FAILURE"},
            {get(ELAC_1_status) == 0 and get(Hydraulic_Y_press) < 1450, "ELAC 1 AND YELLOW HYDRAULIC FAILURE"},
            {not FBW.fctl.surfaces.elev.L.controlled or not FBW.fctl.surfaces.elev.R.controlled, "SINGLE ELEVATOR FAILURE"},
            --MSSING SIDESTICK FAILURE
            {adirs_how_many_irs_fully_work() == 1, "DOUBLE SELF DETECTED IR FAILURE"},
            {ALL_SPLR_FAIL, "ALL SPOILERS FAILURE"},
            {get(SEC_1_status) == 0 and get(SEC_2_status) == 0 and get(SEC_3_status) == 0, "TRIPLE SEC FAILURE"},
        },

        --ALT(REDUCED PROTECTION), DIRECT, MECHANICAL
        {
            {get(FAC_1_status) == 0 and get(FAC_2_status) == 0, "DOUBLE FAC FAILURE (FAC 1 TRANSIENT)"},
            {get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450, "HYDRAULIC G + Y FAILURE"},
            {not FBW.fctl.surfaces.rud.rud.controlled, "YAW DAMPER FAILURE"},
        },

        --DIRECT, DIRECT, MECHANICAL
        {
            {adirs_how_many_irs_fully_work() == 0, "TRIPLE IR FAILURE"}
        },

        --DIRECT, DIRECT, ALT
        {
            {(get(Wheel_status_LGCIU_1) == 0 and get(Wheel_status_LGCIU_2) == 0) or (get(SEC_1_status) == 0 and get(SEC_2_status) == 0 and get(SEC_3_status) == 0) and get(Flaps_internal_config) >= 3, "LGCIU 1 + 2 OR SEC 1 + 2 + 3 FAILURE AND FLAPS >= CONFIG 2"},
        },
    }

    local abdnormal_condition = {
        (adirs_get_avg_pitch() > 50 or adirs_get_avg_pitch() < -30)   and (adirs_how_many_irs_partially_work() ~= 0 or adirs_how_many_irs_fully_work() ~= 0)                                  and get(Any_wheel_on_ground) == 0,
        (adirs_get_avg_roll() > 125 or adirs_get_avg_roll() < -125)   and (adirs_how_many_irs_partially_work() ~= 0 or adirs_how_many_irs_fully_work() ~= 0)                                  and get(Any_wheel_on_ground) == 0,
        (adirs_get_avg_aoa() > 30 or adirs_get_avg_aoa() < -15)       and (adirs_how_many_irs_fully_work() ~= 0 and adirs_how_many_aoa_disagree() ~= 3 and  adirs_how_many_aoa_failed() ~= 3) and get(Any_wheel_on_ground) == 0,
        (adirs_get_avg_ias() > 440 or adirs_get_avg_ias() < 80)       and adirs_how_many_adrs_work() ~= 0                                                                                     and get(Any_wheel_on_ground) == 0,
        adirs_get_avg_mach() > 0.91                                   and adirs_how_many_adrs_work() ~= 0                                                                                     and get(Any_wheel_on_ground) == 0,
    }

    --TIMER--
    var_table.in_air_timer = Math_clamp_higher( (var_table.in_air_timer + get(DELTA_TIME)) * (1 - get(Any_wheel_on_ground)), 10.5)

    --EXIT ABN AFTER 18 SEC OUT
    if (get(All_on_ground) == 1 and get(FBW_vertical_ground_mode_ratio) == 1) or get(Debug_FBW_ABN_LAW_RESET) == 1 then
        if get(Debug_FBW_ABN_LAW_RESET) == 1 then
            set(Debug_FBW_ABN_LAW_RESET, 0)
        end
        var_table.ABN_LAW_WAS_ACTIVE = false--reset for next flight
    end
    if not var_table.ABN_LAW_WAS_ACTIVE then
        var_table.ABNRM_TO_NORM_TIME = 20
    end
    if 0.9 < get(Total_vertical_g_load) and get(Total_vertical_g_load) <= 1.2 then
        if var_table.ABNRM_TO_NORM_TIME < 20 then
            var_table.ABNRM_TO_NORM_TIME = var_table.ABNRM_TO_NORM_TIME + get(DELTA_TIME)
        end
    end
    --IN ABN TIMER RESET
    for i = 1, #abdnormal_condition do
        if abdnormal_condition[i] and var_table.in_air_timer >= 1 then
            var_table.ABN_LAW_WAS_ACTIVE = true
            var_table.ABNRM_TO_NORM_TIME = 0
        end
    end

    --start with normal law then degrade
    set(FBW_total_control_law,  3)
    set(FBW_lateral_law,        3)
    set(FBW_vertical_law,       3)
    set(FBW_yaw_law,            3)
    set(FBW_alt_to_direct_law,  0)
    set(FBW_ABN_LAW_TRIM_INHIB, 0)

    --pitch law priority order 2 --> 3 --> 1 --> 5 --> 4
    for i = 1, #reconfiguration_conditions[2] do
        if reconfiguration_conditions[2][i][1] then
            set(FBW_vertical_law, FBW_ALT_REDUCED_PROT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[3] do
        if reconfiguration_conditions[3][i][1] then
            set(FBW_vertical_law, FBW_ALT_REDUCED_PROT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[1] do
        if reconfiguration_conditions[1][i][1] then
            set(FBW_vertical_law, FBW_ALT_NO_PROT_LAW)
        end
    end
    if var_table.ABNRM_TO_NORM_TIME < 18 or var_table.ABN_LAW_WAS_ACTIVE then
        set(FBW_vertical_law, FBW_ABNORMAL_LAW)
        if var_table.ABNRM_TO_NORM_TIME < 18 then
            set(FBW_ABN_LAW_TRIM_INHIB, 1)
        end
    end
    for i = 1, #reconfiguration_conditions[5] do
        if reconfiguration_conditions[5][i][1] then
            set(FBW_vertical_law, FBW_DIRECT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[4] do
        if reconfiguration_conditions[4][i][1] then
            set(FBW_vertical_law, FBW_DIRECT_LAW)
        end
    end

    --roll law priority order  1 <=> 2 <=> 3 <=> 5 --> 4
    for i = 1, #reconfiguration_conditions[1] do
        if reconfiguration_conditions[1][i][1] then
            set(FBW_lateral_law, FBW_DIRECT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[2] do
        if reconfiguration_conditions[2][i][1] then
            set(FBW_lateral_law, FBW_DIRECT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[3] do
        if reconfiguration_conditions[3][i][1] then
            set(FBW_lateral_law, FBW_DIRECT_LAW)
        end
    end
    if var_table.ABN_LAW_WAS_ACTIVE then
        set(FBW_lateral_law, FBW_DIRECT_LAW)
    end
    if var_table.ABNRM_TO_NORM_TIME < 18 then
        set(FBW_lateral_law, FBW_ABNORMAL_LAW)
    end
    for i = 1, #reconfiguration_conditions[5] do
        if reconfiguration_conditions[5][i][1] then
            set(FBW_lateral_law, FBW_DIRECT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[4] do
        if reconfiguration_conditions[4][i][1] then
            set(FBW_lateral_law, FBW_DIRECT_LAW)
        end
    end

    --yaw law priority order   2 <=> 1 <=> 5 --> 3 --> 4
    for i = 1, #reconfiguration_conditions[2] do
        if reconfiguration_conditions[2][i][1] then
            set(FBW_yaw_law, FBW_ALT_NO_PROT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[1] do
        if reconfiguration_conditions[1][i][1] then
            set(FBW_yaw_law, FBW_ALT_NO_PROT_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[5] do
        if reconfiguration_conditions[5][i][1] then
            set(FBW_yaw_law, FBW_ALT_NO_PROT_LAW)
        end
    end
    if var_table.ABN_LAW_WAS_ACTIVE then
        set(FBW_yaw_law, FBW_ALT_NO_PROT_LAW)
    end
    if var_table.ABNRM_TO_NORM_TIME < 18 then
        set(FBW_yaw_law, FBW_ABNORMAL_LAW)
    end
    for i = 1, #reconfiguration_conditions[3] do
        if reconfiguration_conditions[3][i][1] then
            set(FBW_yaw_law, FBW_MECHANICAL_BACKUP_LAW)
        end
    end
    for i = 1, #reconfiguration_conditions[4] do
        if reconfiguration_conditions[4][i][1] then
            set(FBW_yaw_law, FBW_MECHANICAL_BACKUP_LAW)
        end
    end

    local gear_down_direct = false

    --ALT law flare mode into direct law
    if get(FBW_vertical_law) ~= FBW_NORMAL_LAW and get(FBW_vertical_law) ~= FBW_DIRECT_LAW and get(FBW_vertical_law) ~= FBW_MECHANICAL_BACKUP_LAW and get(FBW_vertical_law) ~= FBW_ABNORMAL_LAW and not var_table.ABN_LAW_WAS_ACTIVE then
        if (get(Gear_handle) == 1 and get(FBW_vertical_flare_mode_ratio) == 1) or (get(Gear_handle) == 1 and (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1)) then
            set(FBW_vertical_law, FBW_DIRECT_LAW)
            set(FBW_alt_to_direct_law, 1)
            gear_down_direct = true
        end
    end
    if get(FBW_lateral_law) ~= FBW_NORMAL_LAW and get(FBW_lateral_law) ~= FBW_DIRECT_LAW and get(FBW_lateral_law) ~= FBW_MECHANICAL_BACKUP_LAW and get(FBW_lateral_law) ~= FBW_ABNORMAL_LAW and not var_table.ABN_LAW_WAS_ACTIVE then
        if (get(Gear_handle) == 1 and get(FBW_vertical_flare_mode_ratio) == 1) or (get(Gear_handle) == 1 and (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1)) then
            set(FBW_lateral_law, FBW_DIRECT_LAW)
            set(FBW_alt_to_direct_law, 1)
            gear_down_direct = true
        end
    end
    if get(FBW_yaw_law) ~= FBW_NORMAL_LAW and get(FBW_yaw_law) ~= FBW_DIRECT_LAW and get(FBW_yaw_law) ~= FBW_MECHANICAL_BACKUP_LAW and get(FBW_yaw_law) ~= FBW_ABNORMAL_LAW and not var_table.ABN_LAW_WAS_ACTIVE then
        if (get(Gear_handle) == 1 and get(FBW_vertical_flare_mode_ratio) == 1) or (get(Gear_handle) == 1 and (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1)) then
            set(FBW_yaw_law, FBW_ALT_NO_PROT_LAW)
            set(FBW_alt_to_direct_law, 1)
            gear_down_direct = true
        end
    end

    --total mode
    set(FBW_total_control_law, get(FBW_vertical_law))

    --print debug msgs
    if get(Debug_FBW_law_reconfig) == 1 then
        local colum_reconfig = {
            "----------------------------------------------------ALT(NO PROTECTION)--DIRECT---------ALT",
            "-----------------------------------------------ALT(REDUCED PROTECTION)--DIRECT---------ALT",
            "-----------------------------------------------ALT(REDUCED PROTECTION)--DIRECT--MECHANICAL",
            "----------------------------------------------------------------DIRECT--DIRECT--MECHANICAL",
            "----------------------------------------------------------------DIRECT--DIRECT---------ALT",
        }

        print("******************************************************************************************")
        for i = 1, #reconfiguration_conditions do
            print(colum_reconfig[i])
            for j = 1, #reconfiguration_conditions[i] do
                if reconfiguration_conditions[i][j][1] then
                    print(reconfiguration_conditions[i][j][2])
                end
            end
        end

        if get(FBW_total_control_law) == FBW_ABNORMAL_LAW then
            print("------------------------------RETURNED TO NRM FOR ".. string.format("%02.f", tostring(var_table.ABNRM_TO_NORM_TIME )) .. "S-------------------------------------")
        end

        for i = 1, #abdnormal_condition do
            if abdnormal_condition[i] then
                print("------------------------------AIRCRAFT IN ABNORMAL ATTITUDES------------------------------")
            end
        end
        if gear_down_direct == true then
            print("----------------------------ALT LAW GEAR DOWN --> DIRECT LAW------------------------------")
        end
        print("------------------------------------------------------------------------------------------")
    end
end

--load up resets-- [so the aircraft does go into degraded laws when you don't want it to]
function onPlaneLoaded()
    FBW_law_var_table.in_air_timer = 0
    FBW_law_var_table.in_air_timer = 0
end
function onAirportLoaded()
    FBW_law_var_table.in_air_timer = 0
end

--run functions--
function update()
    FBW_law_reconfiguration(FBW_law_var_table)
end