-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: fuel_window.lua
-- Short description: Refuel window
-------------------------------------------------------------------------------


size = {840, 600}



local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local SevenSegment = sasl.gl.loadFont("fonts/DSEG7ModernMini-Light.ttf")

local EMPTY    = 0
local ON       = 1
local OFF      = 2
local ON_WHITE = 3
local MANUAL   = 4
local NORM     = 5

local LEFT  = 1
local RIGHT = 2
local CENTER= 0
local ACT   = 3
local RCT   = 4

local KG_PER_SEC = 15

local image_background     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/background.png", 0, 0, 493, 586)
local image_plane          = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/top-alpha.png", 0, 0, 497, 606)
local image_end            = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/end-light.png", 0, 0, 31, 31)
local image_selector = {}
image_selector[0]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/selector-C.png", 0, 0, 66, 50)
image_selector[1]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/selector-L.png", 0, 0, 66, 50)
image_selector[2]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/selector-R.png", 0, 0, 66, 50)
local image_btn = {}
image_btn[EMPTY]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-empty.png", 0, 0, 128, 128)
image_btn[OFF]       = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-off.png", 0, 0, 128, 128)
image_btn[ON]        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-on.png", 0, 0, 128, 128)
image_btn[ON_WHITE]        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-on-white.png", 0, 0, 128, 128)
image_btn[MANUAL] = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-man.png", 0, 0, 128, 128)
image_btn[NORM] = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-norm.png", 0, 0, 128, 128)

local selector_switch_pos   = 0
local battery_switch_status = false
local refuel_switch_status  = false
local mode_sel_switch_status= false
local valve_switch_status   = {}
valve_switch_status[LEFT]   = false
valve_switch_status[RIGHT]  = false
valve_switch_status[CENTER] = false
valve_switch_status[ACT]    = false
valve_switch_status[RCT]    = false

local btn_light_battery = EMPTY
local btn_light_refuel  = EMPTY
local btn_light_mode_sel= EMPTY
local btn_light_left    = EMPTY
local btn_light_right   = EMPTY
local btn_light_center  = EMPTY
local btn_light_act     = EMPTY
local btn_light_rct     = EMPTY

local presel_value = 0
local start_press_time = 0
local last_update_press_time = 0
local remaining_time = 0
local end_light = false
local defueling = false

local fast_speed = false

local function update_btn_status()

    btn_light_battery = (battery_switch_status and ON or (get(XP_Battery_1) == 1 and NORM or EMPTY))

    btn_light_left    = EMPTY
    btn_light_right   = EMPTY
    btn_light_center  = EMPTY
    btn_light_act     = EMPTY
    btn_light_rct     = EMPTY

    if btn_light_battery ~= EMPTY then   -- we have elec power
        btn_light_refuel   = refuel_switch_status   and ON or OFF
        btn_light_mode_sel = mode_sel_switch_status and MANUAL or EMPTY
        
        if mode_sel_switch_status then
            btn_light_left    = valve_switch_status[LEFT]   and ON or OFF
            btn_light_right   = valve_switch_status[RIGHT]  and ON or OFF
            btn_light_center  = valve_switch_status[CENTER] and ON or OFF
            btn_light_act     = valve_switch_status[ACT]    and ON or OFF
            btn_light_rct     = valve_switch_status[RCT]    and ON or OFF
        end
        
    else
        btn_light_refuel   = EMPTY
        btn_light_mode_sel = EMPTY
        refuel_switch_status = false
        mode_sel_switch_status = false
    end
    
end

function update_desired_qty()
    if btn_light_battery == EMPTY then
        return
    end

    if selector_switch_pos == 0 then
        start_press_time = 0
        return
    elseif start_press_time == 0 then
        start_press_time = get(TIME)
    end

    local multiplier = 1

    if get(TIME) - start_press_time > 6 then
        multiplier = 50
    elseif get(TIME) - start_press_time > 3 then
        multiplier = 5
    end

    if get(TIME) - last_update_press_time < 0.05/multiplier then
        return
    end

    if selector_switch_pos == 1 then
        presel_value = presel_value - multiplier
    elseif selector_switch_pos == 2 then
        presel_value = presel_value + multiplier
    end
    
    presel_value = Math_clamp(presel_value, 0, FUEL_TOT_MAX)
    
    last_update_press_time = get(TIME)
end

function update_refuel()
    end_light = false
    if btn_light_battery == EMPTY then
        return
    end
    
    if not refuel_switch_status then
        return
    end

    local diff = presel_value - get(FOB)
    
    if math.ceil(diff) == 0 then
        end_light = true
        return
    end
    
    if diff > 0 then
        defueling = false    
    else
        defueling = true
    end
    
    remaining_time = math.abs(diff)/KG_PER_SEC
    
    local tot_valves_open = ((valve_switch_status[LEFT]  and get(Fuel_quantity[LEFT]) <= FUEL_LR_MAX)   and 1 or 0) 
                          + ((valve_switch_status[RIGHT] and get(Fuel_quantity[RIGHT]) <= FUEL_LR_MAX)  and 1 or 0) 
                          + ((valve_switch_status[CENTER] and get(Fuel_quantity[CENTER]) <= FUEL_C_MAX) and 1 or 0)
                          + ((valve_switch_status[ACT] and get(Fuel_quantity[ACT]) <= FUEL_ACT_MAX)     and 1 or 0) 
                          + ((valve_switch_status[RCT] and get(Fuel_quantity[RCT]) <= FUEL_RCT_MAX)     and 1 or 0)

    local add = KG_PER_SEC * get(DELTA_TIME) / tot_valves_open * (diff >= 0 and 1 or -1)
    
    if fast_speed then
        add = add * 500
    end
    
    if valve_switch_status[LEFT] then
        local fuel_curr = get(Fuel_quantity[LEFT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, FUEL_LR_MAX)
        set(Fuel_quantity[LEFT], fuel_next)
    end
    if valve_switch_status[RIGHT] then
        local fuel_curr = get(Fuel_quantity[RIGHT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, FUEL_LR_MAX)
        set(Fuel_quantity[RIGHT], fuel_next)     
    end
    if valve_switch_status[CENTER] then
        local fuel_curr = get(Fuel_quantity[CENTER])
        local fuel_next = Math_clamp(fuel_curr + add, 0, FUEL_C_MAX)
        set(Fuel_quantity[CENTER], fuel_next)
    end
    if valve_switch_status[ACT] then
        local fuel_curr = get(Fuel_quantity[ACT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, FUEL_ACT_MAX)
        set(Fuel_quantity[ACT], fuel_next)
    end
    if valve_switch_status[RCT] then
        local fuel_curr = get(Fuel_quantity[RCT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, FUEL_RCT_MAX)
        set(Fuel_quantity[RCT], fuel_next)
    end
 
end

local function update_auto_mode()
    if not refuel_switch_status then
        return  -- Refuel is not active
    end
    if mode_sel_switch_status then
        return  -- Manual mode
    end
    
    valve_switch_status[LEFT]  = false
    valve_switch_status[RIGHT] = false
    valve_switch_status[CENTER]= false
    valve_switch_status[ACT]   = false
    valve_switch_status[RCT]   = false
    
    if end_light == true then
        return  -- Refuel end
    end
    
    if not defueling then
        if (get(Fuel_quantity[LEFT]) < FUEL_LR_MAX or get(Fuel_quantity[RIGHT]) < FUEL_LR_MAX) then
            valve_switch_status[LEFT] = true
            valve_switch_status[RIGHT] = true
        elseif get(Fuel_quantity[CENTER]) < FUEL_C_MAX then
            valve_switch_status[CENTER] = true
        elseif get(Fuel_quantity[ACT]) < FUEL_ACT_MAX or get(Fuel_quantity[RCT]) < FUEL_RCT_MAX then
            valve_switch_status[ACT] = true
            valve_switch_status[RCT] = true
        end
    else
        if get(Fuel_quantity[ACT]) > 0 or get(Fuel_quantity[RCT]) > 0 then
            valve_switch_status[ACT] = true
            valve_switch_status[RCT] = true  
        elseif get(Fuel_quantity[CENTER]) > 0 then
            valve_switch_status[CENTER] = true      
        elseif (get(Fuel_quantity[LEFT]) > 0 or get(Fuel_quantity[RIGHT]) > 0) then
            valve_switch_status[LEFT] = true
            valve_switch_status[RIGHT] = true
        end
    
    end
    
end

local function update_ewd_refuelg()
    set(Fuel_is_refuelG, (battery_switch_status or refuel_switch_status) and 1 or 0)
end

function update()
    update_btn_status()
    update_desired_qty()
    
    update_auto_mode()
    update_refuel()
    update_ewd_refuelg()
    
end

local function draw_plane_icon()

    left_perc = math.floor(get(Fuel_quantity[LEFT]) / FUEL_LR_MAX * 100)
    
    sasl.gl.drawText(B612MONO_regular, 582, 160, "LEFT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(566, 180, 30, 92/1.75, UI_LIGHT_GREY)
    Sasl_DrawWideFrame(566, 180, 30, 92/1.75, 1, 1, UI_DARK_BLUE)
    sasl.gl.drawRectangle(566, 180, 30, 92/1.75*left_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 598, 240, left_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)

    right_perc = math.floor(get(Fuel_quantity[RIGHT]) / FUEL_LR_MAX * 100)

    sasl.gl.drawText(B612MONO_regular, 762, 160, "RIGHT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(746, 180, 30, 92/1.75, UI_LIGHT_GREY)
    Sasl_DrawWideFrame(746, 180, 30, 92/1.75, 1, 1, UI_DARK_BLUE)
    sasl.gl.drawRectangle(746, 180, 30, 92/1.75*right_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 778, 240, right_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)

    c_perc = math.floor(get(Fuel_quantity[CENTER]) / FUEL_C_MAX * 100)

    sasl.gl.drawText(B612MONO_regular, 672, 190, "CTR", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 205, 30, 64/1.75, UI_DARK_GREY)
    Sasl_DrawWideFrame(656, 205, 30, 64/1.75, 1, 1, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 205, 30, 64/1.75*c_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 688, 245, c_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)
    
    act_perc = math.floor(get(Fuel_quantity[ACT]) / FUEL_ACT_MAX * 100)
    
    sasl.gl.drawText(B612MONO_regular, 672, 275, "ACT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 290, 30, 50/1.75, UI_LIGHT_GREY)
    Sasl_DrawWideFrame(656, 290, 30, 50/1.75, 1, 1, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 290, 30, 50/1.75*act_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 688, 324, act_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)

    rct_perc = math.floor(get(Fuel_quantity[RCT]) / FUEL_RCT_MAX * 100)

    sasl.gl.drawText(B612MONO_regular, 672, 85, "RCT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 100, 30, 100/1.75, UI_LIGHT_GREY)
    Sasl_DrawWideFrame(656, 100, 30, 100/1.75, 1, 1, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 100, 30, 100/1.75*rct_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 688, 163, rct_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)
end

function draw()

    sasl.gl.drawTexture(image_background, 0, 0, 493, 586)
    sasl.gl.drawTexture(image_plane, 505, 0, 331, 404)

    draw_plane_icon()

    if end_light then
        sasl.gl.drawTexture(image_end, 196, 308, 31, 31)
    end
    
    sasl.gl.drawTexture(image_btn[btn_light_battery], 377, 336, 51, 51)
    sasl.gl.drawTexture(image_btn[btn_light_refuel], 45, 176, 51, 51)
    sasl.gl.drawTexture(image_selector[selector_switch_pos], 95, 253, 66, 42)
    sasl.gl.drawTexture(image_btn[btn_light_mode_sel], 135, 176, 51, 51)
    sasl.gl.drawTexture(image_btn[btn_light_left], 250, 176, 51, 51)
    sasl.gl.drawTexture(image_btn[btn_light_center], 321, 176, 51, 51)
    sasl.gl.drawTexture(image_btn[btn_light_right], 392, 176, 51, 51)
    sasl.gl.drawTexture(image_btn[btn_light_act], 276, 25, 51, 51)
    sasl.gl.drawTexture(image_btn[btn_light_rct], 366, 24, 51, 51)

    if get(Any_wheel_on_ground) == 0 then
        sasl.gl.drawText(B612MONO_regular, 585, 550, "You are AIRBONE!", 17, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_RED)
        sasl.gl.drawFrame(520, 540, 300, 32, UI_LIGHT_RED)
    end

    if refuel_switch_status then
        sasl.gl.drawText(B612MONO_regular, 530, 500, "Remaining time: ", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
        if not end_light then
            sasl.gl.drawText(B612MONO_regular, 730, 500, math.ceil(remaining_time/60) .. " min", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
        else
            sasl.gl.drawText(B612MONO_regular, 730, 500, "DONE", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)        
        end
        sasl.gl.drawRectangle (575, 440, 200, 30, UI_LIGHT_GREY)
        sasl.gl.drawText(B612MONO_regular, 625, 450, "Fast Refuel", 14, false, false, TEXT_ALIGN_LEFT, fast_speed and UI_LIGHT_BLUE or UI_WHITE)
    end

    sasl.gl.drawText(SevenSegment, 147, 457, 88.88, 18, false, false, TEXT_ALIGN_RIGHT, {0.25, 0.25, 0.25})
    sasl.gl.drawText(SevenSegment, 272, 457, 88.88, 18, false, false, TEXT_ALIGN_RIGHT, {0.25, 0.25, 0.25})
    sasl.gl.drawText(SevenSegment, 408, 457, 88.88, 18, false, false, TEXT_ALIGN_RIGHT, {0.25, 0.25, 0.25})
    sasl.gl.drawText(SevenSegment, 131, 72, 88.88, 18, false, false, TEXT_ALIGN_RIGHT, {0.25, 0.25, 0.25})
    sasl.gl.drawText(SevenSegment, 131, 21, 88.88, 18, false, false, TEXT_ALIGN_RIGHT, {0.25, 0.25, 0.25})
    sasl.gl.drawText(SevenSegment, 155, 316, 88.88, 18, false, false, TEXT_ALIGN_RIGHT, {0.25, 0.25, 0.25})
    sasl.gl.drawText(SevenSegment, 326, 316, 88.88, 18, false, false, TEXT_ALIGN_RIGHT, {0.25, 0.25, 0.25})

    if btn_light_battery ~= EMPTY then
        sasl.gl.drawText(SevenSegment, 147, 457, Round_fill(get(Fuel_quantity[LEFT])/1000,2), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 272, 457, Round_fill(get(Fuel_quantity[CENTER])/1000,2), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 408, 457, Round_fill(get(Fuel_quantity[RIGHT])/1000,2), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 131, 72, Round_fill(get(Fuel_quantity[ACT])/1000,2), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 131, 21, Round_fill(get(Fuel_quantity[RCT])/1000,2), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})

        sasl.gl.drawText(SevenSegment, 155, 316, Round_fill(presel_value/1000,2), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 326, 316, Round_fill(get(FOB)/1000,2), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
    end
end

function battery_handler()
    battery_switch_status = not battery_switch_status
end

function refuel_handler()
    refuel_switch_status = not refuel_switch_status
end

function mode_sel_handler()
    mode_sel_switch_status = not mode_sel_switch_status
end

function valve_handlers(which) 
    valve_switch_status[which] = not valve_switch_status[which]
end

function onMouseUp(component , x , y , button , parentX , parentY)
    selector_switch_pos = 0
end

function onMouseHold (component , x , y , button , parentX , parentY)
    if y >=253 and y <= 253+42 then
        if x >= 95 and x <= 95+30 then
            selector_switch_pos = 1
        elseif x >= 95+36 and x <= 95+66  then
            selector_switch_pos = 2
        end
    end

end

function onMouseDown (component , x , y , button , parentX , parentY)
    if y >=176 and y <= 176+51 then
        if x >= 250 and x <= 250+51     then
            valve_handlers(LEFT) 
        elseif x >= 321 and x <= 321+51 then
            valve_handlers(CENTER)
        elseif x >= 392 and x <= 392+51 then
            valve_handlers(RIGHT)
        elseif x >= 45 and x <= 45+51   then
            refuel_handler()
        elseif x >= 135 and x <= 135+51 then
            mode_sel_handler()
        end    
    elseif y >=24 and y <= 24+51 then
        if x >= 276 and x <= 276+51 then
            valve_handlers(ACT)
        elseif x >= 366 and x <= 366+51 then
            valve_handlers(RCT)
        end
    elseif x >= 377 and x <= 377+51 and y >=336 and y <= 336+51 then
        battery_handler()
    elseif x >= 575 and x <= 575+200 and y >= 440 and y <= 440+30 then
        fast_speed = not fast_speed
    end


    return true
end
