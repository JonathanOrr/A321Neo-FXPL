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
local black = {0,0,0}
local white = {1,1,1}
local green = {0.004, 1, 0.004}
local blue = {0.004, 1.0, 1.0}
local orange = {0.843, 0.49, 0}
local red = {1, 0, 0}

--variables
local button_color = {}
button_color = red

local button_text = ""

function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        set(A32nx_autothrust_on, 1-get(A32nx_autothrust_on))
    end
end

function update()
    if get(A32nx_autothrust_on) == 1 then
        button_color = red
        button_text = "DISABLE"
    else
        button_color = white
        button_text = "ENABLE"
    end
end

function draw()
    sasl.gl.drawCircle(size[1]/2-70,  size[2]/2+10, 10, true, button_color)
    sasl.gl.drawCircle(size[1]/2+70,  size[2]/2+10, 10, true, button_color)
    sasl.gl.drawCircle(size[1]/2-70,  size[2]/2-10, 10, true, button_color)
    sasl.gl.drawCircle(size[1]/2+70,  size[2]/2-10, 10, true, button_color)
    sasl.gl.drawRectangle(0, 10, 160 , 20, button_color)
    sasl.gl.drawRectangle(10, 0, 140 , 40, button_color)
    sasl.gl.drawText(B612_MONO_bold, size[1]/2, size[2]/2-10, button_text, 25, false, false, TEXT_ALIGN_CENTER, black)
end