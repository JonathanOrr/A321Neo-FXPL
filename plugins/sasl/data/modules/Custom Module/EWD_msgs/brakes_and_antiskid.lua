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

    sd_page = ECAM_PAGE_WHEEL,

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


----------------------------------------------------------------------------------------------------
-- CAUTION: A/SKID/NWS OFF
----------------------------------------------------------------------------------------------------
Message_ADKIS_NWS = {
    text = function(self)
        return "       ANTI SKID/NWS OFF"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}

Message_ADKIS_MAX_PRESS = {
    text = function(self)
        return " MAX BRK PR......1000 PSI"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return true
  end
}

MessageGroup_ADKIS_NWS = {

    shown = false,

    text  = function(self)
                return "BRAKES"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
        Message_ADKIS_NWS,
        Message_ADKIS_MAX_PRESS,
    },

    is_active = function(self)
        return get(Nosewheel_Steering_and_AS_sw) == 0
    end,

    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: A/SKID/NWS FAULT
----------------------------------------------------------------------------------------------------
Message_ADKIS_NWS_FAULT = {
    text = function(self)
        return "       ANTI SKID/NWS FAULT"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}


MessageGroup_ADKIS_NWS_FAULT = {

    shown = false,

    text  = function(self)
                return "BRAKES"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
        Message_ADKIS_NWS_FAULT,
        Message_ADKIS_MAX_PRESS,
    },

    is_active = function()
        return get(FAILURE_GEAR_NWS) == 1 or (get(Brakes_mode) == 2 or get(Brakes_mode) == 3) 
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) < PHASE_1ST_ENG_ON or (get(EWD_flight_phase) == PHASE_1ST_ENG_ON and get(Engine_1_avail) + get(Engine_2_avail) < 2) or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: AUTO BREAK FAIL
----------------------------------------------------------------------------------------------------

MessageGroup_AUTOBRAKES = {

    shown = false,

    text  = function()
                return "BRAKES"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "       AUTO BRK FAULT" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_GEAR_AUTOBRAKES) == 1 and get(Wheel_autobrake_status) > 0
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: BSCU FAULT
----------------------------------------------------------------------------------------------------
local Message_BSCU_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_GEAR_BSCU1) == 1 and get(FAILURE_GEAR_BSCU2) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_GEAR_BSCU1) == 1 then
            N = "1"
        elseif get(FAILURE_GEAR_BSCU2) == 1 then
            N = "2"
        end
        return "       SYS " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_BSCU_FAULT = {

    shown = false,

    text  = function()
                return "BRAKES"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_BSCU_FAULT
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_GEAR_BSCU1) == 1 or get(FAILURE_GEAR_BSCU2) == 1 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: NORM BRAKE FALT
----------------------------------------------------------------------------------------------------

MessageGroup_BRAKE_NORM_FAULT = {

    shown = false,

    text  = function()
                return "BRAKES"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "       NORM BRK FAULT" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return (get(Brakes_mode) == 2 or get(Brakes_mode) == 3)  and (get(Wheel_status_ABCU) == 1 and get(Hydraulic_Y_press) > 1450)
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ALTN BRAKE FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_BRAKE_ALTN_FAULT = {

    shown = false,

    text  = function()
                return "BRAKES"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "       ALTN BRK FAULT" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return get(Brakes_mode) == 1 and (get(Wheel_status_ABCU) == 0 or get(Hydraulic_Y_press) <= 1450)
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: NORM+ALTN BRAKE FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_BRAKE_NORM_ALTN_FAULT = {

    shown = false,

    text  = function()
                return "BRAKES"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "       NORM + ALTN FAULT" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        },
        { text = function() return " PARK BRK ONLY" end,
           color = function() return COL_ACTIONS end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return (get(Brakes_mode) == 2 or get(Brakes_mode) == 3) and (get(Wheel_status_ABCU) == 0 or get(Hydraulic_Y_press) <= 1450)
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF})
    end

}



----------------------------------------------------------------------------------------------------
-- CAUTION: BRK Y LO PR
----------------------------------------------------------------------------------------------------

MessageGroup_BRAKE_NORM_ALTN_FAULT = {

    shown = false,

    text  = function()
                return "BRAKES"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "       BRK Y ACCU LO PR" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        },
        { text = function() return " . ON GROUND:" end,
           color = function() return COL_REMARKS end,
           is_active = function() return true end
        },
        { text = function() return "    CHOCKS CONSIDER" end,
           color = function() return COL_ACTIONS end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return get(Brakes_accumulator) < 1
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end

}
