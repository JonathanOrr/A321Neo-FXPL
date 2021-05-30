include('EWD_msgs/common.lua')
local time_gear_down = 0  -- Time from when the handle is moved down
local time_gear_up = 0  -- Time from when the handle is moved up

----------------------------------------------------------------------------------------------------
-- WARNING: GEAR NOT DOWNLOCKED
----------------------------------------------------------------------------------------------------

Message_GEAR_NOT_DOWNLOCKED_INIT = {
    text = function(self)
        return "    GEAR NOT DOWNLOCKED"
    end,

    color = function(self)
        return COL_WARNING
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}

Message_GEAR_RECYCLE = {
    text = function(self)
        return " - L/G............RECYCLE"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
        return true
    end
}

Message_GEAR_IF_UNSUCCESSFUL = {
    text = function(self)
        return " . IF UNSUCCESSFUL:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

  is_active = function(self)
      return true 
  end
}

Message_GEAR_GRVTY_EXTN = {
    text = function(self)
        return " - L/G.........GRVTY EXTN"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return true
  end
}

MessageGroup_GEAR_NOT_DOWNLOCKED = {

    shown = false,

    text  = function(self)
                return "L/G"
            end,
    color = function(self)
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    sd_page = ECAM_PAGE_WHEEL,

    messages = {
        Message_GEAR_NOT_DOWNLOCKED_INIT,
        Message_GEAR_RECYCLE,
        Message_GEAR_IF_UNSUCCESSFUL,
        Message_GEAR_GRVTY_EXTN
    },

    -- Method to check if this message group is active
    is_active = function(self)
       
        if get(Gear_handle) == 0 then
            time_gear_down = 0
            return false
        end

        if get(Gear_handle) == 1 and time_gear_down == 0 then
            time_gear_down = get(TIME)
        end
        
        if get(Front_gear_deployment) < 1 or get(Left_gear_deployment) < 1 or get(Right_gear_deployment) < 1 then
            if get(TIME) - time_gear_down  > 30 then
                -- Gear not downlocked after 30 seconds
                set(FAILURE_gear, 2)

                return true
            end
        end
    
        set(FAILURE_gear, 0)
    
        return false
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF 
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: GEAR NOT UPLOCKED
----------------------------------------------------------------------------------------------------

Message_GEAR_NOT_UPLOCKED_INIT = {
    text = function(self)
        return "    GEAR NOT UPLOCKED"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}


Message_GEAR_MAX_SPEED = {
    text = function(self)
        return " MAX SPEED........220/.54"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return true 
  end
}

Message_GEAR_MAX_SPEED_DOWN = {
    text = function(self)
        return " - MAX SPEED......280/.67"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return true 
  end
}

Message_GEAR_DOWN = {
    text = function(self)
        return " - L/G...............DOWN"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

  is_active = function(self)
      return true
  end
}


MessageGroup_GEAR_NOT_UPLOCKED = {

    shown = false,

    text  = function(self)
                return "L/G"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_WHEEL,

    messages = {
        Message_GEAR_NOT_UPLOCKED_INIT,
        Message_GEAR_MAX_SPEED,
        Message_GEAR_RECYCLE,
        Message_GEAR_IF_UNSUCCESSFUL,
        Message_GEAR_DOWN,
        Message_GEAR_MAX_SPEED_DOWN,        
    },

    -- Method to check if this message group is active
    is_active = function(self)
       
        if get(Gear_handle) == 1 then
            time_gear_up = 0
            return false
        end

        if get(Gear_handle) == 0 and time_gear_up == 0 then
            time_gear_up = get(TIME)
        end
        
        if get(Front_gear_deployment) > 0 or get(Left_gear_deployment) > 0 or get(Right_gear_deployment) > 0 then
            if get(TIME) - time_gear_up > 30 then
                -- Gear not uplocked after 30 seconds
                set(FAILURE_gear, 1)
                return true
            end
        end

        set(FAILURE_gear, 0)

        return false
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_FINAL or
               get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_BELOW_80_KTS or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
        
    end

}


----------------------------------------------------------------------------------------------------
-- WARNING: GEAR NOT DOWN
----------------------------------------------------------------------------------------------------

Message_GEAR_NOT_DOWN_INIT = {
    text = function()
        return "    GEAR NOT DOWN"
    end,

    color = function()
        return COL_WARNING
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_GEAR_NOT_DOWN = {

    shown = false,

    text  = function()
                return "L/G"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        Message_GEAR_NOT_DOWN_INIT,
        Message_GEAR_DOWN
    },

    -- Method to check if this message group is active
    is_active = function()
       
        if get(Gear_handle) ~= 1 then
            if get(Capt_ra_alt_ft) < 750 and get(Flaps_handle_ratio) > 0.75 then
                pb_set(PB.mip.ldg_gear_red_light, true, true)
                return true
            end

            if get(Capt_ra_alt_ft) < 750 and get(Eng_1_N1) < 75 and get(Eng_2_N1) < 75 then
                pb_set(PB.mip.ldg_gear_red_light, true, true)
                return true
            end
        end
        pb_set(PB.mip.ldg_gear_red_light, false, false)
        return false
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF 
    end

}



----------------------------------------------------------------------------------------------------
-- CAUTION: TPIU
----------------------------------------------------------------------------------------------------

MessageGroup_TPIU_FAULT = {

    shown = false,

    text  = function()
                return "WHEEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "      TIRE P. MONIT FAULT" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_GEAR_TPIU) == 1
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: TYRE LO PR
----------------------------------------------------------------------------------------------------

MessageGroup_TIRE_LO_PR = {

    shown = false,

    text  = function()
                return "WHEEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "      TYRE LO PR" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_GEAR_TPIU) == 0 and (get(LL_tire_psi) < 180 or get(L_tire_psi) < 180 or get(R_tire_psi) < 180 or get(RR_tire_psi) < 180 or get(NL_tire_psi) < 160 or get(NR_tire_psi) < 160)
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_FINAL, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: N/W STRG FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_NW_STRG_FAULT = {

    shown = false,

    text  = function()
                return "WHEEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { text = function() return "      N/W STRG FAULT" end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_GEAR_NWS) == 1
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_FINAL, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: LGCIU 1 2
----------------------------------------------------------------------------------------------------

MessageGroup_LGCIU_FAULT = {

    shown = false,

    text  = function()
                return "L/G"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_WHEEL,
    
    messages = {
         { 

           text = function()
                local N = ""
                if get(FAILURE_GEAR_LGIU1) == 1 then
                    N = "1"
                end
                if get(FAILURE_GEAR_LGIU2) == 1 then
                    if #N > 0 then
                        N = N .. "+"
                    end
                    N = N .. "2"
                end
                return "    LGCIU " .. N .. " FAULT" 
           end,
           color = function() return COL_CAUTION end,
           is_active = function() return true end
        },
        {  text = function() return " - L/G.........GRVTY EXTN" end,
           color = function() return COL_ACTIONS end,
           is_active = function() return get(FAILURE_GEAR_LGIU1) == 1 and get(FAILURE_GEAR_LGIU2) == 1 end
        },
        {  text = function() return " - GPWS SYS...........OFF" end,
           color = function() return COL_ACTIONS end,
           is_active = function() return  get(FAILURE_GEAR_LGIU1) == 1 and (not PB.ovhd.gpws_sys.status_bottom) end
        }
    },

    is_active = function()
        return get(FAILURE_GEAR_LGIU1) == 1 or get(FAILURE_GEAR_LGIU2) == 1
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


