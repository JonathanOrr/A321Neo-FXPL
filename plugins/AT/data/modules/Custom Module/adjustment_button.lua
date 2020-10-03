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

position = {0,0,340,420}
size = {340, 420}

--fonts
local B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612_bold = sasl.gl.loadFont("fonts/B612-Bold.ttf")
local B612_MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612_MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")

--colors
local black = {0,0,0}
local white = {1,1,1}
local green = {0.004, 1, 0.004}
local blue = {0.004, 1.0, 1.0}
local orange = {0.843, 0.49, 0}
local red = {1, 0, 0}

--colors
local WHITE = {1.0, 1.0, 1.0}
local LIGHT_BLUE = {0, 0.708, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

--mouse click
function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        --button check--
        --target speed - --
        if x >= size[1]/2-80 and x <= size[1]/2-80+30 and y >= size[2]/2+110 and y <= size[2]/2+110+30 then
            set(A32nx_target_spd, get(A32nx_target_spd) - 1)
        end

        --target speed + --
        if x >= size[1]/2+50 and x <= size[1]/2+50+30 and y >= size[2]/2+110 and y <= size[2]/2+110+30 then
            set(A32nx_target_spd, get(A32nx_target_spd) + 1)
        end

        --p gain - --
        if x >= size[1]/6-50 and x <= size[1]/6-50+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.P_gain = A32nx_auto_thrust.P_gain - 0.1
        end

        --p gain + --
        if x >= size[1]/6+30 and x <= size[1]/6+30+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.P_gain = A32nx_auto_thrust.P_gain + 0.1
        end

        --i gain - --
        if x >= size[1]/2-50 and x <= size[1]/2-50+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.I_gain = A32nx_auto_thrust.I_gain - 0.1
        end

        --i gain + --
        if x >= size[1]/2+30 and x <= size[1]/2+30+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.I_gain = A32nx_auto_thrust.I_gain + 0.1
        end

        --d gain - --
        if x >= 5 * size[1]/6-50 and x <= 5 * size[1]/6-50+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.D_gain = A32nx_auto_thrust.D_gain - 0.1
        end

        --d gain + --
        if x >= 5 * size[1]/6+30 and x <= 5 * size[1]/6+30+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.D_gain = A32nx_auto_thrust.D_gain + 0.1
        end

        --i time - --
        if x >= size[1]/6-50 and x <= size[1]/6-50+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.I_time = A32nx_auto_thrust.I_time - 1
        end

        --i time + --
        if x >= size[1]/6+30 and x <= size[1]/6+30+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.I_time = A32nx_auto_thrust.I_time + 1
        end

        --max i - --
        if x >= size[1]/2-50 and x <= size[1]/2-50+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Integral_min = A32nx_auto_thrust.Integral_min + 1
            A32nx_auto_thrust.Integral_max = A32nx_auto_thrust.Integral_max - 1
        end

        --max i + --
        if x >= size[1]/2+30 and x <= size[1]/2+30+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Integral_min = A32nx_auto_thrust.Integral_min - 1
            A32nx_auto_thrust.Integral_max = A32nx_auto_thrust.Integral_max + 1
        end

        --max error - --
        if x >= 5 * size[1]/6-50 and x <= 5 * size[1]/6-50+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Min_error = A32nx_auto_thrust.Min_error + 1
            A32nx_auto_thrust.Max_error = A32nx_auto_thrust.Max_error - 1
        end

        --max error + --
        if x >= 5 * size[1]/6+30 and x <= 5 * size[1]/6+30+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Min_error = A32nx_auto_thrust.Min_error - 1
            A32nx_auto_thrust.Max_error = A32nx_auto_thrust.Max_error + 1
        end
    end
end

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    --scrolling target speed
    if x >= size[1]/2-45 and x <= size[1]/2-45+90 and y >= size[2]/2+110 and y <= size[2]/2+110+35 then
        set(A32nx_target_spd, get(A32nx_target_spd) + value)
    end
end

function update()

end

function draw()

    --drawing adjustment buttons
    --taget speed button--
    sasl.gl.drawRectangle(size[1]/2-80, size[2]/2+110, 30, 30, LIGHT_GREY)
    sasl.gl.drawRectangle(size[1]/2+50, size[2]/2+110, 30, 30, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2-65, size[2]/2 + 110, "-", 50, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2+65, size[2]/2 + 110, "+", 50, false, false, TEXT_ALIGN_CENTER, WHITE)

    --p gain button--
    sasl.gl.drawRectangle(size[1]/6-50, size[2]/2+55, 20, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(size[1]/6+30, size[2]/2+55, 20, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, size[1]/6-40, size[2]/2 + 55, "-", 32, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/6+40, size[2]/2 + 55, "+", 32, false, false, TEXT_ALIGN_CENTER, WHITE)

    --i gain button--
    sasl.gl.drawRectangle(size[1]/2-50, size[2]/2+55, 20, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(size[1]/2+30, size[2]/2+55, 20, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2-40, size[2]/2 + 55, "-", 32, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2+40, size[2]/2 + 55, "+", 32, false, false, TEXT_ALIGN_CENTER, WHITE)

    --d gain button--
    sasl.gl.drawRectangle(5 * size[1]/6-50,  size[2]/2+55, 20, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(5 * size[1]/6+30, size[2]/2+55, 20, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6-40,  size[2]/2 + 55, "-", 32, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6+40, size[2]/2 + 55, "+", 32, false, false, TEXT_ALIGN_CENTER, WHITE)

    --i time button--
    sasl.gl.drawRectangle(size[1]/6-50, size[2]/2-5, 20, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(size[1]/6+30,  size[2]/2-5, 20, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, size[1]/6-40, size[2]/2 - 5, "-", 32, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/6+40,  size[2]/2 - 5, "+", 32, false, false, TEXT_ALIGN_CENTER, WHITE)

    --max i button--
    sasl.gl.drawRectangle(size[1]/2-50, size[2]/2-5, 20, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(size[1]/2+30,  size[2]/2-5, 20, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2-40, size[2]/2 - 5, "-", 32, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, size[1]/2+40,  size[2]/2 - 5, "+", 32, false, false, TEXT_ALIGN_CENTER, WHITE)

    --max error button--
    sasl.gl.drawRectangle(5 * size[1]/6-50, size[2]/2-5, 20, 20, LIGHT_GREY)
    sasl.gl.drawRectangle(5 * size[1]/6+30, size[2]/2-5, 20, 20, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6-40, size[2]/2 - 5, "-", 32, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/6+40, size[2]/2 - 5, "+", 32, false, false, TEXT_ALIGN_CENTER, WHITE)
end
