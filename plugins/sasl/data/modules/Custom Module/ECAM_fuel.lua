size = {900, 900}
include('constants.lua')

FUEL_TANK_C  = 0
FUEL_TANK_L  = 1
FUEL_TANK_R  = 2
FUEL_TANK_ACT  = 3
FUEL_TANK_RCT  = 4

local function draw_wide_frame(x1,y1,x2,y2,width,color)
        sasl.gl.drawWideLine(x1,y1-width/2,x1,y2+width/2,width,color)
        sasl.gl.drawWideLine(x1,y2,x2,y2,width,color)
        sasl.gl.drawWideLine(x2,y2+width/2,x2,y1-width/2,width,color)
        sasl.gl.drawWideLine(x2,y1,x1,y1,width,color)
end

local function draw_open_arrow_up(x,y,color)
    sasl.gl.drawWidePolyLine( {x, y, x-10, y-15, x+10, y-15, x, y }, 3, color)
end

local function draw_tank_qty()

    local fuel_C  = math.floor(get(Fuel_quantity[FUEL_TANK_C]))
    local fuel_L  = math.floor(get(Fuel_quantity[FUEL_TANK_L]))
    local fuel_R  = math.floor(get(Fuel_quantity[FUEL_TANK_R]))
    local fuel_ACT= math.floor(get(Fuel_quantity[FUEL_TANK_ACT]))
    local fuel_RCT= math.floor(get(Fuel_quantity[FUEL_TANK_RCT]))
    
    local c_pump_fail_or_off = true -- TODO
    
    local act_pump_fail = false -- TODO
    local rct_pump_fail = true  -- TODO

    -- Quantities per tank
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2, size[2]/2, fuel_C, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-300, size[2]/2, fuel_L, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2+300, size[2]/2, fuel_R, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    sasl.gl.drawText(B612MONO_regular, size[2]/2-100, size[2]/2-150, fuel_ACT, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, size[2]/2+100, size[2]/2-150, fuel_RCT, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    sasl.gl.drawText(B612MONO_regular, size[2]/2-100, size[2]/2-188, "ACT", 28, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    draw_wide_frame(size[2]/2+40, size[2]/2-160, size[2]/2+160, size[2]/2-120, 3, act_pump_fail and ECAM_ORANGE or ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, size[2]/2+100, size[2]/2-188, "RCT", 28, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    draw_wide_frame(size[2]/2-40, size[2]/2-160, size[2]/2-160, size[2]/2-120, 3, rct_pump_fail and ECAM_ORANGE or ECAM_WHITE)
    
    -- Box center tank
    if c_pump_fail_or_off then
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2-10, size[1]/2+70, size[2]/2-10, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2-12, size[1]/2-70, size[2]/2+30, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2+70, size[2]/2-12, size[1]/2+70, size[2]/2+30, 3 , ECAM_ORANGE)
    end

end

local function draw_fob_qty()

    local any_failure = true -- TODO

    local fob = math.floor(get(FOB))
    -- FOB
    sasl.gl.drawText(Font_AirbusDUL, size[2]/2-130, size[2]/2-310, fob, 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    -- Box FOB
    if any_failure then
        sasl.gl.drawWideLine(size[1]/2-230, size[2]/2-315, size[1]/2-120, size[2]/2-315, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-230, size[2]/2-317, size[1]/2-230, size[2]/2-280, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-120, size[2]/2-317, size[1]/2-120, size[2]/2-280, 3 , ECAM_ORANGE)
    end
end

local function draw_arrows()

    local is_act_transfer_active = true     -- TODO
    local is_rct_transfer_active = true     -- TODO

    if is_act_transfer_active then
        draw_open_arrow_up(size[2]/2-70, size[2]/2-50, ECAM_GREEN)
        sasl.gl.drawWideLine(size[2]/2-70, size[2]/2-67, size[2]/2-70, size[2]/2-119, 3 , ECAM_GREEN)
    end
    if is_rct_transfer_active then
        draw_open_arrow_up(size[2]/2+70, size[2]/2-50, ECAM_GREEN)
        sasl.gl.drawWideLine(size[2]/2+70, size[2]/2-67, size[2]/2+70, size[2]/2-119, 3 , ECAM_GREEN)
    
    end
end

function draw_fuel_page()

    draw_tank_qty()
    draw_fob_qty()
    draw_arrows()
    
end
