--------------------------------------------------------------------------------
-- NORMAL: SEAT BELTS
--------------------------------------------------------------------------------

MessageGroup_SEAT_BELTS = {

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
                    return "SEAT BELTS"
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
        return get(Seatbelts) ~= 0 and get(EWD_is_to_memo_showed) == 0 and get(EWD_is_ldg_memo_showed) == 0
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}

--------------------------------------------------------------------------------
-- NORMAL: NO SMOKING
--------------------------------------------------------------------------------

MessageGroup_NO_SMOKING = {

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
                    return "NO SMOKING"
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
        return get(NoSmoking) ~= 0 and get(EWD_is_to_memo_showed) == 0 and get(EWD_is_ldg_memo_showed) == 0
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}


--------------------------------------------------------------------------------
-- NORMAL: NORMAL
-- This is used in some cases to show "NORMAL" on ECAM, e.g. when you press the
-- RCL button and no messages are available to be recalled
--------------------------------------------------------------------------------

MessageGroup_NORMAL = {

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
                    return "NORMAL"
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
        if (get(TIME) - get(EWD_show_normal)) < 5 then  -- Active for 5 seconds
            return true
        else
            return false
        end
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}


--------------------------------------------------------------------------------
-- NORMAL/CAUTION: IRS_ALIGN
--------------------------------------------------------------------------------

MessageGroup_IRS_ALIGN = {

    shown = false,

    text  = function(self)
                return ""
            end,
    color = function(self)
                return COL_INDICATION
            end,

    priority = PRIORITY_LEVEL_1,

    messages = {
        {
            text = function(self)
                local minutes = math.floor(get(Adirs_time_to_align) / 60)
                if get(EWD_flight_phase) <= 2 then
                    return "IRS IN ALIGN " .. minutes .. " MN"
                else
                    return "IRS IN ALIGN"
                end
            end,
            color = function(self)
                if get(EWD_flight_phase) <= 1 then
                    return COL_INDICATION
                else
                    return COL_CAUTION                
                end
            end,
            is_active = function(self)
              return true
            end
        }
    },

    -- Method to check if this message group is active
    is_active = function(self)
        return get(Adirs_irs_aligned) == 0 
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}
