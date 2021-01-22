include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- BLUE SYSTEM
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- CAUTION: B ELEC PUMP OVHT
----------------------------------------------------------------------------------------------------

Message_HYD_TURN_OFF_B = {
    text = function()
        return " - BLUE ELEC PUMP.....OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return not PB.ovhd.hyd_elec_B.status_bottom
  end
}

MessageGroup_HYD_ELEC_PUMP_B_OVHT = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    B ELEC PUMP OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_B
    },

    is_active = function()
        return get(FAILURE_HYD_B_E_overheat) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B RSVR OVHT
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_B_RSVR_OVHT = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    B RSVR OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_B
    },

    is_active = function()
        return get(FAILURE_HYD_B_R_overheat) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B LO LVL
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_B_RSVR_LO_LVL = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    B RSVR LO LVL" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_B
    },

    is_active = function()
        return get(Hydraulic_B_qty) < 0.31
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B RSVR LO AIR PR
----------------------------------------------------------------------------------------------------


Message_HYD_IF_B_PRESS_FLUCTUATE = {
    text = function()
        return " · IF PRESS FLUCTUATES:"
    end,

    color = function()
        return COL_REMARKS
    end,

  is_active = function()
      return Message_HYD_TURN_OFF_B:is_active()
  end
}


MessageGroup_HYD_B_RSVR_LO_AIR_PRESS = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    B RSVR LO AIR PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_IF_B_PRESS_FLUCTUATE,
        Message_HYD_TURN_OFF_B
    },

    is_active = function()
        return get(FAILURE_HYD_B_low_air) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B SYS LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_B_SYS_LO_PR = {
    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    B SYS LO PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    already_trig = false,

    is_active = function()
        if get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF then
            return  -- Not a valid message in these phases
        end
    
        if get(Hydraulic_B_press) <= 1450 then
            MessageGroup_HYD_B_SYS_LO_PR.already_trig = true
            return true
        elseif MessageGroup_HYD_B_SYS_LO_PR.already_trig and get(Hydraulic_B_press) < 1750 then
            return true
        else
            MessageGroup_HYD_B_SYS_LO_PR.already_trig = false
            return false
        end
    end,

    is_inhibited = function()
        return not(get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_AIRBONE or
                (get(EWD_flight_phase) == PHASE_1ST_ENG_ON and get(Engine_1_avail) == 1
                and get(Engine_2_avail) == 1))

    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B ELEC PUMP LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_B_ELEC_PUMP_LO_PR = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    B ELEC PUMP LO PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_B
    },

    is_active = function()
        return get(FAILURE_HYD_B_pump) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GREEN SYSTEM
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Message_HYD_TURN_OFF_PTU = {
    text = function()
        return " - PTU................OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return not PB.ovhd.hyd_PTU.status_bottom
  end
}


Message_HYD_TURN_OFF_G = {
    text = function()
        return " - GREEN ENG 1 PUMP...OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return not PB.ovhd.hyd_eng1.status_bottom
  end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G RSVR OVHT
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_RSVR_OVHT = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    G RSVR OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_G
    },

    is_active = function()
        return get(FAILURE_HYD_G_R_overheat) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G LO LVL
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_RSVR_LO_LVL = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    G RSVR LO LVL" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_G
    },

    is_active = function()
        return get(Hydraulic_G_qty) < 0.18
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G RSVR LO AIR PR
----------------------------------------------------------------------------------------------------


Message_HYD_IF_G_PRESS_FLUCTUATE = {
    text = function()
        return " · IF PRESS FLUCTUATES:"
    end,

    color = function()
        return COL_REMARKS
    end,

  is_active = function()
      return Message_HYD_TURN_OFF_G:is_active() or Message_HYD_TURN_OFF_PTU:is_active()
  end
}


MessageGroup_HYD_G_RSVR_LO_AIR_PRESS = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    G RSVR LO AIR PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_IF_G_PRESS_FLUCTUATE,
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_G
    },

    is_active = function()
        return get(FAILURE_HYD_G_low_air) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G SYS LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_SYS_LO_PR = {
    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    G SYS LO PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    already_trig = false,

    is_active = function()
        if get(Hydraulic_G_press) <= 1450 then
            MessageGroup_HYD_G_SYS_LO_PR.already_trig = true
            return true
        elseif MessageGroup_HYD_G_SYS_LO_PR.already_trig and get(Hydraulic_G_press) < 1750 then
            return true
        else
            MessageGroup_HYD_G_SYS_LO_PR.already_trig = false
            return false
        end
    end,

    is_inhibited = function()
        return not(get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_AIRBONE or
                (get(EWD_flight_phase) == PHASE_1ST_ENG_ON and get(Engine_1_avail) == 1
                and get(Engine_2_avail) == 1))

    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G ENG 1 PUMP LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_ENG1_PUMP_LO_PR = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    G ENG 1 PUMP LO PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_G
    },

    is_active = function()
        return get(FAILURE_HYD_G_pump) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- YELLOW SYSTEM
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- CAUTION: Y ELEC PUMP OVHT
----------------------------------------------------------------------------------------------------

Message_HYD_TURN_OFF_ENG2_Y = {
    text = function()
        return " - YELLOW ENG2 PUMP...OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return not PB.ovhd.hyd_eng2.status_bottom
  end
}

Message_HYD_TURN_OFF_ELEC_Y = {
    text = function()
        return " - YELLOW ELEC PUMP...OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return PB.ovhd.hyd_elec_B.status_bottom
  end
}

MessageGroup_HYD_ELEC_PUMP_Y_OVHT = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    Y ELEC PUMP OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_ELEC_Y
    },

    is_active = function()
        return get(FAILURE_HYD_Y_E_overheat) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

MessageGroup_HYD_ELEC_PUMP_Y_FAIL = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    Y ELEC PUMP FAIL" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_ELEC_Y
    },

    is_active = function()
        return get(FAILURE_HYD_Y_E_pump) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: Y RSVR OVHT
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_Y_RSVR_OVHT = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    Y RSVR OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_ENG2_Y,
        Message_HYD_TURN_OFF_ELEC_Y
    },

    is_active = function()
        return get(FAILURE_HYD_Y_R_overheat) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: Y LO LVL
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_Y_RSVR_LO_LVL = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    Y RSVR LO LVL" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_ENG2_Y,
        Message_HYD_TURN_OFF_ELEC_Y
    },

    is_active = function()
        return get(Hydraulic_Y_qty) < 0.18
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: Y RSVR LO AIR PR
----------------------------------------------------------------------------------------------------


Message_HYD_IF_Y_PRESS_FLUCTUATE = {
    text = function()
        return " · IF PRESS FLUCTUATES:"
    end,

    color = function()
        return COL_REMARKS
    end,

  is_active = function()
      return Message_HYD_TURN_OFF_ENG2_Y:is_active() or Message_HYD_TURN_OFF_PTU:is_active() or
      Message_HYD_TURN_OFF_ELEC_Y:is_active()
  end
}


MessageGroup_HYD_Y_RSVR_LO_AIR_PRESS = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    Y RSVR LO AIR PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_IF_Y_PRESS_FLUCTUATE,
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_ENG2_Y,
        Message_HYD_TURN_OFF_ELEC_Y
    },

    is_active = function()
        return get(FAILURE_HYD_Y_low_air) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: Y SYS LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_Y_SYS_LO_PR = {
    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    Y SYS LO PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    already_trig = false,

    is_active = function()
        if get(Hydraulic_Y_press) <= 1450 then
            MessageGroup_HYD_Y_SYS_LO_PR.already_trig = true
            return true
        elseif MessageGroup_HYD_Y_SYS_LO_PR.already_trig and get(Hydraulic_Y_press) < 1750 then
            return true
        else
            MessageGroup_HYD_Y_SYS_LO_PR.already_trig = false
            return false
        end
    end,

    is_inhibited = function()
        return not(get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_AIRBONE or
                (get(EWD_flight_phase) == PHASE_1ST_ENG_ON and get(Engine_1_avail) == 1
                and get(Engine_2_avail) == 1))

    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: Y ENG 2 PUMP LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_Y_ENG2_PUMP_LO_PR = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    Y ENG 2 PUMP LO PR" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_ENG2_Y
    },

    is_active = function()
        return get(FAILURE_HYD_Y_pump) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- EXTRAS
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- CAUTION: PTU FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_PTU_FAULT = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    PTU FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_PTU
    },

    is_active = function()
        return get(FAILURE_HYD_PTU) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS 
               or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL
               or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_BELOW_80_KTS
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: RAT FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_RAT_FAULT = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    RAT FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_HYD_RAT) == 1
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS 
               or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL
               or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_BELOW_80_KTS
    end
}


----------------------------------------------------------------------------------------------------
-- WARNING: B + Y SYS LO PR
----------------------------------------------------------------------------------------------------

Message_HYD_TURN_OFF_ELEC_Y_IF_ENG_FAIL = {
    text = function()
        return " - YELLOW ELEC PUMP....ON"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return MessageGroup_HYD_Y_ENG2_PUMP_LO_PR:is_active() and not PB.ovhd.hyd_elec_Y.status_bottom
  end
}

Message_HYD_RAT_MAN_ON_IF_B_LOST = {
    text = function()
        return " - RAT.............MAN ON"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return MessageGroup_HYD_B_ELEC_PUMP_LO_PR:is_active() and get(is_RAT_out) == 0
  end
}

Message_HYD_RAT_MIN_ON_IF_B_LOST = {
    text = function()
        return " MIN RAT SPD.......140 KT"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return MessageGroup_HYD_B_ELEC_PUMP_LO_PR:is_active()
  end
}

Message_HYD_MANEUVER_WITH_CARE = {
    text = function()
        return " MANEUVER WITH CARE"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return true
  end
}


MessageGroup_HYD_B_AND_Y_LO_PR = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    B + Y SYS LO PR" end,
            color = function() return COL_WARNING end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_ELEC_Y_IF_ENG_FAIL,
        Message_HYD_RAT_MAN_ON_IF_B_LOST,
        Message_HYD_RAT_MIN_ON_IF_B_LOST,
        Message_HYD_TURN_OFF_ENG2_Y,
        Message_HYD_TURN_OFF_B,
        Message_HYD_MANEUVER_WITH_CARE
        
    },

    land_asap = true,

    is_active = function()
        return MessageGroup_HYD_Y_SYS_LO_PR:is_active() and MessageGroup_HYD_B_SYS_LO_PR:is_active()
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (get(EWD_flight_phase) == PHASE_1ST_ENG_ON and (get(Engine_1_avail) == 0 or get(Engine_2_avail) == 0))
    end
}

----------------------------------------------------------------------------------------------------
-- WARNING: G + Y SYS LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_AND_Y_LO_PR = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    G + Y SYS LO PR" end,
            color = function() return COL_WARNING end,
            is_active = function() return true end
        },
        Message_HYD_TURN_OFF_ELEC_Y_IF_ENG_FAIL,
        Message_HYD_TURN_OFF_ENG2_Y,
        Message_HYD_TURN_OFF_G,
        Message_HYD_MANEUVER_WITH_CARE
        
    },

    land_asap = true,

    is_active = function()
        return MessageGroup_HYD_Y_SYS_LO_PR:is_active() and MessageGroup_HYD_G_SYS_LO_PR:is_active()
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (get(EWD_flight_phase) == PHASE_1ST_ENG_ON and (get(Engine_1_avail) == 0 or get(Engine_2_avail) == 0))
    end
}

----------------------------------------------------------------------------------------------------
-- WARNING: G + B SYS LO PR
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_AND_B_LO_PR = {

    shown = false,

    text  = function()
                return "HYD"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function() return "    G + B SYS LO PR" end,
            color = function() return COL_WARNING end,
            is_active = function() return true end
        },
        Message_HYD_RAT_MAN_ON_IF_B_LOST,
        Message_HYD_RAT_MIN_ON_IF_B_LOST,
        Message_HYD_TURN_OFF_G,
        Message_HYD_TURN_OFF_B,
        Message_HYD_MANEUVER_WITH_CARE
        
    },

    land_asap = true,

    is_active = function()
        return MessageGroup_HYD_G_SYS_LO_PR:is_active() and MessageGroup_HYD_B_SYS_LO_PR:is_active()
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (get(EWD_flight_phase) == PHASE_1ST_ENG_ON and (get(Engine_1_avail) == 0 or get(Engine_2_avail) == 0))
    end
}


