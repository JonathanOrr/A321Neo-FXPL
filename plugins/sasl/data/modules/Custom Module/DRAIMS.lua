position = {1852, 1449, 600, 400}
size = {600, 400}

--variables
local DRAIMS_entry = ""
local ident_box_timer = 0--used to fade alpha
local vhf_cursor_box_timer = 0--used to fade alpha
local nav_cursor_box_timer = 0--used to fade alpha
local crs_suggest_box_timer = 0--used to fade alpha

local cursor_Mhz_swap_buffer = 0
local cursor_khz_swap_buffer = 0

--navaid infos
local finding_navaid_id = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_type = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_latitude = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_longitude = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_height = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_frequency = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_heading = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_id = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_name = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2
local NAVs_isInsideLoadedDSFs = {} --1 ils, 2 nav1, 3 nav2, 4 adf1, 5 adf2

--navaid name scrolling timer and position
local vor1_scrolling_x_pos = 1
local vor1_scrolling_alignment = TEXT_ALIGN_CENTER
local vor2_scrolling_x_pos = 1
local vor2_scrolling_alignment = TEXT_ALIGN_CENTER
local adf1_scrolling_x_pos = 1
local adf1_scrolling_alignment = TEXT_ALIGN_CENTER
local adf2_scrolling_x_pos = 1
local adf2_scrolling_alignment = TEXT_ALIGN_CENTER

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
local nav_cursor_l_b_text_cl = {0.184, 0.733, 0.219}
local nav_cursor_r_b_text_cl = {0.184, 0.733, 0.219}
local crs_suggest_box_cl = {0.184, 0.733, 0.219, 1}
local ils_menu_cl = {0.184, 0.733, 0.219, 1}
local vor_menu_cl = {0.184, 0.733, 0.219, 1}
local adf_menu_cl = {0.184, 0.733, 0.219, 1}

--speakers alphas
local DRAIMS_line_1_speaker_alpha = 0
local DRAIMS_line_2_speaker_alpha = 0
local DRAIMS_line_3_speaker_alpha = 0

--cursors variables
---vhf/hf cursor
local vhf_cursor_up_arrow_y1_pos = 170
local vhf_cursor_up_arrow_y2_pos = 188
local vhf_cusor_arrow_stick_y1_pos = 170
local vhf_cusor_arrow_stick_y2_pos = 140
local vhf_cursor_down_arrow_y1_pos = 130
local vhf_cursor_down_arrow_y2_pos = 112
local vhf_cursor_l_b_text = ""
local vhf_cursor_r_b_text = ""
local vhf_cusor_text_y_pos = 115
local vhf_cusor_y1_pos = 192
local vhf_cusor_y2_pos = 190
local vhf_cusor_y3_pos = 109
local vhf_cusor_y4_pos = 108
--nav cursor
local nav_cursor_up_arrow_y1_pos = 170
local nav_cursor_up_arrow_y2_pos = 188
local nav_cusor_arrow_stick_y1_pos = 170
local nav_cusor_arrow_stick_y2_pos = 140
local nav_cursor_down_arrow_y1_pos = 130
local nav_cursor_down_arrow_y2_pos = 112
local nav_cursor_l_b_text = ""
local nav_cursor_r_b_text = ""
local nav_cusor_text_y_pos = 115
local nav_cusor_y1_pos = 192
local nav_cusor_y2_pos = 190
local nav_cusor_y3_pos = 109
local nav_cusor_y4_pos = 108
local nav_cusor_speaker_alpha = 0
local nav_cusor_speaker_y_pos = 145
local nav_cusor_speaker_y_array = {345,245,145}

local DRAIMS_cusor_up_arrow_y1_array = {370,270,170}
local DRAIMS_cusor_up_arrow_y2_array = {388,288,188}
local DRAIMS_cusor_arrow_stick_y1_array = {360,270,170}
local DRAIMS_cusor_arrow_stick_y2_array = {330,230,140}
local DRAIMS_cusor_down_arrow_y1_array = {330,230,130}
local DRAIMS_cusor_down_arrow_y2_array = {312,212,112}
local DRAIMS_cusor_text_y_array = {315,215,115}
local DRAIMS_cusor_y1_array = {392,292,192}
local DRAIMS_cusor_y2_array = {390,290,190}
local DRAIMS_cusor_y3_array = {309,209,109}
local DRAIMS_cusor_y4_array = {308,208,108}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")
local A320_panel_font = sasl.gl.loadFont("fonts/A320PanelFont_V0.2b.ttf")
local A320_panel_font_MONO = sasl.gl.loadFont("fonts/A320PanelFont_V0.2b.ttf")
sasl.gl.setFontRenderMode (A320_panel_font_MONO, TEXT_RENDER_FORCED_MONO, 0.48)--force mono space

--image textures
local draims_speaker_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/speaker.png")

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
    local digit_exceeded_7 = 0

    if chk_dec_pt_fmt() == true then
        if tonumber(DRAIMS_entry) >= 0 and tonumber(DRAIMS_entry) <= 7777 then--check for max range
            if tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry)) == 0 then--check for no dp
                for i = 1, #DRAIMS_entry do--cycle through every digit
                    if string.sub(DRAIMS_entry, i, i) ~= "." then--if the character is not a dp then
                        --if the number is within 0 to 7 incl. then correct, if not then add it to the counter
                        if tonumber(string.sub(DRAIMS_entry, i, i)) < 0 or tonumber(string.sub(DRAIMS_entry, i, i)) > 7 then
                            digit_exceeded_7 = digit_exceeded_7 + 1
                        end
                    end
                end
                --check all digits
                if digit_exceeded_7 == 0 then
                    return true--no digits exceeded 7 fmt correct
                else
                    set(DRAIMS_format_error, 19)
                    return false--1 or more digits exceeded 7 fmt error
                end
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
        if (tonumber(DRAIMS_entry) >= 118000 and tonumber(DRAIMS_entry) <= 137000) or--no dp format
            (tonumber(DRAIMS_entry) >= 118 and tonumber(DRAIMS_entry) <= 137) or--full format
            (tonumber(DRAIMS_entry) > 0 and tonumber(DRAIMS_entry) < 1) then--only dp format
            return true
        else
            set(DRAIMS_format_error, 2)--vhf out of range
            return false
        end
    else
        return false
    end
end

local function check_if_entry_is_ils()--check if the nav1 frequency is a ils freq
    if #DRAIMS_entry > 0 then
        if get(chk_dec_pt_fmt) == true then
            if tonumber(DRAIMS_entry) >= 108.1 and tonumber(DRAIMS_entry) <= 111.95 then--full format entry with dp
                if (string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 1, 1) == "1" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 1, 1) == "3" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 1, 1) == "5" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 1, 1) == "7" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 1, 1) == "9") then
                    if(string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 2, 2) == "0" or
                        string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 2, 2) == "5") then
                        print(string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)), "0", 2), 1, 10))
                        return true--the entry is the correct ILS format
                    else
                        set(DRAIMS_format_error, 18)
                        return false--the xxx.x>x< position is not 0 or 5
                    end
                else
                    set(DRAIMS_format_error, 4)
                    return false--the xxx.>x<x position is not a odd number
                end
            elseif tonumber(DRAIMS_entry) >= 10810 and tonumber(DRAIMS_entry) <= 11195 then--full format entry without dp
                if (string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 1, 1) == "1" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 1, 1) == "3" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 1, 1) == "5" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 1, 1) == "7" or
                    string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 1, 1) == "9") then
                    if(string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 2, 2) == "0" or
                        string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 2, 2) == "5") then
                        print(string.sub(Fwd_string_fill(tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)), "0", 2), 1, 10))
                        return true--the entry is the correct ILS format
                    else
                        set(DRAIMS_format_error, 18)
                        return false--the xxx.x>x< position is not 0 or 5
                    end
                else
                    set(DRAIMS_format_error, 4)
                    return false--the xxx.>x<x position is not a odd number
                end
            elseif tonumber(DRAIMS_entry) > 0 and tonumber(DRAIMS_entry) < 1 then--only decimal entry
                if (string.sub(Fwd_string_fill(tostring(Round(tonumber(DRAIMS_entry) * 100)), "0", 2), 1, 1) == "1" or
                    string.sub(Fwd_string_fill(tostring(Round(tonumber(DRAIMS_entry) * 100)), "0", 2), 1, 1) == "3" or
                    string.sub(Fwd_string_fill(tostring(Round(tonumber(DRAIMS_entry) * 100)), "0", 2), 1, 1) == "5" or
                    string.sub(Fwd_string_fill(tostring(Round(tonumber(DRAIMS_entry) * 100)), "0", 2), 1, 1) == "7" or
                    string.sub(Fwd_string_fill(tostring(Round(tonumber(DRAIMS_entry) * 100)), "0", 2), 1, 1) == "9") then
                    if(string.sub(Fwd_string_fill(tostring(Round(tonumber(DRAIMS_entry) * 100)), "0", 2), 2, 2) == "0" or
                        string.sub(Fwd_string_fill(tostring(Round(tonumber(DRAIMS_entry) * 100)), "0", 2), 2, 2) == "5") then
                        return true--the entry is the correct ILS format
                    else
                        set(DRAIMS_format_error, 18)
                        return false--the xxx.x>x< position is not 0 or 5
                    end
                else
                    set(DRAIMS_format_error, 4)
                    return false--the xxx.>x<x position is not a odd number
                end
            else
                set(DRAIMS_format_error, 3)
                return false--the freq is not in the ils range
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
            if tonumber(DRAIMS_entry) >= 108 and tonumber(DRAIMS_entry) <= 117.95 then--full format entry with dp
                if Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 10 == 0 or
                    Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100) % 5 == 0 then
                    return true--the entry is the correct VOR format
                else
                    set(DRAIMS_format_error, 6)
                    return false--the xxx.x>x< position is not 0 or 5
                end
            elseif tonumber(DRAIMS_entry) >= 10800 and tonumber(DRAIMS_entry) <= 11795 then--full format entry without dp
                if Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100) % 10 == 0 or
                    Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100) % 5 == 0 then
                    return true--the entry is the correct VOR format
                else
                    set(DRAIMS_format_error, 6)
                    return false--the xxx.x>x< position is not 0 or 5
                end
            elseif tonumber(DRAIMS_entry) > 0 and tonumber(DRAIMS_entry) < 1 then--only decimal entry
                if Round(tonumber(DRAIMS_entry) * 100) % 10 == 0 or
                    Round(tonumber(DRAIMS_entry) * 100) % 5 == 0 then
                    return true--the entry is the correct VOR format
                else
                    set(DRAIMS_format_error, 6)
                    return false--the xxx.x>x< position is not 0 or 5
                end
            else
                set(DRAIMS_format_error, 5)
                return false--the freq is not in the VOR range
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
        else
            return false
        end
    else
        return false
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

--VHF/HF CURSOR--------------------------------------------------------------------------------------------------------
local function animate_vhf_cursor()
    --blue cursors box fade in and out
    if get(DRAIMS_VHF_cursor_pos) ~= 3 then
        vhf_cursor_box_timer = vhf_cursor_box_timer + math.pi * get(DELTA_TIME)
        vhf_cursor_box_cl[4] = (math.sin(vhf_cursor_box_timer) - -1) / 2
    else
        vhf_cursor_box_timer = math.pi / 2
        vhf_cursor_box_cl[4] = 1
    end

    --change cursor text indications
    if get(DRAIMS_VHF_cursor_pos) == 1 then--cursor on the first row of stby freq
        --the cursor frequency
        if (get(VHF_1_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_1_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then--cusor and stby freq identical no swapping needed
            vhf_cursor_l_b_text = ""
            vhf_cursor_r_b_text = "NO SWAP"
        else--freq different prepare to swap
            vhf_cursor_l_b_text = Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_khz)), "0", 3)
            vhf_cursor_r_b_text = "SWAP"
        end
    elseif get(DRAIMS_VHF_cursor_pos) == 2 then--cursor on the second row of stby freq
        --the cursor frequency
        if (get(VHF_2_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_2_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then--cusor and stby freq identical no swapping needed
            vhf_cursor_l_b_text = ""
            vhf_cursor_r_b_text = "NO SWAP"
        else--freq different prepare to swap
            vhf_cursor_l_b_text = Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_khz)), "0", 3)
            vhf_cursor_r_b_text = "SWAP"
        end
    end

    --animate nav cursor position and arrow indications
    vhf_cursor_up_arrow_y1_pos = Set_anim_value(vhf_cursor_up_arrow_y1_pos, DRAIMS_cusor_up_arrow_y1_array[get(DRAIMS_VHF_cursor_pos)], 170, 370, 25)--animate upper arrow triangle position
    vhf_cursor_up_arrow_y2_pos = Set_anim_value(vhf_cursor_up_arrow_y2_pos, DRAIMS_cusor_up_arrow_y2_array[get(DRAIMS_VHF_cursor_pos)], 188, 388, 25)--animate upper arrow triangle position
    vhf_cusor_arrow_stick_y1_pos = Set_anim_value(vhf_cusor_arrow_stick_y1_pos, DRAIMS_cusor_arrow_stick_y1_array[get(DRAIMS_VHF_cursor_pos)], 170, 360, 25)--animate arrow stick position
    vhf_cusor_arrow_stick_y2_pos = Set_anim_value(vhf_cusor_arrow_stick_y2_pos, DRAIMS_cusor_arrow_stick_y2_array[get(DRAIMS_VHF_cursor_pos)], 140, 330, 25)--animate arrow stick position
    vhf_cursor_down_arrow_y1_pos = Set_anim_value(vhf_cursor_down_arrow_y1_pos, DRAIMS_cusor_down_arrow_y1_array[get(DRAIMS_VHF_cursor_pos)], 130, 330, 25)--animate lower arrow triangle position
    vhf_cursor_down_arrow_y2_pos = Set_anim_value(vhf_cursor_down_arrow_y2_pos, DRAIMS_cusor_down_arrow_y2_array[get(DRAIMS_VHF_cursor_pos)], 112, 312, 25)--animate lower arrow triangle position
    vhf_cusor_text_y_pos = Set_anim_value(vhf_cusor_text_y_pos, DRAIMS_cusor_text_y_array[get(DRAIMS_VHF_cursor_pos)], 115, 315, 25)--animate cursor buttom text position
    vhf_cusor_y1_pos = Set_anim_value(vhf_cusor_y1_pos, DRAIMS_cusor_y1_array[get(DRAIMS_VHF_cursor_pos)], 192, 392, 25)--animate cursor box position
    vhf_cusor_y2_pos = Set_anim_value(vhf_cusor_y2_pos, DRAIMS_cusor_y2_array[get(DRAIMS_VHF_cursor_pos)], 190, 390, 25)--animate cursor box position
    vhf_cusor_y3_pos = Set_anim_value(vhf_cusor_y3_pos, DRAIMS_cusor_y3_array[get(DRAIMS_VHF_cursor_pos)], 109, 309, 25)--animate cursor box position
    vhf_cusor_y4_pos = Set_anim_value(vhf_cusor_y4_pos, DRAIMS_cusor_y4_array[get(DRAIMS_VHF_cursor_pos)], 108, 308, 25)--animate cursor box position
end

--NAV CURSOR-----------------------------------------------------------------------------------------------------------
local function animate_nav_cursor()
    --change nav cursor text info and indications
    if get(DRAIMS_NAV_cursor_pos) == 1 then--ils
        nav_cursor_l_b_text = "NAV 1"
        nav_cursor_r_b_text = "NAV 2"
        --show what freqencies you are listening to if any
        if get(Audio_nav_selection) == 0 then
            if get(DRAIMS_dynamic_NAV_audio_selected) == 1 then--if dynamic nav audio is on
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 1, 0, 1, 15)
            else
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)
            end
            nav_cursor_l_b_text_cl = DRAIMS_GREEN
            nav_cursor_r_b_text_cl = DRAIMS_WHITE
        elseif get(Audio_nav_selection) == 1 then
            if get(DRAIMS_dynamic_NAV_audio_selected) == 1 then--if dynamic nav audio is on
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 1, 0, 1, 15)
            else
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)
            end
            nav_cursor_l_b_text_cl = DRAIMS_WHITE
            nav_cursor_r_b_text_cl = DRAIMS_GREEN
        elseif get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 2 or get(Audio_nav_selection) == 3 then
            nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)--hide speaker because you are not listening to anything
            nav_cursor_l_b_text_cl = DRAIMS_WHITE
            nav_cursor_r_b_text_cl = DRAIMS_WHITE
        end
    elseif get(DRAIMS_NAV_cursor_pos) == 2 then--vor
        nav_cursor_l_b_text = "NAV 1"
        nav_cursor_r_b_text = "NAV 2"
        --show what freqencies you are listening to if any
        if get(Audio_nav_selection) == 0 then
            if get(DRAIMS_dynamic_NAV_audio_selected) == 1 then--if dynamic nav audio is on
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 1, 0, 1, 15)
            else
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)
            end
            nav_cursor_l_b_text_cl = DRAIMS_GREEN
            nav_cursor_r_b_text_cl = DRAIMS_WHITE
        elseif get(Audio_nav_selection) == 1 then
            if get(DRAIMS_dynamic_NAV_audio_selected) == 1 then--if dynamic nav audio is on
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 1, 0, 1, 15)
            else
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)
            end
            nav_cursor_l_b_text_cl = DRAIMS_WHITE
            nav_cursor_r_b_text_cl = DRAIMS_GREEN
        elseif get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 2 or get(Audio_nav_selection) == 3 then
            nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)--hide speaker because you are not listening to anything
            nav_cursor_l_b_text_cl = DRAIMS_WHITE
            nav_cursor_r_b_text_cl = DRAIMS_WHITE
        end
    elseif get(DRAIMS_NAV_cursor_pos) == 3 then--adf
        nav_cursor_l_b_text = "ADF 1"
        nav_cursor_r_b_text = "ADF 2"
        --show what freqencies you are listening to if any
        if get(Audio_nav_selection) == 2 then
            if get(DRAIMS_dynamic_NAV_audio_selected) == 1 then--if dynamic nav audio is on
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 1, 0, 1, 15)
            else
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)
            end
            nav_cursor_l_b_text_cl = DRAIMS_GREEN
            nav_cursor_r_b_text_cl = DRAIMS_WHITE
        elseif get(Audio_nav_selection) == 3 then
            if get(DRAIMS_dynamic_NAV_audio_selected) == 1 then--if dynamic nav audio is on
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 1, 0, 1, 15)
            else
                nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)
            end
            nav_cursor_l_b_text_cl = DRAIMS_WHITE
            nav_cursor_r_b_text_cl = DRAIMS_GREEN
        elseif get(Audio_nav_selection) == 9 or get(Audio_nav_selection) == 0 or get(Audio_nav_selection) == 2 then
            nav_cusor_speaker_alpha = Set_anim_value(nav_cusor_speaker_alpha, 0, 0, 1, 15)--hide speaker because you are not listening to anything
            nav_cursor_l_b_text_cl = DRAIMS_WHITE
            nav_cursor_r_b_text_cl = DRAIMS_WHITE
        end
    end

    --nav cursor box fade in and out
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
    else
        nav_cursor_box_timer = 0
        nav_cursor_box_cl[4] = 1
    end

    --animate nav cursor position and arrow indications
    nav_cursor_up_arrow_y1_pos = Set_anim_value(nav_cursor_up_arrow_y1_pos, DRAIMS_cusor_up_arrow_y1_array[get(DRAIMS_NAV_cursor_pos)], 170, 370, 25)--animate upper arrow triangle position
    nav_cursor_up_arrow_y2_pos = Set_anim_value(nav_cursor_up_arrow_y2_pos, DRAIMS_cusor_up_arrow_y2_array[get(DRAIMS_NAV_cursor_pos)], 188, 388, 25)--animate upper arrow triangle position
    nav_cusor_arrow_stick_y1_pos = Set_anim_value(nav_cusor_arrow_stick_y1_pos, DRAIMS_cusor_arrow_stick_y1_array[get(DRAIMS_NAV_cursor_pos)], 170, 360, 25)--animate arrow stick position
    nav_cusor_arrow_stick_y2_pos = Set_anim_value(nav_cusor_arrow_stick_y2_pos, DRAIMS_cusor_arrow_stick_y2_array[get(DRAIMS_NAV_cursor_pos)], 140, 330, 25)--animate arrow stick position
    nav_cursor_down_arrow_y1_pos = Set_anim_value(nav_cursor_down_arrow_y1_pos, DRAIMS_cusor_down_arrow_y1_array[get(DRAIMS_NAV_cursor_pos)], 130, 330, 25)--animate lower arrow triangle position
    nav_cursor_down_arrow_y2_pos = Set_anim_value(nav_cursor_down_arrow_y2_pos, DRAIMS_cusor_down_arrow_y2_array[get(DRAIMS_NAV_cursor_pos)], 112, 312, 25)--animate lower arrow triangle position
    nav_cusor_text_y_pos = Set_anim_value(nav_cusor_text_y_pos, DRAIMS_cusor_text_y_array[get(DRAIMS_NAV_cursor_pos)], 115, 315, 25)--animate cursor buttom text position
    nav_cusor_y1_pos = Set_anim_value(nav_cusor_y1_pos, DRAIMS_cusor_y1_array[get(DRAIMS_NAV_cursor_pos)], 192, 392, 25)--animate cursor box position
    nav_cusor_y2_pos = Set_anim_value(nav_cusor_y2_pos, DRAIMS_cusor_y2_array[get(DRAIMS_NAV_cursor_pos)], 190, 390, 25)--animate cursor box position
    nav_cusor_y3_pos = Set_anim_value(nav_cusor_y3_pos, DRAIMS_cusor_y3_array[get(DRAIMS_NAV_cursor_pos)], 109, 309, 25)--animate cursor box position
    nav_cusor_y4_pos = Set_anim_value(nav_cusor_y4_pos, DRAIMS_cusor_y4_array[get(DRAIMS_NAV_cursor_pos)], 108, 308, 25)--animate cursor box position
    nav_cusor_speaker_y_pos = Set_anim_value(nav_cusor_speaker_y_pos, nav_cusor_speaker_y_array[get(DRAIMS_NAV_cursor_pos)], 145, 345, 25)--animate cursor box position
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
                if tonumber(DRAIMS_entry) >= 108.1 and tonumber(DRAIMS_entry) <= 111.95 then--full format entry
                    set(NAV_1_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_2_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) >= 10810 and tonumber(DRAIMS_entry) <= 11195 then--full format entry without dp
                    set(NAV_1_freq_Mhz, math.floor(tonumber(DRAIMS_entry) / 100))
                    set(NAV_2_freq_Mhz, math.floor(tonumber(DRAIMS_entry) / 100))
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) < 1 then--decimal entry
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                end
            end
        elseif get(DRAIMS_current_page) == 8 then-- on vor page
            if check_vor_fmt() == true then
                if tonumber(DRAIMS_entry) >= 108 and tonumber(DRAIMS_entry) <= 117.95 then--full format entry
                    set(NAV_1_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) >= 10800 and tonumber(DRAIMS_entry) <= 11795 then--full format entry without dp
                    set(NAV_1_freq_Mhz, math.floor(tonumber(DRAIMS_entry) / 100))
                    set(NAV_1_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) > 0 and tonumber(DRAIMS_entry) < 1 then--decimal entry
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
                if tonumber(DRAIMS_entry) >= 108 and tonumber(DRAIMS_entry) <= 117.95 then--full format entry
                    set(NAV_2_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) >= 10800 and tonumber(DRAIMS_entry) <= 11795 then--full format entry without dp
                    set(NAV_2_freq_Mhz, math.floor(tonumber(DRAIMS_entry) / 100))
                    set(NAV_2_freq_10khz, tostring(Round((tonumber(DRAIMS_entry) / 100 - math.floor(tonumber(DRAIMS_entry) / 100)) * 100)))
                    DRAIMS_entry = ""
                elseif tonumber(DRAIMS_entry) > 0 and tonumber(DRAIMS_entry) < 1 then--decimal entry
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
                        if tonumber(DRAIMS_entry) >= 118 and tonumber(DRAIMS_entry) <= 137 then--full format with dp
                            set(VHF_1_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                            set(VHF_1_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        elseif tonumber(DRAIMS_entry) >= 118000 and tonumber(DRAIMS_entry) <= 137000 then--no dp full format
                            set(VHF_1_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry) / 1000))
                            set(VHF_1_stby_freq_khz, Round((tonumber(DRAIMS_entry) / 1000 - math.floor(tonumber(DRAIMS_entry) / 1000)) * 1000))
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
            else
                if #DRAIMS_entry == 0 then
                    if finding_navaid_id[1] ~= NAV_NOT_FOUND then
                        if Round(get(NAV_1_capt_obs)) ~= Round(NAVs_heading[1]) then
                            set(NAV_1_capt_obs, NAVs_heading[1])
                            set(NAV_1_fo_obs, NAVs_heading[1])
                            set(NAV_2_capt_obs, NAVs_heading[1])
                            set(NAV_2_fo_obs, NAVs_heading[1])
                        end
                    end
                end
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
                        if tonumber(DRAIMS_entry) >= 118 and tonumber(DRAIMS_entry) <= 137 then--full format with dp
                            set(VHF_2_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                            set(VHF_2_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        elseif tonumber(DRAIMS_entry) >= 118000 and tonumber(DRAIMS_entry) <= 137000 then--no dp full format
                            set(VHF_2_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry) / 1000))
                            set(VHF_2_stby_freq_khz, Round((tonumber(DRAIMS_entry) / 1000 - math.floor(tonumber(DRAIMS_entry) / 1000)) * 1000))
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
                        if tonumber(DRAIMS_entry) >= 118 and tonumber(DRAIMS_entry) <= 137 then--full format with dp
                            set(DRAIMS_cursor_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                            set(DRAIMS_cursor_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        elseif tonumber(DRAIMS_entry) >= 118000 and tonumber(DRAIMS_entry) <= 137000 then--no dp full format
                            set(DRAIMS_cursor_freq_Mhz, math.floor(tonumber(DRAIMS_entry) / 1000))
                            set(DRAIMS_cursor_freq_khz, Round((tonumber(DRAIMS_entry) / 1000 - math.floor(tonumber(DRAIMS_entry) / 1000)) * 1000))
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

    --search and store all navaid info for information and suggestion display
    finding_navaid_id[1] = sasl.findNavAid ( nil , nil , get(Aircraft_lat) , get(Aircraft_long) , get(globalProperty("sim/cockpit2/radios/actuators/nav1_frequency_hz")), NAV_ILS)
    finding_navaid_id[2] = sasl.findNavAid ( nil , nil , get(Aircraft_lat) , get(Aircraft_long) , get(globalProperty("sim/cockpit2/radios/actuators/nav1_frequency_hz")), NAV_VOR)
    finding_navaid_id[3] = sasl.findNavAid ( nil , nil , get(Aircraft_lat) , get(Aircraft_long) , get(globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_hz")), NAV_VOR)
    finding_navaid_id[4] = sasl.findNavAid ( nil , nil , get(Aircraft_lat) , get(Aircraft_long) , get(globalProperty("sim/cockpit2/radios/actuators/adf1_frequency_hz")), NAV_NDB)
    finding_navaid_id[5] = sasl.findNavAid ( nil , nil , get(Aircraft_lat) , get(Aircraft_long) , get(globalProperty("sim/cockpit2/radios/actuators/adf2_frequency_hz")), NAV_NDB)
    --aquire navaid info
    NAVs_type[1], NAVs_latitude[1], NAVs_longitude[1], NAVs_height[1], NAVs_frequency[1], NAVs_heading[1], NAVs_id[1], NAVs_name[1], NAVs_isInsideLoadedDSFs[1] = sasl.getNavAidInfo(finding_navaid_id[1])
    NAVs_type[2], NAVs_latitude[2], NAVs_longitude[2], NAVs_height[2], NAVs_frequency[2], NAVs_heading[2], NAVs_id[2], NAVs_name[2], NAVs_isInsideLoadedDSFs[2] = sasl.getNavAidInfo(finding_navaid_id[2])
    NAVs_type[1], NAVs_latitude[3], NAVs_longitude[3], NAVs_height[3], NAVs_frequency[3], NAVs_heading[3], NAVs_id[3], NAVs_name[3], NAVs_isInsideLoadedDSFs[3] = sasl.getNavAidInfo(finding_navaid_id[3])
    NAVs_type[1], NAVs_latitude[4], NAVs_longitude[4], NAVs_height[4], NAVs_frequency[4], NAVs_heading[4], NAVs_id[4], NAVs_name[4], NAVs_isInsideLoadedDSFs[4] = sasl.getNavAidInfo(finding_navaid_id[4])
    NAVs_type[1], NAVs_latitude[5], NAVs_longitude[5], NAVs_height[5], NAVs_frequency[5], NAVs_heading[5], NAVs_id[5], NAVs_name[5], NAVs_isInsideLoadedDSFs[5] = sasl.getNavAidInfo(finding_navaid_id[5])

    --scrolling through the names of the navaid if longer than 10 characters
    --vor 1
    if #NAVs_name[2] - 8 > 11 then
        vor1_scrolling_x_pos = Math_cycle(vor1_scrolling_x_pos - 24 * get(DELTA_TIME), 220 - (#NAVs_name[2] -11 -8) * 19.5, 220)-- -11 because that's the max length -8 to remove the "VOR/DME" and the end
        vor1_scrolling_alignment = TEXT_ALIGN_LEFT
    else
        vor1_scrolling_x_pos = 300
        vor1_scrolling_alignment = TEXT_ALIGN_CENTER
    end
    --vor 2
    if #NAVs_name[3] - 8 > 11 then
        vor2_scrolling_x_pos = Math_cycle(vor2_scrolling_x_pos - 24 * get(DELTA_TIME), 220 - (#NAVs_name[3] -11 -8) * 19.5, 220)-- -11 because that's the max length -8 to remove the "VOR/DME" and the end
        vor2_scrolling_alignment = TEXT_ALIGN_LEFT
    else
        vor2_scrolling_x_pos = 300
        vor2_scrolling_alignment = TEXT_ALIGN_CENTER
    end
    --adf 1
    if #NAVs_name[4] - 4 > 11 then
        adf1_scrolling_x_pos = Math_cycle(adf1_scrolling_x_pos - 24 * get(DELTA_TIME), 220 - (#NAVs_name[4] -11 -4) * 19.5, 220)-- -11 because that's the max length -4 to remove the "NDB" and the end
        adf1_scrolling_alignment = TEXT_ALIGN_LEFT
    else
        adf1_scrolling_x_pos = 300
        adf1_scrolling_alignment = TEXT_ALIGN_CENTER
    end
    --adf 2
    if #NAVs_name[5] - 4 > 11 then
        adf2_scrolling_x_pos = Math_cycle(adf2_scrolling_x_pos - 24 * get(DELTA_TIME), 220 - (#NAVs_name[5] -11 -4) * 19.5, 220)-- -11 because that's the max length -4 to remove the "NDB" and the end
        adf2_scrolling_alignment = TEXT_ALIGN_LEFT
    else
        adf2_scrolling_x_pos = 300
        adf2_scrolling_alignment = TEXT_ALIGN_CENTER
    end

    --ANIMATE THE CURSORS--------------------------------------------------------------------------------------------------
    animate_vhf_cursor()
    animate_nav_cursor()

    --dynamic nav volume control-------------------------------------------------------------------------------------------
    set(DME_volume, 0)
    set(DME_1_volume, 0)
    set(DME_2_volume, 0)
    if get(DRAIMS_dynamic_NAV_audio_selected) == 0 then--kill all volumes
        set(NAV_1_volume, 0)
        set(NAV_2_volume, 0)
        set(ADF_1_volume, 0)
        set(ADF_2_volume, 0)
    elseif get(DRAIMS_dynamic_NAV_audio_selected) == 1 then
        if get(Audio_nav_selection) == 9 then--inactive
            set(NAV_1_volume, 0)
            set(NAV_2_volume, 0)
            set(ADF_1_volume, 0)
            set(ADF_2_volume, 0)
        end
        if get(Audio_nav_selection) == 0 then--nav 1
            set(NAV_1_volume, get(DRAIMS_dynamic_NAV_volume))
        else
            set(NAV_1_volume, 0)
        end
        if get(Audio_nav_selection) == 1 then--nav 2
            set(NAV_2_volume, get(DRAIMS_dynamic_NAV_volume))
        else
            set(NAV_2_volume, 0)
        end
        if get(Audio_nav_selection) == 2 then--adf 1
            set(ADF_1_volume, get(DRAIMS_dynamic_NAV_volume))
        else
            set(ADF_1_volume, 0)
        end
        if get(Audio_nav_selection) == 3 then--adf 2
            set(ADF_2_volume, get(DRAIMS_dynamic_NAV_volume))
        else
            set(ADF_2_volume, 0)
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

    --the small speakers alphas
    if get(VHF_1_audio_selected) == 1 then
        DRAIMS_line_1_speaker_alpha = Set_anim_value(DRAIMS_line_1_speaker_alpha, 1, 0, 1, 15)
    else
        DRAIMS_line_1_speaker_alpha = Set_anim_value(DRAIMS_line_1_speaker_alpha, 0, 0, 1, 15)
    end
    if get(VHF_2_audio_selected) == 1 then
        DRAIMS_line_2_speaker_alpha = Set_anim_value(DRAIMS_line_2_speaker_alpha, 1, 0, 1, 15)
    else
        DRAIMS_line_2_speaker_alpha = Set_anim_value(DRAIMS_line_2_speaker_alpha, 0, 0, 1, 15)
    end

    --ident box fade in and out
    if get(Sqwk_identifying) == 1 then
        ident_box_timer = ident_box_timer + math.pi * get(DELTA_TIME)
        ident_box_cl[4] = (math.sin(ident_box_timer - math.pi / 2) - -1) / 2
    else
        ident_box_timer = 0
    end

    --crs suggest box fade in and out
    if finding_navaid_id[1] ~= NAV_NOT_FOUND then
        if Round(get(NAV_1_capt_obs)) ~= Round(NAVs_heading[1]) then
            crs_suggest_box_timer = crs_suggest_box_timer + math.pi * get(DELTA_TIME)
            crs_suggest_box_cl[4] = (math.sin(crs_suggest_box_timer - math.pi / 2) - -1) / 2
        else
            crs_suggest_box_timer = 0
            crs_suggest_box_cl[4] = Set_anim_value(crs_suggest_box_cl[4], 0, 0, 1, 2.5)
        end
    else
        crs_suggest_box_timer = 0
        crs_suggest_box_cl[4] = Set_anim_value(crs_suggest_box_cl[4], 0, 0, 1, 2.5)
    end
end

function draw()
    --draw the DRAIMS if both of the DRAIMS screens are on
    if get(DRAIMS_1_brightness) > 0 or get(DRAIMS_2_brightness) > 0 then
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
            else--when cursor is on its opsition compare to see if the freqs are the same
                if (get(VHF_1_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_1_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then--cusor and stby freq identical no swapping needed
                    sasl.gl.drawText(A320_panel_font, 380, 344, "IDT FREQ", 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                else
                    sasl.gl.drawText(A320_panel_font_MONO, 380, 344, Fwd_string_fill(tostring(get(VHF_1_stby_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_1_stby_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                end
            end
            --draw vhf 1 speaker
            sasl.gl.drawTexture (draims_speaker_img, 300 - (35 * 0.6) / 2, 315, 35 * 0.6, 42 * 0.6 , {1, 1, 1, DRAIMS_line_1_speaker_alpha})

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
            else--when cursor is on its opsition compare to see if the freqs are the same
                if (get(VHF_2_stby_freq_Mhz) == get(DRAIMS_cursor_freq_Mhz)) and (get(VHF_2_stby_freq_khz) == get(DRAIMS_cursor_freq_khz)) then--cusor and stby freq identical no swapping needed
                    sasl.gl.drawText(A320_panel_font, 380, 244, "IDT FREQ", 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                else
                    sasl.gl.drawText(A320_panel_font_MONO, 380, 244, Fwd_string_fill(tostring(get(VHF_2_stby_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(VHF_2_stby_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
                end
            end
            --draw vhf 2 speaker
            sasl.gl.drawTexture (draims_speaker_img, 300 - (35 * 0.6) / 2, 215, 35 * 0.6, 42 * 0.6 , {1, 1, 1, DRAIMS_line_2_speaker_alpha})

            --vhf 3
            sasl.gl.drawText(A320_panel_font, 180, 132, "DATA", 68, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            --cursor on the thrid row of stby freq(default inactive)
            if get(DRAIMS_VHF_cursor_pos) == 3 then
                --the cursor frequency
                sasl.gl.drawText(A320_panel_font_MONO, 380, 144, Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(DRAIMS_cursor_freq_khz)), "0", 3), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                --indicate if the freqency is an emer frqency
                if get(DRAIMS_cursor_freq_Mhz) == 121 and get(DRAIMS_cursor_freq_khz) == 500 then
                    sasl.gl.drawText(A320_panel_font, 465, 115, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
                end
            end

            --draw nav cursor---------------------------------------------------------------------------------------------------------------------------
            sasl.gl.drawWideLine(355, vhf_cusor_y1_pos, 575, vhf_cusor_y1_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, vhf_cusor_y3_pos, 354, vhf_cusor_y2_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, vhf_cusor_y3_pos, 577, vhf_cusor_y2_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, vhf_cusor_y4_pos, 575, vhf_cusor_y4_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, vhf_cusor_y2_pos, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, vhf_cusor_y2_pos, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, vhf_cusor_y3_pos, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, vhf_cusor_y3_pos, 0, 3, 270, 90, vhf_cursor_box_cl)

            if get(DRAIMS_VHF_cursor_pos) ~= 3 then
                sasl.gl.drawText(A320_panel_font, 380, vhf_cusor_text_y_pos, vhf_cursor_l_b_text, 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
                sasl.gl.drawText(A320_panel_font, 550, vhf_cusor_text_y_pos, vhf_cursor_r_b_text, 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            end

            --cursor movement indicator
            if get(DRAIMS_VHF_cursor_pos) == 3 or get(DRAIMS_VHF_cursor_pos) == 2 then
                sasl.gl.drawTriangle(362, vhf_cursor_up_arrow_y1_pos, 370, vhf_cursor_up_arrow_y2_pos, 378, vhf_cursor_up_arrow_y1_pos, DRAIMS_WHITE)
            end
            sasl.gl.drawWideLine(370, vhf_cusor_arrow_stick_y1_pos, 370, vhf_cusor_arrow_stick_y2_pos, 4, DRAIMS_WHITE)
            if get(DRAIMS_VHF_cursor_pos) == 1 or get(DRAIMS_VHF_cursor_pos) == 2 then
                sasl.gl.drawTriangle(362, vhf_cursor_down_arrow_y1_pos, 370, vhf_cursor_down_arrow_y2_pos, 378, vhf_cursor_down_arrow_y1_pos, DRAIMS_WHITE)
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
            ------------------------------------------------------------------------------------------------------------------------------------------------
        elseif get(DRAIMS_current_page) == 2 then--hf page
            --hf 1
            sasl.gl.drawText(A320_panel_font, 125, 332, "INOP", 68, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            if get(DRAIMS_VHF_cursor_pos) ~= 1 then
                sasl.gl.drawText(A320_panel_font, 465, 344, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            else
                sasl.gl.drawText(A320_panel_font, 465, 344, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)
            end

            --hf 2
            sasl.gl.drawText(A320_panel_font, 125, 232, "INOP", 68, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            if get(DRAIMS_VHF_cursor_pos) ~= 2 then
                sasl.gl.drawText(A320_panel_font, 465, 244, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            else
                sasl.gl.drawText(A320_panel_font, 465, 244, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)
            end

            --draw nav cursor
            sasl.gl.drawWideLine(355, vhf_cusor_y1_pos, 575, vhf_cusor_y1_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(354, vhf_cusor_y3_pos, 354, vhf_cusor_y2_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(577, vhf_cusor_y3_pos, 577, vhf_cusor_y2_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawWideLine(355, vhf_cusor_y4_pos, 575, vhf_cusor_y4_pos, 3, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, vhf_cusor_y2_pos, 0, 3, 90, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, vhf_cusor_y2_pos, 0, 3, 0, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 355, vhf_cusor_y3_pos, 0, 3, 180, 90, vhf_cursor_box_cl)
            sasl.gl.drawArc ( 575, vhf_cusor_y3_pos, 0, 3, 270, 90, vhf_cursor_box_cl)

            if get(DRAIMS_VHF_cursor_pos) ~= 3 then
                sasl.gl.drawText(A320_panel_font, 550, vhf_cusor_text_y_pos, "NO SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
            else
                sasl.gl.drawText(A320_panel_font, 465, 144, "INOP", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)
            end

            --cursor movement indicator
            if get(DRAIMS_VHF_cursor_pos) == 3 or get(DRAIMS_VHF_cursor_pos) == 2 then
                sasl.gl.drawTriangle(362, vhf_cursor_up_arrow_y1_pos, 370, vhf_cursor_up_arrow_y2_pos, 378, vhf_cursor_up_arrow_y1_pos, DRAIMS_WHITE)
            end
            sasl.gl.drawWideLine(370, vhf_cusor_arrow_stick_y1_pos, 370, vhf_cusor_arrow_stick_y2_pos, 4, DRAIMS_WHITE)
            if get(DRAIMS_VHF_cursor_pos) == 1 or get(DRAIMS_VHF_cursor_pos) == 2 then
                sasl.gl.drawTriangle(362, vhf_cursor_down_arrow_y1_pos, 370, vhf_cursor_down_arrow_y2_pos, 378, vhf_cursor_down_arrow_y1_pos, DRAIMS_WHITE)
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

            --draw nav cursor
            sasl.gl.drawWideLine(355, nav_cusor_y1_pos, 575, nav_cusor_y1_pos, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(354, nav_cusor_y3_pos, 354, nav_cusor_y2_pos, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(577, nav_cusor_y3_pos, 577, nav_cusor_y2_pos, 3, nav_cursor_box_cl)
            sasl.gl.drawWideLine(355, nav_cusor_y4_pos, 575, nav_cusor_y4_pos, 3, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, nav_cusor_y2_pos, 0, 3, 90, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, nav_cusor_y2_pos, 0, 3, 0, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 355, nav_cusor_y3_pos, 0, 3, 180, 90, nav_cursor_box_cl)
            sasl.gl.drawArc ( 575, nav_cusor_y3_pos, 0, 3, 270, 90, nav_cursor_box_cl)

            sasl.gl.drawText(A320_panel_font, 380, nav_cusor_text_y_pos, nav_cursor_l_b_text, 28, false, false, TEXT_ALIGN_LEFT, nav_cursor_l_b_text_cl)
            sasl.gl.drawText(A320_panel_font, 550, nav_cusor_text_y_pos, nav_cursor_r_b_text, 28, false, false, TEXT_ALIGN_RIGHT, nav_cursor_r_b_text_cl)

            --cursor movement indicator
            if get(DRAIMS_NAV_cursor_pos) == 3 or get(DRAIMS_NAV_cursor_pos) == 2 then
                sasl.gl.drawTriangle(362, nav_cursor_up_arrow_y1_pos, 370, nav_cursor_up_arrow_y2_pos, 378, nav_cursor_up_arrow_y1_pos, DRAIMS_WHITE)
            end
            sasl.gl.drawWideLine(370, nav_cusor_arrow_stick_y1_pos, 370, nav_cusor_arrow_stick_y2_pos, 4, DRAIMS_WHITE)
            if get(DRAIMS_NAV_cursor_pos) == 1 or get(DRAIMS_NAV_cursor_pos) == 2 then
                sasl.gl.drawTriangle(362, nav_cursor_down_arrow_y1_pos, 370, nav_cursor_down_arrow_y2_pos, 378, nav_cursor_down_arrow_y1_pos, DRAIMS_WHITE)
            end

            sasl.gl.drawTexture (draims_speaker_img, 380, nav_cusor_speaker_y_pos, 35, 42, {1, 1, 1, nav_cusor_speaker_alpha})

        elseif get(DRAIMS_current_page) == 7 then--ils page
            if (string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "1" and
               string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "3" and
               string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "5" and
               string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "7" and
               string.sub(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 5, 5) ~= "9") or
               (tonumber(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2)) < 108.1 or
                tonumber(Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2)) > 111.95) then --not a ILS frequency so must be using VOR
                if finding_navaid_id[2] ~= NAV_NOT_FOUND then
                    sasl.gl.drawText(A320_panel_font, 125, 315, "VOR", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
                else
                    sasl.gl.drawText(A320_panel_font, 125, 315, "INVLD", 50, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
                end
            else
                --ils 1 freq
                sasl.gl.drawText(A320_panel_font_MONO, 125, 315, Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
                --ils 1 name
                sasl.gl.drawText(A320_panel_font, 315, 315, string.upper(NAVs_name[1]), 22, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
                --navaid 1 ID
                sasl.gl.drawText(A320_panel_font, 10, 360, NAVs_id[1], 22, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
            end

            --obs suggestion
            sasl.gl.drawText(A320_panel_font, 550, 338, Round(NAVs_heading[1]), 32, false, false, TEXT_ALIGN_CENTER, crs_suggest_box_cl)

            --draw suggestion box
            sasl.gl.drawWideLine(515, 372, 585, 372, 3, crs_suggest_box_cl)
            sasl.gl.drawWideLine(514, 329, 514, 370, 3, crs_suggest_box_cl)
            sasl.gl.drawWideLine(587, 329, 587, 370, 3, crs_suggest_box_cl)
            sasl.gl.drawWideLine(515, 328, 585, 328, 3, crs_suggest_box_cl)
            sasl.gl.drawArc ( 515, 370, 0, 3, 90, 90, crs_suggest_box_cl)
            sasl.gl.drawArc ( 585, 370, 0, 3, 0, 90, crs_suggest_box_cl)
            sasl.gl.drawArc ( 515, 329, 0, 3, 180, 90, crs_suggest_box_cl)
            sasl.gl.drawArc ( 585, 329, 0, 3, 270, 90, crs_suggest_box_cl)

            --ils 1 obs
            sasl.gl.drawText(A320_panel_font_MONO, 465, 315, Round(get(NAV_1_capt_obs)), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        elseif get(DRAIMS_current_page) == 8 then--vor page
            --show if the nav 1 freq is actually a VOR freq
            if finding_navaid_id[2] ~= NAV_NOT_FOUND then
                --navaid 1 name
                sasl.gl.drawText(A320_panel_font, vor1_scrolling_x_pos, 315, string.sub(NAVs_name[2], 1, #NAVs_name[2] - 8), 25, false, false, vor1_scrolling_alignment, DRAIMS_GREEN)
                --draw navaid 1 name clip region
                sasl.gl.drawRectangle(0, 305, 210, 40, DRAIMS_BLACK)
                sasl.gl.drawRectangle(390, 305, 210, 40, DRAIMS_BLACK)
                --nav 1
                sasl.gl.drawText(A320_panel_font_MONO, 125, 315, Fwd_string_fill(tostring(get(NAV_1_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_1_freq_10khz)), "0", 2), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
                --navaid 1 ID
                sasl.gl.drawText(A320_panel_font, 10, 360, NAVs_id[2], 25, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
            else
                --show ILS if the frequency matches a ILS system
                if finding_navaid_id[1] ~= NAV_NOT_FOUND then
                --nav 1
                    sasl.gl.drawText(A320_panel_font, 125, 315, "ILS", 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
                else--show invalid if freq doesn't match ils nor vor
                    sasl.gl.drawText(A320_panel_font, 125, 315, "INVLD", 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
                end
            end
            --obs 1
            sasl.gl.drawText(A320_panel_font_MONO, 465, 315, Round(get(NAV_1_capt_obs)), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)

            --show if the nav 2 freq is actually a VOR freq
            if finding_navaid_id[3] ~= NAV_NOT_FOUND then
                --navaid 2 name
                sasl.gl.drawText(A320_panel_font, vor2_scrolling_x_pos, 215, string.sub(NAVs_name[3], 1, #NAVs_name[3] - 8), 25, false, false, vor2_scrolling_alignment, DRAIMS_GREEN)
                --draw navaid 2 name clip region
                sasl.gl.drawRectangle(0, 205, 210, 40, DRAIMS_BLACK)
                sasl.gl.drawRectangle(390, 205, 210, 40, DRAIMS_BLACK)
                --nav 2
                sasl.gl.drawText(A320_panel_font_MONO, 125, 215, Fwd_string_fill(tostring(get(NAV_2_freq_Mhz)), "0", 3) .. "." .. Fwd_string_fill(tostring(get(NAV_2_freq_10khz)), "0", 2), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
                --navaid 2 ID
                sasl.gl.drawText(A320_panel_font, 10, 260, NAVs_id[3], 25, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
            else
                --show ILS if the frequency matches a ILS system
                if sasl.findNavAid ( nil , nil , get(Aircraft_lat) , get(Aircraft_long) , get(globalProperty("sim/cockpit2/radios/actuators/nav2_frequency_hz")), NAV_ILS) ~= NAV_NOT_FOUND then--used because there isn't 2 ILS entries
                --nav 2
                    sasl.gl.drawText(A320_panel_font, 125, 215, "ILS", 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_GREEN)
                else--show invalid if freq doesn't match ils nor vor
                    sasl.gl.drawText(A320_panel_font, 125, 215, "INVLD", 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
                end
            end
            --obs 2
            sasl.gl.drawText(A320_panel_font_MONO, 465, 215, Round(get(NAV_2_capt_obs)), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        elseif get(DRAIMS_current_page) == 9 then--adf page
            --show the adf 1 id and name if it is found
            if finding_navaid_id[4] ~= NAV_NOT_FOUND then
                --adf 1 name
                sasl.gl.drawText(A320_panel_font, adf1_scrolling_x_pos, 315, string.sub(NAVs_name[4], 1, #NAVs_name[4] - 4), 25, false, false, adf1_scrolling_alignment, DRAIMS_GREEN)
                --draw navaid 1 name clip region
                sasl.gl.drawRectangle(0, 305, 210, 40, DRAIMS_BLACK)
                sasl.gl.drawRectangle(390, 305, 210, 40, DRAIMS_BLACK)
                --adf 1 id
                sasl.gl.drawText(A320_panel_font, 10, 360, NAVs_id[4], 25, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
            end
            --adf 1
            sasl.gl.drawText(A320_panel_font_MONO, 125, 315, Fwd_string_fill(tostring(get(ADF_1_freq_hz)), "0", 3), 54, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)

            --show the adf 2 id and name if it is found
            if finding_navaid_id[5] ~= NAV_NOT_FOUND then
                --adf 2 name
                sasl.gl.drawText(A320_panel_font, adf2_scrolling_x_pos, 215, string.sub(NAVs_name[5], 1, #NAVs_name[5] - 4), 25, false, false, adf2_scrolling_alignment, DRAIMS_GREEN)
                --draw navaid 2 name clip region
                sasl.gl.drawRectangle(0, 205, 210, 40, DRAIMS_BLACK)
                sasl.gl.drawRectangle(390, 205, 210, 40, DRAIMS_BLACK)
                --adf 2 id
                sasl.gl.drawText(A320_panel_font, 10, 260, NAVs_id[5], 25, false, false, TEXT_ALIGN_LEFT, DRAIMS_GREEN)
            end
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
        elseif get(DRAIMS_format_error) == 18 then--ils last digit 0 or 5
            sasl.gl.drawText(A320_panel_font, 425, 70, "ILS FREQ SP", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
            sasl.gl.drawText(A320_panel_font, 425, 48, "xxx.x>x< MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
            sasl.gl.drawText(A320_panel_font, 498, 26, "^", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
            sasl.gl.drawText(A320_panel_font, 425, 4, "0 OR 5", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        elseif get(DRAIMS_format_error) == 19 then--sqwk 0 to 7 per digit
            sasl.gl.drawText(A320_panel_font, 425, 70, "SQWK FMT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
            sasl.gl.drawText(A320_panel_font, 425, 48, "0 TO 7", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
            sasl.gl.drawText(A320_panel_font, 425, 26, "PER DIGIT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
            sasl.gl.drawText(A320_panel_font, 425, 4, "xxxx", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
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
end