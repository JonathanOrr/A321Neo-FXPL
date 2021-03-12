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
