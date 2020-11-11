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
        sasl.gl.drawWideLine(size[1]/2-38, size[2]/2-219, size[1]/2-38, size[2]/2-219-length, 3, failed and ECAM_ORANGE or ECAM_GREEN)
    else
        sasl.gl.drawWideLine(size[1]/2-35, size[2]/2-219, size[1]/2-35+length*math.sin(3.14/4), size[2]/2-219-length*math.sin(3.14/4), 3, ECAM_ORANGE)
    end

end

local function draw_press_info()
    --pressure info
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-170, size[2]/2+150, Round_fill(get(Cabin_delta_psi), 1), 40, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+140, size[2]/2+177, math.floor(get(Cabin_vs)-(get(Cabin_vs)%50)), 40, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-50, size[2]/2+150, math.floor(get(Cabin_alt_ft)-(get(Cabin_alt_ft)%50)),40, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
end

local function draw_pack_indications()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-304, 140, "PACK 1", 36, false, false, TEXT_ALIGN_CENTER, get(Ecam_press_pack_1_triangle) == 1 and ECAM_WHITE or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+330, 140, "PACK 2", 36, false, false, TEXT_ALIGN_CENTER, get(Ecam_press_pack_2_triangle) == 1 and ECAM_WHITE or ECAM_ORANGE)
end

local function draw_valves_text()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-205, 270, "INLET", 34, false, false, TEXT_ALIGN_CENTER, get(FAILURE_AVIONICS_INLET) == 1 and ECAM_ORANGE or ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-10, 270, "OUTLET", 34, false, false, TEXT_ALIGN_CENTER, get(FAILURE_AVIONICS_OUTLET) == 1 and ECAM_ORANGE or ECAM_WHITE)

    local faulty_blower_or_extract = get(FAILURE_AIRCOND_VENT_BLOWER) == 1 or get(FAILURE_AIRCOND_VENT_EXTRACT) == 1
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-115, 330, "VENT", 34, false, false, TEXT_ALIGN_CENTER, faulty_blower_or_extract and ECAM_ORANGE or ECAM_WHITE)

    if get(FAILURE_AIRCOND_VENT_BLOWER) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-240, 330, "BLOWER", 34, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_AIRCOND_VENT_EXTRACT) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+20, 330, "EXTRACT", 34, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_ldg_elev()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-100, size[2]-50, "LDG ELEV", 34, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    if get(Press_ldg_elev_knob_pos) >= -2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+80, size[2]-50, "MAN", 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+80, size[2]-50, "AUTO", 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end
    
    if true then    -- TODO Hide when MODE SEL NOT AUTO
        local selected = get(Press_ldg_elev_knob_pos) >= -2 and get(Press_ldg_elev_knob_pos)*1000 or 0 -- TODO ADD COMPUTED FROM MCDU HERE
        selected = selected - selected%50
        sasl.gl.drawText(Font_AirbusDUL, size[1]-130, size[2]-50, "FT", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]-150, size[2]-50, selected, 34, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end
end

local function draw_safety_valve()
    local is_open = get(Press_safety_valve_pos) == 1
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]-175, size[2]/2-15, "SAFETY", 34, false, false, TEXT_ALIGN_LEFT, is_open and ECAM_ORANGE or ECAM_WHITE)

    local length=58
    if is_open then
        sasl.gl.drawWideLine(size[1]-84, size[2]/2-30, size[1]-84+length, size[2]/2-30, 3, ECAM_ORANGE)
    else
        sasl.gl.drawWideLine(size[1]-89, size[2]/2-36, size[1]-89, size[2]/2-36-length, 3, ECAM_WHITE)
    end
end

function draw_press_page()

    draw_press_info()
    draw_valves_text()
    draw_valve_inlet(get(Ventilation_avio_inlet_valve), get(FAILURE_AVIONICS_INLET) == 1)
    draw_valve_outlet(get(Ventilation_avio_outlet_valve), get(FAILURE_AVIONICS_OUTLET) == 1)
    draw_safety_valve()
    
    draw_pack_indications()
    draw_ldg_elev()
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
