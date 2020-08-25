position = {1852, 1449, 600, 400}
size = {600, 400}

--variables
local DRAIMS_entry = ""
local ident_box_timer = 0--used to fade alpha
local vhf_cursor_box_timer = 0--used to fade alpha
local nav_cursor_box_timer = 0--used to fade alpha

local vhf_1_monitoring_buffer

local cursor_Mhz_swap_buffer = 0
local cursor_khz_swap_buffer = 0

--DMC colors
local DRAIMS_BLACK = {0,0,0}
local DRAIMS_WHITE = {1.0, 1.0, 1.0}
local DRAIMS_BLUE = {0.004, 1.0, 1.0}
local DRAIMS_GREEN = {0.184, 0.733, 0.219}
local DRAIMS_ORANGE = {0.725, 0.521, 0.18}
local DRAIMS_RED = {1, 0.0, 0.0}

local ident_box_cl = {0.004, 1.0, 1.0, 1}
local vhf_cursor_box_cl = {0.004, 1.0, 1.0, 1}
local nav_cursor_box_cl = {0.184, 0.733, 0.219, 1}
local ils_menu_cl = {0.184, 0.733, 0.219, 1}
local vor_menu_cl = {0.184, 0.733, 0.219, 1}
local adf_menu_cl = {0.184, 0.733, 0.219, 1}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")
local A320_panel_font = sasl.gl.loadFont("fonts/A320PanelFont_V0.2b.ttf")
local A320_panel_font_MONO = sasl.gl.loadFont("fonts/A320PanelFont_V0.2b.ttf")

sasl.gl.setFontRenderMode (A320_panel_font_MONO, TEXT_RENDER_FORCED_MONO, 0.48)--force mono space

--a32nx dataref

--sim dataref

--format checking & error issuing functions RETURN TRUE IF FORMAT IS CORRECT--
--check sqwk code format--
local function chk_dec_pt_fmt()--checking how many decimal points there are
    local dp_found = 0
    local number_found = 0

    for i = 1, #DRAIMS_entry do
        if string.sub(DRAIMS_entry, i, i) == "." then--find decimal point duplication
            dp_found = dp_found + 1
        elseif string.sub(DRAIMS_entry, i, i) ~= "" then--find if there is only decimal points in the entry
            number_found = number_found + 1
        end
    end

    if (number_found == 0 and dp_found > 0) or dp_found > 1 then
        if number_found == 0 and dp_found > 0 then
            set(DRAIMS_format_error, 12)--only decimal points in the entry
            return false
        elseif dp_found > 1 then
            set(DRAIMS_format_error, 11)--more than one decimal points in the entry
            return false
        end
    else
        return true
    end
end

local function check_sqwk_fmt()
    if chk_dec_pt_fmt() == true then
        if tonumber(DRAIMS_entry) >= 0 and tonumber(DRAIMS_entry) <= 7777 then
            if tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry)) == 0 then
                return true
            else
                set(DRAIMS_format_error, 9)--sqwk integer only
                return false
            end
        else
            set(DRAIMS_format_error, 8)--sqwk out of range
            return false
        end
    else
        return false
    end
end

local function check_vhf_fmt()--check for the VHF entry format
    if chk_dec_pt_fmt() == true then
        if (tonumber(DRAIMS_entry) >= 118 and tonumber(DRAIMS_entry) <= 137) or (tonumber(DRAIMS_entry) > 0 and tonumber(DRAIMS_entry) < 1) then
            return true
        else
            set(DRAIMS_format_error, 2)--vhf out of range
            return false
        end
    else
        return false
    end
end

local function check_if_entry_is_ils()--check if the nav1 frequency is a VOR freq
    if #DRAIMS_entry > 0 then
        if get(chk_dec_pt_fmt) == true then
            if tonumber(DRAIMS_entry) >= 1 then--full format entry
                if tonumber(DRAIMS_entry) >= 108.1 and tonumber(DRAIMS_entry) <= 111.95 then--if the frequency you enterd is in the correct range
                    if (string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "1" or
                        string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "3" or
                        string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "5" or
                        string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "7" or
                        string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "9") and
                        (Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 10 == 0 or
                        Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 5 == 0) then
                        return true--the entry is the correct ILS format
                    else
                        set(DRAIMS_format_error, 4)
                        return false--the xxx.>x<x position is not a odd number
                    end
                else
                    set(DRAIMS_format_error, 3)
                    return false--the freq is not in the ils range
                end
            elseif tonumber(DRAIMS_entry) < 1 then--only decimal entry
                if (string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "1" or
                    string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "3" or
                    string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "5" or
                    string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "7" or
                    string.sub(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), 1, 1) == "9") and
                    (Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 10 == 0 or
                    Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 5 == 0) then
                    return true--the entry is the correct ILS format
                else
                    set(DRAIMS_format_error, 4)
                    return false--the xxx.>x<x position is not a odd number
                end
            end
        else
            return false--decimal point fmt error
        end
    else
        return false--nothing in entry
    end
end

local function check_vor_fmt()--check VOR entry format
    if #DRAIMS_entry > 0 then
        if get(chk_dec_pt_fmt) == true then
            if tonumber(DRAIMS_entry) >= 1 then--full format entry
                if tonumber(DRAIMS_entry) >= 108 and tonumber(DRAIMS_entry) <= 117.95 then--if the frequency you enterd is in the correct range
                    if Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 10 == 0 or
                        Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 5 == 0 then
                        return true--the entry is the correct VOR format
                    else
                        set(DRAIMS_format_error, 6)
                        return false--the xxx.x>x< position is not 0 or 5
                    end
                else
                    set(DRAIMS_format_error, 5)
                    return false--the freq is not in the VOR range
                end
            elseif tonumber(DRAIMS_entry) < 1 then--only decimal entry
                if Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 10 == 0 or
                    Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 5 == 0 then
                    return true--the entry is the correct VOR format
                else
                    set(DRAIMS_format_error, 6)
                    return false--the xxx.x>x< position is not 0 or 5
                end
            end
        else
            return false--decimal point fmt error
        end
    else
        return false--nothing in entry
    end
end

local function chk_crs_fmt()
    if #DRAIMS_entry > 0 then
        if get(chk_dec_pt_fmt) == true then
            if tonumber(DRAIMS_entry) >= 0 and tonumber(DRAIMS_entry) <= 360 then
                if tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry)) == 0 then
                    return true--correct crs format
                else
                    set(DRAIMS_format_error, 15)--crs integer only
                    return false
                end
            else
                set(DRAIMS_format_error, 16)--crs out of range
                return false
            end
        end
    end
end

local function chk_adf_fmt()
    if #DRAIMS_entry > 0 then
        if get(chk_dec_pt_fmt) == true then
            if tonumber(DRAIMS_entry) >= 190 and tonumber(DRAIMS_entry) <= 535 then
                if tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry)) == 0 then
                    return true--correct crs format
                else
                    set(DRAIMS_format_error, 17)--adf integer only
                    return false
                end
            else
                set(DRAIMS_format_error, 7)--adf out of range
                return false
            end
        end
    end
end

local function chk_cursor_vhf_same()--check for if the cusor's frequency is the same as the VHF frequency at the same position (TRUE means the same, FALSE means no duplication)
    if get(DRAIMS_VHF_cursor_pos) == 1 then
        if (get(VHF_1_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_1_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then
            set(DRAIMS_format_error, 13)--the vhf frequency is identical to the VHF frequency
            return true
        else
            return false
        end
    elseif get(DRAIMS_VHF_cursor_pos) == 2 then
        if (get(VHF_2_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_2_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then
            set(DRAIMS_format_error, 13)--the vhf frequency is identical to the VHF frequency
            return true
        else
            return false
        end

    end
end

--register commands--
--top buttons
sasl.registerCommandHandler ( Draims_VHF_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_current_page, 1)
    end
end)

sasl.registerCommandHandler ( Draims_HF_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_current_page, 2)
    end
end)

sasl.registerCommandHandler ( Draims_NAV_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_current_page, 6)
        DRAIMS_entry = string.sub(DRAIMS_entry, 1, 6)--cut the length to rescale for NAV freqs
    end
end)

--left side buttons
sasl.registerCommandHandler ( Draims_l_1_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            set(VHF_1_freq_swapped, 1 - get(VHF_1_freq_swapped))
        elseif get(DRAIMS_current_page) == 2 then--hf page
        
        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 7)
            DRAIMS_entry = string.sub(DRAIMS_entry, 1, 6)--cut the length to rescale for NAV freqs
        elseif get(DRAIMS_current_page) == 7 then-- on ils page
            if check_if_entry_is_ils() == true then
                if tonumber(DRAIMS_entry) >= 1 then--full format entry
                    set(NAV_1_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_2_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) < 1 then--decimal entry
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                end
            end
        elseif get(DRAIMS_current_page) == 8 then-- on vor page
            if check_vor_fmt() == true then
                if tonumber(DRAIMS_entry) >= 1 then--full format entry
                    set(NAV_1_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) < 1 then--decimal entry
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                end
            end
        elseif get(DRAIMS_current_page) == 9 then-- on adf page
            if chk_adf_fmt() == true then
                set(ADF_1_freq_hz, tonumber(DRAIMS_entry))
                DRAIMS_entry = ""
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_l_2_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            set(VHF_2_freq_swapped, 1 - get(VHF_2_freq_swapped))
        elseif get(DRAIMS_current_page) == 2 then--hf page

        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 8)
            DRAIMS_entry = string.sub(DRAIMS_entry, 1, 6)--cut the length to rescale for NAV freqs
        elseif get(DRAIMS_current_page) == 8 then-- on vor page
            if check_vor_fmt() == true then
                if tonumber(DRAIMS_entry) >= 1 then--full format entry
                    set(NAV_2_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) < 1 then--decimal entry
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                end
            end
        elseif get(DRAIMS_current_page) == 9 then-- on adf page
            if chk_adf_fmt() == true then
                set(ADF_2_freq_hz, tonumber(DRAIMS_entry))
                DRAIMS_entry = ""
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_l_3_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_current_page) == 1 then--vhf page
        
        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 9)
            DRAIMS_entry = string.sub(DRAIMS_entry, 1, 6)--cut the length to rescale for NAV freqs
        end
    end
end)
sasl.registerCommandHandler ( Draims_l_4_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry > 0 then
            if check_sqwk_fmt() == true then
                set(Sqwk_code, DRAIMS_entry)
                DRAIMS_entry = ""
            end
        else
            if get(Sqwk_mode) == 2 then
                sasl.commandOnce(Sqwk_ident)
            end
        end
    end
end)

--right side buttons
sasl.registerCommandHandler ( Draims_r_1_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            if get(DRAIMS_VHF_cursor_pos) == 1 then
                if #DRAIMS_entry == 0 then
                    if chk_cursor_vhf_same() == false then
                        --swap cursor freq
                        cursor_Mhz_swap_buffer = get(VHF_1_stby_freq_Mhz)
                        cursor_khz_swap_buffer = get(VHF_1_stby_freq_khz)
                        set(VHF_1_stby_freq_Mhz, get(DRAIMS_cursor_freq_Mhz))
                        set(VHF_1_stby_freq_khz, get(DRAIMS_cursor_freq_khz))
                        set(DRAIMS_cursor_freq_Mhz, cursor_Mhz_swap_buffer)
                        set(DRAIMS_cursor_freq_khz, cursor_khz_swap_buffer)
                        set(DRAIMS_VHF_cursor_pos, 3)
                    end
                else
                    set(DRAIMS_format_error, 10)
                end
            else
                if #DRAIMS_entry > 0 then
                    if check_vhf_fmt() == true then
                        if tonumber(DRAIMS_entry) >= 1 then
                            set(VHF_1_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                            set(VHF_1_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        else--only decimal(edit decimal only)
                            set(VHF_1_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        end
                    end
                end
            end
        elseif get(DRAIMS_current_page) == 2 then--hf page
        
        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            if get(DRAIMS_NAV_cursor_pos) == 1 then
                if #DRAIMS_entry == 0 then
                    if get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 2 or get(Audio_nav_selection) == 3 then--swap audio nav sources cycle from off to nav 2
                        set(Audio_nav_selection, 0)
                    elseif get(Audio_nav_selection) == 0 then
                        set(Audio_nav_selection, 1)
                    elseif get(Audio_nav_selection) == 1 then
                        set(Audio_nav_selection, 9)
                    end
                else
                    set(DRAIMS_format_error, 14)
                end
            else--if cursor not on the current position the button can be used like the left buttons to enter the page
                set(DRAIMS_current_page, 7)
                DRAIMS_entry = string.sub(DRAIMS_entry, 1, 6)--cut the length to rescale for NAV freqs
            end
        elseif get(DRAIMS_current_page) == 7 then-- on ils page
            if chk_crs_fmt() == true then
                set(NAV_1_capt_obs, tonumber(DRAIMS_entry))
                set(NAV_1_fo_obs, tonumber(DRAIMS_entry))
                set(NAV_2_capt_obs, tonumber(DRAIMS_entry))
                set(NAV_2_fo_obs, tonumber(DRAIMS_entry))
                DRAIMS_entry = ""
            end
        elseif get(DRAIMS_current_page) == 8 then-- on vor page
            if chk_crs_fmt() == true then
                set(NAV_1_capt_obs, tonumber(DRAIMS_entry))
                set(NAV_1_fo_obs, tonumber(DRAIMS_entry))
                DRAIMS_entry = ""
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_2_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            if get(DRAIMS_VHF_cursor_pos) == 2 then
                if #DRAIMS_entry == 0 then
                    if chk_cursor_vhf_same() == false then
                        --swap cursor freq
                        cursor_Mhz_swap_buffer = get(VHF_2_stby_freq_Mhz)
                        cursor_khz_swap_buffer = get(VHF_2_stby_freq_khz)
                        set(VHF_2_stby_freq_Mhz, get(DRAIMS_cursor_freq_Mhz))
                        set(VHF_2_stby_freq_khz, get(DRAIMS_cursor_freq_khz))
                        set(DRAIMS_cursor_freq_Mhz, cursor_Mhz_swap_buffer)
                        set(DRAIMS_cursor_freq_khz, cursor_khz_swap_buffer)
                        set(DRAIMS_VHF_cursor_pos, 3)
                    end
                else
                    set(DRAIMS_format_error, 10)
                end
            else
                if #DRAIMS_entry > 0 then
                    if check_vhf_fmt() == true then
                        if tonumber(DRAIMS_entry) >= 1 then
                            set(VHF_2_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                            set(VHF_2_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        else--only decimal(edit decimal only)
                            set(VHF_2_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        end
                    end
                end
            end
        elseif get(DRAIMS_current_page) == 2 then--hf page
        
        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            if get(DRAIMS_NAV_cursor_pos) == 2 then
                if #DRAIMS_entry == 0 then
                    if get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 2 or get(Audio_nav_selection) == 3 then--swap audio nav sources cycle from off to nav 2
                        set(Audio_nav_selection, 0)
                    elseif get(Audio_nav_selection) == 0 then
                        set(Audio_nav_selection, 1)
                    elseif get(Audio_nav_selection) == 1 then
                        set(Audio_nav_selection, 9)
                    end
                else
                    set(DRAIMS_format_error, 14)
                end
            else--if cursor not on the current position the button can be used like the left buttons to enter the page
                set(DRAIMS_current_page, 8)
                DRAIMS_entry = string.sub(DRAIMS_entry, 1, 6)--cut the length to rescale for NAV freqs
            end
        elseif get(DRAIMS_current_page) == 8 then-- on vor page
            if chk_crs_fmt() == true then
                set(NAV_2_capt_obs, tonumber(DRAIMS_entry))
                set(NAV_2_fo_obs, tonumber(DRAIMS_entry))
                DRAIMS_entry = ""
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_3_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            if get(DRAIMS_VHF_cursor_pos) == 3 then
                if #DRAIMS_entry > 0 then
                    if check_vhf_fmt() == true then
                        if tonumber(DRAIMS_entry) >= 1 then
                            set(DRAIMS_cursor_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                            set(DRAIMS_cursor_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        else--only decimal(edit decimal only)
                            set(DRAIMS_cursor_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        end
                    end
                end
            else
                if #DRAIMS_entry > 0 then
                    set(DRAIMS_format_error, 10)
                end
            end
        elseif get(DRAIMS_current_page) == 2 then--hf page
        
        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            if get(DRAIMS_NAV_cursor_pos) == 3 then
                if #DRAIMS_entry == 0 then
                    if get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 0 or get(Audio_nav_selection) == 1 then--swap audio nav sources cycle from off to adf 2
                        set(Audio_nav_selection, 2)
                    elseif get(Audio_nav_selection) == 2 then
                        set(Audio_nav_selection, 3)
                    elseif get(Audio_nav_selection) == 3 then
                        set(Audio_nav_selection, 9)
                    end
                else
                    set(DRAIMS_format_error, 14)
                end
            else--if cursor not on the current position the button can be used like the left buttons to enter the page
                set(DRAIMS_current_page, 9)
                DRAIMS_entry = string.sub(DRAIMS_entry, 1, 6)--cut the length to rescale for NAV freqs
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_4_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if DRAIMS_entry == "" then
            set(DRAIMS_easter_egg, Math_cycle(get(DRAIMS_easter_egg) + 1, 0, 11))--cycle throught easter eggs if scratchpad is empty
        end
    end
end)

--numberpad
sasl.registerCommandHandler ( Draims_1_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "1"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "1"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_2_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "2"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "2"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_3_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "3"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "3"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_4_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "4"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "4"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_5_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "5"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "5"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_6_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "6"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "6"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_7_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "7"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "7"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_8_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "8"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "8"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_9_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "9"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "9"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_0_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "0"
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "0"
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_dot_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--scale the entry value for VHF and NAV
                if #DRAIMS_entry < 7 then
                    DRAIMS_entry = DRAIMS_entry .. "."
                end
            else
                if #DRAIMS_entry < 6 then
                    DRAIMS_entry = DRAIMS_entry .. "."
                end
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_clr_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0  then
            if get(DRAIMS_easter_egg) > 0 then
                set(DRAIMS_easter_egg, 0)
            else 
                if #DRAIMS_entry > 1 then
                    DRAIMS_entry = string.sub(DRAIMS_entry, 1, #DRAIMS_entry - 1)
                else
                    DRAIMS_entry = ""
                end
            end
        else
            set(DRAIMS_format_error, 0)
            if get(DRAIMS_easter_egg) > 0 then
                set(DRAIMS_easter_egg, 0)
            end
        end
    end
end)

--tcas buttons
sasl.registerCommandHandler ( Draims_l_tcas_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_Sqwk_mode, Math_cycle(get(DRAIMS_Sqwk_mode) + 1, 0, 3))
    end
end)
sasl.registerCommandHandler ( Draims_r_tcas_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
    end
end)

--draims cursor
sasl.registerCommandHandler ( Draims_cursor_up_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--vhf or hf page
            set(DRAIMS_VHF_cursor_pos, Math_clamp(get(DRAIMS_VHF_cursor_pos) - 1, 1, 3))
        elseif get(DRAIMS_current_page) == 6 then--nav page
            set(DRAIMS_NAV_cursor_pos, Math_clamp(get(DRAIMS_NAV_cursor_pos) - 1, 1, 3))
        end
    end
end)
sasl.registerCommandHandler ( Draims_cursor_dn_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_current_page) == 1 or get(DRAIMS_current_page) == 2 then--vhf or hf page
            set(DRAIMS_VHF_cursor_pos, Math_clamp(get(DRAIMS_VHF_cursor_pos) + 1, 1, 3))
        elseif get(DRAIMS_current_page) == 6 then--nav page
            set(DRAIMS_NAV_cursor_pos, Math_clamp(get(DRAIMS_NAV_cursor_pos) + 1, 1, 3))
        end
    end
end)

--vhf transmission button
sasl.registerCommandHandler ( Draims_transmit_VHF1_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(VHF_transmit_dest_manual, 6)
    end
end)
sasl.registerCommandHandler ( Draims_transmit_VHF2_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(VHF_transmit_dest_manual, 7)
    end
end)

--dynamic nav
sasl.registerCommandHandler ( Draims_dynamic_NAV_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_dynamic_NAV_audio_selected, 1 - get(DRAIMS_dynamic_NAV_audio_selected))
    end
end)
sasl.registerCommandHandler ( Draims_dynamic_NAV_volume_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_dynamic_NAV_volume, Math_clamp(get(DRAIMS_dynamic_NAV_volume) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_dynamic_NAV_volume, Math_clamp(get(DRAIMS_dynamic_NAV_volume) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Draims_dynamic_NAV_volume_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_dynamic_NAV_volume, Math_clamp(get(DRAIMS_dynamic_NAV_volume) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_dynamic_NAV_volume, Math_clamp(get(DRAIMS_dynamic_NAV_volume) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--vhf 1 volume
sasl.registerCommandHandler ( Draims_VHF1_volume_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(VHF_1_volume, Math_clamp(get(VHF_1_volume) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(VHF_1_volume, Math_clamp(get(VHF_1_volume) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Draims_VHF1_volume_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(VHF_1_volume, Math_clamp(get(VHF_1_volume) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(VHF_1_volume, Math_clamp(get(VHF_1_volume) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--vhf 2 volume
sasl.registerCommandHandler ( Draims_VHF2_volume_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(VHF_2_volume, Math_clamp(get(VHF_2_volume) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(VHF_2_volume, Math_clamp(get(VHF_2_volume) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Draims_VHF2_volume_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(VHF_2_volume, Math_clamp(get(VHF_2_volume) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(VHF_2_volume, Math_clamp(get(VHF_2_volume) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

function update()
    --deactivate easter eggs when there are entry in the scratchpad
    if #DRAIMS_entry > 0 then
        set(DRAIMS_easter_egg, 0)
    end
    
    --dynamic nav volume control
    if get(DRAIMS_dynamic_NAV_audio_selected) == 0 then--kill all volumes
        set(NAV_1_volume, 0)
        set(NAV_2_volume, 0)
        set(DME_volume, 0)
        set(DME_1_volume, 0)
        set(DME_2_volume, 0)
        set(ADF_1_volume, 0)
        set(ADF_2_volume, 0)
    elseif get(DRAIMS_dynamic_NAV_audio_selected) == 1 then
        if get(Audio_nav_selection) == 9 then--inactive
            set(NAV_1_volume, 0)
            set(NAV_2_volume, 0)
            set(DME_volume, 0)
            set(DME_1_volume, 0)
            set(DME_2_volume, 0)
            set(ADF_1_volume, 0)
            set(ADF_2_volume, 0)
        elseif get(Audio_nav_selection) == 0 then--nav 1
            set(NAV_1_volume, get(DRAIMS_dynamic_NAV_volume))
            set(NAV_2_volume, 0)
            set(DME_volume, 0)
            set(DME_1_volume, 0)
            set(DME_2_volume, 0)
            set(ADF_1_volume, 0)
            set(ADF_2_volume, 0)
        elseif get(Audio_nav_selection) == 1 then--nav 2
            set(NAV_1_volume, 0)
            set(NAV_2_volume, get(DRAIMS_dynamic_NAV_volume))
            set(DME_volume, 0)
            set(DME_1_volume, 0)
            set(DME_2_volume, 0)
            set(ADF_1_volume, 0)
            set(ADF_2_volume, 0)
        elseif get(Audio_nav_selection) == 2 then--adf 1
            set(NAV_1_volume, 0)
            set(NAV_2_volume, 0)
            set(DME_volume, 0)
            set(DME_1_volume, 0)
            set(DME_2_volume, 0)
            set(ADF_1_volume, get(DRAIMS_dynamic_NAV_volume))
            set(ADF_2_volume, 0)
        elseif get(Audio_nav_selection) == 3 then--adf 2
            set(NAV_1_volume, 0)
            set(NAV_2_volume, 0)
            set(DME_volume, 0)
            set(DME_1_volume, 0)
            set(DME_2_volume, 0)
            set(ADF_1_volume, 0)
            set(ADF_2_volume, get(DRAIMS_dynamic_NAV_volume))
        end
    end

    --tcas modes
    if get(DRAIMS_Sqwk_mode) == 0 then--off
        set(Sqwk_mode, 0)
    elseif get(DRAIMS_Sqwk_mode) == 1 then--stby
        set(Sqwk_mode, 1)
    elseif get(DRAIMS_Sqwk_mode) == 2 then--TA
        set(Sqwk_mode, 2)
    elseif get(DRAIMS_Sqwk_mode) == 3 then--TA/RA
        set(Sqwk_mode, 2)
    end

    --transmition target indication
    if get(VHF_transmit_dest) == 6 then--vhf 1
        set(VHF_1_transmit_selected, 1)
        set(VHF_2_transmit_selected, 0)
    elseif get(VHF_transmit_dest) == 7 then--vhf 2
        set(VHF_1_transmit_selected, 0)
        set(VHF_2_transmit_selected, 1)
    else-- not transmiting to anywhere
        set(VHF_1_transmit_selected, 0)
        set(VHF_2_transmit_selected, 0)
    end

    --show and hide the small speakers
    if get(DRAIMS_current_page) == 1 then--vhf page
        if get(VHF_1_audio_selected) == 1 then
            set(DRAIMS_line_1_speaker_shown, 1)
        else
            set(DRAIMS_line_1_speaker_shown, 0)
        end
        if get(VHF_2_audio_selected) == 1 then
            set(DRAIMS_line_2_speaker_shown, 1)
        else
            set(DRAIMS_line_2_speaker_shown, 0)
        end
    else
        set(DRAIMS_line_1_speaker_shown, 0)
        set(DRAIMS_line_2_speaker_shown, 0)
        set(DRAIMS_line_3_speaker_shown, 0)
    end

    --ident box fade in and out
    if get(Sqwk_identifying) == 1 then
        ident_box_timer = ident_box_timer + math.pi * get(DELTA_TIME)
        ident_box_cl[4] = (math.sin(ident_box_timer - math.pi / 2) - -1) / 2
    else
        ident_box_timer = 0
    end

    --blue cursors box fade in and out
    if get(DRAIMS_VHF_cursor_pos) ~= 3 then
        vhf_cursor_box_timer = vhf_cursor_box_timer + math.pi * get(DELTA_TIME)
        vhf_cursor_box_cl[4] = (math.sin(vhf_cursor_box_timer - math.pi / 2) - -1) / 2
    else
        vhf_cursor_box_timer = 0
        vhf_cursor_box_cl[4] = 1
    end

    --blue cursors box fade in and out
    if get(DRAIMS_current_page) == 6 then--nav page
        if get(Audio_nav_selection) == 9 then--if none of the NAV freqs are being listened to cursor goes to white
            nav_cursor_box_cl[1] = DRAIMS_WHITE[1]
            nav_cursor_box_cl[2] = DRAIMS_WHITE[2]
            nav_cursor_box_cl[3] = DRAIMS_WHITE[3]
        else--if any nav freq is beging listened to the cursor goes green
            nav_cursor_box_cl[1] = DRAIMS_GREEN[1]
            nav_cursor_box_cl[2] = DRAIMS_GREEN[2]
            nav_cursor_box_cl[3] = DRAIMS_GREEN[3]
        end

        if get(DRAIMS_NAV_cursor_pos) == 1 then
            if get(Audio_nav_selection) ~= 0 and get(Audio_nav_selection) ~= 1 then--not listening to ils
                nav_cursor_box_timer = nav_cursor_box_timer + math.pi * get(DELTA_TIME)
                nav_cursor_box_cl[4] = (math.sin(nav_cursor_box_timer - math.pi / 2) - -1) / 2
            else
                nav_cursor_box_timer = 0
                nav_cursor_box_cl[4] = 1
            end
        elseif get(DRAIMS_NAV_cursor_pos) == 2 then
            if get(Audio_nav_selection) ~= 0 and get(Audio_nav_selection) ~= 1 then--not listening to nav 1 nor nav 2 of vor
                nav_cursor_box_timer = nav_cursor_box_timer + math.pi * get(DELTA_TIME)
                nav_cursor_box_cl[4] = (math.sin(nav_cursor_box_timer - math.pi / 2) - -1) / 2
            else
                nav_cursor_box_timer = 0
                nav_cursor_box_cl[4] = 1
            end
        elseif get(DRAIMS_NAV_cursor_pos) == 3 then
            if get(Audio_nav_selection) ~= 2 and get(Audio_nav_selection) ~= 3 then--not listening to adf 1 nor adf 2
                nav_cursor_box_timer = nav_cursor_box_timer + math.pi * get(DELTA_TIME)
                nav_cursor_box_cl[4] = (math.sin(nav_cursor_box_timer - math.pi / 2) - -1) / 2
            else
                nav_cursor_box_timer = 0
                nav_cursor_box_cl[4] = 1
            end
        end
    end
end

function draw()
    --DRAIMS top section--
    --pages
    if get(DRAIMS_current_page) == 1 then--vhf page
        --vhf 1
        sasl.gl.drawText(A320_panel_font_MONO, 240, 332, Fwd_string_fill(tostring(get(VHF_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_1_freq_khz)), "0", 3), 68, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
        --indicate if the freqency is an emer frqency
        if get(VHF_1_freq_Mhz) == 121 and get(VHF_1_freq_khz) == 500 then
            sasl.gl.drawText(A320_panel_font, 125, 308, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        end
        if get(DRAIMS_VHF_cursor_pos) ~= 1 then
            sasl.gl.drawText(A320_panel_font_MONO, 380, 344, Fwd_string_fill(tostring(get(VHF_1_stby_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_1_stby_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
            --indicate if the freqency is an emer frqency
            if get(VHF_1_stby_freq_Mhz) == 121 and get(VHF_1_stby_freq_khz) == 500 then
                sasl.gl.drawText(A320_panel_font, 465, 315, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            end
        end

        --vhf 2
        sasl.gl.drawText(A320_panel_font_MONO, 240, 232, Fwd_string_fill(tostring(get(VHF_2_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_2_freq_khz)), "0", 3), 68, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
        --indicate if the freqency is an emer frqency
        if get(VHF_2_freq_Mhz) == 121 and get(VHF_2_freq_khz) == 500 then
            sasl.gl.drawText(A320_panel_font, 125, 208, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        end
        if get(DRAIMS_VHF_cursor_pos) ~= 2 then
            sasl.gl.drawText(A320_panel_font_MONO, 380, 244, Fwd_string_fill(tostring(get(VHF_2_stby_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_2_stby_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
            --indicate if the freqency is an emer frqency
            if get(VHF_2_stby_freq_Mhz) == 121 and get(VHF_2_stby_freq_khz) == 500 then
                sasl.gl.drawText(A320_panel_font, 465, 215, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            end
        end

        --vhf 3
        sasl.gl.drawText(A320_panel_font, 180, 132, "DATA", 68, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)

        --VHF cursor--
        if get(DRAIMS_VHF_cursor_pos) == 1 then--cursor on the first row of stby freq
            --cursor movement indicator
            --sasl.gl.drawTriangle(362, 370, 370, 388, 378, 370, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 330, 370, 360, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 330, 370, 312, 378, 330, DRAIMS_WHITE)

            --the cursor frequency
            if (get(VHF_1_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_1_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then--cusor and stby freq identical no swapping needed
                sasl.gl.drawText(A320_panel_font, 380, 344, "IDT FREQ", 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                sasl.gl.drawText(A320_panel_font, 575, 315, "NO SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            else--freq different prepare to swap
                sasl.gl.drawText(A320_panel_font_MONO, 380, 344, Fwd_string_fill(tostring(get(VHF_1_stby_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_1_stby_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font_MONO, 380, 315, Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_khz)), "0", 3), 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                sasl.gl.drawText(A320_panel_font, 550, 315, "SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            end

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 392, 575, 392, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 309, 354, 390, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 309, 577, 390, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 308, 575, 308, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 390, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 390, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 309, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 309, 0, 3, 270, 90, vhf_cursor_box_cl)
        elseif get(DRAIMS_VHF_cursor_pos) == 2 then--cursor on the second row of stby freq
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 270, 370, 288, 378, 270, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 230, 370, 270, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 230, 370, 212, 378, 230, DRAIMS_WHITE)

            --the cursor frequency
            if (get(VHF_2_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_2_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then--cusor and stby freq identical no swapping needed
                sasl.gl.drawText(A320_panel_font, 380, 244, "IDT FREQ", 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                sasl.gl.drawText(A320_panel_font, 575, 215, "NO SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            else--freq different prepare to swap
                sasl.gl.drawText(A320_panel_font_MONO, 380, 244, Fwd_string_fill(tostring(get(VHF_2_stby_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_2_stby_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font_MONO, 380, 215, Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_khz)), "0", 3), 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                sasl.gl.drawText(A320_panel_font, 550, 215, "SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            end

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 292, 575, 292, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 209, 354, 290, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 209, 577, 290, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 208, 575, 208, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 290, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 290, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 209, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 209, 0, 3, 270, 90, vhf_cursor_box_cl)
        elseif get(DRAIMS_VHF_cursor_pos) == 3 then--cursor on the thrid row of stby freq(default inactive)
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 170, 370, 188, 378, 170, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 140, 370, 170, 4, DRAIMS_WHITE)
            --sasl.gl.drawTriangle(362, 130, 370, 112, 378, 130, DRAIMS_WHITE)

            --the cursor frequency
            sasl.gl.drawText(A320_panel_font_MONO, 380, 144, Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
            --indicate if the freqency is an emer frqency
            if get(DRAIMS_cursor_freq_Mhz) == 121 and get(DRAIMS_cursor_freq_khz) == 500 then
                sasl.gl.drawText(A320_panel_font, 465, 115, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            end

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 192, 575, 192, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 109, 354, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 109, 577, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 108, 575, 108, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 190, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 190, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 109, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 109, 0, 3, 270, 90, vhf_cursor_box_cl)
        end

        --draw cursor in use indication
        if get(DRAIMS_VHF_cursor_pos) ~= 3 then
            sasl.gl.drawText(A320_panel_font, 465, 115, "IN USE", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 192, 575, 192, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 109, 354, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 109, 577, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 108, 575, 108, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 190, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 190, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 109, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 109, 0, 3, 270, 90, vhf_cursor_box_cl)
        end

    elseif get(DRAIMS_current_page) == 2 then--hf page
        --vhf 1
        sasl.gl.drawText(A320_panel_font, 125, 332, "INOP", 68, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        if get(DRAIMS_VHF_cursor_pos) ~= 1 then
            sasl.gl.drawText(A320_panel_font, 465, 344, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        end

        --vhf 2
        sasl.gl.drawText(A320_panel_font, 125, 232, "INOP", 68, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        if get(DRAIMS_VHF_cursor_pos) ~= 2 then
            sasl.gl.drawText(A320_panel_font, 465, 244, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        end

        --HF cursor--
        if get(DRAIMS_VHF_cursor_pos) == 1 then--cursor on the first row of stby freq
            --cursor movement indicator
            --sasl.gl.drawTriangle(362, 370, 370, 388, 378, 370, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 330, 370, 360, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 330, 370, 312, 378, 330, DRAIMS_WHITE)

            sasl.gl.drawText(A320_panel_font, 465, 344, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)
            sasl.gl.drawText(A320_panel_font, 550, 315, "NO SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 392, 575, 392, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 309, 354, 390, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 309, 577, 390, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 308, 575, 308, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 390, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 390, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 309, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 309, 0, 3, 270, 90, vhf_cursor_box_cl)
        elseif get(DRAIMS_VHF_cursor_pos) == 2 then--cursor on the second row of stby freq
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 270, 370, 288, 378, 270, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 230, 370, 270, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 230, 370, 212, 378, 230, DRAIMS_WHITE)

            sasl.gl.drawText(A320_panel_font, 465, 244, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)
            sasl.gl.drawText(A320_panel_font, 550, 215, "NO SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 292, 575, 292, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 209, 354, 290, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 209, 577, 290, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 208, 575, 208, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 290, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 290, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 209, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 209, 0, 3, 270, 90, vhf_cursor_box_cl)
        elseif get(DRAIMS_VHF_cursor_pos) == 3 then--cursor on the thrid row of stby freq(default inactive)
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 170, 370, 188, 378, 170, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 140, 370, 170, 4, DRAIMS_WHITE)
            --sasl.gl.drawTriangle(362, 130, 370, 112, 378, 130, DRAIMS_WHITE)

            --the cursor frequency
            sasl.gl.drawText(A320_panel_font, 465, 144, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 192, 575, 192, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 109, 354, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 109, 577, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 108, 575, 108, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 190, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 190, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 109, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 109, 0, 3, 270, 90, vhf_cursor_box_cl)
        end

        --draw cursor in use indication
        if get(DRAIMS_VHF_cursor_pos) ~= 3 then
            sasl.gl.drawText(A320_panel_font, 465, 115, "IN USE", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 192, 575, 192, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, 109, 354, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, 109, 577, 190, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, 108, 575, 108, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 190, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 190, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, 109, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, 109, 0, 3, 270, 90, vhf_cursor_box_cl)
        end
    elseif get(DRAIMS_current_page) == 6 then--nav page
        sasl.gl.drawText(A320_panel_font, 560, 344, "ILS", 50, false, false, TEXT_ALIGN_RIGHT, ils_menu_cl)
        sasl.gl.drawText(A320_panel_font, 560, 244, "VOR", 50, false, false, TEXT_ALIGN_RIGHT, vor_menu_cl)
        sasl.gl.drawText(A320_panel_font, 560, 144, "ADF", 50, false, false, TEXT_ALIGN_RIGHT, adf_menu_cl)

        if get(DRAIMS_NAV_cursor_pos) == 1 then--ils
            --cursor movement indicator
            --sasl.gl.drawTriangle(362, 370, 370, 388, 378, 370, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 330, 370, 360, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 330, 370, 312, 378, 330, DRAIMS_WHITE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 392, 575, 392, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(354, 309, 354, 390, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(577, 309, 577, 390, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(355, 308, 575, 308, 3, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, 390, 0, 3, 90, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, 390, 0, 3, 0, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, 309, 0, 3, 180, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, 309, 0, 3, 270, 90, nav_cursor_box_cl)

            --show what freqencies you are listening to if any
            if get(Audio_nav_selection) == 0 then
                sasl.gl.drawText(A320_panel_font, 380, 315, "NAV 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
                sasl.gl.drawText(A320_panel_font, 550, 315, "NAV 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            elseif get(Audio_nav_selection) == 1 then
                sasl.gl.drawText(A320_panel_font, 380, 315, "NAV 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font, 550, 315, "NAV 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_GREEN)
            elseif get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 2 or get(Audio_nav_selection) == 3 then
                sasl.gl.drawText(A320_panel_font, 380, 315, "NAV 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font, 550, 315, "NAV 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            end
        elseif get(DRAIMS_NAV_cursor_pos) == 2 then--vor
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 270, 370, 288, 378, 270, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 230, 370, 270, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 230, 370, 212, 378, 230, DRAIMS_WHITE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 292, 575, 292, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(354, 209, 354, 290, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(577, 209, 577, 290, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(355, 208, 575, 208, 3, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, 290, 0, 3, 90, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, 290, 0, 3, 0, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, 209, 0, 3, 180, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, 209, 0, 3, 270, 90, nav_cursor_box_cl)

            --show what freqencies you are listening to if any
            if get(Audio_nav_selection) == 0 then
                sasl.gl.drawText(A320_panel_font, 380, 215, "NAV 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
                sasl.gl.drawText(A320_panel_font, 550, 215, "NAV 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            elseif get(Audio_nav_selection) == 1 then
                sasl.gl.drawText(A320_panel_font, 380, 215, "NAV 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font, 550, 215, "NAV 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_GREEN)
            elseif get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 2 or get(Audio_nav_selection) == 3 then
                sasl.gl.drawText(A320_panel_font, 380, 215, "NAV 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font, 550, 215, "NAV 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            end
        elseif get(DRAIMS_NAV_cursor_pos) == 3 then--adf
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 170, 370, 188, 378, 170, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 140, 370, 170, 4, DRAIMS_WHITE)
            --sasl.gl.drawTriangle(362, 130, 370, 112, 378, 130, DRAIMS_WHITE)
            
            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 192, 575, 192, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(354, 109, 354, 190, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(577, 109, 577, 190, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(355, 108, 575, 108, 3, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, 190, 0, 3, 90, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, 190, 0, 3, 0, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, 109, 0, 3, 180, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, 109, 0, 3, 270, 90, nav_cursor_box_cl)

            --show what freqencies you are listening to if any
            if get(Audio_nav_selection) == 2 then
                sasl.gl.drawText(A320_panel_font, 380, 115, "ADF 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
                sasl.gl.drawText(A320_panel_font, 550, 115, "ADF 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            elseif get(Audio_nav_selection) == 3 then
                sasl.gl.drawText(A320_panel_font, 380, 115, "ADF 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font, 550, 115, "ADF 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_GREEN)
            elseif get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 0 or get(Audio_nav_selection) == 1 then
                sasl.gl.drawText(A320_panel_font, 380, 115, "ADF 1", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                sasl.gl.drawText(A320_panel_font, 550, 115, "ADF 2", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            end
        end
    elseif get(DRAIMS_current_page) == 7 then--ils page
        if (string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "1" and
           string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "3" and
           string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "5" and
           string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "7" and
           string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "9") or
           (tonumber(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2)) < 108.1 or
            tonumber(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2)) > 111.95) then --not a ILS frequency so must be using VOR
            sasl.gl.drawText(A320_panel_font, 125, 315, "VOR", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
            sasl.gl.drawText(A320_panel_font_MONO, 465, 315, Round(get(NAV_1_capt_obs)), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        else
            sasl.gl.drawText(A320_panel_font_MONO, 125, 315, Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            sasl.gl.drawText(A320_panel_font_MONO, 465, 315, Round(get(NAV_1_capt_obs)), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        end
    elseif get(DRAIMS_current_page) == 8 then--vor page
        --nav 1
        sasl.gl.drawText(A320_panel_font_MONO, 125, 315, Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        sasl.gl.drawText(A320_panel_font_MONO, 465, 315, Round(get(NAV_1_capt_obs)), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        --nav 2
        sasl.gl.drawText(A320_panel_font_MONO, 125, 215, Fwd_string_fill(tostring(get(NAV_2_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_2_freq_10khz)), "0", 2), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        sasl.gl.drawText(A320_panel_font_MONO, 465, 215, Round(get(NAV_2_capt_obs)), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
    elseif get(DRAIMS_current_page) == 9 then--adf page
        --adf 1
        sasl.gl.drawText(A320_panel_font_MONO, 125, 315, Fwd_string_fill(tostring(get(ADF_1_freq_hz)), "0", 3), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        --adf 2
        sasl.gl.drawText(A320_panel_font_MONO, 125, 215, Fwd_string_fill(tostring(get(ADF_2_freq_hz)), "0", 3), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
    end


    --DRAIMS bottom section--
    -----------------------------------------------------------------------------------------------------------------------
    --DRAIMS scratchpad
    if get(DRAIMS_format_error) == 0 then
        if get(DRAIMS_easter_egg) == 0 then
            sasl.gl.drawText(A320_panel_font_MONO, 509, 30, DRAIMS_entry, 45, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        elseif get(DRAIMS_easter_egg) == 1 then--easter egg 1
            sasl.gl.drawText(A320_panel_font, 509, 30, "HUH?", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 2 then--easter egg 2
            sasl.gl.drawText(A320_panel_font, 509, 30, "IT'S EMPTY!", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 3 then--easter egg 3
            sasl.gl.drawText(A320_panel_font, 509, 30, "AGAIN?", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 4 then--easter egg 4
            sasl.gl.drawText(A320_panel_font, 509, 30, "NOTHING HERE!", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 5 then--easter egg 5
            sasl.gl.drawText(A320_panel_font, 509, 30, "SERIOUSLY!", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 6 then--easter egg 6
            sasl.gl.drawText(A320_panel_font, 509, 30, "C'MOM!", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 7 then--easter egg 7
            sasl.gl.drawText(A320_panel_font, 509, 30, "STOP IT!", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 8 then--easter egg 8
            sasl.gl.drawText(A320_panel_font, 509, 30, "GET SOME HELP!", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 9 then--easter egg 9
            sasl.gl.drawText(A320_panel_font, 509, 30, "WHAT NOW?", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 10 then--easter egg 10
            sasl.gl.drawText(A320_panel_font, 509, 30, "I'VE HAD IT!", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        elseif get(DRAIMS_easter_egg) == 11 then--easter egg 11
            sasl.gl.drawText(A320_panel_font, 509, 30, "BYE......", 26, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
        end
    elseif get(DRAIMS_format_error) == 1 then--invalid freqency format
        sasl.gl.drawText(A320_panel_font, 425, 70, "FMT ERR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "xxx.xxx/xx/x", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "OR xxx.", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "OR .xxx/xx/x", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 2 then--VHF out of range
        sasl.gl.drawText(A320_panel_font, 425, 70, "VHF RANGE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "118.000 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "TO", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "137.000 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 3 then--ILS out of range
        sasl.gl.drawText(A320_panel_font, 425, 70, "ILS RANGE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "108.110 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "TO", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "111.950 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 4 then--ILS freq spacing error(not odd)
        sasl.gl.drawText(A320_panel_font, 425, 70, "ILS FREQ SP", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "xxx.>x<x MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 484, 26, "^", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "MUST BE ODD", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 5 then--VOR out of range
        sasl.gl.drawText(A320_panel_font, 425, 70, "VOR RANGE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "108.000 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "TO", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "117.950 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 6 then--VOR freq spacing error
        sasl.gl.drawText(A320_panel_font, 425, 70, "VOR FREQ SP", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "xxx.x>x< MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 498, 26, "^", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "0 OR 5", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 7 then--ADF out of range
        sasl.gl.drawText(A320_panel_font, 425, 70, "ADF RANGE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "190 HZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "TO", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "535 HZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 8 then--sqwk out of range
        sasl.gl.drawText(A320_panel_font, 425, 70, "SQWK RANGE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "0000", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "TO", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "7777", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 9 then--sqwk integer only
        sasl.gl.drawText(A320_panel_font, 425, 70, "SQWK FMT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "NO DEC", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "INT ONLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "xxxx", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 10 then--cursor in use
        sasl.gl.drawText(A320_panel_font, 425, 70, "CURSOR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "CURRENTLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "IN", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "USE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
    elseif get(DRAIMS_format_error) == 11 then--more than one decimal point
        sasl.gl.drawText(A320_panel_font, 425, 70, "FMT ERR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "ONLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "ONE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "DECIMAL DOT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 12 then--only decimal points but no numbers
        sasl.gl.drawText(A320_panel_font, 425, 70, "FMT ERR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "ENTER NUMS", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "THEN", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "DECIMAL DOT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 13 then--cursor and VHF is identical
        sasl.gl.drawText(A320_panel_font, 425, 70, "CURSOR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "AND", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "VHF FREQ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "IDENTICAL", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
    elseif get(DRAIMS_format_error) == 14 then--green cursor use only
        sasl.gl.drawText(A320_panel_font, 425, 70, "CURSOR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
        sasl.gl.drawText(A320_panel_font, 425, 48, "USE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
        sasl.gl.drawText(A320_panel_font, 425, 26, "ONLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
        sasl.gl.drawText(A320_panel_font, 425, 4, "NO ENTRY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
    elseif get(DRAIMS_format_error) == 15 then--crs integer only
        sasl.gl.drawText(A320_panel_font, 425, 70, "CRS FMT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "NO DEC", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "INT ONLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "xxx", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 16 then--crs out of range
        sasl.gl.drawText(A320_panel_font, 425, 70, "CRS RNG", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "0", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "TO", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "360 INCL.", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 17 then--adf integer only
        sasl.gl.drawText(A320_panel_font, 425, 70, "ADF FMT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "NO DEC", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "INT ONLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "xxx", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    end

    --DRAIMS SQWK
    if get(DRAIMS_Sqwk_mode) >= 2 then--TA or TA/RA
        sasl.gl.drawText(A320_panel_font_MONO, 68, 25, Fwd_string_fill(tostring(get(Sqwk_code)), "0", 4), 45, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
    else
        sasl.gl.drawText(A320_panel_font_MONO, 68, 25, Fwd_string_fill(tostring(get(Sqwk_code)), "0", 4), 45, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
    end

    --draw ident alert box
    if get(Sqwk_identifying) == 1 then
        sasl.gl.drawWideLine(15, 66, 119, 66, 3, ident_box_cl)
        sasl.gl.drawWideLine(14, 20, 14, 64, 3, ident_box_cl)
        sasl.gl.drawWideLine(121, 20, 121, 64, 3, ident_box_cl)
        sasl.gl.drawWideLine(15, 19, 119, 19, 3, ident_box_cl)
        sasl.gl.drawArc ( 15, 64, 0, 3, 90, 90, ident_box_cl)
        sasl.gl.drawArc ( 119, 64, 0, 3, 0, 90, ident_box_cl)
        sasl.gl.drawArc ( 15, 20, 0, 3, 180, 90, ident_box_cl)
        sasl.gl.drawArc ( 119, 20, 0, 3, 270, 90, ident_box_cl)
    end
end