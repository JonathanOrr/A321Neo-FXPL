position= {0,0,600,424}
size = { 600 , 424 }

local black = {0,0,0}
local white = {1,1,1}
local yellow = {1,1,0}
local green = {0,1,0}
local red = {1,0,0}
local blue = {0,1,1}
local tape_grey = {69/255, 86/255, 105/255}

local function draw_alpha_tape(x,y,alpha, alphamax, alphaamin)
    sasl.gl.drawRectangle(x + 45, y + 19,60,380, tape_grey)
    
    sasl.gl.drawWideLine(x + 45, y + 18, x + 117, y + 18,2, white)
    sasl.gl.drawWideLine(x + 45, y + 399, x + 117, y + 399,2, white)
    sasl.gl.drawWideLine(x + 105, y + 18, x + 105, y + 399,2, white)

    sasl.gl.drawWideLine(x + 45, y + (18+399)/2, x + 113, y + (18+399)/2,6, yellow)

    local pixels_per_deg = 74/5
    local displayable_alpha_per_side = 13 -- it can display 13 degrees up and down each.

    local i_lower_bound = Round(alpha-displayable_alpha_per_side,0)
    local i_upper_bound = Round(alpha+displayable_alpha_per_side,0)


    sasl.gl.setClipArea (x + 45,y + 19,60,380)
    for i=i_lower_bound, i_upper_bound do
        local ypos = (18+399)/2 -- neutral position
        + i * pixels_per_deg -- so that per 1 degree of alpha the tape dash increases by 1
        - alpha * pixels_per_deg 

        if i%5 == 0 then
            sasl.gl.drawWideLine(x + 96, y + ypos, x + 105,y + ypos,2, white)
            sasl.gl.drawText(Font_ECAMfont, x + 92, y + ypos - 7, i, 18, false, false, TEXT_ALIGN_RIGHT, white)
        else
            sasl.gl.drawWideLine(x + 100, y + ypos, x + 105,y + ypos,2, white)
        end
    end
    sasl.gl.resetClipArea()

    local neutral_point = (18+399)/2-18

    local how_close_are_we_to_alphamin = alpha - alphaamin
    local pixels_to_extend_1 = neutral_point - how_close_are_we_to_alphamin * pixels_per_deg
    pixels_to_extend_1 = math.max(pixels_to_extend_1,0)
    sasl.gl.drawRectangle(x + 106,y + 18,11, pixels_to_extend_1 , red)


    local how_close_are_we_to_alphamax = alphamax - alpha
    local pixels_to_extend_2 = neutral_point - how_close_are_we_to_alphamax * pixels_per_deg
    pixels_to_extend_2 = math.max(pixels_to_extend_2,0)
    sasl.gl.drawRectangle(x + 106,y + 397 - pixels_to_extend_2
    ,11, 397- (397 - pixels_to_extend_2), red)

    local in_danger = how_close_are_we_to_alphamin < 0 or how_close_are_we_to_alphamax < 0

    Sasl_DrawWideFrame( x + 121, y + (18+399)/2-22/2,73,22, 2, 0, in_danger and red or yellow)
    sasl.gl.drawTriangle( x + 109, y + (18+399)/2, x + 121, y + (18+399)/2-4, x + 121, y + (18+399)/2+4, in_danger and red or yellow)
    sasl.gl.drawText(Font_ECAMfont, x + 121 + 70, y + (18+399)/2 - 7, Round_fill(alpha,1), 18, false, false, TEXT_ALIGN_RIGHT, in_danger and red or yellow)

end

local function draw_nz_gauge(x,y, gload, gmin, gmax)
    local in_danger = gload < gmin or gload > gmax
    local danger_colour = in_danger and red or white
    
    sasl.gl.drawArc(x + 420, y + 290, 0, 80, 0, 360, tape_grey)
    sasl.gl.drawRectangle(x + 431, y + 277,74,26, danger_colour)
    sasl.gl.drawRectangle(x + 433,y + 279,70,22, black)
    sasl.gl.drawArc(x + 420, y + 290, 80, 88, 60, 30, red)
    sasl.gl.drawArc(x + 420, y + 290, 80, 88, 270, 30, red)
    for i=-22, 20 do
        local angle = i * (90/15) + 180
        if i % 5 == 0 then
            sasl.gl.drawArc(x + 420, y + 290, 74, 80, angle-1, 2, white)
        else
            sasl.gl.drawArc(x + 420, y + 290, 77, 80, angle-1, 2, white)
        end
    end
    sasl.gl.drawArc(x + 420, y + 290, 80, 81.5, 60, 240, white)

    local pointer_angle_bound = 20
    local pointer_length = 79
    local rotation_angle = 180 + Math_rescale_no_lim(1,0,2,-60,Math_clamp(gload,-1,3))
    sasl.gl.drawTriangle( 
    x + 420, y + 290, 
    Get_rotated_point_x_pos(x + 420, 15, pointer_angle_bound + rotation_angle),  Get_rotated_point_y_pos(y + 290,  15, pointer_angle_bound + rotation_angle), 
    Get_rotated_point_x_pos(x + 420, 15, -pointer_angle_bound + rotation_angle),  Get_rotated_point_y_pos(y + 290,  15, -pointer_angle_bound + rotation_angle), 
    danger_colour)

    sasl.gl.drawTriangle( 
        Get_rotated_point_x_pos(x + 420, pointer_length, 0 + rotation_angle),  Get_rotated_point_y_pos(y + 290,  pointer_length, 0 + rotation_angle), 
        Get_rotated_point_x_pos(x + 420, 15, pointer_angle_bound + rotation_angle),  Get_rotated_point_y_pos(y + 290,  15, pointer_angle_bound + rotation_angle), 
        Get_rotated_point_x_pos(x + 420, 15, -pointer_angle_bound + rotation_angle),  Get_rotated_point_y_pos(y + 290,  15, -pointer_angle_bound + rotation_angle), 
    danger_colour)

    for i= -4,4 do
        sasl.gl.drawText(Font_ECAMfont, Get_rotated_point_x_pos(x + 420, 114, i * 30 + 180), Get_rotated_point_y_pos(y + 290, 114, i * 30 + 180) - 7, 
        -i/2 +1, 18, false, false, TEXT_ALIGN_CENTER, white)
    end

    sasl.gl.drawText(Font_ECAMfont, x + 500, y + 283, Round_fill(gload,2), 18, false, false, TEXT_ALIGN_RIGHT, danger_colour)
end

local function draw_beta_tape(x,y, beta, betamin, betamax)

    local in_danger = beta < betamin or beta > betamax
    local danger_colour = in_danger and red or green

    sasl.gl.drawRectangle(x + 414 - 350/2, y + 87,350,49, tape_grey)

    local center_point = x + 414
    local displayable_beta_per_side = 25
    local pixels_per_beta = 160/20

    local how_close_are_we_to_betamin = beta - betamin
    local how_close_are_we_to_betamax = betamax - beta

    local offset_1 = Math_rescale_no_lim(0,350/2,15,350/2 - 15 * pixels_per_beta, how_close_are_we_to_betamin)
    offset_1 = math.max(0,offset_1)
    sasl.gl.drawRectangle(x + 241, y + 75,offset_1,9, red)
    sasl.gl.drawRectangle(x + 241 , y + 75+ 62,offset_1,9, red)

    local offset_2 = Math_rescale_no_lim(0,350/2,15,350/2 - 15 * pixels_per_beta, how_close_are_we_to_betamax)
    offset_2 = math.max(0,offset_2)
    sasl.gl.drawRectangle(x + 589 - offset_2, y + 75,offset_2,9, red)
    sasl.gl.drawRectangle(x + 589 - offset_2, y + 75+ 62,offset_2,9, red)

    local i_lower_bound = Round(beta - displayable_beta_per_side,0)
    local i_upper_bound = Round(beta + displayable_beta_per_side,0)

    sasl.gl.setClipArea (x + 414 - 350/2, y + 87,350,49)
    for i=i_lower_bound,i_upper_bound do
        local x = center_point + i * pixels_per_beta - beta * pixels_per_beta
        if i%5 == 0 then
            sasl.gl.drawWideLine( x , y + 87, x , y + 94,3, white)
            sasl.gl.drawWideLine( x , y + 135, x , y + 135-7,3, white)
            sasl.gl.drawText(Font_ECAMfont, x, y + 102, i, 16, false, false, TEXT_ALIGN_CENTER, white)
        else
            sasl.gl.drawWideLine( x , y + 87, x , y + 91,3, white)
            sasl.gl.drawWideLine( x , y + 135, x , y + 135-4,3, white)
        end
    end
    sasl.gl.resetClipArea()

    sasl.gl.drawWideLine(x + 414 - 350/2 - 2, y + 87,x + 414 + 350/2- 2, y + 87,3, white)
    sasl.gl.drawWideLine(x + 414 - 350/2+ 2, y + 87 + 49,x + 414 + 350/2+ 2, y + 87 + 49,3, white)

    sasl.gl.drawText(Font_ECAMfont, x + 447, y + 56, Round_fill(beta,1), 18, false, false, TEXT_ALIGN_RIGHT, danger_colour)
    sasl.gl.drawWideLine(x + 414, y + 87,x + 414 , y + 87+ 49,6, yellow)
    sasl.gl.drawWideLine(x + 414 - 350/2, y + 73,x + 414 - 350/2, y + 148,3, white)
    sasl.gl.drawWideLine(x + 414 + 350/2, y + 73,x + 414 + 350/2, y + 148,3, white)

    Sasl_DrawWideFrame( x + 414 - 76/2, y + 52,76,23, 2, 0, danger_colour)
    drawEmptyTriangle(x + 414, y + 87,x + 414 - 10,y + 77,x + 414 + 10,y + 77,2,danger_colour)
end

local function draw_bgd()
    sasl.gl.drawRectangle(0,0,size[1],size[2], black)
end

function draw()
    draw_bgd()
    draw_alpha_tape(0,0,get(Alpha),14,-5)
    draw_nz_gauge(0 ,0 , get(Total_vertical_g_load), -0.5, 2.5)
    draw_beta_tape(0 ,0,get(Beta),-15,15)
end

function update()
end