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
-- File: ND.lua 
-- Short description: main Logic/Graphic code for ND display
-------------------------------------------------------------------------------

position = {get(Capt_nd_position, 1), get(Capt_nd_position, 2), get(Capt_nd_position, 3), get(Capt_nd_position, 4)}
size = {900, 900}
fbo = true

include('ND/common_ND.lua')
include('ND/subcomponents/terrain.lua')

nd_data = new_dataset(ND_CAPT)
ND_all_data[ND_CAPT] = nd_data

local skip_1st_frame_AA = true



----------------------------------------OANS MENU TEST AREA----------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

local oans_menu = { 
    selected_page = 1,
    highlighted_page = 0, -- make it 0 when the mouse is not hovering
    page_1_data = {
        selected_facility = 4,
        dropdown_1 = {
            expanded = false,
            scroller_ratio = 0,
            title = "H",
            line_1 = "H",
            line_2 = "I",
            line_3 = "J",
        },
        dropdown_2 = {
            expanded = false,
            scroller_ratio = 0,
            title = "RICOO",
            line_1 = "JONON",
            line_2 = "GONOW",
            line_3 = "MODEL",
        },
        available_options = {
            addcross = true,
            addflag = true,
            ldgshift = true,
            centermap = true
        }
    }
}

local function ND_OANS_draw_3d_frame(x, y, width, height)
    sasl.gl.drawWideLine(x - (3 / 2), y + height,           x + width + (3 / 2), y + height,                      3, ECAM_WHITE)
    sasl.gl.drawWideLine(x,                    y + (3 / 2), x,                            y + (height - (3 / 2)), 3, ECAM_WHITE)
    sasl.gl.drawWideLine(x + width,            y + (2 / 2), x + width,                    y + (height - (2 / 2)), 2, ECAM_HIGH_GREY)
    sasl.gl.drawWideLine(x - (2 / 2), y,                    x + width + (2 / 2), y,                               2, ECAM_HIGH_GREY)
end

local function ND_OANS_draw_dropdown_triangle(x,y)
    local width
    sasl.gl.drawTriangle( x-10, y+7, x+10, y+7, x, y-9, ECAM_WHITE)
end

local function ND_OANS_page_1(table)
    
    sasl.gl.drawArc(170, 28 + ( 5 - table.page_1_data.selected_facility-1) * 31 , 0, 10, 0, 360, ECAM_BLUE)

    local selection_text = {"RWY", "TWY", "STAND", "OTHER"}
    for i=1,4 do
        sasl.gl.drawArc(170, 28 + (i-1) * 31 , 9, 11, 45, 180, ECAM_HIGH_GREY)
        sasl.gl.drawArc(170, 28 + (i-1) * 31 , 9, 11, 45+180, 180, ECAM_WHITE)

        if not (5-i == table.page_1_data.selected_facility) then
            sasl.gl.drawText(Font_Airbus_panel, 198, 28 + (i-1) * 31  - 9, selection_text[5 -i], 21, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        else
            sasl.gl.drawText(Font_Airbus_panel, 198, 28 + (i-1) * 31  - 9, selection_text[5 -i], 21, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        end
    end

    sasl.gl.drawRectangle(296, 104, 69, 41, ECAM_BLACK)
    sasl.gl.drawRectangle(296+69/2, 104, 69/2, 41, PFD_TAPE_GREY)
    ND_OANS_draw_3d_frame(296, 104, 69, 41)
    ND_OANS_draw_dropdown_triangle(347,123)
    

    sasl.gl.drawRectangle(409, 104, 166, 41, ECAM_BLACK)
    sasl.gl.drawRectangle(409+166-69/2, 104, 69/2, 41, PFD_TAPE_GREY)
    ND_OANS_draw_3d_frame(409, 104, 166, 41)
    ND_OANS_draw_dropdown_triangle(558,123)

    ND_OANS_draw_3d_frame(628, 15, 101, 53)
    ND_OANS_draw_3d_frame(743, 15, 101, 53)
    ND_OANS_draw_3d_frame(628, 86, 101, 53)
    ND_OANS_draw_3d_frame(743, 86, 101, 53)

    local title1 = table.page_1_data.dropdown_1.title
    local title2 = table.page_1_data.dropdown_2.title

    if table.page_1_data.dropdown_1.expanded then
        sasl.gl.drawRectangle(298, 108, 31, 34, ECAM_BLUE)
        sasl.gl.drawText(Font_Airbus_panel, 313,117-3, title1 == nil and "-" or title1, 29, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
    else
        sasl.gl.drawText(Font_Airbus_panel, 313,117, title1 == nil and "-" or title1, 21, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end

    if table.page_1_data.dropdown_1.expanded then
        sasl.gl.drawRectangle(412, 109, 127, 32, ECAM_BLUE)
        sasl.gl.drawText(Font_Airbus_panel, 476,117-3, title2 == nil and "---" or title2, 29, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
    else
        sasl.gl.drawText(Font_Airbus_panel, 476,117, title2 == nil and "---" or title2, 21, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end

    if table.page_1_data.dropdown_1.expanded then
        sasl.gl.drawRectangle(296, 2, 69, 104, PFD_TAPE_GREY)
        ND_OANS_draw_3d_frame(296, 2, 69, 104)
        sasl.gl.drawWideLine(296+69-23,2,296+69-23,104, 2, ECAM_HIGH_GREY)

        sasl.gl.drawRectangle(296+69-21, Math_rescale_no_lim(0,4,1,83,table.page_1_data.dropdown_1.scroller_ratio), 19, 20, ECAM_HIGH_GREY) ------- THE SCROLLING ON THE RIGHT

        sasl.gl.drawText(Font_Airbus_panel, 318,77, table.page_1_data.dropdown_1.line_1, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_Airbus_panel, 318,77-31, table.page_1_data.dropdown_1.line_2, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_Airbus_panel, 318,77-31*2, table.page_1_data.dropdown_1.line_3, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end

    if table.page_1_data.dropdown_2.expanded then
        sasl.gl.drawRectangle(409, 2, 167, 104, PFD_TAPE_GREY)
        ND_OANS_draw_3d_frame(409, 2, 167, 104)
        sasl.gl.drawWideLine(409+167-23,2,409+167-23,104, 2, ECAM_HIGH_GREY)

        sasl.gl.drawRectangle(409+167-21, Math_rescale_no_lim(0,4,1,83,table.page_1_data.dropdown_2.scroller_ratio), 19, 20, ECAM_HIGH_GREY) ------- THE SCROLLING ON THE RIGHT

        sasl.gl.drawText(Font_Airbus_panel, 476,77, table.page_1_data.dropdown_2.line_1, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_Airbus_panel, 476,77-31, table.page_1_data.dropdown_2.line_2, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_Airbus_panel, 476,77-31*2, table.page_1_data.dropdown_2.line_3, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end

    sasl.gl.drawText(Font_Airbus_panel, 678,44, "LDG", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.ldgshift and ECAM_WHITE or ECAM_HIGH_GREY )
    sasl.gl.drawText(Font_Airbus_panel, 678,44-21, "SHIFT", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.ldgshift and ECAM_WHITE or ECAM_HIGH_GREY )

    sasl.gl.drawText(Font_Airbus_panel, 678,44+71, "ADD", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.addcross and ECAM_WHITE or ECAM_HIGH_GREY )
    sasl.gl.drawText(Font_Airbus_panel, 678,44+71-21, "CROSS", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.addcross and ECAM_WHITE or ECAM_HIGH_GREY )

    sasl.gl.drawText(Font_Airbus_panel, 678+114,44, "CENTER", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.centermap and ECAM_WHITE or ECAM_HIGH_GREY )
    sasl.gl.drawText(Font_Airbus_panel, 678+114,44-21, "MAP", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.centermap and ECAM_WHITE or ECAM_HIGH_GREY )

    sasl.gl.drawText(Font_Airbus_panel, 678+114,44+71, "ADD", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.addflag and ECAM_WHITE or ECAM_HIGH_GREY )
    sasl.gl.drawText(Font_Airbus_panel, 678+114,44+71-21, "FLAG", 21, false, false, TEXT_ALIGN_CENTER, table.page_1_data.available_options.addflag and ECAM_WHITE or ECAM_HIGH_GREY )
end

function ND_OANS_draw_menu(table)

    local bgd_colour = PFD_TAPE_GREY

    local x_menu_sel_area = 142
    local y_menu_sel_area = 114
    local y_menu = 151


    local menu_bgd_points = {
        x_menu_sel_area,0 + 2,
        x_menu_sel_area,y_menu+ 2,
        900,y_menu+ 2,
        900,0+ 2
    }

    local menu_sel_lower = 4 - (table.selected_page) - 1
    local menu_sel_upper = 4 - (table.selected_page)

    local menu_surrounding_points = {
        x_menu_sel_area,0,
        x_menu_sel_area,y_menu_sel_area*menu_sel_lower/3,
        2,y_menu_sel_area*menu_sel_lower/3,
        2,y_menu_sel_area*menu_sel_upper/3,
        x_menu_sel_area,y_menu_sel_area*menu_sel_upper/3,
        x_menu_sel_area,y_menu,
        900,y_menu,
        900,0
    }

    for i=1,3 do
        Sasl_DrawWideFrame(2, (i-1) * y_menu_sel_area/3 + 2 , x_menu_sel_area, y_menu_sel_area/3 - 1, 1, 1, ECAM_WHITE)
    end

    sasl.gl.drawConvexPolygon (  menu_bgd_points ,  true ,  5 , bgd_colour )
    sasl.gl.drawRectangle(0,0 + 2  + (4-table.selected_page) * y_menu_sel_area/3 - y_menu_sel_area/3 ,x_menu_sel_area, y_menu_sel_area/3 , bgd_colour)

    sasl.gl.drawWideLine ( menu_surrounding_points[#menu_surrounding_points-1] ,   menu_surrounding_points[#menu_surrounding_points] + 2,  menu_surrounding_points[1] ,  menu_surrounding_points[2] + 2, 3, ECAM_WHITE)
    for i=1, #menu_surrounding_points/2 -1 do
        local starting_cell = i * 2 - 1
        sasl.gl.drawWideLine (  menu_surrounding_points[starting_cell] ,  menu_surrounding_points[starting_cell+1] + 2,  menu_surrounding_points[starting_cell+2] ,  menu_surrounding_points[starting_cell+3] + 2, 3, ECAM_WHITE)
    end

    sasl.gl.drawText(Font_Airbus_panel, 72 ,51 + 38 * 1, "MAP DATA", 21, false, false, TEXT_ALIGN_CENTER, table.selected_page == 1 and ECAM_BLUE or ECAM_WHITE )
    sasl.gl.drawText(Font_Airbus_panel, 72 ,51 + 38 * 0, "ARPT SEL", 21, false, false, TEXT_ALIGN_CENTER, table.selected_page == 2 and ECAM_BLUE or ECAM_WHITE )
    sasl.gl.drawText(Font_Airbus_panel, 72 ,51 + 38 * -1, "STATUS", 21, false, false, TEXT_ALIGN_CENTER, table.selected_page == 3 and ECAM_BLUE or ECAM_WHITE )

    if table.highlighted_page ~= 0 then
        Sasl_DrawWideFrame(1, (3-table.highlighted_page) * y_menu_sel_area/3 + 1 , x_menu_sel_area - 1, y_menu_sel_area/3 + 2 , 3, 2, ECAM_BLUE)
    end
    
    if table.selected_page == 1 then
        ND_OANS_page_1(table)
    end
end



---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------




function draw()

    perf_measure_start("CAPT_ND:draw()")

    if not skip_1st_frame_AA then
        sasl.gl.setRenderTarget(CAPT_ND_popup_texture, true, get(PANEL_AA_LEVEL_1to32))
    else
        sasl.gl.setRenderTarget(CAPT_ND_popup_texture, true)
    end
    skip_1st_frame_AA = false
    
    draw_main(nd_data)
    sasl.gl.restoreRenderTarget()

    sasl.gl.drawTexture(CAPT_ND_popup_texture, 0, 0, 900, 900, {1,1,1})


    ND_OANS_draw_menu(oans_menu)

    perf_measure_stop("CAPT_ND:draw()")
end

sasl.registerCommandHandler (ND_Capt_mode_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.mode = math.min(ND_MODE_PLAN,nd_data.config.mode + 1) end end)
sasl.registerCommandHandler (ND_Capt_mode_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.mode = math.max(ND_MODE_ILS, nd_data.config.mode - 1) end end)
sasl.registerCommandHandler (ND_Capt_range_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then
    nd_data.config.range = math.min(ND_RANGE_320,nd_data.config.range + 1)
    set(ND_Capt_range_knob, (get(ND_Capt_range_knob) + 1) % 11)
end end)
sasl.registerCommandHandler (ND_Capt_range_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then
    nd_data.config.range = math.max(ND_RANGE_ZOOM_02, nd_data.config.range - 1)
    set(ND_Capt_range_knob, (get(ND_Capt_range_knob) - 1) % 11)
end end)

sasl.registerCommandHandler (ND_Capt_nav1_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_1_selector = math.max(-1, nd_data.config.nav_1_selector - 1) end end)
sasl.registerCommandHandler (ND_Capt_nav1_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_1_selector = math.min(1,nd_data.config.nav_1_selector + 1) end end)
sasl.registerCommandHandler (ND_Capt_nav2_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_2_selector = math.max(-1, nd_data.config.nav_2_selector - 1) end end)
sasl.registerCommandHandler (ND_Capt_nav2_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_2_selector = math.min(1,nd_data.config.nav_2_selector + 1) end end)

sasl.registerCommandHandler (ND_Capt_cmd_cstr, 0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_CSTR) end)
sasl.registerCommandHandler (ND_Capt_cmd_wpt,  0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_WPT) end)
sasl.registerCommandHandler (ND_Capt_cmd_vord, 0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_VORD) end)
sasl.registerCommandHandler (ND_Capt_cmd_ndb,  0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_NDB) end)
sasl.registerCommandHandler (ND_Capt_cmd_arpt, 0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_ARPT) end)

sasl.registerCommandHandler (Chrono_cmd_Capt_button, 0, function(phase) nd_chrono_handler(phase, nd_data) end)

sasl.registerCommandHandler (ND_Capt_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Capt_Terrain, 1 - get(ND_Capt_Terrain)) end end)

sasl.registerCommandHandler (Capt_ND_picture_brightness_up, 0, function(phase) Knob_handler_up_float(phase, ND_Capt_picture_brightness, 0, 1, 0.5) end)
sasl.registerCommandHandler (Capt_ND_picture_brightness_dn, 0, function(phase) Knob_handler_down_float(phase, ND_Capt_picture_brightness, 0, 1, 0.5) end)

local function update_buttons()
    pb_set(PB.mip.terr_nd_capt, get(ND_Capt_Terrain) == 1, false)
    
    pb_set(PB.FCU.capt_cstr, false, nd_data.config.extra_data == ND_DATA_CSTR)
    pb_set(PB.FCU.capt_wpt,  false, nd_data.config.extra_data == ND_DATA_WPT)
    pb_set(PB.FCU.capt_vord, false, nd_data.config.extra_data == ND_DATA_VORD)
    pb_set(PB.FCU.capt_ndb,  false, nd_data.config.extra_data == ND_DATA_NDB)
    pb_set(PB.FCU.capt_arpt, false, nd_data.config.extra_data == ND_DATA_ARPT)
    
    pb_set(PB.FCU.capt_range_zoom, false, nd_data.config.range <= ND_RANGE_ZOOM_2)
    pb_set(PB.FCU.capt_range_10, false, nd_data.config.range == ND_RANGE_10)
    pb_set(PB.FCU.capt_range_20, false, nd_data.config.range == ND_RANGE_20)
    pb_set(PB.FCU.capt_range_40, false, nd_data.config.range == ND_RANGE_40)
    pb_set(PB.FCU.capt_range_80, false, nd_data.config.range == ND_RANGE_80)
    pb_set(PB.FCU.capt_range_160, false, nd_data.config.range == ND_RANGE_160)
    pb_set(PB.FCU.capt_range_320, false, nd_data.config.range == ND_RANGE_320)
    
end

local function update_knobs()
    Set_dataref_linear_anim_nostop(ND_Capt_mode_knob, nd_data.config.mode-3, -2, 3, 20)
    Set_dataref_linear_anim_nostop(ND_Capt_nav1_level, nd_data.config.nav_1_selector, -1, 1, 20)
    Set_dataref_linear_anim_nostop(ND_Capt_nav2_level, nd_data.config.nav_2_selector, -1, 1, 20)
    
    nd_data.terrain.brightness = get(ND_Capt_picture_brightness)
end

local function update_disable_click()
    if nd_data.config.range < ND_RANGE_10 then
        set(Capt_PFD_disable_click, get(Capt_pfd_displaying_status) == DMC_ND_CAPT and 1 or 0)
        set(Capt_ND_disable_click, get(Capt_nd_displaying_status) == DMC_ND_CAPT and 1 or 0)
    else
        set(Capt_PFD_disable_click, 0)
        set(Capt_ND_disable_click, 0)
    end
end

function update()

    perf_measure_start("CAPT_ND:update()")

    position = {get(Capt_nd_position, 1), get(Capt_nd_position, 2), get(Capt_nd_position, 3), get(Capt_nd_position, 4)}

    update_buttons()
    update_knobs()
    update_disable_click()

    update_main(nd_data)

    perf_measure_stop("CAPT_ND:update()")

end

function onAirportLoaded()
    -- These must be performed *ONLY* on captain side
    load_altitudes_from_file()          -- Load world (low res) file
    update_terrain_altitudes(nd_data)
end

function onSceneryLoaded()
    -- These must be performed *ONLY* on captain side
    update_terrain_altitudes(nd_data)   -- Load local region from X-Plane

end
