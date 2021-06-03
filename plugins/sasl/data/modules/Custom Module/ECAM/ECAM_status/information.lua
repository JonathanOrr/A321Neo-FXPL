-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
local function is_bleed_fault()
       return (get(L_bleed_press) > 57 
       or get(L_bleed_temp) > 270) 
       or (get(R_bleed_press) > 57 or get(R_bleed_temp) > 270) 
       or get(FAILURE_BLEED_ENG_1_LEAK) == 1 
       or get(FAILURE_BLEED_ENG_2_LEAK) == 1 
       or get(FAILURE_BLEED_WING_L_LEAK) == 1
       or get(FAILURE_BLEED_WING_R_LEAK) == 1 
       or get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1
end
local function door_open_in_flight()
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
   
   local function dc_in_emergency_config()
       return get(DC_ess_bus_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 and get(DC_bus_1_pwrd) == 0
   end
   
   local function elec_in_emer_config()
       local condition =  ((get(Gen_1_pwr) == 0 or get(Gen_1_line_active) == 1) and get(Gen_2_pwr) ==0 and get(Gen_APU_pwr) == 0 and get(Gen_EXT_pwr) == 0)
           condition = condition and not (get(Eng_is_failed, 1) and get(Eng_is_failed, 2))
       return condition
   end
   
   local function engine_shuts_down()
       return (get(Engine_1_master_switch) == 0 and get(EWD_flight_phase) >= PHASE_ABOVE_80_KTS and get(EWD_flight_phase) <= PHASE_TOUCHDOWN)
       or ((get(EWD_flight_phase) < 3 or get(EWD_flight_phase) > 8) and get(Fire_pb_ENG1_status) == 1)
   end
   
   local function spdbrk_3_and_4_fault() --fcom 5231
       return get(FAILURE_FCTL_LSPOIL_3) == 1 and get(FAILURE_FCTL_LSPOIL_4) == 1 or 
       get(FAILURE_FCTL_RSPOIL_3) == 1 and get(FAILURE_FCTL_RSPOIL_4) == 1
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
   
   
   local function adr_disagrees_on_stuff()
       return adirs_pfds_disagree_on_hdg() or adirs_pfds_disagree_on_alt() or adirs_pfds_disagree_on_ias() or adirs_pfds_disagree_on_att()
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
   
   local function one_or_more_spoiler_is_fully_extended_in_speedbrake_fault() --fcom 5231
       return 
       (get(Left_spoiler_1) >= 25 or 
       get(Left_spoiler_2) >= 25 or 
       get(Left_spoiler_3) >= 25 or 
       get(Left_spoiler_4) >= 25 or 
       get(Left_spoiler_5) >= 25 or 
       get(Right_spoiler_1) >= 25 or 
       get(Right_spoiler_2) >= 25 or 
       get(Right_spoiler_3) >= 25 or 
       get(Right_spoiler_4) >= 25 or 
       get(Right_spoiler_5) >= 25) and
       spoilers_are_fucked()
   end
   
   local function stabliser_is_jammed()
       return get(FAILURE_FCTL_THS_MECH) == 1
   end
   
   local function fwc_1_and_2_fault()
       return get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1
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

local inf_messages = {

    -- Primary
    { text="ALTN LAW : PROT LOST", cond=function() 
            return get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
      end },
    { text="WHEN L/G DN : DIRECT LAW", cond=function() 
            return get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
      end },
    { text="DIRECT LAW", cond=function() 
            return get(FBW_total_control_law) == FBW_DIRECT_LAW
      end },
    { text="MANEUVER WITH CARE", cond=function() 
       return get(FBW_total_control_law) == FBW_DIRECT_LAW or
       is_bleed_fault() or
       get(FAILURE_BLEED_APU_LEAK) == 1 or
       get(DC_shed_ess_pwrd) == 0 or
       engine_shuts_down() or
       get(FBW_total_control_law) == FBW_DIRECT_LAW or
       stabliser_is_jammed() or
       Y_is_low_pressure() and B_is_low_pressure() or
       G_is_low_pressure() and B_is_low_pressure() or
       triple_adr_failure()
      end },
    { text="USE SPD BRK WITH CARE", cond=function() 
            return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end },

    -- AUTO FLT

    { text="FLS LIMITED TO F-APP + RAW", cond=function() return
       get(AC_bus_1_pwrd) == 0 or
       get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
       get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 or 
       get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1 or 
       get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[3]) == 1 or
       (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
       (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT) or
       (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT)
    end },
    
    { text="IR (AFFECTED) MAY BE AVAIL IN ATT", cond=function() return
           (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
           (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT) or
           (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT)
    end },

    { text="BOTH PFD ON SAME FAC", cond=function() return
       (
           (get(FAC_1_status) == 0 and get(FAC_2_status) == 0) and get(EWD_flight_phase) >= PHASE_ABOVE_80_KTS and get(EWD_flight_phase) <= PHASE_BELOW_80_KTS or
           get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1 or 
           get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[3]) == 1 or
           get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
           get(DC_ess_bus_pwrd) == 0)
           and not 
           (
              get(FAILURE_FCTL_FAC_1) == 1 and get(FAILURE_FCTL_FAC_2) == 1
           )
    end },

    { text="FMS PRED UNRELIABLE", cond=function() return
           get(AC_bus_1_pwrd) == 0 or get(DC_bus_2_pwrd) == 0 or
           get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
           get(FAILURE_FCTL_ELAC_1) == 1 or get(FAILURE_FCTL_ELAC_2) == 1 or
           get(Slats_ecam_amber) == 1 or get(Flaps_ecam_amber) == 1 or
           get(FAILURE_FCTL_LAIL) == 1 or get(FAILURE_FCTL_RAIL) == 1 or
           get(FAILURE_HYD_B_pump) == 1 or
           get(FAILURE_HYD_B_low_air) == 1 or
           get(Hydraulic_B_qty) < 0.31 or
           get(FAILURE_HYD_B_R_overheat) == 1 or
           get(FAILURE_HYD_G_low_air) == 1 or
           get(Hydraulic_G_qty) < 0.18 or
           get(FAILURE_HYD_G_R_overheat) == 1 or
           get(FAILURE_HYD_Y_E_overheat) == 1 or
           get(FAILURE_HYD_Y_low_air) == 1 or
           get(Hydraulic_Y_qty) < 0.18 or
           get(FAILURE_HYD_Y_R_overheat) == 1 or
           get(FAILURE_HYD_Y_low_air) == 1 and get(FAILURE_HYD_B_low_air) == 1 or
           get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_B_low_air) == 1 or
           get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_Y_low_air) == 1
    end },
    
    -- FUEL
    { text="CTR TK FUEL UNUSABLE", cond=function() return
           get(DC_bus_1_pwrd)==0 and get(DC_bus_2_pwrd) == 0 or
           get(FAILURE_FUEL, C_TK_XFR_1) == 1 and get(FAILURE_FUEL, C_TK_XFR_2) == 1 
    end },

    { text="CTR TK FUEL: 2T UNUSABLE", cond=function() return
       get(DC_bus_1_pwrd)==0 and get(DC_bus_2_pwrd) == 0 or
       get(FAILURE_FUEL, C_TK_XFR_1) == 1 and get(FAILURE_FUEL, C_TK_XFR_2) == 1 
    end },

    { text="CTR TK FEED: MAN ONLY", cond=function() return
       get(Slats_ecam_amber) == 1 or
       not PB.ovhd.fuel_MODE_SEL.status_top and not PB.ovhd.fuel_MODE_SEL.status_bottom and get(Fuel_quantity[tank_CENTER]) > 250 and (get(Fuel_quantity[tank_RIGHT]) < 5000 or get(Fuel_quantity[tank_LEFT]) < 5000) or
       get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and get(FAILURE_FUEL, L_TK_PUMP_2) == 1 or
       (get(Fuel_quantity[tank_LEFT]) < 750 or get(Fuel_quantity[tank_RIGHT]) < 750) and
       not (get(Fuel_quantity[tank_LEFT]) < 750 and get(Fuel_quantity[tank_RIGHT]) < 750)
end },

    { text="FUEL CONSUMPT INCRSD", cond=function() return
       --get(FAILURE_FCTL_ELAC_1) == 1 or get(FAILURE_FCTL_ELAC_2) == 1 or
       get(Slats_ecam_amber) == 1 or get(Flaps_ecam_amber) == 1 or
       get(AC_bus_1_pwrd) == 0 or
       get(DC_bus_2_pwrd) == 0 and get(DC_ess_bus_pwrd) == 0 or
       get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
       get(DC_ess_bus_pwrd) == 0 or
       get(FAILURE_FCTL_ELAC_1) == 1 or
       get(FAILURE_FCTL_ELAC_2) == 1
       --elec_in_emer_config() --this function is not local, fix later
       --get(FAILURE_ENG_COMP_VANE, 1) == 1 --same thing
       --spoilers_are_fucked() --same thing
       --blue_pump_low_pr_or_ovht()
       --get(FAILURE_HYD_B_low_air) == 1
       --get(FAILURE_HYD_G_low_air) == 1
       --get(Hydraulic_G_qty) < 0.18
       --get(FAILURE_HYD_G_R_overheat) == 1
       --get(FAILURE_HYD_Y_low_air) == 1
       --get(Hydraulic_Y_qty) < 0.18
       --Y_is_low_pressure() and B_is_low_pressure()
       -- G_is_low_pressure() and B_is_low_pressure()
       --G_is_low_pressure() and Y_is_low_pressure() 
end },

    -- ENG
    { text="ENG 1 SLOW RESPONSE", cond=function() return
           get(FAILURE_ENG_COMP_VANE, 1)==1
    end },

    { text="ENG 2 SLOW RESPONSE", cond=function() return
           get(FAILURE_ENG_COMP_VANE, 2)==1
    end },

    { text="CONSIDER ENG 1 RELIGHT", cond=function() return
           get(FAILURE_ENG_STALL, 1)==1
    end },

    { text="CONSIDER ENG 2 RELIGHT", cond=function() return
           get(FAILURE_ENG_STALL, 2)==1
    end },

    { text="RISK OF ENG 1 HI EGT", cond=function() return
           get(FAILURE_ENG_SYS_FAULT, 1)==1
    end },

    { text="RISK OF ENG 2 HI EGT", cond=function() return
           get(FAILURE_ENG_SYS_FAULT, 2)==1
    end },


    -- F/CTL
    { text="SLATS SLOW", cond=function() return
           (get(AC_bus_1_pwrd) == 0 or
           get(Slats_ecam_amber) == 1 or
           get(FAILURE_HYD_B_pump) == 1 or
           get(FAILURE_HYD_B_low_air) == 1 or
           get(Hydraulic_B_qty) < 0.31 or
           get(FAILURE_HYD_B_R_overheat) == 1 or
           get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_Y_low_air) == 1
    )
           and not(
           get(DC_bus_2_pwrd) == 0 or
           get(DC_ess_bus_pwrd) == 0 or
           get(FAILURE_HYD_G_pump) == 1 or
           get(FAILURE_HYD_G_low_air) == 1 or
           get(Hydraulic_G_qty) < 0.18 or
           get(FAILURE_HYD_G_R_overheat) == 1 or
           get(FAILURE_HYD_Y_low_air) == 1 and get(FAILURE_HYD_B_low_air) == 1 or
           get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0)
    end },

    { text="SLATS/FLAPS SLOW", cond=function() return
           get(DC_bus_2_pwrd) == 0 or
           get(DC_ess_bus_pwrd) == 0 or
           get(FAILURE_HYD_G_pump) == 1 or
           get(FAILURE_HYD_G_low_air) == 1 or
           get(Hydraulic_G_qty) < 0.18 or
           get(FAILURE_HYD_G_R_overheat) == 1 or
           get(FAILURE_HYD_Y_low_air) == 1 and get(FAILURE_HYD_B_low_air) == 1 or
           get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0
    end },
    
    { text="FLAPS SLOW", cond=function() return
       (get(FAILURE_FCTL_SFCC_1) == 1 or get(FAILURE_FCTL_SFCC_2) == 1 or
       get(FAILURE_HYD_Y_E_overheat) == 1 or
       get(FAILURE_HYD_Y_pump) == 1 or
       get(FAILURE_HYD_Y_low_air) == 1 or
       get(Hydraulic_Y_qty) < 0.18 or
       get(FAILURE_HYD_Y_R_overheat) == 1 or
       get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_B_low_air) == 1
)
       and not(
       get(DC_bus_2_pwrd) == 0 or
       get(DC_ess_bus_pwrd) == 0 or
       get(FAILURE_HYD_G_pump) == 1 or
       get(FAILURE_HYD_G_low_air) == 1 or
       get(Hydraulic_G_qty) < 0.18 or
       get(FAILURE_HYD_G_R_overheat) == 1 or
       get(FAILURE_HYD_Y_low_air) == 1 and get(FAILURE_HYD_B_low_air) == 1 or
       get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0)
    end },

    { text="PITCH MECH BACK UP", cond=function() return
       get(FAILURE_FCTL_LELEV) == 1 and get(FAILURE_FCTL_RELEV) == 1
    end },

    { text="ROLL DIRECT LAW", cond=function() return
       get(FAILURE_FCTL_LELEV) == 1 and get(FAILURE_FCTL_RELEV) == 1
    end },

    { text="CAT 2 ONLY", cond=function() return
           (
                  get(AC_bus_1_pwrd) == 0 or
           get(FAILURE_radioalt_cap) == 1
       ) and not
       (
              get(FAILURE_FCTL_FAC_1) == 1 and get(FAILURE_FCTL_FAC_2) == 1
       )
    end },

    { text="CAT 3 SINGLE ONLY", cond=function() return
           (get(FAC_1_status) == 0 or 
            get(FAC_2_status) == 0 or
            get(FAILURE_GEAR_AUTOBRAKES) == 1 or
            get(Brakes_mode) == 2 or
            get(DC_bus_1_pwrd) == 0 or
            get(DC_bus_2_pwrd) == 0 or
            get(DC_ess_bus_pwrd) == 0 or
            get(DC_shed_ess_pwrd) == 0 or
            get(Gen_1_pwr) == 0 and get(Gen_2_pwr) == 0 or
            get(FAILURE_ELEC_TR_1) == 1 or
            get(FAILURE_ELEC_TR_2) == 1 or
            get(FAILURE_FCTL_ELAC_1) == 1 and get(FAILURE_FCTL_ELAC_2) == 0 or get(FAILURE_FCTL_ELAC_1) == 0 and get(FAILURE_FCTL_ELAC_2) == 1 or
            get(FAILURE_DISPLAY_FWC_1) == 1 or
            get(FAILURE_DISPLAY_FWC_1) == 1 or
            get(FAILURE_HYD_B_pump) == 1 or
            get(FAILURE_HYD_B_low_air) == 1 or
            get(Hydraulic_B_qty) < 0.31 or
            get(FAILURE_HYD_B_R_overheat) == 1 or
            get(FAILURE_HYD_G_pump) == 1 or
            get(FAILURE_HYD_G_low_air) == 1 or
            get(Hydraulic_G_qty) < 0.18 or
            get(FAILURE_HYD_G_R_overheat) == 1 or
            get(FAILURE_HYD_Y_E_overheat) == 1 or
            get(FAILURE_HYD_Y_pump) == 1 or
            get(FAILURE_HYD_Y_low_air) == 1 or
            get(Hydraulic_Y_qty) < 0.18 or
            get(FAILURE_HYD_Y_R_overheat) == 1 or
            get(FAILURE_ADR[1]) == 1 or get(FAILURE_ADR[2]) == 1 or get(FAILURE_ADR[3]) == 1 or
            adirs_pfds_disagree_on_ias() or
            get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
            get(FAILURE_FCTL_RUDDER_TRIM) == 1 --fcom 4423
            or get(FAILURE_FCTL_RUDDER_LIM ) == 1 --fcom 4429
           )
           and not
           -- Put CAT2 conditions here
           (get(AC_bus_1_pwrd) == 0 or
           get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_Y_low_air) or-- IT DOES NOT APPEAR ON DUAL HYD LOW PR
           get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_B_low_air) or
           get(FAILURE_HYD_Y_low_air) == 1 and get(FAILURE_HYD_B_low_air) or
           get(FAILURE_FCTL_FAC_1) == 1 and get(FAILURE_FCTL_FAC_2) == 1 --fcom 4412
           )
    end },

    -- ELEC

    { text="APU BAT START NOT AVAIL", cond=function() return
           get(XP_Battery_1) == 0 or
           get(XP_Battery_2) == 0 or
           get(FAILURE_ELEC_battery_1) == 1 or
           get(FAILURE_ELEC_battery_2) == 1 or
           get(FAILURE_ELEC_DC_BAT_bus) == 1 or
           get(DC_bus_1_pwrd)==0 and get(DC_bus_2_pwrd) == 0
    end
    },
    
    { text="ENG 1 APPR IDLE ONLY", cond=function() return
           (get(FAILURE_AIRCOND_REG_1) == 1 and get(FAILURE_AIRCOND_REG_2) == 1) or get(DC_ess_bus_pwrd) == 0 or
           get(Slats_ecam_amber) == 1 or get(Flaps_ecam_amber) == 1 or
           get(FAILURE_FCTL_SFCC_1) == 1 or get(FAILURE_FCTL_SFCC_2) == 1 or
           get(DC_ess_bus_pwrd) == 0
    end },
    
    { text="ENG 2 APPR IDLE ONLY", cond=function() return
           (get(FAILURE_AIRCOND_REG_1) == 1 and get(FAILURE_AIRCOND_REG_2) == 1) or get(AC_bus_2_pwrd) == 0 or get(DC_bus_2_pwrd) == 0 or get(DC_ess_bus_pwrd) == 0 or
           get(Slats_ecam_amber) == 1 or get(Flaps_ecam_amber) == 1 or
           get(FAILURE_FCTL_SFCC_1) == 1 or get(FAILURE_FCTL_SFCC_2) == 1 or
           get(AC_bus_1_pwrd) == 0 or
           get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
           get(DC_ess_bus_pwrd) == 0
    end },

    { text="L/G CONTROL NOT AVAIL", cond=function() return
           get(DC_bus_2_pwrd) == 0 and get(DC_ess_bus_pwrd) == 0 or
           get(FAILURE_HYD_G_pump) == 1
    end },
    
    
    { text="NORM BRK ONLY", cond=function() return
           get(Brakes_accumulator) < 1 and get(Hydraulic_Y_press) > 1450
    end },
    
    { text="BRK Y ACCU PR ONLY", cond=function() return
           get(Brakes_mode) == 3 and get(Brakes_accumulator) > 1 and Y_is_low_pressure() or
           get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_Y_low_air) == 1
    end },
        
    { text="ALTN Y BRK WITH A/SKID", cond=function() return
           get(Brakes_mode) == 2 or
           get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_B_low_air) == 1 and get(FAILURE_HYD_Y_low_air) == 1 or
           get(Hydraulic_G_qty) < 0.18 or
           get(FAILURE_HYD_G_R_overheat) == 1
    end },

    -- AIR
    { text="ONE PACK ONLY IF WAI ON", cond=function() return 
        get(FAILURE_BLEED_ENG_1_hi_press) == 1 or 
        get(FAILURE_BLEED_ENG_2_hi_press) == 1 or 
        get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 1 or 
        get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 1
    end },
    
    { text="AIR PRESS LOW AT IDLE", cond=function() return 
           get(FAILURE_BLEED_HP_1_VALVE_STUCK) == 1 or
           get(FAILURE_BLEED_HP_2_VALVE_STUCK) == 1
    end },
    
    { text="CKPT AT FIXED TEMP", cond=function() return 
           get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 or
           get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1
    end },

    { text="CAB AT FIXED TEMP", cond=function() return
           get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 or get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0 or
           get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 or
           get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 or
           get(AC_bus_1_pwrd) == 0 or
           get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0
    end },

    { text="PACK 1 AVAIL IN FLT", cond=function() return
        get(FAILURE_BLEED_PACK_1_REGUL_FAULT) == 1 and get(All_on_ground) == 1
    end },

    { text="PACK 2 AVAIL IN FLT", cond=function() return
        get(FAILURE_BLEED_PACK_2_REGUL_FAULT) == 1 and get(All_on_ground) == 1
    end },

    { text="X BLEED MAN CTL", cond=function() return
           get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1
    end },
    
    { text="PACKS AT FIXED TEMP", cond=function() return
           get(FAILURE_AIRCOND_REG_1) == 1 and get(FAILURE_AIRCOND_REG_2) == 1 or
           get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0
    end },
    { text="PACK 2 AT FIXED TEMP", cond=function() return
       get(AC_bus_1_pwrd) == 0
    end },
    
}


function ECAM_status_get_information()
    local messages = {}

    for l,x in pairs(inf_messages) do
        if x.cond() then
            table.insert(messages, x.text)
        end
    end

    return messages
end

function update()

end
