local last_poi_update = 0
local prev_range = 0

local function update_airports(data)
    local multi_airports = Data_manager.get_arpt_by_coords(adirs_get_lat(data.id), adirs_get_lon(data.id), data.config.range >= ND_RANGE_160)
    
    data.poi.arpt = {}
    
    for i,airports in ipairs(multi_airports) do
        for j,x in ipairs(airports) do
            table.insert(data.poi.arpt, {lat=x.lat, lon=x.lon, id=x.id})
        end
    end
end

local function update_vor(data)
    data.poi.vor =  AvionicsBay.navaids.get_by_coords(NAV_ID_VOR, adirs_get_lat(data.id), adirs_get_lon(data.id), data.config.range >= ND_RANGE_160, false)
end

local function update_ndb(data)
    data.poi.ndb =  AvionicsBay.navaids.get_by_coords(NAV_ID_NDB, adirs_get_lat(data.id), adirs_get_lon(data.id), data.config.range >= ND_RANGE_160, false)
end

local function update_wpt(data)
    local multi_fixes = Data_manager.get_fix_by_coords(adirs_get_lat(data.id), adirs_get_lon(data.id), data.config.range >= ND_RANGE_160)

    data.poi.wpt = {}
    
    for i,fixes in ipairs(multi_fixes) do
        for j,x in ipairs(fixes) do
            table.insert(data.poi.wpt, {lat=x.lat, lon=x.lon, id=x.id})
        end
    end
end



function update_poi(data)

    if not adirs_is_position_ok(data.id) then
        return
    end

    if prev_range == data.config.range and get(TIME) - last_poi_update < 10 then
        return
    end

    prev_range = data.config.range

    last_poi_update = get(TIME)

    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        update_airports(data)
        update_vor(data)
        update_ndb(data)
        update_wpt(data)
    end
end

