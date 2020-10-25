--size = {600, 260}

--colors
local RED = {1, 0, 0}
local ORANGE = {1, 0.55, 0.15}
local WHITE = {1.0, 1.0, 1.0}
local GREEN = {0.20, 0.98, 0.20}
local LIGHT_BLUE = {0, 0.708, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

--fonts
local B612_MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--GRAPH PROPERTIES--
local graph_time_limit = 5 --seconds across the x axis

P_array = {}
I_array = {}
D_array = {}
Sum_array = {}
DELTA_TIME_array = {}
DELTA_TIME_sum = 0
Graph_x_offset_sum = 0

function Clear_PID_history()
    for i = 1, #P_array do
        P_array[i] = P_array[i + 1]
    end
    for i = 1, #I_array do
        I_array[i] = I_array[i + 1]
    end
    for i = 1, #D_array do
        D_array[i] = D_array[i + 1]
    end
    for i = 1, #DELTA_TIME_array do
        DELTA_TIME_array[i] = DELTA_TIME_array[i + 1]
    end
end

function Update_PID_historys(x_pos, y_pos, width, height, PID_array)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    if get(DELTA_TIME) ~= 0 then

        DELTA_TIME_sum = 0

        for i = 1, #DELTA_TIME_array do
            DELTA_TIME_sum = DELTA_TIME_sum + DELTA_TIME_array[i]
        end

        if DELTA_TIME_sum < graph_time_limit then
            P_array[#P_array + 1] = Math_clamp(PID_array.Proportional, -PID_array.Error_margin, PID_array.Error_margin) / PID_array.Error_margin
            I_array[#I_array + 1] = Math_clamp(PID_array.Integral, -PID_array.Error_margin, PID_array.Error_margin) / PID_array.Error_margin
            D_array[#D_array + 1] = Math_clamp(PID_array.Derivative, -PID_array.Error_margin, PID_array.Error_margin) / PID_array.Error_margin
            Sum_array[#Sum_array + 1] = PID_array.Output
            DELTA_TIME_array[#DELTA_TIME_array + 1] = get(DELTA_TIME)
        end

        --larger than graph time limit clearing out all extra array items
        if DELTA_TIME_sum >= graph_time_limit then
            for i = 1, #DELTA_TIME_array do
            P_array[i] = P_array[i + 1]
            I_array[i] = I_array[i + 1]
            D_array[i] = D_array[i + 1]
            Sum_array[i] = Sum_array[i + 1]
            DELTA_TIME_array[i] = DELTA_TIME_array[i + 1]
            end
        end

    end
end

function Draw_PID_graph(x_pos, y_pos, width, height, P_color, I_color, D_color, Sum_color, show_P, show_I, show_D, show_Sum)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    sasl.gl.drawRectangle(x_pos, y_pos, width, height, DARK_GREY)
    sasl.gl.drawLine(x_pos, CENTER_Y, END_X, CENTER_Y, LIGHT_GREY)

    Graph_x_offset_sum = 0

    for i = 1 ,#DELTA_TIME_array do
        Graph_x_offset_sum = Graph_x_offset_sum + DELTA_TIME_array[i] / graph_time_limit * width

        if i > 1 then
            --draw all PID array lines
            if show_Sum == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + Sum_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + Sum_array[i] * height / 2, Sum_color)
            end
            if show_D == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + D_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + D_array[i] * height / 2, D_color)
            end
            if show_I == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + I_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + I_array[i] * height / 2, I_color)
            end
            if show_P == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + P_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + P_array[i] * height / 2, P_color)
            end
        end
    end
end

function Draw_list_of_PID_arrays(x, y, width, height_per_item, text_color, menu_color)
    local array_name_list = {}
    local menu_height = 0

    for i = 1, #AT_PID_arrays do
        array_name_list[#array_name_list + 1] = AT_PID_arrays[i].Name
    end
    for i = 1, #FBW_PID_arrays do
        array_name_list[#array_name_list + 1] = FBW_PID_arrays[i].Name
    end

    for i = 1, #array_name_list do
        menu_height = menu_height + height_per_item
    end

    local CENTER_X = (2 * x + width) / 2
    local CENTER_Y = (2 * y - menu_height) / 2
    local END_X = x + width
    local END_Y = y

    sasl.gl.drawRectangle(x, y - menu_height, width, menu_height, menu_color)

    local text_y_pos = y

    for i = 1, #array_name_list do
        sasl.gl.drawText(B612_MONO_regular, x + 15, text_y_pos, array_name_list[i], 12, false, false, TEXT_ALIGN_LEFT, text_color)

        text_y_pos = text_y_pos - height_per_item
    end
end

function update()
    if PID_UI_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHidePIDUI, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHidePIDUI, MENU_UNCHECKED)
    end

    Update_PID_historys(0 + 5, 0 + 5, 400, 250, FBW_PID_arrays.SSS_FBW_roll_rate)

    --print("P: " .. FBW_PID_arrays.SSS_FBW_roll_rate.Proportional)
    --print("D: " .. FBW_PID_arrays.SSS_FBW_roll_rate.Derivative)
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)

    Draw_PID_graph(0 + 5, 0 + 5, 400, 250, WHITE, LIGHT_BLUE, GREEN, ORANGE, true, true, true, true)
    --Draw_list_of_PID_arrays(500, 180, 80, 30, WHITE, LIGHT_BLUE)
end