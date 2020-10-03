include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- BATTERY RELATED
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- CAUTION: BATTERY OFF
----------------------------------------------------------------------------------------------------


MessageGroup_ELEC_BAT_OFF = {

    shown = false,

    text  = function(self)
                return "ELEC"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if ELEC_sys.batteries[1].switch_status == false and get(ELEC_sys.batteries[1].drs.failure) == 0 then
                    x = x .. "1"
                end
                if ELEC_sys.batteries[2].switch_status == false and get(ELEC_sys.batteries[2].drs.failure) == 0 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     BAT " .. x .. " OFF"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return (ELEC_sys.batteries[1].switch_status == false and get(ELEC_sys.batteries[1].drs.failure) == 0)
               or (ELEC_sys.batteries[2].switch_status == false and get(ELEC_sys.batteries[2].drs.failure) == 0)
    end,

    is_inhibited = function(self)
        return not(get(EWD_flight_phase) == PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_AIRBONE)
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: BATTERY FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_ELEC_BAT_FAULT = {

    shown = false,

    text  = function(self)
                return "ELEC"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(ELEC_sys.batteries[1].drs.failure) == 1 then
                    x = x .. "1"
                end
                if get(ELEC_sys.batteries[2].drs.failure) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     BAT " .. x .. " FAULT"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return (get(ELEC_sys.batteries[1].drs.failure) == 1)
               or (get(ELEC_sys.batteries[2].drs.failure) == 1)
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or
               get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN
    end
}
