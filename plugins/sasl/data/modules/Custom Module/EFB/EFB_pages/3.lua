--MOUSE & BUTTONS--
function EFB_execute_page_3_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 808,605,879,636, function ()
        set(LOAD_flapssetting, 1)
        print("flaps_sel_1")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 886,605,954,636, function ()
        set(LOAD_flapssetting, 2)
        print("flaps_sel_2")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 963,605,1031,636, function ()
        set(LOAD_flapssetting, 3)
        print("flaps_sel_3")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 808,539,879,572, function ()
        set(LOAD_runwaycond, 0)
        print("rwy_sel_dry")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 886,539,954,572, function ()
        set(LOAD_runwaycond, 1)
        print("rwy_sel_wet")
    end)

---------------------THIS IS THE CG BUTTONS AREA---------------YAY I LOVE DATAREFS

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 630,361,687,388, function ()
        set(LOAD_CG_pos, get(LOAD_CG_pos)+0.05)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 630,23,687,51, function ()
        set(LOAD_CG_pos, get(LOAD_CG_pos)-0.05)
    end)
end

--UPDATE LOOPS--
function EFB_update_page_3()
    if get(LOAD_CG_pos) > 1 then
        set(LOAD_CG_pos, 1)
    elseif get(LOAD_CG_pos) < 0 then
        set(LOAD_CG_pos, 0)
    end
end

--DRAW LOOPS--
function EFB_draw_page_3()
    if get(LOAD_flapssetting) == 1 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 843,592,192,58,2,1)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 920,592,192,58,2,2)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 996,592,192,58,2,2)
    elseif get(LOAD_flapssetting) == 2 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 843,592,192,58,2,2)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 920,592,192,58,2,1)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 996,592,192,58,2,2)
    elseif get(LOAD_flapssetting) then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 843,592,192,58,2,2)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 920,592,192,58,2,2)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 996,592,192,58,2,1)
    end

    if get(LOAD_runwaycond) == 1 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 843,526,192,58,2,2)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 920,526,192,58,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 843,526,192,58,2,1)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 920,526,192,58,2,2)
    end
    sasl.gl.drawTexture ( EFB_LOAD_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_LOAD_cgball, 641 , 55+get(LOAD_CG_pos)*274 , 32 , 33 , ECAM_WHITE )
    SASL_draw_img_center_aligned ( EFB_LOAD_cross,409-get(LOAD_CG_pos)*263 , 65,27,27 , ECAM_WHITE )

-------CHAI FILL IN THE LINES BELOW WITH YOUR NUMBERS

    sasl.gl.drawText ( Airbus_panel_font , 186 , 622 , "XXX" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_WHITE )--PASSENGER
    sasl.gl.drawText ( Airbus_panel_font , 186 , 557 , "XXXXX" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_WHITE )--FWD CARGO
    sasl.gl.drawText ( Airbus_panel_font , 186 , 493 , "XXXXX" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_WHITE )--AFT CARGO

-------BELOW IS THE BEGINNING OF THE LOADSHEET

    sasl.gl.drawText ( Airbus_panel_font , 656 , 654, "XXXXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--PAYLOAD
    sasl.gl.drawText ( Airbus_panel_font , 656 , 629, math.floor(get(FOB)) , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--BLOCK FUEL

    sasl.gl.drawText ( Airbus_panel_font , 656 , 590, "XXX/XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--ZFW
    sasl.gl.drawText ( Airbus_panel_font , 656 , 565, "XXXXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--TOW
    sasl.gl.drawText ( Airbus_panel_font , 656 , 540, "XXXXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--LW
    sasl.gl.drawText ( Airbus_panel_font , 656 , 516, "XX.XDN" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--TRIM
    sasl.gl.drawText ( Airbus_panel_font , 656 , 492, "XX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--FLEX TEMP

-------BELOW ARE V SPEEDS INCLUDING VREF

sasl.gl.drawText ( Airbus_panel_font , 1013 , 507, "XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--V1
sasl.gl.drawText ( Airbus_panel_font , 1013 , 468, "XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--VR
sasl.gl.drawText ( Airbus_panel_font , 1013 , 427, "XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--V2
sasl.gl.drawText ( Airbus_panel_font , 1013 , 244, "XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--VREF
sasl.gl.drawText ( Airbus_panel_font , 1013 , 174, "XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--FLP RETR
sasl.gl.drawText ( Airbus_panel_font , 1013 , 139, "XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--SLT RETR
sasl.gl.drawText ( Airbus_panel_font , 1013 , 104, "XXX" , 20 ,false , false , TEXT_ALIGN_RIGHT , EFB_WHITE )--CLEAN
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
end