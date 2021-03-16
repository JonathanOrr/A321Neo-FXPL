include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: APU AUTO/EMER SHUT DOWN
----------------------------------------------------------------------------------------------------
Message_APU_AUTO_SHUT_DOWN = {
    text = function()
        return "    AUTO SHUT DOWN"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return get(FAILURE_ENG_APU_FAIL) == 1
    end
}

Message_APU_EMER_SHUT_DOWN = {
    text = function()
        return "    EMERG SHUT DOWN"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return get(FAILURE_FIRE_APU) == 1
    end
}

Message_APU_MASTER_SWITCH_OFF = {
    text = function()
        return " - MASTER SW..........OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

  is_active = function()
      return get(Apu_start_position) ~= 0 
  end
}

MessageGroup_APU_SHUTDOWN = {

    shown = false,

    text  = function()
                return "APU"
            end,
    color = function()
                return COL_CAUTION
            end,

    sd_page = ECAM_PAGE_APU,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_APU_AUTO_SHUT_DOWN,
        Message_APU_EMER_SHUT_DOWN,
        Message_APU_MASTER_SWITCH_OFF
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_ENG_APU_FAIL) == 1 or get(FAILURE_FIRE_APU) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or
               get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end

}

----------------------------------------------------------------------------------------------------
-- WARNING: APU FIRE
----------------------------------------------------------------------------------------------------
Message_APU_FIRE = {
    text = function()
        return "    FIRE"
    end,

    color = function()
        return COL_WARNING
    end,

    is_active = function()
      return true
    end
}

Message_APU_FIRE_PB = {
    text = function()
        return " - APU FIRE P/B......PUSH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Fire_pb_APU_lever) < 0.5 or FIRE_sys.apu_on_test
    end
}

Message_APU_AFTER_10_S = {
    text = function()
        return " . AFTER 10 SECONDS:"
    end,

    color = function()
        return COL_REMARKS
    end,

    is_active = function()
      return not FIRE_sys.apu_squib_discharged or FIRE_sys.apu_on_test
    end
}

Message_APU_AGENT = {
    text = function()
        return "   - AGENT..........DISCH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return not FIRE_sys.apu_squib_discharged or FIRE_sys.apu_on_test
    end
}

MessageGroup_APU_FIRE = {

    shown = false,

    text  = function()
                return "APU"
            end,
    color = function()
                return COL_WARNING
            end,

    sd_page = ECAM_PAGE_APU,
    
    land_asap = true,

    priority = PRIORITY_LEVEL_3,

    messages = {
        Message_APU_FIRE,
        Message_APU_FIRE_PB,
        Message_APU_AFTER_10_S,
        Message_APU_AGENT
    },

    is_active = function()
        return get(FAILURE_FIRE_APU) == 1 or FIRE_sys.apu_on_test
    end,

    is_inhibited = function()
        return false
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: FUEL FILTER CLOG
----------------------------------------------------------------------------------------------------

MessageGroup_ENG_FF_CLOG = {

    shown = false,

    text  = function()
                return "ENG"
            end,
    color = function()
                return COL_CAUTION
            end,

    sd_page = ECAM_PAGE_ENG,
    
    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                N = ""
                if get(FAILURE_ENG_1_FUEL_CLOG) == 1 then
                    N = "1"
                end
                if get(FAILURE_ENG_2_FUEL_CLOG) == 1 then
                    if #N > 0 then
                        N = N .. "+"
                    end
                    N = N .. "2"
                end
                return "    " .. N .. " FUEL FILTER CLOG"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end
        }

    },

    is_active = function()
        return get(FAILURE_ENG_1_FUEL_CLOG) == 1 or get(FAILURE_ENG_2_FUEL_CLOG) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: OIL FILTER CLOG
----------------------------------------------------------------------------------------------------

MessageGroup_ENG_OIL_CLOG = {

    shown = false,

    text  = function()
                return "ENG"
            end,
    color = function()
                return COL_CAUTION
            end,

    sd_page = ECAM_PAGE_ENG,
    
    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                N = ""
                if get(FAILURE_ENG_1_OIL_CLOG) == 1 then
                    N = "1"
                end
                if get(FAILURE_ENG_2_OIL_CLOG) == 1 then
                    if #N > 0 then
                        N = N .. "+"
                    end
                    N = N .. "2"
                end
                return "    " .. N .. " OIL FILTER CLOG"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end
        }

    },

    is_active = function()
        return get(FAILURE_ENG_1_OIL_CLOG) == 1 or get(FAILURE_ENG_2_OIL_CLOG) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end

}



----------------------------------------------------------------------------------------------------
-- CAUTION: ENGINE FADEC FAULT
----------------------------------------------------------------------------------------------------

local function get_fadec_failure_n_text()
    local N = ""
    if get(FAILURE_ENG_FADEC_CH1, 1) == 1 and get(FAILURE_ENG_FADEC_CH2, 1) == 1 then
        N = "1"
    end
    if get(FAILURE_ENG_FADEC_CH1, 2) == 1 and get(FAILURE_ENG_FADEC_CH2, 2) == 1 then
        if #N > 0 then
            N = N .. "+"
        end
        N = N .. "2"
    end
    return N
end

Message_ENG_FADEC_IDLE = {
    text = function()
        which = get_fadec_failure_n_text()
        return " - THR LEVER " .. which .. (#which > 1 and "" or "....") .. ".....IDLE"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true   -- Do not disable
    end
}

Message_ENG_FADEC_CHECK_PARAMS = {
    text = function()
        which = get_fadec_failure_n_text()
        return " - CONFIRM ENG ".. which .. " STATUS"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true   -- Do not disable
    end
}

Message_ENG_FADEC_MASTER_OFF = {
    text = function()
        which = get_fadec_failure_n_text()
        return "   - ENG MASTER " .. which .. (#which > 1 and "" or "....") .. "...OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return ((get(FAILURE_ENG_FADEC_CH1, 1) == 1 and get(FAILURE_ENG_FADEC_CH2, 1) == 1) and get(Engine_1_master_switch) == 1)
          or ((get(FAILURE_ENG_FADEC_CH1, 2) == 1 and get(FAILURE_ENG_FADEC_CH2, 2) == 1) and get(Engine_2_master_switch) == 1)
    end
}


MessageGroup_ENG_FADEC_FAULT = {

    shown = false,

    text  = function()
                return "ENG"
            end,
    color = function()
                return COL_CAUTION
            end,

    sd_page = ECAM_PAGE_ENG,
    
    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()

                return "    " .. get_fadec_failure_n_text() .. " FADEC FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_ENG_FADEC_IDLE,
        Message_ENG_FADEC_CHECK_PARAMS,
        {
            text = function() return " . IF ABN ENG OPERATION:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return true end
        },
        Message_ENG_FADEC_MASTER_OFF
        

    },

    is_active = function()
        return (get(FAILURE_ENG_FADEC_CH1, 1) == 1 and get(FAILURE_ENG_FADEC_CH2, 1) == 1)
            or (get(FAILURE_ENG_FADEC_CH1, 2) == 1 and get(FAILURE_ENG_FADEC_CH2, 2) == 1)
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: SAT ABOVE FLEX TEMP
----------------------------------------------------------------------------------------------------

MessageGroup_SAT_ABOVE_FLEX = {

    shown = false,

    text  = function()
                return "ENG"
            end,
    color = function()
                return COL_CAUTION
            end,

    sd_page = nil,
    
    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function() return "    SAT ABOVE FLEX TEMP" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - T.O DATA.........CHECK" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }

    },

    is_active = function()
        return get(Eng_N1_flex_temp) > 0 and get(OTA) > get(Eng_N1_flex_temp)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON})
    end

}



----------------------------------------------------------------------------------------------------
-- WARNING: ENG FIRE - Ground
----------------------------------------------------------------------------------------------------
local Message_ENG_FIRE = {
    text = function()
        return "      FIRE"
    end,

    color = function()
        return COL_WARNING
    end,

    is_active = function()
      return true
    end
}

local Message_ENG_THR_IDLE = {
    text = function()
        return " - THR LEVERS........IDLE"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return math.abs(get(Cockpit_throttle_lever_L)) > 0.05 or math.abs(get(Cockpit_throttle_lever_R)) > 0.05
    end
}

local Message_AC_STOPPED = {
    text = function()
        return " . WHEN A/C IS STOPPED:"
    end,

    color = function()
        return COL_REMARKS
    end,

    is_active = function()
      return true
    end
}

local Message_PARK_BRK_ON = {
    text = function()
        return "   - PARKING BRK.......ON"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Parkbrake_switch_pos) == 0
    end
}

local Message_ATC_NOTIFY_LVL2 = {
    text = function()
        return "   - ATC...........NOTIFY"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true
    end
}

local Message_CABIN_CREW_ALERT = {
    text = function()
        return "   - CABIN CREW.....ALERT"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true
    end
}

local Message_ENG_MASTER_1_OFF_LVL2 = {
    text = function()
        return "   - ENG MASTER 1.....OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Engine_1_master_switch) == 1
    end
}

local Message_ENG_MASTER_2_OFF_LVL2 = {
    text = function()
        return "   - ENG MASTER 2.....OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Engine_2_master_switch) == 1
    end
}

local Message_ENG_MASTER_1_FIRE_PB_LVL2 = {
    text = function()
        return "   - ENG FIRE P/B 1..PUSH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Fire_pb_ENG1_status) == 0
    end
}

local Message_ENG_MASTER_2_FIRE_PB_LVL2 = {
    text = function()
        return "   - ENG FIRE P/B 2..PUSH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Fire_pb_ENG2_status) == 0
    end
}

local Message_ENG_1_AGENTS_DISCH = {
    text = function()
        return "   - AGENT 1+2......DISCH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return not (FIRE_sys.eng[1].squib_1_disch and FIRE_sys.eng[1].squib_2_disch)
    end
}

local Message_ENG_2_AGENTS_DISCH = {
    text = function()
        return "   - AGENT 1+2......DISCH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return not (FIRE_sys.eng[2].squib_1_disch and FIRE_sys.eng[2].squib_2_disch)
    end
}


local Message_EMER_EVAC_APPLY = {
    text = function()
        return "   EMER EVAC PROC APPLY"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true
    end
}

MessageGroup_ENG_1_FIRE_GROUND = {

    shown = false,

    text  = function()
                return "ENG 1"
            end,
    color = function()
                return COL_WARNING
            end,

    sd_page = ECAM_PAGE_ENG,

    priority = PRIORITY_LEVEL_3,

    messages = {
        Message_ENG_FIRE,
        Message_ENG_THR_IDLE,
        Message_AC_STOPPED,
        Message_PARK_BRK_ON,
        Message_ATC_NOTIFY_LVL2,
        Message_CABIN_CREW_ALERT,
        Message_ENG_MASTER_1_OFF_LVL2,
        Message_ENG_MASTER_1_FIRE_PB_LVL2,
        Message_ENG_1_AGENTS_DISCH,
        Message_EMER_EVAC_APPLY
    },

    is_active = function()
        return get(FAILURE_FIRE_ENG_1) == 1 and FIRE_sys.eng[1].still_on_fire and get(All_on_ground) == 1
    end,

    is_inhibited = function()
        return false
    end

}

MessageGroup_ENG_2_FIRE_GROUND = {

    shown = false,

    text  = function()
                return "ENG 2"
            end,
    color = function()
                return COL_WARNING
            end,

    sd_page = ECAM_PAGE_ENG,

    priority = PRIORITY_LEVEL_3,

    messages = {
        Message_ENG_FIRE,
        Message_ENG_THR_IDLE,
        Message_AC_STOPPED,
        Message_PARK_BRK_ON,
        Message_ATC_NOTIFY_LVL2,
        Message_CABIN_CREW_ALERT,
        Message_ENG_MASTER_2_OFF_LVL2,
        Message_ENG_MASTER_2_FIRE_PB_LVL2,
        Message_ENG_2_AGENTS_DISCH,
        Message_EMER_EVAC_APPLY
    },

    is_active = function()
        return get(FAILURE_FIRE_ENG_2) == 1 and FIRE_sys.eng[2].still_on_fire and get(All_on_ground) == 1
    end,

    is_inhibited = function()
        return false
    end

}


----------------------------------------------------------------------------------------------------
-- WARNING: ENG FIRE - Flight
----------------------------------------------------------------------------------------------------
local Message_ENG_THR_1_IDLE = {
    text = function()
        return " - THR LEVER 1.......IDLE"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return math.abs(get(Cockpit_throttle_lever_L)) > 0.05
    end
}

local Message_ENG_THR_2_IDLE = {
    text = function()
        return " - THR LEVER 2.......IDLE"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return math.abs(get(Cockpit_throttle_lever_R)) > 0.05
    end
}

local Message_ENG_MASTER_1_OFF = {
    text = function()
        return " - ENG MASTER 1.......OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Engine_1_master_switch) == 1
    end
}

local Message_ENG_MASTER_2_OFF = {
    text = function()
        return " - ENG MASTER 2.......OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Engine_2_master_switch) == 1
    end
}

local Message_ENG_MASTER_1_FIRE_PB = {
    text = function()
        return " - ENG FIRE P/B 1....PUSH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Fire_pb_ENG1_status) == 0
    end
}

local Message_ENG_MASTER_2_FIRE_PB = {
    text = function()
        return " - ENG FIRE P/B 2....PUSH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(Fire_pb_ENG2_status) == 0
    end
}

Message_ENG_1_AGENT_1_DISCH = {
    text = function()
        local remaining_sec = math.ceil(10 - (get(TIME) - Message_ENG_1_AGENT_1_DISCH.start_time))
        if remaining_sec <= 0 then
            return " - AGENT 1..........DISCH"
        elseif remaining_sec == 10 then
            return " - AGENT 1 AFT 10S..DISCH"
        else
            return " - AGENT 1 AFT ".. remaining_sec .."S...DISCH"
        end
        
    end,

    start_time = 0,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
        local active = get(Fire_pb_ENG1_status) == 1 and not FIRE_sys.eng[1].squib_1_disch
        if active and Message_ENG_1_AGENT_1_DISCH.start_time == 0 then
            Message_ENG_1_AGENT_1_DISCH.start_time = get(TIME)
        end
        if not active then
            Message_ENG_1_AGENT_1_DISCH.start_time = 0
        end
        return active
    end
}

Message_ENG_2_AGENT_1_DISCH = {
    text = function()
        local remaining_sec = math.ceil(10 - (get(TIME) - Message_ENG_2_AGENT_1_DISCH.start_time))
        if remaining_sec <= 0 then
            return " - AGENT 1..........DISCH"
        elseif remaining_sec == 10 then
            return " - AGENT 1 AFT 10S..DISCH"
        else
            return " - AGENT 1 AFT ".. remaining_sec .."S...DISCH"
        end
        
    end,

    start_time = 0,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
        local active = get(Fire_pb_ENG2_status) == 1 and not FIRE_sys.eng[2].squib_1_disch
        if active and Message_ENG_2_AGENT_1_DISCH.start_time == 0 then
            Message_ENG_2_AGENT_1_DISCH.start_time = get(TIME)
        end
        if not active then
            Message_ENG_2_AGENT_1_DISCH.start_time = 0
        end
        return active
    end
}


local Message_ATC_NOTIFY = {
    text = function()
        return " - ATC.............NOTIFY"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true
    end
}

local Message_AFTER_30SEC_ENG2 = {
    text = function()
        return " . IF FIRE AFTER 30 S:"
    end,

    color = function()
        return COL_REMARKS
    end,

    is_active = function()
      return FIRE_sys.eng[2].squib_1_disch and not FIRE_sys.eng[2].squib_2_disch
    end
}

local Message_ENG_2_AGENT_2 = {
    text = function()
        return "   - AGENT 2........DISCH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return FIRE_sys.eng[2].squib_1_disch and not FIRE_sys.eng[2].squib_2_disch
    end
}

local Message_AFTER_30SEC_ENG1 = {
    text = function()
        return " . IF FIRE AFTER 30 S:"
    end,

    color = function()
        return COL_REMARKS
    end,

    is_active = function()
      return FIRE_sys.eng[1].squib_1_disch and not FIRE_sys.eng[1].squib_2_disch
    end
}

local Message_ENG_1_AGENT_2 = {
    text = function()
        return "   - AGENT 2........DISCH"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return FIRE_sys.eng[1].squib_1_disch and not FIRE_sys.eng[1].squib_2_disch
    end
}

MessageGroup_ENG_1_FIRE_FLIGHT = {

    shown = false,

    text  = function()
                return "ENG 1"
            end,
    color = function()
                return COL_WARNING
            end,

    sd_page = ECAM_PAGE_ENG,
    
    land_asap = true,

    priority = PRIORITY_LEVEL_3,

    messages = {
        Message_ENG_FIRE,
        Message_ENG_THR_1_IDLE,
        Message_ENG_MASTER_1_OFF,
        Message_ENG_MASTER_1_FIRE_PB,
        Message_ENG_1_AGENT_1_DISCH,
        Message_ATC_NOTIFY,
        Message_AFTER_30SEC_ENG1,
        Message_ENG_1_AGENT_2
    },

    is_active = function()
        return get(FAILURE_FIRE_ENG_1) == 1 and FIRE_sys.eng[1].still_on_fire and get(All_on_ground) == 0
    end,

    is_inhibited = function()
        return false
    end

}

MessageGroup_ENG_2_FIRE_FLIGHT = {

    shown = false,

    text  = function()
                return "ENG 2"
            end,
    color = function()
                return COL_WARNING
            end,

    sd_page = ECAM_PAGE_ENG,
    
    land_asap = true,

    priority = PRIORITY_LEVEL_3,

    messages = {
        Message_ENG_FIRE,
        Message_ENG_THR_2_IDLE,
        Message_ENG_MASTER_2_OFF,
        Message_ENG_MASTER_2_FIRE_PB,
        Message_ENG_2_AGENT_1_DISCH,
        Message_ATC_NOTIFY,
        Message_AFTER_30SEC_ENG2,
        Message_ENG_2_AGENT_2
    },

    is_active = function()
        return get(FAILURE_FIRE_ENG_2) == 1 and FIRE_sys.eng[2].still_on_fire and get(All_on_ground) == 0
    end,

    is_inhibited = function()
        return false
    end

}

