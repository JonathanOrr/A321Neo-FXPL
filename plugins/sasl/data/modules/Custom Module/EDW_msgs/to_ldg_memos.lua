include('common.lua')

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
        if (get(Autobrakes)) then
            return "    AUTO BRK MAX"
        else
            return "    AUTO BRK..........MAX"
        end
    end,

    color = function(self)
        if (get(Autobrakes)) then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TO_SIGNS = {
    text = function(self)
        if (get(Seatbelts) and get(NoSmoking)) then
            return "    SIGNS ON"
        else
            return "    SIGNS..............ON"
        end
    end,

    color = function(self)
        if (get(Seatbelts) and get(NoSmoking)) then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TO_CABIN = {
    text = function(self)
        if (get(CabinIsReady)) then
            return "    CABIN CHECK"
        else
            return "    CABIN...........CHECK"
        end
    end,

    color = function(self)
        if (get(CabinIsReady)) then
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TO_SPLRS = {
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
        if (get(Flaps_handle_ratio) > 0 and get(Flaps_handle_ratio) < 0.5) then -- todo check values
            return "    FLAPS T.O."
        else
            return "    FLAPS............T.O."
        end
    end,

    color = function(self)
        if (get(Flaps_handle_ratio) > 0 and get(Flaps_handle_ratio) < 0.5) then -- todo check values
            return COL_INDICATION
        else
            return COL_ACTIONS
        end
    end,

  is_active = function(self)
      return true -- Always active when group is active
  end
}

Message_TO_CONFIG = {
    
    text = function(self)
        if get(TO_Config_is_ready) then
            return "    T.O. CONFIG NORMAL"
        else
            return "    T.O. CONFIG......TEST"
        end
    end,

    color = function(self)
        if self.is_ready() then
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
        Message_TO_SIGNS,
        Message_TO_CABIN,
        Message_TO_SPLRS,
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
            if sasl.getElapsedSeconds(timer_2nd_engine_on) > 120 then
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

    return false 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
    return not (get(EWD_flight_phase) == PHASE_1ST_ENG_ON) 
    end

}
