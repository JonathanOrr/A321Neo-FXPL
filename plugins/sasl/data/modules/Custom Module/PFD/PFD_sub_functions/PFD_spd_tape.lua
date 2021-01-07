include('constants.lua')
include('ADIRS_data_source.lua')

local function draw_accel_arrow(PFD_table)
    --accel arrows
    local show_accel_arrow = true
    if math.abs(get_ias_trend(PFD_table.Screen_ID) * 10) > 2 then
        show_accel_arrow = true
    end
    if math.abs(get_ias_trend(PFD_table.Screen_ID) * 10) < 1 then
        show_accel_arrow = false
    end
    if get(PFD_table.Corresponding_FAC_status) == 0 and get(PFD_table.Opposite_FAC_status) == 0 then
        show_accel_arrow = false
    end

    if show_accel_arrow == true then
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-4, 140, 233)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_up, size[1]/2-354, size[2]/2-4 + Math_rescale(0, -450, 41, -218, get_ias_trend(PFD_table.Screen_ID) * 10), 18, 450, PFD_YELLOW)
        sasl.gl.resetClipArea ()
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 140, 234)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_dn, size[1]/2-354, size[2]/2-244 + Math_rescale(-41, 0, 0, 233, get_ias_trend(PFD_table.Screen_ID) * 10), 18, 450, PFD_YELLOW)
        sasl.gl.resetClipArea ()
    end
end

local function draw_characteristics_spd(PFD_table)
    if get(PFD_table.Corresponding_FAC_status) == 0 and get(PFD_table.Opposite_FAC_status) == 0 then
        return
    end

    if PFD_table.PFD_aircraft_in_air_timer >= 10 then
        --vls
        sasl.gl.drawTexture(PFD_vls_tape, size[1]/2-336, size[2]/2-244 + Math_rescale(-41, -883, 41, -410, get(PFD_table.VLS) - get_ias(PFD_table.Screen_ID)), 17, 883, ECAM_ORANGE)
    end

    --show alpha based speed when in fly by wire flight mode
    if PFD_table.PFD_aircraft_in_air_timer >= 0.7 then
        --aprot
        Draw_LCD_backlight(size[1]/2-336, size[2]/2-244, 17, Math_rescale(-41, 0, 41, 473, get(PFD_table.Aprot_SPD) - get_ias(PFD_table.Screen_ID)), 0, 1, get(PFD_table.PFD_brightness))
        sasl.gl.drawTexture(
            PFD_aprot_tape,
            size[1]/2-336,
            size[2]/2-244 + Math_rescale(-41, -898, 41, -425, get(PFD_table.Aprot_SPD) - get_ias(PFD_table.Screen_ID)),
            17,
            898,
            ECAM_ORANGE
        )
        --amax
        sasl.gl.drawRectangle(
            size[1]/2-336,
            size[2]/2-244,
            22,
            Math_rescale(-41, 0, 41, 473, get(PFD_table.Amax) - get_ias(PFD_table.Screen_ID)),
            ECAM_RED
        )
    end
    --vmo/mmo
    Draw_LCD_backlight(size[1]/2-336, size[2]/2+229, 19, Math_rescale(-41, -473, 41, 0, get(PFD_table.Vmax_spd) - get_ias(PFD_table.Screen_ID)), 0, 1, get(PFD_table.PFD_brightness))
    sasl.gl.drawTexture(PFD_vmax_vsw_tape, size[1]/2-336, size[2]/2+229 + Math_rescale(-41, -473, 41, 0, get(PFD_table.Vmax_spd) - get_ias(PFD_table.Screen_ID)), 19, 1802, ECAM_RED)
end

function PFD_draw_spd_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    --speed tape background
    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244, 99, 473, PFD_TAPE_GREY)

    if is_ias_ok(PFD_table.Screen_ID) == false then
        boarder_cl = PFD_table.SPD_blink_now and ECAM_RED or {0, 0, 0, 0}
        if PFD_table.SPD_blink_now == true then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-390, size[2]/2-20, "SPD", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end

    --clip to draw the speed tape
    if is_ias_ok(PFD_table.Screen_ID) == true then
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 99, 473)
        sasl.gl.drawTexture(PFD_spd_tape, size[1]/2-437, size[2]/2-244 - Math_rescale(30, 355, 460, 2785, get_ias(PFD_table.Screen_ID)), 99, 4096, {1,1,1})
        sasl.gl.resetClipArea ()
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2-338, size[2]/2-244, size[1]/2-338, size[2]/2+229, 4, boarder_cl)
    if is_ias_ok(PFD_table.Screen_ID) == false then
        sasl.gl.drawWideLine(size[1]/2-437, size[2]/2+231, size[1]/2-336, size[2]/2+231, 4, boarder_cl)
        sasl.gl.drawWideLine(size[1]/2-437, size[2]/2-246, size[1]/2-336, size[2]/2-246, 4, boarder_cl)
    else
        sasl.gl.drawWideLine(size[1]/2-437, size[2]/2+231, size[1]/2-310, size[2]/2+231, 4, boarder_cl)
        sasl.gl.drawWideLine(size[1]/2-437, size[2]/2-246, size[1]/2-310, size[2]/2-246, 4, boarder_cl)
    end

    --speed needle
    if is_ias_ok(PFD_table.Screen_ID) == true then
        sasl.gl.drawRectangle(size[1]/2-450, size[2]/2-10, 18, 6, PFD_YELLOW)
        --all spd tape lables
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 120, 473)
        draw_characteristics_spd(PFD_table)
        sasl.gl.resetClipArea ()

        --draw spd needle
        sasl.gl.drawTexture(PFD_spd_needle, size[1]/2-370, size[2]/2-18, 56, 21, PFD_YELLOW)
        draw_accel_arrow(PFD_table)
    end
end