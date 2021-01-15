--MOUSE & BUTTONS--

--function EFB_load_ground_objects()
--    GPUobj = sasl.loadObject ( moduleDirectory .. "/Custom Module/ground_vehicles/GPU.obj" ) 
--end
--
--local loc_x = globalPropertyf("sim/flightmodel/position/local_x")
--local loc_y = globalPropertyf("sim/flightmodel/position/local_y")
--local loc_z = globalPropertyf("sim/flightmodel/position/local_z")
--
--local vehicle_drawn = false
--local gpu_instance = {}

--function EFB_draw_vehicles()
--    -- toggle, so doesn't need to be called every frame
--    if not vehicle_drawn then
--        vehicle_drawn = true
--        print("attempting to draw obj")
--        gpu_instance = sasl.createInstance(GPUobj, {})
--        sasl.setInstancePosition(gpu_instance, get(loc_x), get(loc_y)-2.95, get(loc_z), 0, 0, 0)
--    end
--end

--function EFB_delete_vehicles()
--    vehicle_drawn = false
--    sasl.destroyInstance(gpu_instance)
--end

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
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 601, 65, 617, function ()
        set(VEHICLE_gpu, 1 - get(VEHICLE_gpu))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 569, 65, 585, function ()
        set(VEHICLE_as, 1 - get(VEHICLE_as))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 537, 65, 553, function ()
        set(VEHICLE_ac, 1 - get(VEHICLE_ac))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 505, 65, 521, function ()
        set(VEHICLE_cat1, 1 - get(VEHICLE_cat1))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 473, 65, 489, function ()
        set(VEHICLE_cat2, 1 - get(VEHICLE_cat2))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 441, 65, 457, function ()
        set(VEHICLE_ps1, 1 - get(VEHICLE_ps1))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 409, 65, 425, function ()
        set(VEHICLE_ps2, 1 - get(VEHICLE_ps2))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 377, 65, 393, function ()
        set(VEHICLE_ldcl1, 1 - get(VEHICLE_ldcl1))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 345, 65, 361, function ()
        set(VEHICLE_ldcl2, 1 - get(VEHICLE_ldcl2))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 313, 65, 329, function ()
        set(VEHICLE_uld1, 1 - get(VEHICLE_uld1))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 281, 65, 297, function ()
        set(VEHICLE_uld2, 1 - get(VEHICLE_uld2))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 249, 65, 265, function ()
        set(VEHICLE_fuel, 1 - get(VEHICLE_fuel))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 217, 65, 233, function ()
        set(VEHICLE_lv, 1 - get(VEHICLE_lv))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 29, 185, 65, 201, function ()
        set(VEHICLE_wv, 1 - get(VEHICLE_wv))
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
        sasl.gl.drawTexture ( EFB_GROUND_ac, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 536, 78, 18, 2, 1)
    end

    if get(VEHICLE_as) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_as, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 568, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_as, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 568, 78, 18, 2, 1)
    end
    if get(VEHICLE_wv) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_wv, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 184, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_wv, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 184, 78, 18, 2, 1)
    end
    if get(VEHICLE_cat1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_cat1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 504, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_cat1, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 504, 78, 18, 2, 1)
    end
    if get(VEHICLE_cat2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_cat2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 472, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_cat2, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 472, 78, 18, 2, 1)
    end
    if get(VEHICLE_fuel) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_fuel, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 248, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_fuel, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 248, 78, 18, 2, 1)
    end
    if get(VEHICLE_gpu) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_gpu, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 600, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_gpu, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 600, 78, 18, 2, 1)
    end
    if get(VEHICLE_ldcl1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ldcl1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 376, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ldcl1, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 376, 78, 18, 2, 1)
    end
    if get(VEHICLE_ldcl2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ldcl2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 344, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ldcl2, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 344, 78, 18, 2, 1)
    end
    if get(VEHICLE_lv) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_lv, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 216, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_lv, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 216, 78, 18, 2, 1)
    end
    if get(VEHICLE_ps1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ps1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 440, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ps1, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 440, 78, 18, 2, 1)
    end
    if get(VEHICLE_ps2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_ps2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 408, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_ps2, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 408, 78, 18, 2, 1)
    end
    if get(VEHICLE_uld1) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_uld1, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 312, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_uld1, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 312, 78, 18, 2, 1)
    end
    if get(VEHICLE_uld2) == 1 then
        sasl.gl.drawTexture ( EFB_GROUND_uld2, 0 , 0 , 1143 , 800 , EFB_LIGHTBLUE )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 280, 78, 18, 2, 2)
    else
        sasl.gl.drawTexture ( EFB_GROUND_uld2, 0 , 0 , 1143 , 800 , EFB_DARKGREY )
        SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 48, 280, 78, 18, 2, 1)
    end
end

----OBJECTS-----
--function drawObjects()
--    EFB_draw_vehicles()
--end

 

  
    
  
  
  
   
 
 
    
   
   
  
  
    
