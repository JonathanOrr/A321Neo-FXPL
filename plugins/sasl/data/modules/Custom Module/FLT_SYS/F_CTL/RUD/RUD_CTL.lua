local function RUD_CTL(yaw_input, trim_input, resetting_trim)
    --PROPERTIES--
    local max_rudder_def = 25
    local rudder_trim_speed = 1
    local rudder_trim_reset_speed = 1.5
    --the proportion is the same no matter the limits, hence at higher speed you'll reach the limit with less deflection
    local rudder_travel_target_table = {
        {-1, -max_rudder_def},
        {0,  get(Rudder_trim_actual_angle)},
        {1,  max_rudder_def},
    }
    local rudder_travel_target = Table_interpolate(rudder_travel_target_table, yaw_input)

    --RUDDER LIMITS--
    if get(Force_full_rudder_limit) ~= 1 and FBW.fctl.RUD.STAT.controlled then
        if get(Slats) == 0 then
            set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), -22.1 * math.sqrt(1 - ( (Math_clamp(adirs_get_avg_ias(), 160, 380) - 380) / 220)^2 ) + 25, 0, max_rudder_def, rudder_trim_speed))
        end
        if get(Slats) > 0 then
            set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), 25, 0, max_rudder_def, rudder_trim_speed))
        end
    end

    if get(Force_full_rudder_limit) == 1 then
        set(Rudder_travel_lim, Set_linear_anim_value(get(Rudder_travel_lim), max_rudder_def, 0, max_rudder_def, rudder_trim_speed))
    end

    --rudder trim
    if resetting_trim == 1 then
        if trim_input ~= 0 then
            set(Resetting_rudder_trim, 0)
        elseif get(Rudder_trim_target_angle) == 0 then
            set(Resetting_rudder_trim, 0)
        end
    end

    --IF RUDDER IS ELECTRICALLY CONTROLLED--
    if FBW.fctl.RUD.STAT.controlled then
        if resetting_trim == 0 then--apply human input
            set(Rudder_trim_target_angle, Math_clamp(get(Rudder_trim_target_angle) + trim_input * rudder_trim_speed * get(DELTA_TIME), -20, 20))
            set(Human_rudder_trim, 0)
        else--reset rudder trim
            set(Rudder_trim_target_angle, Set_linear_anim_value(get(Rudder_trim_target_angle), 0, -20, 20, rudder_trim_reset_speed))
            set(Human_rudder_trim, 0)
        end

        --as normal law uses SI demand, it is needed to always center the trim, and let the controller determine the postition of the rudder
        if get(FBW_yaw_law) ~= FBW_NORMAL_LAW or get(All_on_ground) == 1 then
            set(Rudder_trim_actual_angle, Set_linear_anim_value(get(Rudder_trim_actual_angle), get(Rudder_trim_target_angle), -get(Rudder_travel_lim), get(Rudder_travel_lim), rudder_trim_reset_speed))
        else
            set(Rudder_trim_actual_angle, Set_linear_anim_value(get(Rudder_trim_actual_angle), 0, -get(Rudder_travel_lim), get(Rudder_travel_lim), rudder_trim_reset_speed))
        end
    end

    --set rudder pedal center
    local rudder_pedal_anim = {
        {-1, -20},
        {0, 20 * get(Rudder_trim_target_angle) / max_rudder_def},
        {1, 20},
    }
    set(Rudder_pedal_angle, Table_interpolate(rudder_pedal_anim, get(Total_input_yaw)))

    --rudder position calculation--
    FBW.fctl.RUD.ACT(rudder_travel_target)
    set(Rudder_top, get(Rudder_total))
    set(Rudder_btm, get(Rudder_total))
end


function update()
    RUD_CTL(get(FBW_yaw_output), get(Human_rudder_trim), get(Resetting_rudder_trim))
end