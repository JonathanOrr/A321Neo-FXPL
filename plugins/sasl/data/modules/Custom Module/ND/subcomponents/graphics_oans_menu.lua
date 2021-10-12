local oans_menu = { 
    selected_page = 3,
    highlighted_page = 0, -- make it 0 when the mouse is not hovering
    page_1_data = {
        selected_facility = 1,
        highlighted_facility = 0,

        dropdown_1 = {
            highlighted = false, -- is the dropdown itself highlighted (not the lines below)
            expanded = false,
            scroller_ratio = 0,
            title = "H",
            line_1 = "H",
            line_2 = "I",
            line_3 = "J",
            highlighted_line = 0,
        },
        dropdown_2 = {
            highlighted = false,
            expanded = false,
            scroller_ratio = 0,
            title = "RICOO",
            line_1 = "JONON",
            line_2 = "GONOW",
            line_3 = "MODEL",
            highlighted_line = 0,
        },
        available_options = {
            addcross = true,
            addflag = true,
            ldgshift = true,
            centermap = true,
            highlighted = 0 -- in order like above 1-4, 1 is addcross, 4 is centermap
        }
    },
    page_2_data = {
        selected_entry_type = 1,
        highlighted_entry_type = 0,
        dropdown_1 = {
            highlighted = false,
            expanded = false,
            scroller_ratio = 0,
            title = "A",
            line_1 = "B",
            line_2 = "C",
            line_3 = "D",
            highlighted_line = 0,
        },
        dropdown_2 = {
            highlighted = false,
            expanded = false,
            scroller_ratio = 0,
            title = "VHHH",
            line_1 = "RCKH",
            line_2 = "ROAH",
            line_3 = "RJTT",
            highlighted_line = 3,
        },
        display_arpt = {
            avail = false,
            highlighted = false
        },
        airport_data = {
            name = "DUBAI DUDUDU BABABA IIIII INTL",
            icao = "OMDB",
            iata = "DXB",
            coordinates = "25°15.2N/055°21.9E" -- format it yourself plz I don't want to do it thx
        },
        buttons_on_the_right = {
            line_1 = {
                avail = true,
                text = "OKBK",
                highlighted = false,
            },
            line_2 = {
                avail = true,
                text = "ABCD",
                highlighted = false,
            },
            line_3 = {
                avail = false,
                text = "ALTN",
                highlighted = false,
            }
        }
    },
    page_3_data = {
        swap_highlighted = false,
        date_active = "25FEB - 24MAR", --pass me a string plz thx don't feed me rubbish
        data_stby = "28JAN - 24FEB",
        apt_db = "JEP250KUW100075",
        opc = "SXT5A62993AAB01"
    },
}

local function ND_OANS_draw_3d_frame(x, y, width, height)
    sasl.gl.drawWideLine(x - (3 / 2), y + height,           x + width + (3 / 2), y + height,                      3, ECAM_WHITE)
    sasl.gl.drawWideLine(x,                    y + (3 / 2), x,                            y + (height - (3 / 2)), 3, ECAM_WHITE)
    sasl.gl.drawWideLine(x + width,            y + (2 / 2), x + width,                    y + (height - (2 / 2)), 2, ECAM_HIGH_GREY)
    sasl.gl.drawWideLine(x - (2 / 2), y,                    x + width + (2 / 2), y,                               2, ECAM_HIGH_GREY)
end

local function ND_OANS_draw_dropdown_triangle(x,y)
    sasl.gl.drawTriangle( x-10, y+7, x+10, y+7, x, y-9, ECAM_WHITE)
end

local function ND_OANS_page_1(table)
    
    if table.page_1_data.selected_facility ~= 0 then
        sasl.gl.drawArc(170, 28 + ( 5 - table.page_1_data.selected_facility-1) * 31 , 0, 10, 0, 360, ECAM_BLUE)
    end

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
    if table.page_1_data.dropdown_1.highlighted then
        Sasl_DrawWideFrame(296, 104, 69, 39,3,1,ECAM_BLUE)
    end

    sasl.gl.drawRectangle(409, 104, 166, 41, ECAM_BLACK)
    sasl.gl.drawRectangle(409+166-69/2, 104, 69/2, 41, PFD_TAPE_GREY)
    ND_OANS_draw_3d_frame(409, 104, 166, 41)
    ND_OANS_draw_dropdown_triangle(558,123)
    if table.page_1_data.dropdown_2.highlighted then
        Sasl_DrawWideFrame(409, 104, 166, 39,3,1,ECAM_BLUE)
    end


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

    local a = table.page_1_data.available_options.highlighted --this is those 4 boxes on the right
    if a == 1 then
        Sasl_DrawWideFrame(628, 15, 101, 51,3,1,ECAM_BLUE)
    elseif a == 2 then
        Sasl_DrawWideFrame(743, 15, 101, 51,3,1,ECAM_BLUE)
    elseif a == 3 then
        Sasl_DrawWideFrame(628, 86, 101, 51,3,1,ECAM_BLUE)
    elseif a == 4 then
        Sasl_DrawWideFrame(743, 86, 101, 51,3,1,ECAM_BLUE)
    end

    if table.page_1_data.highlighted_facility ~= 0 then
        Sasl_DrawWideFrame(153, 15 + (4-table.page_1_data.highlighted_facility) * 31, 123, 25, 3, 1, ECAM_BLUE)
    end

    if table.page_1_data.dropdown_1.highlighted_line ~= 0 and table.page_1_data.dropdown_1.expanded then
        Sasl_DrawWideFrame(301, 9 + (3 - table.page_1_data.dropdown_1.highlighted_line) * 31, 35, 28, 3, 1, ECAM_BLUE)
    end

    if table.page_1_data.dropdown_2.highlighted_line ~= 0 and table.page_1_data.dropdown_2.expanded then
        Sasl_DrawWideFrame(416, 9 + (3 - table.page_1_data.dropdown_2.highlighted_line) * 31, 130, 28, 3, 1, ECAM_BLUE)
    end

end

local function ND_OANS_page_2(table)
    if table.page_2_data.selected_entry_type ~= 0 then
        sasl.gl.drawArc(170, 28 + ( 4 - table.page_2_data.selected_entry_type-1) * 31 - 8, 0, 10, 0, 360, ECAM_BLUE)
    end
    local selection_text = {"ICAO", "IATA", "CITY NAME"}
    for i=1,3 do
        sasl.gl.drawArc(170, 28 + (i-1) * 31 - 8, 9, 11, 45, 180, ECAM_HIGH_GREY)
        sasl.gl.drawArc(170, 28 + (i-1) * 31 - 8, 9, 11, 45+180, 180, ECAM_WHITE)

        if not (4-i == table.page_2_data.selected_entry_type) then
            sasl.gl.drawText(Font_Airbus_panel, 198, 28 + (i-1) * 31  - 9- 8, selection_text[4 -i], 21, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        else
            sasl.gl.drawText(Font_Airbus_panel, 198, 28 + (i-1) * 31  - 9- 8, selection_text[4 -i], 21, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        end
    end

    if table.page_2_data.highlighted_entry_type ~= 0 then
        Sasl_DrawWideFrame(153, 15 + (3-table.page_2_data.highlighted_entry_type) * 31 - 8, 165, 25, 3, 1, ECAM_BLUE)
    end

    ND_OANS_draw_3d_frame(500, 16, 176, 40)
    sasl.gl.drawText(Font_Airbus_panel, 588 ,28, "DISPLAY ARPT", 21, false, false, TEXT_ALIGN_CENTER, table.page_2_data.display_arpt.avail and ECAM_WHITE or ECAM_HIGH_GREY)
    if table.page_2_data.display_arpt.highlighted then
        Sasl_DrawWideFrame(500, 16, 176, 38, 3, 1, ECAM_BLUE)
    end

    sasl.gl.drawRectangle(296 - 135, 104, 69, 41, ECAM_BLACK)
    sasl.gl.drawRectangle(296 - 135+69/2, 104, 69/2, 41, PFD_TAPE_GREY)
    ND_OANS_draw_3d_frame(296 - 135, 104, 69, 41)
    ND_OANS_draw_dropdown_triangle(347 - 135,123)
    

    sasl.gl.drawRectangle(409 - 135, 104, 166, 41, ECAM_BLACK)
    sasl.gl.drawRectangle(409 - 135+166-69/2, 104, 69/2, 41, PFD_TAPE_GREY)
    ND_OANS_draw_3d_frame(409 - 135, 104, 166, 41)
    ND_OANS_draw_dropdown_triangle(558 - 135,123)

    if table.page_2_data.dropdown_1.highlighted then
        Sasl_DrawWideFrame(296 - 135, 104, 69, 39,3,1,ECAM_BLUE)
    end

    if table.page_2_data.dropdown_2.highlighted then
        Sasl_DrawWideFrame(409 - 135, 104, 166, 39,3,1,ECAM_BLUE)
    end

    if table.page_2_data.dropdown_1.expanded then
        sasl.gl.drawRectangle(296 - 135 , 2, 69, 104, PFD_TAPE_GREY)
        ND_OANS_draw_3d_frame(296 - 135 , 2, 69, 104)
        sasl.gl.drawWideLine(296+69-23 - 135 ,2,296+69-23 - 135 ,104, 2, ECAM_HIGH_GREY)

        sasl.gl.drawRectangle(296+69-21 - 135, Math_rescale_no_lim(0,4,1,83,table.page_2_data.dropdown_1.scroller_ratio), 19, 20, ECAM_HIGH_GREY) ------- THE SCROLLING ON THE RIGHT
        sasl.gl.drawText(Font_Airbus_panel, 318 - 135 ,77, table.page_2_data.dropdown_1.line_1, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_Airbus_panel, 318 - 135 ,77-31, table.page_2_data.dropdown_1.line_2, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_Airbus_panel, 318 - 135 ,77-31*2, table.page_2_data.dropdown_1.line_3, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end

    if table.page_2_data.dropdown_2.expanded then
        if table.page_2_data.selected_entry_type == 1 or table.page_2_data.selected_entry_type == 2 then
            sasl.gl.drawRectangle(409 - 135 , 2, 167, 104, PFD_TAPE_GREY)
            ND_OANS_draw_3d_frame(409 - 135 , 2, 167, 104)
            sasl.gl.drawWideLine(409+167-23 - 135 ,2,409+167-23  - 135,104, 2, ECAM_HIGH_GREY)

            sasl.gl.drawRectangle(409+167-21 - 135, Math_rescale_no_lim(0,4,1,83,table.page_2_data.dropdown_2.scroller_ratio), 19, 20, ECAM_HIGH_GREY) ------- THE SCROLLING ON THE RIGHT

            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 ,77, table.page_2_data.dropdown_2.line_1, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 ,77-31, table.page_2_data.dropdown_2.line_2, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 ,77-31*2, table.page_2_data.dropdown_2.line_3, 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        else
            sasl.gl.drawRectangle(409 - 135 , 2, 300, 104, PFD_TAPE_GREY)
            ND_OANS_draw_3d_frame(409 - 135 , 2, 300, 104)
            sasl.gl.drawWideLine(409+300-23 - 135 ,2,409+300-23  - 135,104, 2, ECAM_HIGH_GREY)

            sasl.gl.drawRectangle(409+300-21 - 135, Math_rescale_no_lim(0,4,1,83,table.page_2_data.dropdown_2.scroller_ratio), 19, 20, ECAM_HIGH_GREY) ------- THE SCROLLING ON THE RIGHT

            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 - 57 ,77, table.page_2_data.dropdown_2.line_1, 21, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 - 57 ,77-31, table.page_2_data.dropdown_2.line_2, 21, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 - 57 ,77-31*2, table.page_2_data.dropdown_2.line_3, 21, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        end
    end
    
    local title1 = table.page_2_data.dropdown_1.title
    local title2 = table.page_2_data.dropdown_2.title

    if table.page_2_data.dropdown_1.expanded then
        sasl.gl.drawRectangle(298 - 135 , 108, 31, 34, ECAM_BLUE)
        sasl.gl.drawText(Font_Airbus_panel, 313 - 135 ,117-3, title1 == nil and "-" or title1, 29, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
    else
        sasl.gl.drawText(Font_Airbus_panel, 313 - 135 ,117, title1 == nil and "-" or title1, 21, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end

    if table.page_2_data.dropdown_2.expanded then
        if table.page_2_data.selected_entry_type == 1 or table.page_2_data.selected_entry_type == 2 then
            sasl.gl.drawRectangle(412 - 135 , 109, 127, 32, ECAM_BLUE)
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 ,117-3, title2 == nil and "---" or title2, 29, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
        else
            sasl.gl.drawRectangle(412 - 135 , 109, 127, 32, ECAM_BLUE)
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 - 57 ,117-3, title2 == nil and "---" or title2, 29, false, false, TEXT_ALIGN_LEFT, ECAM_BLACK)
        end
    else
        if table.page_2_data.selected_entry_type == 1 or table.page_2_data.selected_entry_type == 2 then
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 ,117, title2 == nil and "---" or title2, 21, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        else
            sasl.gl.drawText(Font_Airbus_panel, 476 - 135 - 57 ,117, title2 == nil and "---" or title2, 21, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        end
    end

    if table.page_2_data.dropdown_1.highlighted_line ~= 0 and table.page_2_data.dropdown_1.expanded then
        Sasl_DrawWideFrame(301 - 135 , 9 + (3 - table.page_2_data.dropdown_1.highlighted_line) * 31, 35, 28, 3, 1, ECAM_BLUE)
    end

    if table.page_2_data.dropdown_2.selected_entry_type ~= 0 and table.page_2_data.dropdown_2.expanded then
        if table.page_2_data.selected_entry_type == 1 or table.page_2_data.selected_entry_type == 2 then
            Sasl_DrawWideFrame(416 - 135 , 9 + (3 - table.page_2_data.dropdown_2.highlighted_line) * 31, 130, 28, 3, 1, ECAM_BLUE)
        else
            Sasl_DrawWideFrame(416 - 135 , 9 + (3 - table.page_2_data.dropdown_2.highlighted_line) * 31, 264, 28, 3, 1, ECAM_BLUE)
        end
    end


    sasl.gl.drawWideLine(726,11,726,144, 3, ECAM_HIGH_GREY)


    sasl.gl.drawText(Font_Airbus_panel, 588 ,124, string.sub(table.page_2_data.airport_data.name,1, math.min(#table.page_2_data.airport_data.name, 19)) , 21, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN) -- 19 characters max
    sasl.gl.drawText(Font_Airbus_panel, 524 ,124-26, table.page_2_data.airport_data.icao , 21, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_Airbus_panel, 655 ,124-26, table.page_2_data.airport_data.iata , 21, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_Airbus_panel, 588 ,124-26*2, table.page_2_data.airport_data.coordinates , 21, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)


    ND_OANS_draw_3d_frame(741, 13, 107, 30)
    ND_OANS_draw_3d_frame(741, 13+48, 107, 30)
    ND_OANS_draw_3d_frame(741, 13+48*2, 107, 30)

    if table.page_2_data.buttons_on_the_right.line_1.highlighted then
        Sasl_DrawWideFrame(741, 13, 107, 28, 3, 1, ECAM_BLUE)
    end

    if table.page_2_data.buttons_on_the_right.line_2.highlighted then
        Sasl_DrawWideFrame(741, 13+48, 107, 28, 3, 1, ECAM_BLUE)
    end

    if table.page_2_data.buttons_on_the_right.line_2.highlighted then
        Sasl_DrawWideFrame(741, 13+48*2, 107, 28, 3, 1, ECAM_BLUE)
    end

    sasl.gl.drawText(Font_Airbus_panel, 795 ,115, table.page_2_data.buttons_on_the_right.line_1.text , 21, false, false, TEXT_ALIGN_CENTER, table.page_2_data.buttons_on_the_right.line_1.avail and ECAM_WHITE or ECAM_HIGH_GREY )
    sasl.gl.drawText(Font_Airbus_panel, 795 ,115 - 48 * 1, table.page_2_data.buttons_on_the_right.line_2.text , 21, false, false, TEXT_ALIGN_CENTER, table.page_2_data.buttons_on_the_right.line_2.avail and ECAM_WHITE or ECAM_HIGH_GREY )
    sasl.gl.drawText(Font_Airbus_panel, 795 ,115 - 48 * 2, table.page_2_data.buttons_on_the_right.line_3.text , 21, false, false, TEXT_ALIGN_CENTER, table.page_2_data.buttons_on_the_right.line_3.avail and ECAM_WHITE or ECAM_HIGH_GREY )

end

local function ND_OANS_page_3(table)
    sasl.gl.drawWideLine(174,39,881,39, 3, ECAM_HIGH_GREY)
    sasl.gl.drawWideLine(174,88,881,88, 3, ECAM_HIGH_GREY)
    ND_OANS_draw_3d_frame(495, 102, 77, 39)

    if table.page_3_data.swap_highlighted then
        Sasl_DrawWideFrame(494, 102, 78, 39, 3, 2, ECAM_BLUE)
    end

    sasl.gl.drawText(Font_Airbus_panel, 329, 130, "ACTIVE", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_Airbus_panel, 736, 130, "SECOND", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_Airbus_panel, 329, 103-3, table.page_3_data.date_active , 27, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_Airbus_panel, 736, 103-3, table.page_3_data.data_stby , 21, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_Airbus_panel, 497, 057-3, table.page_3_data.apt_db , 21, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_Airbus_panel, 769, 057-3, table.page_3_data.opc , 21, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    sasl.gl.drawText(Font_Airbus_panel, 534, 114, "SWAP", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_Airbus_panel, 649, 057-3, "OPC", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_Airbus_panel, 275, 057-3, "AIRPORT DATABASE", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
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

    if table.highlighted_page ~= 0 and table.highlighted_page ~= table.selected_page then
        Sasl_DrawWideFrame(1, (3-table.highlighted_page) * y_menu_sel_area/3 + 1 , x_menu_sel_area - 1, y_menu_sel_area/3 + 2 , 3, 2, ECAM_BLUE)
    end
    
    if table.selected_page == 1 then
        ND_OANS_page_1(table)
    elseif table.selected_page == 2 then
        ND_OANS_page_2(table)
    elseif table.selected_page == 3 then
        ND_OANS_page_3(table)
    end

    ND_OANS_draw_3d_frame(857, 115, 33, 33) ---- the X on the top right
    sasl.gl.drawWideLine(859+3,116+3,859+33-6,116+33-6, 4, ECAM_WHITE)
    sasl.gl.drawWideLine(859+33-6,116+3,859+3,116+33-6, 4, ECAM_WHITE)
end
