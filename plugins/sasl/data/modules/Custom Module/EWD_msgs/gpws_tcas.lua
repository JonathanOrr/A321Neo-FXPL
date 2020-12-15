include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: GPWS FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_GPWS_FAULT = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = nil,

    messages = {
        {
            text = function() return "    GPWS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - GPWS SYS...........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return not PB.ovhd.gpws_sys.status_bottom end
        }
    },

    is_active = function()
        return get(FAILURE_GPWS) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_FINAL})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: GPWS FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_GPWS_TERR_FAULT = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = nil,

    messages = {
        {
            text = function() return "    GPWS TERR DET FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - GPWS TERR..........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return not PB.ovhd.gpws_terr.status_bottom end
        }
    },

    is_active = function()
        return get(FAILURE_GPWS_TERR) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_FINAL, PHASE_BELOW_80_KTS})
    end

}
