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
-- File: pages_dynamics.lua 
-- Short description: Draw the dynamic components of the pages
-------------------------------------------------------------------------------

include("DRAIMS/radio_logic.lua")
include("DRAIMS/constants.lua")

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------
local function draw_arrow_up(x,y)
    local ARROW_SIZE = 7
    local ARROW_LENGTH = 25
    sasl.gl.drawConvexPolygon ({x-ARROW_SIZE, y+ARROW_LENGTH,
                                x+ARROW_SIZE, y+ARROW_LENGTH,
                                x, y+ARROW_LENGTH+ARROW_SIZE}, true, 0, ECAM_WHITE)
    sasl.gl.drawWideLine(x, y+5, x, y+ARROW_LENGTH, 5, ECAM_WHITE)
end

local function draw_arrow_dn(x,y)
    local ARROW_SIZE = 7
    local ARROW_LENGTH = 25
    sasl.gl.drawConvexPolygon ({x-ARROW_SIZE, y-ARROW_LENGTH,
                                x, y-ARROW_LENGTH-ARROW_SIZE,
                                x+ARROW_SIZE, y-ARROW_LENGTH,}, true, 0, ECAM_WHITE)
    sasl.gl.drawWideLine(x, y-5, x, y-ARROW_LENGTH, 5, ECAM_WHITE)
end


-------------------------------------------------------------------------------
-- VHF
-------------------------------------------------------------------------------

local function draw_page_vhf_dynamic_freq(data)
    local vhf1_freq = Round_fill(radio_vhf_get_freq(1, false), 3)
    local vhf2_freq = Round_fill(radio_vhf_get_freq(2, false), 3)
    local vhf3_freq = radio_vhf_get_freq(3, false)
    
    if vhf3_freq < 0 then
        vhf3_freq = "DATA"
    else
        vhf3_freq = Round_fill(vhf3_freq ,3)
    end

    if not(DRAIMS_common.vhf_animate_which == 1 and DRAIMS_common.vhf_animate > 0) then
        sasl.gl.drawText(Font_B612regular, 130,size[2]-55, vhf1_freq, 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    if not(DRAIMS_common.vhf_animate_which == 2 and DRAIMS_common.vhf_animate > 0) then
        sasl.gl.drawText(Font_B612regular, 130,size[2]-155, vhf2_freq, 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    if not(DRAIMS_common.vhf_animate_which == 3 and DRAIMS_common.vhf_animate > 0) then
        sasl.gl.drawText(Font_B612regular, 130,size[2]-255, vhf3_freq, 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
end

local function draw_page_vhf_dynamic_freq_animate(perc, freq_prev, freq_curr, i, selected)

    local color_prev = selected and perc > VHF_ANIMATE_SPEED/2 and ECAM_BLUE or ECAM_WHITE
    local color_curr = selected and perc <= VHF_ANIMATE_SPEED/2 and ECAM_BLUE or ECAM_WHITE

    sasl.gl.drawText(Font_B612regular, 100+perc*400,size[2]-40-100*(i-1), freq_curr, 30, false, false, TEXT_ALIGN_CENTER, color_prev)

    sasl.gl.drawText(Font_B612regular, size[1]-100-perc*400,size[2]-40-100*(i-1), freq_prev, 30, false, false, TEXT_ALIGN_CENTER, color_curr)

end

local function is_valid(num)
    return num >= 118.000 and num <= 136.975
end

local function can_be_extended(num)
    return num <= 2 or (num >= 11 and num < 14)
end

local function draw_page_vhf_dynamic_freq_stby_scratchpad(data, i, selected)
    
    local s_len = #DRAIMS_common.scratchpad[i]
    local num = tonumber(DRAIMS_common.scratchpad[i])
    num = num / math.max(1, (10 ^ (s_len-3)))

    local valid = is_valid(num) or can_be_extended(num)

    num = Round_fill(num, math.max(0,s_len-3))
    
    if s_len < 4 then
        num = math.floor(num) .. (s_len < 2 and "_" or "") .. (s_len < 3 and "_" or "") .. ".___"
    else
        num = num .. (s_len < 5 and "_" or "") .. (s_len < 6 and "_" or "")
    end
        
    sasl.gl.drawText(Font_B612regular, size[1]-100,size[2]-55-100*(i-1), num, 35, false, false, TEXT_ALIGN_CENTER, valid and (selected and ECAM_BLUE or ECAM_WHITE) or ECAM_ORANGE)

    if not valid then
                sasl.gl.drawText(Font_B612regular, size[1]-100,size[2]+15-100*(i), "NOT VALID", 23, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

end

local function draw_page_vhf_dynamic_freq_stby_numbers(data, freq, i)
    if freq < 0 then
        freq_str = "DATA"
    else
        freq_str = Round_fill(freq, 3)
    end

    if DRAIMS_common.vhf_animate_which == i and DRAIMS_common.vhf_animate > 0 then
        local freq_curr = radio_vhf_get_freq(i, false)
        if freq_curr < 0 then
            freq_curr = "DATA"
        else
            freq_curr = Round_fill(freq_curr, 3)
        end

        local perc = DRAIMS_common.vhf_animate/VHF_ANIMATE_SPEED

        draw_page_vhf_dynamic_freq_animate(perc, freq_str, freq_curr, i, data.vhf_selected_line == i)
    else
        if #DRAIMS_common.scratchpad[i] > 0 then
            draw_page_vhf_dynamic_freq_stby_scratchpad(data, i, data.vhf_selected_line == i)
        else
            sasl.gl.drawText(Font_B612regular, size[1]-100,size[2]-55-100*(i-1), freq_str, 35, false, false, TEXT_ALIGN_CENTER, data.vhf_selected_line == i and ECAM_BLUE or ECAM_WHITE)
            
            if data.vhf_selected_line == i then
                if freq == 121.500 then
                    sasl.gl.drawText(Font_B612regular, size[1]-100,size[2]+15-100*data.vhf_selected_line, "EMER", 23, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
                elseif freq > 0 then
                    sasl.gl.drawText(Font_B612regular, size[1]-100,size[2]+15-100*data.vhf_selected_line, "STBY", 23, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
                end
            end
        end
    end
end

local function draw_page_vhf_dynamic_freq_stby(data)
    local vhf1_freq = radio_vhf_get_freq(1, true)
    local vhf2_freq = radio_vhf_get_freq(2, true)
    local vhf3_freq = radio_vhf_get_freq(3, true)
    

    draw_page_vhf_dynamic_freq_stby_numbers(data, vhf1_freq, 1)
    draw_page_vhf_dynamic_freq_stby_numbers(data, vhf2_freq, 2)
    draw_page_vhf_dynamic_freq_stby_numbers(data, vhf3_freq, 3)

    -- Rectangle currently selected freq
    Sasl_DrawWideFrame(size[1]-190, size[2]+5-100*data.vhf_selected_line, 180, 80, 2, 1, ECAM_BLUE)
    if data.vhf_selected_line == 3 then
        local arrow_up = vhf3_freq < 0 or vhf3_freq == 121.500
        local arrow_dn = vhf3_freq < 0 or not arrow_up
        if arrow_up then
            draw_arrow_up(size[1]-180,size[2]-255)
        end
        if arrow_dn then
            draw_arrow_dn(size[1]-180,size[2]-255)
        end
    end
end


local function draw_page_vhf_dynamic(data)

    draw_page_vhf_dynamic_freq(data)
    draw_page_vhf_dynamic_freq_stby(data)
    
    -- Update animations
    if data.id == DRAIMS_ID_CAPT and DRAIMS_common.vhf_animate > 0 then
        DRAIMS_common.vhf_animate = DRAIMS_common.vhf_animate - get(DELTA_TIME_NO_STOP)
    end
    
end

-------------------------------------------------------------------------------
-- Generic
-------------------------------------------------------------------------------


local function draw_info_messages(data)
    sasl.gl.drawText(Font_B612regular, 430, 70, data.info_message[1], 24, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 430, 45, data.info_message[2], 24, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 430, 20, data.info_message[3], 24, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
end

function draw_page_dynamic(data)
    if data.current_page == PAGE_VHF then
        draw_page_vhf_dynamic(data)
        draw_info_messages(data)
    end
end
