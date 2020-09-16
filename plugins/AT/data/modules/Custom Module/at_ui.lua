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

--buttons
components = {
    at_button {},
    adjustment_button {}
}

size = { 340 , 420 }

--variables
local target_speed
local p_gain
local i_gain
local d_gain
local integral_sum
local integral
local integral_time
local max_integral
local max_error

--colors
local WHITE = {1.0, 1.0, 1.0}
local LIGHT_BLUE = {0, 0.708, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

--fonts
local B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612_bold = sasl.gl.loadFont("fonts/B612-Bold.ttf")
local B612_MONO_regular = sasl.gl.loadFont("fonts/B612MONO-Regular.ttf")
local B612_MONO_bold = sasl.gl.loadFont("fonts/B612MONO-Bold.ttf")

function update()
    target_speed = get(A32nx_target_spd)
    p_gain = A32nx_auto_thrust.P_gain
    i_gain = A32nx_auto_thrust.I_gain
    d_gain = A32nx_auto_thrust.D_gain
    integral_time = A32nx_auto_thrust.I_time
    max_integral = A32nx_auto_thrust.Integral_max
    integral_sum = A32nx_auto_thrust.Integral_sum
    integral = A32nx_auto_thrust.Integral
    max_error = A32nx_auto_thrust.Max_error

    updateAll(components)
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)
    sasl.gl.drawRectangle(5, 5, size[1] - 10, size[2] - 10, DARK_GREY)

    --printing the title
    sasl.gl.drawText(B612_MONO_bold, size[1]/2, size[2]/2 + 180, "A32NX OPEN-SOURCE ADAPTIVE A/T", 15, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)

    --printing the variables
    --target airspeed--
    sasl.gl.drawText(B612_MONO_regular, size[1]/2, size[2]/2 + 150, "TARGET AIRSPEED", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold,    size[1]/2, size[2]/2 + 110, target_speed, 40, false, false, TEXT_ALIGN_CENTER, WHITE)

    --pid gains--
    sasl.gl.drawText(B612_MONO_regular, size[1]/6,       size[2]/2 + 85, "P GAIN", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/6,       size[2]/2 + 55, p_gain,   20, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2,       size[2]/2 + 85, "I GAIN", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2,       size[2]/2 + 55, i_gain,   20, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6, size[2]/2 + 85, "D GAIN", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6, size[2]/2 + 55, d_gain,   20, false, false, TEXT_ALIGN_CENTER, WHITE)

    --min max range--
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6,   size[2]/2 + 25, "ERROR RANGE", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6,   size[2]/2 - 5,  max_error,     28, false, false, TEXT_ALIGN_CENTER, WHITE)

    --integral info--
    sasl.gl.drawText(B612_MONO_regular, size[1]/6,       size[2]/2 + 25, "I TIME",                                         12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/6,       size[2]/2 - 5,  integral_time,                                           28, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2,       size[2]/2 + 25, "I RANGE",                                        12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2,       size[2]/2 - 5,  max_integral,                                            28, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/4,       size[2]/2 - 35, "INTEGRAL SUM",                                          12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/4,       size[2]/2 - 65, string.format("%.2f", tostring(Round(integral_sum, 2))), 28, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, 3* size[1]/4,    size[2]/2 - 35, "INTEGRAL",                                              12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, 3* size[1]/4,    size[2]/2 - 65, string.format("%.2f", tostring(Round(integral, 2))),     28, false, false, TEXT_ALIGN_CENTER, WHITE)

    --printing the output
    sasl.gl.drawText(B612_MONO_regular, size[1]/2,       size[2]/2 - 95, "THROTTLE RATIO OUTPUT",                                            12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold,    size[1]/2,       size[2]/2 - 125, string.format("%.4f", tostring(get(A32nx_thrust_control_output))), 28, false, false, TEXT_ALIGN_CENTER, WHITE)

    --draw subcomponents
    drawAll(components)
end