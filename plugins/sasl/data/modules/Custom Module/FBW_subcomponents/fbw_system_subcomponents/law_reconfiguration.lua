FBW_law_var_table = {
    in_air_timer = 0,
    fac_1_reset_required = 0,
    abnormal_elac_reset_required = 0,
    abnormal_fac_reset_required = 0,
    last_elac_1_status = 0,
    last_elac_2_status = 0,
    last_fac_1_status = 0,
    last_fac_2_status = 0,
}

function FBW_law_reconfiguration(var_table)
    local reconfiguration_conditions = {
        --ALT(NO PROTECTION), DIRECT, ALT
        {
            --MISSING IAS/MACH DISAGREE
            {how_many_adrs_work() == 0, "TRIPLE ADR FAILURE"},
            {get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0, "DOUBLE SFCC FAILURE"},
            {get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450, "GREEN AND BLUE HYDRAULIC FAILURE"},
            {var_table.abnormal_elac_reset_required == 1, "ABNORMAL LAW AWAITING ELAC RESET"},--put here because of priority order (abnormal exited before reset)
            {var_table.abnormal_fac_reset_required == 1, "ABNORMAL LAW AWAITING FAC RESET"},
        },

        --ALT(REDUCED PROTECTION), DIRECT, ALT
        {
            {how_many_adrs_work() == 1, "DOUBLE SELF DETECTED ADR FAILURE"},
            --MISSING ALPHA DISAGREE
            {get(ELAC_1_status) == 0 and get(ELAC_2_status) == 0, "DOUBLE ELAC FAILURE"},
            {get(FAILURE_FCTL_LAIL) == 1 and get(FAILURE_FCTL_RAIL) == 1, "DOUBLE AILERON FAILURE"},
            {get(FAILURE_FCTL_THS) == 1 or get(FAILURE_FCTL_THS_MECH) == 1, "THS JAMMED"},
            {get(ELAC_2_status) == 0 and get(Hydraulic_B_press) < 1450, "ELAC 2 AND BLUE HYDRAULIC FAILURE"},
            {get(ELAC_1_status) == 0 and get(Hydraulic_G_press) < 1450, "ELAC 1 AND GREEN HYDRAULIC FAILURE"},
            {get(ELAC_1_status) == 0 and get(Hydraulic_Y_press) < 1450, "ELAC 1 AND YELLOW HYDRAULIC FAILURE"},
            {get(FAILURE_FCTL_LELEV) == 1 or get(FAILURE_FCTL_RELEV) == 1, "SINGLE ELEVATOR FAILURE"},
            --MSSING SIDESTICK FAILURE
            {how_many_irs_fully_work() == 1, "DOUBLE SELF DETECTED IR FAILURE"},
            {get(FAILURE_FCTL_LSPOIL_1) == 1 and get(FAILURE_FCTL_LSPOIL_2) == 1 and get(FAILURE_FCTL_LSPOIL_3) == 1 and get(FAILURE_FCTL_LSPOIL_4) == 1 and get(FAILURE_FCTL_LSPOIL_5) == 1 and get(FAILURE_FCTL_RSPOIL_1) == 1 and get(FAILURE_FCTL_RSPOIL_2) == 1 and get(FAILURE_FCTL_RSPOIL_3) == 1 and get(FAILURE_FCTL_RSPOIL_4) == 1 and get(FAILURE_FCTL_RSPOIL_5) == 1, "ALL SPOILERS FAILURE"},
            {get(SEC_1_status) == 0 and get(SEC_2_status) == 0 and get(SEC_3_status) == 0, "TRIPLE SEC FAILURE"},
        },

        --ALT(REDUCED PROTECTION), DIRECT, MECHANICAL
        {
            {get(FAC_1_status) == 0 and get(FAC_2_status) == 0, "DOUBLE FAC FAILURE"},
            {get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450, "HYDRAULIC G + Y FAILURE"},
            --MISSING YAW DAMPER FAILURE
            {get(Gen_EMER_pwr) == 0 and get(Gen_EXT_pwr) == 0 and get(Gen_APU_pwr) == 0 and get(Gen_2_pwr) == 0 and get(Gen_1_pwr) == 0, "EMER ELEC CONFIG (BAT ONLY)"},--can be reset to the column above by reseting FAC 1
            {var_table.fac_1_reset_required == 1 or var_table.fac_1_reset_required == -1, "RESTORED RAT POWER AWAITING FAC 1 RESET"},
        },

        --DIRECT, DIRECT, MECHANICAL
        {
            {how_many_irs_fully_work() == 0, "TRIPLE IR FAILURE"}
        },

        --DIRECT, DIRECT, ALT
        {
            {(get(Wheel_status_LGCIU_1) == 0 and get(Wheel_status_LGCIU_2) == 0) or (get(SEC_1_status) == 0 and get(SEC_2_status) == 0 and get(SEC_3_status) == 0) and get(Flaps_internal_config) >= 3, "LGCIU 1 + 2 OR SEC 1 + 2 + 3 FAILURE AND FLAPS >= CONFIG 2"},
        },
    }

    local abdnormal_condition = {
        (get_avg_pitch() > 50 or get_avg_pitch() < -30)   and (how_many_irs_partially_work() ~= 0 or how_many_irs_fully_work() ~= 0) and get(Any_wheel_on_ground) == 0,
        (get_avg_pitch() > 150 or get_avg_pitch() < -150) and (how_many_irs_partially_work() ~= 0 or how_many_irs_fully_work() ~= 0) and get(Any_wheel_on_ground) == 0,
        (get_avg_aoa() > 30 or get_avg_aoa() < -15)       and how_many_irs_fully_work() ~= 0                                         and get(Any_wheel_on_ground) == 0,
        (get_avg_ias() > 440 or get_avg_ias() < 80)       and how_many_adrs_work() ~= 0                                              and get(Any_wheel_on_ground) == 0,
        get_avg_mach() > 0.91                             and how_many_adrs_work() ~= 0                                              and get(Any_wheel_on_ground) == 0,
    }

    --entered abnormal conditions
    for i = 1, #abdnormal_condition do
        if abdnormal_condition[i] and var_table.in_air_timer >= 1 then
            var_table.abnormal_elac_reset_required = 1
            var_table.abnormal_fac_reset_required = 1
        end
    end

    --check deltas--
    local elac_1_status_delta = get(ELAC_1_status) - var_table.last_elac_1_status
    local elac_2_status_delta = get(ELAC_2_status) - var_table.last_elac_2_status
    local fac_1_status_delta  = get(FAC_1_status)  - var_table.last_fac_1_status
    local fac_2_status_delta  = get(FAC_2_status)  - var_table.last_fac_2_status
    var_table.last_elac_1_status = get(ELAC_1_status)
    var_table.last_elac_2_status = get(ELAC_2_status)
    var_table.last_fac_1_status  = get(FAC_1_status)
    var_table.last_fac_2_status  = get(FAC_2_status)

    --in air timer--
    var_table.in_air_timer = Math_clamp_higher((var_table.in_air_timer + get(DELTA_TIME)) * (1 - get(Any_wheel_on_ground)), 10.5)

    --emer battery config
    if get(DC_shed_ess_pwrd) == 0 and var_table.in_air_timer >= 10 then
        var_table.fac_1_reset_required = 1
    end

    if elac_1_status_delta == 1 or elac_2_status_delta == 1 then
        var_table.abnormal_elac_reset_required = 0
        var_table.abnormal_fac_reset_required = 0
    end
    if fac_1_status_delta == 1 or fac_2_status_delta == 1 then
        var_table.abnormal_elac_reset_required = 0
        var_table.abnormal_fac_reset_required = 0
    end

    if fac_1_status_delta == -1 and var_table.fac_1_reset_required == 1 then
        var_table.fac_1_reset_required = -1
    end
    if fac_1_status_delta == 1 and var_table.fac_1_reset_required == -1 then
        var_table.fac_1_reset_required = 0
    end

    --start with normal law then degrade
    set(FBW_total_control_law, 3)
    set(FBW_lateral_law,       3)
    set(FBW_vertical_law,      3)
    set(FBW_yaw_law,           3)

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
    for i = 1, #abdnormal_condition do
        if abdnormal_condition[i] then
            set(FBW_vertical_law, FBW_ABNORMAL_LAW)
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
    for i = 1, #abdnormal_condition do
        if abdnormal_condition[i] then
            set(FBW_lateral_law, FBW_ABNORMAL_LAW)
        end
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
    for i = 1, #abdnormal_condition do
        if abdnormal_condition[i] then
            set(FBW_yaw_law, FBW_ABNORMAL_LAW)
        end
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
    if get(FBW_vertical_law) ~= FBW_NORMAL_LAW and get(FBW_vertical_law) ~= FBW_DIRECT_LAW and get(FBW_vertical_law) ~= FBW_MECHANICAL_BACKUP_LAW then
        if (get(Gear_handle) == 1 and get(FBW_vertical_flare_mode_ratio) == 1) or (get(Gear_handle) == 1 and (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1)) then
            set(FBW_vertical_law, FBW_DIRECT_LAW)
            gear_down_direct = true
        end
    end
    if get(FBW_lateral_law) ~= FBW_NORMAL_LAW and get(FBW_lateral_law) ~= FBW_DIRECT_LAW and get(FBW_lateral_law) ~= FBW_MECHANICAL_BACKUP_LAW then
        if (get(Gear_handle) == 1 and get(FBW_vertical_flare_mode_ratio) == 1) or (get(Gear_handle) == 1 and (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1)) then
            set(FBW_lateral_law, FBW_DIRECT_LAW)
            gear_down_direct = true
        end
    end
    if get(FBW_yaw_law) ~= FBW_NORMAL_LAW and get(FBW_yaw_law) ~= FBW_DIRECT_LAW and get(FBW_yaw_law) ~= FBW_MECHANICAL_BACKUP_LAW then
        if (get(Gear_handle) == 1 and get(FBW_vertical_flare_mode_ratio) == 1) or (get(Gear_handle) == 1 and (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1)) then
            set(FBW_yaw_law, FBW_ALT_NO_PROT_LAW)
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