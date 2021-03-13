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
-- File: pages.lua 
-- Short description: Draw pages background and fixed elements
-------------------------------------------------------------------------------

size = {600, 400}

local COLOR_DISABLED = {0.4, 0.4, 0.4}

local function draw_line_bottom_area(is_right_complete)
    sasl.gl.drawWideLine(0, 100, size[1], 100, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(140, 100, 140, 0, 3, ECAM_WHITE)

    if is_right_complete then
        sasl.gl.drawWideLine(320, 100, 320, 0, 3, ECAM_WHITE)
        sasl.gl.drawWideLine(420, 100, 420, 0, 3, ECAM_WHITE)
    end
end

local function draw_top_lines()
    sasl.gl.drawWideLine(0, 200, size[1], 200, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(0, 300, size[1], 300, 3, ECAM_WHITE)
end

local function draw_menu_item_right(line, text, color)

    color = color or ECAM_WHITE
    local x = size[1] - 10
    local y = size[2] - ((line-1) * 100)-46
    sasl.gl.drawText(Font_B612regular, x-29, y-10, text, 25, false, false, TEXT_ALIGN_RIGHT, color)

    sasl.gl.drawConvexPolygon ({x, y, x-12, y+12, x-12, y-12}, true, 0, color)

end

local function draw_menu_item_left(line, text, color)

    color = color or ECAM_WHITE
    local x = 10
    local y = size[2] - ((line-1) * 100)-46
    sasl.gl.drawText(Font_B612regular, x+29, y-10, text, 25, false, false, TEXT_ALIGN_LEFT, color)

    sasl.gl.drawConvexPolygon ({x, y, x+12, y-12, x+12, y+12}, true, 0, color)

end


local function draw_page_menu(data)
    sasl.gl.drawText(Font_B612regular, size[1]/2,size[2]-40, "MENU", 25, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 100, 230, "SELCAL", 22, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 100, 200, "JR-CH", 25, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    draw_menu_item_right(2, "SATCOM SETTING")

end

local function draw_inverted_text(x, y, text, size, align, color)

    local w,h = sasl.gl.measureText(Font_B612regular, text, size, false, false)

    if align == TEXT_ALIGN_LEFT then
        sasl.gl.drawRectangle(x-2,y-2, w+4, h+3, color)
    elseif align == TEXT_ALIGN_CENTER then
        sasl.gl.drawRectangle(x-w/2-2,y-2, w+4, h+3, color)
    elseif align == TEXT_ALIGN_RIGHT then
        sasl.gl.drawRectangle(x-w-2,y-2, w+4, h+3, color)
    end
    sasl.gl.drawText(Font_B612regular, x, y, text, size, false, false, align, ECAM_BLACK)
    
end

local function draw_page_menu_satcom(data)
    sasl.gl.drawText(Font_B612regular, size[1]/2,size[2]-40, "SATCOM SETTINGS", 25, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_B612regular, 10, size[2]-45, get(Acars_status) % 2 == 1 and "LOG ON" or "LOG OFF", 25, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    sasl.gl.drawText(Font_B612regular, 10, size[2]-75, "LOGGED ON AUTO", 20, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)

    sasl.gl.drawText(Font_B612regular, size[1]-10, size[2]-45, "ICAO", 20, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, size[1]-10, size[2]-75, "71723146", 20, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)


    sasl.gl.drawText(Font_B612regular, 10, size[2]-145, "LOG MODE", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    draw_inverted_text(10, size[2]-175, "AUTO", 22, TEXT_ALIGN_LEFT, COLOR_DISABLED)
    sasl.gl.drawText(Font_B612regular, 80, size[2]-175, "MANUAL", 22, false, false, TEXT_ALIGN_LEFT, COLOR_DISABLED)

    draw_menu_item_left(4, "RETURN")

end

local function draw_tcas_fixed_indication()
    sasl.gl.drawText(Font_B612regular, 230, 70, "TCAS", 24, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(190, 60, 270, 60, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(190, 60, 190, 50, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(270, 60, 270, 50, 3, ECAM_WHITE)

end

local function draw_page_vhf(data)
    draw_line_bottom_area(true)
    draw_top_lines()
    draw_tcas_fixed_indication()
    
    sasl.gl.drawText(Font_B612regular, size[1]/2+20,size[2]-55, "VHF1", 38, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, size[1]/2+20,size[2]-155, "VHF2", 38, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, size[1]/2+20,size[2]-255, "VHF3", 38, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
end

local function draw_page_hf(data)
    draw_line_bottom_area(true)
    draw_top_lines()
    draw_tcas_fixed_indication()
    
    sasl.gl.drawText(Font_B612regular, size[1]/2+40,size[2]-55, "HF1", 45, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, size[1]/2+40,size[2]-155, "HF2", 45, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
end

local function draw_page_tel(data)
    draw_line_bottom_area(true)
    draw_top_lines()
    draw_tcas_fixed_indication()

    sasl.gl.drawText(Font_B612regular, 140,size[2]-55, "TEL1", 45, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 140,size[2]-85, "CPNY", 22, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 140,size[2]-155, "TEL2", 45, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 140,size[2]-185, "CPNY", 22, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_B612regular, 20,size[2]-45, "DIAL", 25, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    sasl.gl.drawText(Font_B612regular, 20,size[2]-145, "DIAL", 25, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    draw_menu_item_left(3, "CONFERENCE MODE", COLOR_DISABLED)
    draw_menu_item_right(3, "DIRECTORY")
end

local function draw_page_atc(data)
    draw_line_bottom_area(true)
    draw_top_lines()

    sasl.gl.drawText(Font_B612regular, 20,size[2]-35, "ATC", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 20,size[2]-135, "ATC MODE", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 20,size[2]-265, "IDENT", 40, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    sasl.gl.drawText(Font_B612regular, size[1]-20,size[2]-35, "TCAS MODE", 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, size[1]-20,size[2]-135, "TCAS DISPLAY MODE", 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, size[1]-20,size[2]-235, "ALT RPTG", 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)

end

local function draw_page_nav(data)
    draw_line_bottom_area(false)

    sasl.gl.drawText(Font_B612regular, size[1]/2,size[2]-40, "RAD NAV", 25, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)


    sasl.gl.drawText(Font_B612regular, size[1]-20,size[2]-335, "AUDIO NAV", 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612regular, 20,size[2]-335, "VOICE", 25, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

end

function draw_page_static(data)

    if data.current_page == PAGE_VHF then
        draw_page_vhf(data)
    elseif data.current_page == PAGE_HF then
        draw_page_hf(data)
    elseif data.current_page == PAGE_TEL then
        draw_page_tel(data)
    elseif data.current_page == PAGE_ATC then
        draw_page_atc(data)
    elseif data.current_page == PAGE_MENU then
        draw_page_menu(data)
    elseif data.current_page == PAGE_MENU_SATCOM then
        draw_page_menu_satcom(data)
    elseif data.current_page == PAGE_NAV then
        draw_page_nav(data)
    end

end

