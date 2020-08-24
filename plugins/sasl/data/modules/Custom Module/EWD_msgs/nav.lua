--------------------------------------------------------------------------------
-- CAUTION: TCAS
--------------------------------------------------------------------------------

MessageGroup_TCAS_FAULT = {

    shown = false,

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function(self)
                    return "    TCAS FAULT"
            end,
            color = function(self)
                    return COL_CAUTION
            end,
            is_active = function(self)
              return true
            end
        }
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Not showed when any memo is active
        return get(FAILURE_TCAS) == 6
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return get(EWD_flight_phase) == 3 or get(EWD_flight_phase) == 4 or get(EWD_flight_phase) == 5 or get(EWD_flight_phase) == 7
    end

}
