position = {1717, 1405, 160, 61}
size = {160, 61}

local overhead_integral = nil

local batLED = LED7Seg:new({}, "a321neo/led/bat2", 2, 1)

function draw()
    overhead_integral = overhead_integral or globalPropertyf("a321neo/cockpit/lights/overhead_integral_value")
    local LED_cl_start      = {70/255, 70/255, 70/255, 0.75}
    local LED_cl_back_start = {1/255, 1/255, 1/255, 1}

    local LED_cl_end        = {235/255, 200/255, 135/255, 1}
    local LED_cl_back_end   = {5/255, 15/255, 10/255, 1}

    local LED_cl       = {}
    local LED_cl_back  = {}
    for i=1,4 do
        LED_cl[i] = (LED_cl_end[i]-LED_cl_start[i]) * get(overhead_integral) + LED_cl_start[i]
        LED_cl_back[i] = (LED_cl_back_end[i]-LED_cl_back_start[i]) * get(overhead_integral) + LED_cl_back_start[i]
    end
        
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, get(overhead_integral))
    Draw_green_LED_num_and_letter(size[1] / 2 + 10, size[2] / 2 - 25, math.floor(math.abs(get(Elec_bat_2_V))), 2, 74, TEXT_ALIGN_RIGHT, 0.2, 1, 1, LED_cl, LED_cl_back)
    sasl.gl.drawText(Font_7_digits, size[1] / 2 + 16, size[2] / 2 - 25, ".", 74, false, false, TEXT_ALIGN_CENTER, LED_cl)
    Draw_green_LED_num_and_letter(size[1] / 2 + 40, size[2] / 2 - 25, Math_extract_decimal(get(Elec_bat_2_V), 1, true), 1, 74, TEXT_ALIGN_CENTER, 0.2, 1, 1, LED_cl, LED_cl_back)
    
    batLED:clear()
    batLED:display(get(Elec_bat_2_V))
end
