--MOUSE & BUTTONS--
function EFB_execute_page_2_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 175, 415, 210, 437, function ()
        sasl.commandOnce(Door_1_r_toggle)
        print("Door1R Pressed")
    end)
end

--UPDATE LOOPS--
function EFB_update_page_2()
end

--DRAW LOOPS--
function EFB_draw_page_2()
    sasl.gl.drawTexture ( EFB_DOOR, 0 , 0 , 1143 , 800 , ECAM_WHITE )
end