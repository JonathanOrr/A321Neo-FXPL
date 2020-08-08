position= {2279,539,900,900}
size = {900, 900}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local ECAM_WHITE = {1.0, 1.0, 1.0}
local ECAM_HIGH_GREY = {0.6, 0.6, 0.6}
local ECAM_BLUE = {0.004, 1.0, 1.0}
local ECAM_GREEN = {0.184, 0.733, 0.219}
local ECAM_ORANGE = {0.725, 0.521, 0.18}
local ECAM_RED = {1.0, 0.0, 0.0}
local ECAM_MAGENTA = {1.0, 0.0, 1.0}
local ECAM_GREY = {0.3, 0.3, 0.3}

local match_msg_colors = {}
match_msg_colors[0] = ECAM_WHITE
match_msg_colors[1] = ECAM_RED
match_msg_colors[2] = ECAM_MAGENTA
match_msg_colors[3] = ECAM_ORANGE
match_msg_colors[4] = ECAM_GREEN
match_msg_colors[5] = ECAM_WHITE
match_msg_colors[6] = ECAM_BLUE

local time_blinking = sasl.createTimer()
sasl.startTimer(time_blinking)

function update()
    set(Eng_1_FF_kgm, get(Eng_1_FF_kgs) * 3600)
    set(Eng_2_FF_kgm, get(Eng_2_FF_kgs) * 3600)
end

local function draw_engines()
    --N1--
    sasl.gl.drawText(B612regular, size[1]/2-100, size[2]/2+280, Round(get(Eng_1_N1), 1), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612regular, size[1]/2+250, size[2]/2+280, Round(get(Eng_2_N1), 1), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    --EGT--
    sasl.gl.drawText(B612regular, size[1]/2-174, size[2]/2+149, math.floor(get(Eng_1_EGT_c)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(B612regular, size[1]/2+174, size[2]/2+149, math.floor(get(Eng_2_EGT_c)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    --N2--
    if get(Engine_mode_knob) == 1 or get(Engine_mode_knob) == -1 then
        sasl.gl.drawRectangle(size[1]/2-205, size[2]/2+70, 65, 32, ECAM_GREY)
        sasl.gl.drawRectangle(size[1]/2+135, size[2]/2+70, 65, 32, ECAM_GREY)
    end
    sasl.gl.drawText(B612regular, size[1]/2-150, size[2]/2+75, math.floor(get(Eng_1_N2)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612regular, size[1]/2+150, size[2]/2+75, math.floor(get(Eng_2_N2)), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    --FF--
    sasl.gl.drawText(B612regular, size[1]/2-150, size[2]/2+3, math.floor(get(Eng_1_FF_kgm)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612regular, size[1]/2+150, size[2]/2+3, math.floor(get(Eng_2_FF_kgm)), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)

end

local function draw_left_memo()
    local distance = 38

    for i=0,6 do
        if get(EWD_left_memo_group_colors[i]) > 0 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2-430, size[2]/2-200-distance*i, get(EWD_left_memo_group[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_left_memo_group_colors[i])])
            
            -- Print the underline
            width, height = sasl.gl.measureText(B612MONO_regular, get(EWD_left_memo_group[i]), 30, false, false)
            sasl.gl.drawWideLine(size[1]/2-430 + 3, size[2]/2-200-distance*i - 5, size[1]/2-430 + width + 3, size[2]/2-200-distance*i - 5, 5, match_msg_colors[get(EWD_left_memo_group_colors[i])])
        end

        if get(EWD_left_memo_colors[i]) > 0 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2-430, size[2]/2-200-distance*i, get(EWD_left_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_left_memo_colors[i])])
        end
    end

end

local function draw_right_memo()
    local distance = 38

    for i=0,6 do
        if get(EWD_right_memo_colors[i]) > 0 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2+140, size[2]/2-200-distance*i, get(EWD_right_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_right_memo_colors[i])])
        end
    end
end

local function draw_extras()

    -- STS BOX
    if get(EWD_box_sts) == 1 then
        sasl.gl.drawText(B612MONO_regular, size[1]/2+88, size[2]/2-445, "STS", 30, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-447, 62, 28 , ECAM_WHITE)
    end 

    -- ADV BOX
    if get(EWD_box_adv) == 1 then
        local color = ECAM_WHITE
        
        -- Blinking the ADV box with a period of 2 seconds (1 second WHITE, 1 second gray)
        if math.floor(sasl.getElapsedSeconds(time_blinking)) % 2 == 0 then
            color = ECAM_HIGH_GREY
        end
        sasl.gl.drawText(B612MONO_regular, size[1]/2+88, size[2]/2-165, "ADV", 30, false, false, TEXT_ALIGN_LEFT, color)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-167, 62, 28 , color)
    end 
    
    -- overflow arrow (this is not visible if STS box is visible)
    if get(EWD_box_sts) == 0 and get(EWD_arrow_overflow) == 1 then
        sasl.gl.drawWideLine ( size[1]/2+118, size[2]/2-410 , size[1]/2+118 , size[2]/2-425 , 5 , ECAM_GREEN )
        sasl.gl.drawTriangle ( size[1]/2+106, size[2]/2-425 , size[1]/2+119 , size[2]/2-446 , size[1]/2+130, size[2]/2-425 , ECAM_GREEN )
    end 
end

function draw()
    draw_engines()
    draw_left_memo()
    draw_right_memo()
    draw_extras()
end

