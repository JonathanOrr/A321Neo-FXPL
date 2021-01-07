include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: ADR x FAULT (single)
----------------------------------------------------------------------------------------------------

Message_ADR_FAULT_SINGLE = {
    text = function(self)
        return "    ADR " .. MessageGroup_ADR_FAULT_SINGLE:get_failed() .. " FAULT"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end

}

Message_ADR_FAULT_SWITCH = {
    text = function(self)
        if  MessageGroup_ADR_FAULT_SINGLE:get_failed() == 1 then
            return " - AIR DATA SWTG.....CAPT"
        elseif MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2 then
            return " - AIR DATA SWTG......F/O"
        else
            return " - AIR DATA SWTG.....NORM"
        end
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 1 and get(ADIRS_source_rotary_AIRDATA) ~= -1)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 3 and get(ADIRS_source_rotary_AIRDATA) ~= 0)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2 and get(ADIRS_source_rotary_AIRDATA) ~= 1)
    end

}

Message_ADR_FAULT_OFF = {
    text = function(self)
        return " - ADR " .. MessageGroup_ADR_FAULT_SINGLE:get_failed() .. "..............OFF"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return   (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 1 and not PB.ovhd.adr_1.status_bottom)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2 and not PB.ovhd.adr_2.status_bottom)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 3 and not PB.ovhd.adr_3.status_bottom)
    end

}

Message_ADR_FAULT_BARO_REF = {
    text = function(self)
        return " - BARO REF.........CHECK"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2
    end

}

MessageGroup_ADR_FAULT_SINGLE = {

    shown = false,

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_ADR_FAULT_SINGLE,
        Message_ADR_FAULT_SWITCH,
        Message_ADR_FAULT_OFF,      
        Message_ADR_FAULT_BARO_REF      
    },

    is_active = function(self)
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

    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT and (get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL))
    end,
    
        
    get_failed = function(self)
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
    text = function(self)
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        return "    ADR " .. a .. " + " .. b .. " FAULT"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end

}

Message_ADR_FAULT_SWITCH_DOUBLE = {
    text = function(self)
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        if  a == 1 and b == 2 then
            return " - AIR DATA SWTG.....CAPT"
        else
            return " - AIR DATA SWTG.....NORM"
        end
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        if  a == 1 and b == 2 then
            return get(ADIRS_source_rotary_AIRDATA) ~= -1
        else 
            return get(ADIRS_source_rotary_AIRDATA) ~= 0
        end
    end
}

Message_ADR_FAULT_OFF_DOUBLE = {
    text = function(self)
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        return "    ADR " .. a .. " + " .. b .. "...........OFF"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
        a,b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
        return (ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_FAULT and (PB.ovhd.adr_2.status_bottom == false or PB.ovhd.adr_3.status_bottom == false))
        or (ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_FAULT and (PB.ovhd.adr_1.status_bottom == false or PB.ovhd.adr_3.status_bottom == false))
        or (ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_FAULT and (PB.ovhd.adr_2.status_bottom == false or PB.ovhd.adr_1.status_bottom == false)) 
     end
}

MessageGroup_ADR_FAULT_DOUBLE = {

    shown = false,

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_ADR_FAULT_DOUBLE,
        Message_ADR_FAULT_SWITCH_DOUBLE,
        Message_ADR_FAULT_OFF     
    },

    is_active = function(self)
        -- Two and only two ADR failure
        return
        (
        (ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_3].adr_status ~= ADR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_FAULT)
        )
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end,
    
        
    get_failed = function(self)
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

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        {
            text = function(self)
                return "    ADR 1 + 2 + 3 FAULT"
            end,

            color = function(self)
                return COL_WARNING
            end,

            is_active = function(self)
              return true
            end

        },  
        {
            text = function(self)
                return " - ADR 1 + 2 + 3......OFF"
            end,

            color = function(self)
                return COL_ACTIONS
            end,

            is_active = function(self)
                return PB.ovhd.adr_1 == false or PB.ovhd.adr_2 == false or PB.ovhd.adr_3 == false
            end
        },
        {
            text = function(self)
                return "STBY INST.............USE"
            end,

            color = function(self)
                return COL_ACTIONS
            end,

            is_active = function(self)
              return true
            end
        }
    },

    is_active = function(self)
        return
        ADIRS_sys[ADIRS_1].adr_status == ADR_STATUS_FAULT and ADIRS_sys[ADIRS_2].adr_status == ADR_STATUS_FAULT and
        ADIRS_sys[ADIRS_3].adr_status == ADR_STATUS_FAULT
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
    
}


----------------------------------------------------------------------------------------------------
-- CAUTION: IR x FAULT (single)
----------------------------------------------------------------------------------------------------

Message_IR_FAULT_SINGLE = {
    text = function(self)
        return "    IR " .. MessageGroup_IR_FAULT_SINGLE:get_failed() .. " FAULT"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end

}

Message_IR_FAULT_SWITCH = {
    text = function(self)
        if  MessageGroup_IR_FAULT_SINGLE:get_failed() == 1 then
            return " - ATT HDG SWTG......CAPT"
        elseif MessageGroup_IR_FAULT_SINGLE:get_failed() == 2 then
            return " - ATT HDG SWTG.......F/O"
        else
            return " - ATT HDG SWTG......NORM"
        end
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return (MessageGroup_IR_FAULT_SINGLE:get_failed() == 1 and get(ADIRS_source_rotary_ATHDG) ~= -1)
            or (MessageGroup_IR_FAULT_SINGLE:get_failed() == 3 and get(ADIRS_source_rotary_ATHDG) ~= 0)
            or (MessageGroup_IR_FAULT_SINGLE:get_failed() == 2 and get(ADIRS_source_rotary_ATHDG) ~= 1)
    end

}

Message_IR_FAULT_ATT_PROC = {
    text = function(self)
        return "IR ALIGN PROC ATT...APPLY"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
      return true
    end

}

MessageGroup_IR_FAULT_SINGLE = {

    shown = false,

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_IR_FAULT_SINGLE,
        Message_IR_FAULT_SWITCH,
        Message_IR_FAULT_ATT_PROC    
    },

    is_active = function(self)
        -- One and only one IR failure
        return
        (
        (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT)
        )
    end,

    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT and (get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL))
    end,
    
        
    get_failed = function(self)
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
    text = function(self)
        a,b = MessageGroup_IR_FAULT_DOUBLE:get_failed()
        return "    IR " .. a .. " + " .. b .. " FAULT"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end

}

Message_IR_FAULT_SWITCH_DOUBLE = {
    text = function(self)
        a,b = MessageGroup_IR_FAULT_DOUBLE:get_failed()
        if  a == 1 and b == 2 then
            return " - AIR DATA SWTG.....CAPT"
        else
            return " - AIR DATA SWTG.....NORM"
        end
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
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

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_IR_FAULT_DOUBLE,
        Message_IR_FAULT_SWITCH_DOUBLE,
        Message_IR_FAULT_ATT_PROC     
    },

    is_active = function(self)
        -- At least two IR failures
        return
        (
        (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status ~= IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT) or
        (ADIRS_sys[ADIRS_1].ir_status ~= IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT)
        )
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end,
    
        
    get_failed = function(self)
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

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        {
            text = function(self)
                return "    IR 1 + 2 FAULT"
            end,

            color = function(self)
                return COL_CAUTION
            end,

            is_active = function(self)
              return true
            end

        },  
        Message_IR_FAULT_ATT_PROC
    },

    is_active = function(self)
        return
        ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
}

MessageGroup_IR_FAULT_TRIPLE_2 = {

    shown = false,

    text  = function(self)
                return "NAV"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_3,

    messages = {
        {
            text = function(self)
                return "    IR 2 + 3 FAULT"
            end,

            color = function(self)
                return COL_CAUTION
            end,

            is_active = function(self)
              return true
            end

        },  
        Message_IR_FAULT_ATT_PROC
    },

    is_active = function(self)
        return 
        ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_FAULT and ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_FAULT
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
}


