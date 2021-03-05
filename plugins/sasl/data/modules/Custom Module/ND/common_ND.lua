include('ND/subcomponents/constants.lua')
include('ND/subcomponents/graphics.lua')
include('ND/subcomponents/logic.lua')


function new_dataset(input_id)
    return {

    id = input_id,

    config = {
        mode = input_id == ND_CAPT and ND_MODE_ARC or ND_MODE_NAV,
        range = ND_RANGE_10,
        extra_data = ND_DATA_NONE,
        
        nav_1_selector = ND_SEL_OFF,
        nav_2_selector = ND_SEL_OFF
    },
    
    inputs = {
        -- Speeds & Wind
        is_gs_valid = false,
        gs = 0,
        is_tas_valid = false,
        tas = 0,
        is_wind_valid = false,
        wind_speed = 0,
        wind_direction = 0,

        -- Heading
        heading = 0,
        true_heading = 0,
        track = 0,
        is_heading_valid = false,
        is_track_valid = false,
        is_true_heading_showed = false,
        is_true_heading_boxed_showed = false,   -- When slats out
        
        -- Position
        plane_coords_lat = 0, 
        plane_coords_lon = 0,
        
        -- AP
        hdg_sel = 0,
        hdg_sel_visible = false,
        
        -- LS
        ls_direction = 0,
        ls_is_visible = false,
        ls_is_precise = false,
        
        -- VOR
        which_nav_is_active = 0,    -- 0,1, or 2
        
        -- Alitudes -- Needed for Terrain
        altitude = 0,
        vs = 0
    },

    chrono = {
        is_running = false,
        is_active = false,
        start_time = 0,
        elapsed_time = 0
    },
    
    misc = {
        tcas_status  = ND_TCAS_OFF,
        tcas_ta_triggered = false,
        tcas_ra_triggered = false,
        off_side_control  = false,
        gpirs_is_on       = false,
        gps_primary_lost  = false,
        
        map_partially_displayed = false,
        map_precision_downgraded = false,
        map_precision_upgraded = false,
        
        hdg_discrepancy = false,
        ewd_discrepancy = false,
        pfd_discrepancy = false,
        sd_discrepancy = false,
        nd_discrepancy = false,
        mode_change = false,
        range_change = false,
        map_not_avail = false,
        
        windshear_warning = false,
        windshear_caution = false,
        windshear_pred_fail = false,
        
        loc_failure = false,
        vor_failure = false,
        gs_failure  = false,
        
        sid_or_app_visible = false,
        sid_or_app_text = "RNAV33L-A"
        
    },
    
    nav = { {
        selector     = ND_SEL_OFF,
        is_valid     = false,
        identifier   = "XXX",
        frequency    = 0,
        tuning_type  = ND_NAV_TUNED_NONE,
        correction   = ND_NAV_CORRECTION_NONE,
        dme_distance = 0,
        dme_computed = false,
        dme_invalid  = false,
        
        crs = 0,
        crs_is_computed = false,
        deviation_is_visible = false,
        deviation_deg = 0,
        
        needle_visible = false,
        needle_angle = 0
    }, {
        selector     = ND_SEL_OFF,
        is_valid     = false,
        identifier   = "XXX",
        frequency    = 0,
        tuning_type  = ND_NAV_TUNED_NONE,
        correction   = ND_NAV_CORRECTION_NONE,
        dme_distance = 0,
        dme_computed = false,
        dme_invalid  = false,

        crs = 0,
        crs_is_computed = false,

        needle_visible = false,
        needle_angle = 0
    }
    },
    
    poi = { -- Point of interests
        arpt = { --[[
            { lat = 45.4522, lon=9.2763, id="LIML" },
            { lat = 45.6301, lon=8.7255, id="LIMC" },
            { lat = 45.540287, lon=9.202300, id="LIMC" },
            { lat = 45.531059, lon=8.669050, id="LIMN" },
            { lat = 45.672005, lon=9.706893, id="LIME" },
            { lat = 45.720001, lon=9.593889, id="LILV" },
            { lat = 45.769444, lon=9.161111, id="LILB" },
            ]]--
        },
        vor = {
        },
        dme = {
        
        },
        ndb = {
        },
        wpt = {
        },
        cross = {
        },
        flag = {
        }
    },
    
    plan_ctr_lat = 0,
    plan_ctr_lon = 0,
    
    terrain = {
        texture = {nil,nil},          -- There are 2 textures, the old one and the new one
        center = {{},{}},      -- LAT/LON of the center of the texture (it may not correspond to the plane position!)
        texture_in_use = 2,    -- 1 or 2 is the current one (newest)?
        bl_lat = nil, bl_lon = nil,  -- Last used bottom left coordinates (for internal use only)
        tr_lat = nil, tr_lon = nil,  -- Last used top right coordinates (for internal use only)
        last_update = 0,
        min_altitude_tile = 0,
        max_altitude_tile = 0,
        min_altitude_tile_color = ECAM_GREEN,
        max_altitude_tile_color = ECAM_GREEN,
    }
}

end


function nd_chrono_handler(phase, data)
    if phase == SASL_COMMAND_BEGIN then
        if data.chrono.is_active then
            if data.chrono.is_running then
                data.chrono.is_running = false
                data.chrono.elapsed_time = get(TIME) - data.chrono.start_time
            else
                data.chrono.is_active = false
            end
        else
            data.chrono.is_active = true
            data.chrono.is_running = true
            data.chrono.start_time = get(TIME)
        end 
    end
end


function nd_pb_handler(phase, data, config)
    if phase == SASL_COMMAND_BEGIN then
        if data.config.extra_data == config then
            data.config.extra_data = ND_DATA_NONE
        else
            data.config.extra_data = config
        end
    end
end

