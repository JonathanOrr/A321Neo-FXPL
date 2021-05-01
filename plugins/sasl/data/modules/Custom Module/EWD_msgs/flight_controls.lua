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
        return get(Speedbrake_handle_ratio) < 0 and get(EWD_is_to_memo_showed) == 0 and get(EWD_is_ldg_memo_showed) == 0
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
        return get(Speedbrake_handle_ratio) >= 0 and get(Gear_handle) > 0 and get(Capt_ra_alt_ft) <= 500
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
        local limit = get(Eng_N1_idle) + 5
        return get(Speedbrake_handle_ratio) > 0.05 and (get(Eng_1_N1) > limit or get(Eng_2_N1) > limit)
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
