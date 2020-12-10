include('constants.lua')
include('EWD.lua')

position = {0, 0, 900, 900}
size = {900, 900}

function EWD_pop_out_command(phase)
    if phase == SASL_COMMAND_BEGIN then
        EWD_popup_window:setIsVisible(not EWD_popup_window:isVisible())
    end
end

sasl.registerCommandHandler(Pop_out_EWD, 1, EWD_pop_out_command)

--set default size
local window_x
local window_y
local window_width
local window_height

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local last_params_update = 0

local params = {
    eng1_n1 = 0,
    eng2_n1 = 0,
    eng1_n2 = 0,
    eng2_n2 = 0,
    eng1_egt = 0,
    eng2_egt = 0,
    eng1_ff = 0,
    eng2_ff = 0,
    last_update = 0
}

local eng_idle_start = 0  -- When the engines went to IDLE

local match_msg_colors = {}
match_msg_colors[0] = ECAM_WHITE
match_msg_colors[1] = ECAM_RED
match_msg_colors[2] = ECAM_MAGENTA
match_msg_colors[3] = ECAM_ORANGE
match_msg_colors[4] = ECAM_GREEN
match_msg_colors[5] = ECAM_WHITE
match_msg_colors[6] = ECAM_BLUE
match_msg_colors[7] = ECAM_GREEN -- Blinking

local time_blinking = sasl.createTimer()
sasl.startTimer(time_blinking)

local function popup_Draw_engines()

    -- N2 background box --
    if get(Engine_1_master_switch) == 1 and get(Engine_1_avail) == 0 then
          sasl.gl.drawRectangle(size[1]/2-210, size[2]/2+70, 85, 32, {0.2,0.2,0.2})
    end
    if get(Engine_2_master_switch) == 1 and get(Engine_2_avail) == 0 then
          sasl.gl.drawRectangle(size[1]/2+115, size[2]/2+70, 85, 32, {0.2,0.2,0.2})
    end

    if get(EWD_engine_1_XX) == 0 then
        --N1-- -- TODO COLORS
        Draw_LCD_backlight(size[1]/2 - 195, size[2]/2 + 275, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 - 195, size[2]/2 + 275, 100, 35, 2, 0, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-115, size[2]/2+280, math.floor(params.eng1_n1) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-100, size[2]/2+280, math.floor((params.eng1_n1%1)*10)  , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

        --EGT--
        local egt_color_1 = params.eng1_egt > 1050 and ECAM_RED or (params.eng1_egt > 1000 and ECAM_ORANGE or ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-140, size[2]/2+150, params.eng1_egt, 28, false, false, TEXT_ALIGN_RIGHT, egt_color_1)

        --N2--
        local n2_color_1 = params.eng1_n2 > 117 and ECAM_RED or ECAM_GREEN
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-145, size[2]/2+75, math.floor(params.eng1_n2) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, n2_color_1)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-130, size[2]/2+75, math.floor((params.eng1_n2%1)*10) , 24, false, false, TEXT_ALIGN_RIGHT, n2_color_1)

        --FF--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-130, size[2]/2+3, params.eng1_ff, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end

    if get(EWD_engine_2_XX) == 0 then
        --N1-- -- TODO COLORS
        Draw_LCD_backlight(size[1]/2 + 155, size[2]/2 + 275, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 + 155, size[2]/2 + 275, 100, 35, 2, 0, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, size[2]/2+280, math.floor(params.eng2_n1) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2+280, math.floor((params.eng2_n1%1)*10)  , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

        --EGT--
        local egt_color_2 = params.eng2_egt > 1050 and ECAM_RED or (params.eng2_egt > 1000 and ECAM_ORANGE or ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+210, size[2]/2+150, params.eng2_egt, 28, false, false, TEXT_ALIGN_RIGHT, egt_color_2)

        --N2--
        local n2_color_2 = params.eng2_n2 > 117 and ECAM_RED or ECAM_GREEN
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+180, size[2]/2+75, math.floor(params.eng2_n2) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, n2_color_2)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+195, size[2]/2+75, math.floor((params.eng2_n2%1)*10) , 24, false, false, TEXT_ALIGN_RIGHT, n2_color_2)

        --FF--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+195, size[2]/2+3, params.eng2_ff, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end


    -- AVAIL box --
    if get(EWD_engine_avail_ind_1_start) ~= 0 and get(TIME) - get(EWD_engine_avail_ind_1_start) < 10 then
        Draw_LCD_backlight(size[1]/2 - 195, size[2]/2 + 310, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 - 195, size[2]/2 + 310, 100, 35, 2, 0, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - 142, size[2]/2 + 315, "AVAIL", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    if get(EWD_engine_avail_ind_2_start) ~= 0 and get(TIME) - get(EWD_engine_avail_ind_2_start) < 10 then
        Draw_LCD_backlight(size[1]/2 + 155, size[2]/2 + 310, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 + 155, size[2]/2 + 310, 100, 35, 2, 0, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + 208, size[2]/2 + 315, "AVAIL", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    -- IDLE indication
    if eng_idle_start ~= 0 then
        color = ECAM_GREEN
        if get(TIME) - eng_idle_start < 10 then
            if (math.floor(get(TIME)*2)) % 2 == 1 then -- Blinking
                color = ECAM_HIGH_GREEN
            end
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+380, "IDLE" , 30, false, false, TEXT_ALIGN_CENTER, color)        
    end
end

function update()
    --proportionally resize the window
    if EWD_popup_window:isVisible() then
        window_x, window_y, window_width, window_height = EWD_popup_window:getPosition()
        EWD_popup_window:setPosition ( window_x , window_y , window_width, window_width)
    end

    -- Update the parameter every PARAM_DELAY seconds
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_n1 = get(Eng_1_N1)
        params.eng2_n1 = get(Eng_2_N1)
        params.eng1_n2 = get(Eng_1_N2)
        params.eng2_n2 = get(Eng_2_N2)
        if params.eng1_n1 < 5 then params.eng1_n1 = 0 end
        if params.eng2_n1 < 5 then params.eng2_n1 = 0 end

        params.eng1_egt = math.floor(get(Eng_1_EGT_c))
        params.eng2_egt = math.floor(get(Eng_2_EGT_c))

        params.eng1_ff = math.floor(get(Eng_1_FF_kgs)*360)*10
        params.eng2_ff = math.floor(get(Eng_2_FF_kgs)*360)*10


        params.last_update = get(TIME)
    end

    if params.eng1_n1 < get(Eng_N1_idle) + 2 and params.eng2_n1 < get(Eng_N1_idle) + 2 and get(Any_wheel_on_ground) == 0 then
        if eng_idle_start == 0 then
            eng_idle_start = get(TIME)
        end
    else
        eng_idle_start = 0
    end
end

function draw()
    if display_special_mode(size, EWD_valid) then
        sasl.gl.drawRectangle(0, 0, 900, 900, {0, 0, 0, 1 - get(EWD_brightness_act)})
        return
    end

    Draw_LCD_backlight(0, 0, 900, 900, 0.5, 1, get(EWD_brightness_act))
    sasl.gl.drawTexture(EWD_background_img, 0, 0, 900, 900, {1, 1, 1})

    Draw_extra_indication()
    Draw_engines_needles()
    Draw_reverse_indication()
    popup_Draw_engines()
    Draw_left_memo()
    Draw_right_memo()
    Draw_extras()
    Draw_fuel_stuffs()
    Draw_coolings()
    Draw_slat_flap_indications()

    sasl.gl.drawRectangle(0, 0, 900, 900, {0,0,0, 1 - get(EWD_brightness_act)})
end