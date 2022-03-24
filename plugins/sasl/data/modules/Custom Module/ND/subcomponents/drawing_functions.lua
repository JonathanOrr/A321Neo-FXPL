
local small_triangle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/small_triangle.png")
local boc = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/boc.png")
local tod = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/tod.png")
local toc = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/toc.png")
local bod = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/bod.png")
local intercept = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/intercept.png")
local spdchange = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/spdchange.png")
local hold = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/hold.png")


function ND_DRAWING_dashed_arcs(x,y, radius, dashes_width, dashes_length,space_length,start_angle, arc_angle, flexible_spaces, starting_is_space, ending_is_space, colour)

    -------- USAGE
    -- Sincerely thank you for using my function, this is more than 6 hours of work. Enjoy!
    -- Below is a guide to the parameters.

    -----------------------------------------------------------------------------------------------------------------------
    --- DASHES_WIDTH:    |  The width of the ring you are about to draw, use width=3 for typical ND drawings.           ---
    -----------------------------------------------------------------------------------------------------------------------
    --- DASHES_LENGTH:   |  Length of the dashes, in pixels.                                                            ---
    -----------------------------------------------------------------------------------------------------------------------
    --- SPACE_LENGTH:    |  Length of the gaps between the dashes, typically the same as the length of the              ---
    ---                  |  dash itself, also in pixels.                                                                ---
    -----------------------------------------------------------------------------------------------------------------------
    --- FLEXIBLE_SPACES: |  Arc drawing will attempt to fit the defined arc by adjusting the length of the spaces       ---
    ---                  |  with a certain margin. If false, the arc drawing will attempt to fit with the length        ---
    ---                  |  of the dashes instead.                                                                      ---
    -----------------------------------------------------------------------------------------------------------------------
    --- START_IS_SPACE:  |  The beginning of the arc is a space instead of a dash.                                      ---
    -----------------------------------------------------------------------------------------------------------------------
    --- END_IS_SPACE:    |  The ending of the arc is a space instead of a dash.                                         ---
    -----------------------------------------------------------------------------------------------------------------------

    -- ~EXAMPLE 1~
    -- Rico is trying to draw a dashed circular ring.
    --      - flexible_spaces:     |  Depends on case
    --      - starting_is_space:   |  true or false doesn't matter
    --      - ending_is_space:     |  not starting_is_space
    --      - arc_angle      :     |  360 degrees

    -- ~EXAMPLE 2~
    -- Rico is trying to draw the energy circle.
    --      - flexible_spaces:     |  Depends on case
    --      - starting_is_space:   |  false
    --      - ending_is_space:     |  false

    -- ~EXAMPLE 3~
    -- Rico is trying to draw the flight path, one side of the previous leg ends with a dash, the other side starts with a space.
    --      - flexible_spaces:     |  Depends on case
    --      - starting_is_space:   |  false
    --      - ending_is_space:     |  true

    --REMEMBER: When connecting things, do it like lego. If the thing it connects to is a dash, use space on that side. If it is connecting to a space, use dash.

    --WARNING: For all flight paths, use the parameter below:
    --      - starting_is_space:   |  false
    --      - ending_is_space:     |  true   -- THEY MUST NOT BE BOTH FALSE, OR THERE WILL BE ISSUES WHEN CONNECTING TWO CURVES!!!!!

    -- Henrick loves you ;) ♡♡♡♡♡

    local pi = math.pi
    local circumfrence = 2 *radius * pi * (arc_angle / 360)
    local number_of_spaces = (circumfrence - space_length) / (dashes_length + space_length)

    local actual_number_of_spaces = Round(number_of_spaces)
    local actual_number_of_dashes = actual_number_of_spaces + 1

    local predicted_circumfrence = actual_number_of_dashes * dashes_length + actual_number_of_spaces * space_length
    
    local error = predicted_circumfrence - circumfrence

    local new_dashes_length = 0
    local new_spaces_length = 0

    if not flexible_spaces then
        new_dashes_length = dashes_length - error / actual_number_of_dashes
        new_spaces_length = space_length
    else
        new_dashes_length = dashes_length
        new_spaces_length = space_length - error / actual_number_of_spaces
    end

    local new_predicted_circumfrence = actual_number_of_dashes * new_dashes_length + actual_number_of_spaces * new_spaces_length

    local space_angle = (360 * new_spaces_length) / (2 * pi * radius)
    local dash_angle = (360 * new_dashes_length) / (2 * pi * radius)

    local angle_to_next_dash = space_angle + dash_angle

    local start_angle_offset = 0

    if not starting_is_space and ending_is_space then
        angle_to_next_dash = angle_to_next_dash - space_angle / actual_number_of_spaces
    elseif starting_is_space and not ending_is_space then
        start_angle_offset = space_angle
        angle_to_next_dash = angle_to_next_dash -  space_angle / actual_number_of_spaces
    elseif starting_is_space and ending_is_space then
        start_angle_offset = space_angle
        angle_to_next_dash = angle_to_next_dash -  (space_angle / actual_number_of_spaces) * 2
    end

    for i=0, Round(actual_number_of_spaces,0) do
        sasl.gl.drawArc(x, y, radius-dashes_width/2, radius +dashes_width/2  , 
        i * angle_to_next_dash + start_angle_offset + start_angle, dash_angle, colour)
    end

end


function ND_DRAWING_small_triangle(x ,y , rotation)
    SASL_rotated_center_img_center_aligned(small_triangle, x,y,17,15,rotation,0,0, ECAM_WHITE)
end

function ND_DRAWING_small_rose(x ,y , rotation)

    sasl.gl.drawArc(x, y, 292, 295,0 + rotation,360,ECAM_WHITE)

    for i=1, 36 do
        sasl.gl.drawArc(x, y, 295, 310 , (i-1) * 10 - rotation , 0.5, ECAM_WHITE)
        sasl.gl.drawArc(x, y, 295, 302 , (i-1) * 10 - rotation + 5 , 0.5, ECAM_WHITE)
    end
    for i=1, 12 do
        if (i-1)%3 == 0 then
            SASL_drawText_rotated(Font_ECAMfont, 0, -17,
            450 + 340 * math.sin(math.rad((i-1)*30 + rotation)), 
            450 + 340 * math.cos(math.rad((i-1)*30 + rotation)), 
            (i-1)*30+ rotation, (i-1)*3, 38, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        else
            SASL_drawText_rotated(Font_ECAMfont, 0, -15,
            450 + 340 * math.sin(math.rad((i-1)*30 + rotation)), 
            450 + 340 * math.cos(math.rad((i-1)*30 + rotation)), 
            (i-1)*30+ rotation, (i-1)*3, 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        end
    end
end

function ND_DRAWING_small_tcas_ring(x,y)
    for i=1, 12 do
        sasl.gl.drawArc(x+1, y, 54, 67 , i * 30 , 3, ECAM_WHITE)
    end
end

function ND_DRAWING_small_red_ring(x,y)
    ND_DRAWING_dashed_arcs(x,y, 147, 3, 20,20,0, 360, true, true, false, ECAM_RED)
    sasl.gl.drawArc(x, y, 292, 295,0,360,ECAM_RED)
    sasl.gl.drawArc(x, y, 9, 12,0,360,ECAM_RED)
end

function ND_DRAWING_large_rose(x,y,rotation)

    sasl.gl.drawArc(x, y, 577, 580,0 - rotation,360,ECAM_WHITE)
    for i=1, 36 do
        sasl.gl.drawArc(x, y, 578, 606 , (i-1) * 10 - rotation , 0.35, ECAM_WHITE)
        sasl.gl.drawArc(x, y, 578, 592 , (i-1) * 10 - rotation + 5 , 0.35, ECAM_WHITE)
    end
    for i=1, 36 do
        if (i-1)%3 == 0 then
            SASL_drawText_rotated(Font_ECAMfont, 0, -17,
            x + 630 * math.sin(math.rad((i-1)*10 + rotation)), 
            y + 630 * math.cos(math.rad((i-1)*10 + rotation)), 
            (i-1)*10+ rotation, i-1, 42, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        else
            SASL_drawText_rotated(Font_ECAMfont, 0, -15,
            x + 626 * math.sin(math.rad((i-1)*10 + rotation)), 
            y + 626 * math.cos(math.rad((i-1)*10 + rotation)), 
            (i-1)*10+ rotation, i-1, 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        end
    end
end

function ND_DRAWING_large_dashed_rings(x,y)
    for i=1, 3 do
        ND_DRAWING_dashed_arcs(x,y,(578/4)*i, 3, 20,20,11, 158, true, false, false, ECAM_WHITE)
    end
end

function ND_DRAWING_large_dashed_rings_zoom(x,y)
    local i = 2
    ND_DRAWING_dashed_arcs(x,y,(578/4)*i, 3, 20,20,11, 158, true, false, false, ECAM_WHITE)
end

function ND_DRAWING_hdg_not_avail(x,y)
    for i=1, 3 do
        ND_DRAWING_dashed_arcs(x,y,(578/4)*i, 3, 20,20,11, 158, true, false, false, ECAM_RED)
    end
    sasl.gl.drawArc(x, y, 11, 14,0 ,360,ECAM_RED)
    sasl.gl.drawArc(x, y, 577, 580,0 ,360,ECAM_RED)
end

function ND_DRAWING_large_tcas_ring(x,y)
    for i=1, 5 do
        sasl.gl.drawArc(x+1, y, 54, 67 , i * 30 , 3, ECAM_WHITE)
    end
end

function ND_SYMBOLS_draw_decelleration(x,y)
    sasl.gl.drawArc(x, y, 15.5, 17.5 , 0 , 360, ECAM_MAGENTA)
    sasl.gl.drawText (Font_ECAMfont, x+1, y-9,"D", 30, true, false, TEXT_ALIGN_CENTER, ECAM_MAGENTA)
end

function ND_SYMBOLS_draw_bottom_of_climb(x,y,colour)
    SASL_draw_img_center_aligned(boc, x, y, 50, 23, colour)
end

function ND_SYMBOLS_draw_bottom_of_descent(x,y,colour)
    SASL_draw_img_center_aligned(bod, x, y, 49, 21, colour)
end

function ND_SYMBOLS_draw_top_of_descent(x,y,colour)
    SASL_draw_img_center_aligned(tod, x, y, 50, 23, colour)
end

function ND_SYMBOLS_draw_top_of_climb(x,y,colour)
    SASL_draw_img_center_aligned(toc, x, y, 49, 21, colour)
end

function ND_SYMBOLS_draw_vpath_intercept(x,y,colour)
    SASL_draw_img_center_aligned(intercept, x, y, 48, 16, colour)
end

function ND_SYMBOLS_draw_speed_change(x,y)
    SASL_draw_img_center_aligned(spdchange, x, y, 34, 34, ECAM_MAGENTA)
end

function ND_SYMBOLS_draw_hold_symbol(x,y)
    SASL_draw_img_center_aligned(hold, x, y, 33, 46, ECAM_WHITE)
end