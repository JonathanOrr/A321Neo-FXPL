Output1_array = {}
Timeline1_array = {}

Output2_array = {}
Timeline2_array = {}

Graph1_timeline_sum = 0
Graph1_x_offset_sum = 0

Graph2_timeline_sum = 0
Graph2_x_offset_sum = 0

function Update_pid_graph_module_960x340(x_pos, y_pos)
    local CENTER_X = (2 * x_pos + 960) / 2
    local CENTER_Y = (2 * y_pos + 340) / 2
    local end_x = x_pos + 960
    local end_y = y_pos + 340

    Graph1_x_offset_sum = 0
    Graph2_x_offset_sum = 0

    --graph 1--
    if #Timeline1_array > 550 then
        for i = 1, #Timeline1_array do
            Timeline1_array[i] = Timeline1_array[i+1]
            Output1_array[i] = Output1_array[i+1]
        end
    end

    Output1_array[#Output1_array+1] = Math_clamp(SSS_FBW_roll_rate.Proportional / SSS_FBW_roll_rate.Max_error, -1,1) * 150
    Timeline1_array[#Timeline1_array+1] = get(DELTA_TIME) * 80

    for i = 1, #Timeline1_array do
        Graph1_x_offset_sum = Graph1_x_offset_sum + Timeline1_array[i]
    end

    --graph 2--
    if #Timeline2_array > 550 then
        for i = 1, #Timeline2_array do
            Timeline2_array[i] = Timeline2_array[i+1]
            Output2_array[i] = Output2_array[i+1]
        end
    end

    Output2_array[#Output2_array+1] = Math_clamp(SSS_FBW_roll_rate.Derivative / SSS_FBW_roll_rate.Max_error, -1, 1) * 150
    Timeline2_array[#Timeline2_array+1] = get(DELTA_TIME) * 80

    for i = 1, #Timeline2_array do
        Graph2_x_offset_sum = Graph2_x_offset_sum + Timeline2_array[i]
    end
end

function Draw_pid_graph_module_960x340(x_pos, y_pos)
    local CENTER_X = (2 * x_pos + 960) / 2
    local CENTER_Y = (2 * y_pos + 340) / 2
    local end_x = x_pos + 960
    local end_y = y_pos + 340

    sasl.gl.drawRectangle(x_pos,y_pos, 960, 340, DARK_GREY)
    sasl.gl.drawLine(0, CENTER_Y+150, end_x, CENTER_Y+150, RED)
    sasl.gl.drawLine(0, CENTER_Y-150, end_x, CENTER_Y-150, RED)
    sasl.gl.drawLine(0, CENTER_Y, end_x, CENTER_Y, ORANGE)

    Graph1_timeline_sum = 0
    Graph2_timeline_sum = 0

    for i = 1 ,#Timeline1_array do
        Graph1_timeline_sum = Graph1_timeline_sum + Timeline1_array[i]

        if i > 1 then

            sasl.gl.drawLine(CENTER_X + Graph1_timeline_sum - Timeline1_array[i] - Graph1_x_offset_sum, CENTER_Y + Output1_array[i-1], CENTER_X + Graph1_timeline_sum - Graph1_x_offset_sum, CENTER_Y + Output1_array[i], WHITE)

        end
    end

    for i = 1 ,#Timeline2_array do
        Graph2_timeline_sum = Graph2_timeline_sum + Timeline2_array[i]

        if i > 1 then

            sasl.gl.drawLine(CENTER_X + Graph2_timeline_sum - Timeline2_array[i] - Graph2_x_offset_sum, CENTER_Y + Output2_array[i-1], CENTER_X + Graph2_timeline_sum - Graph2_x_offset_sum, CENTER_Y + Output2_array[i], LIGHT_BLUE)

        end

    end
end