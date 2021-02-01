
NUMBER_OF_PAGES = 10
PAGE_NUM = 1

--MOUSE & BUTTONS--
function EFB_execute_page_6_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1031,18,1099,48, function ()
        PAGE_NUM = PAGE_NUM + 1
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 954,18,1021,48, function ()
        PAGE_NUM = PAGE_NUM - 1
    end)
end

--UPDATE LOOPS--
function EFB_update_page_6()
    if PAGE_NUM > NUMBER_OF_PAGES then
        PAGE_NUM = 10
    elseif PAGE_NUM < 1 then
        PAGE_NUM = 1
    end
end

--DRAW LOOPS--
function EFB_draw_page_6()
    if PAGE_NUM == 1 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_1, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 2 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_2, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 3 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_3, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 4 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_4, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 5 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_5, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 6 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_6, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 7 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_7, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 8 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_8, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 9 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_9, size[1]/2, 385,1072,603,EFB_WHITE)
    elseif PAGE_NUM == 10 then
        SASL_draw_img_center_aligned ( EFB_INFO_page_10, size[1]/2, 385,1072,603,EFB_WHITE)
    end
    SASL_draw_img_center_aligned (EFB_INFO_selector, 1026,33, 147, 32, EFB_WHITE)
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
    sasl.gl.drawText ( Airbus_panel_font , 880 , 24 , "Page "..PAGE_NUM.."/"..NUMBER_OF_PAGES.."", 25 , false , false , TEXT_ALIGN_CENTER , EFB_WHITE)
end