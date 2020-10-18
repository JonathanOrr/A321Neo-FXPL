include('EWD_msgs/common.lua')
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
