--MOUSE & BUTTONS--
function EFB_execute_page_5_buttons()

end

--UPDATE LOOPS--
function EFB_update_page_5()
    if AVITAB_INSTALLED == true then
        set(Avitab_Enabled, 1)
    end
end

--DRAW LOOPS--
function EFB_draw_page_5()
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
    if AVITAB_INSTALLED == false then
        sasl.gl.drawText ( Airbus_panel_font , size[1]/2 , size[2]/2 , "AVITAB NOT INSTALLED" , 50 , false , false , TEXT_ALIGN_CENTER , EFB_FULL_RED)
        sasl.gl.drawText ( Airbus_panel_font , size[1]/2 , 350 , "Please Download from github.com/fpw/avitab" , 25 , false , false , TEXT_ALIGN_CENTER , EFB_FULL_RED)
    else
        sasl.gl.drawRectangle ( 0 , 0 , size[1] , 700 , EFB_LIGHTBLUE )
    end
end


