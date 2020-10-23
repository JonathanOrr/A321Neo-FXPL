size = {900, 900}
include('constants.lua')

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local last_params_update = 0

local params = {
    eng1_vib_n1 = 0,
    eng1_vib_n2 = 0,
    eng2_vib_n1 = 0,
    eng2_vib_n2 = 0,
    last_update = 0
}

local function draw_fuel_usage()
    local fuel_usage_1 = math.floor(get(Ecam_fuel_usage_1))
    local fuel_usage_2 = math.floor(get(Ecam_fuel_usage_2))

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 760, "12345", 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 760, "12345", 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 730, fuel_usage_2+fuel_usage_2, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

end

local function draw_oil_qt()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-150, 650, math.floor(get(Eng_1_OIL_qty)) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 650, math.floor((get(Eng_1_OIL_qty)%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, 650, math.floor(get(Eng_2_OIL_qty)) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 650, math.floor((get(Eng_2_OIL_qty)%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
                    
end

local function draw_vibrations()
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-150, 560, math.floor(params.eng1_vib_n1) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 560, math.floor((params.eng1_vib_n1%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, 560, math.floor(params.eng2_vib_n1) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 560, math.floor((params.eng2_vib_n1%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-150, 520, math.floor(params.eng1_vib_n2) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 520, math.floor((params.eng1_vib_n2%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
                    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, 520, math.floor(params.eng2_vib_n2) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 520, math.floor((params.eng2_vib_n2%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
end

local function draw_temps()
    --temperatures 
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-330, size[2]/2-250, math.floor(get(Cockpit_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-190, size[2]/2-250, math.floor(get(Front_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-70, size[2]/2-250, math.floor(get(Aft_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    --cab press
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+10, size[2]/2-105, Round(get(Cabin_delta_psi),1), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+300, size[2]/2-185, math.floor(get(Cabin_vs)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+300, size[2]/2-290, math.floor(get(Cabin_alt_ft)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
end

function draw_cruise_page()
    draw_temps()
    draw_fuel_usage()
    draw_oil_qt()
    draw_vibrations()
end

function ecam_update_cruise_page()
    
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_vib_n1    = get(Eng_1_VIB_N1)
        params.eng1_vib_n2    = get(Eng_1_VIB_N2)
        params.eng2_vib_n1    = get(Eng_2_VIB_N1)
        params.eng2_vib_n2    = get(Eng_2_VIB_N2)
        params.last_update = get(TIME)
    end
    
end
