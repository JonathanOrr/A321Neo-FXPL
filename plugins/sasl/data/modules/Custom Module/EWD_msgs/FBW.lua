include('EWD_msgs/common.lua')

--------------------------------------------------------------------------------
-- CAUTION: ALTN LAW and DIRECT LAW
--------------------------------------------------------------------------------

Message_ALTN_LAW = {
    text = function()
            return "      ALTN LAW"
    end,
    color = function()
            return COL_CAUTION
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
    end
}

Message_DIRECT_LAW = {
    text = function()
            return "      DIRECT LAW"
    end,
    color = function()
            return COL_CAUTION
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

Message_PROT_LOST = {
    text = function()
            return "      (PROT LOST)"
    end,
    color = function()
            return COL_CAUTION
    end,
    is_active = function()
      return true
    end
}

Message_FBW_DO_NOT_SPD_BRK = {
    text = function()
            return " SPD BRK.......DO NOT USE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

Message_FBW_SPEED_LIMIT = {
    text = function()
        if get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW then
            return " MAX SPEED........320/.82"
        else
            return " MAX SPEED........320/.77"
        end
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return true
    end
}

Message_FBW_MAN_PITCH_TRIM = {
    text = function()
            return " - MAN PITCH TRIM.....USE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

Message_FBW_MANEUVER_WITH_CARE = {
    text = function()
            return " MANEUVER WITH CARE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

MessageGroup_FBW_ALTN_DIRECT_LAW = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_ALTN_LAW,
        Message_DIRECT_LAW,
        Message_PROT_LOST,
        Message_FBW_DO_NOT_SPD_BRK,
        Message_FBW_SPEED_LIMIT,
        Message_FBW_MAN_PITCH_TRIM,
        Message_FBW_MANEUVER_WITH_CARE

    },

    sd_page = ECAM_PAGE_FCTL,

    -- Method to check if this message group is active
    is_active = function()
        -- Not showed when any memo is active
        return get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW or get(FBW_total_control_law) == FBW_DIRECT_LAW
    end,

    is_inhibited = function()
        -- Inhibited during takeoff and landing
        return is_active_in({PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end

}

