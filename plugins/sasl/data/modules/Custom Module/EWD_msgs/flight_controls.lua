--------------------------------------------------------------------------------
-- NORMAL: GND SPLRS ARMED
--------------------------------------------------------------------------------

MessageGroup_GND_SPEEDBRAKES = {

    shown = false,

    text  = function(self)
                return ""
            end,
    color = function(self)
                return COL_INDICATION
            end,

    priority = PRIORITY_LEVEL_MEMO,

    messages = {
        {
            text = function(self)
                    return "GND SPLRS ARMED"
            end,
            color = function(self)
                    return COL_INDICATION
            end,
            is_active = function(self)
              return true
            end
        }
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Not showed when any memo is active
        return get(SPDBRK_HANDLE_RATIO) < 0 and get(EWD_is_to_memo_showed) == 0 and get(EWD_is_ldg_memo_showed) == 0
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}


--------------------------------------------------------------------------------
-- CAUTION: GND SPLRS NOT ARMED
--------------------------------------------------------------------------------

MessageGroup_GND_SPLRS_NOT_ARMED = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function() return "      GND SPLR NOT ARMED" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    sd_page = nil,

    is_active = function()
        return get(SPDBRK_HANDLE_RATIO) >= 0 and get(Gear_handle) > 0 and get(Capt_ra_alt_ft) <= 500 and get(EWD_flight_phase) == PHASE_FINAL
    end,

    is_inhibited = function()
        return is_active_in({PHASE_FINAL})
    end

}

--------------------------------------------------------------------------------
-- CAUTION: SPD BRK STILL OUT
--------------------------------------------------------------------------------

MessageGroup_SPD_BRK_STILL_OUT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function() return "      SPD BRK STILL OUT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    sd_page = nil,

    is_active = function()
        local limit_1 = ENG.dyn[1].n1_idle + 5
        local limit_2 = ENG.dyn[2].n1_idle + 5
        return get(Speedbrake_handle_ratio) > 0.05 and (ENG.dyn[1].n1 > limit_1 or ENG.dyn[2].n1 > limit_2)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_AIRBONE, PHASE_FINAL})
    end

}


--------------------------------------------------------------------------------
-- WARNING: FLAP LVR NOT ZERO
--------------------------------------------------------------------------------

MessageGroup_FLAP_LVR_NOT_ZERO = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        {
            text = function() return "      FLAP LVR NOT ZERO" end,
            color = function() return COL_WARNING end,
            is_active = function() return true end
        }
    },

    sd_page = nil,

    is_active = function()
        return get(Flaps_internal_config) ~= 0 and get(Capt_baro_alt_ft) > 22000
    end,

    is_inhibited = function()
        return is_active_in({PHASE_AIRBONE})
    end

}


--------------------------------------------------------------------------------
-- CAUTION: L+R AIL FAULT
--------------------------------------------------------------------------------

MessageGroup_FCTL_AIL_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                local x = "?"
                if get(FAILURE_FCTL_LAIL) == 1 and get(FAILURE_FCTL_RAIL) == 1 then
                    x = "L+R"
                elseif get(FAILURE_FCTL_LAIL) == 1 then
                    x = "L"
                elseif get(FAILURE_FCTL_RAIL) == 1 then
                    x = "R"
                end
                return "      " .. x .. " AIL FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " FUEL CONSUMPT INCRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " FMS PRED UNRELIABLE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        return get(FAILURE_FCTL_LAIL) == 1 or get(FAILURE_FCTL_RAIL) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF})
    end

}


--------------------------------------------------------------------------------
-- CAUTION: L or R ELEV FAULT
--------------------------------------------------------------------------------

MessageGroup_FCTL_LR_ELEV_FAULT_SINGLE = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    thr_lvl_cond = 0,

    messages = {
        {
            text = function()
                local x = "?"
                if get(FAILURE_FCTL_LELEV) == 1 then
                    x = "L"
                elseif get(FAILURE_FCTL_RELEV) == 1 then
                    x = "R"
                end
                return "      " .. x .. " ELEV FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " MANEUVER WITH CARE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " FOR GA: MAX PITCH 15 DEG" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " - THE LVR..TOGA THEN MCT" end,
            color = function() return COL_ACTIONS end,
            is_active = function()
                if MessageGroup_FCTL_LR_ELEV_FAULT_SINGLE.thr_lvl_cond == 0 and get(Cockpit_throttle_lever_L) > 0.99 and get(Cockpit_throttle_lever_R) > 0.99 then
                    MessageGroup_FCTL_LR_ELEV_FAULT_SINGLE.thr_lvl_cond = 1
                elseif MessageGroup_FCTL_LR_ELEV_FAULT_SINGLE.thr_lvl_cond == 1 and get(Cockpit_throttle_lever_L) < 0.99 and get(Cockpit_throttle_lever_R) < 0.99 then
                    MessageGroup_FCTL_LR_ELEV_FAULT_SINGLE.thr_lvl_cond = 2
                end
                return MessageGroup_FCTL_LR_ELEV_FAULT_SINGLE.thr_lvl_cond < 2
            end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        local condition = (get(FAILURE_FCTL_LELEV) == 1 or get(FAILURE_FCTL_RELEV) == 1) and not (get(FAILURE_FCTL_LELEV) == 1 and get(FAILURE_FCTL_RELEV) == 1)
        if not condition then
            MessageGroup_FCTL_LR_ELEV_FAULT_SINGLE.thr_lvl_cond = 0
        end
        return condition
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF})
    end

}


--------------------------------------------------------------------------------
-- WARNING: L+R ELEV FAULT
--------------------------------------------------------------------------------

MessageGroup_FCTL_LR_ELEV_FAULT_DOUBLE = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    thr_lvl_cond = 0,

    messages = {
        {
            text = function()
                return "      L+R ELEV FAULT"
            end,
            color = function() return COL_WARNING end,
            is_active = function() return true end
        },
        {
            text = function() return " - MAX SPD........320/.77" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " - MAN PITCH TRIM.....USE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " - SPD BRK.....DO NOT USE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        return not FCTL.ELEV.STAT.L.controlled and not FCTL.ELEV.STAT.R.controlled
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}



--------------------------------------------------------------------------------
-- CAUTION: STABILIZER JAM
--------------------------------------------------------------------------------

MessageGroup_FCTL_STAB_JAM = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "      STABILIZER JAM"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - MAN PITCH TRIM...CHECK" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " . IF MAN TRIM AVAIL:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return true end
        },
        {
            text = function() return "   TRIM FOR NEUTRAL ELEV" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return "   MANEUVER WITH CARE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        return get(FAILURE_FCTL_THS_MECH) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF})
    end

}


--------------------------------------------------------------------------------
-- CAUTION: SPLR FAULT
--------------------------------------------------------------------------------

local function any_extented_at(angle)
    if get(FAILURE_FCTL_LSPOIL_1) == 1 and get(L_SPLR_1) >= angle then
        return true
    end
    if get(FAILURE_FCTL_LSPOIL_2) == 1 and get(L_SPLR_2) >= angle then
        return true
    end
    if get(FAILURE_FCTL_LSPOIL_3) == 1 and get(L_SPLR_3) >= angle then
        return true
    end
    if get(FAILURE_FCTL_LSPOIL_4) == 1 and get(L_SPLR_4) >= angle then
        return true
    end
    if get(FAILURE_FCTL_LSPOIL_5) == 1 and get(L_SPLR_5) >= angle then
        return true
    end
    if get(FAILURE_FCTL_RSPOIL_1) == 1 and get(R_SPLR_1) >= angle then
        return true
    end
    if get(FAILURE_FCTL_RSPOIL_2) == 1 and get(R_SPLR_2) >= angle then
        return true
    end
    if get(FAILURE_FCTL_RSPOIL_3) == 1 and get(R_SPLR_3) >= angle then
        return true
    end
    if get(FAILURE_FCTL_RSPOIL_4) == 1 and get(R_SPLR_4) >= angle then
        return true
    end
    if get(FAILURE_FCTL_RSPOIL_5) == 1 and get(R_SPLR_5) >= angle then
        return true
    end

    return false
end

MessageGroup_FCTL_SPLR_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "      SPLR FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - OPT SPD.....G.DOT+10KT" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return any_extented_at(24) end
        },
        {
            text = function() return " - AP..........DO NOT USE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return any_extented_at(24) end
        },
        {
            text = function() return " - SPD BRK.....DO NOT USE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_FCTL_LSPOIL_3) + get(FAILURE_FCTL_LSPOIL_4) + get(FAILURE_FCTL_RSPOIL_3) + get(FAILURE_FCTL_RSPOIL_4) > 0 end
        },
        {
            text = function() return " FUEL CONSUMPT INCRSD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return any_extented_at(2.5) end
        },
        {
            text = function() return " FMS PRED UNRELIABLE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return any_extented_at(2.5) end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        return get(FAILURE_FCTL_LSPOIL_1) + get(FAILURE_FCTL_LSPOIL_2) + get(FAILURE_FCTL_LSPOIL_3)
             + get(FAILURE_FCTL_LSPOIL_4) + get(FAILURE_FCTL_LSPOIL_5)
             + get(FAILURE_FCTL_RSPOIL_1) + get(FAILURE_FCTL_RSPOIL_2) + get(FAILURE_FCTL_RSPOIL_3)
             + get(FAILURE_FCTL_RSPOIL_4) + get(FAILURE_FCTL_RSPOIL_5) > 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL})
    end

}

--------------------------------------------------------------------------------
-- CAUTION: GND SPLR 5 FAULT
--------------------------------------------------------------------------------

MessageGroup_FCTL_GND_SPLR_5_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "      GND SPLR 5 FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        return false --get(SEC_2_status) == 0 and get(SEC_1_status) + get(SEC_2_status) + get(SEC_3_status) >= 2
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

--------------------------------------------------------------------------------
-- CAUTION: GND SPLR 1+2/3+4/() FAULT
--------------------------------------------------------------------------------

MessageGroup_FCTL_GND_SPLR_1234_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "      GND SPLR 1+2 FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return false end --get(SEC_3_status) == 0 and get(SEC_1_status) == 1 and get(SEC_2_status) == 1 end
        },
        {
            text = function()
                return "      GND SPLR 3+4 FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return false end --get(SEC_1_status) == 0 and get(SEC_3_status) == 1 and get(SEC_2_status) == 1 end
        },
        {
            text = function()
                return "      GND SPLR FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return false end--get(SEC_1_status) + get(SEC_2_status) + get(SEC_3_status) < 2 end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        return false --get(SEC_3_status) == 0 or get(SEC_1_status) == 0
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}



