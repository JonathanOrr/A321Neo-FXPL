include('ND/subcomponents/constants.lua')
include('ADIRS_data_source.lua')

local function update_speed_and_wind(data)
    local id = data.id

    data.inputs.gs = get_gs(id)
    data.inputs.is_gs_valid = is_gs_ok(id)

    data.inputs.tas = get_tas(id)
    data.inputs.is_tas_valid = is_tas_ok(id) and data.inputs.tas >= 65

    data.inputs.wind_speed = get_wind_spd(id)
    data.inputs.wind_direction = get_wind_dir(id)
    data.inputs.is_wind_valid = is_wind_ok(id) and is_tas_ok(id) and data.inputs.tas > 100
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

local function update_gps(data)
    data.misc.gps_primary_lost = get(GPS_1_is_available) == 0 and get(GPS_2_is_available) == 0
    -- TODO gpirs_is_on
end

local function update_tcas(data)
    data.misc.tcas_status = ND_TCAS_OK
end

local function update_navaid_raw(data)

    data.nav[1].selector = data.config.nav_1_selector
    data.nav[2].selector = data.config.nav_2_selector

    if data.nav[1].selector == ND_SEL_OFF then
        -- TODO Auto-FMS NAV1
    else
        data.nav[1].tuning_type = ND_NAV_TUNED_R
    end

    if data.nav[2].selector == ND_SEL_OFF then
        -- TODO Auto-FMS NAV1
    else
        data.nav[2].tuning_type = ND_NAV_TUNED_R
    end

    if data.nav[1].selector == ND_SEL_VOR then
        data.nav[1].frequency = get(NAV_1_freq_Mhz)*100 + get(NAV_1_freq_10khz)
        data.nav[1].identifier = ""
        data.nav[1].is_valid = get(NAV_1_is_valid) == 1
        data.nav[1].dme_distance = get(NAV_1_dme_value)
        data.nav[1].dme_computed = get(NAV_1_dme_valid) == 1
    elseif data.nav[1].selector == ND_SEL_ADF then
        data.nav[1].frequency = get(ADF_1_freq_hz)
        data.nav[1].identifier = ""
    end

    if data.nav[2].selector == ND_SEL_VOR then
        data.nav[2].frequency = get(NAV_2_freq_Mhz)*100 + get(NAV_2_freq_10khz)
        data.nav[2].identifier = ""
        data.nav[2].is_valid = get(NAV_2_is_valid) == 1
        data.nav[2].dme_distance = get(NAV_2_dme_value)
        data.nav[2].dme_computed = get(NAV_2_dme_valid) == 1
    elseif data.nav[2].selector == ND_SEL_ADF then
        data.nav[2].frequency = get(ADF_2_freq_hz)
        data.nav[2].identifier = ""
    end

end

function update_main(data)

    update_speed_and_wind(data)
    update_hdg_track(data)
    update_gps(data)
    update_tcas(data)
    update_position(data)
    update_navaid_raw(data)
end
