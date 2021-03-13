-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: pages_logic.lua 
-- Short description: Logic for pages
-------------------------------------------------------------------------------
include("DRAIMS/radio_logic.lua")

function update_scratchpad(data)
    local value = data.scratchpad_input
    if value < 0 then
        return
    end

    local sel = data.vhf_selected_line

    if value == 2 and #DRAIMS_common.scratchpad[sel] == 0 then
        DRAIMS_common.scratchpad[sel] = "1"
    end

    if value < 10 then
        if #DRAIMS_common.scratchpad[sel] < 6 then
            DRAIMS_common.scratchpad[sel] = DRAIMS_common.scratchpad[sel] .. value
        else
            DRAIMS_common.scratchpad[sel] = value
        end
    elseif value == 10 then

    elseif value == 11 then
        DRAIMS_common.scratchpad[sel] = string.sub(DRAIMS_common.scratchpad[sel], 1, -2)
    end

    data.scratchpad_input = -1   -- Reset to no key pressed
end

function save_scratchpad(data, new_sel)
    local old_sel = data.vhf_selected_line

    if old_sel == new_sel then   -- Save
        local num = tonumber(DRAIMS_common.scratchpad[old_sel])
        local freq_to_set = 0
        if num/1000 >= 118.000 and num/1000 <= 136.975 then
            freq_to_set = num/1000
        end
        if num/100 >= 118.000 and num/100 <= 136.975 then
            freq_to_set = num/100
        end
        if num/10 >= 118.000 and num/10 <= 136.975 then
            freq_to_set = num/10
        end
        if num >= 118.000 and num <= 136.975 then
            freq_to_set = num
        end
        if num == 1 then
            freq_to_set = 118.000
        end
        if (num >= 11 and num < 14) then
            freq_to_set = num * 10
        end
        if freq_to_set > 0 then
            freq_to_set = freq_to_set - (freq_to_set % 0.005)
            radio_vhf_set_freq(old_sel, true, freq_to_set)
            DRAIMS_common.scratchpad[old_sel] = ""
            return true
        end
    else    -- Revert
        if #DRAIMS_common.scratchpad[old_sel] > 0 then
            data.info_message[1] = "VHF" .. old_sel
            data.info_message[2] = "REVERTED TO"
            data.info_message[3] = "PREV ENTRY"
            DRAIMS_common.scratchpad[old_sel] = ""
        end
    end
    
    return false

end

function clear_info_message(data)
    data.info_message[1] = ""
    data.info_message[2] = ""
    data.info_message[3] = ""
end

function info_hf_inop(data, i)
    data.info_message[1] = "HF" .. i
    data.info_message[2] = "INOPERATIVE"
    data.info_message[3] = ""
end

function vhf_swap_freq(data, i)

    if #DRAIMS_common.scratchpad[i] > 0 then
        if not save_scratchpad(data, i) then
            return
        end
    end
    radio_vhf_swap_freq(i)
    DRAIMS_common.vhf_animate_which = i
    DRAIMS_common.vhf_animate = VHF_ANIMATE_SPEED
end

