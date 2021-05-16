size = {900, 800}
position = {0,0,900,800}

local function drawTextCentered(font, x, y, string, size, isbold, isitalic, alignment, colour)
    sasl.gl.drawText (font, x, y - (size/3),string, size, isbold, isitalic, alignment, colour)
end

local function row(number)
    return 700 - (number-1) * 24 -- 700 is the column beginning height
end

local function column(number)
    local returning = 0
        if number % 2 == 0 then
            returning = (number-1) * 80
        else
            returning = (number-1) * 80 + 30
        end
    return returning
end

local white = {1,1,1,1}
local test_numbers = {1,1,1,1,1}

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    for i=1, 2 do --ROLL RATE CONTROLLER
        for j=1, 6 do
            if x > column(i)-15 and x < column(i)+15 and y > row(j) - 10 and y < row(j) +10 then --P GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.P[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.P[j][i] + value
                end
            end
            if x > column(i)-15 and x < column(i)+15 and y > row(j+7) - 10 and y < row(j+7) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.I[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.I[j][i] + value
                end
            end
            if x > column(i)-15 and x < column(i)+15 and y > row(j+14) - 10 and y < row(j+14) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.D[j][i] + value/10000
                else --first column
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.D[j][i] + value
                end
            end




            if x > column(i+2)-15 and x < column(i+2)+15 and y > row(j) - 10 and y < row(j) +10 then --P GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.P[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.P[j][i] + value
                end
            end
            if x > column(i+2)-15 and x < column(i+2)+15 and y > row(j+7) - 10 and y < row(j+7) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.I[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.I[j][i] + value
                end
            end
            if x > column(i+2)-15 and x < column(i+2)+15 and y > row(j+14) - 10 and y < row(j+14) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.D[j][i] + value/10000
                else --first column
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.D[j][i] + value
                end
            end


            if x > column(i+6)-15 and x < column(i+6)+15 and y > row(j) - 10 and y < row(j) +10 then --P GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.P[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.P[j][i] + value/100
                end
            end
            if x > column(i+6)-15 and x < column(i+6)+15 and y > row(j+7) - 10 and y < row(j+7) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.I[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.I[j][i] + value/100
                end
            end
            if x > column(i+6)-15 and x < column(i+6)+15 and y > row(j+14) - 10 and y < row(j+14) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.D[j][i] + value/10000
                else --first column
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.D[j][i] + value/100
                end
            end
        end --end the gigantic for loop


        for j=1, 8 do
            if x > column(i+4)-15 and x < column(i+4)+15 and y > row(j) - 10 and y < row(j) +10 then --P GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.P[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.P[j][i] =
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.P[j][i] + value
                end
            end
            if x > column(i+4)-15 and x < column(i+4)+15 and y > row(j+9) - 10 and y < row(j+9) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.I[j][i] + value/1000
                else --first column
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.I[j][i] =
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.I[j][i] + value
                end
            end
            if x > column(i+4)-15 and x < column(i+4)+15 and y > row(j+18) - 10 and y < row(j+18) +10 then --I GAINS
                if i % 2 == 0 then --second column
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.D[j][i] + value/10000
                else --first column
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.D[j][i] =
                    FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.D[j][i] + value
                end
            end
        end
    end
end

local rgb = {0,0,0}
local function rgb_cycle()
    rgb[1] = Table_interpolate({{0,1},{1,0},{2,0},{3,1}}, get(TIME)%3)
    rgb[2] = Table_interpolate({{0,0},{1,1},{2,0},{3,0}}, get(TIME)%3)
    rgb[3] = Table_interpolate({{0,0},{1,0},{2,1},{3,0}}, get(TIME)%3)
    return rgb
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1] , size[2], EFB_BACKGROUND_COLOUR)

    drawTextCentered(Font_AirbusDUL,  (column(1) + column(2))/2 ,750, "ROL RATE" , 20, true, false, TEXT_ALIGN_CENTER, white)
    drawTextCentered(Font_AirbusDUL,  (column(3) + column(4))/2 ,750, "PCH RATE" , 20, true, false, TEXT_ALIGN_CENTER, white)
    drawTextCentered(Font_AirbusDUL,  (column(5) + column(6))/2 ,750, " C STAR " , 20, true, false, TEXT_ALIGN_CENTER, white)
    drawTextCentered(Font_AirbusDUL,  (column(7) + column(8))/2 ,750, "SLIP REQ" , 20, true, false, TEXT_ALIGN_CENTER, white)

    for i=1, 2 do
        for j=1, 6 do
            drawTextCentered(Font_AirbusDUL,  column(i),row(j), FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.P[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i),row(j+7), FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.I[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i),row(j+14), FBW_PID_arrays.FBW_ROLL_RATE_PID_array.Schedule_table.D[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)

            drawTextCentered(Font_AirbusDUL,  column(i+2),row(j), FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.P[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i+2),row(j+7), FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.I[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i+2),row(j+14), FBW_PID_arrays.FBW_PITCH_RATE_PID_array.Schedule_table.D[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)

            drawTextCentered(Font_AirbusDUL,  column(i+6),row(j), FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.P[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i+6),row(j+7), FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.I[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i+6),row(j+14), FBW_PID_arrays.FBW_NRM_YAW_PID_array.Schedule_table.D[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
        end

        for j=1, 8 do
            drawTextCentered(Font_AirbusDUL,  column(i+4),row(j), FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.P[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i+4),row(j+9), FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.I[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
            drawTextCentered(Font_AirbusDUL,  column(i+4),row(j+18), FBW_PID_arrays.FBW_CSTAR_PID_array.Schedule_table.D[j][i] , 16, false, false, TEXT_ALIGN_CENTER, white)
        end
    end

    drawTextCentered(Font_Chinese, size[1]/2 ,50, "女友调教：训练出最敏感的XXX!" , 40, true, false, TEXT_ALIGN_CENTER, rgb_cycle())
    Sasl_DrawWideFrame(size[1]/2-350 ,50-25, 700, 50, 4, 1, rgb_cycle())
end