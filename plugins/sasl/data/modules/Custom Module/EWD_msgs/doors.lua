include('EWD_msgs/common.lua')

local function add_door(text, door_name, door_ref)
    if get(door_ref) > 0 then
        if #text > 0 then
            text = text .. "+"
        end
        text = text .. door_name
    end
    return text
end

----------------------------------------------------------------------------------------------------
-- CAUTION: DOORS CABIN
----------------------------------------------------------------------------------------------------
Message_DOORS_CABIN = {
    text = function(self)
        local text = ""
        
        text = add_door(text, "L1", Door_1_l_ratio)
        text = add_door(text, "R1", Door_1_r_ratio)
        text = add_door(text, "L3", Door_2_l_ratio)
        text = add_door(text, "R3", Door_2_r_ratio)
        text = add_door(text, "L4", Door_3_l_ratio)
        text = add_door(text, "R4", Door_3_r_ratio)

        if #text < 15 then
            text = text .. " CABIN"
        end

        return "      " .. text
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}

Message_DOORS_IN_FLIGHT_1 = {
    text = function(self)
        return " . IF ABN CAB V/S:"
    end,

    color = function(self)
        return COL_REMARKS
    end,

    is_active = function(self)
        return get(EWD_flight_phase) == PHASE_AIRBONE
    end
}

Message_DOORS_IN_FLIGHT_2 = {
    text = function(self)
        return " - MAX FL.........100/MEA"
    end,

    color = function(self)
        return COL_ACTIONS
    end,

    is_active = function(self)
        return get(EWD_flight_phase) == PHASE_AIRBONE
    end
}

MessageGroup_DOORS_CABIN = {

    shown = false,

    text  = function(self)
                return "DOORS"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_DOOR,

    messages = {
        Message_DOORS_CABIN,
        Message_DOORS_IN_FLIGHT_1,        
        Message_DOORS_IN_FLIGHT_2        
    },

    is_active = function(self)
        -- Active if any brakes over 300 C
        return get(Door_1_l_ratio) > 0 or get(Door_1_r_ratio) > 0 or get(Door_2_l_ratio) > 0 or get(Door_2_r_ratio) > 0 or get(Door_3_l_ratio) > 0 or get(Door_3_r_ratio) > 0
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: DOORS CARGO
----------------------------------------------------------------------------------------------------
Message_DOORS_CARGO = {
    text = function(self)
        local text = ""
        
        text = add_door(text, "FWD", Cargo_1_ratio)
        text = add_door(text, "AFT", Cargo_2_ratio)

        return "      CARGO " .. text
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}


MessageGroup_DOORS_CARGO = {

    shown = false,

    text  = function(self)
                return "DOORS"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_DOOR,

    messages = {
        Message_DOORS_CARGO,
        Message_DOORS_IN_FLIGHT_1,        
        Message_DOORS_IN_FLIGHT_2        
    },

    is_active = function(self)
        -- Active if any brakes over 300 C
        return get(Cargo_1_ratio) > 0 or get(Cargo_2_ratio) > 0
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end

}



----------------------------------------------------------------------------------------------------
-- CAUTION: DOORS EMERGENCY EXIT
----------------------------------------------------------------------------------------------------
Message_DOORS_EMER_EXIT = {
    text = function(self)
        local text = ""
        
        text = add_door(text, "L1", Overwing_exit_1_l_ratio)
        text = add_door(text, "R1", Overwing_exit_1_r_ratio)
        text = add_door(text, "L2", Overwing_exit_2_l_ratio)
        text = add_door(text, "R2", Overwing_exit_2_r_ratio)

        if #text < 15 then
            text = text .. " EMER EXIT"
        end

        return "      " .. text
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}


MessageGroup_DOORS_EMER_EXIT = {

    shown = false,

    text  = function(self)
                return "DOORS"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_DOOR,

    messages = {
        Message_DOORS_EMER_EXIT,
        Message_DOORS_IN_FLIGHT_1,        
        Message_DOORS_IN_FLIGHT_2        
    },

    is_active = function(self)
        -- Active if any brakes over 300 C
        return get(Overwing_exit_1_l_ratio) > 0 or get(Overwing_exit_1_r_ratio) > 0 or get(Overwing_exit_2_l_ratio) > 0 or get(Overwing_exit_2_r_ratio) > 0
    end,

    is_inhibited = function(self)
        return get(EWD_flight_phase) == PHASE_ELEC_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF or get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN or get(EWD_flight_phase) == PHASE_2ND_ENG_OFF
    end

}
