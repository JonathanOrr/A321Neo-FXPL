--STUFF YOU CAN MESS WITH
BUTTON_PRESS_TIME = 0.5

---STUFF YOU CANNOT MESS WITH

local NUMBER_OF_PAGES = 2
efb_p5_subpage_number = 1

include("EFB/EFB_pages/5_subpage1.lua")
include("EFB/EFB_pages/5_subpage2.lua")
include("libs/table.save.lua")
include("networking/metar_request.lua")

local function mutual_button_loop()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1031,18,1099,48, function () --SELECTOR BUTTONS WORK AT ALL TIMES
        efb_p5_subpage_number = 2
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 954,18,1021,48, function ()
        efb_p5_subpage_number = 1
    end)
end

local function mutual_update_loop()
end

local function mutual_draw_loop()
    SASL_draw_img_center_aligned (EFB_INFO_selector, 1026,33, 147, 32, EFB_WHITE) -- THIS IS THE SELECTOR, IT DRAWS ON ALL PAGES
        sasl.gl.drawText ( Font_ECAMfont , 880 , 24 , "Page "..efb_p5_subpage_number.."/"..NUMBER_OF_PAGES.."", 20 , false , false , TEXT_ALIGN_CENTER , EFB_WHITE)
end

--MOUSE & BUTTONS--
function EFB_execute_page_5_buttons()
    if efb_p5_subpage_number == 1 then
        p5s1_buttons()
    elseif efb_p5_subpage_number == 2 then
        p5s2_buttons()
    end
    mutual_button_loop()
end

--UPDATE LOOPS--
function EFB_update_page_5()
    if efb_p5_subpage_number == 1 then
        p5s1_update()
    elseif efb_p5_subpage_number ==  2 then
        p5s2_update()
    end
    mutual_update_loop()
end

--DRAW LOOPS--
function EFB_draw_page_5()
    if efb_p5_subpage_number == 1 then
        p5s1_draw()
    elseif efb_p5_subpage_number == 2 then
        p5s2_draw()
    end
    mutual_draw_loop()
end


