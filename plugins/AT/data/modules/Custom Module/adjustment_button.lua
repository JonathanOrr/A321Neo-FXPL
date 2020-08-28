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

--colors
local black = {0,0,0}
local white = {1,1,1}
local green = {0.004, 1, 0.004}
local blue = {0.004, 1.0, 1.0}
local orange = {0.843, 0.49, 0}
local red = {1, 0, 0}

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
        if x >= size[1]/2-160 and x <= size[1]/2-160+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.P_gain = A32nx_auto_thrust.P_gain - 0.1
        end

        --p gain + --
        if x >= size[1]/2-80 and x <= size[1]/2-80+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
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
        if x >= size[1]/2+60 and x <= size[1]/2+60+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.D_gain = A32nx_auto_thrust.D_gain - 0.1
        end

        --d gain + --
        if x >= size[1]/2+140 and x <= size[1]/2+140+20 and y >= size[2]/2+55 and y <= size[2]/2+55+20 then
            A32nx_auto_thrust.D_gain = A32nx_auto_thrust.D_gain + 0.1
        end

        --i delay - --
        if x >= size[1]/2-160 and x <= size[1]/2-160+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.I_delay = A32nx_auto_thrust.I_delay - 1
        end

        --i delay + --
        if x >= size[1]/2-80 and x <= size[1]/2-80+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.I_delay = A32nx_auto_thrust.I_delay + 1
        end

        --min error - --
        if x >= size[1]/2-50 and x <= size[1]/2-50+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Min_error = A32nx_auto_thrust.Min_error + 1
            A32nx_auto_thrust.Max_error = A32nx_auto_thrust.Max_error - 1
        end

        --min error + --
        if x >= size[1]/2+30 and x <= size[1]/2+30+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Min_error = A32nx_auto_thrust.Min_error - 1
            A32nx_auto_thrust.Max_error = A32nx_auto_thrust.Max_error + 1
        end

        --error offset - --
        if x >= size[1]/2+60 and x <= size[1]/2+60+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Error_offset = A32nx_auto_thrust.Error_offset - 1
        end

        --error offset + --
        if x >= size[1]/2+140 and x <= size[1]/2+140+20 and y >= size[2]/2-5 and y <= size[2]/2-5+20 then
            A32nx_auto_thrust.Error_offset = A32nx_auto_thrust.Error_offset + 1
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
    sasl.gl.drawCircle(size[1]/2-65, size[2]/2+125, 15, true, white)
    sasl.gl.drawCircle(size[1]/2+65, size[2]/2+125, 15, true, white)
    sasl.gl.drawText(B612_bold, size[1]/2-65, size[2]/2 + 110, "-", 50, false, false, TEXT_ALIGN_CENTER, black)
    sasl.gl.drawText(B612_bold, size[1]/2+65, size[2]/2 + 110, "+", 50, false, false, TEXT_ALIGN_CENTER, black)

    --p gain button--
    sasl.gl.drawCircle(size[1]/2-150, size[2]/2+65, 10, true, white)
    sasl.gl.drawCircle(size[1]/2-70,  size[2]/2+65, 10, true, white)
    sasl.gl.drawText(B612_bold, size[1]/2-150, size[2]/2 + 55, "-", 32, false, false, TEXT_ALIGN_CENTER, black)
    sasl.gl.drawText(B612_bold, size[1]/2-70,  size[2]/2 + 55, "+", 32, false, false, TEXT_ALIGN_CENTER, black)
    
    --i gain button--
    sasl.gl.drawCircle(size[1]/2-40, size[2]/2+65, 10, true, white)
    sasl.gl.drawCircle(size[1]/2+40, size[2]/2+65, 10, true, white)
    sasl.gl.drawText(B612_bold, size[1]/2-40, size[2]/2 + 55, "-", 32, false, false, TEXT_ALIGN_CENTER, black)
    sasl.gl.drawText(B612_bold, size[1]/2+40, size[2]/2 + 55, "+", 32, false, false, TEXT_ALIGN_CENTER, black)

    --d gain button--
    sasl.gl.drawCircle(size[1]/2+70,  size[2]/2+65, 10, true, white)
    sasl.gl.drawCircle(size[1]/2+150, size[2]/2+65, 10, true, white)
    sasl.gl.drawText(B612_bold, size[1]/2+70,  size[2]/2 + 55, "-", 32, false, false, TEXT_ALIGN_CENTER, black)
    sasl.gl.drawText(B612_bold, size[1]/2+150, size[2]/2 + 55, "+", 32, false, false, TEXT_ALIGN_CENTER, black)

    --i delay button--
    sasl.gl.drawCircle(size[1]/2-150, size[2]/2+5, 10, true, white)
    sasl.gl.drawCircle(size[1]/2-70,  size[2]/2+5, 10, true, white)
    sasl.gl.drawText(B612_bold, size[1]/2-150, size[2]/2 - 5, "-", 32, false, false, TEXT_ALIGN_CENTER, black)
    sasl.gl.drawText(B612_bold, size[1]/2-70,  size[2]/2 - 5, "+", 32, false, false, TEXT_ALIGN_CENTER, black)
    
    --min button--
    sasl.gl.drawCircle(size[1]/2-40, size[2]/2+5, 10, true, white)
    sasl.gl.drawCircle(size[1]/2+40, size[2]/2+5, 10, true, white)
    sasl.gl.drawText(B612_bold, size[1]/2-40, size[2]/2 - 5, "-", 32, false, false, TEXT_ALIGN_CENTER, black)
    sasl.gl.drawText(B612_bold, size[1]/2+40, size[2]/2 - 5, "+", 32, false, false, TEXT_ALIGN_CENTER, black)

    --max button--
    sasl.gl.drawCircle(size[1]/2+70,  size[2]/2+5, 10, true, white)
    sasl.gl.drawCircle(size[1]/2+150, size[2]/2+5, 10, true, white)
    sasl.gl.drawText(B612_bold, size[1]/2+70,  size[2]/2 - 5, "-", 32, false, false, TEXT_ALIGN_CENTER, black)
    sasl.gl.drawText(B612_bold, size[1]/2+150, size[2]/2 - 5, "+", 32, false, false, TEXT_ALIGN_CENTER, black)
end