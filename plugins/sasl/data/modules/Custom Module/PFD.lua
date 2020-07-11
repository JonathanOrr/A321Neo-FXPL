position = {1365, 499, 900, 900}
size = {900, 900}

--varibles--
local vvi_left_pixel_offset = 0
local vvi_number_display = 0

--sim dataref--
local current_heading = globalProperty("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
local ground_track = globalProperty("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
local vvi = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")

--a32nx dataref--
local ground_track_delta = createGlobalPropertyf("a321neo/cockpit/PFD/ground_track_delta", 0, false, true, false)
local max_speed = createGlobalPropertyf("a321neo/cockpit/PFD/max_speed", 0, false, true, false)
local stall_speed = createGlobalPropertyf("a321neo/cockpit/PFD/stall_speed", 138, false, true, false) -- clean stall 138kts

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local PFD_BLACK = {0.0, 0.0, 0.0}
local PFD_WHITE = {1.0, 1.0, 1.0}
local PFD_BLUE = {0.004, 1.0, 1.0}
local PFD_GREEN = {0.184, 0.733, 0.219}
local PFD_ORANGE = {0.725, 0.521, 0.18}
local PFD_GREY = {0.3, 0.3, 0.3}
local vvi_cl = PFD_GREEN

function update()
    set(ground_track_delta, get(ground_track) - get(current_heading))


    vvi_cl = PFD_GREEN
    if get(vvi) > -1000 and get(vvi) < 1000 then
        --v/s -1000 to 1000
        vvi_left_pixel_offset = 442 + 150 * get(vvi)/1000

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -2)/100
        
        if vvi_number_display ~= 10 or vvi_number_display ~= 10 then
            vvi_number_display = "0" .. Round(math.abs(math.floor(get(vvi))), -2)/100
        end
        
    elseif (get(vvi) > -2000 and get(vvi) < -1000) or (get(vvi) > 1000 and get(vvi) < 2000) then -- -2000 to 2000
        vvi_left_pixel_offset = Math_clamp(442 + 150 * get(vvi)/1000, 292, 592)
        if get(vvi) > 0 then
            vvi_left_pixel_offset = vvi_left_pixel_offset + 60 * (get(vvi)-1000)/1000
        else
            vvi_left_pixel_offset = vvi_left_pixel_offset + 60 * (get(vvi)+1000)/1000
        end

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -3)/100
    elseif (get(vvi) > -6000 and get(vvi) < -2000) or (get(vvi) > 2000 and get(vvi) < 6000) then -- -6000 to 6000
        vvi_left_pixel_offset = Math_clamp(442 + 150 * get(vvi)/1000, 292, 592)
        if get(vvi) > 0 then
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)-1000)/1000, 232, 652)
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)-2000)/4000, 172, 712)
        else
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)+1000)/1000, 232, 652)
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)+2000)/4000, 172, 652)
        end

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -3)/100
    elseif get(vvi) < -6000 or get(vvi) > 6000 then -- -6000- and 6000+
        if get(vvi) > 0 then
            vvi_left_pixel_offset = 712
            vvi_cl = PFD_ORANGE
        else
            vvi_left_pixel_offset = 172
            vvi_cl = PFD_ORANGE
        end

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -3)/100
    end
end

function draw()
    sasl.gl.drawWideLine(848, vvi_left_pixel_offset, 900, 442, 4, vvi_cl)
    if get(vvi) >= 0 then
        sasl.gl.drawRectangle(850, vvi_left_pixel_offset + 6, 34, 22, PFD_BLACK)
        sasl.gl.drawText(B612MONO_regular, 852, vvi_left_pixel_offset + 8, vvi_number_display, 23, false, false, TEXT_ALIGN_LEFT, vvi_cl)
    else
        sasl.gl.drawRectangle(850, vvi_left_pixel_offset - 28, 34, 22, PFD_BLACK)
        sasl.gl.drawText(B612MONO_regular, 852, vvi_left_pixel_offset - 26, vvi_number_display, 23, false, false, TEXT_ALIGN_LEFT, vvi_cl)
    end
end