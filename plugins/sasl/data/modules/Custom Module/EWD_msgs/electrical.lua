include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- BATTERY RELATED
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- CAUTION: BATTERY OFF
----------------------------------------------------------------------------------------------------


MessageGroup_ELEC_BAT_OFF = {

    shown = false,

    text  = function(self)
                return "ELEC"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if ELEC_sys.batteries[1].switch_status == false and get(ELEC_sys.batteries[1].drs.failure) == 0 then
                    x = x .. "1"
                end
                if ELEC_sys.batteries[2].switch_status == false and get(ELEC_sys.batteries[2].drs.failure) == 0 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     BAT " .. x .. " OFF"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return (ELEC_sys.batteries[1].switch_status == false and get(ELEC_sys.batteries[1].drs.failure) == 0)
               or (ELEC_sys.batteries[2].switch_status == false and get(ELEC_sys.batteries[2].drs.failure) == 0)
    end,

    is_inhibited = function(self)
        return not(get(EWD_flight_phase) == PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_AIRBONE)
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: BATTERY FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_ELEC_BAT_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(ELEC_sys.batteries[1].drs.failure) == 1 then
                    x = x .. "1"
                end
                if get(ELEC_sys.batteries[2].drs.failure) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     BAT " .. x .. " FAULT"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return (get(ELEC_sys.batteries[1].drs.failure) == 1)
               or (get(ELEC_sys.batteries[2].drs.failure) == 1)
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}


----------------------------------------------------------------------------------------------------
-- WARNING: EMER CONFIG
----------------------------------------------------------------------------------------------------
Message_ELEC_RAT_MIN_SPD = {
    text = function(self)
        return " MIN RAT SPD.......140 KT"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return true
  end
}

Message_ELEC_GEN_1_2_OFF_ON = {
    text = function(self)
        return " - GEN 1+2....OFF THEN ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    already_switched_off = false,
    already_switched_on  = false,

    is_active = function(self)
        if Message_ELEC_GEN_1_2_OFF_ON.already_switched_off == false then
            Message_ELEC_GEN_1_2_OFF_ON.already_switched_off = ELEC_sys.generators[1].switch_status == false and ELEC_sys.generators[2].switch_status == false
        end
        if Message_ELEC_GEN_1_2_OFF_ON.already_switched_off == true and Message_ELEC_GEN_1_2_OFF_ON.already_switched_on == false then
            Message_ELEC_GEN_1_2_OFF_ON.already_switched_on = ELEC_sys.generators[1].switch_status == true and ELEC_sys.generators[2].switch_status == true
        end
      return not Message_ELEC_GEN_1_2_OFF_ON.already_switched_on
    end
}

Message_ELEC_GEN_1_2_OFF_ON_2 = {
    text = function(self)
        return " - GEN 1+2....OFF THEN ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    already_switched_off = false,
    already_switched_on  = false,
    
    is_active = function(self)
        if Message_ELEC_GEN_1_2_OFF_ON_2.already_switched_off == false then
            Message_ELEC_GEN_1_2_OFF_ON_2.already_switched_off = ELEC_sys.generators[1].switch_status == false and ELEC_sys.generators[2].switch_status == false and Message_ELEC_GEN_1_2_OFF_ON:is_active() == false
        end
        if Message_ELEC_GEN_1_2_OFF_ON_2.already_switched_off == true and Message_ELEC_GEN_1_2_OFF_ON_2.already_switched_on == false then
            Message_ELEC_GEN_1_2_OFF_ON_2.already_switched_on = ELEC_sys.generators[1].switch_status == true and ELEC_sys.generators[2].switch_status == true
        end
      return not Message_ELEC_GEN_1_2_OFF_ON_2.already_switched_on
    end
}

Message_ELEC_IF_UNSUCCESSFUL = {
    text = function(self)
        return " · IF UNSUCCESSFUL:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

  is_active = function(self)
      return Message_ELEC_BUS_TIE_OFF.is_active() or Message_ELEC_EMER_GEN_PWR.is_active() or Message_ELEC_ENG_MODE_SEL.is_active()
  end
}

Message_ELEC_BUS_TIE_OFF = {
    text = function(self)
        return " - BUS TIE............OFF"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return ELEC_sys.buses.bus_tie_pushbutton_status
    end
}

Message_ELEC_EMER_GEN_PWR = {
    text = function(self)
        return " - EMER ELEC PWR...MAN ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return ELEC_sys.generators[5].switch_status == false or get(is_RAT_out) == 0
    end
}

Message_ELEC_ENG_MODE_SEL = {
    text = function(self)
        return " - ENG MODE SEL.......IGN"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return get(Engine_mode_knob) ~= 1
    end
}

Message_ELEC_VHF_1_ATC_1 = {
    text = function(self) return " - VHF1/HF1/ATC1......USE" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}

Message_ELEC_APPR_NAVAID = {
    text = function(self) return " - APPR NAVAID....ON RMP1" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}

Message_ELEC_IR_2_3OFF = {
    text = function(self) return " - IR 2+3(IF IR1 OK)..OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Adirs_ir_is_ok[2]) == 1 or get(Adirs_ir_is_ok[3]) == 1 end
}

Message_ELEC_FUEL_GRAVITY_1 = {
    text = function(self) return " FUEL GRVTY FEED" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}

Message_ELEC_FUEL_GRAVITY_PROC = {
    text = function(self) return " PROC: GRVTY FUEL FEEDING" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}

Message_ELEC_BLOWER_OVRD = {
    text = function(self) return " - BLOWER............OVRD" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Ventilation_blower_override) == 0 end
}

Message_ELEC_EXTRACT_OVRD = {
    text = function(self) return " - EXTRACT...........OVRD" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Ventilation_extract_override) == 0 end
}

Message_ELEC_FAC_1_OFF_ON = {
    text = function(self)
        return " - FAC 1......OFF THEN ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    already_switched_off = false,
    already_switched_on  = false,

    is_active = function(self)
        if Message_ELEC_FAC_1_OFF_ON.already_switched_off == false then
            Message_ELEC_FAC_1_OFF_ON.already_switched_off = get(FAC_1_status) == 0
        end
        if Message_ELEC_FAC_1_OFF_ON.already_switched_off == true and Message_ELEC_FAC_1_OFF_ON.already_switched_on == false then
            Message_ELEC_FAC_1_OFF_ON.already_switched_on = get(FAC_1_status) == 1
        end
      return not Message_ELEC_FAC_1_OFF_ON.already_switched_on
    end
}

Message_ELEC_LDG_ELEV_ADJ = {
    text = function(self) return " LDG ELEV......MAN ADJUST" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}

MessageGroup_ELEC_EMER_CONFIG = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self) return "     EMER CONFIG" end,
            color = function(self) return COL_WARNING end,
            is_active = function(self) return true end
        },
        Message_ELEC_RAT_MIN_SPD,
        Message_ELEC_GEN_1_2_OFF_ON,
        Message_ELEC_IF_UNSUCCESSFUL,
        Message_ELEC_BUS_TIE_OFF,
        Message_ELEC_GEN_1_2_OFF_ON_2,
        Message_ELEC_EMER_GEN_PWR,
        Message_ELEC_ENG_MODE_SEL,
        Message_ELEC_APPR_NAVAID,
        Message_ELEC_VHF_1_ATC_1,
        Message_ELEC_IR_2_3OFF,
        Message_ELEC_FUEL_GRAVITY_1,
        Message_ELEC_FUEL_GRAVITY_PROC,
        Message_ELEC_FAC_1_OFF_ON,
        Message_ELEC_BLOWER_OVRD,
        Message_ELEC_EXTRACT_OVRD,
        Message_ELEC_LDG_ELEV_ADJ
        
        
    },


    land_asap = true,

    is_active = function(self)
        local condition =  ((get(Gen_1_pwr) == 0 or get(Gen_1_line_active) == 1) and get(Gen_2_pwr) ==0 and get(Gen_APU_pwr) == 0 and get(Gen_EXT_pwr) == 0) and not override_ELEC_always_on

        return condition
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
}


----------------------------------------------------------------------------------------------------
-- WARNING: ESS BUSES ON BAT
----------------------------------------------------------------------------------------------------

MessageGroup_ELEC_ESS_BUSES_ON_BAT = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self) return "     ESS BUSES ON BAT" end,
            color = function(self) return COL_WARNING end,
            is_active = function(self) return true end
        },
        Message_ELEC_RAT_MIN_SPD,
        Message_ELEC_EMER_GEN_PWR
    },

    land_asap = true,

    is_active = function(self)
        return ELEC_sys.buses.dc_ess_powered_by == 42 -- BAT_2
               or ELEC_sys.buses.ac_ess_powered_by == 21 -- Static inverter
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) <=4 or get(EWD_flight_phase) >= 8
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: AC BUS 1 FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_ELEC_AC_BUS_1_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self) return "     AC BUS 1 FAULT" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_ELEC_BLOWER_OVRD
    },

    is_active = function(self)
        return get(AC_bus_1_pwrd) == 0
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: AC BUS 2 FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_ELEC_AC_BUS_2_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self) return "     AC BUS 2 FAULT" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_ELEC_EXTRACT_OVRD
    },

    is_active = function(self)
        return get(AC_bus_2_pwrd) == 0
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
}



----------------------------------------------------------------------------------------------------
-- CAUTION: GEN 1 LINE OFF
----------------------------------------------------------------------------------------------------

MessageGroup_ELEC_EMER_GEN_1_LINE_OFF = {

    shown = false,

    text  = function(self)
                return "EMER"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self) return "     GEN 1 LINE OFF" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return get(Gen_1_line_active) == 1
    end,

    is_inhibited = function(self)
        return not(get(EWD_flight_phase) == PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_AIRBONE)
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: AC ESS BUS SHED FAULT
----------------------------------------------------------------------------------------------------
Message_ELEC_ATC_2_USE = {
    text = function(self) return " ATC2.................USE" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}

MessageGroup_ELEC_AC_BUS_ESS_SHED_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     AC ESS BUS SHED" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_ATC_2_USE
    },

    is_active = function()
        return get(AC_ess_shed_pwrd) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: DC BUS 1 FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_ELEC_DC_BUS_1_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     DC BUS 1 FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_BLOWER_OVRD,
        Message_ELEC_EXTRACT_OVRD
    },

    is_active = function()
        return get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: DC BUS 2 FAULT
----------------------------------------------------------------------------------------------------
Message_ELEC_AIR_DATA_SWTG_FO = {
    text = function(self) return " - AIR DATA SWTG......F/O" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(ADIRS_source_rotary_AIRDATA) ~= 1 end
}

Message_ELEC_BARO_REF_CHECK = {
    text = function(self) return " - BARO REF.........CHECK" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}

MessageGroup_ELEC_DC_BUS_2_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     DC BUS 2 FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_AIR_DATA_SWTG_FO,
        Message_ELEC_BARO_REF_CHECK
    },

    is_active = function()
        return get(DC_bus_2_pwrd) == 0 and get(DC_bus_1_pwrd) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: DC BUS 1+2 FAULT
----------------------------------------------------------------------------------------------------
Message_ELEC_BRK = {
    text = function(self) return " MAX BRK PR......1000 PSI" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}
MessageGroup_ELEC_DC_BUS_1_2_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     DC BUS 1 + 2 FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_BLOWER_OVRD,
        Message_ELEC_EXTRACT_OVRD,
        Message_ELEC_BARO_REF_CHECK,
        Message_ELEC_BRK
    },

    is_active = function()
        return get(DC_bus_2_pwrd) == 0 and get(DC_bus_1_pwrd) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: DC ESS BUS SHED
----------------------------------------------------------------------------------------------------
Message_ELEC_AVOID_ICE = {
    text = function(self) return " AVOID ICING CONDITIONS" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}
MessageGroup_ELEC_DC_ESS_BUS_SHED = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     DC ESS BUS SHED" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_EXTRACT_OVRD,
        Message_ELEC_AVOID_ICE
    },

    is_active = function()
        return get(DC_shed_ess_pwrd) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: DC ESS BUS FAULT
----------------------------------------------------------------------------------------------------
Message_ELEC_VHF_2_OR_3 = {
    text = function(self) return " - VHF 2 OR 3.........USE" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}
Message_ELEC_AUDIO_SWTG_SELECT = {
    text = function(self) return " - AUDIO SWTG......SELECT" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}
MessageGroup_ELEC_DC_ESS_BUS_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     DC ESS BUS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_VHF_2_OR_3,
        Message_ELEC_AUDIO_SWTG_SELECT,
        Message_ELEC_BARO_REF_CHECK
    },

    is_active = function()
        return get(DC_ess_bus_pwrd) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: AC ESS BUS FAULT
----------------------------------------------------------------------------------------------------
Message_ELEC_AC_ESS_ALTN = {
    text = function(self) return " - AC ESS FEED.......ALTN" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return ELEC_sys.buses.ac_ess_bus_pushbutton_status end
}

MessageGroup_ELEC_AC_BUS_ESS_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     AC ESS BUS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_AC_ESS_ALTN,
        Message_ELEC_ATC_2_USE
    },

    is_active = function()
        return get(AC_ess_bus_pwrd) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: DC BAT BUS FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_ELEC_DC_BAT_BUS_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     DC BAT BUS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(DC_bat_bus_pwrd) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: DC EMER CONFIG
----------------------------------------------------------------------------------------------------

MessageGroup_ELEC_DC_EMER_CONFIG = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     DC EMER CONFIG" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ELEC_EMER_GEN_PWR
    },

    land_asap = true,

    is_active = function()
        return get(DC_ess_bus_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 and get(DC_bus_1_pwrd) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: GEN 1/2 OFF
----------------------------------------------------------------------------------------------------


MessageGroup_ELEC_GEN_OFF = {

    shown = false,

    text  = function(self)
                return "ELEC"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if ELEC_sys.generators[1].switch_status == false and get(ELEC_sys.generators[1].drs.failure) == 0 then
                    x = x .. "1"
                end
                if ELEC_sys.generators[2].switch_status == false and get(ELEC_sys.generators[2].drs.failure) == 0 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     GEN " .. x .. " OFF"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return (ELEC_sys.generators[1].switch_status == false and get(ELEC_sys.generators[1].drs.failure) == 0)
               or (ELEC_sys.generators[2].switch_status == false and get(ELEC_sys.generators[2].drs.failure) == 0)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: GEN 1/2 FAULT
----------------------------------------------------------------------------------------------------

Message_ELEC_GEN_1_OFF_ON = {
    text = function(self)
        return " - GEN 1......OFF THEN ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    already_switched_off = false,
    already_switched_on  = false,

    is_active = function()
        if Message_ELEC_GEN_1_OFF_ON.already_switched_off == false then
            Message_ELEC_GEN_1_OFF_ON.already_switched_off = ELEC_sys.generators[1].switch_status == false
        end
        if Message_ELEC_GEN_1_OFF_ON.already_switched_off == true and Message_ELEC_GEN_1_OFF_ON.already_switched_on == false then
            Message_ELEC_GEN_1_OFF_ON.already_switched_on = ELEC_sys.generators[1].switch_status == true
        end
      return get(ELEC_sys.generators[1].drs.failure) == 1 and not Message_ELEC_GEN_1_OFF_ON.already_switched_on
    end
}

Message_ELEC_GEN_2_OFF_ON = {
    text = function(self)
        return " - GEN 2......OFF THEN ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    already_switched_off = false,
    already_switched_on  = false,

    is_active = function()
        if Message_ELEC_GEN_2_OFF_ON.already_switched_off == false then
            Message_ELEC_GEN_2_OFF_ON.already_switched_off = ELEC_sys.generators[2].switch_status == false
        end
        if Message_ELEC_GEN_2_OFF_ON.already_switched_off == true and Message_ELEC_GEN_2_OFF_ON.already_switched_on == false then
            Message_ELEC_GEN_2_OFF_ON.already_switched_on = ELEC_sys.generators[2].switch_status == true
        end
      return get(ELEC_sys.generators[2].drs.failure) == 1 and not Message_ELEC_GEN_2_OFF_ON.already_switched_on
    end
}

Message_ELEC_GEN_1_OFF = {
    text = function() return " - GEN 1..............OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(ELEC_sys.generators[1].drs.failure) == 1 and ELEC_sys.generators[1].switch_status end
}
Message_ELEC_GEN_2_OFF = {
    text = function() return " - GEN 2..............OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(ELEC_sys.generators[2].drs.failure) == 1 and ELEC_sys.generators[2].switch_status end
}


Message_ELEC_IF_UNSUCCESSFUL_GEN_FAULT = {
    text = function(self)
        return " · IF UNSUCCESSFUL:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

  is_active = function(self)
      return Message_ELEC_GEN_1_OFF.is_active() or Message_ELEC_GEN_2_OFF.is_active()
  end
}


MessageGroup_ELEC_GEN_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(ELEC_sys.generators[1].drs.failure) == 1 then
                    x = x .. "1"
                end
                if get(ELEC_sys.generators[2].drs.failure) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     GEN " .. x .. " FAULT"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_ELEC_GEN_1_OFF_ON,
        Message_ELEC_GEN_2_OFF_ON,
        Message_ELEC_IF_UNSUCCESSFUL_GEN_FAULT,
        Message_ELEC_GEN_1_OFF,
        Message_ELEC_GEN_2_OFF,
        
    },

    is_active = function(self)
        return (get(ELEC_sys.generators[1].drs.failure) == 1)
               or (get(ELEC_sys.generators[2].drs.failure) == 1)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON , PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: APU GEN FAULT
----------------------------------------------------------------------------------------------------

Message_ELEC_APU_GEN_OFF_ON = {
    text = function(self)
        return " - APU GEN....OFF THEN ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    already_switched_off = false,
    already_switched_on  = false,

    is_active = function()
        if Message_ELEC_APU_GEN_OFF_ON.already_switched_off == false then
            Message_ELEC_APU_GEN_OFF_ON.already_switched_off = ELEC_sys.generators[3].switch_status == false
        end
        if Message_ELEC_APU_GEN_OFF_ON.already_switched_off == true and Message_ELEC_APU_GEN_OFF_ON.already_switched_on == false then
            Message_ELEC_APU_GEN_OFF_ON.already_switched_on = ELEC_sys.generators[3].switch_status == true
        end
      return get(ELEC_sys.generators[3].drs.failure) == 1 and not Message_ELEC_APU_GEN_OFF_ON.already_switched_on
    end
}

Message_ELEC_APU_GEN_OFF = {
    text = function() return " - APU GEN............OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return ELEC_sys.generators[3].switch_status end
}


Message_ELEC_IF_UNSUCCESSFUL_APU_GEN_FAULT = {
    text = function(self)
        return " · IF UNSUCCESSFUL:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

  is_active = function(self)
      return Message_ELEC_APU_GEN_OFF.is_active()
  end
}


MessageGroup_ELEC_APU_GEN_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                return "     APU GEN FAULT"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_ELEC_APU_GEN_OFF_ON,
        Message_ELEC_IF_UNSUCCESSFUL_APU_GEN_FAULT,
        Message_ELEC_APU_GEN_OFF
    },

    is_active = function(self)
        return (get(ELEC_sys.generators[3].drs.failure) == 1)
    end,

    is_inhibited = function(self)
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: STATIC INV FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_ELEC_STATIC_INV_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     STATIC INV FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_ELEC_STATIC_INV) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: TR 1/2 FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_ELEC_TR_1_2_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(FAILURE_ELEC_TR_1) == 1 then
                    x = x .. "1"
                end
                if get(FAILURE_ELEC_TR_2) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     TR " .. x .. " FAULT"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },


    is_active = function()
        return get(FAILURE_ELEC_TR_1) == 1 or get(FAILURE_ELEC_TR_2) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: TR ESS FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_ELEC_TR_ESS_FAULT = {
    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "     TR ESS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_ELEC_TR_ESS) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: IDG LO PR
----------------------------------------------------------------------------------------------------
Message_ELEC_IDG_1_OFF_LOPR = {
    text = function(self) return " IDG1.................OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return (get(FAILURE_ELEC_IDG1_oil) == 1 and ELEC_sys.generators[1].idg_status) end
}
Message_ELEC_IDG_2_OFF_LOPR = {
    text = function(self) return " IDG2.................OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return (get(FAILURE_ELEC_IDG2_oil) == 1 and ELEC_sys.generators[2].idg_status) end
}

MessageGroup_ELEC_IDG_LO_PR = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(FAILURE_ELEC_IDG1_oil) == 1 then
                    x = x .. "1"
                end
                if get(FAILURE_ELEC_IDG2_oil) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     IDG " .. x .. " OIL LO PR"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_ELEC_IDG_1_OFF_LOPR,
        Message_ELEC_IDG_2_OFF_LOPR
    },

    is_active = function()
        return get(FAILURE_ELEC_IDG1_oil) == 1 or get(FAILURE_ELEC_IDG2_oil) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ELEC_PWR, PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN, PHASE_FINAL, PHASE_TOUCHDOWN, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: IDG OVHT
----------------------------------------------------------------------------------------------------
Message_ELEC_IDG_1_OFF_OVHT = {
    text = function(self) return " IDG1.................OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return (get(ELEC_sys.generators[1].drs.idg_temp)>185 and ELEC_sys.generators[1].idg_status) end
}
Message_ELEC_IDG_2_OFF_OVHT = {
    text = function(self) return " IDG2.................OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return (get(ELEC_sys.generators[2].drs.idg_temp)>185 and ELEC_sys.generators[2].idg_status) end
}
MessageGroup_ELEC_IDG_OVHT = {

    shown = false,

    text  = function(self)
                return "ELEC"   
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(ELEC_sys.generators[1].drs.idg_temp)>185 then
                    x = x .. "1"
                end
                if get(ELEC_sys.generators[2].drs.idg_temp)>185 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     IDG " .. x .. " OIL OVHT"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_ELEC_IDG_1_OFF_OVHT,
        Message_ELEC_IDG_2_OFF_OVHT
    },

    is_active = function()
        return get(ELEC_sys.generators[1].drs.idg_temp)>185 or get(ELEC_sys.generators[2].drs.idg_temp)>185
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ELEC_PWR, PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN, PHASE_FINAL, PHASE_TOUCHDOWN, PHASE_2ND_ENG_OFF})
    end
}

