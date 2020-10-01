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
                Set_dataref_linear_anim(Left_aileron, -25, -25, 25, 50, 51 * get(DELTA_TIME))
                Set_dataref_linear_anim(Right_aileron, -25, -25, 25, 50, 51 * get(DELTA_TIME))
            else
                --ailerons
                Set_dataref_linear_anim(Left_aileron, 25 * (total_roll) + (5 * get(Flaps_handle_deploy_ratio)), -25, 25, 50, 51 * get(DELTA_TIME))
                Set_dataref_linear_anim(Right_aileron, -25 * (total_roll) + (5 * get(Flaps_handle_deploy_ratio)), -25, 25, 50, 51 * get(DELTA_TIME))
            end

            --Roll spoilers--
            if get(Aft_wheel_on_ground) == 1 and (get(Eng_1_reverser_deployment) > 0.1 or get(Eng_2_reverser_deployment) > 0.1) then --missing reverser logic
                Set_dataref_linear_anim(Left_inboard_spoilers, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 47 * get(DELTA_TIME))
                Set_dataref_linear_anim(Left_outboard_spoilers2, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 47 * get(DELTA_TIME))
                Set_dataref_linear_anim(Left_outboard_spoilers345, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 47 * get(DELTA_TIME))

                Set_dataref_linear_anim(Right_inboard_spoilers, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 47 * get(DELTA_TIME))
                Set_dataref_linear_anim(Right_outboard_spoilers2, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 47 * get(DELTA_TIME))
                Set_dataref_linear_anim(Right_outboard_spoilers345, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 47 * get(DELTA_TIME))
            else
                --left inboard spoiler
                Set_dataref_linear_anim(Left_inboard_spoilers, 0, 0, 50, 46.5, 47 * get(DELTA_TIME))
                --left outboard spoiler 2
                if get(Left_outboard_spoilers2) > 25 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Left_outboard_spoilers2, 25, 0, 50, 46.5, 47 * get(DELTA_TIME))
                else--normal control
                    if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                        if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -25 * ((total_roll + 0.18)/0.82), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -25 * ((total_roll + 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -15 * ((total_roll + 0.18)/0.82), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers2, -15 * ((total_roll + 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        end
                    end
                end
                --left outboard spoilers 345
                if get(Left_outboard_spoilers345) > 35 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Left_outboard_spoilers345, 35, 0, 50, 46.5, 47 * get(DELTA_TIME))
                else--normal control
                    if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                        if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -35 * ((total_roll + 0.18)/0.82), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -35 * ((total_roll + 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -25 * ((total_roll + 0.18)/0.82), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Left_outboard_spoilers345, -25 * ((total_roll + 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        end
                    end
                end

                --right inboard spoiler
                Set_dataref_linear_anim(Right_inboard_spoilers, 0, 0, 50, 46.5, 47 * get(DELTA_TIME))
                --right outboard spoiler 2
                if get(Right_outboard_spoilers2) > 25 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Right_outboard_spoilers2, 25, 0, 50, 46.5, 47 * get(DELTA_TIME))
                else--normal control
                    if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                        if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 25 * ((total_roll - 0.18)/0.82), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 25 * ((total_roll - 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 15 * ((total_roll - 0.18)/0.82), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers2, 15 * ((total_roll - 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 47 * get(DELTA_TIME))
                        end
                    end
                end
                --right outboard spoilers 345
                if get(Right_outboard_spoilers345) > 35 then--come down from ground spoiler position
                    Set_dataref_linear_anim(Right_outboard_spoilers345, 35, 0, 50, 46.5, 47 * get(DELTA_TIME))
                else--normal control
                    if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                        if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 35 * ((total_roll - 0.18)/0.82), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 35 * ((total_roll - 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        end
                    else--if flaps not down operate in normal range of motion
                        if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 25 * ((total_roll - 0.18)/0.82), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        else
                            Set_dataref_linear_anim(Right_outboard_spoilers345, 25 * ((total_roll - 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 47 * get(DELTA_TIME))
                        end
                    end
                end
            end

            --Pitch inputs
            if total_pitch >= 0 then
                Set_dataref_linear_anim(Elevators_hstab_1, -30 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
                Set_dataref_linear_anim(Elevators_hstab_2, -30 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
            else
                Set_dataref_linear_anim(Elevators_hstab_1, -17 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
                Set_dataref_linear_anim(Elevators_hstab_2, -17 * (total_pitch), -30, 17, 150, 151 * get(DELTA_TIME))
            end

            --flap inputs
            if get(Flaps_handle_deploy_ratio) >= 0 then
                set(Slats, Math_clamp(0.7 * get(Flaps_handle_deploy_ratio)/0.25, 0, 0.7))
                set(Left_inboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
                set(Left_outboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
                set(Right_inboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
                set(Right_outboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
                if get(Flaps_handle_deploy_ratio) > 0.25 then
                    set(Slats, Math_clamp(get(Slats) + 0.1 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 0.7, 0.8))
                    set(Left_inboard_flaps, Math_clamp(get(Left_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
                    set(Left_outboard_flaps, Math_clamp(get(Left_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
                    set(Right_inboard_flaps, Math_clamp(get(Right_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
                    set(Right_outboard_flaps, Math_clamp(get(Right_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
                end
                if get(Flaps_handle_deploy_ratio) > 0.5 then
                    set(Slats, Math_clamp(get(Slats) + 0 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 0.8, 0.8))
                    set(Left_inboard_flaps, Math_clamp(get(Left_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
                    set(Left_outboard_flaps, Math_clamp(get(Left_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
                    set(Right_inboard_flaps, Math_clamp(get(Right_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
                    set(Right_outboard_flaps, Math_clamp(get(Right_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
                end
                if get(Flaps_handle_deploy_ratio) > 0.75 then
                    set(Slats, Math_clamp(get(Slats) + 0.2 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 0.8, 1))
                    set(Left_inboard_flaps, Math_clamp(get(Left_inboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
                    set(Left_outboard_flaps, Math_clamp(get(Left_outboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
                    set(Right_inboard_flaps, Math_clamp(get(Right_inboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
                    set(Right_outboard_flaps, Math_clamp(get(Right_outboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
                end
            end

            --Rudder
            Set_dataref_linear_anim(Rudder, get(Yaw_lim) * (total_yaw), -30, 30, 25, 26 * get(DELTA_TIME))

        end
    end
end