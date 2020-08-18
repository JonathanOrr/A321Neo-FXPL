include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- CAUTION: BLEED OFF
----------------------------------------------------------------------------------------------------
Message_BLEED_OFF = {
    text = function(self)
        local N = ""
        if get(Eng1_bleed_off_button) == 1 and get(Eng2_bleed_off_button) == 1 then
            N = "1 + 2"
        elseif get(Eng1_bleed_off_button) == 1 then
            N = "1"
        elseif get(Eng2_bleed_off_button) == 1 then
            N = "2"
        end
        return "    BLEED " .. N .. " OFF"
    end,

    color = function(self)
        return COL_CAUTION
    end,

    is_active = function(self)
      return true -- Always active when group is active
    end
}

MessageGroup_BLEED_OFF = {

    shown = false,

    text  = function(self)
                return "AIR"
            end,
    color = function(self)
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_1,

    sd_page = ECAM_PAGE_BLEED,

    messages = {
        Message_BLEED_OFF
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Active if any brakes over 300 C
        return get(Eng1_bleed_off_button) == 1 or get(Eng2_bleed_off_button) == 1
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        -- During takeoff and landing at high speed
        return get(EWD_flight_phase) ~= PHASE_1ST_ENG_ON and get(EWD_flight_phase) ~= PHASE_AIRBONE
    end

}
