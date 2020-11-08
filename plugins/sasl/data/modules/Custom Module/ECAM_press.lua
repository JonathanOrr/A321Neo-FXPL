size = {900, 900}
include('constants.lua')

local function draw_valve_inlet(pos, failed)

    local length = 58

    if math.floor(pos) == 0 then
        sasl.gl.drawWideLine(size[1]/2-179, size[2]/2-214, size[1]/2-179-length, size[2]/2-214, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    elseif math.ceil(pos) == 10 then
        sasl.gl.drawWideLine(size[1]/2-173, size[2]/2-219, size[1]/2-173, size[2]/2-219-length, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    else
        sasl.gl.drawWideLine(size[1]/2-176, size[2]/2-217, size[1]/2-176-length*math.sin(3.14/4), size[2]/2-217-length*math.sin(3.14/4), 3, ECAM_ORANGE)
    end

end

local function draw_valve_outlet(pos, failed)

    local length = 58

    if math.floor(pos) == 0 then
        sasl.gl.drawWideLine(size[1]/2-33, size[2]/2-214, size[1]/2-33+length, size[2]/2-214, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    elseif math.ceil(pos) == 5 then
        sasl.gl.drawWideLine(size[1]/2-35, size[2]/2-219, size[1]/2-35+length*math.sin(3.14/4), size[2]/2-219-length*math.sin(3.14/4), 3, failed and ECAM_ORANGE or ECAM_GREEN)
    elseif math.ceil(pos) == 10 then
        sasl.gl.drawWideLine(size[1]/2-38, size[2]/2-220, size[1]/2-38, size[2]/2-220-length, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    else
        sasl.gl.drawWideLine(size[1]/2-35, size[2]/2-219, size[1]/2-35+length*math.sin(3.14/4), size[2]/2-219-length*math.sin(3.14/4), 3, ECAM_ORANGE)
    end

end

local function draw_press_info()
    --pressure info
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-225, size[2]/2+150, math.floor(get(Cabin_delta_psi)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+30, size[2]/2+180, math.floor(get(Cabin_vs)), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+290, size[2]/2+150, math.floor(get(Cabin_alt_ft)), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
end

local function draw_pack_indications()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-304, 140, "PACK 1", 36, false, false, TEXT_ALIGN_CENTER, get(Ecam_press_pack_1_triangle) == 1 and ECAM_WHITE or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+330, 140, "PACK 2", 36, false, false, TEXT_ALIGN_CENTER, get(Ecam_press_pack_2_triangle) == 1 and ECAM_WHITE or ECAM_ORANGE)
end

function draw_press_page()

    draw_press_info()
    draw_valve_inlet(get(Ventilation_avio_inlet_valve), false)  -- TODO Add failure
    draw_valve_outlet(get(Ventilation_avio_outlet_valve), false)  -- TODO Add failure

    draw_pack_indications()
end

function ecam_update_press_page()

    -- Pack indication is amber when pack not available and associated engine running
    if get(Pack_L) == 0 and get(Engine_1_avail) == 1 then
        set(Ecam_press_pack_1_triangle, 0)    
    else
        set(Ecam_press_pack_1_triangle, 1)
    end

    if get(Pack_R) == 0 and get(Engine_2_avail) == 1 then
        set(Ecam_press_pack_2_triangle, 0)    
    else
        set(Ecam_press_pack_2_triangle, 1)
    end


end
