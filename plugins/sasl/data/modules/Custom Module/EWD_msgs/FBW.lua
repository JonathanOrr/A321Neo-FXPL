--------------------------------------------------------------------------------
-- CAUTION: ALTN LAW and DIRECT LAW
--------------------------------------------------------------------------------

Message_ALTN_LAW = {
    text = function(self)
            return "      ALTN LAW"
    end,
    color = function(self)
            return COL_CAUTION
    end,
    is_active = function(self)
      return get(FBW_status) == 1
    end
}

Message_DIRECT_LAW = {
    text = function(self)
            return "      DIRECT LAW"
    end,
    color = function(self)
            return COL_CAUTION
    end,
    is_active = function(self)
      return get(FBW_status) == 0
    end
}

Message_PROT_LOST = {
    text = function(self)
            return "      (PROT LOST)"
    end,
    color = function(self)
            return COL_CAUTION
    end,
    is_active = function(self)
      return true
    end
}

Message_FBW_DO_NOT_SPD_BRK = {
    text = function(self)
            return " SPD BRK.......DO NOT USE"
    end,
    color = function(self)
            return COL_ACTIONS
    end,
    is_active = function(self)
      return get(FBW_status) == 0
    end
}

Message_FBW_SPEED_LIMIT = {
    text = function(self)
        if get(FBW_status) == 1 then
            return " MAX SPEED........330/.82"
        else
            return " MAX SPEED........305/.80"        
        end
    end,
    color = function(self)
            return COL_ACTIONS
    end,
    is_active = function(self)
      return true
    end
}

Message_FBW_MAN_PITCH_TRIM = {
    text = function(self)
            return " - MAN PITCH TRIM.....USE"
    end,
    color = function(self)
            return COL_ACTIONS
    end,
    is_active = function(self)
      return get(FBW_status) == 0
    end
}

Message_FBW_MANEUVER_WITH_CARE = {
    text = function(self)
            return " MANEUVER WITH CARE"
    end,
    color = function(self)
            return COL_ACTIONS
    end,
    is_active = function(self)
      return get(FBW_status) == 0
    end
}

MessageGroup_FBW_ALTN_DIRECT_LAW = {

    shown = false,

    text  = function(self)
                return "F/CTL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_ALTN_LAW,
        Message_DIRECT_LAW,
        Message_PROT_LOST,
        Message_FBW_DO_NOT_SPD_BRK,
        Message_FBW_SPEED_LIMIT,
        Message_FBW_MAN_PITCH_TRIM,
        Message_FBW_MANEUVER_WITH_CARE
        
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Not showed when any memo is active
        return get(FBW_status) == 1 or get(FBW_status) == 0
    end,

    is_inhibited = function(self)
        -- Inhibited during takeoff and landing
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end

}

