local function draw_needle(PFD_table)
    local vs_needle_outter_anim = {
        {-6000, -266},
        {-2000, -207},
        {-1000, -148},
        {0,      0},
        {1000,   148},
        {2000,   207},
        {6000,   266},
    }

    local vs_needle_inner_anim = {
        {-6000, -115},
        {0,      0},
        {6000,   115},
    }

    local needle_color = ECAM_GREEN

    if adirs_get_vs(PFD_table.Screen_ID) > 6000 then
        needle_color = ECAM_ORANGE
    end
    if get(PFD_table.RA_ALT) >= 2500 then
        if adirs_get_vs(PFD_table.Screen_ID) < -6000 then
            needle_color = ECAM_ORANGE
        end
    elseif 1000 <= get(PFD_table.RA_ALT) and get(PFD_table.RA_ALT) < 2500 then
        if adirs_get_vs(PFD_table.Screen_ID) < -2000 then
            needle_color = ECAM_ORANGE
        end
    elseif get(PFD_table.RA_ALT) < 1000 then
        if adirs_get_vs(PFD_table.Screen_ID) < -1200 then
            needle_color = ECAM_ORANGE
        end
    end

    local VS_string = Fwd_string_fill(tostring(math.floor(math.abs(adirs_get_vs(PFD_table.Screen_ID)) / 100)), "0", 2)
    local VS_box_x_pos = #VS_string == 2 and size[1]/2+410 or size[1]/2+391
    local VS_box_y_pos = (adirs_get_vs(PFD_table.Screen_ID) >= 0 and size[2]/2-0 or size[2]/2-36) + Table_interpolate(vs_needle_outter_anim, adirs_get_vs(PFD_table.Screen_ID))
    local VS_box_margin = 4
    local VS_box_width, VS_box_height = sasl.gl.measureText (Font_ECAMfont, VS_string, 30, false, false)
    VS_box_width, VS_box_height = VS_box_width + VS_box_margin * 2, VS_box_height + VS_box_margin * 2
    if math.abs(adirs_get_vs(PFD_table.Screen_ID)) >= 200 then
        sasl.gl.drawRectangle(
            VS_box_x_pos - VS_box_margin,
            VS_box_y_pos - VS_box_margin - 2,
            VS_box_width,
            VS_box_height + 4,
            ECAM_BLACK
        )
        sasl.gl.drawText(
            Font_ECAMfont,
            VS_box_x_pos - VS_box_margin + VS_box_width / 2,
            VS_box_y_pos - VS_box_margin + VS_box_height / 2 - 10,
            VS_string,
            30,
            false,
            false,
            TEXT_ALIGN_CENTER,
            needle_color
        )
        if math.abs(adirs_get_vs(PFD_table.Screen_ID)) >= 10000 then
            Sasl_DrawWideFrame(
                VS_box_x_pos - VS_box_margin,
                VS_box_y_pos - VS_box_margin,
                VS_box_width,
                VS_box_height,
                2,
                1,
                ECAM_GREEN
            )
        end
    end
    sasl.gl.drawWideLine(size[1]/2+400, size[2]/2-8 + Table_interpolate(vs_needle_outter_anim, adirs_get_vs(PFD_table.Screen_ID)), size[1]/2+450, size[2]/2-8 + Table_interpolate(vs_needle_inner_anim, adirs_get_vs(PFD_table.Screen_ID)), 5, needle_color)

end

function PFD_draw_vs_needle(PFD_table)
    if adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
        return
    end

    if adirs_is_vs_ok(PFD_table.Screen_ID) == false then
        sasl.gl.drawTexture(PFD_vs_mask, 831, 155, 53, 575, ECAM_GREY)
        
        if PFD_table.VS_blink_now == true then
            sasl.gl.drawText(Font_AirbusDUL_vert, size[1]/2+392, size[2]/2-10, "V/S", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end

        return
    end

    sasl.gl.drawTexture(PFD_vs_bgd, 831, 155, 53, 575, ECAM_WHITE)

    draw_needle(PFD_table)
end
