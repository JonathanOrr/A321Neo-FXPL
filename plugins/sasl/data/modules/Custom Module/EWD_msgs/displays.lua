----------------------------------------------------------------------------------------------------
-- CAUTION: DMC FAULT
----------------------------------------------------------------------------------------------------
local Message_DMC_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_DISPLAY_DMC_1) == 1 and get(FAILURE_DISPLAY_DMC_2) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_DISPLAY_DMC_2) == 1 and get(FAILURE_DISPLAY_DMC_3) == 1 then
            N = "2 + 3"
        elseif get(FAILURE_DISPLAY_DMC_1) == 1 and get(FAILURE_DISPLAY_DMC_3) == 1 then
            N = "1 + 3"
        elseif get(FAILURE_DISPLAY_DMC_1) == 1 then
            N = "1"
        elseif get(FAILURE_DISPLAY_DMC_2) == 1 then
            N = "2"
        elseif get(FAILURE_DISPLAY_DMC_3) == 1 then
            N = "3"
        end
        return "    DMC " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

local Message_EIS_SWITCH_CAPT = {
    text = function()
        return " - EIS DMC SWITCH....CAPT"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(FAILURE_DISPLAY_DMC_1) == 1 and 
             not (get(FAILURE_DISPLAY_DMC_2) == 1 or get(FAILURE_DISPLAY_DMC_3) == 1)
             and get(DMC_position_dmc_eis) > -0.5
    end
}

local Message_EIS_SWITCH_FO = {
    text = function()
        return " - EIS DMC SWITCH......FO"
    end,

    color = function()
        return COL_ACTIONS
    end,

    is_active = function()
      return get(FAILURE_DISPLAY_DMC_2) == 1 and 
             not (get(FAILURE_DISPLAY_DMC_1) == 1 or get(FAILURE_DISPLAY_DMC_3) == 1)
             and get(DMC_position_dmc_eis) < 0.5
    end
}


MessageGroup_DMC_FAULT = {

    shown = false,

    text  = function()
                return "EIS"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_DMC_FAULT,
        Message_EIS_SWITCH_CAPT,
        Message_EIS_SWITCH_FO
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_DISPLAY_DMC_1) == 1 or get(FAILURE_DISPLAY_DMC_2) == 1  or get(FAILURE_DISPLAY_DMC_3) == 1  
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: FWC FAULT
----------------------------------------------------------------------------------------------------

local Message_FWC_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_DISPLAY_FWC_1) == 1 then
            N = "1"
        elseif get(FAILURE_DISPLAY_FWC_2) == 1 then
            N = "2"
        end
        return "    FWC " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

local Message_MONITOR_SYS = {
    text = function() return " MONITOR SYS" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1 end
}

local Message_MONITOR_OVHD = {
    text = function() return " MONITOR OVERHEAD PANEL" end,
    color = function() return COL_ACTIONS end,
    is_active = function() return get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1 end
}

MessageGroup_FWC_FAULT = {

    shown = false,

    text  = function()
                return "FWS"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_FWC_FAULT,
        Message_MONITOR_SYS,
        Message_MONITOR_OVHD
    },

    -- Method to check if this message group is active
    is_active = function()
        return get(FAILURE_DISPLAY_FWC_1) == 1 or get(FAILURE_DISPLAY_FWC_2) == 1 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return not (get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1) and  
        is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end

}


