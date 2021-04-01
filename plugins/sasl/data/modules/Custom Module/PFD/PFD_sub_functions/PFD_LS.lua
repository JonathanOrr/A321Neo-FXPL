
local function PFD_draw_ils(PFD_table)

    if PFD_table.ILS_data.is_valid then -- ILS name
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-380, PFD_table.ILS_data.id, 34, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
    else -- ILS flag
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-380, "ILS" .. PFD_table.Screen_ID, 34, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        return
    end

    -- Draw frequency
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-410, math.floor(PFD_table.ILS_data.frequency) .. ".", 34, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
   sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-410, Round(PFD_table.ILS_data.frequency % 1, 2) * 100, 30, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)

end

local function PFD_draw_dme(PFD_table)
    if not PFD_table.DME_data.is_valid then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-440, "DME" .. PFD_table.Screen_ID, 34, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        return
    end
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-325, size[2]/2-440, "NM", 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-440, math.floor(PFD_table.DME_data.value), 34, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
    
    local offset = PFD_table.DME_data.value < 10 and 20 or 0
    if PFD_table.DME_data.value < 20 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-405-offset, size[2]/2-440, ".", 34, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-382-offset, size[2]/2-440, math.floor((PFD_table.DME_data.value%1) * 10), 30, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
    
    end
    
    
end

local function PFD_draw_deviations(PFD_table)

--    if PFD_table.ILS_data.is_valid then
        -- TODO Blinking LOC and G/S in case of receiver failures
        SASL_draw_img_center_aligned(PFD_loc_scale, size[1]/2-55, size[2]/2-290, 352, 42, ECAM_WHITE)
        SASL_draw_img_center_aligned(PFD_gs_scale, size[1]/2+187, size[2]/2-7, 58, 352, ECAM_WHITE)

        if PFD_table.ILS_data.loc_is_valid then
            local degrees = PFD_table.ILS_data.loc_deviation
            local degrees_clamp = Math_clamp(degrees, -1.7, 1.7)
            if math.abs(degrees_clamp) <= 1.6 then
                -- Normal diamond
                local px_scaled = degrees_clamp*170 / 1.6
                SASL_draw_img_center_aligned(PFD_H_diamond, size[1]/2-55+px_scaled, size[2]/2-290, 45, 32, ECAM_WHITE)
            else
                -- Out of bounds
                local texture = degrees_clamp > 1.6 and PFD_H_diamond_R or PFD_H_diamond_L
                local offset  = degrees_clamp > 1.6 and 180 or -180
                SASL_draw_img_center_aligned(texture, size[1]/2-55+offset, size[2]/2-290, 22, 32, ECAM_WHITE)
            end
        end



        if PFD_table.ILS_data.gs_is_valid then
            local degrees = PFD_table.ILS_data.gs_deviation
            local degrees_clamp = Math_clamp(degrees, -0.9, 0.9)
            if math.abs(degrees_clamp) <= 0.8 then
                local px_scaled = degrees_clamp*170 / 0.8
                SASL_draw_img_center_aligned(PFD_V_diamond, size[1]/2+182, size[2]/2-7+px_scaled, 32, 45, ECAM_WHITE)
            else
                -- Out of bounds
                local texture = degrees_clamp > 0.8 and PFD_V_diamond_U or PFD_V_diamond_D
                local offset  = degrees_clamp > 0.8 and 180 or -180
                SASL_draw_img_center_aligned(texture, size[1]/2+182, size[2]/2-7+offset, 32, 22, ECAM_WHITE)
            end
            
        end
--    end

end

local function PFD_draw_extras(PFD_table)
    -- TODO ADD GLS
    sasl.gl.drawText(Font_AirbusDUL, 550, 215, "ILS", 42, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
end

function PFD_draw_LS(PFD_table)
    if get(PFD_table.LS_enabled) == 0 then
        return
    end
    
    PFD_draw_ils(PFD_table)
    PFD_draw_dme(PFD_table)
    PFD_draw_extras(PFD_table)
    PFD_draw_deviations(PFD_table)

end
