local close_button_start_time = 0
local  BUTTON_PRESS_TIME = 0.5


local door_image_names = {
EFB_GROUND2_l1,
EFB_GROUND2_l2,
EFB_GROUND2_l3,
EFB_GROUND2_l4,
EFB_GROUND2_l5,
EFB_GROUND2_r1,
EFB_GROUND2_r2,
EFB_GROUND2_r3,
EFB_GROUND2_r4,
EFB_GROUND2_r5,
EFB_GROUND2_cfront,
EFB_GROUND2_caft,
}

local door_anim_drf_names = 
{Door_1_l_ratio,
Overwing_exit_1_l_ratio, 
Overwing_exit_2_l_ratio,
Door_2_l_ratio, 
Door_3_l_ratio,
Door_1_r_ratio,
Overwing_exit_1_r_ratio,
Overwing_exit_2_r_ratio,
Door_2_r_ratio, 
Door_3_r_ratio,
Cargo_1_ratio,
Cargo_2_ratio
}

local door_switch_drf_names = 
{Door_1_l_switch,
Overwing_exit_1_l_switch, 
Overwing_exit_2_l_switch,
Door_2_l_switch, 
Door_3_l_switch,
Door_1_r_switch,
Overwing_exit_1_r_switch,
Overwing_exit_2_r_switch,
Door_2_r_switch, 
Door_3_r_switch,
Cargo_1_switch,
Cargo_2_switch
}

function p2s2_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 206,478,244,528, function ()
        set(door_switch_drf_names[1], get(door_switch_drf_names[1]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 487,483,507,522, function ()
        set(door_switch_drf_names[2], get(door_switch_drf_names[2]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 507,483,534,522, function ()
        set(door_switch_drf_names[3], get(door_switch_drf_names[3]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 612,482,651,527, function ()
        set(door_switch_drf_names[4], get(door_switch_drf_names[4]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 842,482,874,527, function ()
        set(door_switch_drf_names[5], get(door_switch_drf_names[5]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 898,190,931,242, function ()
        set(door_switch_drf_names[6], get(door_switch_drf_names[6]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y,  633,196,656,238, function ()
        set(door_switch_drf_names[7], get(door_switch_drf_names[7]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 609,196,633,238, function ()
        set(door_switch_drf_names[8], get(door_switch_drf_names[8]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 494,191,529,245, function ()
        set(door_switch_drf_names[9], get(door_switch_drf_names[9]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 267,188,303,245, function ()
        set(door_switch_drf_names[10], get(door_switch_drf_names[10]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 830,164,877,199, function ()
        set(door_switch_drf_names[11], get(door_switch_drf_names[11]) ==  1 and 0 or 1)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 395,164,458,199, function ()
        set(door_switch_drf_names[12], get(door_switch_drf_names[12]) ==  1 and 0 or 1)
    end)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 52,56,382,94, function ()
        close_button_start_time = get(TIME)
        for i=1, #door_switch_drf_names do
            set(door_switch_drf_names[i], 0)
        end
    end)
end

--UPDATE LOOPS--
function p2s2_update()
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
end


local door_pos_table = {
    {216,483,21,40},
    {494,490,13,27},
    {510,490,13,27},
    {622,486,19,38},
    {847,485,21,40},
    {904,196,21,41},
    {634,203,15,28},
    {618,202,15,29},
    {500,199,20,40},
    {273,199,21,40},
    {836,167,36,30},
    {407,167,34,29},
}
--DRAW LOOPS--
function p2s2_draw()

    if get(TIME) - close_button_start_time > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_GROUND2_closeall_button, 220,60,634,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_GROUND2_closeall_button, 220,60,634,32,2,2)
    end
    drawTextCentered( Font_Airbus_panel ,  214, 75 ,"CLOSE ALL DOORS" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )

    for i=1, #door_anim_drf_names do
        local door_state = get(door_anim_drf_names[i])
        if door_state == 0 then
            sasl.gl.drawTexture ( door_image_names[i], door_pos_table[i][1] , door_pos_table[i][2] , door_pos_table[i][3] , door_pos_table[i][4] , EFB_LIGHTBLUE )
        elseif door_state > 0 and door_state < 1 then
            sasl.gl.drawTexture ( door_image_names[i], door_pos_table[i][1] , door_pos_table[i][2] , door_pos_table[i][3] , door_pos_table[i][4] , EFB_FULL_RED )
        elseif door_state == 1 then
            sasl.gl.drawTexture ( door_image_names[i], door_pos_table[i][1] , door_pos_table[i][2] , door_pos_table[i][3] , door_pos_table[i][4] , EFB_FULL_GREEN )
        end
    end
    sasl.gl.drawTexture ( EFB_GROUND2_bgd, 57 , 127 , 962 , 526 , EFB_WHITE )
end

 

  
    
  
  
  
   
 
 
    
   
   
  
  
    
