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
    text = function(self)
        return " - BLUE ELEC PUMP.....OFF"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(Hyd_light_B_ElecPump) % 2 == 0
  end
}

MessageGroup_HYD_ELEC_PUMP_B_OVHT = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    B ELEC PUMP OVHT" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_TURN_OFF_B
    },

    is_active = function(self)
        return get(FAILURE_HYD_B_E_overheat) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B RSVR OVHT
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_B_RSVR_OVHT = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    B RSVR OVHT" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_TURN_OFF_B
    },

    is_active = function(self)
        return get(FAILURE_HYD_B_R_overheat) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B LO LVL
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_B_RSVR_LO_LVL = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    B RSVR LO LVL" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_TURN_OFF_B
    },

    is_active = function(self)
        return get(Hydraulic_B_qty) < 0.31
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: B RSVR LO AIR PR
----------------------------------------------------------------------------------------------------


Message_HYD_IF_B_PRESS_FLUCTUATE = {
    text = function(self)
        return " · IF PRESS FLUCTUATES:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

  is_active = function(self)
      return Message_HYD_TURN_OFF_B:is_active()
  end
}


MessageGroup_HYD_B_RSVR_LO_AIR_PRESS = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    B RSVR LO AIR PR" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_IF_B_PRESS_FLUCTUATE,
        Message_HYD_TURN_OFF_B
    },

    is_active = function(self)
        return get(FAILURE_HYD_B_low_air) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GREEN SYSTEM
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Message_HYD_TURN_OFF_PTU = {
    text = function(self)
        return " - PTU................OFF"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(Hyd_light_PTU) % 2 == 0
  end
}


Message_HYD_TURN_OFF_G = {
    text = function(self)
        return " - GREEN ENG 1 PUMP...OFF"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(Hyd_light_Eng1Pump) % 2 == 0
  end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G RSVR OVHT
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_RSVR_OVHT = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    G RSVR OVHT" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_G
    },

    is_active = function(self)
        return get(FAILURE_HYD_G_R_overheat) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G LO LVL
----------------------------------------------------------------------------------------------------
MessageGroup_HYD_G_RSVR_LO_LVL = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    G RSVR LO LVL" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_G
    },

    is_active = function(self)
        return get(Hydraulic_G_qty) < 0.18
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: G RSVR LO AIR PR
----------------------------------------------------------------------------------------------------


Message_HYD_IF_G_PRESS_FLUCTUATE = {
    text = function(self)
        return " · IF PRESS FLUCTUATES:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

  is_active = function(self)
      return Message_HYD_TURN_OFF_G:is_active()
  end
}


MessageGroup_HYD_G_RSVR_LO_AIR_PRESS = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    G RSVR LO AIR PR" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_IF_G_PRESS_FLUCTUATE,
        Message_HYD_TURN_OFF_PTU,
        Message_HYD_TURN_OFF_G
    },

    is_active = function(self)
        return get(FAILURE_HYD_G_low_air) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
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

Message_HYD_TURN_OFF_Y = {
    text = function(self)
        return " - YELLOW ELEC PUMP...OFF"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(Hyd_light_Y_ElecPump) % 2 == 1
  end
}

MessageGroup_HYD_ELEC_PUMP_Y_OVHT = {

    shown = false,

    text  = function(self)
                return "HYD"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_HYD,
    
    messages = {
        {
            text = function(self) return "    Y ELEC PUMP OVHT" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_HYD_TURN_OFF_Y
    },

    is_active = function(self)
        return get(FAILURE_HYD_Y_E_overheat) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}

