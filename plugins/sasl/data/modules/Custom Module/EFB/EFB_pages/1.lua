--MOUSE & BUTTONS--
function EFB_execute_page_1_buttons()

end

--UPDATE LOOPS--
function EFB_update_page_1()
end

local year = os.date("%Y")

--DRAW LOOPS--
function EFB_draw_page_1()
    sasl.gl.drawTexture ( EFB_HOME_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE )
    drawTextCentered( Font_Airbus_panel ,  525, 175 , year.." C STAR SYSTEMS (CSS)" , 30 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    drawTextCentered( Font_Airbus_panel ,  525, 120 , "ALL RIGHTS RESERVED" , 30 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
end