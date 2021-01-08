local function update_airports(data)
    local airports = Data_manager.get_nav_by_coords(get_lat(data.id), get_lon(data.id))
    
    print(#airports)
end

local function update_vor(data)
    local vors = Data_manager.get_nav_by_coords(NAV_ID_VOR, get_lat(data.id), get_lon(data.id))
end


function update_poi(data)

    if not is_position_ok(data.id) then
        return
    end

    update_vor(data)

end

