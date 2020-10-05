size = {900, 900}
include('constants.lua')

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

FUEL_TANK_C  = 0
FUEL_TANK_L  = 1
FUEL_TANK_R  = 2


local function draw_tank_qty()

    local fuel_C  = math.floor(get(Fuel_quantity[FUEL_TANK_C]))
    local fuel_L  = math.floor(get(Fuel_quantity[FUEL_TANK_L]))
    local fuel_R  = math.floor(get(Fuel_quantity[FUEL_TANK_R]))

    local c_pump_fail_or_off = true -- TODO

    -- Quantities per tank
    sasl.gl.drawText(B612MONO_regular, size[2]/2, size[2]/2, fuel_C, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, size[2]/2-300, size[2]/2, fuel_L, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, size[2]/2+300, size[2]/2, fuel_R, 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    -- Box center tank
    if c_pump_fail_or_off then
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2-10, size[1]/2+70, size[2]/2-10, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-70, size[2]/2-12, size[1]/2-70, size[2]/2+30, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2+70, size[2]/2-12, size[1]/2+70, size[2]/2+30, 3 , ECAM_ORANGE)
    end
    
    local fob = math.floor(get(FOB))
    -- FOB
    sasl.gl.drawText(B612MONO_regular, size[2]/2-130, size[2]/2-310, fob, 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    -- Box FOB
    if c_pump_fail_or_off then
        sasl.gl.drawWideLine(size[1]/2-230, size[2]/2-315, size[1]/2-120, size[2]/2-315, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-230, size[2]/2-317, size[1]/2-230, size[2]/2-280, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2-120, size[2]/2-317, size[1]/2-120, size[2]/2-280, 3 , ECAM_ORANGE)
    end
end

function draw_fuel_page()

    draw_tank_qty()
end
