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

-------------------------------------------------------------------------------
-- Scratchpad functinos
-------------------------------------------------------------------------------

local function update_scratchpad_vhf(data)
    local value = data.scratchpad_input
    local sel = data.vhf_selected_line

    if value == 2 and #DRAIMS_common.scratchpad[sel] == 0 then
        DRAIMS_common.scratchpad[sel] = "1"
    end

    if value < 10 then
        if #DRAIMS_common.scratchpad[sel] < 6 then
            DRAIMS_common.scratchpad[sel] = DRAIMS_common.scratchpad[sel] .. value
        else
            DRAIMS_common.scratchpad[sel] = "" .. value
        end
    elseif value == 10 then
        -- We don't need to do anything special for the dot
    elseif value == 11 then
        DRAIMS_common.scratchpad[sel] = string.sub(DRAIMS_common.scratchpad[sel], 1, -2)
    end
end

local function update_scratchpad_sqwk(data)
    local value = data.scratchpad_input
    if value <= 7 then
        if #DRAIMS_common.scratchpad_sqwk < 4 then
            DRAIMS_common.scratchpad_sqwk = DRAIMS_common.scratchpad_sqwk .. value
        else
            DRAIMS_common.scratchpad_sqwk = "" .. value
        end
    elseif value == 11 then
        DRAIMS_common.scratchpad_sqwk = string.sub(DRAIMS_common.scratchpad_sqwk, 1, -2)
    end

    if #DRAIMS_common.scratchpad_sqwk == 4 then
        DRAIMS_common.scratchpad_sqwk_timeout = get(TIME)
        DRAIMS_common.scratchpad_sqwk_data = data
    else
        DRAIMS_common.scratchpad_sqwk_timeout = 0
    end

end

local function update_scratchpad_nav_ls(data)
    local value = data.scratchpad_input
    local sel = data.nav_ls_selected_line
    
    if value == 0 and #DRAIMS_common.scratchpad_nav_ls[sel] == 0 then
        DRAIMS_common.scratchpad_nav_ls[sel] = "1"
    end
    
    if value < 10 then
        if (sel == 1 and #DRAIMS_common.scratchpad_nav_ls[sel] < 5) or (#DRAIMS_common.scratchpad_nav_ls[sel] < 3) then
            DRAIMS_common.scratchpad_nav_ls[sel] = DRAIMS_common.scratchpad_nav_ls[sel] .. value
        else
            DRAIMS_common.scratchpad_nav_ls[sel] = "" .. value
        end
    elseif value == 10 then
        -- We don't need to do anything special for the dot
    elseif value == 11 then
        DRAIMS_common.scratchpad_nav_ls[sel] = string.sub(DRAIMS_common.scratchpad_nav_ls[sel], 1, -2)
    end

end

local function update_scratchpad_nav_gls(data)
    local value = data.scratchpad_input
    
    if value < 10 then
        if #DRAIMS_common.scratchpad_nav_gls < 5 then
            DRAIMS_common.scratchpad_nav_gls = DRAIMS_common.scratchpad_nav_gls .. value
        else
            DRAIMS_common.scratchpad_nav_gls = "" .. value
        end
    elseif value == 10 then
        -- We don't need to do anything special for the dot
    elseif value == 11 then
        DRAIMS_common.scratchpad_nav_gls = string.sub(DRAIMS_common.scratchpad_nav_gls, 1, -2)
    end

end

local function update_scratchpad_nav_vor(data)
    local value = data.scratchpad_input
    local sel = data.nav_vor_selected_line
    
    if value == 0 and #DRAIMS_common.scratchpad_nav_vor[sel] == 0 then
        DRAIMS_common.scratchpad_nav_vor[sel] = "1"
    end
    
    if value < 10 then
        if (sel <= 2 and #DRAIMS_common.scratchpad_nav_vor[sel] < 5) or (#DRAIMS_common.scratchpad_nav_vor[sel] < 3) then
            DRAIMS_common.scratchpad_nav_vor[sel] = DRAIMS_common.scratchpad_nav_vor[sel] .. value
        else
            DRAIMS_common.scratchpad_nav_vor[sel] = "" .. value
        end
    elseif value == 10 then
        -- We don't need to do anything special for the dot
    elseif value == 11 then
        DRAIMS_common.scratchpad_nav_vor[sel] = string.sub(DRAIMS_common.scratchpad_nav_vor[sel], 1, -2)
    end

end


local function update_scratchpad_nav_adf(data)
    local value = data.scratchpad_input
    local sel = data.nav_adf_selected_line
    
    if value == 0 and #DRAIMS_common.scratchpad_nav_adf[sel] == 0 then
        DRAIMS_common.scratchpad_nav_adf[sel] = "1"
    end
    
    if value < 10 then
        if (#DRAIMS_common.scratchpad_nav_adf[sel] < 3) then
            DRAIMS_common.scratchpad_nav_adf[sel] = DRAIMS_common.scratchpad_nav_adf[sel] .. value
        else
            DRAIMS_common.scratchpad_nav_adf[sel] = "" .. value
        end
    elseif value == 10 then
        -- We don't need to do anything special for the dot
    elseif value == 11 then
        DRAIMS_common.scratchpad_nav_adf[sel] = string.sub(DRAIMS_common.scratchpad_nav_adf[sel], 1, -2)
    end

end


function save_scratchpad_sqwk(data)
    DRAIMS_common.scratchpad_sqwk_timeout = 0
    if #DRAIMS_common.scratchpad_sqwk == 4 then
        set(TCAS_code, tonumber(DRAIMS_common.scratchpad_sqwk))
    else
        data.info_message[1] = "SQWK"
        data.info_message[2] = "REVERTED TO"
        data.info_message[3] = "PREV ENTRY"
    end
    DRAIMS_common.scratchpad_sqwk = ""
end

function update_scratchpad(data)
    local value = data.scratchpad_input
    if value < 0 then
        return
    end

    if data.current_page == PAGE_VHF and not data.sqwk_select then
        update_scratchpad_vhf(data)
    elseif (data.current_page == PAGE_VHF
         or data.current_page == PAGE_HF
         or data.current_page == PAGE_TEL
         or data.current_page == PAGE_ATC) and data.sqwk_select then
        update_scratchpad_sqwk(data)
    elseif data.current_page == PAGE_NAV_LS then
        update_scratchpad_nav_ls(data)
    elseif data.current_page == PAGE_NAV_GLS then
        update_scratchpad_nav_gls(data)
    elseif data.current_page == PAGE_NAV_VOR then
        update_scratchpad_nav_vor(data)
    elseif data.current_page == PAGE_NAV_ADF then
        update_scratchpad_nav_adf(data)
    end
    data.scratchpad_input = -1   -- Reset to no key pressed
end

local function frequency_hinter(num, min, max)
    local freq_to_set = 0
    if num/1000 >= min and num/1000 <= max then
        freq_to_set = num/1000
    end
    if num/100 >= min and num/100 <= max then
        freq_to_set = num/100
    end
    if num/10 >= min and num/10 <= max then
        freq_to_set = num/10
    end
    if num >= min and num <= max then
        freq_to_set = num
    end
    if num == 1 then
        freq_to_set = min
    end
    if (num >= math.floor(min/10) and num < math.ceil(max/10)) then
        freq_to_set = num * 10
    end

    return freq_to_set
end

function save_scratchpad(data, new_sel)
    local old_sel = data.vhf_selected_line

    if old_sel == new_sel and #DRAIMS_common.scratchpad[old_sel] > 0 then   -- Save
        local num = tonumber(DRAIMS_common.scratchpad[old_sel])

        local freq_to_set = frequency_hinter(num, 118.000, 136.975)

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

function save_scratchpad_ls(data, new_sel)
    local old_sel = data.nav_ls_selected_line

    if old_sel == new_sel and #DRAIMS_common.scratchpad_nav_ls[old_sel] > 0 then   -- Save
        local num = tonumber(DRAIMS_common.scratchpad_nav_ls[old_sel])
        
        if old_sel == 1 then
            -- FREQUENCY
            local freq_to_set = frequency_hinter(num, 108.000, 111.95)
            if freq_to_set > 0 then
                radio_ils_set_freq(freq_to_set)
                DRAIMS_common.scratchpad_nav_ls[old_sel] = ""
            end
        else
            -- CRS
            if num <= 360 then
                radio_ils_set_crs(num)
            end
            DRAIMS_common.scratchpad_nav_ls[old_sel] = ""
        end
    else    -- Revert
        if #DRAIMS_common.scratchpad_nav_ls[old_sel] > 0 then
            DRAIMS_common.scratchpad_nav_ls[old_sel] = ""
        end
    end
end

function save_scratchpad_gls(data)

    if #DRAIMS_common.scratchpad_nav_gls > 0 then   -- Save
        local num = tonumber(DRAIMS_common.scratchpad_nav_gls)
        -- CRS
        if num <= 99999 then
            radio_gls_set_channel(num)
        end
        DRAIMS_common.scratchpad_nav_gls = ""
    end
end


function save_scratchpad_vor(data, new_sel)
    local old_sel = data.nav_vor_selected_line

    if old_sel == new_sel and #DRAIMS_common.scratchpad_nav_vor[old_sel] > 0 then   -- Save
        local num = tonumber(DRAIMS_common.scratchpad_nav_vor[old_sel])
        
        if old_sel <= 2 then
            -- FREQUENCY
            local freq_to_set = frequency_hinter(num, 108.000, 117.975)
            
            if freq_to_set > 0 then
                radio_vor_set_freq(old_sel, false, freq_to_set)
                DRAIMS_common.scratchpad_nav_vor[old_sel] = ""
            end
        else
            -- CRS
            if num <= 360 then
                radio_vor_set_crs(old_sel-2, num)
            end
            DRAIMS_common.scratchpad_nav_vor[old_sel] = ""
        end
    else    -- Revert
        if #DRAIMS_common.scratchpad_nav_vor[old_sel] > 0 then
            DRAIMS_common.scratchpad_nav_vor[old_sel] = ""
        end
    end
end

function save_scratchpad_adf(data, new_sel)
    local old_sel = data.nav_adf_selected_line

    if old_sel == new_sel and #DRAIMS_common.scratchpad_nav_adf[old_sel] > 0 then   -- Save
        local num = tonumber(DRAIMS_common.scratchpad_nav_adf[old_sel])

        -- FREQUENCY
        if num >= 190 and num <= 535 then
            radio_adf_set_freq(old_sel, num)
            DRAIMS_common.scratchpad_nav_adf[old_sel] = ""
        end
    else    -- Revert
        if #DRAIMS_common.scratchpad_nav_adf[old_sel] > 0 then
            DRAIMS_common.scratchpad_nav_adf[old_sel] = ""
        end
    end
end

-------------------------------------------------------------------------------
-- Info messages
-------------------------------------------------------------------------------

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

function info_tel_inop(data, i)
    data.info_message[1] = "TEL" .. i
    data.info_message[2] = "INOPERATIVE"
    data.info_message[3] = ""
end

function info_no_conf(data)
    data.info_message[1] = "NO ONGOING"
    data.info_message[2] = "CALL"
    data.info_message[3] = ""
end

-------------------------------------------------------------------------------
-- VHF freq
-------------------------------------------------------------------------------

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

function vhf_sel_line(data, i)
    save_scratchpad(data, i)
    if #DRAIMS_common.scratchpad_sqwk > 0 then
        save_scratchpad_sqwk(data)
    end
    data.vhf_selected_line = i
    data.sqwk_select = false
end

function ls_sel_line(data, i)
    save_scratchpad_ls(data, i)
    data.nav_ls_selected_line = i
end

function gls_sel_line(data)
    save_scratchpad_gls(data)
end

function vor_sel_line(data, i)
    save_scratchpad_vor(data, i)
    data.nav_vor_selected_line = i
end

function adf_sel_line(data, i)
    save_scratchpad_adf(data, i)
    data.nav_adf_selected_line = i
end

-------------------------------------------------------------------------------
-- TCAS
-------------------------------------------------------------------------------

function tcas_ident()
    sasl.commandOnce(sasl.findCommand("sim/transponder/transponder_ident"))
end

function tcas_sqwk_num(data)
    if #DRAIMS_common.scratchpad[data.vhf_selected_line] > 0 then
        save_scratchpad(data, -1)
    end
    if #DRAIMS_common.scratchpad_sqwk > 0 then
        save_scratchpad_sqwk(data)
    end
    data.sqwk_select = not data.sqwk_select
end

-------------------------------------------------------------------------------
-- Misc updates
-------------------------------------------------------------------------------


function update_lights()
    local bright_dr = globalPropertyf("a321neo/cockpit/lights/mip_pedestal_integral_value")
    set(DRAIMS_1_keys_brightness, get(bright_dr) * (get(DRAIMS_1_brightness_act) > 0 and 1 or 0) );
    set(DRAIMS_2_keys_brightness, get(bright_dr) * (get(DRAIMS_2_brightness_act) > 0 and 1 or 0) );
end

function update_vhf_data()
    set(VHF_transmit_dest, get(Capt_VHF_1_transmit_selected) * 6 + get(Capt_VHF_2_transmit_selected) * 7)
    set(VHF_transmit_dest_manual, get(Capt_VHF_1_transmit_selected) * 6 + get(Capt_VHF_2_transmit_selected) * 7)

    set(VHF_1_audio_selected, get(Capt_VHF_recv_selected, 1))
    set(VHF_2_audio_selected, get(Capt_VHF_recv_selected, 2))
end

function update_sqkw_timeout()
    if DRAIMS_common.scratchpad_sqwk_timeout > 0 and get(TIME) - DRAIMS_common.scratchpad_sqwk_timeout > 1 then
        DRAIMS_common.scratchpad_sqwk_timeout = 0
        save_scratchpad_sqwk(DRAIMS_common.scratchpad_sqwk_data)
    end
end

