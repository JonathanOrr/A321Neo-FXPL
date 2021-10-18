local focused_slider = 0
local slider_pos = {0,0.3,0.7,1,1,1,1,1,1}
local efb_save_button_begin = 0

------ ok so if you want to add more stuff to the remaining sliders,
-- the {for i=1,6} change it to {for i=1,number_of_sliders_you_want }
-- also add the access functions in the functions_name{}

local function draw_sliders(x,y,i)
    sasl.gl.drawRectangle( x ,y,  404 * slider_pos[i],     15, EFB_DARKGREY)
    local cursor_is_near_slider = within(EFB_CURSOR_X,(x-2)+ 404 * slider_pos[i],(x-2)+30+ 404 * slider_pos[i]) and within(EFB_CURSOR_Y,y-2,y-2+19) 
    if cursor_is_near_slider or focused_slider == i then
        sasl.gl.drawRectangle( (x-2)+ 404 * slider_pos[i] + (1-slider_pos[i]) - 1,   y-2,      29 + 1,     18 + 1, focused_slider == i and EFB_SLIDER_COLOUR or EFB_WHITE)
    end
    sasl.gl.drawRectangle(      x + 403 * slider_pos[i],        y,      26,     15,  focused_slider == i and EFB_SLIDER_COLOUR or EFB_LIGHTBLUE)
end

local function EFB_p4s2_onmousedown(x,y,i) --the mose down function is put inside the button loop
    if within(EFB_CURSOR_X,(x-2)+ 404 * slider_pos[i],(x-2)+30+ 404 * slider_pos[i]) and within(EFB_CURSOR_Y,y-2,y-2+19) then
        focused_slider = i
    end
end

function EFB_p4s2_onmouseup() -- called in main script EFB.lua, when mouse is up disconnects all sliders.
    focused_slider = 0
end

local function EFB_p4s2_move_slider() -- this function sets the global table value to the slider position, to make sure everything syncs.
    if focused_slider ~= 0 then
        slider_pos[focused_slider] = Math_rescale(83, 0, 487, 1, EFB_CURSOR_X)
    end

    local functions_name = {
        EFB.pref_set_sound_ext,
        EFB.pref_set_sound_int,
        EFB.pref_set_sound_warn,
        EFB.pref_set_sound_enviro,
        EFB.pref_set_display_aa,
        EFB.pref_set_brk_strength ,
    }
    for i=1,6 do
        functions_name[i](slider_pos[i])
    end
end

local function draw_save_config_button()
    if get(TIME) - efb_save_button_begin < 0.5 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,2)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,1)
    end
end

local function EFB_p4s2_update_global_table() -- this table set slider_pos to the value in the global table. Used for when global table is load from prefrences file.
    local functions_name = {
        EFB.pref_get_sound_ext,
        EFB.pref_get_sound_int,
        EFB.pref_get_sound_warn,
        EFB.pref_get_sound_enviro,
        EFB.pref_get_display_aa,
        EFB.pref_get_brk_strength,
    }
    for i=1,6 do
        if functions_name[i] then
            slider_pos[i] = functions_name[i]()
        end
    end
end

local function reset_slider_when_mouse_leave()
    if not EFB_CURSOR_on_screen then
        focused_slider = 0
    end
end
------------------------------------------------------------------------------------

function p4s2_buttons()
    for i=1, 9 do
        EFB_p4s2_onmousedown(71,602 - (i-1)*52,i)
    end

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 414,46,738,90, function ()
        efb_save_button_begin = get(TIME)
        EFB.pref_save()
    end)
end

function p4s2_update()
    EFB_p4s2_move_slider()
    reset_slider_when_mouse_leave()
end

function p4s2_draw()
    draw_save_config_button()
    sasl.gl.drawTexture(EFB_CONFIG_s2_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
    for i=1, 9 do
        draw_sliders(71,602 - (i-1)*52,i)
    end
end

EFB_p4s2_update_global_table()
