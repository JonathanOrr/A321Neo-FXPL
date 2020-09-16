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

position = {90,25,160, 40}
size = {160, 40}

--fonts
local B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612_MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")

--colors

--colors
local WHITE = {1.0, 1.0, 1.0}
local RED = {1, 0, 0}
local LIGHT_BLUE = {0, 0.708, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

--variables
local button_color = {}
button_color = WHITE

local button_text = ""

function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        set(A32nx_autothrust_on, 1-get(A32nx_autothrust_on))
    end
end

function update()
    if get(A32nx_autothrust_on) == 1 then
        button_color = RED
        button_text = "DISABLE"
    else
        button_color = LIGHT_GREY
        button_text = "ENABLE"
    end
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], button_color)
    sasl.gl.drawText(B612_MONO_bold, size[1]/2, size[2]/2-10, button_text, 25, false, false, TEXT_ALIGN_CENTER, WHITE)
end