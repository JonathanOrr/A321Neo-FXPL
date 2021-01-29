
i = 0

--MOUSE & BUTTONS--
function EFB_execute_page_10_buttons()
    if EFB_PAGE == 10 and i > 2 then
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 0,0,1143,800, function ()
            print("EFB On")
            EFB_PAGE = 1
            i = 0
        end)
    end
end

--UPDATE LOOPS--
function EFB_update_page_10()
    if i < 10 then
        i = (i+1)
    end
end

--DRAW LOOPS--
function EFB_draw_page_10()
    sasl.gl.drawRectangle ( 0 , 0 , 1143 , 800 , EFB_BLACK )
    --print("EFB Page 10")
    --print(i)
end