MODE_QNH = 1
MODE_QFE = 2
MODE_STD = 3

UNIT_INHG = 1
UNIT_HPA  = 2


local LED_cl = {235/255, 200/255, 135/255}
local MIN_VALUE = 22.00
local MAX_VALUE = 32.49

local function Draw_green_LED_num_and_letter_lc(x, y, string, max_digits, size, alignment, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local LED_cl = {235/255, 200/255, 135/255, brightness}
    local LED_backlight_cl = {15/255, 20/255, 15/255}

    local backlight_string = ""

    for i = 1, max_digits do
        backlight_string = backlight_string .. 8
    end

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[3], brightness)

    sasl.gl.drawText(Font_7segment_led, x, y, backlight_string, size, false, false, alignment, {blacklight_R, blacklight_G, blacklight_B})
    sasl.gl.drawText(Font_7segment_led, x, y, string, size, false, false, alignment, LED_cl)
end

local function inhg_to_hpa(x)
    return 3386.39 * x
end

function setup_cmd_handlers(data)
    sasl.registerCommandHandler (data.dr.cmd_knob_push, 0, function(phase)
        if phase == SASL_COMMAND_BEGIN then
            if data.mode == MODE_STD then
                data.mode = data.mode_last
            else
                data.mode = data.mode == MODE_QNH and MODE_QFE or MODE_QNH
                data.mode_last = data.mode
            end
        end
    end )
    sasl.registerCommandHandler (data.dr.cmd_knob_pull, 0, function(phase) if phase == SASL_COMMAND_BEGIN then data.mode = MODE_STD end end )


    sasl.registerCommandHandler (data.dr.cmd_value_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then data.value = math.max(MIN_VALUE, data.value - 0.01) end end )
    sasl.registerCommandHandler (data.dr.cmd_value_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then data.value = math.min(MAX_VALUE, data.value + 0.01) end end )

end

function draw_lcd(data)
    if data.mode == MODE_QNH then
        sasl.gl.drawText(Font_AirbusDUL, 120, 63, "QNH", 26, false, false, TEXT_ALIGN_CENTER, LED_cl)
    elseif data.mode == MODE_QFE then
        sasl.gl.drawText(Font_AirbusDUL, 60, 63, "QFE", 26, false, false, TEXT_ALIGN_CENTER, LED_cl)
    else
        Draw_green_LED_num_and_letter_lc(20, 10, "Std ", 4, 60, TEXT_ALIGN_LEFT, 0.2, 1, 1)
    end
    
    if data.mode == MODE_QNH or data.mode == MODE_QFE then
        if data.unit == UNIT_INHG then
            Draw_green_LED_num_and_letter_lc(20, 10, math.floor(data.value * 100), 4, 60, TEXT_ALIGN_LEFT, 0.2, 1, 1)
            sasl.gl.drawText(Font_7segment_led, 73, 10, ".", 60, false, false, TEXT_ALIGN_CENTER, LED_cl)
        else
            local hpa = math.floor(inhg_to_hpa(data.value)/100)
            Draw_green_LED_num_and_letter_lc(20, 10, hpa, 4, 60, TEXT_ALIGN_LEFT, 0.2, 1, 1)
        end
    end
end
