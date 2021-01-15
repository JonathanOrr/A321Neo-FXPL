include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: ADR x FAULT (single)
----------------------------------------------------------------------------------------------------

Message_ADR_FAULT_SINGLE = {
    text = function()
        return "    ADR " .. MessageGroup_ADR_FAULT_SINGLE:get_failed() .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end

}

Message_ADR_FAULT_SWITCH = {
    text = function()
        if  MessageGroup_ADR_FAULT_SINGLE:get_failed() == 1 then
            return " - AIR DATA SWTG.....CAPT"
        elseif MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2 then
            return " - AIR DATA SWTG......F/O"
        else
            return " - AIR DATA SWTG.....NORM"
        end
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 1 and get(ADIRS_source_rotary_AIRDATA) ~= -1)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 3 and get(ADIRS_source_rotary_AIRDATA) ~= 0)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2 and get(ADIRS_source_rotary_AIRDATA) ~= 1)
    end

}

Message_ADR_FAULT_OFF = {
    text = function()
        return " - ADR " .. MessageGroup_ADR_FAULT_SINGLE:get_failed() .. "..............OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return   (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 1 and not PB.ovhd.adr_1.status_bottom)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2 and not PB.ovhd.adr_2.status_bottom)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 3 and not PB.ovhd.adr_3.status_bottom)
    end

}

Message_ADR_FAULT_BARO_REF = {
    text = function()
        return " - BARO REF.........CHECK"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2
    end

}

MessageGroup_ADR_FAULT_SINGLE = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_ADR_FAULT_SINGLE,
        Message_ADR_FAULT_SWITCH,
        Message_ADR_FAULT_OFF,      
        Message_ADR_FAULT_BARO_REF      
    },

    is_active = function()
        -- One and only one ADR failure
        return
        (
        (ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_FAULT
        and ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_FAULT
        and ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_FAULT
        and ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_FAULT))
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT and (get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL))
    end,
    
        
    get_failed = function()
        if ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT then
            return 1
        elseif ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT then
            return 2
        elseif ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT then
            return 3
        end        
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: ADR x FAULT (double)
----------------------------------------------------------------------------------------------------
Message_ADR_FAULT_DOUBLE = {
    text = function()
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        return "    ADR " .. a .. " + " .. b .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end

}

Message_ADR_FAULT_SWITCH_DOUBLE = {
    text = function()
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        if  a == 1 and b == 2 then
            return " - AIR DATA SWTG.....CAPT"
        else
            return " - AIR DATA SWTG.....NORM"
        end
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        if  a == 1 and b == 2 then
            return get(ADIRS_source_rotary_AIRDATA) ~= -1
        else 
            return get(ADIRS_source_rotary_AIRDATA) ~= 0
        end
    end
}

Message_ADR_FAULT_OFF_DOUBLE = {
    text = function()
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        return "    ADR " .. a .. " + " .. b .. "...........OFF"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        return (ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_FAULT and (PB.ovhd.adr_2.status_bottom == false or PB.ovhd.adr_3.status_bottom == false))
        or (ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_FAULT and (PB.ovhd.adr_1.status_bottom == false or PB.ovhd.adr_3.status_bottom == false))
        or (ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_FAULT and (PB.ovhd.adr_2.status_bottom == false or PB.ovhd.adr_1.status_bottom == false)) 
     end
}

MessageGroup_ADR_FAULT_DOUBLE = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_ADR_FAULT_DOUBLE,
        Message_ADR_FAULT_SWITCH_DOUBLE,
        Message_ADR_FAULT_OFF     
    },

    is_active = function()
        -- Two and only two ADR failure
        return
        (
        (ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_FAULT)
        )
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end,
    
        
    get_failed = function()
        if ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_FAULT then
            return 2,3
        elseif ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_FAULT then
            return 1,3
        elseif ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_FAULT then
            return 1,2
        end        
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: ADR x FAULT (triple)
----------------------------------------------------------------------------------------------------
MessageGroup_ADR_FAULT_TRIPLE = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        {
            text = function()
                return "    ADR 1 + 2 + 3 FAULT"
            end,

            color = function()
                return COL_WARNING
            end,

            is_active = function()
              return true
            end

        },  
        {
            text = function()
                return " - ADR 1 + 2 + 3......OFF"
            end,

            color = function()
                return COL_ACTIONS
            end,

            is_active = function()
                return PB.ovhd.adr_1 == false or PB.ovhd.adr_2 == false or PB.ovhd.adr_3 == false
            end
        },
        {
            text = function()
                return "STBY INST.............USE"
            end,

            color = function()
                return COL_ACTIONS
            end,

            is_active = function()
              return true
            end
        }
    },

    is_active = function()
        return
        ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT and
        ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
    
}


----------------------------------------------------------------------------------------------------
-- CAUTION: IR x FAULT (single)
----------------------------------------------------------------------------------------------------

Message_IR_FAULT_SINGLE = {
    text = function()
        return "    IR " .. MessageGroup_IR_FAULT_SINGLE:get_failed() .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end

}

Message_IR_FAULT_SWITCH = {
    text = function()
        if  MessageGroup_IR_FAULT_SINGLE:get_failed() == 1 then
            return " - ATT HDG SWTG......CAPT"
        elseif MessageGroup_IR_FAULT_SINGLE:get_failed() == 2 then
            return " - ATT HDG SWTG.......F/O"
        else
            return " - ATT HDG SWTG......NORM"
        end
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return (MessageGroup_IR_FAULT_SINGLE:get_failed() == 1 and get(ADIRS_source_rotary_ATHDG) ~= -1)
            or (MessageGroup_IR_FAULT_SINGLE:get_failed() == 3 and get(ADIRS_source_rotary_ATHDG) ~= 0)
            or (MessageGroup_IR_FAULT_SINGLE:get_failed() == 2 and get(ADIRS_source_rotary_ATHDG) ~= 1)
    end

}

Message_IR_FAULT_ATT_PROC = {
    text = function()
        return "IR ALIGN PROC ATT...APPLY"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return true
    end

}

MessageGroup_IR_FAULT_SINGLE = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_IR_FAULT_SINGLE,
        Message_IR_FAULT_SWITCH,
        Message_IR_FAULT_ATT_PROC    
    },

    is_active = function()
        -- One and only one IR failure
        return
        (
        (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT)
        )
    end,

    is_inhibited = function()
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT and (get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL))
    end,
    
        
    get_failed = function()
        if ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT then
            return 1
        elseif ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT then
            return 2
        elseif ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT then
            return 3
        end        
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: IR x FAULT (double)
----------------------------------------------------------------------------------------------------
Message_IR_FAULT_DOUBLE = {
    text = function()
        a,b = MessageGroup_IR_FAULT_DOUBLE:get_failed()
        return "    IR " .. a .. " + " .. b .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end

}

Message_IR_FAULT_SWITCH_DOUBLE = {
    text = function()
        a,b = MessageGroup_IR_FAULT_DOUBLE:get_failed()
        if  a == 1 and b == 2 then
            return " - AIR DATA SWTG.....CAPT"
        else
            return " - AIR DATA SWTG.....NORM"
        end
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
        a,b = MessageGroup_IR_FAULT_DOUBLE:get_failed()
        if  a == 1 and b == 2 then
            return get(ADIRS_source_rotary_ATHDG) ~= -1
        else 
            return get(ADIRS_source_rotary_ATHDG) ~= 0
        end
    end
}



MessageGroup_IR_FAULT_DOUBLE = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_IR_FAULT_DOUBLE,
        Message_IR_FAULT_SWITCH_DOUBLE,
        Message_IR_FAULT_ATT_PROC     
    },

    is_active = function()
        -- At least two IR failures
        return
        (
        (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT)
        )
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end,
    
        
    get_failed = function()
        if ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT then
            return 2,3
        elseif ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT then
            return 1,3
        elseif ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT then
            return 1,2
        end        
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: IR x FAULT (triple)
----------------------------------------------------------------------------------------------------
MessageGroup_IR_FAULT_TRIPLE_1 = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        {
            text = function()
                return "    IR 1 + 2 FAULT"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        },  
        Message_IR_FAULT_ATT_PROC
    },

    is_active = function()
        return
        ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
}

MessageGroup_IR_FAULT_TRIPLE_2 = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "    IR 2 + 3 FAULT"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        },  
        Message_IR_FAULT_ATT_PROC
    },

    is_active = function()
        return 
        ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
}


----------------------------------------------------------------------------------------------------
-- WARNING: OVERSPEED
----------------------------------------------------------------------------------------------------

local function get_vfe()
    if get(Flaps_internal_config) == 1 then
        return 243
    elseif get(Flaps_internal_config) == 2 then
        return 225
    elseif get(Flaps_internal_config) == 3 then
        return 215
    elseif get(Flaps_internal_config) == 4 then
        return 195
    elseif get(Flaps_internal_config) == 5 then
        return 186
    end
    return 999
end

local speed_margin = 4
local mach_margin = 0.006

local function get_no_ldg_cond()
    return (get_avg_ias() > 350 + speed_margin) or (get_avg_mach() > 0.82 + mach_margin)
end
local function get_ldg_cond()
    return ((get_avg_ias() > 280 + speed_margin) or (get_avg_mach() > 0.67 + mach_margin)) and (get(Front_gear_deployment) > 0.01 or get(Left_gear_deployment) > 0.01 or get(Right_gear_deployment) > 0.01)
end
local function get_vfe_cond()
    return (get_avg_ias() > get_vfe() + speed_margin) and get(Flaps_internal_config) > 0
end

Message_OVERSPEED_SPEED = {
    text = function()
        if get_no_ldg_cond() then
            return " - VMO/MMO........350/.82"
        elseif get_ldg_cond() then
            return " - VLE............280/.67"
        elseif get_vfe_cond() then
            return " - VLE................" .. get_vfe()
        end
    end,

    color = function()
        return COL_WARNING
    end,

    is_active = function()
      return true
    end
}

MessageGroup_OVERSPEED = {

    shown = false,

    text  = function()
                return ""
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        {
            text = function()
                return "OVERSPEED"
            end,

            color = function()
                return COL_WARNING
            end,

            is_active = function()
              return true
            end

        },  
        Message_OVERSPEED_SPEED
    },

    is_active = function()
        return get_no_ldg_cond() or get_ldg_cond() or get_vfe_cond()
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) < PHASE_LIFTOFF or get(EWD_flight_phase) >= PHASE_TOUCHDOWN
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: AOA CAPT FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_AOA_CAPT_FAULT = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,

    messages = {
        {
            text = function()
                return "    CAPT AOA FAULT"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        }
    },

    is_active = function()
        return get(FAILURE_SENSOR_AOA_CAPT) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: AOA F/O FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_AOA_FO_FAULT = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,

    messages = {
        {
            text = function()
                return "    F/O AOA FAULT"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        }
    },

    is_active = function()
        return get(FAILURE_SENSOR_AOA_FO) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: AOA STBY FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_AOA_STBY_FAULT = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,

    messages = {
        {
            text = function()
                return "    STBY AOA FAULT"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        }
    },

    is_active = function()
        return get(FAILURE_SENSOR_AOA_STBY) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: HDG DISCREPANCY
----------------------------------------------------------------------------------------------------

MessageGroup_HDG_DISCREPANCY = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "    HDG DISCREPANCY"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        },
        {
            text = function() return " - HDG............X CHECK" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " - ATT HDG SWTG...AS RQRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
        
    },

    is_active = function()
        return math.abs(get_hdg(PFD_CAPT) - get_hdg(PFD_FO)) > 5
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: ATT DISCREPANCY
----------------------------------------------------------------------------------------------------

MessageGroup_ATT_DISCREPANCY = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "    ATT DISCREPANCY"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        },
        {
            text = function() return " - ATT............X CHECK" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " - ATT HDG SWTG...AS RQRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
        
    },

    is_active = function()
        return math.abs(get_pitch(PFD_CAPT) - get_pitch(PFD_FO)) > 5 or math.abs(get_roll(PFD_CAPT) - get_roll(PFD_FO)) > 5
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: ALTI DISCREPANCY
----------------------------------------------------------------------------------------------------

MessageGroup_ALTI_DISCREPANCY = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "    ALTI DISCREPANCY"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        },
        {
            text = function() return " - ALT............X CHECK" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " - AIR DATA SWTG..AS RQRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
        
    },

    is_active = function()
        return math.abs(get_alt(PFD_CAPT) - get_alt(PFD_FO)) > 250
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: BARO REF DISCREPANCY
----------------------------------------------------------------------------------------------------

MessageGroup_BARO_REF_DISCREPANCY = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "    BARO REF DISCREPANCY"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        },
        {
            text = function() return " - BARO REF.......X CHECK" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
        
    },

    start_time = 0,

    is_active = function()
        if math.abs(get(Capt_Baro) - get(Fo_Baro)) > 0.02 then
            if MessageGroup_BARO_REF_DISCREPANCY.start_time == 0 then
                MessageGroup_BARO_REF_DISCREPANCY.start_time = get(TIME)
            elseif get(TIME) - MessageGroup_BARO_REF_DISCREPANCY.start_time > 20 then
                return true
            end
        else
            MessageGroup_BARO_REF_DISCREPANCY.start_time = 0
        end
        return false
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_TOUCHDOWN})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: IAS DISCREPANCY
----------------------------------------------------------------------------------------------------

MessageGroup_IAS_DISCREPANCY = {

    shown = false,

    text  = function()
                return "NAV"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function()
                return "    IAS DISCREPANCY"
            end,

            color = function()
                return COL_CAUTION
            end,

            is_active = function()
              return true
            end

        },
        {
            text = function() return " - AIR SPD........X CHECK" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " - AIR DATA SWTG..AS RQRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
        
    },

    is_active = function()
        return math.abs(get_ias(PFD_CAPT) - get_ias(PFD_FO)) > 3
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}

