
local function put_inop_sys_msg_2(messages, dr_1, dr_2, t_1, t_2, title)
    if dr_1 and dr_2 then
        return ( title .. " " .. t_1 .. "+" .. t_2)
    elseif dr_1 then
        return ( title .. " " .. t_1)
    elseif dr_2 then
        return ( title .. " " .. t_2)
    end
    return "UNKWN"    -- Shold not happen
end

local function put_inop_sys_msg_3(messages, dr_1, dr_2, dr_3, t_1, t_2, t_3, title)
    if dr_1 and dr_2 and dr_3 then
        return ( title .. " "..t_1.."+"..t_2.."+"..t_3)
    elseif dr_1 and dr_2 then
        return ( title .. " "..t_1.."+"..t_2.."")
    elseif dr_1  and dr_3 then
        return ( title .. " "..t_1.."+"..t_3.."")
    elseif dr_2 and dr_3 then
        return ( title .. " "..t_2.."+"..t_3.."")
    elseif dr_1 then
        return ( title .. " "..t_1)
    elseif dr_2 then
        return ( title .. " "..t_2)
    elseif dr_3 then
        return ( title .. " "..t_3)
    end
    return "UNKWN"    -- Shold not happen
end

local function base_cond()
    return (ENG.dyn[1].is_avail and ENG.dyn[2].is_avail) or (get(Any_wheel_on_ground)  == 0)
end

local inop_systems_desc = {

    -- ANTI-ICE
    {
     text = "CAPT PITOT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_PITOT_CAPT) == 1 or get(AC_ess_bus_pwrd) == 0 end,
    },
    {
     text = "F/O PITOT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_PITOT_FO) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "STBY PITOT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_PITOT_STDBY) == 1 or get(AC_bus_1_pwrd) == 0 end,
    },
    {
     text = "CAPT AOA", nr = 1,
     cond_1 = function() return get(FAILURE_AI_AOA_CAPT) == 1 or get(AC_ess_shed_pwrd) == 0 end,
    },
    {
     text = "F/O AOA", nr = 1,
     cond_1 = function() return get(FAILURE_AI_AOA_FO) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "STBY AOA", nr = 1,
     cond_1 = function() return get(FAILURE_AI_AOA_STDBY) == 1 or get(AC_bus_1_pwrd) == 0 end,
    },
    {
     text = "CAPT STAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_SP_CAPT) == 1 or get(DC_bus_1_pwrd) == 0 end,
    },
    {
     text = "F/O STAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_SP_FO) == 1 or get(DC_bus_2_pwrd) == 0 end,
    },
    {
     text = "STBY STAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_SP_STDBY) == 1 or get(DC_bus_1_pwrd) == 0 end,
    },
    {
     text = "CAPT TAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_TAT_CAPT) == 1 or get(AC_bus_1_pwrd) == 0 end,
    },
    {
     text = "F/O TAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_TAT_FO) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "ENG", text_after = "A.ICE", nr = 2,
     cond_1 = function() return not AI_sys.comp[ANTIICE_ENG_1].valve_status and (get(DC_bus_1_pwrd) == 0 or get(FAILURE_AI_Eng1_valve_stuck) == 1) end,
     cond_2 = function() return not AI_sys.comp[ANTIICE_ENG_2].valve_status and (get(DC_bus_2_pwrd) == 0 or get(FAILURE_AI_Eng2_valve_stuck) == 1) end,
    },
    {
     text = "WSHLD", text_after = "HEAT", text_1="L", text_2="R", nr = 2,
     cond_1 = function() return get(AI_sys.comp[ANTIICE_WINDOW_HEAT_L].failure) == 1 or get(AI_sys.comp[ANTIICE_WINDOW_HEAT_L].source_elec) == 0 end,
     cond_2 = function() return get(AI_sys.comp[ANTIICE_WINDOW_HEAT_R].failure) == 1 or get(AI_sys.comp[ANTIICE_WINDOW_HEAT_R].source_elec) == 0 end,
    },
    
    -- BLEED
    {
     text = "APU BLEED", nr = 1,
     cond_1 = function() return (get(FAILURE_BLEED_APU_VALVE_STUCK) == 1 and get(Apu_bleed_xplane) == 0) or get(FAILURE_BLEED_APU_LEAK) == 1 end,
    },
    {
     text = "BMC", nr = 2,
     cond_1 = function() return get(FAILURE_BLEED_BMC_1) == 1 or get(DC_shed_ess_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_BLEED_BMC_2) == 1 or get(DC_bus_2_pwrd) == 0 end,
    },
    {
     text = "ENG", text_after="BLEED", nr = 2,
     cond_1 = function() return get(FAILURE_BLEED_APU_LEAK) == 1 or get(FAILURE_BLEED_ENG_1_hi_temp) == 1 or get(FAILURE_BLEED_ENG_1_hi_press) == 1 or get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 1 end,
     cond_2 = function() return get(FAILURE_BLEED_ENG_2_hi_temp) == 1 or get(FAILURE_BLEED_ENG_2_hi_press) == 1 or get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 1  end,
    },
    {
     text = "X BLEED", nr = 1,
     cond_1 = function() return get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1 or (get(DC_bus_2_pwrd) == 0 and get(DC_ess_bus_pwrd) == 0) end,
    },
    {
     text = "PACK", nr = 2,
     cond_1 = function() return get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 end,
     cond_2 = function() return get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 end,
    },
    {
     text = "PACK REGUL", nr = 2,
     cond_1 = function() return get(FAILURE_BLEED_PACK_1_REGUL_FAULT) == 1 or get(DC_shed_ess_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_BLEED_PACK_2_REGUL_FAULT) == 1 or get(DC_bus_2_pwrd) == 0 end,
    },
    

    -- APU
    {
     text = "APU", nr = 1,
     cond_1 = function() return get(FAILURE_ENG_APU_FAIL) == 1 or get(FAILURE_FIRE_APU) == 1 end,
    },
    {
     text = "APU", nr = 1,
     cond_1 = function() return get(FAILURE_ENG_APU_FAIL) == 1 or get(FAILURE_FIRE_APU) == 1 end,
    },

    -- BRAKES
    {
     text = "ANTI SKID", nr = 1,
     cond_1 = function() return get(Brakes_mode) == 3 end,
    },
    {
     text = "NORM BRK", nr = 1,
     cond_1 = function() return get(Brakes_mode) ~= 1 and get(Brakes_mode) ~= 4 end,
    },
    {
     text = "AUTO BRK", nr = 1,
     cond_1 = function() return (get(SEC_1_status) + get(SEC_2_status) + get(SEC_3_status) < 2) or get(FAILURE_GEAR_AUTOBRAKES) == 1 or (get(Brakes_mode) ~= 1 and get(Brakes_mode) ~= 4) end,
    },
    {
     text = "ALTN BRK", nr = 1,
     cond_1 = function() return get(Brakes_mode) == 1 and (get(Wheel_status_ABCU) == 0 or get(Hydraulic_Y_press) <= 1450) end,
    },
    {
     text = "BRK Y ACCU", nr = 1,
     cond_1 = function() return get(Brakes_accumulator) < 1 end,
    },
    {
     text = "BRK SYS", nr = 2,
     cond_1 = function() return get(FAILURE_GEAR_BSCU1) == 1 or get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_GEAR_BSCU2) == 1 or get(AC_bus_2_pwrd) == 0 or get(DC_bus_2_pwrd) == 0 end,
    },

    -- PRESS
    {
     text = "CAB PR", nr = 2,
     cond_1 = function() return get(FAILURE_PRESS_SYS_1) == 1 or get(DC_ess_bus_pwrd) == 0 
              or ((ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT or ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_OFF) 
              and (ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT or ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_OFF) 
              and (ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT or ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_OFF)) 
    end,
     cond_2 = function() return get(FAILURE_PRESS_SYS_2) == 1 or get(DC_bus_2_pwrd) == 0
              or ((ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT or ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_OFF) 
              and (ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT or ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_OFF) 
              and (ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT or ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_OFF))
     end,
    },

    -- DMC
    {
     text = "DMC", nr = 3,
     cond_1 = function() return get(FAILURE_DISPLAY_DMC_1) == 1 or get(AC_ess_bus_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_DISPLAY_DMC_2) == 1 or get(AC_bus_2_pwrd) == 0 end,
     cond_3 = function() return get(FAILURE_DISPLAY_DMC_3) == 1 or (get(AC_bus_1_pwrd) == 0 and get(AC_ess_bus_pwrd) == 0) end,
    },

    -- ELEC
    {
     text = "APU GEN", nr = 1,
     cond_1 = function() return get(FAILURE_ELEC_GEN_APU) == 1 end,
    },
    {
     text = "GEN", nr = 2,
     cond_1 = function() return get(FAILURE_ELEC_GEN_1) == 1 or (not ENG.dyn[1].is_avail and get(All_on_ground) == 0) or not ELEC_sys.generators[1].idg_status end,
     cond_2 = function() return get(FAILURE_ELEC_GEN_2) == 1 or (not ENG.dyn[2].is_avail and get(All_on_ground) == 0) or not ELEC_sys.generators[2].idg_status end,
    },
    {
     text = "BAT", nr = 2,
     cond_1 = function() return get(FAILURE_ELEC_battery_1) == 1 end,
     cond_2 = function() return get(FAILURE_ELEC_battery_2) == 1 end,
    },
    {
     text = "GALY/CAB", nr = 1,
     cond_1 = function() return get(Gally_pwrd) == 0 and PB.ovhd.elec_galley.status_bottom == false end,
    },
    {
     text = "MAIN GALLEY", nr = 1,
     cond_1 = function() return (get(Gen_1_pwr) + get(Gen_2_pwr) <= 1) and (get(Gen_APU_pwr) + get(Gen_EXT_pwr) == 0) end,
    },
    {
     text = "TR", nr = 2,
     cond_1 = function() return get(FAILURE_ELEC_TR_1) == 1 end,
     cond_2 = function() return get(FAILURE_ELEC_TR_2) == 1 end,
    },
    {
     text = "TR ESS", nr = 1,
     cond_1 = function() return get(FAILURE_ELEC_TR_ESS) == 1 end,
    },
    {
     text = "EMER GEN", nr = 1,
     cond_1 = function() return get(Hydraulic_B_qty) < 0.1 or get(Hydraulic_RAT_status) == 2 or get(FAILURE_HYD_RAT) == 1 or get(FAILURE_ELEC_GEN_EMER) == 1 end,
    },
    {
     text = "STAT.INV", nr = 1,
     cond_1 = function() return get(FAILURE_ELEC_STATIC_INV) == 1 or get(FAILURE_ELEC_battery_1) == 1 end,
    },

    -- ENG
    {
     text = "REVERSER", nr = 2,
     all_cond = base_cond,
     cond_1 = function() return get(FAILURE_ENG_REV_FAULT, 1) == 1 or ENG.dyn[1].is_fadec_pwrd == 0 or (get(FAILURE_ENG_FADEC_CH1, 1) == 1 and get(FAILURE_ENG_FADEC_CH2, 1) == 1) or get(Hydraulic_G_press) < 1000 end,
     cond_2 = function() return get(FAILURE_ENG_REV_FAULT, 2) == 1 or ENG.dyn[2].is_fadec_pwrd == 0 or (get(FAILURE_ENG_FADEC_CH1, 2) == 1 and get(FAILURE_ENG_FADEC_CH2, 2) == 1) or get(Hydraulic_Y_press) < 1000 end,
    },
    

    -- F/CTL
    {
     text = "AIL", text_after = "", text_1="L", text_2="R", nr = 2,
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.AIL.STAT.L.controlled end,
     cond_2 = function() return not FBW.fctl.AIL.STAT.R.controlled end,
    },
    {
     text = "ELEV", text_after = "", text_1="L", text_2="R", nr = 2,
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.ELEV.STAT.L.controlled end,
     cond_2 = function() return not FBW.fctl.ELEV.STAT.R.controlled end,
    },
    {
     text = "SPLR", nr = 2, text_1="L1", text_2="L5",
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.SPLR.STAT.L[1].controlled end,
     cond_2 = function() return not FBW.fctl.SPLR.STAT.L[5].controlled end,
    },
    {
     text = "SPLR", nr = 3, text_1="L2", text_2="L3", text_3="L4",
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.SPLR.STAT.L[2].controlled end,
     cond_2 = function() return not FBW.fctl.SPLR.STAT.L[3].controlled end,
     cond_3 = function() return not FBW.fctl.SPLR.STAT.L[4].controlled end,
    },
    {
     text = "SPLR", nr = 2, text_1="R1", text_2="R5",
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.SPLR.STAT.R[1].controlled end,
     cond_2 = function() return not FBW.fctl.SPLR.STAT.R[5].controlled end,
    },
    {
     text = "SPLR", nr = 3, text_1="R2", text_2="R3", text_3="R4",
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.SPLR.STAT.R[2].controlled end,
     cond_2 = function() return not FBW.fctl.SPLR.STAT.R[3].controlled end,
     cond_3 = function() return not FBW.fctl.SPLR.STAT.R[4].controlled end,
    },
    {
     text = "SPD BRK", nr = 1,
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.SPLR.STAT.R[2].controlled and not FBW.fctl.SPLR.STAT.R[3].controlled and not FBW.fctl.SPLR.STAT.R[4].controlled and not FBW.fctl.SPLR.STAT.L[2].controlled and not FBW.fctl.SPLR.STAT.L[3].controlled and not FBW.fctl.SPLR.STAT.L[4].controlled end,
    },
    {
     text = "STABILIZER", nr = 1,
     all_cond = base_cond,
     cond_1 = function() return not FBW.fctl.THS.STAT.mechanical end,
    },
    {
     text = "SLATS", nr = 1,
     cond_1 = function() return get(Slats_ecam_amber) == 1 end,
    },
    {
     text = "FLAPS", nr = 1,
     cond_1 = function() return get(Flaps_ecam_amber) == 1 end,
    },
    {
     text = "ELAC",
     nr = 2,
     cond_1 = function() return get(FAILURE_FCTL_ELAC_1) == 1 or (get(DC_ess_bus_pwrd) == 0 and get(HOT_bus_1_pwrd) == 0) end,
     cond_2 = function() return get(FAILURE_FCTL_ELAC_2) == 1 or (get(DC_bus_2_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0) end,
    },
    {
     text = "SEC",
     nr = 3,
     cond_1 = function() return get(FAILURE_FCTL_SEC_1) == 1 or (get(DC_ess_bus_pwrd) == 0 and get(HOT_bus_1_pwrd) == 0) end,
     cond_2 = function() return get(FAILURE_FCTL_SEC_2) == 1 or (get(DC_bus_2_pwrd) == 0) end,
     cond_3 = function() return get(FAILURE_FCTL_SEC_3) == 1 or (get(DC_bus_2_pwrd) == 0) end,
    },
    {
     text = "FAC",
     nr = 2,
     cond_1 = function() return get(FAILURE_FCTL_FAC_1) == 1 or not (get(AC_ess_bus_pwrd) == 1 and get(DC_shed_ess_pwrd) == 1) end,
     cond_2 = function() return get(FAILURE_FCTL_FAC_2) == 1 or not (get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1) end,
    },

    -- FUEL
    {
     text = "ACT PUMP", nr = 1,
     cond_1 = function() return get(FAILURE_FUEL, ACT_TK_XFR) == 1 or (get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0) end,
    },
    {
     text = "RCT PUMP", nr = 1,
     cond_1 = function() return get(FAILURE_FUEL, RCT_TK_XFR) == 1 or (get(AC_bus_2_pwrd) == 0 or get(DC_bus_2_pwrd) == 0) end,
    },
    {
     text = "CTR TK PUMP",
     nr = 2,
     cond_1 = function() return get(FAILURE_FUEL, C_TK_XFR_1) == 1 or (get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0) end,
     cond_2 = function() return get(FAILURE_FUEL, C_TK_XFR_2) == 1 or (get(AC_bus_2_pwrd) == 0 or get(DC_bus_2_pwrd) == 0) end,
    },
    {
     text = "L TK PUMP",
     nr = 2,
     cond_1 = function() return get(FAILURE_FUEL, L_TK_PUMP_1) == 1 or not ((get(Gen_1_line_active) == 0 and get(AC_bus_1_pwrd) == 1 and get(DC_bus_1_pwrd) == 1) or (get(Gen_1_line_active) == 1 and get(Gen_1_pwr) == 1 and (get(DC_bus_1_pwrd) == 1 or get(DC_ess_bus_pwrd) == 1))) end,
     cond_2 = function() return get(FAILURE_FUEL, L_TK_PUMP_2) == 1 or not (get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1) end,
    },
    {
     text = "R TK PUMP",
     nr = 2,
     cond_1 = function() return get(FAILURE_FUEL, R_TK_PUMP_1) == 1 or not ((get(Gen_1_line_active) == 0 and get(AC_bus_1_pwrd) == 1 and get(DC_bus_1_pwrd) == 1) or (get(Gen_1_line_active) == 1 and get(Gen_1_pwr) == 1 and (get(DC_bus_1_pwrd) == 1 or get(DC_ess_bus_pwrd) == 1))) end,
     cond_2 = function() return get(FAILURE_FUEL, R_TK_PUMP_2) == 1 or not (get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1) end,
    },
    {
     text = "FUEL X FEED", nr = 1,
     cond_1 = function() return get(FAILURE_FUEL_X_FEED) == 1 or (get(DC_shed_ess_pwrd) == 0 and get(DC_bus_2_pwrd) == 0) end,
    },

    -- FWC
    {
     text = "FWC", nr = 2,
     cond_1 = function() return get(FAILURE_DISPLAY_FWC_1) == 1 or get(AC_ess_bus_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_DISPLAY_FWC_2) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "ECAM WARN", nr = 1,
     cond_1 = function() return (get(FAILURE_DISPLAY_FWC_1) == 1 or get(AC_ess_bus_pwrd) == 0) and (get(FAILURE_DISPLAY_FWC_2) == 1 or get(AC_bus_2_pwrd) == 0) end,
    },
    {
     text = "ALTI ALERT", nr = 1,
     cond_1 = function() return (get(FAILURE_DISPLAY_FWC_1) == 1 or get(AC_ess_bus_pwrd) == 0) and (get(FAILURE_DISPLAY_FWC_2) == 1 or get(AC_bus_2_pwrd) == 0) end,
    },
    {
     text = "STATUS", nr = 1,
     cond_1 = function() return (get(FAILURE_DISPLAY_FWC_1) == 1 or get(AC_ess_bus_pwrd) == 0) and (get(FAILURE_DISPLAY_FWC_2) == 1 or get(AC_bus_2_pwrd) == 0) end,
    },
    {
     text = "SDAC", nr = 2,
     cond_1 = function() return get(FAILURE_DISPLAY_SDAC_1) == 1 or get(AC_ess_bus_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_DISPLAY_SDAC_2) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    
    -- HYD
    {
     text = "GREEN HYD", nr = 1,
     cond_1 = function() return get(FAILURE_HYD_G_R_overheat) == 1 or (base_cond() and get(Hydraulic_G_press) < 1450) or get(Hydraulic_G_qty) == 0 end,
    },
    {
     text = "BLUE HYD", nr = 1,
     cond_1 = function() return get(FAILURE_HYD_B_R_overheat) == 1 or (base_cond() and get(Hydraulic_B_press) < 1450) or get(Hydraulic_B_qty) == 0 end,
    },
    {
     text = "YELLOW HYD", nr = 1,
     cond_1 = function() return get(FAILURE_HYD_Y_R_overheat) == 1 or (base_cond() and get(Hydraulic_Y_press) < 1450) or get(Hydraulic_Y_qty) == 0 end,
    },
    {
     text = "B ELEC PUMP", nr = 1,
     cond_1 = function() return get(FAILURE_HYD_B_R_overheat) == 1 or get(FAILURE_HYD_B_E_overheat) == 1 or get(FAILURE_HYD_B_pump) == 1 or get(AC_bus_1_pwrd) == 0 or get(DC_ess_bus_pwrd) == 0 or get(Hydraulic_B_qty) == 0 end,
    },
    {
     text = "Y ELEC PUMP", nr = 1,
     cond_1 = function() return get(FAILURE_HYD_Y_R_overheat) == 1 or get(FAILURE_HYD_Y_E_overheat) == 1 or get(FAILURE_HYD_Y_E_pump) == 1 or get(AC_bus_1_pwrd) == 0 or get(DC_bus_2_pwrd) == 0 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "G ENG 1 PUMP", nr = 1,
     cond_1 = function() return (not ENG.dyn[1].is_avail and get(All_on_ground) == 0) or get(FAILURE_HYD_G_pump) == 1 or get(FAILURE_HYD_G_R_overheat) == 1 or get(Hydraulic_G_qty) == 0 end,
    },
    {
     text = "Y ENG 2 PUMP", nr = 1,
     cond_1 = function() return (not ENG.dyn[2].is_avail and get(All_on_ground) == 0) or get(FAILURE_HYD_Y_pump) == 1 or get(FAILURE_HYD_Y_R_overheat) == 1 or get(Hydraulic_Y_qty) == 0 end,
    },
    {
     text = "PTU", nr = 1,
     all_cond = base_cond,
     cond_1 = function() return get(FAILURE_HYD_PTU) == 1 or get(FAILURE_HYD_G_R_overheat) == 1 or get(FAILURE_HYD_Y_R_overheat) == 1 or ((get(Hydraulic_Y_press) < 1450 or get(Hydraulic_Y_qty) == 0) and (get(Hydraulic_G_press) < 1450 or get(Hydraulic_G_qty) == 0)) or get(DC_bus_2_pwrd) == 0 end,
    },
    {
     text = "CARGO DOOR", nr = 1,
     cond_1 = function() return get(Hydraulic_Y_press) < 1450 or get(Hydraulic_Y_qty) == 0 end,
    },
    {
     text = "RAT", nr = 1,
     cond_1 = function() return get(FAILURE_HYD_RAT) == 1 end,
    },

    -- GEAR
    {
     text = "N/W STEER", nr = 1,
     all_cond = base_cond,
     cond_1 = function() return get(FAILURE_GEAR_NWS) == 1 or get(Nosewheel_Steering_working) == 0 or (get(FAILURE_GEAR_LGIU1) == 1  and get(FAILURE_GEAR_LGIU2) == 1 ) end,
    },
    {
     text = "LGCIU", nr = 2,
     cond_1 = function() return get(FAILURE_GEAR_LGIU1) == 1 or get(DC_ess_bus_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_GEAR_LGIU2) == 1 or get(DC_bus_2_pwrd) == 0 end,
    },
    
    -- GPWS
    {
     text = "GPWS", nr = 1,
     cond_1 = function() return get(FAILURE_GPWS) == 1 or get(FAILURE_GEAR_LGIU1) == 1 or get(AC_bus_1_pwrd) == 0 or ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT or ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_OFF end,
    },
    {
     text = "GPWS TERR", nr = 1,
     cond_1 = function() return get(FAILURE_GPWS_TERR) == 1 end
    },
    
    -- NAV
    {
     text = "ADR", nr = 3,
     cond_1 = function() return get(FAILURE_ADR[1]) == 1 or (get(AC_ess_bus_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0) end,
     cond_2 = function() return get(FAILURE_ADR[2]) == 1 or (get(AC_bus_2_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0) end,
     cond_3 = function() return get(FAILURE_ADR[3]) == 1 or (get(AC_bus_1_pwrd) == 0 and get(HOT_bus_1_pwrd) == 0) end,
    },
    {
     text = "CAPT AOA", nr = 1,
     cond_1 = function() return get(FAILURE_SENSOR_AOA_CAPT) == 1 end,
    },
    {
     text = "F/O AOA", nr = 1,
     cond_1 = function() return get(FAILURE_SENSOR_AOA_FO) == 1 end,
    },
    {
     text = "STBY AOA", nr = 1,
     cond_1 = function() return get(FAILURE_SENSOR_AOA_STBY) == 1 end,
    },
    {
     text = "TCAS", nr = 1,
     cond_1 = function() return get(FAILURE_TCAS) == 1 or get(AC_bus_1_pwrd) == 0 or
            (
            (get(FAILURE_ATC_1) == 1 or get(DC_shed_ess_pwrd) == 0) and
            (get(FAILURE_ATC_2) == 1 or get(AC_bus_2_pwrd) == 0)
            )
            or (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_ATT_ALIGNED and ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_ALIGNED)
     end,
    },
    {
     text = "ATC/XPDR", nr = 2,
     cond_1 = function() return get(FAILURE_ATC_1) == 1 or get(AC_ess_shed_pwrd) == 0 
              or
              (get(FAILURE_IR[1]) == 1 or (get(AC_ess_bus_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0))
     end,
     cond_2 = function() return get(FAILURE_ATC_2) == 1 or get(AC_bus_2_pwrd) == 0
              or
              (get(FAILURE_IR[2]) == 1 or (get(AC_bus_2_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0))
     end,
    },
    {
     text = "GPS", nr = 2,
     cond_1 = function() return get(FAILURE_GPS_1) == 1 or get(AC_ess_shed_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_GPS_2) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "ILS", nr = 2,
     cond_1 = function() return get(FAILURE_RADIO_ILS_1) == 1 or get(AC_ess_shed_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_RADIO_ILS_2) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "ADR", nr = 3,
     cond_1 = function() return get(FAILURE_IR[1]) == 1 or (get(AC_ess_bus_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0) end,
     cond_2 = function() return get(FAILURE_IR[2]) == 1 or (get(AC_bus_2_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0) end,
     cond_3 = function() return get(FAILURE_IR[3]) == 1 or (get(AC_bus_1_pwrd) == 0 and get(HOT_bus_1_pwrd) == 0) end,
    },
    
    -- FIRE etc.
    {
     text = "AFT CRG VENT", nr = 1,
     cond_1 = function() return get(FAILURE_FIRE_CARGO_AFT) == 1 end,
    },
    {
     text = "AFT CRG HEAT", nr = 1,
     cond_1 = function() return get(FAILURE_FIRE_CARGO_AFT) == 1 end,
    },
    {
     text = "AVNCS VENT", nr = 1,
     cond_1 = function() return get(FAILURE_AVIONICS_INLET) == 1 or get(FAILURE_AVIONICS_OUTLET) == 1 end,
    },
    {
     text = "VENT BLOWER", nr = 1,
     cond_1 = function() return get(FAILURE_AIRCOND_VENT_BLOWER) == 1 or get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0 end,
    },
    {
     text = "VENT EXTRACT", nr = 1,
     cond_1 = function() return get(FAILURE_AIRCOND_VENT_EXTRACT) == 1 or get(AC_bus_2_pwrd) == 0 or get(DC_shed_ess_pwrd) == 0 end,
    },
    
    -- ANTI-ICE
    {
     text = "WING ANTI ICE", nr = 1,
     cond_1 = function() return get(FAILURE_AI_Wing_L_valve_stuck) == 1 or get(FAILURE_AI_Wing_L_valve_stuck) == 1 or get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1 or get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 1  or get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 1  end,
    },
    
    -- COND
    {
     text = "HOT AIR", nr = 1,
     cond_1 = function() return get(FAILURE_AIRCOND_HOT_AIR_STUCK) == 1 end,
    },
    {
     text = "CRG HOT AIR", nr = 1,
     cond_1 = function() return get(FAILURE_AIRCOND_HOT_AIR_CARGO_STUCK) == 1 end,
    },
    {
     text = "CAB FAN", nr = 2, text_1="L", text_2="R",
     cond_1 = function() return get(Cab_fan_fwd_running) == 0 end,
     cond_2 = function() return get(Cab_fan_aft_running) == 0 end
    },
    {
     text = "ZONE REGUL", nr = 1,
     cond_1 = function() return (get(FAILURE_AIRCOND_REG_1) == 1 and get(FAILURE_AIRCOND_REG_2) == 1) or ((get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0) and (get(AC_bus_2_pwrd) == 0 or get(DC_ess_bus_pwrd) == 0)) end,
    },


}


function ECAM_status_get_inop_sys()

    local messages = {}

    -- FBW
    if base_cond() and get(FBW_total_control_law) < FBW_NORMAL_LAW then
        table.insert(messages, "F/CTL PROT")
    end

    for l,x in pairs(inop_systems_desc) do
        if x.all_cond == nil or x.all_cond() then
            if x.nr == 1 and x.cond_1() then
                table.insert(messages, x.text)
            elseif x.nr == 2 and (x.cond_1() or x.cond_2()) then
                local t1 = x.text_1 and x.text_1 or "1"
                local t2 = x.text_2 and x.text_2 or "2"
                local msg = put_inop_sys_msg_2(messages, x.cond_1(), x.cond_2(), t1, t2, x.text)
                if x.text_after then msg = msg .. " " .. x.text_after end
                table.insert(messages, msg)
            elseif x.nr == 3 and (x.cond_1() or x.cond_2() or x.cond_3()) then
                local t1 = x.text_1 and x.text_1 or "1"
                local t2 = x.text_2 and x.text_2 or "2"
                local t3 = x.text_3 and x.text_3 or "3"
                local msg = put_inop_sys_msg_3(messages, x.cond_1(), x.cond_2(), x.cond_3(), t1, t2, t3, x.text)
                if x.text_after then msg = msg .. " " .. x.text_after end
                table.insert(messages, msg)
            end
        end
    end



    return messages
end
    
