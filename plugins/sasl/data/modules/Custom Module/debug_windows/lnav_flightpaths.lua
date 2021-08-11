function ND_FLIGHTPATH_drawarc(lat,lon,radius,start,arc) --x y in lat long, radius in nautical miles 
    local radius_in_lat = radius / distance_per_box
    local x = lon
    local y = lat
    x = coords_parser_x(x)
    y = coords_parser_y(y)
    ND_DRAWING_dashed_arcs(x,y, (900 / displayable_latitude) * (radius_in_lat), 3, 20,20,start, arc, true, false, true, ECAM_YELLOW)
    SASL_draw_needle(x,y, (900 / displayable_latitude) * (radius_in_lat), start, 3, ECAM_BLUE)
    drawTextCentered(Font_AirbusDUL, x,y-35, radius.."NM", Round(Math_rescale_no_lim(5, 24, 10, 12, displayable_latitude),0), true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
end