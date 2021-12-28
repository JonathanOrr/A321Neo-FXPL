-------------------------------------------------------------

include("libs/table.save.lua")
include("EFB/EFB_pages/4_subpage1.lua")
include("EFB/EFB_pages/4_subpage2.lua")

local NUMBER_OF_PAGES = 2
efb_p4_subpage_number = 1

local function mutual_button_loop()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1031,18,1099,48, function () --SELECTOR BUTTONS WORK AT ALL TIMES
        efb_p4_subpage_number = math.min(efb_p4_subpage_number + 1, NUMBER_OF_PAGES)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 954,18,1021,48, function ()
        efb_p4_subpage_number = math.max( efb_p4_subpage_number - 1, 1)
    end)
end

local function mutual_update_loop()
end

local function mutual_draw_loop()
    SASL_draw_img_center_aligned (EFB_INFO_selector, 1026,33, 147, 32, EFB_WHITE) -- THIS IS THE SELECTOR, IT DRAWS ON ALL PAGES
    sasl.gl.drawText ( Font_Airbus_panel , 880 , 24 , "Page "..efb_p4_subpage_number.."/"..NUMBER_OF_PAGES.."", 20 , false , false , TEXT_ALIGN_CENTER , EFB_WHITE)
end

--------------------------------------------------------------------------

function EFB_execute_page_4_buttons()
    if efb_p4_subpage_number == 1 then
        p4s1_buttons()
    elseif efb_p4_subpage_number == 2 then
        p4s2_buttons()
    end
    mutual_button_loop()
end

--UPDATE LOOPS--
function EFB_update_page_4() -- update loop
    if efb_p4_subpage_number == 1 then
        p4s1_update()
    elseif efb_p4_subpage_number == 2 then
        p4s2_update()
    end
    mutual_update_loop()
end

--DRAW LOOPS--
function EFB_draw_page_4()
    if efb_p4_subpage_number == 1 then
        p4s1_draw()
    elseif efb_p4_subpage_number == 2 then
        p4s2_draw()
    end
    mutual_draw_loop()
end
