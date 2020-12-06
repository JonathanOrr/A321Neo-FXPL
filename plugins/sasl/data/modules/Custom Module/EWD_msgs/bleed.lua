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

----------------------------------------------------------------------------------------------------
-- CAUTION: BLEED MONITORING SYSTEM
----------------------------------------------------------------------------------------------------
local Message_BLEED_BMC_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_BLEED_BMC_1) == 1 and get(FAILURE_BLEED_BMC_2) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_BLEED_BMC_1) == 1 then
            N = "1"
        elseif get(FAILURE_BLEED_BMC_2) == 1 then
            N = "2"
        end
        return "      MONIT SYS " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_BLEED_BMC_FAULT = {

    shown = false,

    text  = function()
                return "BLEED"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        Message_BLEED_BMC_FAULT
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_BMC_1) == 1 or get(FAILURE_BLEED_BMC_2) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: BLEED FAULT
----------------------------------------------------------------------------------------------------

local Message_BLEED_X_OPEN = {
    text = function() return " - X BLEED...........OPEN" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(X_bleed_dial) ~= 2 end
}

MessageGroup_BLEED_ENG1_FAULT = {

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
        {   text = function() return "    ENG 1 BLEED FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - ENG BLEED 1........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(ENG_1_bleed_switch) == 1 end
        },
        {
            text = function() return " . IF WING A.I. REQUIRED" end,
            color = function() return COL_REMARKS end,
            is_active = function() return get(Pack_L) == 1 end
        },
        {
            text = function() return "   AND PACK 2 AVAIL:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return get(Pack_L) == 1 end
        },
        {
            text = function() return "   - PACK 1...........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Pack_L) == 1 end
        },
        Message_BLEED_X_OPEN
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(L_bleed_press) > 57 or get(L_bleed_temp) > 270
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end

}

MessageGroup_BLEED_ENG2_FAULT = {

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
        {   text = function() return "    ENG 2 BLEED FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - ENG BLEED 2........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(ENG_1_bleed_switch) == 1 end
        },
        {
            text = function() return " . IF WING A.I. REQUIRED" end,
            color = function() return COL_REMARKS end,
            is_active = function() return get(Pack_L) == 1 end
        },
        {
            text = function() return "   AND PACK 1 AVAIL:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return get(Pack_L) == 1 end
        },
        {
            text = function() return "   - PACK 2...........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Pack_L) == 1 end
        },
        Message_BLEED_X_OPEN
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(R_bleed_press) > 57 or get(R_bleed_temp) > 270
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: ENG X HP VALVE FAULT
----------------------------------------------------------------------------------------------------
local Message_BLEED_HP_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_BLEED_HP_1_VALVE_STUCK) == 1 and get(FAILURE_BLEED_HP_2_VALVE_STUCK) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_BLEED_HP_1_VALVE_STUCK) == 1 then
            N = "1"
        elseif get(FAILURE_BLEED_HP_2_VALVE_STUCK) == 1 then
            N = "2"
        end
        return "    ENG " .. N .. " HP VALVE FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_BLEED_HP_FAULT = {

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
        Message_BLEED_HP_FAULT
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_HP_1_VALVE_STUCK) == 1 or get(FAILURE_BLEED_HP_2_VALVE_STUCK) == 1 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ENG X IP VALVE FAULT
----------------------------------------------------------------------------------------------------
local Message_BLEED_IP_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 1 and get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 1 then
            N = "1"
        elseif get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 1 then
            N = "2"
        end
        return "    ENG " .. N .. " IP VALVE FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_BLEED_IP_FAULT = {

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
        Message_BLEED_IP_FAULT
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_IP_1_VALVE_STUCK) == 1 or get(FAILURE_BLEED_IP_2_VALVE_STUCK) == 1 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: APU VALVE FAULT
----------------------------------------------------------------------------------------------------
MessageGroup_BLEED_APU_FAULT = {

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
            text = function() return "    APU BLEED FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_APU_VALVE_STUCK) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: APU LEAK
----------------------------------------------------------------------------------------------------
MessageGroup_BLEED_APU_LEAK = {

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
            text = function() return "    APU BLEED LEAK" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - APU BLEED..........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Apu_bleed_switch) == 1 end
        },
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_APU_LEAK) == 1 and get(Apu_bleed_switch) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ENG X BLEED LEAK
----------------------------------------------------------------------------------------------------
local Message_BLEED_ENG_LEAK = {
    text = function()
        local N = ""
        if get(FAILURE_BLEED_ENG_1_LEAK) == 1 and get(FAILURE_BLEED_ENG_2_LEAK) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_BLEED_ENG_1_LEAK) == 1 then
            N = "1"
        elseif get(FAILURE_BLEED_ENG_2_LEAK) == 1 then
            N = "2"
        end
        return "    ENG " .. N .. " BLEED LEAK"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}


local Message_BLEED_X_SHUT = {
    text = function() return " - X BLEED...........SHUT" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(X_bleed_dial) ~= 0 end
}

local Message_WING_ANTI_ICE_OFF_1ST_LVL = {
    text = function()
        return " - WING ANTI-ICE......OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return AI_sys.switches[3]
    end
}

local Message_AVOID_ICE_1ST_LVL = {
    text = function()
        return " AVOID ICING CONDITIONS"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true
    end
}

MessageGroup_BLEED_ENG_LEAK = {

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
        Message_BLEED_ENG_LEAK,
        {
            text = function() return " - ENG 1 BLEED........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_ENG_1_LEAK) == 1 and get(ENG_1_bleed_switch) == 1 end
        },
        {
            text = function() return " - ENG 2 BLEED........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_ENG_2_LEAK) == 1 and get(ENG_2_bleed_switch) == 1 end
        },
        Message_BLEED_X_SHUT,
        Message_WING_ANTI_ICE_OFF_1ST_LVL,
        Message_AVOID_ICE_1ST_LVL
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_ENG_1_LEAK) == 1 or get(FAILURE_BLEED_ENG_2_LEAK) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: WING X BLEED LEAK
----------------------------------------------------------------------------------------------------
local Message_BLEED_WING_LEAK = {
    text = function()
        local N = ""
        if get(FAILURE_BLEED_WING_L_LEAK) == 1 and get(FAILURE_BLEED_WING_R_LEAK) == 1 then
            N = "L + R"
        elseif get(FAILURE_BLEED_WING_L_LEAK) == 1 then
            N = "L"
        elseif get(FAILURE_BLEED_WING_R_LEAK) == 1 then
            N = "R"
        end
        return "    WING " .. N .. " BLEED LEAK"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}



MessageGroup_BLEED_WING_LEAK = {

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
        Message_BLEED_WING_LEAK,
        {
            text = function() return " - ENG 1 BLEED........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_WING_L_LEAK) == 1 and get(ENG_1_bleed_switch) == 1 end
        },
        {
            text = function() return " - ENG 2 BLEED........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_WING_R_LEAK) == 1 and get(ENG_2_bleed_switch) == 1 end
        },
        {
            text = function() return " - APU BLEED..........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_WING_L_LEAK) == 1 and get(Apu_bleed_switch) == 1 end
        },
        Message_BLEED_X_SHUT,
        Message_WING_ANTI_ICE_OFF_1ST_LVL,
        Message_AVOID_ICE_1ST_LVL
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_WING_L_LEAK) == 1 or get(FAILURE_BLEED_WING_R_LEAK) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}
