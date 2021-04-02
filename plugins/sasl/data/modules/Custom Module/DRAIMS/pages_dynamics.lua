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
include("DRAIMS/misc_drawings.lua")
include("DRAIMS/constants.lua")

local COLOR_DISABLED = {0.4, 0.4, 0.4}

local tel_directory = {
    "OPS AIRLINE",
    "TECH AIRLINE",
    "CARGO OPS",
    "EMERG CALL",
    "JONATHAN",
    "HENRICK",
    "RICORICO",
    "CHAI",
    "THE US PRESIDENT"
}

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

local function complete_frequency(num, str_len)

    num = Round_fill(num, math.max(0,str_len-3))

    if str_len < 4 then
        num = math.floor(num) .. (str_len < 2 and "_" or "") .. (str_len < 3 and "_" or "") .. ".___"
    else
        num = num .. (str_len < 5 and "_" or "") .. (str_len < 6 and "_" or "")
    end
    return num
end

local function complete_frequency_nav(num, str_len)

    num = Round_fill(num, math.max(0,str_len-3))

    if str_len < 4 then
        num = math.floor(num) .. (str_len < 2 and "_" or "") .. (str_len < 3 and "_" or "") .. ".__"
    else
        num = num .. (str_len < 5 and "_" or "")
    end
    return num
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
        sasl.gl.drawText(Font_Roboto, 130,size[2]-55, vhf1_freq, 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    if not(DRAIMS_common.vhf_animate_which == 2 and DRAIMS_common.vhf_animate > 0) then
        sasl.gl.drawText(Font_Roboto, 130,size[2]-155, vhf2_freq, 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    if not(DRAIMS_common.vhf_animate_which == 3 and DRAIMS_common.vhf_animate > 0) then
        sasl.gl.drawText(Font_Roboto, 130,size[2]-255, vhf3_freq, 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
end

local function draw_page_vhf_dynamic_freq_animate(perc, freq_prev, freq_curr, i, selected)

    local color_prev = selected and perc > VHF_ANIMATE_SPEED/2 and ECAM_BLUE or ECAM_WHITE
    local color_curr = selected and perc <= VHF_ANIMATE_SPEED/2 and ECAM_BLUE or ECAM_WHITE

    sasl.gl.drawText(Font_Roboto, 100+perc*400,size[2]-40-100*(i-1), freq_curr, 30, false, false, TEXT_ALIGN_CENTER, color_prev)

    sasl.gl.drawText(Font_Roboto, size[1]-100-perc*400,size[2]-40-100*(i-1), freq_prev, 30, false, false, TEXT_ALIGN_CENTER, color_curr)

end

local function is_valid_vhf(num)
    return num >= 118.000 and num <= 136.975
end

local function is_valid_vor(num)
    return num >= 108.000 and num <= 117.95
end

local function can_be_extended_vor(num)
    return num <= 1 or (num >= 10 and num < 12)
end

local function is_valid_ls(num)
    return num >= 108.100 and num <= 111.95
end

local function can_be_extended_ls(num)
    return num <= 1 or (num >= 10 and num < 12)
end


local function can_be_extended_vhf(num)
    return num <= 2 or (num >= 11 and num < 14)
end

local function draw_page_vhf_dynamic_freq_stby_scratchpad(data, i, selected)
    
    local s_len = #DRAIMS_common.scratchpad[i]
    local num = tonumber(DRAIMS_common.scratchpad[i])
    num = num / math.max(1, (10 ^ (s_len-3)))

    local valid = is_valid_vhf(num) or can_be_extended_vhf(num)

    num = complete_frequency(num, s_len)

    sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]-55-100*(i-1), num, 35, false, false, TEXT_ALIGN_CENTER, valid and (selected and ECAM_BLUE or ECAM_WHITE) or ECAM_ORANGE)

    if not valid then
        sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]+15-100*(i), "NOT VALID", 23, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
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

        draw_page_vhf_dynamic_freq_animate(perc, freq_str, freq_curr, i, data.vhf_selected_line == i and not data.sqwk_select)
    else
        if #DRAIMS_common.scratchpad[i] > 0 then
            draw_page_vhf_dynamic_freq_stby_scratchpad(data, i, data.vhf_selected_line == i and not data.sqwk_select)
        else
            sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]-55-100*(i-1), freq_str, 35, false, false, TEXT_ALIGN_CENTER, data.vhf_selected_line == i and not data.sqwk_select and ECAM_BLUE or ECAM_WHITE)
            
            if data.vhf_selected_line == i and not data.sqwk_select then
                if freq == 121.500 then
                    sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]+15-100*data.vhf_selected_line, "EMER", 23, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
                elseif freq > 0 then
                    sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]+15-100*data.vhf_selected_line, "STBY", 23, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
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
    if not data.sqwk_select then
        Sasl_DrawWideFrame(size[1]-190, size[2]+5-100*data.vhf_selected_line, 180, 80, 2, 1, ECAM_BLUE)
    end
    if data.vhf_selected_line == 3 and not data.sqwk_select then
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
-- ATC
-------------------------------------------------------------------------------

local function draw_page_atc_tcas_lbl(text, x, y, which_type)
    if which_type == 1 then
        draw_inverted_text(x, y, text, 25, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    elseif which_type == 2 then
        local w,h = sasl.gl.measureText(Font_Roboto, text, 25, false, false)
        Sasl_DrawWideFrame(x-w, y-3, w, 26, 2, 1, ECAM_BLUE)
        sasl.gl.drawText(Font_Roboto, x, y, text, 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    elseif which_type == 3 then
        sasl.gl.drawText(Font_Roboto, x, y, text, 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    end
end

local function draw_page_atc_tcas_mode(data)
    local y = size[2]-75
    if get(TCAS_mode) == 0 then
        draw_page_atc_tcas_lbl("STBY", size[1] - 160, y, get(TCAS_master) == 1 and 1 or 2)
        draw_page_atc_tcas_lbl("TA/RA", size[1] - 65, y, 3)
        draw_page_atc_tcas_lbl("TA", size[1] - 20, y, 3)
    elseif get(TCAS_mode) == 1 then
        draw_page_atc_tcas_lbl("STBY", size[1] - 160, y, 3)
        draw_page_atc_tcas_lbl("TA/RA", size[1] - 65, y, 3)
        draw_page_atc_tcas_lbl("TA", size[1] - 20, y, get(TCAS_master) == 1 and 1 or 2)
    else
        draw_page_atc_tcas_lbl("STBY", size[1] - 160, y, 3)
        draw_page_atc_tcas_lbl("TA/RA", size[1] - 65, y, get(TCAS_master) == 1 and 1 or 2)
        draw_page_atc_tcas_lbl("TA", size[1] - 20, y, 3)
    end
end

local function draw_page_atc_tcas_disp_mode(data)
    local y = size[2]-175
    if get(TCAS_disp_mode) == 0 then
        draw_page_atc_tcas_lbl("NORM", size[1] - 220, y, get(TCAS_master) == 1 and 1 or 2)
        draw_page_atc_tcas_lbl("ABV", size[1] - 160, y, 3)
        draw_page_atc_tcas_lbl("BLW", size[1] - 95, y, 3)
        draw_page_atc_tcas_lbl("THRT", size[1] - 20, y, 3)
    elseif get(TCAS_disp_mode) == 1 then
        draw_page_atc_tcas_lbl("NORM", size[1] - 220, y, 3)
        draw_page_atc_tcas_lbl("ABV", size[1] - 160, y, get(TCAS_master) == 1 and 1 or 2)
        draw_page_atc_tcas_lbl("BLW", size[1] - 95, y, 3)
        draw_page_atc_tcas_lbl("THRT", size[1] - 20, y, 3)
    elseif get(TCAS_disp_mode) == 2 then
        draw_page_atc_tcas_lbl("NORM", size[1] - 220, y, 3)
        draw_page_atc_tcas_lbl("ABV", size[1] - 160, y, 3)
        draw_page_atc_tcas_lbl("BLW", size[1] - 95, y, get(TCAS_master) == 1 and 1 or 2)
        draw_page_atc_tcas_lbl("THRT", size[1] - 20, y, 3)
    else
        draw_page_atc_tcas_lbl("NORM", size[1] - 220, y, 3)
        draw_page_atc_tcas_lbl("ABV", size[1] - 160, y, 3)
        draw_page_atc_tcas_lbl("BLW", size[1] - 95, y, 3)
        draw_page_atc_tcas_lbl("THRT", size[1] - 20, y, get(TCAS_master) == 1 and 1 or 2)
    end
end

local function draw_page_atc_tcas_alt_rptg(data)
    local y = size[2]-275
    if get(TCAS_alt_rptg) == 0 then
        draw_page_atc_tcas_lbl("OFF", size[1] - 70, y, get(TCAS_master) == 1 and 1 or 2)
        draw_page_atc_tcas_lbl("ON", size[1] - 20, y, 3)
    else
        draw_page_atc_tcas_lbl("OFF", size[1] - 70, y, 3)
        draw_page_atc_tcas_lbl("ON", size[1] - 20, y, get(TCAS_master) == 1 and 1 or 2)
    end
end

local function draw_page_atc_dynamic(data)

    if get(TCAS_atc_sel) == 1 then
        draw_inverted_text(20,size[2]-75, "XPDR1", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_Roboto, 110, size[2]-75, "XPDR2", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    else
        sasl.gl.drawText(Font_Roboto, 20, size[2]-75, "XPDR1", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        draw_inverted_text(110,size[2]-75, "XPDR2", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)
    end

    if get(TCAS_master) == 0 then
        draw_inverted_text(20,size[2]-175, "STBY", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_Roboto, 90, size[2]-175, "AUTO", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    else
        sasl.gl.drawText(Font_Roboto, 20, size[2]-175, "STBY", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        draw_inverted_text(90, size[2]-175, "AUTO", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)
    end

    draw_page_atc_tcas_mode(data)
    draw_page_atc_tcas_disp_mode(data)
    draw_page_atc_tcas_alt_rptg(data)
end


local function draw_tcas_shortcuts(data)
    local text  = "NORM"
    local color = ECAM_GREEN

    if get(TCAS_disp_mode) == 1 then
        text = "ABV"
        color = ECAM_WHITE
    elseif get(TCAS_disp_mode) == 2 then
        text = "BLW"
        color = ECAM_WHITE
    elseif get(TCAS_disp_mode) == 3 then
        text = "THRT"
        color = ECAM_WHITE
    end
    
    if get(TCAS_master) == 0 then
        color = COLOR_DISABLED
    end
    
    sasl.gl.drawText(Font_Roboto, 185, 20, text, 24, false, false, TEXT_ALIGN_CENTER, color)

    if get(TCAS_mode) == 0 then
        text = "STBY"
        color = ECAM_ORANGE
    elseif get(TCAS_mode) == 1 then
        text = "TA"
        color = ECAM_WHITE
    elseif get(TCAS_mode) == 2 then
        text = "TA/RA"
        color = ECAM_GREEN
    end

    if get(TCAS_master) == 0 then
        color = COLOR_DISABLED
    end

    sasl.gl.drawText(Font_Roboto, 275, 20, text, 24, false, false, TEXT_ALIGN_CENTER, color)
end


local function draw_tcas_sqwk(data)
    if get(TCAS_master) == 1 then
        sasl.gl.drawText(Font_Roboto, 65, 70, "SQWK" .. get(TCAS_atc_sel), 24, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    else
        sasl.gl.drawText(Font_Roboto, 65, 70, "STBY", 24, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    
    local curr_tcas_code = get(TCAS_code)
    local font_size = 38
    
    if DRAIMS_common.scratchpad_sqwk ~= nil and #DRAIMS_common.scratchpad_sqwk > 0 then
        curr_tcas_code = DRAIMS_common.scratchpad_sqwk
        for i=#DRAIMS_common.scratchpad_sqwk,3 do
            curr_tcas_code = curr_tcas_code .. "_"
        end
        font_size = 32
    end
    sasl.gl.drawText(Font_Roboto, 65, 25, curr_tcas_code, font_size, false, false, TEXT_ALIGN_CENTER, data.sqwk_select and ECAM_BLUE or (get(TCAS_master) == 1 and ECAM_GREEN or ECAM_WHITE))

    if data.sqwk_select then
        Sasl_DrawWideFrame(10, 20, 115, 74, 2, 1, ECAM_BLUE)
    end
end

-------------------------------------------------------------------------------
-- NAV
-------------------------------------------------------------------------------

local function draw_page_nav_dynamic_stby_nav()
    if get(DRAIMS_nav_stby_mode) == 0 then
        draw_inverted_text(20, size[2]-175, "AUTO", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_Roboto, 100, size[2]-175, "STBY NAV", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

        draw_menu_item_right(1, "LS", COLOR_DISABLED)
        draw_menu_item_right(2, "VOR",COLOR_DISABLED)
        draw_menu_item_right(3, "ADF",COLOR_DISABLED)
    else
        sasl.gl.drawText(Font_Roboto, 20, size[2]-175, "AUTO", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        draw_inverted_text(100, size[2]-175, "STBY NAV", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)

        draw_menu_item_right(1, "LS")
        draw_menu_item_right(2, "VOR")
        draw_menu_item_right(3, "ADF")
    end
end

local function draw_page_nav_dynamic_voice()
    if get(DRAIMS_nav_voice_mode) == 0 then
        sasl.gl.drawText(Font_Roboto, 20, size[2]-375, "ON", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        draw_inverted_text(70, size[2]-375, "OFF", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)
    else
        draw_inverted_text(20, size[2]-375, "ON", 25, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_Roboto, 70, size[2]-375, "OFF", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end
end

local function draw_page_nav_dynamic_audio_nav_single(x, text, cond)
    if cond then
        draw_inverted_text(x, size[2]-375, text, 25, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    else
        sasl.gl.drawText(Font_Roboto, x, size[2]-375, text, 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    end
end

local function draw_page_nav_dynamic_audio_nav()

    draw_page_nav_dynamic_audio_nav_single(size[1]-390, "LS", get(DRAIMS_nav_audio_sel) == 0)
    draw_page_nav_dynamic_audio_nav_single(size[1]-320, "MKR", get(DRAIMS_nav_audio_sel) == 1)
    draw_page_nav_dynamic_audio_nav_single(size[1]-245, "VOR1", get(DRAIMS_nav_audio_sel) == 2)
    draw_page_nav_dynamic_audio_nav_single(size[1]-170, "VOR2", get(DRAIMS_nav_audio_sel) == 3)
    draw_page_nav_dynamic_audio_nav_single(size[1]-95,  "ADF1", get(DRAIMS_nav_audio_sel) == 4)
    draw_page_nav_dynamic_audio_nav_single(size[1]-20,  "ADF2", get(DRAIMS_nav_audio_sel) == 5)

end

local function draw_page_nav_dynamic(data)
    draw_page_nav_dynamic_stby_nav()
    if get(DRAIMS_nav_audio_sel) == 2 or get(DRAIMS_nav_audio_sel) == 3 then
        draw_page_nav_dynamic_voice()
    end
    draw_page_nav_dynamic_audio_nav()
end

local function draw_nav_reminder()
    if get(DRAIMS_nav_stby_mode) == 0 then
        return
    end

    sasl.gl.drawRectangle(330, 15, 80, 75, ECAM_GREEN)
    sasl.gl.drawText(Font_Roboto, 370, 60, "STBY", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
    sasl.gl.drawText(Font_Roboto, 370, 28, "NAV", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
end

-------------------------------------------------------------------------------
-- NAV - ILS
-------------------------------------------------------------------------------

local function draw_page_ls_dynamic_sel_box(data)
    if data.nav_ls_selected_line == 1 then
        Sasl_DrawWideFrame(45, size[2]+5-100, 180, 80, 2, 1, ECAM_BLUE)
    elseif data.nav_ls_selected_line == 2 then
        Sasl_DrawWideFrame(size[1]-190, size[2]+5-100, 180, 80, 2, 1, ECAM_BLUE)
    end
end

local function get_page_ls_dynamic_freq_scratchpad(ls_freq, i)
    local s_len = #DRAIMS_common.scratchpad_nav_ls[i]

    if s_len == 0 then
        return ls_freq, ECAM_BLUE, 40
    end

    local num = tonumber(DRAIMS_common.scratchpad_nav_ls[i])
    num = num / math.max(1, (10 ^ (s_len-3)))

    local valid = is_valid_ls(num) or can_be_extended_ls(num)

    num = complete_frequency_nav(num, s_len)
    
    return num, valid and ECAM_BLUE or ECAM_ORANGE, 32
end

local function get_page_ls_dynamic_freq_crs(ls_crs, i)
    local s_len = #DRAIMS_common.scratchpad_nav_ls[i]

    if s_len == 0 then
        return ls_crs, ECAM_BLUE, 40
    end

    local num = tonumber(DRAIMS_common.scratchpad_nav_ls[i])
    local valid = num <= 360
    
    return num, valid and ECAM_BLUE or ECAM_ORANGE, 32
end

local function draw_page_ls_dynamic_freq(data)
    local ls1_freq = Round_fill(radio_ils_get_freq(), 2)
    local ls1_crs = Fwd_string_fill(""..radio_ils_get_crs(), "0", 3)

    local ls1_color = ECAM_WHITE
    local crs1_color = ECAM_WHITE

    local ls1_font_size = 40
    local crs1_font_size = 40
    

    if data.nav_ls_selected_line == 1 then
        ls1_freq,ls1_color,ls1_font_size = get_page_ls_dynamic_freq_scratchpad(ls1_freq, 1)
    elseif data.nav_ls_selected_line == 2 then
        ls1_crs,crs1_color,crs1_font_size = get_page_ls_dynamic_freq_crs(ls1_crs, 2)
    end
    
    if not radio_is_ils_working(1) and not not radio_is_ils_working(2) then
        ls1_color = ECAM_ORANGE
        crs1_color = ECAM_ORANGE
        ls1_freq = "---.--"
        ls1_crs = "---"
    end

    sasl.gl.drawText(Font_Roboto, 130,size[2]-80, ls1_freq, ls1_font_size, false, false, TEXT_ALIGN_CENTER, ls1_color)

    sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]-80, ls1_crs, crs1_font_size, false, false, TEXT_ALIGN_CENTER, crs1_color)

end

local function draw_page_nav_ls_dynamic(data)
    draw_page_ls_dynamic_freq(data)
    draw_page_ls_dynamic_sel_box(data)
end


-------------------------------------------------------------------------------
-- NAV - GLS
-------------------------------------------------------------------------------

local function get_page_gls_dynamic_freq_scratchpad(ls_freq)
    local s_len = #DRAIMS_common.scratchpad_nav_gls

    if s_len == 0 then
        return ls_freq, ECAM_BLUE, 40
    end

    local num = tonumber(DRAIMS_common.scratchpad_nav_gls)

    return num, ECAM_BLUE, 32
end

local function draw_page_gls_dynamic_freq(data)
    local ls1_freq = Fwd_string_fill(radio_gls_get_channel().."", "0", 5)
    local crs = radio_gls_get_crs()
    local ls1_crs = crs >= 0 and Fwd_string_fill(""..radio_gls_get_crs(), "0", 3) or "---"

    local ls1_color = ECAM_WHITE

    local ls1_font_size = 40

    ls1_freq,ls1_color,ls1_font_size = get_page_gls_dynamic_freq_scratchpad(ls1_freq)
    
    if not radio_is_gls_working() then
        ls1_color = ECAM_ORANGE
        ls1_freq = "----"
        ls1_crs = "---"
    end

    sasl.gl.drawText(Font_Roboto, 130,size[2]-80, ls1_freq, ls1_font_size, false, false, TEXT_ALIGN_CENTER, ls1_color)

    sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]-68, ls1_crs, 35, false, false, TEXT_ALIGN_CENTER, ls1_crs == "---" and ECAM_ORANGE or ECAM_GREEN)

end

local function draw_page_nav_gls_dynamic(data)
    draw_page_gls_dynamic_freq(data)
    Sasl_DrawWideFrame(45, size[2]+5-100, 180, 80, 2, 1, ECAM_BLUE)
end

-------------------------------------------------------------------------------
-- NAV - VOR
-------------------------------------------------------------------------------

local function draw_page_vor_dynamic_sel_box(data)
    if data.nav_vor_selected_line == 1 then
        Sasl_DrawWideFrame(45, size[2]+5-100, 180, 80, 2, 1, ECAM_BLUE)
    elseif data.nav_vor_selected_line == 2 then
        Sasl_DrawWideFrame(45, size[2]+5-200, 180, 80, 2, 1, ECAM_BLUE)
    elseif data.nav_vor_selected_line == 3 then
        Sasl_DrawWideFrame(size[1]-190, size[2]+5-100, 180, 80, 2, 1, ECAM_BLUE)
    elseif data.nav_vor_selected_line == 4 then
        Sasl_DrawWideFrame(size[1]-190, size[2]+5-200, 180, 80, 2, 1, ECAM_BLUE)
    end
end

local function get_page_vor_dynamic_freq_scratchpad(vor_freq, i)
    local s_len = #DRAIMS_common.scratchpad_nav_vor[i]

    if s_len == 0 then
        return vor_freq, ECAM_BLUE, 40
    end

    local num = tonumber(DRAIMS_common.scratchpad_nav_vor[i])
    num = num / math.max(1, (10 ^ (s_len-3)))

    local valid = is_valid_vor(num) or can_be_extended_vor(num)

    num = complete_frequency_nav(num, s_len)
    
    return num, valid and ECAM_BLUE or ECAM_ORANGE, 32
end

local function get_page_vor_dynamic_freq_crs(vor_crs, i)
    local s_len = #DRAIMS_common.scratchpad_nav_vor[i]

    if s_len == 0 then
        return vor_crs, ECAM_BLUE, 40
    end

    local num = tonumber(DRAIMS_common.scratchpad_nav_vor[i])
    local valid = num <= 360
    
    return num, valid and ECAM_BLUE or ECAM_ORANGE, 32
end

local function draw_page_vor_dynamic_freq(data)
    local vor1_freq = Round_fill(radio_vor_get_freq(1), 2)
    local vor2_freq = Round_fill(radio_vor_get_freq(2), 2)
    local vor1_crs = Fwd_string_fill(""..radio_vor_get_crs(1), "0", 3)
    local vor2_crs = Fwd_string_fill(""..radio_vor_get_crs(2), "0", 3)

    local vor1_color = ECAM_WHITE
    local vor2_color = ECAM_WHITE
    local crs1_color = ECAM_WHITE
    local crs2_color = ECAM_WHITE

    local vor1_font_size = 40
    local vor2_font_size = 40
    local crs1_font_size = 40
    local crs2_font_size = 40
    

    if data.nav_vor_selected_line == 1 then
        vor1_freq,vor1_color,vor1_font_size = get_page_vor_dynamic_freq_scratchpad(vor1_freq, 1)
    elseif data.nav_vor_selected_line == 2 then
        vor2_freq,vor2_color,vor2_font_size = get_page_vor_dynamic_freq_scratchpad(vor2_freq, 2)
    elseif data.nav_vor_selected_line == 3 then
        vor1_crs,crs1_color,crs1_font_size = get_page_vor_dynamic_freq_crs(vor1_crs, 3)
    elseif data.nav_vor_selected_line == 4 then
        vor2_crs,crs2_color,crs2_font_size = get_page_vor_dynamic_freq_crs(vor2_crs, 4)
    end
    
    if not radio_is_vor_working(1) then
        vor1_color = ECAM_ORANGE
        crs1_color = ECAM_ORANGE
        vor1_freq = "---.--"
        vor1_crs = "---"
    end

    if not radio_is_vor_working(2) then
        vor2_color = ECAM_ORANGE
        crs2_color = ECAM_ORANGE
        vor2_freq = "---.--"
        vor2_crs = "---"
    end
    
    sasl.gl.drawText(Font_Roboto, 130,size[2]-80, vor1_freq, vor1_font_size, false, false, TEXT_ALIGN_CENTER, vor1_color)
    sasl.gl.drawText(Font_Roboto, 130,size[2]-180, vor2_freq, vor2_font_size, false, false, TEXT_ALIGN_CENTER, vor2_color)

    sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]-80, vor1_crs, crs1_font_size, false, false, TEXT_ALIGN_CENTER, crs1_color)
    sasl.gl.drawText(Font_Roboto, size[1]-100,size[2]-180, vor2_crs, crs2_font_size, false, false, TEXT_ALIGN_CENTER, crs2_color)

end

local function draw_page_nav_vor_dynamic(data)
    draw_page_vor_dynamic_freq(data)
    draw_page_vor_dynamic_sel_box(data)
end

-------------------------------------------------------------------------------
-- NAV - ADF
-------------------------------------------------------------------------------

local function draw_page_adf_dynamic_sel_box(data)
    if data.nav_adf_selected_line == 1 then
        Sasl_DrawWideFrame(45, size[2]+5-100, 180, 80, 2, 1, ECAM_BLUE)
    elseif data.nav_adf_selected_line == 2 then
        Sasl_DrawWideFrame(45, size[2]+5-200, 180, 80, 2, 1, ECAM_BLUE)
    end
end

local function get_page_adf_dynamic_freq_scratchpad(adf_freq, i)
    local s_len = #DRAIMS_common.scratchpad_nav_adf[i]

    if s_len == 0 then
        return adf_freq, ECAM_BLUE, 40
    end

    local num = tonumber(DRAIMS_common.scratchpad_nav_adf[i])

    local valid = (num >= 190 and num <= 535) or num < 100

    return num, valid and ECAM_BLUE or ECAM_ORANGE, 32
end

local function draw_page_adf_dynamic_freq(data)
    local adf1_freq = radio_adf_get_freq(1)
    local adf2_freq = radio_adf_get_freq(2)

    local adf1_color = ECAM_WHITE
    local adf2_color = ECAM_WHITE

    local adf1_font_size = 40
    local adf2_font_size = 40
    

    if data.nav_adf_selected_line == 1 then
        adf1_freq,adf1_color,adf1_font_size = get_page_adf_dynamic_freq_scratchpad(adf1_freq, 1)
    elseif data.nav_adf_selected_line == 2 then
        adf2_freq,adf2_color,adf2_font_size = get_page_adf_dynamic_freq_scratchpad(adf2_freq, 2)
    end
    
    if not radio_is_adf_working(1) then
        adf1_color = ECAM_ORANGE
        adf1_freq = "---"
    end

    if not radio_is_adf_working(2) then
        adf2_color = ECAM_ORANGE
        adf2_freq = "---"
    end
    
    sasl.gl.drawText(Font_Roboto, 130,size[2]-80, adf1_freq, adf1_font_size, false, false, TEXT_ALIGN_CENTER, adf1_color)
    sasl.gl.drawText(Font_Roboto, 130,size[2]-180, adf2_freq, adf2_font_size, false, false, TEXT_ALIGN_CENTER, adf2_color)

end


local function draw_page_nav_adf_dynamic(data)
    draw_page_adf_dynamic_freq(data)
    draw_page_adf_dynamic_sel_box(data)
end

-------------------------------------------------------------------------------
-- TEL
-------------------------------------------------------------------------------

local function draw_tel_directory(data)

    if data.tel_directory_selected <= 0 then
        data.tel_directory_selected = 1
    elseif data.tel_directory_selected > #tel_directory then
        data.tel_directory_selected = #tel_directory
    end

    local spacing_y = 35
    local initial_y_offset_n = 238
    local initial_y_offset_t = 238

    local c_i = data.tel_directory_selected
    local center_item = tel_directory[c_i]
    sasl.gl.drawText(Font_Roboto, 70, initial_y_offset_n, Fwd_string_fill(""..c_i, "0", 3), 26, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    sasl.gl.drawText(Font_Roboto, 130, initial_y_offset_t, center_item, 34, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    local min = math.max(1, c_i - 3)
    local max = math.min(#tel_directory, c_i + 3)

    if c_i > 1 then
        draw_arrow_up(430,360)
    end

    if c_i < #tel_directory then
        draw_arrow_dn(430,140)
    end


    -- DOWN
    for i=c_i+1,max do
        local j = i - c_i
        sasl.gl.drawText(Font_Roboto, 70, initial_y_offset_n - j*spacing_y - 15, Fwd_string_fill(""..i, "0", 3), 26, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        sasl.gl.drawText(Font_Roboto, 130, initial_y_offset_t- j*spacing_y - 15, tel_directory[i], 26, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end

    -- UP
    for i=min,c_i-1 do
        local j = i - min + 1
        local rev_i = c_i - i + min - 1
        sasl.gl.drawText(Font_Roboto, 70, initial_y_offset_n + j*spacing_y + 15, Fwd_string_fill(""..rev_i, "0", 3), 26, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        sasl.gl.drawText(Font_Roboto, 130, initial_y_offset_t+ j*spacing_y + 15, tel_directory[rev_i], 26, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end


end


-------------------------------------------------------------------------------
-- Generic
-------------------------------------------------------------------------------


local function draw_info_messages(data)
    sasl.gl.drawText(Font_Roboto, 430, 70, data.info_message[1], 24, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_Roboto, 430, 45, data.info_message[2], 24, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_Roboto, 430, 20, data.info_message[3], 24, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
end

function draw_page_dynamic(data)
    if data.current_page == PAGE_VHF then
        draw_page_vhf_dynamic(data)
        draw_info_messages(data)
        draw_tcas_shortcuts(data)
        draw_tcas_sqwk(data)
        draw_nav_reminder()
    elseif data.current_page == PAGE_HF or data.current_page == PAGE_TEL then
        draw_info_messages(data)
        draw_tcas_shortcuts(data)
        draw_tcas_sqwk(data)
        draw_nav_reminder()
    elseif data.current_page == PAGE_TEL_DIRECTORY then
        draw_info_messages(data)
        draw_tcas_shortcuts(data)
        draw_tcas_sqwk(data)
        draw_nav_reminder()
        draw_tel_directory(data)
    elseif data.current_page == PAGE_ATC then
        draw_page_atc_dynamic(data)
        draw_info_messages(data)
        draw_tcas_sqwk(data)
        draw_nav_reminder()
    elseif data.current_page == PAGE_NAV then
        draw_page_nav_dynamic(data)
    elseif data.current_page == PAGE_NAV_GLS then
        draw_page_nav_gls_dynamic(data)
    elseif data.current_page == PAGE_NAV_LS then
        draw_page_nav_ls_dynamic(data)
    elseif data.current_page == PAGE_NAV_VOR then
        draw_page_nav_vor_dynamic(data)
    elseif data.current_page == PAGE_NAV_ADF then
        draw_page_nav_adf_dynamic(data)
    end
end
