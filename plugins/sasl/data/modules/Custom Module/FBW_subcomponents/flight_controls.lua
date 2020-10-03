--variables--
local total_roll = 0
local total_pitch = 0
local total_yaw = 0

--sim datarefs

local servo_roll = globalProperty("sim/joystick/servo_roll_ratio")
local servo_pitch = globalProperty("sim/joystick/servo_pitch_ratio")
local servo_yaw = globalProperty("sim/joystick/servo_heading_ratio")

local roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
local pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
local yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")

local elev_trim_ratio = globalProperty("sim/cockpit2/controls/elevator_trim")
local max_elev_trim_up = globalProperty("sim/aircraft/controls/acf_hstb_trim_up")
local max_elev_trim_dn = globalProperty("sim/aircraft/controls/acf_hstb_trim_dn")

local horizontal_stabilizer_deflection = globalProperty("sim/flightmodel2/controls/stabilizer_deflection_degrees")


--custom functions
local function slats_flaps_calc_and_control()
    --SFCC 1/2 status
    if get(FAILURE_SFCC_1) == 1 then
        set(SFCC_1_status, 0)
    else
        set(SFCC_1_status, 1)
    end
    if get(FAILURE_SFCC_2) == 1 then
        set(SFCC_2_status, 0)
    else
        set(SFCC_2_status, 1)
    end

    --surface speeds
    local slats_speed = 0.0625
    local flaps_speed = 2.5

    local last_flaps_handle_pos = get(Flaps_handle_position)
    set(Flaps_handle_position, Round(get(Flaps_handle_ratio) * 4))
    local flaps_handle_delta = get(Flaps_handle_position) - last_flaps_handle_pos

    if flaps_handle_delta ~= 0 then
        if last_flaps_handle_pos == 0 and flaps_handle_delta == 1 then
            if get(Capt_IAS) <= 100 then
                set(Flaps_internal_config, 2)-- 1+F
            else
                set(Flaps_internal_config, 1)-- 1
            end
        elseif last_flaps_handle_pos == 2 and flaps_handle_delta == -1 then
            if get(Capt_IAS) <= 210 then
                set(Flaps_internal_config, 2)-- 1+F
            else
                set(Flaps_internal_config, 1)-- 1
            end
        else
            if get(Flaps_handle_position) == 0 then
                set(Flaps_internal_config, 0)--0
            elseif get(Flaps_handle_position) == 2 then
                set(Flaps_internal_config, 3)--2
            elseif get(Flaps_handle_position) == 3 then
                set(Flaps_internal_config, 4)--3
            elseif get(Flaps_handle_position) == 4 then
                set(Flaps_internal_config, 5)--full
            end
        end
    else
        if get(Flaps_internal_config) == 2 and get(Capt_IAS) >= 210 then--back to 1
            set(Flaps_internal_config, 1)
        end
    end

    --speed and inhibition
    --slats
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_B_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        slats_speed = 0.0625
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_B_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        slats_speed = 0
    else
        slats_speed = 0.0625 / 2
    end
    --flaps
    if get(Hydraulic_G_press) > 1450 and get(Hydraulic_Y_press) > 1450 and get(SFCC_1_status) == 1 and get(SFCC_2_status) == 1 then
        flaps_speed = 2.5
    elseif (get(Hydraulic_G_press) < 1450 and get(Hydraulic_Y_press) < 1450) or (get(SFCC_1_status) == 0 and get(SFCC_2_status) == 0) then
        flaps_speed = 0
    else
        flaps_speed = 2.5 / 2
    end

    local past_slats_pos = get(Slats)
    local past_flaps_angle = get(Flaps_deployed_angle)

    if get(Flaps_internal_config) == 0 then--0
        set(Slats, Set_linear_anim_value(get(Slats), 0, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 0, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 1 then--1
        set(Slats, Set_linear_anim_value(get(Slats), 0.7, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 0, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 2 then--1+f
        set(Slats, Set_linear_anim_value(get(Slats), 0.7, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 10, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 3 then--2
        set(Slats, Set_linear_anim_value(get(Slats), 0.8, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 15, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 4 then--3
        set(Slats, Set_linear_anim_value(get(Slats), 0.8, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 20, 0, 40, flaps_speed))
    elseif get(Flaps_internal_config) == 5 then--full
        set(Slats, Set_linear_anim_value(get(Slats), 1, 0, 1, slats_speed))
        set(Flaps_deployed_angle, Set_linear_anim_value(get(Flaps_deployed_angle), 40, 0, 40, flaps_speed))
    end

    local new_slats_pos = get(Slats)
    local new_flaps_angle = get(Flaps_deployed_angle)

    if new_slats_pos - past_slats_pos ~= 0 then--flaps moving
        set(Slats_in_transit, 1)
    else
        set(Slats_in_transit, 0)
    end

    if new_flaps_angle - past_flaps_angle ~= 0 then--flaps moving
        set(Flaps_in_transit, 1)
    else
        set(Flaps_in_transit, 0)
    end

    set(Left_inboard_flaps, get(Flaps_deployed_angle))
    set(Left_outboard_flaps, get(Flaps_deployed_angle))
    set(Right_inboard_flaps, get(Flaps_deployed_angle))
    set(Right_outboard_flaps, get(Flaps_deployed_angle))
end

local function get_elev_trim_degrees()
    if get(elev_trim_ratio) == 0 then
        return 0
    elseif get(elev_trim_ratio) > 0 then
        return get(elev_trim_ratio) * get(max_elev_trim_up)
    elseif get(elev_trim_ratio) < 0 then
        return get(elev_trim_ratio) * get(max_elev_trim_dn)
    end
end

--init
set(Elev_trim_degrees, 0)

--initialise flight controls
set(Override_artstab, 1)
set(Override_control_surfaces, 1)

function onPlaneLoaded()
    set(Override_artstab, 1)
    set(Override_control_surfaces, 1)
end

function onAirportLoaded()
    set(Override_artstab, 1)
    set(Override_control_surfaces, 1)
end

function onModuleShutdown()--reset things back so other planes will work
    set(Override_artstab, 0)
    set(Override_control_surfaces, 0)
end

function update()
    --sync and identify the elevator trim degrees
    set(Elev_trim_degrees, get_elev_trim_degrees())

    --summing the controls
    total_roll = get(Roll) + get(roll_artstab) -- Roll rate commanding
    total_pitch = get(Pitch) + get(pitch_artstab) --G commanding
    total_yaw = get(Yaw) + get(yaw_artstab)


    if get(Override_control_surfaces) == 1 then
        if get(DELTA_TIME) ~= 0 then
            if get(Speedbrake_handle_ratio) == 1 and get(Aft_wheel_on_ground) == 1 and (get(Eng_1_reverser_deployment) > 0.1 or get(Eng_2_reverser_deployment) > 0.1) then
                --ailerons
                Set_dataref_linear_anim(Left_aileron, -25, -25, 25, 50)
                Set_dataref_linear_anim(Right_aileron, -25, -25, 25, 50)
            else
                --ailerons
                Set_dataref_linear_anim(Left_aileron, 25 * (total_roll) + (5 * get(Flaps_deployed_angle) / 40), -25, 25, 50)
                Set_dataref_linear_anim(Right_aileron, -25 * (total_roll) + (5 * get(Flaps_deployed_angle) / 40), -25, 25, 50)
            end

            --Roll spoilers--
            if get(Aft_wheel_on_ground) == 1 and (get(Eng_1_reverser_deployment) > 0.1 or get(Eng_2_reverser_deployment) > 0.1) then --missing reverser logic
                Set_dataref_linear_anim(Left_inboard_spoilers, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5)
                Set_dataref_linear_anim(Left_outboard_spoilers2, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5)
                Set_dataref_linear_anim(Left_outboard_spoilers345, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5)

                Set_dataref_linear_anim(Right_inboard_spoilers, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5)
                Set_dataref_linear_anim(Right_outboard_spoilers2, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5)
                Set_dataref_linear_anim(Right_outboard_spoilers345, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5)
            else
                --left inboard spoiler
                Set_dataref_linear_anim(Left_inboard_spoilers, 0, 0, 50, 46.5)
                --left outboard spoiler 2
                if get(Left_outboard_spoilers2) > 25 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Left_outboard_spoilers2, 25, 0, 50, 46.5)
                else--normal control
                    if get(Flaps_deployed_angle) > 0 then--flaps down increase range of motion
                        if get(Flaps_deployed_angle) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -25 * ((total_roll + 0.18)/0.82), 0, 25, 46.5)
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -25 * ((total_roll + 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5)
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -15 * ((total_roll + 0.18)/0.82), 0, 25, 46.5)
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -15 * ((total_roll + 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5)
                        end
                    end
                end
                --left outboard spoilers 345
                if get(Left_outboard_spoilers345) > 35 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Left_outboard_spoilers345, 35, 0, 50, 46.5)
                else--normal control
                    if get(Flaps_deployed_angle) > 0 then--flaps down increase range of motion
                        if get(Flaps_deployed_angle) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -35 * ((total_roll + 0.18)/0.82), 0, 35, 46.5)
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -35 * ((total_roll + 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5)
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -25 * ((total_roll + 0.18)/0.82), 0, 35, 46.5)
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -25 * ((total_roll + 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5)
                        end
                    end
                end

                --right inboard spoiler
                Set_dataref_linear_anim(Right_inboard_spoilers, 0, 0, 50, 46.5)
                --right outboard spoiler 2
                if get(Right_outboard_spoilers2) > 25 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Right_outboard_spoilers2, 25, 0, 50, 46.5)
                else--normal control
                    if get(Flaps_deployed_angle) > 0 then--flaps down increase range of motion
                        if get(Flaps_deployed_angle) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 25 * ((total_roll - 0.18)/0.82), 0, 25, 46.5)
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 25 * ((total_roll - 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5)
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 15 * ((total_roll - 0.18)/0.82), 0, 25, 46.5)
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 15 * ((total_roll - 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5)
                        end
                    end
                end
                --right outboard spoilers 345
                if get(Right_outboard_spoilers345) > 35 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Right_outboard_spoilers345, 35, 0, 50, 46.5)
                else--normal control
                    if get(Flaps_deployed_angle) > 0 then--flaps down increase range of motion
                        if get(Flaps_deployed_angle) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 35 * ((total_roll - 0.18)/0.82), 0, 35, 46.5)
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 35 * ((total_roll - 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5)
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 25 * ((total_roll - 0.18)/0.82), 0, 35, 46.5)
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 25 * ((total_roll - 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5)
                        end
                    end
                end
            end

            slats_flaps_calc_and_control()

            --Pitch inputs
            if total_pitch >= 0 then
                Set_dataref_linear_anim(Elevators_hstab_1, -30 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
                Set_dataref_linear_anim(Elevators_hstab_2, -30 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
            else
                Set_dataref_linear_anim(Elevators_hstab_1, -17 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
                Set_dataref_linear_anim(Elevators_hstab_2, -17 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
            end

            --Rudder
            Set_dataref_linear_anim(Rudder, get(Yaw_lim) * (total_yaw), -30, 30, 25, 26 * get(DELTA_TIME))

        end
    end
end