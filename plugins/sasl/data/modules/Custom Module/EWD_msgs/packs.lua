include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: PACKS OFF
----------------------------------------------------------------------------------------------------
local Message_PACKS_OFF = {
    text = function()
        local N = ""
        if PB.ovhd.ac_pack_1.status_bottom and PB.ovhd.ac_pack_2.status_bottom then
            N = "1 + 2"
        elseif PB.ovhd.ac_pack_1.status_bottom then
            N = "1"
        elseif PB.ovhd.ac_pack_2.status_bottom then
            N = "2"
        end
        return "    PACK " .. N .. " OFF"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_PACKS_OFF = {

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
        Message_PACKS_OFF
    },

    -- Method to check if this message group is active
    is_active = function()
        return (PB.ovhd.ac_pack_1.status_bottom and not get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1) 
            or (PB.ovhd.ac_pack_2.status_bottom and not get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1)
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return get(EWD_flight_phase) ~= PHASE_AIRBONE
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: PACKS FAULT
----------------------------------------------------------------------------------------------------
local Message_PACKS_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 and get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1  then
            N = "1"
        elseif get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1  then
            N = "2"
        end
        return "    PACK " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_PACKS_FAULT = {

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
        Message_PACKS_FAULT,
        {
            text  = function() return " - PACK 1.............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return not PB.ovhd.ac_pack_1.status_bottom and get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 end
        },
        {
            text  = function() return " - PACK 2.............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return not PB.ovhd.ac_pack_2.status_bottom and get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 end
        },
        {
            text  = function() return " DESCENT TO FL 100/MEA" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 and get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 end
        },
        {
            text  = function() return " . BELOW FL 100:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return  get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 and get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 end
        },
        {
            text  = function() return "   - RAM AIR...........ON" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 and get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 and not PB.ovhd.ac_ram_air.status_bottom end
        },
        {
            text  = function() return "   - MAX FL.......100/MEA" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 and get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 end
        },
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 or get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: PACK 1/2 REGUL FAULT
----------------------------------------------------------------------------------------------------
local Message_PACKS_REGUL_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_BLEED_PACK_1_REGUL_FAULT) == 1 and get(FAILURE_BLEED_PACK_2_REGUL_FAULT) == 1 then
            N = "1+2"
        elseif get(FAILURE_BLEED_PACK_1_REGUL_FAULT) == 1 then
            N = "1"
        elseif get(FAILURE_BLEED_PACK_2_REGUL_FAULT) == 1 then
            N = "2"
        end
        return "    PACK " .. N .. " REGUL FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

MessageGroup_PACKS_REGUL_FAULT = {

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
        Message_PACKS_REGUL_FAULT
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_BLEED_PACK_1_REGUL_FAULT) == 1 or get(FAILURE_BLEED_PACK_2_REGUL_FAULT) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}


