--[[A32NX Adaptive Auto Throttle
Copyright (C) 2020 Jonathan Orr

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.]]

size = {420,340}

local graph_timeline = 0
local past_graph_timeline = 0
local past_output = 0

--colors
local black = {0,0,0}
local white = {1,1,1}
local green = {0.004, 1, 0.004}
local blue = {0.004, 1.0, 1.0}
local orange = {0.725, 0.521, 0.18}
local red = {1, 0, 0}

local output1_array = {}
local timeline1_array = {}

local output2_array = {}
local timeline2_array = {}

local graph1_timeline_sum = 0
local graph1_x_offset_sum = 0

local graph2_timeline_sum = 0
local graph2_x_offset_sum = 0

function update()

    graph1_x_offset_sum = 0
    graph2_x_offset_sum = 0

    --graph 1--
    if #timeline1_array > 550 then
        for i = 1, #timeline1_array do
            timeline1_array[i] = timeline1_array[i+1]
            output1_array[i] = output1_array[i+1]
        end
    end

    output1_array[#output1_array+1] = size[2]/2 + get(A32nx_thrust_control_output)*150
    timeline1_array[#timeline1_array+1] = get(DELTA_TIME)*30

    for i = 1, #timeline1_array do
        graph1_x_offset_sum = graph1_x_offset_sum + timeline1_array[i]
    end

    --graph 2--
    if #timeline2_array > 550 then
        for i = 1, #timeline2_array do
            timeline2_array[i] = timeline2_array[i+1]
            output2_array[i] = output2_array[i+1]
        end
    end

    output2_array[#output2_array+1] = size[2]/2 + D_value *150
    timeline2_array[#timeline2_array+1] = get(DELTA_TIME)*30

    for i = 1, #timeline2_array do
        graph2_x_offset_sum = graph2_x_offset_sum + timeline2_array[i]
    end

end

function draw()
    sasl.gl.drawRectangle(0,0,420,340,black)
    sasl.gl.drawLine(0, size[2]/2+150, size[1], size[2]/2+150, red)
    sasl.gl.drawLine(0, size[2]/2-150, size[1], size[2]/2-150, red)
    sasl.gl.drawLine(0, size[2]/2, size[1], size[2]/2, orange)

    graph1_timeline_sum = 0
    graph2_timeline_sum = 0

    for i = 1 ,#timeline1_array do
        graph1_timeline_sum = graph1_timeline_sum + timeline1_array[i]

        if i > 1 then

            sasl.gl.drawLine(size[1]/2+graph1_timeline_sum-timeline1_array[i]-graph1_x_offset_sum, output1_array[i-1], size[1]/2+graph1_timeline_sum-graph1_x_offset_sum, output1_array[i], white)

        end
    end

    for i = 1 ,#timeline2_array do
        graph2_timeline_sum = graph2_timeline_sum + timeline2_array[i]

        if i > 1 then

            sasl.gl.drawLine(size[1]/2+graph2_timeline_sum-timeline2_array[i]-graph2_x_offset_sum, output2_array[i-1], size[1]/2+graph2_timeline_sum-graph2_x_offset_sum, output2_array[i], blue)

        end

    end
end