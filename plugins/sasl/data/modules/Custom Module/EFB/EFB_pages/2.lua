--MOUSE & BUTTONS--

function EFB_execute_page_2_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 44, 108, 427, 130, function ()
        set(VEHICLE_ac,1)
        set(VEHICLE_as,1)
        set(VEHICLE_cat1,1)
        set(VEHICLE_cat2,1)
        set(VEHICLE_fuel,1)
        set(VEHICLE_gpu,1)
        set(VEHICLE_ldcl1,1)
        set(VEHICLE_ldcl2,1)
        set(VEHICLE_lv,1)
        set(VEHICLE_ps1,1)
        set(VEHICLE_ps2,1)
        set(VEHICLE_uld1,1)
        set(VEHICLE_uld2,1)
        set(VEHICLE_wv,1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 44, 76, 427, 98, function ()
        set(VEHICLE_ac,0)
        set(VEHICLE_as,0)
        set(VEHICLE_cat1,0)
        set(VEHICLE_cat2,0)
        set(VEHICLE_fuel,0)
        set(VEHICLE_gpu,0)
        set(VEHICLE_ldcl1,0)
        set(VEHICLE_ldcl2,0)
        set(VEHICLE_lv,0)
        set(VEHICLE_ps1,0)
        set(VEHICLE_ps2,0)
        set(VEHICLE_uld1,0)
        set(VEHICLE_uld2,0)
        set(VEHICLE_wv,0)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 44, 43, 427, 67, function ()
        set(VEHICLE_ac,1)
        set(VEHICLE_as,1)
        set(VEHICLE_cat1,1)
        set(VEHICLE_cat2,1)
        set(VEHICLE_fuel,1)
        set(VEHICLE_gpu,1)
        set(VEHICLE_ldcl1,1)
        set(VEHICLE_ldcl2,1)
        set(VEHICLE_lv,1)
        set(VEHICLE_ps1,0)
        set(VEHICLE_ps2,0)
        set(VEHICLE_uld1,1)
        set(VEHICLE_uld2,1)
        set(VEHICLE_wv,1)
    end)
end

--UPDATE LOOPS--
function EFB_update_page_2()
end

--DRAW LOOPS--
function EFB_draw_page_2()
    sasl.gl.drawTexture ( EFB_GROUND_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
    sasl.gl.drawTexture ( EFB_GROUND_plane, 0 , 0 , 1143 , 800 , EFB_WHITE )
    ----------------------------------------------------------------------
    if get(VEHICLE_ac) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ac, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 536, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ac, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 536, 78, 18, 2, 1)
    end

    if get(VEHICLE_as) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_as, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 568, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_as, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 568, 78, 18, 2, 1)
    end
    if get(VEHICLE_wv) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_wv, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 184, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_wv, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 184, 78, 18, 2, 1)
    end
    if get(VEHICLE_cat1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_cat1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 504, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_cat1, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 504, 78, 18, 2, 1)
    end
    if get(VEHICLE_cat2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_cat2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 472, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_cat2, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 472, 78, 18, 2, 1)
    end
    if get(VEHICLE_fuel) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_fuel, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 248, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_fuel, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 248, 78, 18, 2, 1)
    end
    if get(VEHICLE_gpu) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_gpu, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 600, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_gpu, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 600, 78, 18, 2, 1)
    end
    if get(VEHICLE_ldcl1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ldcl1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 376, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ldcl1, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 376, 78, 18, 2, 1)
    end
    if get(VEHICLE_ldcl2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ldcl2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 344, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ldcl2, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 344, 78, 18, 2, 1)
    end
    if get(VEHICLE_lv) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_lv, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 216, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_lv, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 216, 78, 18, 2, 1)
    end
    if get(VEHICLE_ps1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ps1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 440, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ps1, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 440, 78, 18, 2, 1)
    end
    if get(VEHICLE_ps2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ps2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 408, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ps2, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 408, 78, 18, 2, 1)
    end
    if get(VEHICLE_uld1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_uld1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 312, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_uld1, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 312, 78, 18, 2, 1)
    end
    if get(VEHICLE_uld2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_uld2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 280, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_uld2, 0 , 0 , 1143 , 800 , EFB_WHITE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 280, 78, 18, 2, 1)
    end
end


 

  
    
  
  
  
   
 
 
    
   
   
  
  
    