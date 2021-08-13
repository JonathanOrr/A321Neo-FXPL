size = {900, 900}

include("ND/subcomponents/terrain.lua")
include("libs/geo-helpers.lua")

local function leading_zeros_int(num, num_total)
    return string.format("%0" .. num_total .. "d", num) 
end

local image_wind_arrow = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/wind-arrow.png")

local image_symbols = {
    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor1.png"),
    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor2.png"),
    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-adf.png")
}

local function draw_common_gs_and_tas(data)
    -- Fixed elements
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-50, "GS", 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 160, size[2]-50, "TAS", 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    local gs_value = "---"
    
    if data.inputs.is_gs_valid then
        gs_value = math.floor(data.inputs.gs)
    end

    local tas_value = "---"
    
    if data.inputs.is_tas_valid then
        tas_value = math.floor(data.inputs.tas)
    end

    
    sasl.gl.drawText(Font_AirbusDUL, 130, size[2]-50, gs_value, 34, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, 290, size[2]-50, tas_value, 34, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

end

local function draw_common_wind_arrow(data)
    if data.inputs.is_wind_valid and data.inputs.wind_speed >= 2 then
        local rotation_angle = (data.inputs.wind_direction - data.inputs.true_heading)
        sasl.gl.drawRotatedTexture(image_wind_arrow, rotation_angle-180, 100, size[2]-150, 44/3,112/3, {1,1,1})    
    end
end

local function draw_common_wind(data)
    -- Fixed element
    sasl.gl.drawText(Font_AirbusDUL, 85, size[2]-90, "/", 32, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    local txt_direction = "---"
    local txt_speed = "---"

    if data.inputs.is_wind_valid then
        txt_direction = leading_zeros_int(math.floor(data.inputs.wind_direction), 3)
        txt_speed = math.floor(data.inputs.wind_speed)
    end
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-90, txt_direction, 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, 110, size[2]-90, txt_speed, 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)

    draw_common_wind_arrow(data)

end

local function draw_common_chrono(data)
    if not data.chrono.is_active then
        return
    end

    sasl.gl.drawRectangle(30, 110, 120, 35, ECAM_GREY)

    -- The chrono can show two format:
    -- 1) if then value is lower than 1 hour, that the value is shown as MM'SS"
    -- 2) otherwise is showed as HH^H MM'

    local chrono_text = ""
    local show_upper_H = false
    local elapsed_secs = get(TIME) - data.chrono.start_time 
    if not data.chrono.is_running then
        elapsed_secs = data.chrono.elapsed_time
    end

    if elapsed_secs > 60*60 then
        show_upper_H = true
        local hours = leading_zeros_int(math.min(99, math.floor(elapsed_secs/(60*60))), 2)
        local minutes = leading_zeros_int(math.floor(elapsed_secs/60) % 60, 2)
        chrono_text = hours .. " " .. minutes .. "'" 
    else
        local minutes = leading_zeros_int(math.floor(elapsed_secs/60) % 60, 2)
        local seconds = leading_zeros_int(math.floor(elapsed_secs) % 60, 2)
        chrono_text = minutes .. "'" .. seconds .. "\"" 
    end
    
    sasl.gl.drawText(Font_AirbusDUL, 30, 115, chrono_text, 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    if show_upper_H then
        -- Draw the H between hours and minutes
        sasl.gl.drawText(Font_AirbusDUL, 74, 125, "H", 24, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end
end

local function draw_common_nav_stations_single(data, id)

    local x = id == 1 and 10 or size[2]-10
    local m = id == 1 and 1 or -1

    if data.nav[id].selector == ND_SEL_OFF then
        return
    end
    
    local text = ""
    local color = nil
    local image = nil
    if data.nav[id].selector == ND_SEL_ADF then
        text = "ADF" .. id
        color = ECAM_GREEN
        sym_image = image_symbols[3]
    else
        text = "VOR" .. id
        color = ECAM_WHITE
        sym_image = image_symbols[id]
    end
    
    
    -- First line
    if not data.nav[id].is_valid then
        color = ECAM_RED
    else
        -- Image
        sasl.gl.drawTexture(sym_image, x+15*m-10, 35, 48/1.5,82/1.5, {1,1,1})
    end
    
    sasl.gl.drawText(Font_AirbusDUL, x+40*m, 85, text, 26, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, color)

    --- Extra symbol
    if data.nav[id].correction == ND_NAV_CORRECTION_CORR then
        sasl.gl.drawText(Font_AirbusDUL, x+120*m, 85, "CORR", 22, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, ECAM_MAGENTA)
    elseif data.nav[id].correction == ND_NAV_CORRECTION_MAG then
        sasl.gl.drawText(Font_AirbusDUL, x+120*m, 85, "MAG", 22, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, ECAM_ORANGE)    
    elseif data.nav[id].correction == ND_NAV_CORRECTION_TRUE then
        sasl.gl.drawText(Font_AirbusDUL, x+120*m, 85, "TRUE", 22, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    end
    
    -- Second line
    if data.nav[id].identifier ~= "" then
        sasl.gl.drawText(Font_AirbusDUL, x+40*m, 55, data.nav[id].identifier, 26, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, color)
    else
        local freq_str = ""
        if data.nav[id].selector == ND_SEL_VOR then
            freq_str = Round_fill(data.nav[id].frequency, 2)
        else
            freq_str = math.floor(data.nav[id].frequency)
        end
        sasl.gl.drawText(Font_AirbusDUL, x+40*m, 55, freq_str, 26, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, color)    
    end
    --- Extra symbol
    local tuned_symbol = ""
    if data.nav[id].tuning_type == ND_NAV_TUNED_M then
        tuned_symbol = "M"
    elseif data.nav[id].tuning_type == ND_NAV_TUNED_R then
        tuned_symbol = "R"
    end
    
    if tuned_symbol ~= "" then
        sasl.gl.drawText(Font_AirbusDUL, x+150*m, 55, tuned_symbol, 22, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawWideLine(x+151*m, 50, x+161*m, 50, 2, ECAM_WHITE)
    end

    if data.nav[id].selector ~= ND_SEL_ADF then

        -- Third line
        if data.nav[id].dme_invalid then
            sasl.gl.drawText(Font_AirbusDUL, x+40*m, 20, "DME " .. id, 26, false, false, id == 1 and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT, ECAM_RED)
        else
            local integer    = data.nav[id].dme_computed and math.floor(data.nav[id].dme_distance) or "--"
            local fractional = data.nav[id].dme_computed and math.floor((data.nav[id].dme_distance%1)*10) or "-"

            sasl.gl.drawText(Font_AirbusDUL, x+90*m, 20, integer..".", 26, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)    
            sasl.gl.drawText(Font_AirbusDUL, x+18+90*m, 20, fractional, 22, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)    

            sasl.gl.drawText(Font_AirbusDUL, x+30+90*m, 20, "NM", 22, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        end
    end    
end

local function draw_common_messages_bottom_1(data)
    -- This is for TCAS info only

    if data.misc.tcas_status == ND_TCAS_OK then
        return  -- Nothing to draw
    end
    
    local text = ""
    local color = nil

    if data.misc.tcas_status == ND_TCAS_OFF then
        text = "TCAS STBY"
        color = ECAM_ORANGE
    elseif data.misc.tcas_status == ND_TCAS_TA_ONLY then
        text = "TA ONLY"
        color = ECAM_WHITE
    elseif data.misc.tcas_status == ND_TCAS_TEST then
        text = "TCAS TEST"
        color = ECAM_ORANGE
    elseif data.misc.tcas_status == ND_TCAS_FAULT then
        -- TCAS flashes for 9 seconds in case of fault
        -- TODO BLINKING
        text = "TCAS"
        color = ECAM_ORANGE
    else
        assert(false) -- This should not happen
    end
    
    Sasl_DrawWideFrame(200, 55, size[2]-400, 35, 2, 0, ECAM_HIGH_GREY)
    sasl.gl.drawText(Font_AirbusDUL, 450, 61, text, 34, false, false, TEXT_ALIGN_CENTER, color)
    
end

local function draw_common_messages_bottom_2(data)

    local text = ""
    local color = nil

    -- ** IMPORTANT **
    -- If you add another condition here, please update also
    -- the condition list in graphics.lua

    if data.misc.off_side_control_mode then
        text  = "SET OFFSIDE MODE"
        color = ECAM_ORANGE
    elseif data.misc.off_side_control_rng then
        text  = "SET OFFSIDE RNG"
        color = ECAM_ORANGE
    elseif data.misc.backup_nav then
        text  = "BACK-UP NAV"
        color = ECAM_ORANGE
    elseif data.misc.gps_primary_lost then
        text  = "GPS PRIMARY LOST"
        color = ECAM_ORANGE
    elseif data.misc.oans_arpt_not_active and data.config.range <= ND_RANGE_ZOOM_2 then
        text  = "ARPT NOT IN ACTIVE F-PLN"
        color = ECAM_ORANGE
    elseif data.misc.map_partially_displayed then
        text  = "MAP PARTLY DISPLAYED"
        color = ECAM_ORANGE
    elseif data.misc.off_side_control then
        text  = "OFFSIDE FM CONTROL"
        color = ECAM_ORANGE
    elseif data.misc.gpirs_is_on then
        text  = "GPS PRIMARY"
        color = ECAM_WHITE
    end

    if color ~= nil then
        Draw_LCD_backlight(200, 20, size[2]-400, 35, 0.5, 1, get(Capt_ND_brightness_act))
        Sasl_DrawWideFrame(200, 20, size[2]-400, 35, 2, 0, ECAM_HIGH_GREY)
        sasl.gl.drawText(Font_AirbusDUL, 450, 26, text, 34, false, false, TEXT_ALIGN_CENTER, color)
    end
end

local function draw_common_messages_center(data)

    local text = ""
    local color = nil

    local is_nav_or_rose = data.config.mode == ND_MODE_NAV or data.config.mode == ND_MODE_ARC

    if data.misc.map_not_avail then
        text = "MAP NOT AVAIL"
        color = ECAM_RED
    elseif data.misc.not_avail then
        text = "NOT AVAIL"
        color = ECAM_RED
    elseif data.misc.apt_pos_lost then
        text = "ARPT NAV POS LOST"
        color = ECAM_RED
    elseif (data.misc.tcas_ra_triggered or data.misc.tcas_ta_triggered) and not is_nav_or_rose then
        text = "TCAS:CHANGE MODE"
        color = data.misc.tcas_ra_triggered and ECAM_RED or ECAM_ORANGE
    elseif (data.misc.tcas_ra_triggered or data.misc.tcas_ta_triggered) and data.config.range <= ND_RANGE_ZOOM_2 then
        text = "TCAS:INCREASE RANGE"
        color = data.misc.tcas_ra_triggered and ECAM_RED or ECAM_ORANGE
    elseif (data.misc.tcas_ra_triggered or data.misc.tcas_ta_triggered) and data.config.range > ND_RANGE_40 then
        text = "TCAS:REDUCE RANGE"
        color = data.misc.tcas_ra_triggered and ECAM_RED or ECAM_ORANGE
    elseif (data.misc.windshear_warning or data.misc.windshear_caution) and not is_nav_or_rose then
        text = "W/S:CHANGE MODE"
        color = data.misc.windshear_warning and ECAM_RED or ECAM_ORANGE
    elseif (data.misc.windshear_warning or data.misc.windshear_caution) and data.config.range > ND_RANGE_10 then
        text = "W/S:SET RNG 10 NM"
        color = data.misc.windshear_warning and ECAM_RED or ECAM_ORANGE
    elseif data.misc.windshear_inc_range then
        text = "W/S:INCREASE RANGE"
        color = ECAM_RED
    elseif (get(GPWS_pred_terr) == 1 or get(GPWS_pred_terr_pull) == 1) and data.config.mode == ND_MODE_PLAN then
        text = "TERR:CHANGE MODE"
        color = get(GPWS_pred_terr_pull) == 1 and ECAM_RED or ECAM_ORANGE
    elseif (get(GPWS_pred_terr) == 1 or get(GPWS_pred_terr_pull) == 1) and data.config.range > ND_RANGE_80 then
        text = "TERR:REDUCE RANGE"
        color = get(GPWS_pred_terr_pull) == 1 and ECAM_RED or ECAM_ORANGE
    elseif data.misc.mode_change then
        text = "MODE CHANGE"
        color = ECAM_GREEN
    elseif data.misc.range_change then
        text = "RANGE CHANGE"
        color = ECAM_GREEN
    elseif data.misc.please_wait then
        text = "PLEASE WAIT"
        color = ECAM_GREEN
    end
    
    if color ~= nil then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 530, text, 48, false, false, TEXT_ALIGN_CENTER, color)
    end

    if data.config.mode == ND_MODE_VOR then
        if data.misc.vor_failure then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 482, "VOR", 48, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end


    if data.config.mode == ND_MODE_ILS then
        if data.misc.loc_failure then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 500, "LOC", 48, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end

        if data.misc.gs_failure then
            sasl.gl.drawText(Font_AirbusDUL, size[1]-50, size[2]/2+48, "G", 32, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
            sasl.gl.drawText(Font_AirbusDUL, size[1]-50, size[2]/2,    "/", 32, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
            sasl.gl.drawText(Font_AirbusDUL, size[1]-50, size[2]/2-48, "S", 32, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end
    
    if data.misc.windshear_pred_fail then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-120, size[2]/2-170, "PRED W/S", 48, false, false, TEXT_ALIGN_CENTER, ECAM_RED)    
    end

end

local function draw_common_messages_top(data)
    if not data.inputs.is_heading_valid then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 612, "HDG", 48, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end
    
    if data.misc.hdg_discrepancy then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 670, "CHECK HDG", 48, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    
    local other_side = data.id == ND_CAPT and "FO" or "CAPT" 

    local text = ""    
    if data.misc.nd_discrepancy then
        text = "CHECK " .. other_side .. " ND"
    elseif data.misc.pfd_discrepancy then
        text = "CHECK " .. other_side .. " PFD"
    elseif data.misc.ewd_discrepancy then
        text = "CHECK EWD"
    elseif data.misc.sd_discrepancy then
        text = "CHECK SD"
    end

    if text ~= "" then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 803, text, 32, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_common_rwy_and_true(data)
    if data.misc.sid_or_app_visible then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]-40, data.misc.sid_or_app_text, 32, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)    
    end
    if data.inputs.is_true_heading_showed then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]-70, "TRUE", 32, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end
    
    if data.inputs.is_true_heading_boxed_showed then
        Sasl_DrawWideFrame(size[1]/2-39, size[2]-73, 80, 29, 2, 0, ECAM_BLUE)
    end
end

local function draw_common_messages(data)

    draw_common_messages_top(data)
    draw_common_messages_center(data)
    draw_common_messages_bottom_1(data) -- On bottom first squared box
    draw_common_messages_bottom_2(data) -- On bottom second squared box
end

local function draw_common_nav_stations(data)
    if data.config.mode ~= ND_MODE_PLAN then
        draw_common_nav_stations_single(data, 1, 10)
        draw_common_nav_stations_single(data, 2, 10)
    end
end


local function draw_common_oans_info(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        return  -- No OANS over zoom
    end
    
    local oans_airport = data.oans.displayed_apt
    if oans_airport ~= nil then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-30, size[2]-40, oans_airport.name, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]-30, size[2]-75, oans_airport.id, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        
        data.oans.displayed_apt.distance = get_distance_nm(data.inputs.plane_coords_lat, data.inputs.plane_coords_lon, oans_airport.lat, oans_airport.lon)
        if data.oans.displayed_apt.distance >= 5 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]-70, size[2]-110, math.floor(data.oans.displayed_apt.distance), 32, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
            sasl.gl.drawText(Font_AirbusDUL, size[1]-30, size[2]-110, "NM", 28, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        end
    end
end

local function draw_common_terrain_numbers(data)
    if data.config.mode ~= ND_MODE_PLAN and
          data.id == ND_CAPT and get(ND_Capt_Terrain) == 1
       or data.id == ND_FO   and get(ND_Fo_Terrain) == 1 then
       
        local max_alt = Fwd_string_fill(""..math.ceil(data.terrain.max_altitude_tile/100), "0", 3)
        if data.terrain.max_altitude_tile < -90000 then
            max_alt = "000"
        end
        
        local min_alt = Fwd_string_fill(""..math.ceil(math.max(0,data.terrain.min_altitude_tile/100)), "0", 3)
        if data.terrain.min_altitude_tile > 90000 then
            min_alt = "000"
        end

        if get(GPWS_pred_terr_pull) == 1 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]-55, 190, "TERR", 28, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
            sasl.gl.drawText(Font_AirbusDUL, size[1]-55, 165, "AHEAD", 28, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        elseif get(GPWS_pred_terr) == 1 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]-55, 190, "TERR", 28, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
            sasl.gl.drawText(Font_AirbusDUL, size[1]-55, 165, "AHEAD", 28, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]-55, 165, "TERR", 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]-40, 140, max_alt, 24, false, false, TEXT_ALIGN_CENTER, data.terrain.max_altitude_tile_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]-40, 115, min_alt, 24, false, false, TEXT_ALIGN_CENTER, data.terrain.min_altitude_tile_color)

        Sasl_DrawWideFrame(size[1]-65, 137, 50, 23, 2, 0, {1., 1., 0})
        Sasl_DrawWideFrame(size[1]-65, 112, 50, 23, 2, 0, {1., 1., 0})
       
    end
end

local function draw_common_mora(data)

    if data.config.extra_data ~= ND_DATA_CSTR then
        return
    end

    if data.config.range < ND_RANGE_40 then
        return
    end

    if data.config.mode ~= ND_MODE_ARC and data.config.mode ~= ND_MODE_NAV then
        return
    end

    sasl.gl.drawText(Font_ECAMfont, 5, 171, "40NM MORA", 24, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)

    local mora_text = "N/A"
    
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        if data.misc.mora_value_time == nil or get(TIME) - data.misc.mora_value_time > 5.1 then    -- Update every 5 seconds
            data.misc.mora_value = geo_get_mora(data.inputs.plane_coords_lat, data.inputs.plane_coords_lon)
            data.misc.mora_value_time = get(TIME)
        end
    
        mora_text = data.misc.mora_value
    end
    sasl.gl.drawText(Font_ECAMfont, 25, 147, mora_text, 24, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
end

local function draw_test_gpws()
    if get(GPWS_long_test_in_progress) == 1 then
        draw_terrain_test_gpws()
    end
end

local function draw_next_waypoint_info(data)
    if data.config.mode == ND_MODE_ILS or data.config.mode == ND_MODE_VOR then
        return -- Not present in these modes
    end

    if data.config.range <= ND_RANGE_ZOOM_2 then
        return -- Not present in OANS mode
    end

    local active_legs = FMGS_get_route_legs()
    local next_leg_id = FMGS_get_next_leg_id()
    if active_legs == nil or #active_legs == 0 or next_leg_id == nil then
        return
    end
    
    if data.misc.map_not_avail then
        return
    end
    
    local next_wpt = active_legs[next_leg_id]
    
    -- WPT Name
    local next_wpt_name = next_wpt.id == nil and "COORDS" or next_wpt.id    -- This is possible when the waypoint is coordinates
    sasl.gl.drawText(Font_ECAMfont, size[1]-120, size[2]-50, next_wpt.id, 28, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    
    -- Bearing
    local true_bearing = get_earth_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,next_wpt.lat,next_wpt.lon)
    if data.inputs.is_true_heading_showed then
        true_bearing = true_bearing - Local_magnetic_deviation()
    end
    sasl.gl.drawText(Font_ECAMfont, size[1]-55, size[2]-50, Round(true_bearing, 0), 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]-30, size[2]-50, data.inputs.is_true_heading_showed and "T" or "°", 28, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)


    -- Distance
    local distance = get_distance_nm(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,next_wpt.lat,next_wpt.lon)
    sasl.gl.drawText(Font_ECAMfont, size[1]-80, size[2]-82, Round(distance, 0) .. ".", 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]-65, size[2]-82, math.floor((distance%1)*10, 0), 22, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]-20, size[2]-82, "NM", 22, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)


    if data.inputs.is_gs_valid and data.inputs.gs > 100 then
        local dist_hours = distance / data.inputs.gs -- [nm / (nm/h)] = [h]
        local curr_hours = get(ZULU_hours) + get(ZULU_mins) / 60 + get(ZULU_secs) / 3600
        
        curr_hours = (curr_hours + dist_hours) % 24
        
        local hours   = math.floor(curr_hours)
        local minutes = math.floor((curr_hours % 1) * 60)
        
        sasl.gl.drawText(Font_ECAMfont, size[1]-80, size[2]-114, Fwd_string_fill(""..hours, "0", 2), 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_ECAMfont, size[1]-57, size[2]-112, ":", 28, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawText(Font_ECAMfont, size[1]-20, size[2]-114, Fwd_string_fill(""..minutes, "0", 2), 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        
    end

end

function draw_common(data)

    draw_common_gs_and_tas(data)
    draw_common_wind(data)
    draw_common_mora(data)
    draw_common_chrono(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        draw_common_nav_stations(data)
        draw_common_terrain_numbers(data)
    else
        draw_common_oans_info(data)
    end
    draw_common_messages(data)
    draw_common_rwy_and_true(data)
    draw_next_waypoint_info(data)
    draw_test_gpws()
end

