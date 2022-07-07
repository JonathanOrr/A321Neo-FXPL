-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
include('ADIRS_data_source.lua')

local function draw_accel_arrow(x, y, PFD_table)
    --accel arrows
    if math.abs(adirs_get_ias_trend(PFD_table.Screen_ID) * 10) > 2 then
        PFD_table.Show_spd_trend = true
    end
    if PFD_table.Show_spd_trend and math.abs(adirs_get_ias_trend(PFD_table.Screen_ID) * 10) < 1 then
        PFD_table.Show_spd_trend = false
    end
    if not PFD_table.FAC_SPD_LIM_AVAIL() then
        PFD_table.Show_spd_trend = false
    end

    if PFD_table.Show_spd_trend then
        sasl.gl.setClipArea(x + size[1]/2-437, y + size[2]/2-4, 140, 233)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_up, x + size[1]/2-354, y + size[2]/2-4 + Math_rescale(0, -450, 42, -218, adirs_get_ias_trend(PFD_table.Screen_ID) * 10), 18, 450, ECAM_YELLOW)
        sasl.gl.resetClipArea ()
        sasl.gl.setClipArea(x + size[1]/2-437, y + size[2]/2-244, 140, 234)
        SASL_draw_img_xcenter_aligned(PFD_spd_trend_dn, x + size[1]/2-354, y + size[2]/2-244 + Math_rescale(-43, 0, 0, 233, adirs_get_ias_trend(PFD_table.Screen_ID) * 10), 18, 450, ECAM_YELLOW)
        sasl.gl.resetClipArea ()
    end
end

local function draw_characteristics_spd(x, y, PFD_table)
    --SPD LIM flag
    if not PFD_table.FAC_SPD_LIM_AVAIL() or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-295, y + size[2]/2-200, "SPD", 42, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
        sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-295, y + size[2]/2-235, "LIM", 42, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end

    if not PFD_table.FAC_SPD_LIM_AVAIL() then
        return
    end

    if PFD_table.PFD_SPD_LIM_timer >= 10 then
        --let Aprot cover it with the mask
        sasl.gl.drawMaskStart ()
        --aprot
        sasl.gl.drawRectangle(x + size[1]/2-336, y + size[2]/2-244, 18, Math_rescale(-43, 0, 42, 473, get(PFD_table.Aprot_SPD) - adirs_get_ias(PFD_table.Screen_ID)), {1, 1, 1})
        --VMAX
        sasl.gl.drawRectangle(x + size[1]/2-336, y + size[2]/2+229, 19, Math_rescale(-43, -473, 42, 0, get(PFD_table.Vmax_spd) - adirs_get_ias(PFD_table.Screen_ID)), {1, 1, 1})
        sasl.gl.drawUnderMask(true)

        --vls
        sasl.gl.drawTexture(PFD_vls_tape, x + size[1]/2-336, y + size[2]/2-244 + Math_rescale(-43, -883, 42, -410, get(PFD_table.VLS) - adirs_get_ias(PFD_table.Screen_ID)), 17, 883, ECAM_ORANGE)

        --terminate masked drawing
        sasl.gl.drawMaskEnd ()
    end

    --show alpha based speed when in fly by wire flight mode
    if PFD_table.PFD_SPD_LIM_timer >= 0.7 then
        if get(FBW_total_control_law) == 3 then
            --aprot
            sasl.gl.drawTexture(
                PFD_aprot_tape,
                x + size[1]/2-336,
                y + size[2]/2-244 + Math_rescale(-43, -898, 42, -425, get(PFD_table.Aprot_SPD) - adirs_get_ias(PFD_table.Screen_ID)),
                18,
                898,
                ECAM_ORANGE
            )
            --amax
            sasl.gl.drawRectangle(
                x + size[1]/2-336,
                y + size[2]/2-244,
                20,
                Math_rescale(-43, 0, 42, 473, get(PFD_table.Amax) - adirs_get_ias(PFD_table.Screen_ID)),
                ECAM_RED
            )
        else
            --vsw
            sasl.gl.drawTexture(
                PFD_vmax_vsw_tape,
                x + size[1]/2-336,
                y + size[2]/2-244 + Math_rescale(-43, -1802, 42, -1329, get(PFD_table.Aprot_SPD) - adirs_get_ias(PFD_table.Screen_ID)),
                19,
                1802,
                ECAM_RED
            )
        end

        --vmax protection speeds
        if get(FBW_total_control_law) == FBW_NORMAL_LAW then
            sasl.gl.drawRectangle(x + size[1]/2-363, y + size[2]/2-3  + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.Vmax_prot_spd) - adirs_get_ias(PFD_table.Screen_ID)), 22, 3, ECAM_GREEN)
            sasl.gl.drawRectangle(x + size[1]/2-363, y + size[2]/2-14 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.Vmax_prot_spd) - adirs_get_ias(PFD_table.Screen_ID)), 22, 3, ECAM_GREEN)
        else
            sasl.gl.drawText(Font_Airbus_panel, x + size[1]/2-352, y + size[2]/2-16 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.Vmax_prot_spd) - adirs_get_ias(PFD_table.Screen_ID)), "x", 34, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        end

        --vmo/mmo
        sasl.gl.drawTexture(PFD_vmax_vsw_tape, x + size[1]/2-336, y + size[2]/2+229 + Math_rescale(-43, -473, 42, 0, get(PFD_table.Vmax_spd) - adirs_get_ias(PFD_table.Screen_ID)), 19, 1802, ECAM_RED)

        --VFE next
        if adirs_get_alt(PFD_table.Screen_ID) < 20000 and get(Flaps_handle_position) ~= 4 then
            sasl.gl.drawRectangle(x + size[1]/2-363, y + size[2]/2-3  + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.VFE) - adirs_get_ias(PFD_table.Screen_ID)), 22, 3, ECAM_ORANGE)
            sasl.gl.drawRectangle(x + size[1]/2-363, y + size[2]/2-14 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.VFE) - adirs_get_ias(PFD_table.Screen_ID)), 22, 3, ECAM_ORANGE)
        end

        --S and F speeds
        if get(SFCC_1_status) == 1 or get(SFCC_2_status) == 1 then
            if get(Flaps_handle_position) == 1 then
                sasl.gl.drawRectangle(x + size[1]/2-336, y + size[2]/2-9 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.S_spd) - adirs_get_ias(PFD_table.Screen_ID)), 20, 4, ECAM_GREEN)
                sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-300, y + size[2]/2-22 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.S_spd) - adirs_get_ias(PFD_table.Screen_ID)), "S", 42, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            end
            if get(Flaps_handle_position) == 2 or get(Flaps_handle_position) == 3 then
                sasl.gl.drawRectangle(x + size[1]/2-336, y + size[2]/2-9 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.F_spd) - adirs_get_ias(PFD_table.Screen_ID)), 20, 4, ECAM_GREEN)
                sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-300, y + size[2]/2-22 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.F_spd) - adirs_get_ias(PFD_table.Screen_ID)), "F", 42, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            end
        end

        --GD speed
        if get(Slats) == 0 and get(Flaps_deployed_angle) == 0 then
            sasl.gl.drawArc(x + size[1]/2-338, y + size[2]/2-7 + Math_rescale_no_lim(-43, -240, 42, 240, get(PFD_table.GD_spd) - adirs_get_ias(PFD_table.Screen_ID)), 6, 10, 0, 360, ECAM_GREEN)
        end
    end
end

local function draw_BUSS(x, y, PFD_table)
    local AoA_anim_table = {
        {get(BUSS_VFE_red_AoA),  64},
        {get(BUSS_VFE_norm_AoA), 124},
        {get(BUSS_VLS_AoA),      177},
        {get(BUSS_VSW_AoA),      237},
    }

    local update_time = 0.15
    if get(TIME) - PFD_table.BUSS_update_time >= update_time then
        PFD_table.BUSS_vsw_pos = Table_extrapolate(AoA_anim_table, get(PFD_table.AoA))

        local target_pos = (size[2]/2-129 + PFD_table.BUSS_vsw_pos + size[2]/2-189 + PFD_table.BUSS_vsw_pos) / 2

        PFD_table.BUSS_target_pos = Math_clamp(target_pos, size[2]/2-244, size[2]/2+229)

        PFD_table.BUSS_update_time = get(TIME)
    end

    sasl.gl.setClipArea(x + size[1]/2-390, y + size[2]/2-244, 75, 473)
    sasl.gl.drawRectangle(x + size[1]/2-390, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60, 75, Math_clamp_lower(150 - (PFD_table.BUSS_vsw_pos - 150), 0), ECAM_RED)
    sasl.gl.drawRectangle(x + size[1]/2-390, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53, 75, 60, ECAM_ORANGE)
    sasl.gl.drawTriangle (x + size[1]/2-390, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60, x + size[1]/2-315, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60, x + size[1]/2-352.5, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53, ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-352.5, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60 + 53 + 60 + 30, "FAST", 28, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawRectangle(x + size[1]/2-390, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60, 75, 53, ECAM_GREEN)

    sasl.gl.drawRectangle(x + size[1]/2-390, y + size[2]/2-244, 75, PFD_table.BUSS_vsw_pos, ECAM_RED)
    sasl.gl.drawRectangle(x + size[1]/2-390, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos, 75, 60, ECAM_ORANGE)
    sasl.gl.drawTriangle (x + size[1]/2-390, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos, x + size[1]/2-315, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos, x + size[1]/2-352.5, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos + 60, ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-352.5, y + size[2]/2-244 + PFD_table.BUSS_vsw_pos - 20 - 30, "SLOW", 28, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.resetClipArea ()

    --green AoA target
    SASL_draw_img_ycenter_aligned(PFD_spd_target, x + size[1]/2-315, y + PFD_table.BUSS_target_pos, 33, 42, ECAM_GREEN)

    --needle
    sasl.gl.drawRectangle(x + size[1]/2-400, y + size[2]/2-10, 55, 6, ECAM_YELLOW)
    sasl.gl.drawTexture(PFD_spd_needle, x + size[1]/2-345, y + size[2]/2-18, 56, 21, ECAM_YELLOW)
end

local function draw_decel_info(x, y, PFD_table)
    if get(Wheel_autobrake_is_in_decel) == 1 then
        sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-387, y + size[2]/2-278, "DECEL", 35, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end
end

local function draw_mach_info(x, y, PFD_table)
    if adirs_is_mach_ok(PFD_table.Screen_ID) == true then
        if adirs_get_mach(PFD_table.Screen_ID) > 0.5 then
            PFD_table.Show_mach = true
        end
        if PFD_table.Show_mach and adirs_get_mach(PFD_table.Screen_ID) < 0.45 then
            PFD_table.Show_mach = false
        end
        if PFD_table.Show_mach then
            sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-387, y + size[2]/2-308, "." .. Round(adirs_get_mach(PFD_table.Screen_ID) % 1 * 1000), 35, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
    else
        sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-387, y + size[2]/2-308, "MACH", 35, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end
end

local function draw_airspeed_numbers(string, x, y)
    for i=1, 3 do
        sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-420 + (i-1) * 21, y, string.sub(string, i, i) , 38, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
end

local function draw_airspeed_tape(airspeed, x, y, PFD_table)

    local airspeed_offset = Math_rescale_no_lim(30, 0, 60, -168, airspeed)

    local weird_airspeed_error = Math_rescale_no_lim(30, 0, 500, 3, airspeed)

    local airspeed_to_s_lower_bound = Math_clamp_lower(Round(Math_rescale_no_lim(30, -7, 150, 5, airspeed), 0), 0)
    local airspeed_to_s_upper_bound = Round(Math_rescale_no_lim(30, 5, 150, 17,airspeed), 0)

    for s=airspeed_to_s_lower_bound, airspeed_to_s_upper_bound do
        local line_y = y + size[2]/2+50 + airspeed_offset + (s*10) * 5.592 + weird_airspeed_error

        sasl.gl.drawWideLine(x + size[1]/2-360, line_y, x + size[1]/2-340, line_y, 3, ECAM_WHITE) --long dashes

        if s%2 == 0 then
            draw_airspeed_numbers(Fwd_string_fill(tostring(30 + (s+1) * 10), "0", 3), x, y + size[2]/2+36 + airspeed_offset + (s*10) * 5.592 + weird_airspeed_error)
        end
    end
end

local function draw_target_spd(x, y, PFD_table)

    -- TODO: This should become cyan when selected by FCU

    -- TODO: ECON speed range
    if PFD_table.target_speed then
        local offset_y = y + size[2]/2 - 9 + Math_rescale_no_lim(-43, -240, 42, 240, PFD_table.target_speed - adirs_get_ias(PFD_table.Screen_ID))
        local offset_x = x + size[1]/2-336
        local height = 40
        local width  = 28
        sasl.gl.drawWideLine(offset_x, offset_y-5, offset_x + width, offset_y - height/2, 3, ECAM_MAGENTA)
        sasl.gl.drawWideLine(offset_x, offset_y+5, offset_x + width, offset_y + height/2, 3, ECAM_MAGENTA)
        sasl.gl.drawWideLine(offset_x + width, offset_y + height/2, offset_x + width, offset_y - height/2, 3, ECAM_MAGENTA)
    end
end

function PFD_draw_spd_tape(x, y, PFD_table)
    local boarder_cl = ECAM_WHITE

    --speed tape background
    if not adirs_is_buss_visible(PFD_table.Screen_ID) then
        sasl.gl.drawRectangle(x + size[1]/2-437, y + size[2]/2-244, 99, 473, ECAM_GREY)
    end

    if adirs_is_ias_ok(PFD_table.Screen_ID) == false and not adirs_is_buss_visible(PFD_table.Screen_ID) then
        boarder_cl = PFD_table.SPD_blink_now and ECAM_RED or {0, 0, 0, 0}
        if PFD_table.SPD_blink_now == true then
            sasl.gl.drawText(Font_ECAMfont, x + size[1]/2-390, y + size[2]/2-20, "SPD", 42, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end

    --clip to draw the speed tape
    if adirs_is_ias_ok(PFD_table.Screen_ID) == true and not adirs_is_buss_visible(PFD_table.Screen_ID) then
        sasl.gl.setClipArea(x + size[1]/2-437, y + size[2]/2-244, 99, 473)
            draw_airspeed_tape(Math_clamp_lower(adirs_get_ias(PFD_table.Screen_ID), 30), x, y)
        sasl.gl.resetClipArea ()
    end

    --boarder lines
    if not adirs_is_buss_visible(PFD_table.Screen_ID) then
        sasl.gl.drawWideLine(x + size[1]/2-437, y + size[2]/2+231, x + size[1]/2-310, y + size[2]/2+231, 4, boarder_cl)
        if adirs_is_ias_ok(PFD_table.Screen_ID) == true then
            sasl.gl.drawWideLine(x + size[1]/2-338, y + size[2]/2-7 + Math_clamp_lower(Math_rescale_lim_lower(30, 0, 60, -168, adirs_get_ias(PFD_table.Screen_ID)), -237), x + size[1]/2-338, y + size[2]/2+229, 4, boarder_cl)
            if adirs_get_ias(PFD_table.Screen_ID) > 72 then
                sasl.gl.drawWideLine(x + size[1]/2-437, y + size[2]/2-246, x + size[1]/2-310, y + size[2]/2-246, 4, boarder_cl)
            end
        else
            sasl.gl.drawWideLine(x + size[1]/2-338, y + size[2]/2-244, x + size[1]/2-338, y + size[2]/2+229, 4, boarder_cl)
            sasl.gl.drawWideLine(x + size[1]/2-437, y + size[2]/2-246, x + size[1]/2-310, y + size[2]/2-246, 4, boarder_cl)
        end
    end

    --speed needle
    if adirs_is_ias_ok(PFD_table.Screen_ID) == true and not adirs_is_buss_visible(PFD_table.Screen_ID) then
        sasl.gl.drawRectangle(x + size[1]/2-450, y + size[2]/2-10, 18, 6, ECAM_YELLOW)
        --all spd tape lables
        sasl.gl.setClipArea(x + size[1]/2-437, y + size[2]/2-244, 185, 473)
        draw_characteristics_spd(x, y, PFD_table)
        sasl.gl.resetClipArea ()

        sasl.gl.setClipArea(x + size[1]/2-437, y + size[2]/2-244, 185, 473)
        draw_target_spd(x, y, PFD_table)
        sasl.gl.resetClipArea()

        --draw spd needle
        sasl.gl.drawTexture(PFD_spd_needle, x + size[1]/2-370, y + size[2]/2-18, 56, 21, ECAM_YELLOW)
        draw_accel_arrow(x, y, PFD_table)

        --draw indications
        draw_decel_info(x, y, PFD_table)
        draw_mach_info(x, y, PFD_table)

        --needle
        sasl.gl.drawTexture(PFD_spd_needle, x + size[1]/2-370, y + size[2]/2-18, 56, 21, ECAM_YELLOW)
        sasl.gl.drawRectangle(x + size[1]/2-450, y + size[2]/2-10, 18, 6, ECAM_YELLOW)
    end


    if adirs_is_buss_visible(PFD_table.Screen_ID) then
        draw_BUSS(x, y, PFD_table)
    end

end
