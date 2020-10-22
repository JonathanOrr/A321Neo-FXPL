size = {900, 900}
include('constants.lua')

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local last_params_update = 0

local params = {
    eng1_oil_press = 0,
    eng2_oil_press = 0,
    eng1_oil_temp = 0,
    eng2_oil_temp = 0,
    eng1_vib_n1 = 0,
    eng1_vib_n2 = 0,
    eng1_vib_n1 = 0,
    eng2_vib_n2 = 0,
    last_update = 0
}

local function draw_fuel_usage()
    local fuel_usage_1 = math.floor(get(Ecam_fuel_usage_1))
    local fuel_usage_2 = math.floor(get(Ecam_fuel_usage_2))

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 760, fuel_usage_1, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 760, fuel_usage_2, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_oil_press = math.floor(get(Eng_1_OIL_press))
        params.eng2_oil_press = math.floor(get(Eng_2_OIL_press))
        params.eng1_oil_temp  = math.floor(get(Eng_1_OIL_temp))
        params.eng2_oil_temp  = math.floor(get(Eng_2_OIL_temp))
        params.eng1_vib_n1    = get(Eng_1_VIB_N1)
        params.eng1_vib_n2    = get(Eng_1_VIB_N2)
        params.eng2_vib_n1    = get(Eng_2_VIB_N1)
        params.eng2_vib_n2    = get(Eng_2_VIB_N2)
        params.last_update = get(TIME)
    end

end

local function draw_oil_qt_press_temp()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-153, 625, math.floor(get(Eng_1_OIL_qty)) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-136, 625, math.floor((get(Eng_1_OIL_qty)%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+223, 625, math.floor(get(Eng_2_OIL_qty)) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+240, 625, math.floor((get(Eng_2_OIL_qty)%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-165, 525, params.eng1_oil_press, 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+213, 525, params.eng2_oil_press ,36,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 455, params.eng1_oil_temp ,36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 455, params.eng2_oil_temp ,36,
                    false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

                    
end

local function draw_vibrations()
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-175, 385, math.floor(params.eng1_vib_n1) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-155, 385, math.floor((params.eng1_vib_n1%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, 385, math.floor(params.eng2_vib_n1) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+220, 385, math.floor((params.eng2_vib_n1%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-175, 350, math.floor(params.eng1_vib_n2) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-155, 350, math.floor((params.eng1_vib_n2%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, 350, math.floor(params.eng2_vib_n2) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+220, 350, math.floor((params.eng2_vib_n2%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
end

local function draw_bleed()

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-188, 136, math.floor(get(L_bleed_press)), 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+192, 136, math.floor(get(R_bleed_press)), 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
end

local function draw_special()
    
    if get(FAILURE_ENG_1_FUEL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 720, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_ENG_2_FUEL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 720, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_ENG_1_OIL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 490, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_ENG_2_OIL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 490, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end    
end

local function draw_ignition()

      if get(Ecam_eng_igniter_eng_1) % 2 == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-202, 250, "A" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end
      if get(Ecam_eng_igniter_eng_1) >= 2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-177, 250, "B" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end

      if get(Ecam_eng_igniter_eng_2) % 2 == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+180, 250, "A" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end
      if get(Ecam_eng_igniter_eng_2) >= 2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+205, 250, "B" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end
end

function draw_eng_page()

    draw_fuel_usage()
    draw_oil_qt_press_temp()
    draw_vibrations()
    draw_special()
    draw_ignition()
    
    draw_bleed()

end
