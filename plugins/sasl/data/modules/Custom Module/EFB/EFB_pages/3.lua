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
end

--UPDATE LOOPS--
function EFB_update_page_3()
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
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
end