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
        return PB.ovhd.ac_pack_1.status_bottom or PB.ovhd.ac_pack_1.status_bottom
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function()
        return get(EWD_flight_phase) ~= PHASE_AIRBONE
    end

}

