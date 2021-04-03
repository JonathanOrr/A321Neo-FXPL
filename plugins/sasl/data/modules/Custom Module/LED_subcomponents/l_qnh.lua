position = {971, 1539, 178, 85}
size = {178, 85}

include('LED_subcomponents/qnh_common.lua')

local qnh_status = {
    mode = MODE_QNH,
    unit = UNIT_INHG,
    value = 29.92,
    
    dr = {
        baro_setting = Capt_Baro,
        cmd_value_dn = FCU_Capt_knob_qnh_dn,
        cmd_value_up = FCU_Capt_knob_qnh_up,
        cmd_knob_push = FCU_Capt_knob_qnh_push,
        cmd_knob_pull = FCU_Capt_knob_qnh_pull,
        cmd_knob_toggle = FCU_Capt_knob_qnh_unit_toggle,
    }
}

ADIRS_sys.qnh_capt = qnh_status

setup_cmd_handlers(qnh_status)

function draw()
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, 1)
    
    draw_lcd(qnh_status)
end

function update()
    if qnh_status.mode == MODE_STD then
        set(Capt_Baro, 29.92)
    else
        set(Capt_Baro, qnh_status.value)
    end
end
