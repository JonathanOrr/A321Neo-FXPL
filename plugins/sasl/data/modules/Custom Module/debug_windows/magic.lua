---------------------------------------------

local function all_engine_failure()
    return get(FAILURE_ENG_1_FAILURE) == 1 and get(FAILURE_ENG_2_FAILURE) == 1
end

local function flaps_slats_fault_in_config_0()
    return (get(Slats_ecam_amber) == 1 or get(Flaps_ecam_amber) == 1) and get(Flaps_deployed_angle) == 0
end

local function spdbrk_2_or_3_and_4_fault() --fcom 5231
    return get(FAILURE_FCTL_LSPOIL_2) == 1 or get(FAILURE_FCTL_LSPOIL_3) == 1 and get(FAILURE_FCTL_LSPOIL_4) == 1 or 
    get(FAILURE_FCTL_RSPOIL_2) == 1 or get(FAILURE_FCTL_RSPOIL_3) == 1 and get(FAILURE_FCTL_RSPOIL_4) == 1
end

local function elec_in_emer_config()
    local condition =  ((get(Gen_1_pwr) == 0 or get(Gen_1_line_active) == 1) and get(Gen_2_pwr) ==0 and get(Gen_APU_pwr) == 0 and get(Gen_EXT_pwr) == 0)
        condition = condition and not (get(Eng_is_failed, 1) and get(Eng_is_failed, 2))
    return condition
end

local function spoilers_are_fucked()
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

local function stabliser_is_jammed()
    return get(FAILURE_FCTL_THS_MECH) == 1
end

local function blue_pump_low_pr_or_ovht()
    return  get(FAILURE_HYD_B_pump) == 1 or get(FAILURE_HYD_B_E_overheat) == 1
end

local function Y_is_low_pressure()
    return get(Hydraulic_Y_press) <= 1450
end

local function G_is_low_pressure()
    return get(Hydraulic_G_press) <= 1450
end

local function B_is_low_pressure()
    return get(Hydraulic_B_press) <= 1450
end

local function B_is_low_level()
    return get(Hydraulic_B_qty) < 0.31
end

local function Y_is_low_level()
    return get(Hydraulic_Y_qty) < 0.18
end

local function G_is_low_level()
    return get(Hydraulic_G_qty) < 0.18
end

local function dual_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 or
    get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1 or
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[3]) == 1
end

local function triple_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1
end

local function adr_disagrees_on_stuff()
    return adirs_pfds_disagree_on_hdg() and adirs_pfds_disagree_on_alt() and adirs_pfds_disagree_on_ias() and adirs_pfds_disagree_on_att()
end

function draw()
    sasl.gl.drawRectangle ( 20 , 20 , 260 , 60 , EFB_WHITE )
end





