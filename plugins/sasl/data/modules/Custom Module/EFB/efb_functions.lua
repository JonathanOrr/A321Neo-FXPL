--mouse functions
function Button_check_and_action(cursor_x, cursor_y, lower_x, lower_y, higher_x, higher_y, callback)
    if cursor_x >= lower_x and cursor_x <= higher_x and cursor_y >= lower_y and cursor_y <= higher_y then
        callback()
    end
end

function I_hate_button_check_and_action(cursor_x, cursor_y, lower_x, lower_y, higher_x, higher_y, callback)
    if not(cursor_x >= lower_x and cursor_x <= higher_x and cursor_y >= lower_y and cursor_y <= higher_y) then
        callback()
    end
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

function gimp2y(y)
    return 800-y
end

function efb_draw_focus_frames(x, y, w, h)
    Sasl_DrawWideFrame(  x , y , w , h , 2, 2, EFB_FULL_YELLOW )
end

function draw_dropdown_menu(x, y, width, height, outside_colour, inside_colour, table, expanded, selected)

    local number_of_rows = #table
    local selector_extend_distance = height

    
    sasl.gl.drawRectangle ( x - width/2 ,  y - height/2 ,  width + selector_extend_distance , height , outside_colour)
    sasl.gl.drawRectangle ( x - width/2 + 2 ,  y - height/2 + 2 ,  width - 4 , height - 4 , inside_colour)

    if expanded and #table > 0 then
        sasl.gl.drawRectangle ( x - width/2 ,  y - height/2 - (number_of_rows)*height - 4,  width , height + (number_of_rows -1)*height + 4, outside_colour)
        sasl.gl.drawRectangle ( x - width/2 + 2 ,  y - height/2 - (number_of_rows)*height + 2 - 4,  width - 4 , height + (number_of_rows -1)*height - 3 + 5, inside_colour)

        for i, v in pairs(table) do
            drawTextCentered(Font_Airbus_panel, x  ,  y-1 - height*i , table[i], 20, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)

            if EFB_CURSOR_Y > y-1 - height*i - 15 and EFB_CURSOR_Y < y-1 - height*i + 14 and  EFB_CURSOR_X >  x - width/2 and EFB_CURSOR_X <  x + width/2 then
                --sasl.gl.drawFrame (  x - width/2 + 5 , y-1 - height*i - 10 - 3 , width - 8 , height , EFB_WHITE )
                Sasl_DrawWideFrame(  x - width/2 + 5 , y - height*i - 14 , width - 10 , height - 2 , 2, 1, EFB_WHITE )
            end
        end
    end

    sasl.gl.drawTriangle ( x + width/2 + 2 ,  y + height/2 - 8 , x + width/2 + selector_extend_distance - 2 -2 , y + height/2 - 8 , ((x + width/2 + 2) + (x + width/2 + selector_extend_distance - 2 ))/2 - 1  ,  y - height/2 + 2 , inside_colour )
    sasl.gl.drawTriangle ( x + width/2 + 6 ,  y + height/2 - 8 , x + width/2 + selector_extend_distance - 6 -2 , y + height/2 - 8 , ((x + width/2 + 2) + (x + width/2 + selector_extend_distance - 2 ))/2 - 1  ,  y - height/2 + 8 , outside_colour )

    if #table > 0 then
        drawTextCentered(Font_Airbus_panel, x  ,  y-1 , table[selected] , 20, false, false, TEXT_ALIGN_CENTER, EFB_FULL_GREEN)
    end

    local component_x = x
    local component_y = y
end

function istable(t) 
    return type(t) == 'table'
 end

local STANDBY_SCREEN_COLOURS = {
    {0.800, 0.600 ,1.000},
    {0.663, 0.820 ,0.969},
    {0.706, 0.941 ,0.655},
    {1.000, 1.000 ,0.749},
    {1.000, 0.694 ,0.694},
}

function draw_standby_screen(onscreen_message)
    sasl.gl.drawRectangle ( 0 , 0 , 1143, 710, EFB_BACKGROUND_COLOUR)

    local center_point = {1143/2, 380}
    local rotation_degrees = (100*get(TIME))%360
    local radius = 70 + math.sin(get(TIME)*3) * 20

    for i=1,5 do
        local x = Get_rotated_point_x_pos(center_point[1], radius,  rotation_degrees + i * 72 )
        local y = Get_rotated_point_y_pos(center_point[2], radius,  rotation_degrees + i * 72 )
        sasl.gl.drawCircle(x, y, 13, true, STANDBY_SCREEN_COLOURS[i])
    end

    drawTextCentered(Font_Airbus_panel,  50, 105, "PLEASE WAIT", 25, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel,  50, 70, onscreen_message, 30, false, false, TEXT_ALIGN_LEFT, EFB_WHITE)
end

function within(what,min,max)
    if what <= max and what >= min then 
        return true 
    else 
        return false 
    end
end