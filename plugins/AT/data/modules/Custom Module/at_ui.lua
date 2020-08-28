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
local i_delay
local integral
local min_error
local max_error
local error_offset

--colors
local black = {0,0,0}
local white = {1,1,1}
local green = {0.004, 1, 0.004}
local blue = {0.004, 1.0, 1.0}
local orange = {0.843, 0.49, 0}
local red = {1, 0, 0}

--fonts
local B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612_bold = sasl.gl.loadFont("fonts/B612-Bold.ttf")



function update()
    target_speed = get(A32nx_target_spd)
    p_gain = A32nx_auto_thrust.P_gain
    i_gain = A32nx_auto_thrust.I_gain
    d_gain = A32nx_auto_thrust.D_gain
    i_delay = A32nx_auto_thrust.I_delay
    integral = A32nx_auto_thrust.Integral
    min_error = A32nx_auto_thrust.Min_error
    max_error = A32nx_auto_thrust.Max_error
    error_offset = A32nx_auto_thrust.Error_offset

    updateAll(components)
end

function draw()
    sasl.gl.drawRectangle(0, 0, 340 , 420, black)
    
    --printing the title
    sasl.gl.drawText(B612_bold, size[1]/2, size[2]/2 + 180, "THE A32NX OPEN-SOURCE ADAPTIVE A/T", 15, false, false, TEXT_ALIGN_CENTER, blue)

    --printing the variables
    --target airspeed--
    sasl.gl.drawText(B612_regular, size[1]/2, size[2]/2 + 150, "TARGET AIRSPEED", 12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_bold,    size[1]/2, size[2]/2 + 110, target_speed, 40, false, false, TEXT_ALIGN_CENTER, white)
    
    --pid gains--
    sasl.gl.drawText(B612_regular, size[1]/2 - 110, size[2]/2 + 85, "P GAIN", 12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_regular, size[1]/2 - 110, size[2]/2 + 55, p_gain,   20, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawText(B612_regular, size[1]/2,       size[2]/2 + 85, "I GAIN", 12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_regular, size[1]/2,       size[2]/2 + 55, i_gain,   20, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawText(B612_regular, size[1]/2 + 110, size[2]/2 + 85, "D GAIN", 12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_regular, size[1]/2 + 110, size[2]/2 + 55, d_gain,   20, false, false, TEXT_ALIGN_CENTER, white)

    --min max range--
    sasl.gl.drawText(B612_regular, size[1]/2,       size[2]/2 + 25, "ERROR RANGE",  12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_regular, size[1]/2,       size[2]/2 - 5, max_error,       28, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawText(B612_regular, size[1]/2 + 110, size[2]/2 + 25, "ERROR OFFSET", 12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_regular, size[1]/2 + 110, size[2]/2 - 5, error_offset,    28, false, false, TEXT_ALIGN_CENTER, white)

    --integral info--
    sasl.gl.drawText(B612_regular, size[1]/2 - 110, size[2]/2 + 25, "INTEGRAL DELAY", 12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_regular, size[1]/2 - 110, size[2]/2 - 5, i_delay,           28, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawText(B612_regular, size[1]/2,       size[2]/2 - 35, "INTEGRAL",       12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_regular, size[1]/2,       size[2]/2 - 65, integral,         28, false, false, TEXT_ALIGN_CENTER, white)

    --printing the output
    sasl.gl.drawText(B612_regular, size[1]/2,       size[2]/2 - 95, "THROTTLE RATIO OUTPUT", 12, false, false, TEXT_ALIGN_CENTER, blue)
    sasl.gl.drawText(B612_bold,    size[1]/2,       size[2]/2 - 125, get(A32nx_thrust_control_output), 28, false, false, TEXT_ALIGN_CENTER, white)

    --draw subcomponents
    drawAll(components)
end