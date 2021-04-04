
local NUMBER_OF_PAGES = 5
PAGE_NUM = 1

local acf_directory = 0

--MOUSE & BUTTONS--
function EFB_execute_page_6_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1031,18,1099,48, function ()
        PAGE_NUM = PAGE_NUM + 1
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 954,18,1021,48, function ()
        PAGE_NUM = PAGE_NUM - 1
    end)
end

local function get_aircraft_root_directory()
    acf_directory = sasl.getAircraftPath ()
    --print(acf_directory)
end

--UPDATE LOOPS--
function EFB_update_page_6()

    get_aircraft_root_directory()

    if PAGE_NUM > NUMBER_OF_PAGES then
        PAGE_NUM = NUMBER_OF_PAGES
    elseif PAGE_NUM < 1 then
        PAGE_NUM = 1
    end
end

--DRAW LOOPS--
function EFB_draw_page_6()

        SASL_draw_img_center_aligned (EFB_INFO_page[PAGE_NUM], size[1]/2, 385,1072,603,EFB_WHITE)

    SASL_draw_img_center_aligned (EFB_INFO_selector, 1026,33, 147, 32, EFB_WHITE)
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
    sasl.gl.drawText ( Font_Airbus_panel , 880 , 24 , "Page "..PAGE_NUM.."/"..NUMBER_OF_PAGES.."", 20 , false , false , TEXT_ALIGN_CENTER , EFB_WHITE)
end
