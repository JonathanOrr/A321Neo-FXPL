include('ND/subcomponents/constants.lua')
include('ADIRS_data_source.lua')
include('ND/subcomponents/logic_poi.lua')

local function update_speed_and_wind(data)
    local id = data.id

    data.inputs.gs = adirs_get_gs(id)
    data.inputs.is_gs_valid = adirs_is_gs_ok(id)

    data.inputs.tas = adirs_get_tas(id)
    data.inputs.is_tas_valid = adirs_is_tas_ok(id) and data.inputs.tas >= 65

    data.inputs.wind_speed = adirs_get_wind_spd(id)
    data.inputs.wind_direction = adirs_get_wind_dir(id)
    data.inputs.is_wind_valid = adirs_is_wind_ok(id) and adirs_is_tas_ok(id) and data.inputs.tas > 100
end

local function update_hdg_track(data)
    local id = data.id
    
    data.inputs.heading          = adirs_get_hdg(id)
    data.inputs.true_heading     = adirs_get_true_hdg(id)
    data.inputs.is_heading_valid = adirs_is_hdg_ok(id)

    data.inputs.track = adirs_get_track(id)
    data.inputs.is_track_valid = adirs_is_track_ok(id)

    if adirs_is_true_hdg_ok(id) and adirs_is_position_ok(id) and (adirs_get_lat(id) > 73 or adirs_get_lat(id) < -60) then
        data.inputs.is_true_heading_showed = true
        data.inputs.is_true_heading_boxed_showed = get(Flaps_internal_config) > 0
    end

end

function update_position(data)
    local id = data.id

    data.misc.map_not_avail = not adirs_is_position_ok(id)

    if not data.misc.map_not_avail then
        data.inputs.plane_coords_lat = adirs_get_lat(id) 
        data.inputs.plane_coords_lon = adirs_get_lon(id) 
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

local function update_navaid_bearing(data)
    local id = data.id
    
    -- These are necessary for ROSE-VOR and ROSE-ILS mode even if the
    -- VOR is not selected
    data.nav[1].crs = get(NAV_1_capt_obs)
    data.nav[1].crs_is_computed = adirs_is_hdg_ok(id)
    data.nav[2].crs = get(NAV_2_fo_obs)
    data.nav[2].crs_is_computed = adirs_is_hdg_ok(id)
    data.inputs.which_nav_is_active = data.id == ND_CAPT and 1 or 2
    
    data.nav[1].deviation_is_visible = get(NAV_1_is_valid) == 1
    data.nav[2].deviation_is_visible = get(NAV_2_is_valid) == 1
    data.nav[1].deviation_deg = get(NAV_1_bearing_deg) - data.nav[1].crs
    data.nav[2].deviation_deg = get(NAV_2_bearing_deg) - data.nav[2].crs
    
end

function update_main(data)
    update_speed_and_wind(data)
    update_hdg_track(data)
    update_gps(data)
    update_tcas(data)
    update_position(data)
    update_navaid_raw(data)
    update_navaid_bearing(data)
    update_poi(data)
end
