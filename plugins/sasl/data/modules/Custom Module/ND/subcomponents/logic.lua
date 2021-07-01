include('ADIRS_data_source.lua')
include('ND/subcomponents/constants.lua')
include('ND/subcomponents/logic_poi.lua')
include('DRAIMS/radio_logic.lua')
include('FMGS/functions.lua')

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

local function update_position_fmgs(data)
    data.misc.off_side_control      = false
    data.misc.off_side_control_mode = false
    data.misc.off_side_control_rng  = false
    
    local fmgs_status = FMGS_get_status();

    if fmgs_status == FMGS_MODE_SINGLE then
        data.misc.off_side_control = FMGS_get_master() ~= data.id
        if data.misc.off_side_control then
            if ND_all_data[ND_CAPT].config.mode ~= ND_all_data[ND_FO].config.mode then
                data.misc.off_side_control_mode = true
                data.misc.map_not_avail = true
            end
            if ND_all_data[ND_CAPT].config.range ~= ND_all_data[ND_FO].config.range then
                data.misc.off_side_control_rng = true
                data.misc.map_not_avail = true
            end
        end
    elseif fmgs_status == FMGS_MODE_BACKUP then
        data.misc.backup_nav = true
    elseif fmgs_status == FMGS_MODE_OFF then
        data.misc.map_not_avail = true
    end
end

local function update_position(data)
    local id = data.id

    data.misc.map_not_avail = ((not adirs_is_position_ok(id) and data.config.range > ND_RANGE_ZOOM_2) 
                              or not AvionicsBay.is_initialized() or (not AvionicsBay.apts.is_nearest_apt_computed() and data.config.range <= ND_RANGE_ZOOM_2))
    data.misc.map_partially_displayed = (AvionicsBay.is_initialized() and not AvionicsBay.is_ready()) or data.misc.not_displaying_all_data

    data.misc.not_displaying_all_data = false -- reset it

    update_position_fmgs(data) -- This may change data.misc.map_not_avail

    if not data.misc.map_not_avail then
        local ret = adirs_get_fms(id)
        if ret[1] == nil or ret[2] == nil then
            data.misc.map_not_avail = true
        else
            data.inputs.plane_coords_lat, data.inputs.plane_coords_lon = ret[1], ret[2]
        end
    end
end

local function update_gps(data)
    local was_lost = data.misc.gps_primary_lost 
    data.misc.gps_primary_lost = not FMGS_sys.config.gps_primary

    if not data.misc.gps_primary_lost and was_lost then
        set(ND_GPIRS_indication, 1)    -- it can be killed by MCDU
    end

    data.misc.gpirs_is_on = get(ND_GPIRS_indication) > 0
end

local function update_tcas(data)
    if get(TCAS_actual_mode) == TCAS_MODE_OFF then
        data.misc.tcas_status = ND_TCAS_OFF
    elseif get(TCAS_actual_mode) == TCAS_MODE_TA then
        data.misc.tcas_status = ND_TCAS_TA_ONLY
    elseif get(TCAS_actual_mode) == TCAS_MODE_TARA then
        data.misc.tcas_status = ND_TCAS_OK
    elseif get(TCAS_actual_mode) == TCAS_MODE_FAULT then
        data.misc.tcas_status = ND_TCAS_FAULT
    end

    data.misc.tcas_ra_triggered = TCAS_sys.alert.type == TCAS_ALERT_RA
    data.misc.tcas_ta_triggered = TCAS_sys.alert.type == TCAS_ALERT_TA
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

local function update_whr_shear(data)
    if data.config.range <= ND_RANGE_ZOOM_2 and (data.config.mode == ND_MODE_VOR or data.config.mode == ND_MODE_ILS) then
        data.misc.windshear_inc_range = true
    else
        data.misc.windshear_inc_range = false
    end
end

local function update_oans_inflight_no_plan(data)

    local at_least_one = false

    local arr_apt = FMGS_get_apt_arr()
    if arr_apt then
        -- Arrival airport
        local arr_distance    = get_distance_nm(data.inputs.plane_coords_lat, data.inputs.plane_coords_lon, arr_apt.lat, arr_apt.lon)
        local arr_diff_height = math.abs(data.inputs.altitude - arr_apt.alt)
        if arr_distance < 20 and arr_diff_height < 5000 then
            data.oans.displayed_apt = arr_apt
            return
        end
        at_least_one = true
    end

    local alt_apt = FMGS_get_apt_alt()
    if alt_apt then
        -- Alternate airport
        local alt_distance    = get_distance_nm(data.inputs.plane_coords_lat, data.inputs.plane_coords_lon, alt_apt.lat, alt_apt.lon)
        local alt_diff_height = math.abs(data.inputs.altitude - alt_apt.alt)
        if alt_distance < 20 and alt_diff_height < 5000 then
            data.oans.displayed_apt = alt_apt
            return
        end
        at_least_one = true
    end

    local dep_apt = FMGS_get_apt_dep()
    if dep_apt then
        -- Departure airport
        local dep_distance    = get_distance_nm(data.inputs.plane_coords_lat, data.inputs.plane_coords_lon, dep_apt.lat, dep_apt.lon)
        local dep_diff_height = math.abs(data.inputs.altitude - dep_apt.alt)
        if dep_distance < 20 and dep_diff_height < 5000 then
            data.oans.displayed_apt = dep_apt
            return
        end
        at_least_one = true
    end

    if data.oans.displayed_apt == nil and arr_apt then
        data.oans.displayed_apt = arr_apt -- Far from all, display the destination for the arrow purposes
    end
    
    if not at_least_one then
    
        data.misc.oans_arpt_not_active = true
    end
end

local function update_oans(data)
    data.oans.displayed_apt = nil
    data.misc.oans_arpt_not_active = false

    if not (AvionicsBay.is_initialized() and AvionicsBay.is_ready()) then
        return
    end

    local nearest_airport = AvionicsBay.apts.get_nearest_apt(true)
    if get(All_on_ground) == 1 and data.config.mode ~= ND_MODE_PLAN then
        data.oans.displayed_apt = nearest_airport
        return
    end

    -- In flight or in PLAN

    if data.config.mode == ND_MODE_PLAN then
        local dep_apt = FMGS_get_apt_dep()
        local arr_apt = FMGS_get_apt_arr()
        data.misc.oans_arpt_not_active = get(All_on_ground) == 1 and not (dep_apt and nearest_airport.id == dep_apt.id)
        
        if dep_apt and arr_apt then
            -- Departure and Arrival airport
            local cross_dist = get_distance_nm(arr_apt.lat, arr_apt.lon, dep_apt.lat, dep_apt.lon)
            if cross_dist < 300 then
                data.oans.displayed_apt = arr_apt
            elseif get_distance_nm(data.inputs.plane_coords_lat, data.inputs.plane_coords_lon, dep_apt.lat, dep_apt.lon) < 50 then
                data.oans.displayed_apt = dep_apt
            else
                data.oans.displayed_apt = arr_apt
            end
            return
        else
            data.misc.oans_arpt_not_active = true
            return
        end

    else
        -- In flight, ARC or ROSE
        update_oans_inflight_no_plan(data)
    end


end

local function update_plan_coords(data)
    if data.config.mode ~= ND_MODE_PLAN or data.config.range <= ND_RANGE_ZOOM_2 then
        return
    end
    
    --[[if #FMGS_sys.fpln.active.legs > 0  then
        local n_wpt = FMGS_sys.fpln.active.legs[FMGS_sys.fpln.active.next_leg]
        data.plan_ctr_lat = n_wpt.lat
        data.plan_ctr_lon = n_wpt.lon
    else]]--
        data.plan_ctr_lat = data.inputs.plane_coords_lat
        data.plan_ctr_lon = data.inputs.plane_coords_lon
    --end -- TODO There are other cases (page scrolls, etc.)
end


function update_main(data)
    update_speed_and_wind(data)
    update_hdg_track(data)
    update_gps(data)
    update_tcas(data)
    update_position(data)
    update_navaid_raw(data)
    update_whr_shear(data)

    update_poi(data)
    update_altitude(data)

    update_plan_coords(data)

    update_oans(data)
end
