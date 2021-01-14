local image_bkg_ring        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/ring.png")
local image_bkg_ring_red    = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/ring-red.png")
local image_bkg_ring_tcas   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/tcas-ring.png")
local image_bkg_ring_arrows = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/ring-arrows.png")
local image_bkg_ring_middle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/ring-middle.png")

local image_point_apt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-apt.png")
local image_point_vor = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor.png")
local image_point_ndb = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-ndb.png")
local image_point_wpt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-wpt.png")

local image_vor_1 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-VOR1.png")
local image_vor_2 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-VOR2.png")
local image_adf   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/needle-ADF1.png")

local image_track_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-track-ring.png")
local image_hdgsel_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-hdgsel-ring.png")

local image_ils_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-ring.png")
local image_ils_nonprec_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-nonprec-ring.png")
    

size = {900, 900}

local COLOR_YELLOW = {1,1,0}

local poi_position_last_update = 0
local POI_UPDATE_RATE = 0.1
local MAX_LIMIT_WPT = 500

local function get_range_in_nm(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        return math.floor(2^(data.config.range-1) * 10)
    elseif data.config.range == ND_RANGE_ZOOM_2 then
        return 2
    elseif data.config.range == ND_RANGE_ZOOM_1 then
        return 1
    elseif data.config.range == ND_RANGE_ZOOM_05 then
        return 0.5
    elseif data.config.range == ND_RANGE_ZOOM_02 then
        return 0.2
    end
    assert(false) -- Should never happen
end


local function draw_backgrounds(data)
    -- Main rose background
    if data.inputs.is_heading_valid then
        sasl.gl.drawRotatedTexture(image_bkg_ring, -data.inputs.heading, (size[1]-750)/2,(size[2]-750)/2,750,750, {1,1,1})

        if data.misc.tcas_ta_triggered or data.misc.tcas_ra_triggered or data.config.range == ND_RANGE_10 then

            -- Inner (TCAS) circle is activated only when:
            -- - Range is 10, or
            -- - TCAS RA or TA activates
            sasl.gl.drawRotatedTexture(image_bkg_ring_tcas, -data.inputs.heading, (size[1]-750)/2,(size[2]-750)/2,750,750, {1,1,1})
        end
    else
        -- Heading not available
        sasl.gl.drawTexture(image_bkg_ring_red, (size[1]-591)/2,(size[2]-590)/2,591,590, {1,1,1})
    end
    
end

local function draw_fixed_symbols(data)

    if not data.inputs.is_heading_valid then
        return
    end

    -- Plane
    sasl.gl.drawWideLine(410, 450, 490, 450, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)
    sasl.gl.drawWideLine(450, 400, 450, 475, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)
    sasl.gl.drawWideLine(435, 415, 465, 415, 4, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)

    -- Top heading indicator (yellow)
    sasl.gl.drawWideLine(450, 720, 450, 770, 5, data.config.range > ND_RANGE_ZOOM_2 and COLOR_YELLOW or ECAM_MAGENTA)

    sasl.gl.drawTexture(image_bkg_ring_arrows, (size[1]-750)/2,(size[2]-750)/2,750,750, {1,1,1})
    sasl.gl.drawTexture(image_bkg_ring_middle, (size[1]-750)/2,(size[2]-750)/2,750,750, {1,1,1})
    
end

local function draw_ranges(data)
    -- Ranges
    --if data.config.range > 0 then
        local ext_range = get_range_in_nm(data)
        local int_range = ext_range / 2
        sasl.gl.drawText(Font_AirbusDUL, 250, 250, ext_range, 20, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, 350, 350, int_range, 20, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    --end

end

local function draw_track_symbol(data)
    if not data.inputs.is_track_valid then
        return
    end

    sasl.gl.drawRotatedTexture(image_track_sym, (data.inputs.track-data.inputs.heading), (size[1]-17)/2,(size[2]-594)/2,17,594, {1,1,1})
    
end

local function draw_hdgsel_symbol(data)

    if not data.inputs.hdg_sel_visible then
        return
    end
    
    sasl.gl.drawRotatedTexture(image_hdgsel_sym, (data.inputs.hdg_sel-data.inputs.heading), (size[1]-32)/2,(size[2]-641)/2,32,641, {1,1,1})
end

local function draw_ls_symbol(data)

    if not data.inputs.ls_is_visible then
        return
    end
    
    sasl.gl.drawRotatedTexture(data.inputs.ls_is_precise and image_ils_sym or image_ils_nonprec_sym,
                              (data.inputs.ls_direction-data.inputs.heading+180), (size[1]-19)/2,(size[2]-657)/2,19,657, {1,1,1})
end


local function draw_navaid_pointer_single(data, id)
    if not data.nav[id].needle_visible then
        return
    end

    local image = data.nav[id].selector == ND_SEL_ADF and image_adf or (id == 1 and image_vor_1 or image_vor_2)

    sasl.gl.drawRotatedTexture(image, 180+data.nav[id].needle_angle, (size[1]-42)/2,(size[2]-586)/2,42,586, {1,1,1})

end

local function draw_navaid_pointers(data)
    draw_navaid_pointer_single(data, 1)
    draw_navaid_pointer_single(data, 2)
end

local function get_distance_nm(lat1,lon1,lat2,lon2)
    return GC_distance_km(lat1, lon1, lat2, lon2) * 0.539957
end

local function get_bearing(lat1,lon1,lat2,lon2)
    local lat1_rad = math.rad(lat1)
    local lat2_rad = math.rad(lat2)
    local lon1_rad = math.rad(lon1)
    local lon2_rad = math.rad(lon2)

    local x = math.sin(lon2_rad - lon1_rad) * math.cos(lat2_rad)
    local y = math.cos(lat1_rad) * math.sin(lat2_rad) - math.sin(lat1_rad)*math.cos(lat2_rad)*math.cos(lon2_rad - lon1_rad)
    local theta = math.atan2(y, x)
    local brng = (theta * 180 / math.pi + 360) % 360

    return brng
end

local function get_px_per_nm(data)
    -- 588 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    return 588 / range_in_nm
end

local function get_x_y(data, lat, lon)  -- Do not use this for poi
    local px_per_nm = get_px_per_nm(data)
    
    local distance = get_distance_nm(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
    local distance_px = distance * px_per_nm
    local bearing  = get_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,lat,lon)
    
    local x = size[1]/2 + distance_px * math.cos(math.rad(bearing+data.inputs.heading))
    local y = size[1]/2 + distance_px * math.sin(math.rad(bearing+data.inputs.heading))
    
    return x,y
end

local function draw_poi_array(data, poi, texture, color)
    local modified = false

    -- 588 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = get_range_in_nm(data)
    -- The the per_px nm is:
    local px_per_nm = 588 / range_in_nm

    if poi.distance == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
       poi.distance = get_distance_nm(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,poi.lat,poi.lon)
    end
    
    if poi.distance > range_in_nm * 2 then
        return true, poi
    end

    if poi.x == nil or poi.y == nil or (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE then
        modified = true
        
        local bearing  = get_bearing(data.inputs.plane_coords_lat,data.inputs.plane_coords_lon,poi.lat,poi.lon)
        
        local distance_px = poi.distance * px_per_nm

        poi.x = size[1]/2 + distance_px * math.cos(math.rad(bearing+data.inputs.heading))
        poi.y = size[1]/2 + distance_px * math.sin(math.rad(bearing+data.inputs.heading))
    end


    if poi.x > 0 and poi.x < size[1] and poi.y > 0 and poi.y < size[2] then
        sasl.gl.drawTexture(texture, poi.x-16, poi.y-16, 32,32, color)
        sasl.gl.drawText(Font_AirbusDUL, poi.x+25, poi.y-16, poi.id, 36, false, false, TEXT_ALIGN_LEFT, color)        
    end
    
    return modified, poi
end

local function draw_airports(data)
    if data.config.extra_data ~= ND_DATA_ARPT then
        return  -- Airport button not selected
    end
    
    -- For each airtport visible...
    for i,airport in ipairs(data.poi.arpt) do
        local modified, poi = draw_poi_array(data, airport, image_point_apt, ECAM_MAGENTA)
        if modified then
            data.poi.arpt[i] = poi
        end
    end
end

local function draw_vors(data)

    if data.config.extra_data ~= ND_DATA_VORD then
        return  -- Vor button not selected
    end

    -- For each airtport visible...
    for i,vor in ipairs(data.poi.vor) do
        local modified, poi = draw_poi_array(data, vor, image_point_vor, ECAM_MAGENTA)
        if modified then
            data.poi.vor[i] = poi
        end
    end
    
end

local function draw_ndbs(data)

    if data.config.extra_data ~= ND_DATA_NDB then
        return  -- Vor button not selected
    end

    -- For each airtport visible...
    for i,ndb in ipairs(data.poi.ndb) do
        local modified, poi = draw_poi_array(data, ndb, image_point_ndb, ECAM_MAGENTA)
        if modified then
            data.poi.ndb[i] = poi
        end
    end
    
end

local function draw_wpts(data)

    if data.config.extra_data ~= ND_DATA_WPT then
        return  -- Vor button not selected
    end

    local displayed_num = 0
    data.misc.map_partially_displayed = false
    
    -- For each waypoint visible...
    for i,wpt in ipairs(data.poi.wpt) do
        displayed_num = displayed_num + 1
        local modified, poi = draw_poi_array(data, wpt, image_point_wpt, ECAM_MAGENTA)
        if modified then
            data.poi.wpt[i] = poi
        end
        
        if displayed_num > MAX_LIMIT_WPT and data.config.range >= ND_RANGE_160 then
            data.misc.map_partially_displayed = true
            break
        end
    end
    
end

local function draw_terrain(data)

--    local terrain_coords = {lat=, lon=, color=}

--    sasl.gl.drawRectangle (size[1]/2 , size[2]/2, 32, 32, ECAM_RED)
end

local function draw_pois(data)

    if data.config.range <= ND_RANGE_ZOOM_2 then
        return  -- POIs are not drawn during the zoom mode
    end

    
    draw_airports(data)
    draw_vors(data)
    draw_ndbs(data)
    draw_wpts(data)

    local need_to_update_poi = (get(TIME) - poi_position_last_update) > POI_UPDATE_RATE
    if need_to_update_poi then
        poi_position_last_update = get(TIME)
    end


end

local function compute_angle(x1, y1, x2, y2)
    return math.atan2(y1-y2, x1-x2)
end 

local function draw_oans_rwy(data, rwy_start, rwy_end)

    local x_start,y_start = get_x_y(data, rwy_start.lat, rwy_start.lon)
    local x_end,y_end = get_x_y(data, rwy_end.lat, rwy_end.lon)

    local px_per_nm = get_px_per_nm(data)
    local semiwidth_px = math.floor(rwy_start.width * 0.000539957 * px_per_nm / 2)

    local angle = compute_angle(x_end,y_end,x_start,y_start)    -- This is the runway angle
    local perp_angle = angle + 3.14 / 2 -- This the angle of the base of the runway
    
    -- Draw runway
    
    local x_shift = semiwidth_px * math.cos(perp_angle)
    local y_shift = semiwidth_px * math.sin(perp_angle)
    
    local ll_x = x_start + x_shift
    local ll_y = y_start + y_shift
    local lr_x = x_start - x_shift
    local lr_y = y_start - y_shift
    local ul_x = x_end   + x_shift
    local ul_y = y_end   + y_shift
    local ur_x = x_end   - x_shift
    local ur_y = y_end   - y_shift

    sasl.gl.drawConvexPolygon ({ll_x, ll_y, lr_x, lr_y , ur_x, ur_y  , ul_x, ul_y} , true , 1 , {0.6,0.6,0.6})
    
    -- Draw runway marks
    local dist_line = 7
    local x_shift_line = (semiwidth_px-dist_line) * math.cos(perp_angle)
    local y_shift_line = (semiwidth_px-dist_line) * math.sin(perp_angle)
    local x_shift_inner = dist_line * math.cos(angle)
    local y_shift_inner = dist_line * math.sin(angle)

    local ll_x = x_start + x_shift_line + x_shift_inner
    local ll_y = y_start + y_shift_line + y_shift_inner
    local lr_x = x_start - x_shift_line + x_shift_inner
    local lr_y = y_start - y_shift_line + y_shift_inner
    local ul_x = x_end   + x_shift_line - x_shift_inner
    local ul_y = y_end   + y_shift_line - y_shift_inner
    local ur_x = x_end   - x_shift_line - x_shift_inner
    local ur_y = y_end   - y_shift_line - y_shift_inner
    sasl.gl.drawWidePolyLine  ({ll_x, ll_y, lr_x, lr_y , ur_x, ur_y  , ul_x, ul_y, ll_x, ll_y} , 1 - data.config.range * 2 , {1,1,1} )

    -- Draw center line
    sasl.gl.setLinePattern ({10.0, -10.0 })
    sasl.gl.drawLinePattern (x_start,y_start,x_end,y_end, false, ECAM_WHITE)

end

local function draw_oans(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        return  -- No OANS over zoom
    end

    local nearest_airport = Data_manager.nearest_airport
    if nearest_airport ~= nil then
    
        local apt = Data_manager.get_arpt_by_name(nearest_airport.id)
        local already_seen_runways = {}
        
        for rwyname,rwy in pairs(apt.rwys) do
            
            if already_seen_runways[rwyname] == nil then
                already_seen_runways[rwyname] = true
                already_seen_runways[rwy.sibling] = true
                
                local sibling_rwy = apt.rwys[rwy.sibling]
                draw_oans_rwy(data, rwy, sibling_rwy)

                --sasl.gl.setLinePattern ({5.0, -5.0 })
                --sasl.gl.drawLinePattern (x_start,y_start,x_end ,y_end, false, ECAM_RED)
            end            
        end
    end

    
    
    
end

local function draw_oans_info(data)
    if data.config.range > ND_RANGE_ZOOM_2 then
        return  -- No OANS over zoom
    end
    
    local nearest_airport = Data_manager.nearest_airport
    if nearest_airport ~= nil then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-30, size[2]-40, nearest_airport.name, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]-30, size[2]-75, nearest_airport.id, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    end
end

function draw_rose_unmasked(data)
    draw_backgrounds(data)
    draw_fixed_symbols(data)
    draw_track_symbol(data)
    draw_hdgsel_symbol(data)
    draw_ls_symbol(data)
    draw_ranges(data)
    draw_oans_info(data)
end

function draw_rose(data)

    draw_terrain(data)
    draw_pois(data)
    draw_oans(data)
    draw_navaid_pointers(data)

end

