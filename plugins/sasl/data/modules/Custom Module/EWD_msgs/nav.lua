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

MessageGroup_RA_FAULT = {
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
                local RA_1_fault = not RA_sys.Sensors[1].Valid or get(RA_1_status) == 0
                local RA_2_fault = not RA_sys.Sensors[2].Valid or get(RA_2_status) == 0

                if RA_1_fault and not RA_2_fault then
                    return "    RA 1 FAULT"
                elseif not RA_1_fault and RA_2_fault then
                    return "    RA 2 FAULT"
                else
                    return "    RA 1 + 2 FAULT"
                end
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
        return (not RA_sys.Sensors[1].Valid or get(RA_1_status) == 0) or (not RA_sys.Sensors[2].Valid or get(RA_2_status) == 0)
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return get(EWD_flight_phase) == 3 or get(EWD_flight_phase) == 4 or get(EWD_flight_phase) == 5 or get(EWD_flight_phase) == 8
    end

}

MessageGroup_RA_DEGRADED = {
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
                return "    RA DEGRADED"
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
        return RA_sys.RA_disagree()
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return get(EWD_flight_phase) >= 2 and get(EWD_flight_phase) <= 8
    end

}