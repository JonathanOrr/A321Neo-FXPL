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
      return   (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 1 and get(ADIRS_light_ADR[1]) % 2 ~= 1)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 2 and get(ADIRS_light_ADR[2]) % 2 ~= 1)
            or (MessageGroup_ADR_FAULT_SINGLE:get_failed() == 3 and get(ADIRS_light_ADR[3]) % 2 ~= 1)
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
        return not (get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF) and 
        get(Adirs_adr_is_ok[1]) + get(Adirs_adr_is_ok[2]) + get(Adirs_adr_is_ok[3]) == 2
    end,

    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (get(Adirs_adr_is_ok[3]) == 0 and (get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL))
    end,
    
        
    get_failed = function(self)
        if get(Adirs_adr_is_ok[1]) == 0 then
            return 1
        elseif get(Adirs_adr_is_ok[2]) == 0 then
            return 2
        elseif get(Adirs_adr_is_ok[3]) == 0 then
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
        return get(ADIRS_light_ADR[a]) % 2 ~= 1 or get(ADIRS_light_ADR[b]) % 2 ~= 1
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
        return not (get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF) and  
        get(Adirs_adr_is_ok[1]) + get(Adirs_adr_is_ok[2]) + get(Adirs_adr_is_ok[3]) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end,
    
        
    get_failed = function(self)
        if get(Adirs_adr_is_ok[1]) == 1 then
            return 2,3
        elseif get(Adirs_adr_is_ok[2]) == 1 then
            return 1,3
        elseif get(Adirs_adr_is_ok[3]) == 1 then
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
              return get(ADIRS_light_ADR[1]) % 2 ~= 1 or get(ADIRS_light_ADR[2]) % 2 ~= 1 or get(ADIRS_light_ADR[3]) % 2 ~= 1
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
        return not (get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF) and 
        get(Adirs_adr_is_ok[1]) + get(Adirs_adr_is_ok[2]) + get(Adirs_adr_is_ok[3]) == 0
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
        return not (get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF) and 
        get(Adirs_ir_is_ok[1]) + get(Adirs_ir_is_ok[2]) + get(Adirs_ir_is_ok[3]) == 2
    end,

    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
               or (get(Adirs_ir_is_ok[3]) == 0 and (get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL))
    end,
    
        
    get_failed = function(self)
        if get(Adirs_ir_is_ok[1]) == 0 then
            return 1
        elseif get(Adirs_ir_is_ok[2]) == 0 then
            return 2
        elseif get(Adirs_ir_is_ok[3]) == 0 then
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
        -- Two and only two IR failure
        return not (get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF) and 
        get(Adirs_ir_is_ok[1]) + get(Adirs_ir_is_ok[2]) + get(Adirs_ir_is_ok[3]) == 1
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end,
    
        
    get_failed = function(self)
        if get(Adirs_ir_is_ok[1]) == 1 then
            return 2,3
        elseif get(Adirs_ir_is_ok[2]) == 1 then
            return 1,3
        elseif get(Adirs_ir_is_ok[3]) == 1 then
            return 1,2
        end        
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: IR x FAULT (triple)
----------------------------------------------------------------------------------------------------
MessageGroup_IR_FAULT_TRIPLE = {

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
                return "    IR 1 + 2 + 3 FAULT"
            end,

            color = function(self)
                return COL_WARNING
            end,

            is_active = function(self)
              return true
            end

        },  
        Message_IR_FAULT_ATT_PROC
    },

    is_active = function(self)
        return not (get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_1ST_ENG_ON or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF) and 
        get(Adirs_ir_is_ok[1]) + get(Adirs_ir_is_ok[2]) + get(Adirs_ir_is_ok[3]) == 0
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end
    
}




