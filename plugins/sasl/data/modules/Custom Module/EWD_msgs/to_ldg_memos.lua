include('EWD_msgs/common.lua')

--
-- Timers
--
timer_2nd_engine_on = sasl.createTimer()
timer_2nd_engine_on_started = false

--
-- Messages
--

Message_TO_AUTOBRK = {
    text = function(self)
        if (get(Autobrakes) == 3) then
            return "    AUTO BRK MAX"
        else
            return "    AUTO BRK..........MAX"
        end
    end,

    color = function(self)
        if (get(Autobrakes) == 3) then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TOLDG_SIGNS = {
    text = function(self)
        if (get(Seatbelts) ~= 0 and get(NoSmoking) ~= 0) then
            return "    SIGNS ON"
        else
            return "    SIGNS..............ON"
        end
    end,

    color = function(self)
        if (get(Seatbelts) ~= 0 and get(NoSmoking) ~= 0) then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TOLDG_CABIN = {
    text = function(self)
        if (get(CabinIsReady) == 1) then
            return "    CABIN CHECK"
        else
            return "    CABIN...........CHECK"
        end
    end,

    color = function(self)
        if (get(CabinIsReady) == 1) then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TOLDG_SPLRS = {
    text = function(self)
        if (get(Speedbrake_handle_ratio) < 0) then
            return "    SPLRS ARM"
        else
            return "    SPLRS.............ARM"
        end
    end,

    color = function(self)
        if (get(Speedbrake_handle_ratio) < 0) then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TO_FLAPS = {
    text = function(self)
        if get(Flaps_internal_config) == 2 then
            return "    FLAPS T.O."
        else
            return "    FLAPS............T.O."
        end
    end,

    color = function(self)
        if get(Flaps_internal_config) == 2 then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_LDG_GEAR = {
    text = function(self)
        if (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1) then 
            return "    LDG GEAR DN"
        else
            return "    LDG GEAR...........DN"
        end
    end,

    color = function(self)
        if (get(Front_gear_deployment) == 1 and get(Left_gear_deployment) == 1 and get(Right_gear_deployment) == 1) then 
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_LDG_FLAPS = {

    text = function(self)
        if get(FBW_status) < 2 then -- alternate or direct law
            if get(Flaps_internal_config) == 4 then
                return "    FLAPS CONF 3"
            else
                return "    FLAPS..........CONF 3"
            end
        else    -- normal law
            if get(Flaps_internal_config) == 5 then
                return "    FLAPS FULL"
            else
                return "    FLAPS............FULL"
            end
        end
        
    end,

    color = function(self)
         if get(FBW_status) < 2 then -- alternate or direct law
            if get(Flaps_internal_config) == 4 then
                return COL_INDICATION
            else
                return COL_ACTIONS
            end
        else    -- normal law
            if get(Flaps_internal_config) == 5 then
                return COL_INDICATION
            else
                return COL_ACTIONS
            end
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TO_CONFIG = {
    
    text = function(self)
        if get(TO_Config_is_ready) == 1 then
            return "    T.O. CONFIG NORMAL"
        else
            return "    T.O. CONFIG......TEST"
        end
    end,

    color = function(self)
        if get(TO_Config_is_ready) == 1 then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true
  end
}

--
-- Message groups
--

MessageGroup_MEMO_TAKEOFF = {

    shown = false,

    text  = function(self)
                return "T.O"
            end,
    color = function(self)
                return COL_INDICATION
            end,

    priority = PRIORITY_LEVEL_MEMO,

    messages = {
        Message_TO_AUTOBRK,
        Message_TOLDG_SIGNS,
        Message_TOLDG_CABIN,
        Message_TOLDG_SPLRS,
        Message_TO_FLAPS,
        Message_TO_CONFIG
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Active after 2 minutes from the second engine start this message is enabled
        if (get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1) then
            if not timer_2nd_engine_on_started then
                sasl.startTimer(timer_2nd_engine_on)
                timer_2nd_engine_on_started = true
            else
                if (get(EWD_flight_phase) == PHASE_1ST_ENG_ON) and sasl.getElapsedSeconds(timer_2nd_engine_on) > 120 then
                    set(EWD_is_to_memo_showed, 1)
                    return true
                end
            end        
        else    
            if timer_2nd_engine_on_started then -- Someone powered off an engine here
                sasl.stopTimer(timer_2nd_engine_on)
                timer_2nd_engine_on_started = false
            end        
        end

        -- TODO Check TO CONFIG BUTTON

        set(EWD_is_to_memo_showed, 0)
        return false 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return not (get(EWD_flight_phase) == PHASE_1ST_ENG_ON) 
    end

}


MessageGroup_MEMO_LANDING = {

    shown = false,

    text  = function(self)
                return "LDG"
            end,
    color = function(self)
                return COL_INDICATION
            end,

    priority = PRIORITY_LEVEL_MEMO,

    messages = {
        Message_LDG_GEAR,
        Message_TOLDG_SIGNS,
        Message_TOLDG_CABIN,
        Message_TOLDG_SPLRS,
        Message_LDG_FLAPS,
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Active if in phase 7 or below 2000ft if LDG down, until below 80 kts
        if (get(Gear_handle) == 1 and get(EWD_flight_phase) == PHASE_AIRBONE and get(Capt_ra_alt_ft) < 2000) or (get(EWD_flight_phase) == PHASE_FINAL) or (get(EWD_flight_phase) == PHASE_TOUCHDOWN) then
            set(EWD_is_ldg_memo_showed, 1)
            return true
        else
            set(EWD_is_ldg_memo_showed, 0)
            return false 
        end
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        -- Never inhibited
        return false
    end

}




----------------------------------------------------------------------------------------------------
-- WARNING: TAKEOFF CONFIG
----------------------------------------------------------------------------------------------------
Message_CONFIG_TAKEOFF_BRAKES = {
            text = function(self)
                    return "       PARK BRK ON"
            end,
            color = function(self)
                    return COL_WARNING
            end,
            is_active = function(self)
              return get(Actual_brake_ratio) > 0
            end
}

Message_CONFIG_TAKEOFF_SPDBRK = {
            text = function(self)
                    return "       SPDBRK NOT RETRACTED"
            end,
            color = function(self)
                    return COL_WARNING
            end,
            is_active = function(self)
              return get(Speedbrake_handle_ratio) > 0
            end
}

Message_CONFIG_TAKEOFF_FLAPS = {
            text = function(self)
                    return "       FLAPS NOT IN T.O CFG"
            end,
            color = function(self)
                    return COL_WARNING
            end,
            is_active = function(self)
              return get(Flaps_internal_config) ~= 2 
            end
}

Message_CONFIG_TAKEOFF_PITCH_TRIM = {
            text = function(self)
                    return "       PITCH TRIM NOT IN TO"
            end,
            color = function(self)
                    return COL_WARNING
            end,
            is_active = function(self)
              return get(Elev_trim_ratio) > (3.5/13.5) or get(Elev_trim_ratio) < (-3/4)
            end
}

Message_CONFIG_TAKEOFF_RUD_TRIM = {
            text = function(self)
                    return "       RUD TRIM NOT IN T.O "

            end,
            color = function(self)
                    return COL_WARNING
            end,
            is_active = function(self)
              return get(Rudder_trim_ratio) ~= 0
            end
}

MessageGroup_CONFIG_TAKEOFF = {

    shown = false,

    text  = function(self)
                return "CONFIG"
            end,
    color = function(self)
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,
 
    messages = {
        Message_CONFIG_TAKEOFF_BRAKES,
        Message_CONFIG_TAKEOFF_SPDBRK,
        Message_CONFIG_TAKEOFF_FLAPS,
        Message_CONFIG_TAKEOFF_PITCH_TRIM,
        Message_CONFIG_TAKEOFF_RUD_TRIM
    },

    is_active = function(self)
        local active = false
        for i, msg in ipairs(MessageGroup_CONFIG_TAKEOFF.messages) do
            if msg.is_active() then
                active = true
                break
            end
        end
        
        if active then
            set(TO_Config_is_ready, 0)
        end
        
        return active and (get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS)
    end,

    is_inhibited = function(self)
        -- Never inhibited
        return false
    end

}


MessageGroup_TOCONFIG_NORMAL = {

    shown = false,

    text  = function(self)
                return ""
            end,
    color = function(self)
                return COL_INDICATION
            end,

    priority = PRIORITY_LEVEL_MEMO,

    messages = {
        { text = function(self)
                    return "T.O CONFIG NORMAL"
          end,
          color = function(self)
            return COL_INDICATION
          end,
          is_active = function(self)
            return true
          end}
    },

    is_active = function(self)
        return get(TO_Config_is_pressed) == 1 and get(TO_Config_is_ready) == 1
    end,

    is_inhibited = function(self)
        -- Never inhibited
        return false
    end

}




