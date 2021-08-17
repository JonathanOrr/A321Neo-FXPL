function EFB_common_buttons()
    if EFB_PAGE ~= 10 then
        
        EFB_PREV_PAGE = EFB_PAGE

        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 5, 732, 110, 772, function ()
            EFB_PAGE = 1
        end)
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 118, 732, 224, 772, function ()
            EFB_PAGE = 2
        end)
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 233, 732, 337, 772, function ()
            EFB_PAGE = 3
        end)
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 348, 732, 452, 772, function ()
            EFB_PAGE = 4
        end)
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 461, 732, 567, 772, function ()
            EFB_PAGE = 5
        end)
        --Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 575, 732, 681, 772, function ()
        --    EFB_PAGE = 6
        --end)
        --Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 5, 732, 110, 772, function ()
        --    EFB_PAGE = 7
        --end)
        --Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 5, 732, 110, 772, function ()
        --    EFB_PAGE = 8
        --end)
        --Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 5, 732, 110, 772, function ()
        --    EFB_PAGE = 9
        --end)
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1033, 732, 1138, 772, function ()
            EFB_PAGE = 10
        end)
    end
end