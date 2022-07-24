include('FMGS/functions.lua')

local speed_speed_speed_time = 0

local function SPEED_SPEED_SPEED()
    set(GPWS_mode_speed, 0)

    if get(FBW_total_control_law) ~= FBW_NORMAL_LAW or
       get(Flaps_internal_config) <= 2 or
       RA_sys.all_RA_user() < 100 or
       RA_sys.all_RA_user() > 2000 or
       get(Cockpit_throttle_lever_L) >= THR_TOGA_START or get(Cockpit_throttle_lever_R) >= THR_TOGA_START or
       adirs_get_avg_ias() > get(VLS) and adirs_get_avg_ias_trend() >= 0 then--missing AFLOOR
        speed_speed_speed_time = 0
        return
    end

    local delta_vls = 0

    delta_vls = (adirs_get_avg_pitch() - FBW.FMGEC.MIXED.aoa) * -6 + 26 / Math_clamp_higher(adirs_get_avg_ias_trend(), 0)
    delta_vls = Math_clamp(delta_vls, -10, 10)

    if adirs_get_avg_ias() < (get(VLS) + delta_vls) then
        if speed_speed_speed_time == 0 then
            speed_speed_speed_time = get(TIME)
        elseif get(TIME) - speed_speed_speed_time > 0.5 then-- It should be true for more than 0.5 sec to avoid spurious activations in turbolence
            set(GPWS_mode_speed, 1)
        end
    else
        speed_speed_speed_time = 0
    end
end

local function STALL_STALL()
    set(GPWS_mode_stall, 0)
    --stall warning (needs to be further comfirmed)
    if (get(FBW_total_control_law) == FBW_NORMAL_LAW and RA_sys.all_RA_user() < 1500) or
       get(Any_wheel_on_ground) == 1 or
       not FMGC_get_single_status(1) and not FMGC_get_single_status(2) then
        return
    end

    local NRM_LAW = {13.5, 21}
    local ALT_LAW = {8,    13}

    if get(FBW_total_control_law) == FBW_NORMAL_LAW then
        if FBW.FMGEC.MIXED.aoa > NRM_LAW[(get(Slats) <= 15/27) and 1 or 2] then
            set(GPWS_mode_stall, 1)
        end
    else
        if FBW.FMGEC.MIXED.aoa > ALT_LAW[(get(Slats) <= 15/27) and 1 or 2] then
            set(GPWS_mode_stall, 1)
        end
    end
end

local last_wind_dir = 0
local windshear_pfd_timer = 15

local function WINDSHEAR()
    if get(DELTA_TIME) == 0 then return end

    if RA_sys.all_RA_user() > 1300 or
       RA_sys.all_RA_user() < 50 or
       get(Flaps_internal_config) == 0 then
        set(GPWS_mode_windshear, 0)
        set(GPWS_mode_windshear_PFD, 0)
        return
    end

    set(GPWS_mode_windshear, 0)

    if windshear_pfd_timer < 15 then
        windshear_pfd_timer = windshear_pfd_timer + get(DELTA_TIME)
    else
        set(GPWS_mode_windshear_PFD, 0)
    end

    local wind_dir_delta = get(Wind_flightmodel_dir) - last_wind_dir
    local abs_wind_dir_dt = math.abs(wind_dir_delta / get(DELTA_TIME))
    last_wind_dir = get(Wind_flightmodel_dir)

    --threshold determined through flight tests
    if abs_wind_dir_dt > 35 then
        set(GPWS_mode_windshear, 1)
        set(GPWS_mode_windshear_PFD, 1)
        windshear_pfd_timer = 0
    end
end

function update()
    SPEED_SPEED_SPEED()
    STALL_STALL()
    WINDSHEAR()
end