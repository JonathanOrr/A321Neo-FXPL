include('ND/subcomponents/constants.lua')
include('ADIRS_data_source.lua')

local function update_speed_and_wind(data)
    local id = data.id

    data.inputs.is_gs_valid = is_gs_ok(id)
    data.inputs.gs = get_gs(id)

    data.inputs.is_tas_valid = is_tas_ok(id)
    data.inputs.tas = get_tas(id)

    data.inputs.is_wind_valid = is_wind_ok(id)
    data.inputs.wind_speed = get_wind_spd(id)
    data.inputs.wind_direction = get_wind_dir(id)
end

local function update_hdg_track(data)
    local id = data.id
    
    data.inputs.heading          = get_hdg(id)
    data.inputs.true_heading     = get_true_hdg(id)
    data.inputs.is_heading_valid = is_hdg_ok(id)

    data.inputs.heading = get_track(id)
    data.inputs.is_heading_valid = is_track_ok(id)

    if is_true_hdg_ok(id) and is_position_ok(id) and (get_lat(id) > 73 or get_lat(id) < -60) then
        data.inputs.is_true_heading_showed = true
        data.inputs.is_true_heading_boxed_showed = get(Flaps_internal_config) > 0
    end

end

function update_position(data)
    local id = data.id

    data.misc.map_not_avail = not is_position_ok(id)

    if not data.misc.map_not_avail then
        data.inputs.plane_coords_lat = get_lat(id) 
        data.inputs.plane_coords_lon = get_lon(id) 
    end
end

function update_main(data)

    update_speed_and_wind(data)
    update_hdg_track(data)
    update_position(data)

end
