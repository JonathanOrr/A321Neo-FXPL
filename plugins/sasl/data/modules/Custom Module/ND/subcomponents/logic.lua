include('ND/subcomponents/constants.lua')
include('ADIRS_data_source.lua')
include('ND/subcomponents/logic_poi.lua')
include('DRAIMS/radio_logic.lua')

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

local function update_altitude(data)
    local id = data.id
    
    data.inputs.altitude    = adirs_get_alt(id)
    data.inputs.vs          = adirs_get_vs(id)

end


function update_position(data)
    local id = data.id

    data.misc.map_not_avail = (not adirs_is_position_ok(id) or not AvionicsBay.is_initialized() or (not AvionicsBay.apts.is_nearest_apt_computed() and data.config.range <= ND_RANGE_ZOOM_2))
    data.misc.map_partially_displayed = (AvionicsBay.is_initialized() and not AvionicsBay.is_ready()) or data.misc.not_displaying_all_data

    data.misc.not_displaying_all_data = false -- reset it

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

local function update_navaid_raw_single(data, i)
    if data.nav[i].selector == ND_SEL_OFF then
        -- TODO Auto-FMS NAV1
    else
        data.nav[i].tuning_type = radio_vor_get_tuning_source()
    end

    data.nav[i].needle_visible = false
    if data.nav[i].selector == ND_SEL_VOR then
        data.nav[i].frequency = radio_vor_get_freq(i)
        data.nav[i].identifier = DRAIMS_common.radio.vor[i] == nil and "" or DRAIMS_common.radio.vor[i].id
        data.nav[i].is_valid = radio_vor_is_valid(i)
        data.nav[i].needle_visible = data.nav[i].is_valid
        data.nav[i].needle_angle = DRAIMS_common.radio.vor[i] == nil and 0 or DRAIMS_common.radio.vor[i].curr_bearing
        data.nav[i].dme_distance = radio_vor_get_dme_value(i)
        data.nav[i].dme_computed = radio_vor_is_dme_valid(i)
    elseif data.nav[i].selector == ND_SEL_ADF then
        data.nav[i].frequency = radio_adf_get_freq(i)
        data.nav[i].is_valid = radio_adf_is_valid(i)
        data.nav[i].identifier = DRAIMS_common.radio.adf[i] == nil and "" or DRAIMS_common.radio.adf[i].id
        data.nav[i].needle_visible = radio_adf_is_valid(i)
        data.nav[i].needle_angle = DRAIMS_common.radio.adf[i] == nil and 0 or DRAIMS_common.radio.adf[i].curr_bearing
    end

end

local function update_navaid_raw(data)

    data.nav[1].selector = data.config.nav_1_selector
    data.nav[2].selector = data.config.nav_2_selector
    
    update_navaid_raw_single(data, 1)
    update_navaid_raw_single(data, 2)

end


function update_main(data)
    update_speed_and_wind(data)
    update_hdg_track(data)
    update_gps(data)
    update_tcas(data)
    update_position(data)
    update_navaid_raw(data)

    update_poi(data)
    update_altitude(data)
end
