local speed_speed_speed_time = 0

local function SPEED_SPEED_SPEED()
    set(GPWS_mode_speed, 0)

    if get(FBW_total_control_law) ~= FBW_NORMAL_LAW or
       get(Flaps_internal_config) <= 2 or
       get(Capt_ra_alt_ft) < 100 or get(Fo_ra_alt_ft) < 100 or
       get(Capt_ra_alt_ft) > 2000 or get(Fo_ra_alt_ft) > 2000 or
       get(Cockpit_throttle_lever_L) >= THR_TOGA_START or get(Cockpit_throttle_lever_R) >= THR_TOGA_START or
       adirs_get_avg_ias() > get(VLS) and adirs_get_avg_ias_trend() >= 0 then--missing AFLOOR
        speed_speed_speed_time = 0
        return
    end

    local delta_vls = 0

    delta_vls = (adirs_get_avg_pitch() - FBW.FAC_COMPUTATION.MIXED.aoa) * -6 + 26 / Math_clamp_higher(adirs_get_avg_ias_trend(), 0)
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
    if get(FBW_total_control_law) == FBW_NORMAL_LAW or
       get(Any_wheel_on_ground) == 1 or
       get(FAC_1_status) == 0 and get(FAC_2_status) == 0 then
        return
    end

    if FBW.FAC_COMPUTATION.MIXED.aoa > get(FAC_MIXED_Aprot_AoA) - 0.5 then
        set(GPWS_mode_stall, 1)
    end
end

function update()
    SPEED_SPEED_SPEED()
    STALL_STALL()
end