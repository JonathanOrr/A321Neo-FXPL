function drawTextCentered(font, x, y, string, size, isbold, isitalic, alignment, colour)
    sasl.gl.drawText (font, x, y - (size/3),string, size, isbold, isitalic, alignment, colour)
end

function click_anywhere_except_that_area( x1, y1, x2, y2, callback)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 0, y2 , 1143, 800, function ()
        callback()
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 0, 0 , x1, 800, function ()
        callback()
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 0, 0 , 1143, y1, function ()
        callback()
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x2, 0 , 1143, 800, function ()
        callback()
    end)
end


function draw_dropdown_menu(x, y, width, height, outside_colour, inside_colour, table, expanded, current)

    local number_of_rows = #table
    local selector_extend_distance = height

    
    sasl.gl.drawRectangle ( x - width/2 ,  y - height/2 ,  width + selector_extend_distance , height , outside_colour)
    sasl.gl.drawRectangle ( x - width/2 + 2 ,  y - height/2 + 2 ,  width - 4 , height - 4 , inside_colour)

    if expanded then
        sasl.gl.drawRectangle ( x - width/2 ,  y - height/2 - (number_of_rows)*height - 4,  width , height + (number_of_rows -1)*height + 4, outside_colour)
        sasl.gl.drawRectangle ( x - width/2 + 2 ,  y - height/2 - (number_of_rows)*height + 2 - 4,  width - 4 , height + (number_of_rows -1)*height - 3 + 5, inside_colour)

        for i, v in pairs(table) do
            drawTextCentered(Font_Airbus_panel, x  ,  y-1 - height*i , table[i], 20, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)

            if EFB_CURSOR_Y > y-1 - height*i - 15 and EFB_CURSOR_Y < y-1 - height*i + 14 and  EFB_CURSOR_X >  x - width/2 and EFB_CURSOR_X <  x + width/2 then
                --sasl.gl.drawFrame (  x - width/2 + 5 , y-1 - height*i - 10 - 3 , width - 8 , height , EFB_WHITE )

                Sasl_DrawWideFrame(  x - width/2 + 5 , y-1 - height*i - 10 - 3 , width - 10 , height - 2 , 2, 1, EFB_WHITE )
            end
        end
    end

    sasl.gl.drawTriangle ( x + width/2 + 2 ,  y + height/2 - 8 , x + width/2 + selector_extend_distance - 2 -2 , y + height/2 - 8 , ((x + width/2 + 2) + (x + width/2 + selector_extend_distance - 2 ))/2 - 1  ,  y - height/2 + 2 , inside_colour )
    sasl.gl.drawTriangle ( x + width/2 + 6 ,  y + height/2 - 8 , x + width/2 + selector_extend_distance - 6 -2 , y + height/2 - 8 , ((x + width/2 + 2) + (x + width/2 + selector_extend_distance - 2 ))/2 - 1  ,  y - height/2 + 8 , outside_colour )

    drawTextCentered(Font_Airbus_panel, x  ,  y-1 , current, 20, false, false, TEXT_ALIGN_CENTER, EFB_FULL_GREEN)

    local component_x = x
    local component_y = y


    function onMouseDown ( component , x , y , button , parentX , parentY )
        if button == MB_LEFT and EFB_CURSOR_X > component_x - width/2  and EFB_CURSOR_Y > component_y - height/2 and EFB_CURSOR_X < (component_x + width/2 + selector_extend_distance) and EFB_CURSOR_Y < (component_y + height/2)then
            expanded = not expanded
            print("hello")
        end
        return false
     end
end