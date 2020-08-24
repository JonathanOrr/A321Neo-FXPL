position = {1852, 1449, 600, 400}
size = {600, 400}

--variables
local DRAIMS_entry = ""
local ident_box_timer = 0--used to fade alpha
local cursor_box_timer = 0--used to fade alpha

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
local cursor_box_cl = {0.004, 1.0, 1.0, 1}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")
local A320_panel_font = sasl.gl.loadFont("fonts/A320PanelFont_V0.2b.ttf")
local A320_panel_font_MONO = sasl.gl.loadFont("fonts/A320PanelFont_V0.2b.ttf")

sasl.gl.setFontRenderMode (A320_panel_font_MONO, TEXT_RENDER_FORCED_MONO, 0.48)--force mono space

--a32nx dataref

--sim dataref

--format checking & error issuing functions--
--check sqwk code format--
local function chk_dec_pt_duplication()--checking how many decimal points there are
    local dp_found = 0

    for i = 1, #DRAIMS_entry do
        if string.sub(DRAIMS_entry, i, i) == "." then
            dp_found = dp_found + 1
        end
    end

    return dp_found
end

local function check_sqwk_fmt()
    if chk_dec_pt_duplication() <= 1 then
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
        set(DRAIMS_format_error, 11)
        return false
    end
end

local function check_vhf_fmt()--check for the VHF entry format
    if chk_dec_pt_duplication() <= 1 then
        if (tonumber(DRAIMS_entry) >= 118 and tonumber(DRAIMS_entry) <= 137) or (tonumber(DRAIMS_entry) > 0 and tonumber(DRAIMS_entry) < 1) then
            return true
        else
            set(DRAIMS_format_error, 2)--vhf out of range
            return false
        end
    else
        set(DRAIMS_format_error, 11)
        return false
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
    end
end)

--left side buttons
sasl.registerCommandHandler ( Draims_l_1_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            set(VHF_1_freq_swapped, 1 - get(VHF_1_freq_swapped))
        elseif get(DRAIMS_current_page) == 2 then--hf page

        end
    end
end)
sasl.registerCommandHandler ( Draims_l_2_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            set(VHF_2_freq_swapped, 1 - get(VHF_2_freq_swapped))
        elseif get(DRAIMS_current_page) == 2 then--hf page

        end
    end
end)
sasl.registerCommandHandler ( Draims_l_3_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
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
            if get(DRAIMS_cursor_pos) == 1 then
                if #DRAIMS_entry == 0 then
                    --swap cursor freq
                    cursor_Mhz_swap_buffer = get(VHF_1_stby_freq_Mhz)
                    cursor_khz_swap_buffer = get(VHF_1_stby_freq_khz)
                    set(VHF_1_stby_freq_Mhz, get(DRAIMS_cursor_freq_Mhz))
                    set(VHF_1_stby_freq_khz, get(DRAIMS_cursor_freq_khz))
                    set(DRAIMS_cursor_freq_Mhz, cursor_Mhz_swap_buffer)
                    set(DRAIMS_cursor_freq_khz, cursor_khz_swap_buffer)
                    set(DRAIMS_cursor_pos, 3)
                else
                    set(DRAIMS_format_error, 10)
                end
            else
                if #DRAIMS_entry > 0 then
                    if check_vhf_fmt() == true then
                        if tonumber(DRAIMS_entry) >= 1 then
                            if tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry)) ~= 0 then--has decimal point(full format)
                                set(VHF_1_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                                set(VHF_1_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                                DRAIMS_entry = ""
                            else--only integer(edit integer only)
                                set(VHF_1_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                                DRAIMS_entry = ""
                            end
                        else--only decimal(edit decimal only)
                            set(VHF_1_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        end
                    end
                end
            end
        elseif get(DRAIMS_current_page) == 2 then--hf page
        
        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 7)
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_2_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            if get(DRAIMS_cursor_pos) == 2 then
                if #DRAIMS_entry == 0 then
                    --swap cursor freq
                    cursor_Mhz_swap_buffer = get(VHF_2_stby_freq_Mhz)
                    cursor_khz_swap_buffer = get(VHF_2_stby_freq_khz)
                    set(VHF_2_stby_freq_Mhz, get(DRAIMS_cursor_freq_Mhz))
                    set(VHF_2_stby_freq_khz, get(DRAIMS_cursor_freq_khz))
                    set(DRAIMS_cursor_freq_Mhz, cursor_Mhz_swap_buffer)
                    set(DRAIMS_cursor_freq_khz, cursor_khz_swap_buffer)
                    set(DRAIMS_cursor_pos, 3)
                else
                    set(DRAIMS_format_error, 10)
                end
            else
                if #DRAIMS_entry > 0 then
                    if check_vhf_fmt() == true then
                        if tonumber(DRAIMS_entry) >= 1 then
                            if tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry)) ~= 0 then--has decimal point(full format)
                                set(VHF_2_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                                set(VHF_2_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                                DRAIMS_entry = ""
                            else--only integer(edit integer only)
                                set(VHF_2_stby_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                                DRAIMS_entry = ""
                            end
                        else--only decimal(edit decimal only)
                            set(VHF_2_stby_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                            DRAIMS_entry = ""
                        end
                    end
                end
            end
        elseif get(DRAIMS_current_page) == 2 then--hf page
        
        elseif get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 8)
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_3_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        --different pages
        if get(DRAIMS_current_page) == 1 then--vhf page
            if get(DRAIMS_cursor_pos) == 3 then
                if #DRAIMS_entry > 0 then
                    if check_vhf_fmt() == true then
                        if tonumber(DRAIMS_entry) >= 1 then
                            if tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry)) ~= 0 then--has decimal point(full format)
                                set(DRAIMS_cursor_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                                set(DRAIMS_cursor_freq_khz, Round((tonumber(DRAIMS_entry) - math.floor(tonumber(DRAIMS_entry))) * 1000))
                                DRAIMS_entry = ""
                            else--only integer(edit integer only)
                                set(DRAIMS_cursor_freq_Mhz, math.floor(tonumber(DRAIMS_entry)))
                                DRAIMS_entry = ""
                            end
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
            set(DRAIMS_current_page, 9)
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_4_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
    end
end)

--numberpad
sasl.registerCommandHandler ( Draims_1_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "1"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_2_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "2"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_3_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "3"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_4_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "4"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_5_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "5"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_6_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "6"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_7_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "7"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_8_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "8"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_9_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "9"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_0_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "0"
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_dot_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry < 7 then
                DRAIMS_entry = DRAIMS_entry .. "."
            end
        end
    end
end)
sasl.registerCommandHandler ( Draims_clr_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_format_error) == 0 then
            if #DRAIMS_entry > 1 then
                DRAIMS_entry = string.sub(DRAIMS_entry, 1, #DRAIMS_entry - 1)
            else
                DRAIMS_entry = ""
            end
        else
            set(DRAIMS_format_error, 0)
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


sasl.registerCommandHandler ( Draims_cursor_up_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_cursor_pos, Math_clamp(get(DRAIMS_cursor_pos) - 1, 1, 3))
    end
end)
sasl.registerCommandHandler ( Draims_cursor_dn_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_cursor_pos, Math_clamp(get(DRAIMS_cursor_pos) + 1, 1, 3))
    end
end)

function update()
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

    --ident box fade in and out
    if get(Sqwk_identifying) == 1 then
        ident_box_timer = ident_box_timer + math.pi * get(DELTA_TIME)
        ident_box_cl[4] = (math.sin(ident_box_timer - math.pi / 2) - -1) / 2
    else
        ident_box_timer = 0
    end

    --ident box fade in and out
    if get(DRAIMS_cursor_pos) ~= 3 then
        cursor_box_timer = cursor_box_timer + math.pi * get(DELTA_TIME)
        cursor_box_cl[4] = (math.sin(cursor_box_timer - math.pi / 2) - -1) / 2
    else
        cursor_box_timer = 0
        cursor_box_cl[4] = 1
    end
end

function draw()
    --DRAIMS top section--
    --pages
    if get(DRAIMS_current_page) == 1 then--vhf page
        --vhf 1
        sasl.gl.drawText(A320_panel_font_MONO, 240, 332, Aft_string_fill(tostring(get(VHF_1_freq_Mhz)) .. "." .. tostring(get(VHF_1_freq_khz)), "0", 7), 68, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
        --indicate if the freqency is an emer frqency
        if Aft_string_fill(tostring(get(VHF_1_freq_Mhz)) .. "." .. tostring(get(VHF_1_freq_khz)), "0", 7) == "121.500" then
            sasl.gl.drawText(A320_panel_font, 125, 308, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        end
        if get(DRAIMS_cursor_pos) ~= 1 then
            sasl.gl.drawText(A320_panel_font_MONO, 380, 344, Aft_string_fill(tostring(get(VHF_1_stby_freq_Mhz)) .. "." .. tostring(get(VHF_1_stby_freq_khz)), "0", 7), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
            --indicate if the freqency is an emer frqency
            if Aft_string_fill(tostring(get(VHF_1_stby_freq_Mhz)) .. "." .. tostring(get(VHF_1_stby_freq_khz)), "0", 7) == "121.500" then
                sasl.gl.drawText(A320_panel_font, 465, 315, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            end
        end

        --vhf 2
        sasl.gl.drawText(A320_panel_font_MONO, 240, 232, Aft_string_fill(tostring(get(VHF_2_freq_Mhz)) .. "." .. tostring(get(VHF_2_freq_khz)), "0", 7), 68, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)
        --indicate if the freqency is an emer frqency
        if Aft_string_fill(tostring(get(VHF_2_freq_Mhz)) .. "." .. tostring(get(VHF_2_freq_khz)), "0", 7) == "121.500" then
            sasl.gl.drawText(A320_panel_font, 125, 208, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
        end
        if get(DRAIMS_cursor_pos) ~= 2 then
            sasl.gl.drawText(A320_panel_font_MONO, 380, 244, Aft_string_fill(tostring(get(VHF_2_stby_freq_Mhz)) .. "." .. tostring(get(VHF_2_stby_freq_khz)), "0", 7), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
            --indicate if the freqency is an emer frqency
            if Aft_string_fill(tostring(get(VHF_2_stby_freq_Mhz)) .. "." .. tostring(get(VHF_2_stby_freq_khz)), "0", 7) == "121.500" then
                sasl.gl.drawText(A320_panel_font, 465, 215, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            end
        end

        --vhf 3
        sasl.gl.drawText(A320_panel_font, 180, 132, "DATA", 68, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)

        --VHF cursor--
        if get(DRAIMS_cursor_pos) == 1 then--cursor on the first row of stby freq
            --cursor movement indicator
            --sasl.gl.drawTriangle(362, 370, 370, 388, 378, 370, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 330, 370, 360, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 330, 370, 312, 378, 330, DRAIMS_WHITE)

            --the cursor frequency
            sasl.gl.drawText(A320_panel_font_MONO, 380, 344, Aft_string_fill(tostring(get(VHF_1_stby_freq_Mhz)) .. "." .. tostring(get(VHF_1_stby_freq_khz)), "0", 7), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
            sasl.gl.drawText(A320_panel_font_MONO, 380, 315, Aft_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)) .. "." .. tostring(get(DRAIMS_cursor_freq_khz)), "0", 7), 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
            sasl.gl.drawText(A320_panel_font, 550, 315, "SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 392, 575, 392, 3, cursor_box_cl)
            sasl.gl.drawWideLine(354, 309, 354, 390, 3, cursor_box_cl)
            sasl.gl.drawWideLine(577, 309, 577, 390, 3, cursor_box_cl)
            sasl.gl.drawWideLine(355, 308, 575, 308, 3, cursor_box_cl)
            sasl.gl.drawArc ( 355, 390, 0, 3, 90, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 390, 0, 3, 0, 90, cursor_box_cl)
            sasl.gl.drawArc ( 355, 309, 0, 3, 180, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 309, 0, 3, 270, 90, cursor_box_cl)
        elseif get(DRAIMS_cursor_pos) == 2 then--cursor on the second row of stby freq
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 270, 370, 288, 378, 270, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 230, 370, 270, 4, DRAIMS_WHITE)
            sasl.gl.drawTriangle(362, 230, 370, 212, 378, 230, DRAIMS_WHITE)

            --the cursor frequency
            sasl.gl.drawText(A320_panel_font_MONO, 380, 244, Aft_string_fill(tostring(get(VHF_2_stby_freq_Mhz)) .. "." .. tostring(get(VHF_2_stby_freq_khz)), "0", 7), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
            sasl.gl.drawText(A320_panel_font_MONO, 380, 215, Aft_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)) .. "." .. tostring(get(DRAIMS_cursor_freq_khz)), "0", 7), 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
            sasl.gl.drawText(A320_panel_font, 550, 215, "SWAP", 28, false, false, TEXT_ALIGN_RIGHT, DRAIMS_WHITE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 292, 575, 292, 3, cursor_box_cl)
            sasl.gl.drawWideLine(354, 209, 354, 290, 3, cursor_box_cl)
            sasl.gl.drawWideLine(577, 209, 577, 290, 3, cursor_box_cl)
            sasl.gl.drawWideLine(355, 208, 575, 208, 3, cursor_box_cl)
            sasl.gl.drawArc ( 355, 290, 0, 3, 90, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 290, 0, 3, 0, 90, cursor_box_cl)
            sasl.gl.drawArc ( 355, 209, 0, 3, 180, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 209, 0, 3, 270, 90, cursor_box_cl)
        elseif get(DRAIMS_cursor_pos) == 3 then--cursor on the thrid row of stby freq(default inactive)
            --cursor movement indicator
            sasl.gl.drawTriangle(362, 170, 370, 188, 378, 170, DRAIMS_WHITE)
            sasl.gl.drawWideLine(370, 140, 370, 170, 4, DRAIMS_WHITE)
            --sasl.gl.drawTriangle(362, 130, 370, 112, 378, 130, DRAIMS_WHITE)

            --the cursor frequency
            sasl.gl.drawText(A320_panel_font_MONO, 380, 144, Aft_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)) .. "." .. tostring(get(DRAIMS_cursor_freq_khz)), "0", 7), 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_BLUE)
            --indicate if the freqency is an emer frqency
            if Aft_string_fill(tostring(get(DRAIMS_cursor_freq_Mhz)) .. "." .. tostring(get(DRAIMS_cursor_freq_khz)), "0", 7) == "121.500" then
                sasl.gl.drawText(A320_panel_font, 465, 115, "EMER", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
            end

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 192, 575, 192, 3, cursor_box_cl)
            sasl.gl.drawWideLine(354, 109, 354, 190, 3, cursor_box_cl)
            sasl.gl.drawWideLine(577, 109, 577, 190, 3, cursor_box_cl)
            sasl.gl.drawWideLine(355, 108, 575, 108, 3, cursor_box_cl)
            sasl.gl.drawArc ( 355, 190, 0, 3, 90, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 190, 0, 3, 0, 90, cursor_box_cl)
            sasl.gl.drawArc ( 355, 109, 0, 3, 180, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 109, 0, 3, 270, 90, cursor_box_cl)
        end

        --draw cursor in use indication
        if get(DRAIMS_cursor_pos) ~= 3 then
            sasl.gl.drawText(A320_panel_font, 465, 115, "IN USE", 28, false, false, TEXT_ALIGN_CENTER, DRAIMS_BLUE)

            --cursor box moved by the up and down arrows
            sasl.gl.drawWideLine(355, 192, 575, 192, 3, cursor_box_cl)
            sasl.gl.drawWideLine(354, 109, 354, 190, 3, cursor_box_cl)
            sasl.gl.drawWideLine(577, 109, 577, 190, 3, cursor_box_cl)
            sasl.gl.drawWideLine(355, 108, 575, 108, 3, cursor_box_cl)
            sasl.gl.drawArc ( 355, 190, 0, 3, 90, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 190, 0, 3, 0, 90, cursor_box_cl)
            sasl.gl.drawArc ( 355, 109, 0, 3, 180, 90, cursor_box_cl)
            sasl.gl.drawArc ( 575, 109, 0, 3, 270, 90, cursor_box_cl)
        end

    elseif get(DRAIMS_current_page) == 2 then--hf page

    elseif get(DRAIMS_current_page) == 6 then--nav page

    elseif get(DRAIMS_current_page) == 7 then--ils page

    elseif get(DRAIMS_current_page) == 8 then--vor page

    elseif get(DRAIMS_current_page) == 9 then--adf page

    end


    --DRAIMS bottom section--
    -----------------------------------------------------------------------------------------------------------------------
    --DRAIMS scratchpad
    if get(DRAIMS_format_error) == 0 then
        sasl.gl.drawText(A320_panel_font_MONO, 509, 30, DRAIMS_entry, 45, false, false, TEXT_ALIGN_CENTER, DRAIMS_WHITE)
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
        sasl.gl.drawText(A320_panel_font, 425, 48, "xxx.>x<xx MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 484, 26, "^", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "MUST BE ODD", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 5 then--VOR out of range
        sasl.gl.drawText(A320_panel_font, 425, 70, "VOR RANGE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "108.000 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "TO", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "117.950 MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 6 then--VOR freq spacing error
        sasl.gl.drawText(A320_panel_font, 425, 70, "VOR FREQ SP", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "xxx.>xxx< MHZ", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 484, 26, "^^^", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "000 OR 500", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
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
        sasl.gl.drawText(A320_panel_font, 425, 70, "CURSOR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "CURRENTLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "IN", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "USE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    elseif get(DRAIMS_format_error) == 11 then--cursor in use
        sasl.gl.drawText(A320_panel_font, 425, 70, "FMT ERR", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 48, "ONLY", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 26, "ONE", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
        sasl.gl.drawText(A320_panel_font, 425, 4, "DECIMAL DOT", 28, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
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