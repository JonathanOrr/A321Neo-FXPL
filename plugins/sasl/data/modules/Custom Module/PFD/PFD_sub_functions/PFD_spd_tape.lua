include('constants.lua')

local function draw_accel_arrow(PFD_table)
    --accel arrows
    local show_accel_arrow = true
    if math.abs(get(PFD_table.IAS_accel) * 10) > 2 then
        show_accel_arrow = true
    end
    if math.abs(get(PFD_table.IAS_accel) * 10) < 1 then
        show_accel_arrow = false
    end
    if get(PFD_table.Corresponding_FAC_status) == 0 then
        show_accel_arrow = false
    end

    if show_accel_arrow == true then
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-4, 140, 233)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_up, size[1]/2-354, size[2]/2-4 + Math_rescale(0, -450, 41, -218, get(PFD_table.IAS_accel) * 10), 18, 450, PFD_yellow)
        sasl.gl.resetClipArea ()
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 140, 234)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_dn, size[1]/2-354, size[2]/2-244 + Math_rescale(-41, 0, 0, 233, get(PFD_table.IAS_accel) * 10), 18, 450, PFD_yellow)
        sasl.gl.resetClipArea ()
    end
end

local function draw_characteristics_spd(PFD_table)
    if get(PFD_table.Corresponding_FAC_status) == 0 and get(PFD_table.Opposite_FAC_status) == 0 then
        return
    end

    if PFD_table.PFD_aircraft_in_air_timer >= 10 then
        --vls
        sasl.gl.drawTexture(PFD_vls_tape, size[1]/2-336, size[2]/2-244 + Math_rescale(-41, -883, 41, -410, get(PFD_table.VLS) - get(PFD_table.IAS)), 17, 883, ECAM_ORANGE)
    end

    --show alpha based speed when in fly by wire flight mode
    if get(FBW_in_flight_mode) == 1 then
        --aprot
        Draw_LCD_backlight(size[1]/2-336, size[2]/2-244, 17, Math_rescale(-41, 0, 41, 473, get(PFD_table.Aprot_SPD) - get(PFD_table.IAS)), 0, 1, get(PFD_table.PFD_brightness))
        sasl.gl.drawTexture(
            PFD_aprot_tape,
            size[1]/2-336,
            size[2]/2-244 + Math_rescale(-41, -898, 41, -425, get(PFD_table.Aprot_SPD) - get(PFD_table.IAS)),
            17,
            898,
            ECAM_ORANGE
        )
        --amax
        sasl.gl.drawRectangle(
            size[1]/2-336,
            size[2]/2-244,
            22,
            Math_rescale(-41, 0, 41, 473, get(PFD_table.Amax) - get(PFD_table.IAS)),
            ECAM_RED
        )
    end
    --vmo/mmo
    Draw_LCD_backlight(size[1]/2-336, size[2]/2+229, 19, Math_rescale(-41, -473, 41, 0, get(PFD_table.Vmax_spd) - get(PFD_table.IAS)), 0, 1, get(PFD_table.PFD_brightness))
    sasl.gl.drawTexture(PFD_vmax_vsw_tape, size[1]/2-336, size[2]/2+229 + Math_rescale(-41, -473, 41, 0, get(PFD_table.Vmax_spd) - get(PFD_table.IAS)), 19, 1802, ECAM_RED)
end

function PFD_draw_spd_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    if get(PFD_table.ADR_avail) == 0 then
        boarder_cl = get(PFD_table.ADR_blinking) == 1 and {0, 0, 0, 0} or ECAM_RED
    elseif get(PFD_table.ADR_avail) == 1 then
        boarder_cl = ECAM_WHITE
    end

    --speed tape background
    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244, 99, 473, PFD_tape_grey)

    --clip to draw the speed tape
    if get(PFD_table.ADR_avail) == 1 then
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 99, 473)
        sasl.gl.drawTexture(PFD_spd_tape, size[1]/2-437, size[2]/2-244 - Math_rescale(30, 355, 460, 2785, get(PFD_table.IAS)), 99, 4096, {1,1,1})
        sasl.gl.resetClipArea ()
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2-338, size[2]/2-244, size[1]/2-338, size[2]/2+229, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2-437, size[2]/2+231, size[1]/2-310, size[2]/2+231, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2-437, size[2]/2-246, size[1]/2-310, size[2]/2-246, 4, boarder_cl)

    --speed needle
    if get(PFD_table.ADR_avail) == 1 then
        sasl.gl.drawRectangle(size[1]/2-450, size[2]/2-10, 18, 6, PFD_yellow)
        --all spd tape lables
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 120, 473)
        draw_characteristics_spd(PFD_table)
        sasl.gl.resetClipArea ()

        --draw spd needle
        sasl.gl.drawTexture(PFD_spd_needle, size[1]/2-370, size[2]/2-18, 56, 21, PFD_yellow)
        draw_accel_arrow(PFD_table)
    end
end