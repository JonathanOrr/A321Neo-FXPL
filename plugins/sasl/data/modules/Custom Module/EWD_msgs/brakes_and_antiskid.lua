include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: BRAKES HOT
----------------------------------------------------------------------------------------------------
Message_BRAKES_HOT = {
    text = function(self)
        return "       HOT"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}

Message_BRAKES_FAN = {
    text = function(self)
        return " - BRK FAN.............ON"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(Brakes_fan) == 0 
  end
}

Message_BRAKES_TO_DELAY = {
    text = function(self)
        return " - DELAY T.O. FOR COOL"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(EWD_flight_phase) < PHASE_ABOVE_80_KTS
  end
}

Message_BRAKES_IF_PERMITS = {
    text = function(self)
        return " · IF PERF PERMITS:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

  is_active = function(self)
      return get(EWD_flight_phase) >= PHASE_LIFTOFF and get(EWD_flight_phase) <= PHASE_FINAL and
             (get(Front_gear_deployment) ~= 1 or get(Left_gear_deployment) ~= 1 or get(Right_gear_deployment) ~= 1) 
  end
}

Message_BRAKES_LDG_DOWN = {

    text = function(self)
        return " - L/G........DN FOR COOL"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(EWD_flight_phase) >= PHASE_LIFTOFF and get(EWD_flight_phase) <= PHASE_FINAL and
             (get(Front_gear_deployment) ~= 1 or get(Left_gear_deployment) ~= 1 or get(Right_gear_deployment) ~= 1)  
  end
}

Message_BRAKES_LDG_MAX_SPEED = {

    text = function(self)
        return " MAX SPEED........250/.60"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return get(EWD_flight_phase) >= PHASE_LIFTOFF and get(EWD_flight_phase) <= PHASE_FINAL 
  end
}

MessageGroup_BRAKES_HOT = {

    shown = false,

    text  = function(self)
                return "BRAKES"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_BRAKES_HOT,
        Message_BRAKES_FAN,
        Message_BRAKES_TO_DELAY,
        Message_BRAKES_IF_PERMITS,
        Message_BRAKES_LDG_DOWN,
        Message_BRAKES_LDG_MAX_SPEED,
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Active if any brakes over 300 C
        return get(Left_brakes_temp) > 300 or get(Right_brakes_temp) > 300
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end

}

