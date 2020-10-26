include('EWD_msgs/common.lua')
include('constants.lua')
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
        return (Fuel_sys.tank_pump_and_xfr[C_TK_XFR_1].switch == false and get(FAILURE_FUEL, C_TK_XFR_1) == 0) 
            or (Fuel_sys.tank_pump_and_xfr[C_TK_XFR_2].switch == false and get(FAILURE_FUEL, C_TK_XFR_2) == 0)
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
    is_active = function() return get(Fuel_light_x_feed) < 10 end
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
            text = function() return "     CTR TK XFR 1+2 LO PR" end,
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
    is_active = function(self) return get(Fuel_light_x_feed)==0 end
}
Message_FUEL_LO_LVL_L_TK_PUMP_1_OFF = {
    text = function(self) return " - L TK PUMP 1........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_LEFT]) < 750 end
}
Message_FUEL_LO_LVL_L_TK_PUMP_2_OFF = {
    text = function(self) return " - L TK PUMP 2........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_LEFT]) < 750 end
}
Message_FUEL_LO_LVL_R_TK_PUMP_1_OFF = {
    text = function(self) return " - R TK PUMP 1........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_RIGHT]) < 750 end
}
Message_FUEL_LO_LVL_R_TK_PUMP_2_OFF = {
    text = function(self) return " - R TK PUMP 2........OFF" end,
    color = function(self) return COL_ACTIONS end,
    is_active = function(self) return get(Fuel_quantity[tank_RIGHT]) < 750 end
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
    is_active = function(self) return get(Fuel_light_mode_sel) == 0 end
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


