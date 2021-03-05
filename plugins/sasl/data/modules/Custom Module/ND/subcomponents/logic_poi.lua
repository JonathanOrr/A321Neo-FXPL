local last_poi_update = 0
local prev_range = 0

local function table_concat(table1,table2)
    local t1_init_length = #table1 
    for i=1,#table2 do
        table1[t1_init_length+i] = table2[i]
    end
    return table1
end


local function update_airports(data)

    data.poi.arpt =  AvionicsBay.apts.get_by_coords(adirs_get_lat(data.id), adirs_get_lon(data.id), false)
    if data.config.range >= ND_RANGE_160 then
        data.poi.arpt = table_concat(data.poi.arpt, AvionicsBay.apts.get_by_coords(adirs_get_lat(data.id)+4, adirs_get_lon(data.id), false))
        data.poi.arpt = table_concat(data.poi.arpt, AvionicsBay.apts.get_by_coords(adirs_get_lat(data.id),   adirs_get_lon(data.id)+4, false))
        data.poi.arpt = table_concat(data.poi.arpt, AvionicsBay.apts.get_by_coords(adirs_get_lat(data.id)-4, adirs_get_lon(data.id), false))
        data.poi.arpt = table_concat(data.poi.arpt, AvionicsBay.apts.get_by_coords(adirs_get_lat(data.id),   adirs_get_lon(data.id)-4, false))
    end

end

local function update_vor(data)
    data.poi.vor =  AvionicsBay.navaids.get_by_coords(NAV_ID_VOR, adirs_get_lat(data.id), adirs_get_lon(data.id), false)
    if data.config.range >= ND_RANGE_160 then
        data.poi.vor = table_concat(data.poi.vor, AvionicsBay.navaids.get_by_coords(NAV_ID_VOR, adirs_get_lat(data.id)+4, adirs_get_lon(data.id), false))
        data.poi.vor = table_concat(data.poi.vor, AvionicsBay.navaids.get_by_coords(NAV_ID_VOR, adirs_get_lat(data.id),   adirs_get_lon(data.id)+4, false))
        data.poi.vor = table_concat(data.poi.vor, AvionicsBay.navaids.get_by_coords(NAV_ID_VOR, adirs_get_lat(data.id)-4, adirs_get_lon(data.id), false))
        data.poi.vor = table_concat(data.poi.vor, AvionicsBay.navaids.get_by_coords(NAV_ID_VOR, adirs_get_lat(data.id),   adirs_get_lon(data.id)-4, false))
    end
end

local function update_dme(data)
    data.poi.dme =  AvionicsBay.navaids.get_by_coords(NAV_ID_DME_ALONE, adirs_get_lat(data.id), adirs_get_lon(data.id), false)
    if data.config.range >= ND_RANGE_160 then
        data.poi.dme = table_concat(data.poi.dme, AvionicsBay.navaids.get_by_coords(NAV_ID_DME_ALONE, adirs_get_lat(data.id)+4, adirs_get_lon(data.id), false))
        data.poi.dme = table_concat(data.poi.dme, AvionicsBay.navaids.get_by_coords(NAV_ID_DME_ALONE, adirs_get_lat(data.id),   adirs_get_lon(data.id)+4, false))
        data.poi.dme = table_concat(data.poi.dme, AvionicsBay.navaids.get_by_coords(NAV_ID_DME_ALONE, adirs_get_lat(data.id)-4, adirs_get_lon(data.id), false))
        data.poi.dme = table_concat(data.poi.dme, AvionicsBay.navaids.get_by_coords(NAV_ID_DME_ALONE, adirs_get_lat(data.id),   adirs_get_lon(data.id)-4, false))
    end
end


local function update_ndb(data)
    data.poi.ndb =  AvionicsBay.navaids.get_by_coords(NAV_ID_NDB, adirs_get_lat(data.id), adirs_get_lon(data.id), false)
    if data.config.range >= ND_RANGE_160 then
        data.poi.ndb = table_concat(data.poi.ndb, AvionicsBay.navaids.get_by_coords(NAV_ID_NDB, adirs_get_lat(data.id)+4, adirs_get_lon(data.id), false))
        data.poi.ndb = table_concat(data.poi.ndb, AvionicsBay.navaids.get_by_coords(NAV_ID_NDB, adirs_get_lat(data.id),   adirs_get_lon(data.id)+4, false))
        data.poi.ndb = table_concat(data.poi.ndb, AvionicsBay.navaids.get_by_coords(NAV_ID_NDB, adirs_get_lat(data.id)-4, adirs_get_lon(data.id), false))
        data.poi.ndb = table_concat(data.poi.ndb, AvionicsBay.navaids.get_by_coords(NAV_ID_NDB, adirs_get_lat(data.id),   adirs_get_lon(data.id)-4, false))
    end
end

local function update_wpt(data)
    data.poi.wpt = AvionicsBay.fixes.get_by_coords(adirs_get_lat(data.id), adirs_get_lon(data.id), false)
    if data.config.range >= ND_RANGE_160 then
        data.poi.wpt = table_concat(data.poi.wpt, AvionicsBay.fixes.get_by_coords(adirs_get_lat(data.id)+4, adirs_get_lon(data.id), false))
        data.poi.wpt = table_concat(data.poi.wpt, AvionicsBay.fixes.get_by_coords(adirs_get_lat(data.id), adirs_get_lon(data.id)+4, false))
        data.poi.wpt = table_concat(data.poi.wpt, AvionicsBay.fixes.get_by_coords(adirs_get_lat(data.id)-4, adirs_get_lon(data.id), false))
        data.poi.wpt = table_concat(data.poi.wpt, AvionicsBay.fixes.get_by_coords(adirs_get_lat(data.id), adirs_get_lon(data.id)-4, false))
    end
end



function update_poi(data)

    if not adirs_is_position_ok(data.id) then
        return
    end

    local is_avionics_bay_ok = AvionicsBay.is_initialized() and AvionicsBay.is_ready()

    if prev_range == data.config.range and get(TIME) - last_poi_update < 10 and is_avionics_bay_ok then
        return
    end

    prev_range = data.config.range

    last_poi_update = get(TIME)

    if is_avionics_bay_ok then
        update_airports(data)
        update_vor(data)
        update_dme(data)
        update_ndb(data)
        update_wpt(data)
    end
end

