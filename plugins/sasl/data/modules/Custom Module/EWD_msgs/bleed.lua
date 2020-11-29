include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: BLEED OFF
----------------------------------------------------------------------------------------------------
local Message_BLEED_OFF = {
    text = function()
        local N = ""
        if PB.ovhd.ac_bleed_1.status_bottom and PB.ovhd.ac_bleed_2.status_bottom then
            N = "1 + 2"
        elseif PB.ovhd.ac_bleed_1.status_bottom then
            N = "1"
        elseif PB.ovhd.ac_bleed_2.status_bottom then
            N = "2"
        end
        return "    BLEED " .. N .. " OFF"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_BLEED_OFF = {

    shown = false,

    text  = function()
                return "AIR"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        Message_BLEED_OFF
    },

    -- Method to check if this message group is active
    is_active = function()
        return PB.ovhd.ac_bleed_1.status_bottom or PB.ovhd.ac_bleed_2.status_bottom
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return get(EWD_flight_phase) ~= PHASE_1ST_ENG_ON and get(EWD_flight_phase) ~= PHASE_AIRBONE
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: AIR X BLEED FAULT
----------------------------------------------------------------------------------------------------
local Message_WING_ANTI_ICE_OFF_2ND_LVL = {
    text = function()
        return "   - WING ANTI-ICE....OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return AI_sys.switches[3]
    end
}

local Message_AVOID_ICE_2ND_LVL = {
    text = function()
        return "   AVOID ICING CONDITIONS"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true
    end
}

MessageGroup_AIR_X_BLEED_FAULT = {

    shown = false,

    text  = function()
                return "AIR"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        {
            text = function() return "    X BLEED FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - X BLEED........MAN CTL" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " . IF MAN INOP AND SINGLE" end,
            color = function() return COL_REMARKS end,
            is_active = function() return true end
        },
        {
            text = function() return "   BLEED:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return true end
        },
        Message_WING_ANTI_ICE_OFF_2ND_LVL,
        Message_AVOID_ICE_2ND_LVL
    },

    is_active = function()
        return get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

