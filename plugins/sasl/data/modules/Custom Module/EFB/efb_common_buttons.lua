function EFB_common_buttons()
    Button_check_and_action(CURSOR_X, CURSOR_Y, 63, 705, 143, 785, function ()
        print("Page 1 Signal")
        EFB_PAGE = 1
    end)
    Button_check_and_action(CURSOR_X, CURSOR_Y, 167, 705, 247, 785, function ()
        print("Page 2 Signal")
        EFB_PAGE = 2
    end)
    Button_check_and_action(CURSOR_X, CURSOR_Y, 271, 705, 351, 785, function ()
        print("Page 3 Signal")
        EFB_PAGE = 3
    end)
    Button_check_and_action(CURSOR_X, CURSOR_Y, 375, 705, 455, 785, function ()
        print("Page 4 Signal")
        EFB_PAGE = 4
    end)
    --[[Button_check_and_action(CURSOR_X, CURSOR_Y, 480, 705, 560, 785, function ()
        print("Page 5 Signal")
        EFB_PAGE = 5
    end)
    Button_check_and_action(CURSOR_X, CURSOR_Y, 583, 705, 663, 785, function ()
        print("Page 6 Signal")
        EFB_PAGE = 6
    end)
    Button_check_and_action(CURSOR_X, CURSOR_Y, 687, 705, 767, 785, function ()
        print("Page 7 Signal")
        EFB_PAGE = 7
    end)
    Button_check_and_action(CURSOR_X, CURSOR_Y, 791, 705, 871, 785, function ()
        print("Page 8 Signal")
        EFB_PAGE = 8
    end)]]
    Button_check_and_action(CURSOR_X, CURSOR_Y, 895, 705, 975, 785, function ()
        print("Page 9 Signal")
        EFB_PAGE = 9
    end)
    Button_check_and_action(CURSOR_X, CURSOR_Y, 989, 705, 1079, 785, function ()
        print("Page 10 Signal")
        EFB_PAGE = 10
    end)
end