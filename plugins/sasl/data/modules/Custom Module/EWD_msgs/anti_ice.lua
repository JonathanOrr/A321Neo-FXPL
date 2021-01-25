include('EWD_msgs/common.lua')

local ENG_1  = 1
local ENG_2  = 2
local WINGS  = 3
local PROBES = 4


----------------------------------------------------------------------------------------------------
-- CAUTION: WING A.ICE OPEN ON GND
----------------------------------------------------------------------------------------------------

MessageGroup_WAI_OPEN_ON_GND = {

    shown = false,

    text  = function()
                return "WING A.ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        {
            text = function() return "           OPEN ON GND" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - WING ANTI ICE......OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return AI_sys.switches[WINGS] end
        }
    },
    
    start_time = 0,

    is_active = function()
        local self = MessageGroup_WAI_OPEN_ON_GND
        if get(All_on_ground) == 1 and (AI_sys.comp[ANTIICE_WING_L].valve_status or AI_sys.comp[ANTIICE_WING_R].valve_status) then
            if self.start_time == 0 then
                self.start_time = get(TIME)
                return false
            end
            if get(TIME) - self.start_time > 35 then
                return true
            end
        else
            self.start_time = 0
            return false
        end
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: WING A.ICE SYS FAULT
----------------------------------------------------------------------------------------------------

local Message_AVOID_ICING_COND_LVL2 = {
    text = function() return "   AVOID ICING CONDITIONS" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}

MessageGroup_WAI_SYS_FAULT_1 = {

    shown = false,

    text  = function()
                return "WING A.ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        {
            text = function() return "           SYS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - THRUST........INCREASE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " . IF UNSUCCESSFUL:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return AI_sys.switches[WINGS] end
        },
        {
            text = function() return "   - WING ANTI ICE....OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return AI_sys.switches[WINGS] end
        },
        Message_AVOID_ICING_COND_LVL2
    },
    
    start_time = 0,

    is_active = function()
        return AI_sys.switches[WINGS] == true and (not AI_sys.comp[ANTIICE_WING_L].valve_status or not AI_sys.comp[ANTIICE_WING_R].valve_status) and get(L_bleed_press) > 5 and get(R_bleed_press) > 5
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

MessageGroup_WAI_SYS_FAULT_2 = {

    shown = false,

    text  = function()
                return "WING A.ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        {
            text = function() return "           SYS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - X BLEED...........OPEN" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(X_bleed_dial) ~= 2 end
        }
    },
    
    start_time = 0,

    is_active = function()
        return AI_sys.switches[WINGS] == true and (not AI_sys.comp[ANTIICE_WING_L].valve_status or not AI_sys.comp[ANTIICE_WING_R].valve_status) and (get(L_bleed_press) <= 5 and get(R_bleed_press) > 5) or (get(L_bleed_press) > 5 and get(R_bleed_press) <= 5)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: WING A.ICE L (R) VALVE OPEN
----------------------------------------------------------------------------------------------------

MessageGroup_WAI_L_R_OPEN = {

    shown = false,

    text  = function()
                return "WING A.ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        {

            text = function()
                local N = ""
                if AI_sys.comp[ANTIICE_WING_L].valve_status and AI_sys.comp[ANTIICE_WING_R].valve_status then
                    N = "L+R"
                elseif AI_sys.comp[ANTIICE_WING_L].valve_status then
                    N = "L"
                elseif AI_sys.comp[ANTIICE_WING_R].valve_status then
                    N = "R"
                end
                return "           " .. N ..  " VALVE OPEN"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " WAI AVAIL IN FLIGHT" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " WING ANTI ICE....AS RQRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " THRUST LIM PENALTY" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
    },
    
    start_time = 0,

    is_active = function()
        return AI_sys.switches[WINGS] == false and (AI_sys.comp[ANTIICE_WING_L].valve_status or AI_sys.comp[ANTIICE_WING_R].valve_status)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}
