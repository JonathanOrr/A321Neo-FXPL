------------------------STUFF YOU CAN MESS WITH
BUTTON_PRESS_TIME = 0.5




------------------------------LOCAL STUFF
local compute_vspeeds = 0
local refuel = 0
local refuel_button_begin = 0
local force_refuel = 0
local force_refuel_button_begin = 0


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
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 808,473,879,503, function ()
        set(LOAD_thrustto, 0)
        print("thr_sel_toga")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 886,473,954,503, function ()
        set(LOAD_thrustto, 1)
        print("thr_sel_flex")
    end)



    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 420,244,735,274, function ()
        refuel_button_begin = get(TIME)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 420,200,735,230, function ()
        force_refuel_button_begin = get(TIME)
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

    if get(LOAD_thrustto) == 1 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 843,460,192,58,2,2)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 920,460,192,58,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 843,460,192,58,2,1)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 920,460,192,58,2,2)
    end






    if get(TIME) - refuel_button_begin < BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_refuel_button, 578,244,634,32,2,2)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_refuel_button, 578,244,634,32,2,1)
        refuel_button_begin = 0 --reset timer
    end

    if get(TIME) - force_refuel_button_begin < BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_refuel_button, 578,195,634,32,2,2)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_refuel_button, 578,195,634,32,2,1)
        force_refuel_button_begin = 0
    end



    -----------------------------------------------------------------------THIS IS THE OVERLAGE IMAGE-----------------------------
    sasl.gl.drawTexture ( EFB_LOAD_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE )

    sasl.gl.drawText ( Airbus_panel_font , 535 , 531, math.floor(get(FOB)).."KG" , 20 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )

-------CHAI FILL IN THE LINES BELOW WITH YOUR NUMBERS


-------BELOW IS THE BEGINNING OF THE LOADSHEET




-------BELOW ARE V SPEEDS INCLUDING VREF


    print(EFB_CURSOR_X, EFB_CURSOR_Y)


end