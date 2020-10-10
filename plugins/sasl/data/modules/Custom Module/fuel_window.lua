size = {840, 600}

include('constants.lua')


local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local SevenSegment = sasl.gl.loadFont("fonts/DSEG7ModernMini-Light.ttf")

local EMPTY = 0
local ON    = 1
local OFF   = 2
local SYSON = 3
local SYSON_MAN = 4

local LEFT  = 0
local RIGHT = 1
local CENTER= 2
local ACT   = 3
local RCT   = 4

local TOT_MAX_FUEL   = 40755
local LR_MAX_FUEL    = 9247
local C_MAX_FUEL     = 6445
local ACT_MAX_FUEL   = 5000
local RCT_MAX_FUEL   = 10062

local KG_PER_SEC = 15

local image_background     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/background.png", 0, 0, 493, 584)
local image_plane          = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/top-alpha.png", 0, 0, 497, 606)
local image_end            = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/end-light.png", 0, 0, 31, 31)
local image_selector = {}
image_selector[0]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/selector-C.png", 0, 0, 66, 42)
image_selector[1]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/selector-L.png", 0, 0, 66, 42)
image_selector[2]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/selector-R.png", 0, 0, 66, 42)
local image_btn = {}
image_btn[EMPTY]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-empty.png", 0, 0, 128, 128)
image_btn[OFF]       = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-off.png", 0, 0, 128, 128)
image_btn[ON]        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-on.png", 0, 0, 128, 128)
image_btn[SYSON]     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-syson.png", 0, 0, 128, 128)
image_btn[SYSON_MAN] = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fuel_window/btn-syson-man.png", 0, 0, 128, 128)

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

local function update_btn_status()

    btn_light_battery = (battery_switch_status or get(XP_Battery_1) == 1) and ON or EMPTY

    btn_light_left    = EMPTY
    btn_light_right   = EMPTY
    btn_light_center  = EMPTY
    btn_light_act     = EMPTY
    btn_light_rct     = EMPTY

    if btn_light_battery == ON then   -- we have elec power
        btn_light_refuel   = refuel_switch_status   and ON or OFF
        btn_light_mode_sel = mode_sel_switch_status and SYSON_MAN or SYSON
        
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
    if btn_light_battery ~= ON then
        return
    end

    if selector_switch_pos == 0 then
        start_press_time = 0
        return
    elseif start_press_time == 0 then
        start_press_time = get(TIME)
    end

    local multiplier = 1

    if get(TIME) - start_press_time > 9 then
        multiplier = 1000
    elseif get(TIME) - start_press_time > 6 then
        multiplier = 100
    elseif get(TIME) - start_press_time > 3 then
        multiplier = 10
    end

    if get(TIME) - last_update_press_time < 0.1 then
        return
    end

    if selector_switch_pos == 1 then
        presel_value = presel_value - multiplier
    elseif selector_switch_pos == 2 then
        presel_value = presel_value + multiplier
    end
    
    presel_value = Math_clamp(presel_value, 0, TOT_MAX_FUEL)
    
    last_update_press_time = get(TIME)
end

function update_refuel()
    end_light = false
    if btn_light_battery ~= ON then
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
    
    remaining_time = math.abs(diff)/KG_PER_SEC
    
    local tot_valves_open = (valve_switch_status[LEFT] and 1 or 0) 
                          + (valve_switch_status[RIGHT] and 1 or 0) 
                          + (valve_switch_status[CENTER] and 1 or 0)
                          + (valve_switch_status[ACT] and 1 or 0) 
                          + (valve_switch_status[RCT] and 1 or 0)

    local add = KG_PER_SEC * get(DELTA_TIME) / tot_valves_open * (diff >= 0 and 1 or -1)
    
    if valve_switch_status[LEFT] then
        local fuel_curr = get(Fuel_quantity[LEFT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, LR_MAX_FUEL)
        set(Fuel_quantity[LEFT], fuel_next)
    end
    if valve_switch_status[RIGHT] then
        local fuel_curr = get(Fuel_quantity[RIGHT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, LR_MAX_FUEL)
        set(Fuel_quantity[RIGHT], fuel_next)     
    end
    if valve_switch_status[CENTER] then
        local fuel_curr = get(Fuel_quantity[CENTER])
        local fuel_next = Math_clamp(fuel_curr + add, 0, C_MAX_FUEL)
        set(Fuel_quantity[CENTER], fuel_next)
    end
    if valve_switch_status[ACT] then
        local fuel_curr = get(Fuel_quantity[ACT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, ACT_MAX_FUEL)
        set(Fuel_quantity[ACT], fuel_next)
    end
    if valve_switch_status[RCT] then
        local fuel_curr = get(Fuel_quantity[RCT])
        local fuel_next = Math_clamp(fuel_curr + add, 0, RCT_MAX_FUEL)
        set(Fuel_quantity[RCT], fuel_next)
    end
 
end

function update()
    update_btn_status()
    update_desired_qty()
    
    update_refuel()
    
end

local function draw_plane_icon()

    left_perc = math.floor(get(Fuel_quantity[LEFT]) / LR_MAX_FUEL * 100)
    
    sasl.gl.drawText(B612MONO_regular, 582, 160, "LEFT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(566, 180, 30, 92/1.75, UI_LIGHT_GREY)
    sasl.gl.drawFrame(566, 180, 30, 92/1.75, UI_DARK_BLUE)
    sasl.gl.drawRectangle(566, 180, 30, 92/1.75*left_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 598, 240, left_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)

    right_perc = math.floor(get(Fuel_quantity[RIGHT]) / LR_MAX_FUEL * 100)

    sasl.gl.drawText(B612MONO_regular, 762, 160, "RIGHT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(746, 180, 30, 92/1.75, UI_LIGHT_GREY)
    sasl.gl.drawFrame(746, 180, 30, 92/1.75, UI_DARK_BLUE)
    sasl.gl.drawRectangle(746, 180, 30, 92/1.75*right_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 778, 240, right_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)

    c_perc = math.floor(get(Fuel_quantity[CENTER]) / C_MAX_FUEL * 100)

    sasl.gl.drawText(B612MONO_regular, 672, 190, "CTR", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 205, 30, 64/1.75, UI_DARK_GREY)
    sasl.gl.drawFrame(656, 205, 30, 64/1.75, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 205, 30, 64/1.75*c_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 688, 245, c_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)
    
    act_perc = math.floor(get(Fuel_quantity[ACT]) / ACT_MAX_FUEL * 100)
    
    sasl.gl.drawText(B612MONO_regular, 672, 275, "ACT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 290, 30, 50/1.75, UI_LIGHT_GREY)
    sasl.gl.drawFrame(656, 290, 30, 50/1.75, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 290, 30, 50/1.75*act_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 688, 324, act_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)

    rct_perc = math.floor(get(Fuel_quantity[RCT]) / RCT_MAX_FUEL * 100)

    sasl.gl.drawText(B612MONO_regular, 672, 85, "RCT", 14, false, false, TEXT_ALIGN_CENTER, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 100, 30, 100/1.75, UI_LIGHT_GREY)
    sasl.gl.drawFrame(656, 100, 30, 100/1.75, UI_DARK_BLUE)
    sasl.gl.drawRectangle(656, 100, 30, 100/1.75*rct_perc/100, UI_DARK_BLUE)
    sasl.gl.drawText(B612MONO_regular, 688, 163, rct_perc .. "%", 14, false, false, TEXT_ALIGN_RIGHT, UI_DARK_BLUE)
end

function draw()

    sasl.gl.drawTexture(image_background, 0, 0, 493, 584)
    sasl.gl.drawTexture(image_plane, 505, 0, 331, 404)

    draw_plane_icon()

    if end_light then
        sasl.gl.drawTexture(image_end, 350, 308, 31, 31)
    end
    
    sasl.gl.drawText(B612MONO_regular, 80, 245, "BATTERY", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_battery], 50, 180, 58, 58)

    sasl.gl.drawText(B612MONO_regular, 165, 265, "REFUEL", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(B612MONO_regular, 165, 245, "DEFUEL", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_refuel], 135, 180, 58, 58)

    sasl.gl.drawTexture(image_selector[selector_switch_pos], 90, 300, 66, 42)

    
    sasl.gl.drawText(B612MONO_regular, 250, 245, "MODE SEL", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(B612MONO_regular, 290, 227, "A", 14, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(B612MONO_regular, 290, 210, "U", 14, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(B612MONO_regular, 290, 193, "T", 14, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(B612MONO_regular, 290, 176, "O", 14, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_mode_sel], 220, 180, 58, 58)

    sasl.gl.drawText(B612MONO_regular, 80, 100, "LEFT", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_left], 50, 30, 58, 58)

    sasl.gl.drawText(B612MONO_regular, 165, 100, "CTR", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_center], 135, 30, 58, 58)
    
    sasl.gl.drawText(B612MONO_regular, 250, 100, "RIGHT", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_right], 220, 30, 58, 58)

    sasl.gl.drawText(B612MONO_regular, 335, 100, "ACT", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_act], 305, 30, 58, 58)

    sasl.gl.drawText(B612MONO_regular, 420, 100, "RCT", 15, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawTexture(image_btn[btn_light_rct], 390, 30, 58, 58)

    if get(Any_wheel_on_ground) == 0 then
        sasl.gl.drawText(B612MONO_regular, 585, 550, "You are AIRBONE!", 17, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_RED)
        sasl.gl.drawFrame(520, 540, 300, 32, UI_LIGHT_RED)
    end

    if refuel_switch_status then
        sasl.gl.drawText(B612MONO_regular, 530, 500, "Remaining time: ", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
        sasl.gl.drawText(B612MONO_regular, 730, 500, math.ceil(remaining_time/60) .. " min", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

        sasl.gl.drawRectangle (575, 440, 200, 30, UI_LIGHT_GREY)
        sasl.gl.drawText(B612MONO_regular, 585, 450, "Instantaneous Refuel", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    end
        
    if btn_light_battery == ON then
        sasl.gl.drawText(SevenSegment, 154, 455, math.floor(get(Fuel_quantity[LEFT])), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 282, 455, math.floor(get(Fuel_quantity[CENTER])), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 409, 455, math.floor(get(Fuel_quantity[RIGHT])), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 400, 230, math.floor(get(Fuel_quantity[ACT])), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 400, 180, math.floor(get(Fuel_quantity[RCT])), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})

        sasl.gl.drawText(SevenSegment, 150, 365, presel_value, 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
        sasl.gl.drawText(SevenSegment, 392, 365, math.floor(get(FOB)), 18, false, false, TEXT_ALIGN_RIGHT, {0, 0.6, 0.2})
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
    if x >= 85 and x <= 113 and y >=304 and y <= 339 then
        selector_switch_pos = 1
    elseif x >= 131 and x <= 160 and y >=304 and y <= 339 then
        selector_switch_pos = 2
    end
end

function onMouseDown (component , x , y , button , parentX , parentY)
    if x >= 50 and x <= 50+58 and y >=30 and y <= 30+58 then
        valve_handlers(LEFT) 
    elseif x >= 135 and x <= 135+58 and y >=30 and y <= 30+58 then
        valve_handlers(CENTER)
    elseif x >= 220 and x <= 220+58 and y >=30 and y <= 30+58 then
        valve_handlers(RIGHT)
    elseif x >= 305 and x <= 305+58 and y >=30 and y <= 30+58 then
        valve_handlers(ACT)
    elseif x >= 390 and x <= 390+58 and y >=30 and y <= 30+58 then
        valve_handlers(RCT)
    elseif x >= 50 and x <= 50+58 and y >=180 and y <= 180+58 then
        battery_handler()
    elseif x >= 135 and x <= 135+58 and y >=180 and y <= 180+58 then
        refuel_handler()
    elseif x >= 220 and x <= 220+58 and y >=180 and y <= 180+58 then
        mode_sel_handler()
    end

    return true
end
