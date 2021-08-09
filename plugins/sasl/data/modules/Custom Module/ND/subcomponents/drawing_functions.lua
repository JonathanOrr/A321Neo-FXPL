
local small_triangle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/small_triangle.png")
local boc = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/Constrains/boc.png")
local tod = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/Constrains/tod.png")
local toc = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/Constrains/toc.png")
local bod = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/Constrains/bod.png")
local intercept = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/Constrains/intercept.png")
local spdchange = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/Constrains/spdchange.png")
local hold = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/Constrains/hold.png")

function ND_DRAWING_dashed_ring(x,y, radius, dashes_width, dashes_length,start_angle, arc_angle, rotation, colour)
    local pi = math.pi
    local circumfrence = 2 *radius * pi
    local pie_angle_per_dash = (dashes_length / circumfrence) * 360
    local number_of_pies = arc_angle / pie_angle_per_dash
    for i=1, Round(number_of_pies,0) do
        if i%2==0 then 
            sasl.gl.drawArc(x, y, radius - dashes_width/2, radius + dashes_width/2, 
            start_angle + i * pie_angle_per_dash + rotation, pie_angle_per_dash, colour)
        end
    end
end

function ND_DRAWING_dashed_ring_include_tails(x,y, radius, dashes_width, dashes_length,start_angle, arc_angle, rotation, colour)
    local pi = math.pi
    local circumfrence = 2 *radius * pi
    local pie_angle_per_dash = (dashes_length / circumfrence) * 360
    local number_of_pies = arc_angle / pie_angle_per_dash
    for i=0, Round(number_of_pies,0) do
        if i%2==0 then 
            actual_start_angle = start_angle + i * pie_angle_per_dash + rotation
            actual_end_angle = actual_start_angle + pie_angle_per_dash

            sasl.gl.drawArc(x, y, radius - dashes_width/2, radius + dashes_width/2, 
            actual_start_angle
            , pie_angle_per_dash
            , colour)
        end
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
            SASL_drawText_rotated(Font_AirbusDUL, 0, -17,
            450 + 340 * math.sin(math.rad((i-1)*30 + rotation)), 
            450 + 340 * math.cos(math.rad((i-1)*30 + rotation)), 
            (i-1)*30+ rotation, (i-1)*3, 38, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        else
            SASL_drawText_rotated(Font_AirbusDUL, 0, -15,
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
    ND_DRAWING_dashed_ring(x,y, 147 , 3, 21, 0, 360, 0, ECAM_RED)
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
            SASL_drawText_rotated(Font_AirbusDUL, 0, -17,
            x + 630 * math.sin(math.rad((i-1)*10 + rotation)), 
            y + 630 * math.cos(math.rad((i-1)*10 + rotation)), 
            (i-1)*10+ rotation, i-1, 42, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        else
            SASL_drawText_rotated(Font_AirbusDUL, 0, -15,
            x + 626 * math.sin(math.rad((i-1)*10 + rotation)), 
            y + 626 * math.cos(math.rad((i-1)*10 + rotation)), 
            (i-1)*10+ rotation, i-1, 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        end
    end
end

function ND_DRAWING_large_dashed_rings(x,y)
    for i=1, 3 do
        ND_DRAWING_dashed_ring_include_tails(x,y, (578/4)*i , 3, 18, 11, 160, -1, ECAM_WHITE)
    end
end

function ND_DRAWING_large_dashed_rings_zoom(x,y)
    local i = 2
    ND_DRAWING_dashed_ring_include_tails(x,y, (578/4)*i , 3, 18, 11, 160, -1, ECAM_WHITE)
end

function ND_DRAWING_hdg_not_avail(x,y)
    for i=1, 3 do
        ND_DRAWING_dashed_ring_include_tails(x,y, (578/4)*i , 3, 18, 11, 160, -1, ECAM_RED)
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
    sasl.gl.drawText (Font_AirbusDUL, x+1, y-9,"D", 30, true, false, TEXT_ALIGN_CENTER, ECAM_MAGENTA)
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