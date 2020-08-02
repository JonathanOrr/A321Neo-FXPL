position= {2279,499,900,900}
size = {900, 900}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local ECAM_WHITE = {1.0, 1.0, 1.0}
local ECAM_BLUE = {0.004, 1.0, 1.0}
local ECAM_GREEN = {0.184, 0.733, 0.219}
local ECAM_ORANGE = {0.725, 0.521, 0.18}
local ECAM_RED = {1.0, 0.0, 0.0}
local ECAM_MAGENTA = {1.0, 0.0, 1.0}
local ECAM_GREY = {0.3, 0.3, 0.3}

local match_msg_colors = {}
match_msg_colors[0] = ECAM_WHITE
match_msg_colors[1] = ECAM_RED
match_msg_colors[2] = ECAM_ORANGE
match_msg_colors[3] = ECAM_GREEN
match_msg_colors[4] = ECAM_WHITE
match_msg_colors[5] = ECAM_BLUE
match_msg_colors[6] = ECAM_MAGENTA

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
        if get(EWD_left_memo_colors[i]) > 0 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2-430, size[2]/2-200-distance*i, get(EWD_left_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_left_memo_colors[i])])
        end
    end

end

local function draw_right_memo()
    local distance = 38

    for i=0,6 do
        if get(EWD_right_memo_colors[i]) > 0 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2+150, size[2]/2-200-distance*i, get(EWD_right_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_right_memo_colors[i])])
        end
    end
end

function draw()
    draw_engines()
    draw_left_memo()
    draw_right_memo()
end

