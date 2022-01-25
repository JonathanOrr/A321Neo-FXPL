function is_bleed_fault()
    return (get(L_bleed_press) > 57 
    or get(L_bleed_temp) > 270) 
    or (get(R_bleed_press) > 57 or get(R_bleed_temp) > 270) 
    or get(FAILURE_BLEED_ENG_1_LEAK) == 1 
    or get(FAILURE_BLEED_ENG_2_LEAK) == 1 
    or get(FAILURE_BLEED_WING_L_LEAK) == 1
    or get(FAILURE_BLEED_WING_R_LEAK) == 1 
    or get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1
end
function door_open_in_flight()
    return (get(Door_1_l_ratio) > 0 or
    get(Door_1_r_ratio) > 0 or
    get(Door_2_l_ratio) > 0 or
    get(Door_2_r_ratio) > 0 or
    get(Door_3_l_ratio) > 0 or
    get(Door_3_r_ratio) > 0 or
    get(Overwing_exit_1_l_ratio) > 0 or
    get(Overwing_exit_1_r_ratio) > 0 or
    get(Overwing_exit_2_l_ratio) > 0 or
    get(Overwing_exit_2_r_ratio) > 0 or
    get(Cargo_1_ratio) > 0 or
    get(Cargo_2_ratio) > 0) and
    get(All_on_ground) == 0
end

function dc_in_emergency_config()
    return get(DC_ess_bus_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 and get(DC_bus_1_pwrd) == 0
end

function elec_in_emer_config()
      condition =  ((get(Gen_1_pwr) == 0 or get(Gen_1_line_active) == 1) and get(Gen_2_pwr) ==0 and get(Gen_APU_pwr) == 0 and get(Gen_EXT_pwr) == 0)
        condition = condition and not (ENG.dyn[1].is_failed and ENG.dyn[2].is_failed)
    return condition
end

function engine_shuts_down()
    return (get(Engine_1_master_switch) == 0 and get(EWD_flight_phase) >= PHASE_ABOVE_80_KTS and get(EWD_flight_phase) <= PHASE_TOUCHDOWN)
    or ((get(EWD_flight_phase) < PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) > PHASE_TOUCHDOWN) and get(Fire_pb_ENG1_status) == 1)
end

function spdbrk_3_and_4_fault() --fcom 5231
    return get(FAILURE_FCTL_LSPOIL_3) == 1 and get(FAILURE_FCTL_LSPOIL_4) == 1 or 
    get(FAILURE_FCTL_RSPOIL_3) == 1 and get(FAILURE_FCTL_RSPOIL_4) == 1
end

function Y_is_low_pressure()
    return get(Hydraulic_Y_press) <= 1450
end

function G_is_low_pressure()
    return get(Hydraulic_G_press) <= 1450
end

function B_is_low_pressure()
    return get(Hydraulic_B_press) <= 1450
end


function adr_disagrees_on_stuff()
    return adirs_pfds_disagree_on_hdg() or adirs_pfds_disagree_on_alt() or adirs_pfds_disagree_on_ias() or adirs_pfds_disagree_on_att()
end

function spoilers_are_fucked()
    return
    get(FAILURE_FCTL_LSPOIL_1) == 1 or
    get(FAILURE_FCTL_LSPOIL_2) == 1 or
    get(FAILURE_FCTL_LSPOIL_3) == 1 or
    get(FAILURE_FCTL_LSPOIL_4) == 1 or
    get(FAILURE_FCTL_LSPOIL_5) == 1 or
    get(FAILURE_FCTL_RSPOIL_1) == 1 or
    get(FAILURE_FCTL_RSPOIL_2) == 1 or
    get(FAILURE_FCTL_RSPOIL_3) == 1 or
    get(FAILURE_FCTL_RSPOIL_4) == 1 or
    get(FAILURE_FCTL_RSPOIL_5) == 1
end

function one_or_more_spoiler_is_fully_extended_in_speedbrake_fault() --fcom 5231
    return 
    (get(L_SPLR_1) >= 25 or 
    get(L_SPLR_2) >= 25 or 
    get(L_SPLR_3) >= 25 or 
    get(L_SPLR_4) >= 25 or 
    get(L_SPLR_5) >= 25 or 
    get(R_SPLR_1) >= 25 or 
    get(R_SPLR_2) >= 25 or 
    get(R_SPLR_3) >= 25 or 
    get(R_SPLR_4) >= 25 or 
    get(R_SPLR_5) >= 25) and
    spoilers_are_fucked()
end

function stabliser_is_jammed()
    return get(FAILURE_FCTL_THS_MECH) == 1
end

function fwc_1_and_2_fault()
    return get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1
end

function dual_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 or
    get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1 or
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[3]) == 1
end

function triple_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1
end


  function all_engine_failure()
    return get(FAILURE_ENG_1_FAILURE) == 1 and get(FAILURE_ENG_2_FAILURE) == 1
end

  function flaps_slats_fault_in_config_0()
    return (get(Slats_ecam_amber) == 1 or get(Flaps_ecam_amber) == 1) and get(Flaps_deployed_angle) == 0
end

  function spdbrk_2_or_3_and_4_fault() --fcom 5231
    return get(FAILURE_FCTL_LSPOIL_2) == 1 or get(FAILURE_FCTL_LSPOIL_3) == 1 and get(FAILURE_FCTL_LSPOIL_4) == 1 or 
    get(FAILURE_FCTL_RSPOIL_2) == 1 or get(FAILURE_FCTL_RSPOIL_3) == 1 and get(FAILURE_FCTL_RSPOIL_4) == 1
end

  function elec_in_emer_config()
      condition =  ((get(Gen_1_pwr) == 0 or get(Gen_1_line_active) == 1) and get(Gen_2_pwr) ==0 and get(Gen_APU_pwr) == 0 and get(Gen_EXT_pwr) == 0)
        condition = condition and not (ENG.dyn[1].is_failed and ENG.dyn[2].is_failed)
    return condition
end

  function spoilers_are_fucked()
    return
    get(FAILURE_FCTL_LSPOIL_1) == 1 or
    get(FAILURE_FCTL_LSPOIL_2) == 1 or
    get(FAILURE_FCTL_LSPOIL_3) == 1 or
    get(FAILURE_FCTL_LSPOIL_4) == 1 or
    get(FAILURE_FCTL_LSPOIL_5) == 1 or
    get(FAILURE_FCTL_RSPOIL_1) == 1 or
    get(FAILURE_FCTL_RSPOIL_2) == 1 or
    get(FAILURE_FCTL_RSPOIL_3) == 1 or
    get(FAILURE_FCTL_RSPOIL_4) == 1 or
    get(FAILURE_FCTL_RSPOIL_5) == 1
end

  function dc_in_emergency_config()
    return get(DC_ess_bus_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 and get(DC_bus_1_pwrd) == 0
end

  function stabliser_is_jammed()
    return get(FAILURE_FCTL_THS_MECH) == 1
end

  function blue_pump_low_pr_or_ovht()
    return  get(FAILURE_HYD_B_pump) == 1 or get(FAILURE_HYD_B_E_overheat) == 1
end

  function Y_is_low_pressure()
    return get(Hydraulic_Y_press) <= 1450
end

  function G_is_low_pressure()
    return get(Hydraulic_G_press) <= 1450
end

  function B_is_low_pressure()
    return get(Hydraulic_B_press) <= 1450
end

  function B_is_low_level()
    return get(Hydraulic_B_qty) < 0.31
end

  function Y_is_low_level()
    return get(Hydraulic_Y_qty) < 0.18
end

  function G_is_low_level()
    return get(Hydraulic_G_qty) < 0.18
end

  function dual_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 or
    get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1 or
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[3]) == 1
end

  function triple_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1
end

  function adr_disagrees_on_stuff()
    return adirs_pfds_disagree_on_hdg() and adirs_pfds_disagree_on_alt() and adirs_pfds_disagree_on_ias() and adirs_pfds_disagree_on_att()
end

  function vref_10()
    return             (
        (get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
            or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
            or get(FBW_total_control_law) == FBW_DIRECT_LAW
        or
        (get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW)
        or 
        (get(FAILURE_FCTL_SEC_1) == 1 and --fcom 5207
        get(FAILURE_FCTL_SEC_2) == 1)
        or
        Y_is_low_pressure() and B_is_low_pressure() and --B+Y LO PR
            not Y_is_low_level() and not B_is_low_level() or
            adr_disagrees_on_stuff() or
            get(FAILURE_FCTL_ELAC_1) == 1 or
            get(FAILURE_FCTL_ELAC_2) == 1
         ) --fucking hell this is a mess
        and
        not elec_in_emer_config()
        and
        not all_engine_failure()
        and
        not flaps_slats_fault_in_config_0()
        )
end

  function vref_10_140()
    return elec_in_emer_config() 
    and 
    not all_engine_failure() and not get(FBW_total_control_law) == FBW_DIRECT_LAW
    and not flaps_slats_fault_in_config_0() 
    and not stabliser_is_jammed()
end

  function vref_15()
    return get(FBW_total_control_law) == FBW_DIRECT_LAW or
    stabliser_is_jammed()
    and not flaps_slats_fault_in_config_0() or
    dual_adr_failure()
end

  function vref_25()
    return  G_is_low_pressure() and B_is_low_pressure() or
    G_is_low_pressure() and Y_is_low_pressure() 
end

  function vref_50()
    return flaps_slats_fault_in_config_0()
end

  function vref_60()
    return flaps_slats_fault_in_config_0()
    and not stabliser_is_jammed()
end
