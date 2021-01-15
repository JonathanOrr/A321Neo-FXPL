--MOUSE & BUTTONS--
function EFB_execute_page_4_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,618,673,745, function ()
        set(VOLUME_ext, get(VOLUME_ext)-0.1)
        print("ext_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,618,1073,745, function ()
        set(VOLUME_ext, get(VOLUME_ext)+0.1)
        print("ext_up")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,557,673,584, function ()
        set(VOLUME_int, get(VOLUME_int)-0.1)
        print("int_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,557,1073,584, function ()
        set(VOLUME_int, get(VOLUME_int)+0.1)
        print("int_up")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,497,673,525, function ()
        set(VOLUME_wind, get(VOLUME_wind)-0.1)
        print("wind_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,497,1073,525, function ()
        set(VOLUME_wind, get(VOLUME_wind)+0.1)
        print("wind_up")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,437,673,466, function ()
        set(VOLUME_cabin, get(VOLUME_cabin)-0.1)
        print("cabin_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,437,1073,466, function ()
        set(VOLUME_cabin, get(VOLUME_cabin)+0.1)
        print("cabin_up")
    end)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 67,636,277,661, function ()
        print("irs_align")
    end)
----- minus 79 vertical
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 67,557,277,582, function ()
        print("checklist")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 67,478,277,503, function ()
        print("failure")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 67,399,277,431, function ()
        print("fuel")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 67,320,277,352, function ()
        print("stow_rat")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 67,241,277,273, function ()
        print("refill_hyd")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 67,162,277,194, function ()
        print("recon_idg")
    end)
end

--UPDATE LOOPS--
function EFB_update_page_4()
    if get(VOLUME_ext) > 1 then
        set(VOLUME_ext, 1)
    elseif get(VOLUME_ext) < 0 then
        set(VOLUME_ext, 0)
    end

    if get(VOLUME_int) > 1 then
        set(VOLUME_int, 1)
    elseif get(VOLUME_int) < 0 then
        set(VOLUME_int, 0)
    end

    if get(VOLUME_wind) > 1 then
        set(VOLUME_wind, 1)
    elseif get(VOLUME_wind) < 0 then
        set(VOLUME_wind, 0)
    end

    if get(VOLUME_cabin) > 1 then
        set(VOLUME_cabin, 1)
    elseif get(VOLUME_cabin) < 0 then
        set(VOLUME_cabin, 0)
    end
end

--DRAW LOOPS--
function EFB_draw_page_4()
    sasl.gl.drawTexture ( EFB_CONFIG_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_ext)*333+680 , 619 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_int)*333+680 , 559 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_wind)*333+680 , 499 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_cabin)*333+680 , 439 , 22 , 22 , ECAM_WHITE )
    --sasl.gl.drawTexture ( EFB_CONFIG_slider, 1013 , 619 , 22 , 22 , ECAM_WHITE )
end