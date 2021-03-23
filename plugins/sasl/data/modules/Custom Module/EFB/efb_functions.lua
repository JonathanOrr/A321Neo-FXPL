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