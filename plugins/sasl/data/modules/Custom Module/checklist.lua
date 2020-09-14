size = { 480 , 550 }
position = { 0 , 0 , 480 , 550 }

--including--
include('checklists/checklist_constants.lua')
include('checklists/before_start.lua')
include('checklists/push_start.lua')
include('checklists/after_start.lua')
include('checklists/before_take_off.lua')
include('checklists/after_take_off.lua')
include('checklists/descent.lua')
include('checklists/landing.lua')
include('checklists/after_landing.lua')
include('checklists/shutdown.lua')
include('checklists/securing_the_aircraft.lua')
include('checklists/before_leaving_the_aircraft.lua')


--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")

--image textures
local camera_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/checklist/white_camera.png")
local zigzag_arrow_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/checklist/zigzag_arrow.png")
local drak_grey_eye_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/checklist/dark_grey_eye.png")
local white_eye_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/checklist/white_eye.png")
local blue_eye_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/checklist/blue_eye.png")

local current_checklist = createGlobalPropertyi("a321neo/cockpit/checklist/current_checklist", 1, false, true, false)-- 1 before start, 2 push/ start, 3 after start, 4 before take off, 5 after takeoff, 6 descent, 7 landing, 8 after landing, 9 shutdown, 10 secureing the aircraft, 11 BEFORE LEAVING THE AIRCRAFT
local camera_control_active = createGlobalPropertyi("a321neo/cockpit/checklist/camera_control_active", 1, false, true, false)--if camera control of the checklist is active
local use_smooth_animation = createGlobalPropertyi("a321neo/cockpit/checklist/use_smooth_animation", 1, false, true, false)--if camera animation is smoothed, turnning this off can potentially overpower other camera plugins

local show_small_arrow = createGlobalPropertyf("a321neo/cockpit/checklist/show_small_arrow", 0, false, true, false)
local show_norm_arrow = createGlobalPropertyf("a321neo/cockpit/checklist/show_norm_arrow", 0, false, true, false)
local show_large_arrow = createGlobalPropertyf("a321neo/cockpit/checklist/show_large_arrow", 0, false, true, false)

local small_arrow_lit = createGlobalPropertyf("a321neo/cockpit/checklist/small_arrow_lit", 1, false, true, false)
local norm_arrow_lit = createGlobalPropertyf("a321neo/cockpit/checklist/norm_arrow_lit", 1, false, true, false)
local large_arrow_lit = createGlobalPropertyf("a321neo/cockpit/checklist/large_arrow_lit", 1, false, true, false)

local small_arrow_tramsform_x = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/small_arrow_x", -10, false, true, false)--left right in relation to flight path(cm)
local norm_arrow_tramsform_x = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/norm_arrow_x", 0, false, true, false)--left right in relation to flight path(cm)
local large_arrow_tramsform_x = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/large_arrow_x", 10, false, true, false)--left right in relation to flight path(cm)

local small_arrow_tramsform_y = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/small_arrow_y", 0, false, true, false)--forward backwards in relation to flight path(cm)
local norm_arrow_tramsform_y = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/norm_arrow_y", 0, false, true, false)--forward backwards in relation to flight path(cm)
local large_arrow_tramsform_y = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/large_arrow_y", 0, false, true, false)--forward backwards in relation to flight path(cm)

local small_arrow_tramsform_z = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/small_arrow_z", 15, false, true, false)--up down in relation to flight path(cm)
local norm_arrow_tramsform_z = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/norm_arrow_z", 15, false, true, false)--up down in relation to flight path(cm)
local large_arrow_tramsform_z = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_transform/large_arrow_z", 15, false, true, false)--up down in relation to flight path(cm)

local small_arrow_rotate_x = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/small_arrow_x", 0, false, true, false)--left right in relation to flight path(degs)
local norm_arrow_rotate_x = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/norm_arrow_x", 0, false, true, false)--left right in relation to flight path(degs)
local large_arrow_rotate_x = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/large_arrow_x", 0, false, true, false)--left right in relation to flight path(degs)

local small_arrow_rotate_y = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/small_arrow_y", 0, false, true, false)--forward backwards in relation to flight path(degs)
local norm_arrow_rotate_y = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/norm_arrow_y", 0, false, true, false)--forward backwards in relation to flight path(degs)
local large_arrow_rotate_y = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/large_arrow_y", 0, false, true, false)--forward backwards in relation to flight path(degs)

local small_arrow_rotate_z = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/small_arrow_z", 0, false, true, false)--up down in relation to flight path(degs)
local norm_arrow_rotate_z = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/norm_arrow_z", 0, false, true, false)--up down in relation to flight path(degs)
local large_arrow_rotate_z = createGlobalPropertyf("a321neo/cockpit/checklist/arrow_rotate/large_arrow_z", 0, false, true, false)--up down in relation to flight path(degs)

--previous head status
local previous_head_x = -0.472440
local previous_head_y = 2.1333600
local previous_head_z = -17.373600
local previous_head_phi = 0
local previous_head_psi = 0
local previous_head_the = 0
local head_returning = false

--checklist items
local all_checklist = {
    Before_start_checklist,
    Push_start_checklist,
    After_start_checklist,
    Before_takeoff_checklist,
    After_takeoff_checklist,
    Descent_checklist,
    Landing_checklist,
    After_landing_checklist,
    Shutdown_checklist,
    Securing_the_aircraft_checklist,
    Before_leaving_the_aircraft_checklist
}

--checklist function
local function resize_checklist(checklist_array)
    local pos_x
    local pos_y
    local pos_width
    local pos_height

    pos_x, pos_y, pos_width, pos_height = Checklist_window:getPosition()

    local window_height = 20 + 20 + 30 --20px for upper boarder and 20px for lower boarder 30px for the title box

    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_PROPERTIES then--if the item is a checklist property
        elseif checklist_array[i].Type == CHECKLIST_LINE then--if the item is a line in the checklist
            --sum 10px of the boarder above and 30px of box height to the window
            window_height = window_height + 10 + 30
        elseif checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item
            --sum 10px of the boarder above and 30px of box height to the window
            window_height = window_height + 10 + 30

            --sub-items if any
            if checklist_array[i].Sub_items ~= nil then
                for j = 1, #checklist_array[i].Sub_items do
                    --sum 10px of the boarder above and 30px of box height to the window
                    window_height = window_height + 10 + 30
                end
            end
        end
    end

    --add the camera control box height
    window_height = window_height + 10 + 30

    --resize to fit the checklist
    size[1] = 480
    size[2] = window_height
    Checklist_window:setSizeLimits ( 480 / 2, window_height / 2, 480, window_height)
    Checklist_window:setPosition ( pos_x , pos_y + (pos_height - window_height), 480, window_height)
end

local function draw_checklist(checklist_array)

    local rectangle_vertical_pos = size[2] - 20 - 30 - 10 - 30-- 20 + 20 px of boarders + 30px + 10px of height from the first box then another 30px for the second box
    local text_vertical_pos = size[2] - 20 - 30 - 10 - 30 + 10-- + 10px to the above value to center the text

    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_PROPERTIES then--if the item is a checklist property
            if get(current_checklist) == 1 then
                sasl.gl.drawRectangle(20, size[2] - 20 - 30, size[1] - 20 - 20 - 30 - 10, 30, checklist_array[i].Color)
                sasl.gl.drawText(B612MONO_bold, (size[1] - 40) / 2, size[2] - 20 - 30 + 7, checklist_array[i].Title, 22, false, false, TEXT_ALIGN_CENTER, DARK_GREY)
            elseif get(current_checklist) == #all_checklist then
                sasl.gl.drawRectangle(20 + 30 + 10, size[2] - 20 - 30, size[1] - 20 - (20 + 30 + 10), 30, checklist_array[i].Color)
                sasl.gl.drawText(B612MONO_bold, (40 + size[1]) / 2, size[2] - 20 - 30 + 7, checklist_array[i].Title, 22, false, false, TEXT_ALIGN_CENTER, DARK_GREY)
            else
                sasl.gl.drawRectangle(20 + 30 + 10, size[2] - 20 - 30, size[1] - 20 - (20 + 30 + 10) - 30 - 10, 30, checklist_array[i].Color)
                sasl.gl.drawText(B612MONO_bold, size[1] / 2, size[2] - 20 - 30 + 7, checklist_array[i].Title, 22, false, false, TEXT_ALIGN_CENTER, DARK_GREY)
            end
        elseif checklist_array[i].Type == CHECKLIST_LINE then--if the item is a line in the checklist
            --draw boxes
            sasl.gl.drawRectangle(20, rectangle_vertical_pos, 440, 30, LIGHT_GREY)

            --draw text
            sasl.gl.drawText(B612MONO_bold, (20 + 460) / 2, text_vertical_pos, checklist_array[i].Name, 15, false, false, TEXT_ALIGN_CENTER, WHITE)

            --scroll down
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30
        elseif checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item
            --draw boxes
            sasl.gl.drawRectangle(20, rectangle_vertical_pos, 360, 30, LIGHT_GREY)

            --draw viewing click box
            sasl.gl.drawRectangle(390, rectangle_vertical_pos, 30, 30, LIGHT_GREY)
            if checklist_array[i].Quickview == VIEW_AVAILABLE then--an item and only but no view no arrow, but not no view but with arrow so this draws a grey eye if quickview for the item is not available
                if checklist_array[i].Viewing == false then--draw tick according to state
                    sasl.gl.drawTexture (white_eye_img, 390, rectangle_vertical_pos, 30, 30, {1, 1, 1, 1})
                else
                    sasl.gl.drawTexture (blue_eye_img, 390, rectangle_vertical_pos, 30, 30, {1, 1, 1, 1})
                end
            else
                sasl.gl.drawTexture (drak_grey_eye_img, 390, rectangle_vertical_pos, 30, 30, {1, 1, 1, 1})
            end

            if checklist_array[i].Checked == false then--draw tick according to state
                sasl.gl.drawRectangle(430, rectangle_vertical_pos, 30, 30, LIGHT_GREY)--draw tick click box
            else
                sasl.gl.drawRectangle(430, rectangle_vertical_pos, 30, 30, LIGHT_GREY)--draw tick click box
                sasl.gl.drawRectangle(435, rectangle_vertical_pos + 5, 20, 20, LIGHT_BLUE)
            end

            if checklist_array[i].Checked == false then--draw item according to state
                --draw text
                sasl.gl.drawText(B612MONO_bold, 25, text_vertical_pos, checklist_array[i].Name, 14, false, false, TEXT_ALIGN_LEFT, WHITE)
            else
                --draw text
                sasl.gl.drawText(B612MONO_bold, 25, text_vertical_pos, checklist_array[i].Name, 14, false, false, TEXT_ALIGN_LEFT, LIGHT_BLUE)
            end


            --scroll down
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30

            --draw sub-items if any
            if checklist_array[i].Sub_items ~= nil then
                for j = 1, #checklist_array[i].Sub_items do
                    if j == 1 then
                        --draw boxes
                        sasl.gl.drawRectangle(20, rectangle_vertical_pos, 440, 30, LIGHT_GREY)
                    else
                        --draw boxes
                        sasl.gl.drawRectangle(20, rectangle_vertical_pos, 440, 40, LIGHT_GREY)
                    end

                    if checklist_array[i].Checked == false then--draw item according to state
                        --draw text
                        sasl.gl.drawText(B612MONO_bold, 25, text_vertical_pos, checklist_array[i].Sub_items[j], 14, false, false, TEXT_ALIGN_LEFT, WHITE)
                    else
                        --draw text
                        sasl.gl.drawText(B612MONO_bold, 25, text_vertical_pos, checklist_array[i].Sub_items[j], 14, false, false, TEXT_ALIGN_LEFT, LIGHT_BLUE)
                    end

                    --scroll down
                    rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
                    text_vertical_pos = text_vertical_pos - 10 -30
                end
            end
        end
    end

    --skip to start button
    sasl.gl.drawRectangle(20, rectangle_vertical_pos, 30, 30, LIGHT_GREY)
    sasl.gl.drawTriangle( 20 + 5, (2 * rectangle_vertical_pos + 30) / 2 , 20 + 25, rectangle_vertical_pos + 25, 20 + 25, rectangle_vertical_pos + 5, WHITE)
    sasl.gl.drawWideLine(20 + 5, rectangle_vertical_pos + 25, 20 + 5, rectangle_vertical_pos + 5, 2, WHITE)

    --draw camera control indication
    if get(camera_control_active) == 1 then
        sasl.gl.drawRectangle(20 + (10 + 30), rectangle_vertical_pos, 30, 30, LIGHT_BLUE)
    else
        sasl.gl.drawRectangle(20 + (10 + 30), rectangle_vertical_pos, 30, 30, LIGHT_GREY)
    end
    sasl.gl.drawTexture (camera_img, 20 + (10 + 30), rectangle_vertical_pos, 30, 30, {1, 1, 1, 1})

    --draw toggle animation button
    if get(use_smooth_animation) == 1 then
        sasl.gl.drawRectangle(20 + (10 + 30) * 2, rectangle_vertical_pos, 30, 30, LIGHT_BLUE)
    else
        sasl.gl.drawRectangle(20 + (10 + 30) * 2, rectangle_vertical_pos, 30, 30, LIGHT_GREY)
    end
    sasl.gl.drawTexture (zigzag_arrow_img, 20 + (10 + 30) * 2, rectangle_vertical_pos, 30, 30, {1, 1, 1, 1})

    --skip to end button
    sasl.gl.drawRectangle(size[1] -20 - 30, rectangle_vertical_pos, 30, 30, LIGHT_GREY)
    sasl.gl.drawTriangle(size[1] -20 - 30 + 25, (2 * rectangle_vertical_pos + 30) / 2 , size[1] -20 - 30 + 5, rectangle_vertical_pos + 25, size[1] -20 - 30 + 5, rectangle_vertical_pos + 5, WHITE)
    sasl.gl.drawWideLine(size[1] -20 - 30 + 25, rectangle_vertical_pos + 25, size[1] -20 - 30 + 25, rectangle_vertical_pos + 5, 2,WHITE)
end

local function check_mouse_check(checklist_array, mouse_x, mouse_y)
    local rectangle_vertical_pos = size[2] - 20 - 30 - 10 - 30-- 20 + 20 px of boarders + 30px + 10px of height from the first box then another 30px for the second box
    local text_vertical_pos = size[2] - 20 - 30 - 10 - 30 + 10-- + 10px to the above value to center the text

    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_LINE then--if the item is a line in the checklist
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30
        elseif checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item

            --check/uncheck checklist item
            if mouse_x >= 430 and mouse_x <= 430 + 30 and mouse_y >= rectangle_vertical_pos and mouse_y <= rectangle_vertical_pos + 30 then
                if checklist_array[i].Checked == false then
                    checklist_array[i].Checked = true
                elseif checklist_array[i].Checked == true then
                    checklist_array[i].Checked = false
                end
            end

            --scroll down
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30
            --draw sub-items if any
            if checklist_array[i].Sub_items ~= nil then
                for j = 1, #checklist_array[i].Sub_items do

                    --scroll down
                    rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
                    text_vertical_pos = text_vertical_pos - 10 -30
                end
            end
        end
    end
end

local function view_mouse_check(checklist_array, mouse_x, mouse_y)
    local rectangle_vertical_pos = size[2] - 20 - 30 - 10 - 30-- 20 + 20 px of boarders + 30px + 10px of height from the first box then another 30px for the second box
    local text_vertical_pos = size[2] - 20 - 30 - 10 - 30 + 10-- + 10px to the above value to center the text

    --used to check if there is any view currently active to not store the quickview as the head position history as you don't want to return to the previous checklist position
    local any_view_active = false

    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_LINE then--if the item is a line in the checklist
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30
        elseif checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item

            --toggle view checklist item
            if mouse_x >= 390 and mouse_x <= 390 + 30 and mouse_y >= rectangle_vertical_pos and mouse_y <= rectangle_vertical_pos + 30 then
                if checklist_array[i].Viewing == false then
                    if checklist_array[i].Quickview ==  VIEW_AVAILABLE then --only enable view if the view is actually available
                        --cycle the whole list and disable viewing of all other items
                        for k = 1, #checklist_array do
                            if checklist_array[k].Type == CHECKLIST_ITEM then--if the item is a checklist item
                                if checklist_array[k].Viewing == true then
                                    checklist_array[k].Viewing = false
                                    any_view_active = true
                                end
                            end
                        end

                        --store the previos head position(if the head is not currently being returned, otherwise it'll store some inbetween position which you don't want), also don't store the previous checklist position as history
                        if head_returning == false and any_view_active == false then
                            previous_head_x = get(Head_x)
                            previous_head_y = get(Head_y)
                            previous_head_z = get(Head_z)
                            previous_head_phi = get(Head_phi)
                            previous_head_psi = get(Head_psi)
                            previous_head_the = get(Head_the)
                        end

                        --stop the head returning because it'll counter the view travel
                        head_returning = false

                        --change current item state
                        checklist_array[i].Viewing = true
                    end
                elseif checklist_array[i].Viewing == true then
                    --cycle the whole list and disable viewing of all other items
                    for k = 1, #checklist_array do
                        if checklist_array[k].Type == CHECKLIST_ITEM then--if the item is a checklist item
                            checklist_array[k].Viewing = false
                        end
                    end

                    --change current item state
                    checklist_array[i].Viewing = false

                    --return head to previous position
                    head_returning = true
                end
            end

            --scroll down
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30
            --draw sub-items if any
            if checklist_array[i].Sub_items ~= nil then
                for j = 1, #checklist_array[i].Sub_items do
                    --scroll down
                    rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
                    text_vertical_pos = text_vertical_pos - 10 -30
                end
            end
        end
    end
end

--used to check mouse click for the very bottom row
local function special_mouse_check(checklist_array, mouse_x, mouse_y)
    local rectangle_vertical_pos = size[2] - 20 - 30 - 10 - 30-- 20 + 20 px of boarders + 30px + 10px of height from the first box then another 30px for the second box
    local text_vertical_pos = size[2] - 20 - 30 - 10 - 30 + 10-- + 10px to the above value to center the text

    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_LINE then--if the item is a line in the checklist
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30
        elseif checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item
            --scroll down
            rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
            text_vertical_pos = text_vertical_pos - 10 -30
            --draw sub-items if any
            if checklist_array[i].Sub_items ~= nil then
                for j = 1, #checklist_array[i].Sub_items do
                    --scroll down
                    rectangle_vertical_pos = rectangle_vertical_pos - 10 -30
                    text_vertical_pos = text_vertical_pos - 10 -30
                end
            end
        end
    end

    if mouse_x >= 20 and mouse_x <= 20 + 30 and mouse_y >= rectangle_vertical_pos and mouse_y <= rectangle_vertical_pos + 30 then
        --skip to start
        set(current_checklist, 1)
        resize_checklist(all_checklist[get(current_checklist)])
    elseif mouse_x >= 60 and mouse_x <= 90 and mouse_y >= rectangle_vertical_pos and mouse_y <= rectangle_vertical_pos + 30 then
        --toggle camera control
        set(camera_control_active, 1 - get(camera_control_active))
    elseif mouse_x >= 100 and mouse_x <= 130 and mouse_y >= rectangle_vertical_pos and mouse_y <= rectangle_vertical_pos + 30 then
        --toggle soomth camera animation
        set(use_smooth_animation, 1 - get(use_smooth_animation))
    elseif mouse_x >= size[1] -20 - 30 and mouse_x <= size[1] -20 and mouse_y >= rectangle_vertical_pos and mouse_y <= rectangle_vertical_pos + 30 then
        --skip to end
        set(current_checklist, #all_checklist)
        resize_checklist(all_checklist[get(current_checklist)])
    end
end

local function arrows_control(checklist_array)
    --show and hide arrows
    set(show_small_arrow, 0)
    set(show_norm_arrow, 0)
    set(show_large_arrow, 0)

    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_PROPERTIES then--if the item is a checklist property
        elseif checklist_array[i].Type == CHECKLIST_LINE then--if the item is a line in the checklist
        elseif checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item
            if checklist_array[i].Viewing == true then--viewing item
                if checklist_array[i].Arrow == NO_ARROW then
                    --show and hide arrows
                    set(show_small_arrow, 0)
                    set(show_norm_arrow, 0)
                    set(show_large_arrow, 0)
                elseif checklist_array[i].Arrow == SMALL_ARROW then
                    --show and hide arrows
                    set(show_small_arrow, 1)
                    set(show_norm_arrow, 0)
                    set(show_large_arrow, 0)
                    --change arrow color
                    set(small_arrow_lit, (math.sin(get(TIME) * 2) + 1) / 2)
                    --transform arrow
                    set(small_arrow_tramsform_x, Set_anim_value(get(small_arrow_tramsform_x), checklist_array[i].X, -1000000, 1000000, 5))
                    set(small_arrow_tramsform_y, Set_anim_value(get(small_arrow_tramsform_y), checklist_array[i].Y, -1000000, 1000000, 5))
                    set(small_arrow_tramsform_z, Set_anim_value(get(small_arrow_tramsform_z), checklist_array[i].Z, -1000000, 1000000, 5))
                    set(small_arrow_rotate_x, Set_anim_value(get(small_arrow_rotate_x), checklist_array[i].X_rot, -1000000, 1000000, 5))
                    set(small_arrow_rotate_y, Set_anim_value(get(small_arrow_rotate_y), checklist_array[i].Y_rot, -1000000, 1000000, 5))
                    set(small_arrow_rotate_z, Set_anim_value(get(small_arrow_rotate_z), checklist_array[i].Z_rot, -1000000, 1000000, 5))
                elseif checklist_array[i].Arrow == NORM_ARROW then
                    --show and hide arrows
                    set(show_small_arrow, 0)
                    set(show_norm_arrow, 1)
                    set(show_large_arrow, 0)
                    --change arrow color
                    set(norm_arrow_lit, (math.sin(get(TIME) * 2) + 1) / 2)
                    --transform arrow
                    set(norm_arrow_tramsform_x, Set_anim_value(get(norm_arrow_tramsform_x), checklist_array[i].X, -1000000, 1000000, 5))
                    set(norm_arrow_tramsform_y, Set_anim_value(get(norm_arrow_tramsform_y), checklist_array[i].Y, -1000000, 1000000, 5))
                    set(norm_arrow_tramsform_z, Set_anim_value(get(norm_arrow_tramsform_z), checklist_array[i].Z, -1000000, 1000000, 5))
                    set(norm_arrow_rotate_x, Set_anim_value(get(norm_arrow_rotate_x), checklist_array[i].X_rot, -1000000, 1000000, 5))
                    set(norm_arrow_rotate_y, Set_anim_value(get(norm_arrow_rotate_y), checklist_array[i].Y_rot, -1000000, 1000000, 5))
                    set(norm_arrow_rotate_z, Set_anim_value(get(norm_arrow_rotate_z), checklist_array[i].Z_rot, -1000000, 1000000, 5))
                elseif checklist_array[i].Arrow == LARGE_ARROW then
                    --show and hide arrows
                    set(show_small_arrow, 0)
                    set(show_norm_arrow, 0)
                    set(show_large_arrow, 1)
                    --change arrow color
                    set(large_arrow_lit, (math.sin(get(TIME) * 2) + 1) / 2)
                    --transform arrow
                    set(large_arrow_tramsform_x, Set_anim_value(get(large_arrow_tramsform_x), checklist_array[i].X, -1000000, 1000000, 5))
                    set(large_arrow_tramsform_y, Set_anim_value(get(large_arrow_tramsform_y), checklist_array[i].Y, -1000000, 1000000, 5))
                    set(large_arrow_tramsform_z, Set_anim_value(get(large_arrow_tramsform_z), checklist_array[i].Z, -1000000, 1000000, 5))
                    set(large_arrow_rotate_x, Set_anim_value(get(large_arrow_rotate_x), checklist_array[i].X_rot, -1000000, 1000000, 5))
                    set(large_arrow_rotate_y, Set_anim_value(get(large_arrow_rotate_y), checklist_array[i].Y_rot, -1000000, 1000000, 5))
                    set(large_arrow_rotate_z, Set_anim_value(get(large_arrow_rotate_z), checklist_array[i].Z_rot, -1000000, 1000000, 5))
                end
            end
        end
    end
end

local function view_control(checklist_array)
    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_PROPERTIES then--if the item is a checklist property
        elseif checklist_array[i].Type == CHECKLIST_LINE then--if the item is a line in the checklist
        elseif checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item
            if checklist_array[i].Viewing == true then--viewing item
                if checklist_array[i].Quickview == VIEW_AVAILABLE then--if a view is available
                    if get(use_smooth_animation) == 1 then--if smooth animation is enabled
                        set(Head_x, Set_anim_value(get(Head_x), checklist_array[i].Head_x, -1000000, 1000000, 10))
                        set(Head_y, Set_anim_value(get(Head_y), checklist_array[i].Head_y, -1000000, 1000000, 10))
                        set(Head_z, Set_anim_value(get(Head_z), checklist_array[i].Head_z, -1000000, 1000000, 10))
                        set(Head_phi, Set_anim_value(get(Head_phi), checklist_array[i].Head_phi, -1000000, 1000000, 10))
                        set(Head_psi, Set_anim_value(get(Head_psi), checklist_array[i].Head_psi, -1000000, 1000000, 10))
                        set(Head_the, Set_anim_value(get(Head_the), checklist_array[i].Head_the, -1000000, 1000000, 10))
                    else--if smooth animation is disabled
                        set(Head_x, checklist_array[i].Head_x)
                        set(Head_y, checklist_array[i].Head_y)
                        set(Head_z, checklist_array[i].Head_z)
                        set(Head_phi, checklist_array[i].Head_phi)
                        set(Head_psi, checklist_array[i].Head_psi)
                        set(Head_the, checklist_array[i].Head_the)
                    end
                end
            end
        end
    end
end

local function clear_views(checklist_array)
    for i = 1, #checklist_array do
        if checklist_array[i].Type == CHECKLIST_ITEM then--if the item is a checklist item
            --cycle the whole list and disable viewing of all other items
            for j = 1, #checklist_array do
                if checklist_array[j].Type == CHECKLIST_ITEM then--if the item is a checklist item
                    checklist_array[j].Viewing = false
                end
            end
        end
    end
end

--mouse click functionality
function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        if x >= 20 and x <= 20 + 30 and y >= size[2] - 20 - 30 and y <= size[2] - 20 then
            if get(current_checklist) ~= 1 then
                clear_views(all_checklist[get(current_checklist)])
                head_returning = true
                set(current_checklist, Math_clamp(get(current_checklist) - 1, 1, #all_checklist))
                resize_checklist(all_checklist[get(current_checklist)])
            end
        elseif x >= size[1] - 20 - 30 and x <= size[1] - 20 and y >= size[2] - 20 - 30 and y <= size[2] - 20 then
            if get(current_checklist) ~= #all_checklist then
                clear_views(all_checklist[get(current_checklist)])
                head_returning = true
                set(current_checklist, Math_clamp(get(current_checklist) + 1, 1, #all_checklist))
                resize_checklist(all_checklist[get(current_checklist)])
            end
        else
            view_mouse_check(all_checklist[get(current_checklist)], x, y)
            check_mouse_check(all_checklist[get(current_checklist)], x, y)
            special_mouse_check(all_checklist[get(current_checklist)], x, y)
        end
    end
end

function update()
    --change menu item state
    if Checklist_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideChecklist, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideChecklist, MENU_UNCHECKED)
    end

    arrows_control(all_checklist[get(current_checklist)])

    --control the camera if the camera control is active
    if get(camera_control_active) == 1 then
        --view controls
        view_control(all_checklist[get(current_checklist)])

        --returning head position to previous
        if head_returning == true then
            if get(use_smooth_animation) == 1 then--if smooth animation is enabled
                set(Head_x, Set_anim_value(get(Head_x), previous_head_x, -1000000, 1000000, 10))
                set(Head_y, Set_anim_value(get(Head_y), previous_head_y, -1000000, 1000000, 10))
                set(Head_z, Set_anim_value(get(Head_z), previous_head_z, -1000000, 1000000, 10))
                set(Head_phi, Set_anim_value(get(Head_phi), previous_head_phi, -1000000, 1000000, 10))
                set(Head_psi, Set_anim_value(get(Head_psi), previous_head_psi, -1000000, 1000000, 10))
                set(Head_the, Set_anim_value(get(Head_the), previous_head_the, -1000000, 1000000, 10))
            else
                set(Head_x, previous_head_x)
                set(Head_y, previous_head_y)
                set(Head_z, previous_head_z)
                set(Head_phi, previous_head_phi)
                set(Head_psi, previous_head_psi)
                set(Head_the, previous_head_the)
            end

            --check proximity--
            if (get(Head_x) - previous_head_x < 0.01 and get(Head_x) - previous_head_x > -0.01) and
               (get(Head_y) - previous_head_y < 0.01 and get(Head_y) - previous_head_y > -0.01) and
               (get(Head_z) - previous_head_z < 0.01 and get(Head_z) - previous_head_z > -0.01) and
               (get(Head_phi) - previous_head_phi < 0.1 and get(Head_phi) - previous_head_phi > -0.1) and
               (get(Head_psi) - previous_head_psi < 0.1 and get(Head_psi) - previous_head_psi > -0.1) and
               (get(Head_the) - previous_head_the < 0.1 and get(Head_the) - previous_head_the > -0.1) then
                --close enough to stop the return
                head_returning = false
            end
        end
    else--stop any kind of camera movement
        head_returning = false
    end
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)
    sasl.gl.drawRectangle(10, 10, size[1] - 20, size[2] - 20, DARK_GREY)

    draw_checklist(all_checklist[get(current_checklist)])

    --previous page button
    if get(current_checklist) ~= 1 then
        sasl. gl.drawRectangle(20, size[2] - 20 - 30, 30, 30, LIGHT_GREY)
        sasl.gl.drawTriangle ( 20 + 5, (size[2] - 20 - 30 + size[2] - 20 - 30 + 30) / 2 , 20 + 25, size[2] - 20 - 30 + 25, 20 + 25, size[2] - 20 - 30 + 5, WHITE)
    end

    --next page button
    if get(current_checklist) ~= #all_checklist then
        sasl. gl.drawRectangle(size[1] - 20 - 30, size[2] - 20 - 30, 30, 30, LIGHT_GREY)
        sasl.gl.drawTriangle (size[1] - 20 - 30 + 25, (size[2] - 20 - 30 + size[2] - 20 - 30 + 30) / 2 , size[1] - 20 - 30 + 5, size[2] - 20 - 30 + 25, size[1] - 20 - 30 + 5, size[2] - 20 - 30 + 5, WHITE)
    end
end