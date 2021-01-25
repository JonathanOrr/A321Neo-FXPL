include('EWD_msgs/common.lua')
--------------------------------------------------------------------------------
-- NORMAL: REFUELG
--------------------------------------------------------------------------------

MessageGroup_REFUELG = {

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
                    return "REFUELG"
            end,
            color = function(self)
                    return COL_INDICATION
            end,
            is_active = function(self)
              return true
            end
        }
    },

    is_active = function(self)
        return get(Fuel_is_refuelG) == 1
    end,

    is_inhibited = function(self)
        return false
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: L TK PUMP 1/2 OFF
----------------------------------------------------------------------------------------------------


MessageGroup_FUEL_L_TK_PUMP_OFF = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                x = ""
                if Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_1].switch == false and get(FAILURE_FUEL, L_TK_PUMP_1) == 0 then
                    x = x .. "1"
                end
                if Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_2].switch == false and get(FAILURE_FUEL, L_TK_PUMP_2) == 0  then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     L TK PUMP " .. x .. " OFF"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return (Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_1].switch == false and get(FAILURE_FUEL, 1) == 0) 
            or (Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_2].switch == false and get(FAILURE_FUEL, 2) == 0)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: R TK PUMP 1/2 OFF
----------------------------------------------------------------------------------------------------


MessageGroup_FUEL_R_TK_PUMP_OFF = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                x = ""
                if Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_1].switch == false and get(FAILURE_FUEL, R_TK_PUMP_1) == 0 then
                    x = x .. "1"
                end
                if Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_2].switch == false and get(FAILURE_FUEL, R_TK_PUMP_2) == 0  then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     R TK PUMP " .. x .. " OFF"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        }
    },

    is_active = function(self)
        return (Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_1].switch == false and get(FAILURE_FUEL, R_TK_PUMP_1) == 0) 
            or (Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_2].switch == false and get(FAILURE_FUEL, R_TK_PUMP_2) == 0)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: CTR TK PUMP 1/2 OFF
----------------------------------------------------------------------------------------------------
Message_FUEL_CTR_TK_1_ON = {
    text = function(self) return " - CTR TK XFR 1........ON" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return not Fuel_sys.tank_pump_and_xfr[C_TK_XFR_1].switch end
}

Message_FUEL_CTR_TK_2_ON = {
    text = function(self) return " - CTR TK XFR 2........ON" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return not Fuel_sys.tank_pump_and_xfr[C_TK_XFR_2].switch end
}

MessageGroup_FUEL_C_TK_XFR_OFF = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                x = ""
                if Fuel_sys.tank_pump_and_xfr[C_TK_XFR_1].switch == false and get(FAILURE_FUEL, C_TK_XFR_1) == 0 then
                    x = x .. "1"
                end
                if Fuel_sys.tank_pump_and_xfr[C_TK_XFR_2].switch == false and get(FAILURE_FUEL, C_TK_XFR_2) == 0  then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     CTR TK XFR " .. x .. " OFF"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_CTR_TK_1_ON,
        Message_FUEL_CTR_TK_2_ON
        
    },

    is_active = function(self)
        return not PB.ovhd.fuel_MODE_SEL.status_bottom and ((Fuel_sys.tank_pump_and_xfr[C_TK_XFR_1].switch == false and get(FAILURE_FUEL, C_TK_XFR_1) == 0) 
            or (Fuel_sys.tank_pump_and_xfr[C_TK_XFR_2].switch == false and get(FAILURE_FUEL, C_TK_XFR_2) == 0))
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: CTR TK PUMP 1/2 LO PR
----------------------------------------------------------------------------------------------------
Message_FUEL_CTR_TK_1_OFF = {
    text = function() return " - CTR TK XFR 1.......OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(FAILURE_FUEL, C_TK_XFR_1) == 1 and Fuel_sys.tank_pump_and_xfr[C_TK_XFR_1].switch end
}

Message_FUEL_CTR_TK_2_OFF = {
    text = function() return " - CTR TK XFR 2.......OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(FAILURE_FUEL, C_TK_XFR_2) == 1 and Fuel_sys.tank_pump_and_xfr[C_TK_XFR_2].switch end
}

Message_FUEL_IF_NO_FUEL_LEAK_CTR_LO_PR = {
    text = function() return " · IF NO FUEL LEAK:" end,
    color = function() return COL_REMARKS end,
    is_active = function() return Message_FUEL_X_FEED_ON.is_active() end
}

Message_FUEL_X_FEED_ON = {
    text = function() return "   - FUEL X FEED.......ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return not PB.ovhd.fuel_XFEED.status_top end
}


MessageGroup_FUEL_C_TK_XFR_LO_PR_SINGLE = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(FAILURE_FUEL, C_TK_XFR_1) == 1 then
                    x = "1"
                elseif get(FAILURE_FUEL, C_TK_XFR_2) == 1  then
                    x = "2"
                end
                return "     CTR TK XFR " .. x .. " LO PR"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_IF_NO_FUEL_LEAK_CTR_LO_PR,
        Message_FUEL_X_FEED_ON,
        Message_FUEL_CTR_TK_1_OFF,
        Message_FUEL_CTR_TK_2_OFF
        
    },

    is_active = function(self)
        return get(FAILURE_FUEL, C_TK_XFR_1) + get(FAILURE_FUEL, C_TK_XFR_2) == 1 
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

Message_FUEL_CTR_TK_UNUSABLE = {
    text = function() return " CTR TK UNUSABLE" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}

MessageGroup_FUEL_C_TK_XFR_LO_PR_DOUBLE = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function() return "     CTR TK XFR 1 + 2 LO PR" end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_CTR_TK_1_OFF,
        Message_FUEL_CTR_TK_2_OFF,
        Message_FUEL_CTR_TK_UNUSABLE
    },

    is_active = function(self)
        return get(FAILURE_FUEL, C_TK_XFR_1) == 1 and get(FAILURE_FUEL, C_TK_XFR_2) == 1 
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: L/R WING TK LO LVL
----------------------------------------------------------------------------------------------------
Message_FUEL_DO_NOT_APPLY_F_LEAK = {
    text = function(self) return " . IF NO FUEL LEAK AND" end,
    color = function(self) return COL_REMARKS end,
    is_active = function(self) return true end
}
Message_FUEL_DO_NOT_APPLY_F_LEAK_2 = {
    text = function(self) return "   FUEL IMBALANCE" end,
    color = function(self) return COL_REMARKS end,
    is_active = function(self) return true end
}

Message_FUEL_X_FEED = {
    text = function(self) return " - FUEL X FEED.........ON" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return not PB.ovhd.fuel_XFEED.status_top end
}
Message_FUEL_LO_LVL_L_TK_PUMP_1_OFF = {
    text = function(self) return " - L TK PUMP 1........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_LEFT]) < 750 and Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_1].switch == true end
}
Message_FUEL_LO_LVL_L_TK_PUMP_2_OFF = {
    text = function(self) return " - L TK PUMP 2........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_LEFT]) < 750 and Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_2].switch == true end
}
Message_FUEL_LO_LVL_R_TK_PUMP_1_OFF = {
    text = function(self) return " - R TK PUMP 1........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_RIGHT]) < 750 and Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_1].switch == true end
}
Message_FUEL_LO_LVL_R_TK_PUMP_2_OFF = {
    text = function(self) return " - R TK PUMP 2........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_RIGHT]) < 750 and Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_2].switch == false end
}

MessageGroup_FUEL_WING_LO_LVL_SINGLE = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(Fuel_quantity[tank_LEFT]) < 750 then
                    x = "L"
                end
                if get(Fuel_quantity[tank_RIGHT]) < 750 then
                    x = "R"
                end
                return "     " .. x .. " WING TK LO LVL"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_DO_NOT_APPLY_F_LEAK,
        Message_FUEL_DO_NOT_APPLY_F_LEAK_2,
        Message_FUEL_X_FEED,
        Message_FUEL_LO_LVL_L_TK_PUMP_1_OFF,
        Message_FUEL_LO_LVL_L_TK_PUMP_2_OFF,
        Message_FUEL_LO_LVL_R_TK_PUMP_1_OFF,
        Message_FUEL_LO_LVL_R_TK_PUMP_2_OFF
    },

    is_active = function(self)
        return (get(Fuel_quantity[tank_LEFT]) < 750 or get(Fuel_quantity[tank_RIGHT]) < 750) and
                not (get(Fuel_quantity[tank_LEFT]) < 750 and get(Fuel_quantity[tank_RIGHT]) < 750)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: L + R WING TK LO LVL
----------------------------------------------------------------------------------------------------

Message_FUEL_LO_LVL_FUEL_MODE = {
    text = function(self) return " - FUEL MODE SEL......MAN" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return not PB.ovhd.fuel_MODE_SEL.status_top end
}
Message_FUEL_LO_LVL_ALL_ON = {
    text = function(self) return " - ALL TK PUMPS........ON" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}


MessageGroup_FUEL_WING_LO_LVL_DOUBLE = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    land_asap = true,
    
    messages = {
        {
            text = function(self)
                return "     L + R WING TK LO LVL"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_LO_LVL_FUEL_MODE,
        Message_FUEL_LO_LVL_ALL_ON,
        Message_FUEL_X_FEED
    },

    is_active = function(self)
        return (get(Fuel_quantity[tank_LEFT]) < 750) and (get(Fuel_quantity[tank_RIGHT]) < 750)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: FOB DISAGREE
----------------------------------------------------------------------------------------------------

Message_FUEL_FUEL_LEAK_PROC = {
    text = function(self) return " - FUEL LEAK PROC...APPLY" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return true end
}


MessageGroup_FUEL_FUSED_FOB_DISAGREE = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                return "     F.USED/FOB DISAGREE"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_FUEL_LEAK_PROC
    },

    is_active = function(self)
        return get(Fuel_on_takeoff) ~= 0 and (get(Fuel_on_takeoff) - (get(FOB) + get(Ecam_fuel_usage_1) + get(Ecam_fuel_usage_2)) > 50)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_AIRBONE})
    end
}




----------------------------------------------------------------------------------------------------
-- CAUTION: R TK PUMP 1(2) FAULT
----------------------------------------------------------------------------------------------------
Message_FUEL_LO_LVL_R_TK_PUMP_1_OFF_FAIL = {
    text = function(self) return " - R TK PUMP 1........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(FAILURE_FUEL, R_TK_PUMP_1) == 1 and Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_1].switch == true end
}
Message_FUEL_LO_LVL_R_TK_PUMP_2_OFF_FAIL = {
    text = function(self) return " - R TK PUMP 2........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(FAILURE_FUEL, R_TK_PUMP_2) == 1 and Fuel_sys.tank_pump_and_xfr[R_TK_PUMP_2].switch == true end
}


MessageGroup_FUEL_R_TK_1_OR_2_PUMP_FAULT = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(FAILURE_FUEL, R_TK_PUMP_1) == 1 then
                    x = "1"
                elseif  get(FAILURE_FUEL, R_TK_PUMP_2) == 1  then
                    x = "2"
                end
                return "     R TK PUMP " .. x .. " LO PR"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_LO_LVL_R_TK_PUMP_1_OFF_FAIL,
        Message_FUEL_LO_LVL_R_TK_PUMP_2_OFF_FAIL
    },

    is_active = function(self)
        return xor(get(FAILURE_FUEL, R_TK_PUMP_1) == 1, get(FAILURE_FUEL, R_TK_PUMP_2) == 1)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: L TK PUMP 1(2) LO PR
----------------------------------------------------------------------------------------------------
Message_FUEL_LO_LVL_L_TK_PUMP_1_OFF_FAIL = {
    text = function(self) return " - L TK PUMP 1........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_1].switch == true end
}
Message_FUEL_LO_LVL_L_TK_PUMP_2_OFF_FAIL = {
    text = function(self) return " - L TK PUMP 2........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(FAILURE_FUEL, L_TK_PUMP_2) == 1 and Fuel_sys.tank_pump_and_xfr[L_TK_PUMP_2].switch == true end
}


MessageGroup_FUEL_L_TK_1_OR_2_PUMP_FAULT = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function(self)
                x = ""
                if get(FAILURE_FUEL, L_TK_PUMP_1) == 1 then
                    x = "1"
                elseif  get(FAILURE_FUEL, L_TK_PUMP_2) == 1  then
                    x = "2"
                end
                return "     L TK PUMP " .. x .. " LO PR"
            end,
            color = function(self) return COL_CAUTION end,
            is_active = function(self) return true end
        },
        Message_FUEL_LO_LVL_L_TK_PUMP_1_OFF_FAIL,
        Message_FUEL_LO_LVL_L_TK_PUMP_2_OFF_FAIL
    },

    is_active = function(self)
        return xor(get(FAILURE_FUEL, L_TK_PUMP_1) == 1, get(FAILURE_FUEL, L_TK_PUMP_2) == 1)
    end,

    is_inhibited = function(self)
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: L TK PUMP 1 + 2 LO PR
----------------------------------------------------------------------------------------------------

Message_FUEL_DO_NOT_APPLY_F_LEAK_DP_FAULT = {
    text = function() return " . IF NO FUEL LEAK" end,
    color = function() return COL_REMARKS end,
    is_active = function() return get(Capt_Baro_Alt) > 15000 and not PB.ovhd.fuel_XFEED.status_top end
}
Message_FUEL_X_FEED_ON_DP_FAULT = {
    text = function() return "   - FUEL X FEED.......ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(Capt_Baro_Alt) > 15000 and not PB.ovhd.fuel_XFEED.status_top end
}
Message_FUEL_ENG_MODE_SEL_IGN = {
    text = function() return " - ENG MODE SEL.......IGN" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(Engine_mode_knob) ~= 1 end
}


MessageGroup_FUEL_L_TK_1_AND_2_PUMP_FAULT = {

    shown = false,

    text  = function()
                return "FUEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     L TK PUMP 1 + 2 LO PR"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_DO_NOT_APPLY_F_LEAK_DP_FAULT,
        Message_FUEL_X_FEED_ON_DP_FAULT,
        Message_FUEL_ENG_MODE_SEL_IGN,
        Message_FUEL_LO_LVL_L_TK_PUMP_1_OFF_FAIL,
        Message_FUEL_LO_LVL_L_TK_PUMP_2_OFF_FAIL
    },

    is_active = function()
        return get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and get(FAILURE_FUEL, L_TK_PUMP_2) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: R TK PUMP 1 + 2 LO PR
----------------------------------------------------------------------------------------------------

Message_FUEL_DO_NOT_APPLY_F_LEAK_DP_FAULT = {
    text = function() return " . IF NO FUEL LEAK" end,
    color = function() return COL_REMARKS end,
    is_active = function() return get(Capt_Baro_Alt) > 15000 and not PB.ovhd.fuel_XFEED.status_top end
}
Message_FUEL_X_FEED_ON_DP_FAULT = {
    text = function() return "   - FUEL X FEED.......ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(Capt_Baro_Alt) > 15000 and not PB.ovhd.fuel_XFEED.status_top end
}
Message_FUEL_ENG_MODE_SEL_IGN = {
    text = function() return " - ENG MODE SEL.......IGN" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(Engine_mode_knob) ~= 1 end
}


MessageGroup_FUEL_R_TK_1_AND_2_PUMP_FAULT = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     R TK PUMP 1 + 2 LO PR"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_DO_NOT_APPLY_F_LEAK_DP_FAULT,
        Message_FUEL_X_FEED_ON_DP_FAULT,
        Message_FUEL_ENG_MODE_SEL_IGN,
        Message_FUEL_LO_LVL_R_TK_PUMP_1_OFF_FAIL,
        Message_FUEL_LO_LVL_R_TK_PUMP_2_OFF_FAIL
    },

    is_active = function()
        return get(FAILURE_FUEL, R_TK_PUMP_1) == 1 and get(FAILURE_FUEL, R_TK_PUMP_2) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: AUTO FEED FAULT
----------------------------------------------------------------------------------------------------
Message_FUEL_CTR_TK_1_ON = {
    text = function() return " - CTR TK XFR 1........ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return not Fuel_sys.tank_pump_and_xfr[C_TK_XFR_1].switch and get(Fuel_quantity[tank_LEFT]) < 5000 end
}

Message_FUEL_CTR_TK_2_ON = {
    text = function() return " - CTR TK XFR 2........ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return not Fuel_sys.tank_pump_and_xfr[C_TK_XFR_2].switch and get(Fuel_quantity[tank_RIGHT]) < 5000 end
}


MessageGroup_FUEL_AUTO_FEED_FAULT = {

    shown = false,

    text  = function()
                return "FUEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     AUTO FEED FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_LO_LVL_FUEL_MODE,
        Message_FUEL_CTR_TK_1_ON,
        Message_FUEL_CTR_TK_2_ON
    },

    is_active = function()
        return not PB.ovhd.fuel_MODE_SEL.status_top and not PB.ovhd.fuel_MODE_SEL.status_bottom and get(Fuel_quantity[tank_CENTER]) > 250 and (get(Fuel_quantity[tank_RIGHT]) < 5000 or get(Fuel_quantity[tank_LEFT]) < 5000)
    end,

    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_LIFTOFF, PHASE_AIRBONE, PHASE_FINAL, PHASE_BELOW_80_KTS})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: L/R WING HI TEMP
----------------------------------------------------------------------------------------------------

Message_FUEL_AFT_TWO_MIN = {
    text = function() return " . AFTER 2 MIN:" end,
    color = function() return COL_REMARKS end,
    is_active = function() return Message_FUEL_GEN_1_OFF.is_active() or Message_FUEL_GEN_2_OFF.is_active() end
}
Message_FUEL_GEN_1_OFF = {
    text = function() return "   - GEN 1............OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return ELEC_sys.generators[1].switch_status and get(Fuel_wing_L_temp) > 57 end
}
Message_FUEL_GEN_2_OFF = {
    text = function() return "   - GEN 2............OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return ELEC_sys.generators[2].switch_status and get(Fuel_wing_R_temp) > 57 end
}

Message_FUEL_HI_TEMP_DELAY_TO = {
    text = function() return " - DELAY T.O." end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 1 end
}

Message_FUEL_HI_TEMP_ENG_MASTER_1 = {
    text = function() return " - ENG MASTER 1.......OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 1 and get(Fuel_wing_L_temp) > 57 and get(Engine_1_master_switch) == 1 end
}

Message_FUEL_HI_TEMP_ENG_MASTER_2 = {
    text = function() return " - ENG MASTER 2.......OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 1 and get(Fuel_wing_R_temp) > 57 and get(Engine_2_master_switch) == 1 end
}

Message_FUEL_HI_TEMP_ENG_1_FF = {
    text = function() return " - ENG 1 F.FLOW..INCREASE" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 0 and get(Fuel_wing_L_temp) > 57 end
}

Message_FUEL_HI_TEMP_ENG_2_FF = {
    text = function() return " - ENG 2 F.FLOW..INCREASE" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 0 and get(Fuel_wing_R_temp) > 57  end
}

Message_FUEL_HI_TEMP_STILL = {
    text = function() return " . IF TEMP STILL > 57 C:" end,
    color = function() return COL_REMARKS end,
    is_active = function() return get(All_on_ground) == 0 end
}

Message_FUEL_HI_TEMP_APU_AS_RQRD = {
    text = function() return "   - APU..........AS RQRD" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 0 end
}

Message_FUEL_HI_TEMP_IDG_OFF_1 = {
    text = function() return "   - IDG 1............OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 0 and get(Gen_2_pwr) == 1 and ELEC_sys.generators[1].idg_status end
}

Message_FUEL_HI_TEMP_IDG_OFF_2 = {
    text = function() return "   - IDG 2............OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(All_on_ground) == 0 and get(Gen_1_pwr) == 1 and ELEC_sys.generators[2].idg_status end
}


MessageGroup_FUEL_LR_HI_TEMP = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                x = ""
                if get(Fuel_wing_L_temp) > 57 then
                    x = x .. "L"
                end
                if get(Fuel_wing_R_temp) > 57  then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "R"
                end
                return "     " .. x .. " TK HI TEMP"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_AFT_TWO_MIN,
        Message_FUEL_GEN_1_OFF,
        Message_FUEL_GEN_2_OFF,
        Message_FUEL_HI_TEMP_DELAY_TO,      -- on ground only
        Message_FUEL_HI_TEMP_ENG_MASTER_1,  -- on ground only
        Message_FUEL_HI_TEMP_ENG_MASTER_2,  -- on ground only
        Message_FUEL_HI_TEMP_ENG_1_FF,      -- in flight only
        Message_FUEL_HI_TEMP_ENG_2_FF,      -- in flight only
        Message_FUEL_HI_TEMP_STILL,         -- in flight only
        Message_FUEL_HI_TEMP_APU_AS_RQRD,   -- in flight only
        Message_FUEL_HI_TEMP_IDG_OFF_1,     -- in flight only
        Message_FUEL_HI_TEMP_IDG_OFF_2      -- in flight only
        
        
    },

    is_active = function()
        return get(Fuel_wing_L_temp) > 57 or get(Fuel_wing_R_temp) > 57
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}



----------------------------------------------------------------------------------------------------
-- CAUTION: L/R WING LO TEMP
----------------------------------------------------------------------------------------------------

MessageGroup_FUEL_LR_LO_TEMP = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                x = ""
                if get(Fuel_wing_L_temp) < -43 then
                    x = x .. "L"
                end
                if get(Fuel_wing_R_temp) < -43 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "R"
                end
                return "     " .. x .. " TK LO TEMP"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_HI_TEMP_DELAY_TO      -- on ground only

    },

    is_active = function()
        return get(Fuel_wing_L_temp) < -43 or get(Fuel_wing_R_temp) < -43
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: APU LP VALVE FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_FUEL_APU_VALVE_FAULT = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     APU LP VALVE FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_FUEL_APU_VALVE_STUCK) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: ENG 1/2 VALVE FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_FUEL_ENG_1_2_VALVE_FAULT = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                x = ""
                if get(FAILURE_FUEL_ENG1_VALVE_STUCK) == 1 then
                    x = x .. "1"
                end
                if get(FAILURE_FUEL_ENG2_VALVE_STUCK) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     ENG " .. x .. " LP VALVE FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_FUEL_ENG1_VALVE_STUCK) == 1 or get(FAILURE_FUEL_ENG2_VALVE_STUCK) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}
----------------------------------------------------------------------------------------------------
-- CAUTION: X FEED VALVE FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_FUEL_X_FEED_VALVE_FAULT = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     X FEED VALVE FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_FUEL_X_FEED) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: L/R WING OVERFLOW
----------------------------------------------------------------------------------------------------

Message_FUEL_CTR_TK_1_OFF_OVFW = {
    text = function() return " - CTR TK XFR 1.......OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(Fuel_wing_L_overflow) == 1 and Fuel_sys.tank_pump_and_xfr[C_TK_XFR_1].switch end
}

Message_FUEL_CTR_TK_2_OFF_OVFW = {
    text = function() return " - CTR TK XFR 2.......OFF" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(Fuel_wing_R_overflow) == 1 and Fuel_sys.tank_pump_and_xfr[C_TK_XFR_2].switch end
}

MessageGroup_FUEL_LR_OVERFLOW = {

    shown = false,

    text  = function(self)
                return "FUEL"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                x = ""
                if get(Fuel_wing_L_overflow) == 1 then
                    x = x .. "L"
                end
                if get(Fuel_wing_R_overflow) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "R"
                end
                return "     " .. x .. " TK OVERFLOW"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_CTR_TK_1_OFF_OVFW,
        Message_FUEL_CTR_TK_2_OFF_OVFW

    },

    is_active = function()
        return get(Fuel_wing_L_overflow) == 1 or get(Fuel_wing_R_overflow) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: FQI 1+2 FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_FUEL_FQI_1_2_FAULT = {

    shown = false,

    text  = function()
                return "FUEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_3,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                x = ""
                if get(FAILURE_FUEL_FQI_1_FAULT) == 1 then
                    x = x .. "1"
                end
                if get(FAILURE_FUEL_FQI_2_FAULT) == 1 then
                    if #x > 0 then
                        x = x .. " + "
                    end
                    x = x .. "2"
                end
                return "     FQI CH " .. x .. " FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },

    is_active = function()
        return get(FAILURE_FUEL_FQI_1_FAULT) == 1 or get(FAILURE_FUEL_FQI_2_FAULT) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: ACT AUTO XFR FAULT
----------------------------------------------------------------------------------------------------
Message_FUEL_ACT_PROC_APPLY = {
    text = function() return " - ACT FAULT PROC...APPLY" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}

Message_FUEL_MONITOR_CG_LIMITS = {
    text = function() return " MONITOR CG LIMITS" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}


MessageGroup_FUEL_ACT_AUTO_XFR_FAULT = {

    shown = false,

    text  = function()
                return "FUEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     ACT AUTO XFR FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_ACT_PROC_APPLY,
        Message_FUEL_MONITOR_CG_LIMITS
    },

    is_active = function()
        local transfer_conditions = get(Flaps_internal_config) ==0
        
        return get(Fuel_quantity[tank_CENTER]) < 3000 and get(Fuel_quantity[tank_ACT]) > 100
    end,

    is_inhibited = function()
        return is_active_in({PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: RCT AUTO XFR FAULT
----------------------------------------------------------------------------------------------------
Message_FUEL_RCT_PROC_APPLY = {
    text = function() return " - RCT FAULT PROC...APPLY" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}

MessageGroup_FUEL_RCT_AUTO_XFR_FAULT = {

    shown = false,

    text  = function()
                return "FUEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     RCT AUTO XFR FAULT"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_RCT_PROC_APPLY,
        Message_FUEL_MONITOR_CG_LIMITS
    },

    is_active = function()
        local transfer_conditions = get(Flaps_internal_config) ==0
        
        return get(Fuel_quantity[tank_CENTER]) < 3000 and get(Fuel_quantity[tank_RCT]) > 100
    end,

    is_inhibited = function()
        return is_active_in({PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: ACT TK XFR
----------------------------------------------------------------------------------------------------
Message_FUEL_IF_NO_PACKS_AVAIL = {
    text = function() return " . IF NO PACKS AVAIL:" end,
    color = function() return COL_REMARKS end,
    is_active = function() return true end
}

Message_FUEL_ACT_USABLE= {
    text = function() return "   - ACT TK UNUSABLE" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}

Message_FUEL_MONITOR_CG_2_LEVEL= {
    text = function() return "   - MONITOR CG LIMITS" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}


MessageGroup_FUEL_ACT_LO_PR_XFR_FAULT = {

    shown = false,

    text  = function()
                return "FUEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     ACT TK XFR LO PR"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_IF_NO_PACKS_AVAIL,
        Message_FUEL_ACT_USABLE,
        Message_FUEL_MONITOR_CG_2_LEVEL
    },

    is_active = function()
        return get(FAILURE_FUEL, 7) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}



----------------------------------------------------------------------------------------------------
-- CAUTION: RCT TK XFR
----------------------------------------------------------------------------------------------------
Message_FUEL_RCT_USABLE= {
    text = function() return "   - RCT TK UNUSABLE" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return true end
}

MessageGroup_FUEL_RCT_LO_PR_XFR_FAULT = {

    shown = false,

    text  = function()
                return "FUEL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_FUEL,
    
    messages = {
        {
            text = function()
                return "     RCT TK XFR LO PR"
            end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_FUEL_IF_NO_PACKS_AVAIL,
        Message_FUEL_RCT_USABLE,
        Message_FUEL_MONITOR_CG_2_LEVEL
    },

    is_active = function()
        return get(FAILURE_FUEL, 8) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

