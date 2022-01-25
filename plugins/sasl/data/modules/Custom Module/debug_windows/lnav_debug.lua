position = { 0 , 0 , 900 , 900 }
size = {900, 900}

local window_default_position = {22,115}
local window_default_size = 0.5
local slew_speed = 1

----------------------

local black = {0,0,0}
local grey  = {0.5,0.5,0.5}
local lightgrey  = {0.8,0.8,0.8}
local darkgrey  = {0.2,0.2,0.2}
local white = {1,1,1}
local red   = {1,0,0}
local green = {0,1,0}
local blue  = {0,0,1}

local window_center = {window_default_position[2],window_default_position[1]}
displayable_latitude = 2/window_default_size
distance_per_box = 1 --nm

local dragging = false
local mouse_left_the_window_few_seconds_ago = false

local mx = 0
local my = 0
local mx_last = 0
local my_last = 0

include("libs/geo-helpers.lua")
include("ND/subcomponents/drawing_functions.lua")
include("debug_windows/lnav_flightpaths.lua")

function onMouseWheel( component,  x,  y,  button,  parentX,  parentY,  value)
    displayable_latitude = displayable_latitude - Math_rescale_no_lim(0, 0, 5, value, displayable_latitude)
    displayable_latitude = math.max(0.01, displayable_latitude)
end

function onMouseMove(_, x, y)
    mx_last = mx
    my_last = my
	mx = x
  	my = y
      return true
end

function onMouseDown( component,  x,  y,  button,  parentX,  parentY)
    if  mx < 100 and my < 50 then
        window_center[1] = window_default_position[2]
        window_center[2] = window_default_position[1]
    else
        dragging = true
    end
    return true
end

function onMouseUp( component,  x,  y,  button,  parentX,  parentY)
    dragging = false
    mouse_left_the_window_few_seconds_ago = false
    return true
end

function onMouseLeave()
    mouse_left_the_window_few_seconds_ago = true
    dragging = false
end


function coords_parser_x(x)
    return Math_rescale_no_lim(window_center[1], 450, displayable_latitude/2 + window_center[1], 900, x)
end

function coords_parser_y(y)
    return Math_rescale_no_lim(window_center[2], 450, displayable_latitude/2 + window_center[2], 900, y)
end

local function draw_reset_button()
    sasl.gl.drawRectangle(0, 0, 100, 50, white)
    drawTextCentered(Font_ECAMfont, 50, 25, "RESET", 24, false, false, TEXT_ALIGN_CENTER, black)
end

local function draw_crosshair()
    sasl.gl.drawWideLine(430, 450, 470, 450, 2, red)
    sasl.gl.drawWideLine(450, 430, 450, 470, 2, red)
end

local function draw_backgrounds()
    sasl.gl.drawRectangle(0, 0, 900, 900, white)
    sasl.gl.drawRectangle(3, 3, 894, 894, black)

    local x_lower_bound = math.floor( window_center[1] - displayable_latitude/2 )
    local x_upper_bound = math.ceil( window_center[1] + displayable_latitude/2 )

    local y_lower_bound = math.floor( window_center[2] - displayable_latitude/2 )
    local y_upper_bound = math.ceil( window_center[2] + displayable_latitude/2 )

    if displayable_latitude <= 7 then
        for i=x_lower_bound, x_upper_bound do
            for j=x_lower_bound*10, x_upper_bound*10 do
                local x2 = coords_parser_x(j/10)
                sasl.gl.drawWideLine(x2, 0, x2, 900, 1, darkgrey)
            end
            local x = coords_parser_x(i)
            sasl.gl.drawWideLine(x, 0, x, 900, 3, grey)
        end
        for i=y_lower_bound, y_upper_bound do
            for j=y_lower_bound*10, y_upper_bound*10 do
                local y2 = coords_parser_y(j/10)
                sasl.gl.drawWideLine(0, y2, 900, y2, 1, darkgrey)
            end
            local y = coords_parser_y(i)
            sasl.gl.drawWideLine(0, y, 900, y, 2, grey)
        end
    elseif displayable_latitude > 2 then
        for i=x_lower_bound, x_upper_bound do
            local x = coords_parser_x(i)
            sasl.gl.drawWideLine(x, 0, x, 900, 3, grey)
        end
        for i=y_lower_bound, y_upper_bound do
            local y = coords_parser_y(i)
            sasl.gl.drawWideLine(0, y, 900, y, 2, grey)
        end
    end

    local text_size = Round(Math_rescale_no_lim(5, 24, 10, 12, displayable_latitude),0)

    if displayable_latitude <= 10 then
        for j=y_lower_bound, y_upper_bound do
            for i=x_lower_bound, x_upper_bound do
                local x = coords_parser_x(i)
                local y = coords_parser_y(j)
                drawTextCentered(Font_ECAMfont, x + 10, y + 25, j..","..i, text_size, false, false, TEXT_ALIGN_LEFT, lightgrey)
            end
        end
    else
        for i=x_lower_bound, x_upper_bound do
            if i%2 == 0 then
                drawTextCentered(Font_ECAMfont, coords_parser_x(i) + 10, 25, i, 16, true, false, TEXT_ALIGN_LEFT, lightgrey)
            end
        end
        for i=y_lower_bound, y_upper_bound do
            if i%2 == 0 then
                drawTextCentered(Font_ECAMfont, 10, coords_parser_y(i) + 25, i, 16, true, false, TEXT_ALIGN_LEFT, lightgrey)
            end
        end
    end
end

local function proportional_resizing()
    if Lnav_debug_window:isVisible() then
        local window_x, window_y, window_width, window_height = Lnav_debug_window:getPosition()
        Lnav_debug_window:setPosition ( window_x , window_y , window_width, window_width)
    end
end

local function map_moving()
    if dragging and not mouse_left_the_window_few_seconds_ago then

        local true_slew_speed = Math_rescale_no_lim(0,0.05, 0.5, slew_speed, displayable_latitude)

        window_center[1] = window_center[1] + Math_rescale_no_lim(450, 0, 900, get(DELTA_TIME) * true_slew_speed, mx)
        window_center[2] = window_center[2] + Math_rescale_no_lim(450, 0, 900, get(DELTA_TIME) * true_slew_speed, my)
    end
end

local function data_updating()
    distance_per_box = get_distance_nm(window_center[1],window_center[2],window_center[1]+1,window_center[2]+1)
end


-----------------------------------------LINE DRAWINGS

function ND_FLIGHTPATH_drawarc(lat,lon,radius,start,arc,dash_or_not) --x y in lat long, radius in nautical miles 
    local radius_in_lat = radius / distance_per_box
    local x = lon
    local y = lat
    x = coords_parser_x(x)
    y = coords_parser_y(y)
    local real_rad = (900 / displayable_latitude) * (radius_in_lat)
    if dash_or_not then
        ND_DRAWING_dashed_arcs(x,y, real_rad, 3, 20,20,start, arc, true, false, true, ECAM_YELLOW)
    else
        sasl.gl.drawArc(x, y, real_rad - 1.5, (900 / displayable_latitude) * (radius_in_lat) + 1.5 , start, arc, ECAM_GREEN)
    end

    --Hints for drawing, not actual path
    SASL_draw_needle(x,y, real_rad, start, 3, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, (2*x + real_rad * math.cos(math.rad(start)))/2 ,(2*y + real_rad * math.sin(math.rad(start)))/2 - math.min(Round(Math_rescale_no_lim(5, 24, 10, 12, displayable_latitude)),24),
     radius.."NM", Round(Math_rescale_no_lim(5, 16, 10, 9, displayable_latitude),0), true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
end

function ND_FLIGHTPATH_drawline(lat1,lon1,lat2,lon2,dash_or_not)
    local x1 = lon1
    local y1 = lat1
    local x2 = lon2
    local y2 = lat2
    x1 = coords_parser_x(x1)
    y1 = coords_parser_y(y1)
    x2 = coords_parser_x(x2)
    y2 = coords_parser_y(y2)
    sasl.gl.drawWideLine(x1, y1,x2,y2, 3, ECAM_GREEN)
end

function ND_FLIGHTPATH_drawline_special(lat1,lon1,lat2,lon2,colour)
    local x1 = lon1
    local y1 = lat1
    local x2 = lon2
    local y2 = lat2
    x1 = coords_parser_x(x1)
    y1 = coords_parser_y(y1)
    x2 = coords_parser_x(x2)
    y2 = coords_parser_y(y2)
    sasl.gl.drawWideLine(x1, y1,x2,y2, 3, colour)
end

function ND_FLIGHTPATH_drawbezier(lat1,lon1,lat2,lon2,lat3,lon3,parts,colour)
    sasl.gl.drawWideBezierLineQ (  coords_parser_x(lon1) ,  coords_parser_y(lat1) ,   coords_parser_x(lon2) ,  coords_parser_y(lat2) ,  coords_parser_x(lon3) ,  coords_parser_y(lat3) ,   parts ,  3 ,  colour )
end

function ND_FLIGHTPATH_drawfix(lat,lon,wpt_name)
    local x = lon
    local y = lat
    x = coords_parser_x(x)
    y = coords_parser_y(y)
    local size_px = 6
    sasl.gl.drawConvexPolygon( {x-size_px,y,x,y+size_px,x+size_px,y,x,y-size_px} ,  false ,  2 , ECAM_GREEN )
    drawTextCentered(Font_ECAMfont, x + 12, y, wpt_name, 19, true, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
end

-----------------------------------------LOOPS


function draw()
    map_moving()
    proportional_resizing()
    data_updating()
    draw_backgrounds()
    draw_flightpaths()
    draw_reset_button()
    draw_crosshair()
end