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

local Message_THRUST_LIM_PENALTY =
{
    text = function() return " THRUST LIM PENALTY" end,
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
        Message_THRUST_LIM_PENALTY
    },
    
    start_time = 0,

    is_active = function()
        return AI_sys.switches[WINGS] == false and (AI_sys.comp[ANTIICE_WING_L].valve_status or AI_sys.comp[ANTIICE_WING_R].valve_status)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: ENG 1 (2) VALVE CLSD
----------------------------------------------------------------------------------------------------

local Message_AVOID_ICING_COND_LVL1 = {
    text = function() return " AVOID ICING CONDITIONS" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}

MessageGroup_EAI_VLV_CLSD = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function()
                local N = ""
                local ai_eng_1 = (AI_sys.switches[ENG_1] and not AI_sys.comp[ENG_1].valve_status)
                local ai_eng_2 = (AI_sys.switches[ENG_2] and not AI_sys.comp[ENG_2].valve_status)

                if ai_eng_1 and ai_eng_2 then
                    N = "1+2"
                elseif ai_eng_1 then
                    N = "1"
                elseif ai_eng_2 then
                    N = "2"
                end
                return "         ENG " .. N ..  " VALVE CLSD"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AVOID_ICING_COND_LVL1
    },

    is_active = function()
        return (AI_sys.switches[ENG_1] and not AI_sys.comp[ENG_1].valve_status) or (AI_sys.switches[ENG_2] and not AI_sys.comp[ENG_2].valve_status)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: ENG 1 (2) VALVE OPEN
----------------------------------------------------------------------------------------------------

MessageGroup_EAI_VLV_OPEN = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function()
                local N = ""
                local ai_eng_1 = (not AI_sys.switches[ENG_1] and AI_sys.comp[ENG_1].valve_status)
                local ai_eng_2 = (not AI_sys.switches[ENG_2] and AI_sys.comp[ENG_2].valve_status)

                if ai_eng_1 and ai_eng_2 then
                    N = "1+2"
                elseif ai_eng_1 then
                    N = "1"
                elseif ai_eng_2 then
                    N = "2"
                end
                return "         ENG " .. N ..  " VALVE OPEN"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_THRUST_LIM_PENALTY
    },

    is_active = function()
        return (not AI_sys.switches[ENG_1] and AI_sys.comp[ENG_1].valve_status) or (not AI_sys.switches[ENG_2] and AI_sys.comp[ENG_2].valve_status)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE L(R) WINDSHIELD
----------------------------------------------------------------------------------------------------

MessageGroup_AI_WINDSHIELD = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function()
                local N = ""
                local ai_w_L = get(FAILURE_AI_Window_Heat_L) == 1
                local ai_w_R = get(FAILURE_AI_Window_Heat_R) == 1

                if ai_w_L and ai_w_R then
                    N = "L + R"
                elseif ai_w_L then
                    N = "L"
                elseif ai_w_R then
                    N = "R"
                end
                return "         " .. N ..  " WINDSHIELD"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_AI_Window_Heat_L) + get(FAILURE_AI_Window_Heat_R) >= 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE CAPT/FO/STBY PITOT
----------------------------------------------------------------------------------------------------

local Message_AIRDATA_TO_CAPT3 = {
    text = function() return " - AIR DATA SWTG...CAPT 3" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(ADIRS_source_rotary_AIRDATA) ~= -1 end
}

local Message_AIRDATA_TO_FO3 = {
    text = function() return " - AIR DATA SWTG.....FO 3" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(ADIRS_source_rotary_AIRDATA) ~= 1 end
}

MessageGroup_AI_CAPT_PITOT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         CAPT PITOT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRDATA_TO_CAPT3
    },

    is_active = function()
        return get(FAILURE_AI_PITOT_CAPT) == 1 and get(FAILURE_AI_PITOT_FO) == 0 and get(FAILURE_AI_PITOT_STDBY) == 0
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

MessageGroup_AI_FO_PITOT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         F/O PITOT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRDATA_TO_FO3
    },

    is_active = function()
        return get(FAILURE_AI_PITOT_CAPT) == 0 and get(FAILURE_AI_PITOT_FO) == 1 and get(FAILURE_AI_PITOT_STDBY) == 0
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


MessageGroup_AI_STBY_PITOT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         STBY PITOT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_AI_PITOT_CAPT) == 0 and get(FAILURE_AI_PITOT_FO) == 0 and get(FAILURE_AI_PITOT_STDBY) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE CAPT/FO/STBY STAT
----------------------------------------------------------------------------------------------------

MessageGroup_AI_CAPT_STAT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         CAPT STAT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRDATA_TO_CAPT3
    },

    is_active = function()
        return get(FAILURE_AI_SP_CAPT) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

MessageGroup_AI_FO_STAT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         F/O STAT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRDATA_TO_FO3
    },

    is_active = function()
        return get(FAILURE_AI_SP_FO) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


MessageGroup_AI_STBY_STAT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         STBY STAT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_AI_SP_STDBY) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE CAPT/FO/STBY AOA
----------------------------------------------------------------------------------------------------

MessageGroup_AI_CAPT_AOA = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         CAPT AOA" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRDATA_TO_CAPT3
    },

    is_active = function()
        return get(FAILURE_AI_AOA_CAPT) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

MessageGroup_AI_FO_AOA = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         F/O AOA" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRDATA_TO_FO3
    },

    is_active = function()
        return get(FAILURE_AI_AOA_FO) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


MessageGroup_AI_STBY_AOA = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         STBY AOA" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_AI_AOA_STDBY) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE CAPT/FO/STBY TAT
----------------------------------------------------------------------------------------------------

MessageGroup_AI_CAPT_TAT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         CAPT TAT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_AI_TAT_CAPT) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

MessageGroup_AI_FO_TAT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         F/O TAT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_AI_TAT_FO) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE CAPT+FO PITOT DOUBLE
----------------------------------------------------------------------------------------------------

MessageGroup_AI_CAPT_FO_PITOT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         CAPT+F/O PITOT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {

            text = function() return " - ADR 1..............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_1].adr_switch_status and ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_ON end
        },
        {

            text = function() return " . IF ICING EXPECTED:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_ON end
        },
        {

            text = function() return "   - ADR 1............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_1].adr_switch_status and ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_ON end
        },
        {

            text = function() return "   UNREL SPD PROC...APPLY" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_ON end
        },

    },

    is_active = function()
        return get(FAILURE_AI_PITOT_CAPT) == 1 and get(FAILURE_AI_PITOT_FO) == 1 and get(FAILURE_AI_PITOT_STDBY) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_TOUCHDOWN})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE CAPT+STBY PITOT DOUBLE
----------------------------------------------------------------------------------------------------

MessageGroup_AI_CAPT_STBY_PITOT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         CAPT+STBY PITOT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {

            text = function() return " - ADR 3..............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_3].adr_switch_status and ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_ON end
        },
        {

            text = function() return " . IF ICING EXPECTED:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_ON end
        },
        {

            text = function() return "   - ADR 3............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_3].adr_switch_status and ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_ON end
        },
        {

            text = function() return "   UNREL SPD PROC...APPLY" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_ON end
        },

    },

    is_active = function()
        return get(FAILURE_AI_PITOT_CAPT) == 1 and get(FAILURE_AI_PITOT_FO) == 0 and get(FAILURE_AI_PITOT_STDBY) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_TOUCHDOWN})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE FO+STBY PITOT DOUBLE
----------------------------------------------------------------------------------------------------

MessageGroup_AI_FO_STBY_PITOT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         F/O+STBY PITOT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {

            text = function() return " - ADR 2..............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_2].adr_switch_status and ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_ON end
        },
        {

            text = function() return " . IF ICING EXPECTED:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_ON end
        },
        {

            text = function() return "   - ADR 2............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_2].adr_switch_status and ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_ON end
        },
        {

            text = function() return "   UNREL SPD PROC...APPLY" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_ON end
        },

    },

    is_active = function()
        return get(FAILURE_AI_PITOT_CAPT) == 0 and get(FAILURE_AI_PITOT_FO) == 1 and get(FAILURE_AI_PITOT_STDBY) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_TOUCHDOWN})
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: ANTICE ALL PITOT
----------------------------------------------------------------------------------------------------

MessageGroup_AI_ALL_PITOT = {

    shown = false,

    text  = function()
                return "ANTI ICE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {

            text = function() return "         ALL PITOT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {

            text = function() return " - ADR 3..............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_3].adr_switch_status end
        },
        {

            text = function() return " . IF ICING EXPECTED:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return true end
        },
        {

            text = function() return "   - ADR 1............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return ADIRS_sys[ADIRS_1].adr_switch_status end
        },
        {

            text = function() return "   UNREL SPD PROC...APPLY" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },

    },

    is_active = function()
        return get(FAILURE_AI_PITOT_CAPT) == 1 and get(FAILURE_AI_PITOT_FO) == 1 and get(FAILURE_AI_PITOT_STDBY) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_TOUCHDOWN})
    end

}

