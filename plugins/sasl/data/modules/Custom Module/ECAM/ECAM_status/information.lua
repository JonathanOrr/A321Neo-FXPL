
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
            return get(FBW_total_control_law) == FBW_DIRECT_LAW
      end },
    { text="USE SPD BRK WITH CARE", cond=function() 
            return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end },
    
    -- AUTO FLT
    { text="BOTH PFD ON SAME FAC", cond=function() return
           (get(FAC_1_status) == 0 and get(FAC_2_status) == 0) and get(EWD_flight_phase) >= PHASE_ABOVE_80_KTS and get(EWD_flight_phase) <= PHASE_BELOW_80_KTS
    end },

    { text="FMS PRED UNRELIABLE", cond=function() return
           get(AC_bus_1_pwrd) == 0 or get(DC_bus_2_pwrd) == 0
    end },
    
    -- FUEL
    { text="CTR TK FUEL UNUSABLE", cond=function() return
           get(DC_bus_1_pwrd)==0 and get(DC_bus_2_pwrd) == 0
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
           get(AC_bus_1_pwrd) == 0
    end },

    { text="SLATS/FLAPS SLOW", cond=function() return
           get(DC_bus_2_pwrd) == 0 or
           get(DC_ess_bus_pwrd) == 0
    end },
    
    

    { text="CAT 2 ONLY", cond=function() return
           get(AC_bus_1_pwrd) == 0
    end },

    { text="CAT 3 SINGLE ONLY", cond=function() return
           (get(FAC_1_status) == 0 or 
            get(FAC_2_status) == 0 or
            get(FAILURE_FCTL_YAW_DAMPER) == 1 or
            get(FAILURE_GEAR_AUTOBRAKES) == 1 or
            get(Brakes_mode) == 2 or
            get(DC_bus_1_pwrd) == 0 or
            get(DC_bus_2_pwrd) == 0 or
            get(DC_ess_bus_pwrd) == 0 or
            get(DC_shed_ess_pwrd) == 0 or
            (get(Gen_1_pwr) == 0 and get(Gen_2_pwr) == 0) or
            get(FAILURE_ELEC_TR_1) == 1 or
            get(FAILURE_ELEC_TR_2) == 1
           )
           and not
           -- Put CAT2 conditions here
           (get(AC_bus_1_pwrd) == 0)
    end },

    -- ELEC

    { text="APU BAT START NOT AVAIL", cond=function() return
           get(XP_Battery_1) == 0
        or get(XP_Battery_2) == 0
        or get(FAILURE_ELEC_battery_1) == 1
        or get(FAILURE_ELEC_battery_2) == 1
        or get(FAILURE_ELEC_DC_BAT_bus) == 1
        or (get(DC_bus_1_pwrd)==0 and get(DC_bus_2_pwrd) == 0)
    end
    },
    
    { text="ENG 1 APPR IDLE ONLY", cond=function() return
           (get(FAILURE_AIRCOND_REG_1) == 1 and get(FAILURE_AIRCOND_REG_2) == 1) or get(DC_ess_bus_pwrd) == 0
    end },
    
    { text="ENG 2 APPR IDLE ONLY", cond=function() return
           (get(FAILURE_AIRCOND_REG_1) == 1 and get(FAILURE_AIRCOND_REG_2) == 1) or get(AC_bus_2_pwrd) == 0 or get(DC_bus_2_pwrd) == 0 or get(DC_ess_bus_pwrd) == 0
    end },

    { text="L/G CONTROL NOT AVAIL", cond=function() return
           get(DC_bus_2_pwrd) == 0 and get(DC_ess_bus_pwrd) == 0
    end },
    
    
    { text="NORM BRK ONLY", cond=function() return
           get(Brakes_accumulator) < 1 and get(Hydraulic_Y_press) > 1450
    end },
    
    { text="BRK Y ACCU PR ONLY", cond=function() return
           get(Brakes_mode) == 3 and get(Brakes_accumulator) > 1
    end },
        
    { text="ALTN Y BRK WITH A/SKID", cond=function() return
           get(Brakes_mode) == 2
    end },

    -- AIR
    { text="ONE PACK ONLY IF WAI ON", cond=function() return 
           get(FAILURE_BLEED_ENG_1_hi_press) == 1
        or get(FAILURE_BLEED_ENG_2_hi_press) == 1
        or get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 1
        or get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 1
    end },
    
    { text="AIR PRESS LOW AT IDLE", cond=function() return 
           get(FAILURE_BLEED_HP_1_VALVE_STUCK) == 1
        or get(FAILURE_BLEED_HP_2_VALVE_STUCK) == 1
    end },
    
    { text="CKPT AT FIXED TEMP", cond=function() return 
           get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1
    end },

    { text="CAB AT FIXED TEMP", cond=function() return
           get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 or get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0
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
           get(FAILURE_AIRCOND_REG_1) == 1 and get(FAILURE_AIRCOND_REG_2) == 1
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
