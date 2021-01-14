include('ADIRS_data_source.lua')

local function draw_accel_arrow(PFD_table)
    --accel arrows
    if math.abs(get_ias_trend(PFD_table.Screen_ID) * 10) > 2 then
        PFD_table.Show_spd_trend = true
    end
    if PFD_table.Show_spd_trend and math.abs(get_ias_trend(PFD_table.Screen_ID) * 10) < 1 then
        PFD_table.Show_spd_trend = false
    end
    if get(PFD_table.Corresponding_FAC_status) == 0 and get(PFD_table.Opposite_FAC_status) == 0 then
        PFD_table.Show_spd_trend = false
    end

    if PFD_table.Show_spd_trend then
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-4, 140, 233)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_up, size[1]/2-354, size[2]/2-4 + Math_rescale(0, -450, 42, -218, get_ias_trend(PFD_table.Screen_ID) * 10), 18, 450, PFD_YELLOW)
        sasl.gl.resetClipArea ()
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 140, 234)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_dn, size[1]/2-354, size[2]/2-244 + Math_rescale(-43, 0, 0, 233, get_ias_trend(PFD_table.Screen_ID) * 10), 18, 450, PFD_YELLOW)
        sasl.gl.resetClipArea ()
    end
end

local function draw_characteristics_spd(PFD_table)
    --SPD LIM flag
    if (get(PFD_table.Corresponding_FAC_status) == 0 and get(PFD_table.Opposite_FAC_status) == 0) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-295, size[2]/2-200, "SPD", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-295, size[2]/2-235, "LIM", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end

    if get(PFD_table.Corresponding_FAC_status) == 0 and get(PFD_table.Opposite_FAC_status) == 0 then
        return
    end

    if PFD_table.PFD_aircraft_in_air_timer >= 10 then
        --let Aprot cover it with the mask
        sasl.gl.drawMaskStart ()
        --aprot
        sasl.gl.drawRectangle(size[1]/2-336, size[2]/2-244, 18, Math_rescale(-43, 0, 42, 473, get(PFD_table.Aprot_SPD) - get_ias(PFD_table.Screen_ID)), {1, 1, 1})
        --VMAX
        sasl.gl.drawRectangle(size[1]/2-336, size[2]/2+229, 19, Math_rescale(-43, -473, 42, 0, get(PFD_table.Vmax_spd) - get_ias(PFD_table.Screen_ID)), {1, 1, 1})
        sasl.gl.drawUnderMask(true)

        --vls
        sasl.gl.drawTexture(PFD_vls_tape, size[1]/2-336, size[2]/2-244 + Math_rescale(-43, -883, 42, -410, get(PFD_table.VLS) - get_ias(PFD_table.Screen_ID)), 17, 883, ECAM_ORANGE)

        --terminate masked drawing
        sasl.gl.drawMaskEnd ()
    end

    --show alpha based speed when in fly by wire flight mode
    if PFD_table.PFD_aircraft_in_air_timer >= 0.7 then
        if get(FBW_total_control_law) == 3 then
            --aprot
            sasl.gl.drawTexture(
                PFD_aprot_tape,
                size[1]/2-336,
                size[2]/2-244 + Math_rescale(-43, -898, 42, -425, get(PFD_table.Aprot_SPD) - get_ias(PFD_table.Screen_ID)),
                18,
                898,
                ECAM_ORANGE
            )
            --amax
            sasl.gl.drawRectangle(
                size[1]/2-336,
                size[2]/2-244,
                20,
                Math_rescale(-43, 0, 42, 473, get(PFD_table.Amax) - get_ias(PFD_table.Screen_ID)),
                ECAM_RED
            )
        else
            --vsw
            sasl.gl.drawTexture(
                PFD_vmax_vsw_tape,
                size[1]/2-336,
                size[2]/2-244 + Math_rescale(-43, -1802, 42, -1329, get(PFD_table.Aprot_SPD) - get_ias(PFD_table.Screen_ID)),
                19,
                1802,
                ECAM_RED
            )
        end

        --vmo/mmo
        sasl.gl.drawTexture(PFD_vmax_vsw_tape, size[1]/2-336, size[2]/2+229 + Math_rescale(-43, -473, 42, 0, get(PFD_table.Vmax_spd) - get_ias(PFD_table.Screen_ID)), 19, 1802, ECAM_RED)

        --VFE next
        if get_alt(PFD_table.Screen_ID) < 20000 and get(Flaps_handle_position) ~= 4 then
            sasl.gl.drawRectangle(size[1]/2-363, size[2]/2-3  + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.VFE) - get_ias(PFD_table.Screen_ID)), 22, 3, ECAM_ORANGE)
            sasl.gl.drawRectangle(size[1]/2-363, size[2]/2-14 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.VFE) - get_ias(PFD_table.Screen_ID)), 22, 3, ECAM_ORANGE)
        end

        --S and F speeds
        if get(SFCC_1_status) == 1 or get(SFCC_2_status) == 1 then
            if get(Flaps_handle_position) == 1 then
                sasl.gl.drawRectangle(size[1]/2-336, size[2]/2-9 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.S_spd) - get_ias(PFD_table.Screen_ID)), 20, 4, ECAM_GREEN)
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2-300, size[2]/2-22 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.S_spd) - get_ias(PFD_table.Screen_ID)), "S", 42, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            end
            if get(Flaps_handle_position) == 2 or get(Flaps_handle_position) == 3 then
                sasl.gl.drawRectangle(size[1]/2-336, size[2]/2-9 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.F_spd) - get_ias(PFD_table.Screen_ID)), 20, 4, ECAM_GREEN)
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2-300, size[2]/2-22 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.F_spd) - get_ias(PFD_table.Screen_ID)), "F", 42, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            end
        end

        --GD speed
        if get(Slats) == 0 and get(Flaps_deployed_angle) == 0 then
            sasl.gl.drawArc(size[1]/2-338, size[2]/2-7 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.GD_spd) - get_ias(PFD_table.Screen_ID)), 6, 10, 0, 360, ECAM_GREEN)
        end
    end
end

local function draw_BUSS(PFD_table)
    local anim_table = {
        {get(BUSS_VFE_red_AoA), 64},
        {get(BUSS_VFE_norm_AoA), 124},
        {get(BUSS_VLS_AoA), 177},
        {get(BUSS_VSW_AoA), 237},
    }

    local update_time = 0.15
    PFD_table.BUSS_update_timer = PFD_table.BUSS_update_timer + get(DELTA_TIME)

    if PFD_table.BUSS_update_timer >= update_time then
        PFD_table.BUSS_vsw_pos = Table_extrapolate(anim_table, get_aoa(PFD_table.Screen_ID))

        PFD_table.BUSS_update_timer = 0
    end

    sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 99, 473)
    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60, 99, Math_clamp_lower(150 - (PFD_table.BUSS_vsw_pos - 150), 0), ECAM_RED)
    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53, 99, 60, ECAM_ORANGE)
    sasl.gl.drawTriangle (size[1]/2-437, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60, size[1]/2-338, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60, size[1]/2-387.5, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53, ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-387.5, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60, "FAST", 35, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60, 99, 53, ECAM_GREEN)

    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244, 99, PFD_table.BUSS_vsw_pos, ECAM_RED)
    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244 + PFD_table.BUSS_vsw_pos, 99, 60, ECAM_ORANGE)
    sasl.gl.drawTriangle (size[1]/2-437, size[2]/2-244 + PFD_table.BUSS_vsw_pos, size[1]/2-338, size[2]/2-244 + PFD_table.BUSS_vsw_pos, size[1]/2-387.5, size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60, ECAM_RED)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-387.5, size[2]/2-244 + PFD_table.BUSS_vsw_pos - 23, "SLOW", 35, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.resetClipArea ()
end

local function draw_decel_info(PFD_table)
    if get(Wheel_autobrake_is_in_decel) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-387, size[2]/2-278, "DECEL", 35, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end
end

local function draw_mach_info(PFD_table)
    if is_mach_ok(PFD_table.Screen_ID) == true then
        if get_mach(PFD_table.Screen_ID) > 0.5 then
            PFD_table.Show_mach = true
        end
        if PFD_table.Show_mach and get_mach(PFD_table.Screen_ID) < 0.45 then
            PFD_table.Show_mach = false
        end
        if PFD_table.Show_mach then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-387, size[2]/2-308, "." .. Round(get_mach(PFD_table.Screen_ID) % 1 * 1000), 35, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-387, size[2]/2-308, "MACH", 35, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end
end

function PFD_draw_spd_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    --speed tape background
    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244, 99, 473, PFD_TAPE_GREY)

    if is_ias_ok(PFD_table.Screen_ID) == false and is_buss_visible(PFD_table.Screen_ID) == false then
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
    if is_ias_ok(PFD_table.Screen_ID) == true or is_buss_visible(PFD_table.Screen_ID) == false then
        sasl.gl.drawWideLine(size[1]/2-437, size[2]/2+231, size[1]/2-310, size[2]/2+231, 4, boarder_cl)
        if is_ias_ok(PFD_table.Screen_ID) == true then
            sasl.gl.drawWideLine(size[1]/2-338, size[2]/2-7 + Math_clamp_lower(Math_rescale_lim_lower(30, 0, 50, -133, get_ias(PFD_table.Screen_ID)), -237), size[1]/2-338, size[2]/2+229, 4, boarder_cl)
            if get_ias(PFD_table.Screen_ID) > 66 then
                sasl.gl.drawWideLine(size[1]/2-437, size[2]/2-246, size[1]/2-310, size[2]/2-246, 4, boarder_cl)
            end
        else
            sasl.gl.drawWideLine(size[1]/2-338, size[2]/2-244, size[1]/2-338, size[2]/2+229, 4, boarder_cl)
            sasl.gl.drawWideLine(size[1]/2-437, size[2]/2-246, size[1]/2-310, size[2]/2-246, 4, boarder_cl)
        end
    end

    --speed needle
    if is_ias_ok(PFD_table.Screen_ID) == true then
        sasl.gl.drawRectangle(size[1]/2-450, size[2]/2-10, 18, 6, PFD_YELLOW)
        --all spd tape lables
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 185, 473)
        draw_characteristics_spd(PFD_table)
        sasl.gl.resetClipArea ()

        --draw spd needle
        sasl.gl.drawTexture(PFD_spd_needle, size[1]/2-370, size[2]/2-18, 56, 21, PFD_YELLOW)
        draw_accel_arrow(PFD_table)

        --draw indications
        draw_decel_info(PFD_table)
        draw_mach_info(PFD_table)
    end

    if is_buss_visible(PFD_table.Screen_ID) then
        draw_BUSS(PFD_table)
        sasl.gl.drawTexture(PFD_spd_needle, size[1]/2-370, size[2]/2-18, 56, 21, PFD_YELLOW)
        sasl.gl.drawRectangle(size[1]/2-450, size[2]/2-10, 18, 6, PFD_YELLOW)
    end
end