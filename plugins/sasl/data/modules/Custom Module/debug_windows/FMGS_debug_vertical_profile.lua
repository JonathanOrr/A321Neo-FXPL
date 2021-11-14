local trip_dist = 500

local function dist_to_px(dist)
    local point_relative_ratio = Math_rescale_no_lim(0,0,trip_dist,1,dist)
    local ratio = Math_rescale_no_lim(vprof_view_start,0,vprof_view_end,1,point_relative_ratio)
    local px = Math_rescale_no_lim(0,50,1,900,ratio)
    return px
end

local function alt_to_px(alt)
    return Math_rescale_no_lim(0, 60, 40000, 380, alt)
end

local function draw_wpt(dist, alt, name)
    sasl.gl.drawCircle (  dist_to_px(dist) ,  alt_to_px(alt) ,  3 ,  true , UI_GREEN )
    sasl.gl.drawText(Font_B612MONO_regular, dist_to_px(dist),alt_to_px(alt) + 5, name == nil and "INVLD" or name, 16, false, false, TEXT_ALIGN_CENTER,name == nil and UI_LIGHT_RED or UI_GREEN)
end

function draw_vprof_actual()
end

function update_vprof_actual()
end