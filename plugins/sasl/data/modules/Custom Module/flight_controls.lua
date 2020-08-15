--variables--
local total_roll = 0
local total_pitch = 0
local total_yaw = 0

--sim datarefs
local roll = globalProperty("sim/joystick/yoke_roll_ratio")
local pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
local yaw = globalProperty("sim/joystick/yoke_heading_ratio")

local servo_roll = globalProperty("sim/joystick/servo_roll_ratio")
local servo_pitch = globalProperty("sim/joystick/servo_pitch_ratio")
local servo_yaw = globalProperty("sim/joystick/servo_heading_ratio")

local roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
local pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
local yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")

local elev_trim_ratio = globalProperty("sim/cockpit2/controls/elevator_trim")
local max_elev_trim_up = globalProperty("sim/aircraft/controls/acf_hstb_trim_up")
local max_elev_trim_dn = globalProperty("sim/aircraft/controls/acf_hstb_trim_dn")

local left_aileron = globalProperty("sim/flightmodel/controls/wing2l_ail1def") -- -25 deg up 25 deg down
local left_inboard_spoilers = globalProperty("sim/flightmodel/controls/wing1l_spo1def")--50 degrees ground spoilers
local left_outboard_spoilers2 = globalProperty("sim/flightmodel/controls/wing2l_spo1def") --roll spoilers 25 deg max up with ailerons when speed brake full, with flaps down it can roll up to 25 deg, does not deploy in flight if speed below 150 or in a.floor toga, normally 0 degrees starts at 18% aileron, 15 degrees in flight decel, 50 degrees for ground spoilers
local left_outboard_spoilers345 = globalProperty("sim/flightmodel/controls/wing2l_spo2def") --roll spoilers 35 deg max up with ailerons when speed brake full, with flaps down it can roll up to 35 deg, does not deploy in flight if speed below 150 or in a.floor toga, normally 25 degrees starts at 18% aileron, 25 degrees in flight decel, 50 degrees for ground spoilers
local left_outboard_flaps = globalProperty("sim/flightmodel/controls/wing2l_fla2def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local left_inboard_flaps = globalProperty("sim/flightmodel/controls/wing1l_fla1def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local right_aileron = globalProperty("sim/flightmodel/controls/wing2r_ail1def") -- -25 deg up 25 deg down
local right_inboard_spoilers = globalProperty("sim/flightmodel/controls/wing1r_spo1def")--50 degrees ground spoilers
local right_outboard_spoilers2 = globalProperty("sim/flightmodel/controls/wing2r_spo1def") --roll spoilers 25 deg max up with ailerons when speed brake full, with flaps down it can roll up to 25 deg, does not deploy in flight if speed below 150 or in a.floor toga, normally 0 degrees starts at 18% aileron, 15 degrees in flight decel, 50 degrees for ground spoilers
local right_outboard_spoilers345 = globalProperty("sim/flightmodel/controls/wing2r_spo2def") --roll spoilers 35 deg max up with ailerons when speed brake full, with flaps down it can roll up to 35 deg, does not deploy in flight if speed below 150 or in a.floor toga, normally 25 degrees starts at 18% aileron, 25 degrees in flight decel, 50 degrees for ground spoilers
local right_outboard_flaps = globalProperty("sim/flightmodel/controls/wing2r_fla2def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local right_inboard_flaps = globalProperty("sim/flightmodel/controls/wing1r_fla1def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local slats = globalProperty("sim/flightmodel2/controls/slat1_deploy_ratio") --deploys with flaps 0 = 0, 1 = 0.7, 2 = 0.8, 3 = 0.8, 4 = 1

local horizontal_stabilizer_deflection = globalProperty("sim/flightmodel2/controls/stabilizer_deflection_degrees")
local elevators_hstab_1 = globalProperty("sim/flightmodel/controls/hstab1_elv1def") --elevators -17 deg down 30 deg up
local elevators_hstab_2 = globalProperty("sim/flightmodel/controls/hstab2_elv1def") --elevators -17 deg down 30 deg up
local rudder = globalProperty("sim/flightmodel/controls/vstab1_rud1def") --rudder 30 deg left -30 deg right

--a321neo datarefs
local elev_trim_degrees = createGlobalPropertyf("a321neo/cockpit/controls/elevator_trim_degrees", 0, false, true, false)


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
set(elev_trim_degrees, 0)

function update()
    --sync and identify the elevator trim degrees
    set(elev_trim_degrees, get_elev_trim_degrees())

    --summing the controls
    if get(Flight_director_1_mode) == 2 or get(Flight_director_2_mode) == 2 then -- if the autopilot is on
        total_roll = get(roll) + get(roll_artstab)-- + get(servo_roll)
        total_pitch = get(pitch) + get(pitch_artstab)-- + get(servo_pitch)
        total_yaw = get(yaw) + get(yaw_artstab)-- + get(servo_yaw)
    else
        total_roll = get(roll_artstab) -- roll rate commanding
        total_pitch = get(pitch_artstab) --G commanding
        total_yaw = get(yaw) + get(yaw_artstab)
    end


    if get(Override_control_surfaces) == 1 then

        if get(Speedbrake_handle_ratio) == 1 and get(Aft_wheel_on_ground) == 1 and (get(Eng_1_reverser_deployment) > 0.1 or get(Eng_2_reverser_deployment) > 0.1) then
            --ailerons
            Set_dataref_linear_anim(left_aileron, -25, -25, 25, 50, 0.5)
            Set_dataref_linear_anim(right_aileron, -25, -25, 25, 50, 0.5)
        else
            --ailerons
            Set_dataref_linear_anim(left_aileron, 25 * (total_roll) + (5 * get(Flaps_handle_deploy_ratio)), -25, 25, 50, 0.5)
            Set_dataref_linear_anim(right_aileron, -25 * (total_roll) + (5 * get(Flaps_handle_deploy_ratio)), -25, 25, 50, 0.5)
        end

        --roll spoilers--
        if get(Aft_wheel_on_ground) == 1 and (get(Eng_1_reverser_deployment) > 0.1 or get(Eng_2_reverser_deployment) > 0.1) then --missing reverser logic
            Set_dataref_linear_anim(left_inboard_spoilers, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 1)
            Set_dataref_linear_anim(left_outboard_spoilers2, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 1)
            Set_dataref_linear_anim(left_outboard_spoilers345, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 1)

            Set_dataref_linear_anim(right_inboard_spoilers, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 1)
            Set_dataref_linear_anim(right_outboard_spoilers2, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 1)
            Set_dataref_linear_anim(right_outboard_spoilers345, 50 * get(Speedbrake_handle_ratio), 0, 50, 46.5, 1)
        else
            --left inboard spoiler
            Set_dataref_linear_anim(left_inboard_spoilers, 0, 0, 50, 46.5, 1)
            --left outboard spoiler 2
            if get(left_outboard_spoilers2) > 25 then--come down from ground spoiler position
                Set_dataref_linear_anim(left_outboard_spoilers2, 25, 0, 50, 46.5, 1)
            else--normal control
                if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                    if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(left_outboard_spoilers2, -25 * ((total_roll + 0.18)/0.82), 0, 25, 46.5, 1)
                    else
                        Set_dataref_linear_anim(left_outboard_spoilers2, -25 * ((total_roll + 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 1)
                    end
                else--if flaps not down operate in normal range of motion
                    if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(left_outboard_spoilers2, -15 * ((total_roll + 0.18)/0.82), 0, 25, 46.5, 1)
                    else
                        Set_dataref_linear_anim(left_outboard_spoilers2, -15 * ((total_roll + 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 1)
                    end
                end
            end
            --left outboard spoilers 345
            if get(left_outboard_spoilers345) > 35 then--come down from ground spoiler position
                Set_dataref_linear_anim(left_outboard_spoilers345, 35, 0, 50, 46.5, 1)
            else--normal control
                if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                    if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(left_outboard_spoilers345, -35 * ((total_roll + 0.18)/0.82), 0, 35, 46.5, 1)
                    else
                        Set_dataref_linear_anim(left_outboard_spoilers345, -35 * ((total_roll + 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 1)
                    end
                else--if flaps not down operate in normal range of motion
                    if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(left_outboard_spoilers345, -25 * ((total_roll + 0.18)/0.82), 0, 35, 46.5, 1)
                    else
                        Set_dataref_linear_anim(left_outboard_spoilers345, -25 * ((total_roll + 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 1)
                    end
                end
            end

            --right inboard spoiler
            Set_dataref_linear_anim(right_inboard_spoilers, 0, 0, 50, 46.5, 1)
            --right outboard spoiler 2
            if get(right_outboard_spoilers2) > 25 then--come down from ground spoiler position
                Set_dataref_linear_anim(right_outboard_spoilers2, 25, 0, 50, 46.5, 1)
            else--normal control
                if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                    if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(right_outboard_spoilers2, 25 * ((total_roll - 0.18)/0.82), 0, 25, 46.5, 1)
                    else
                        Set_dataref_linear_anim(right_outboard_spoilers2, 25 * ((total_roll - 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 1)
                    end
                else--if flaps not down operate in normal range of motion
                    if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(right_outboard_spoilers2, 15 * ((total_roll - 0.18)/0.82), 0, 25, 46.5, 1)
                    else
                        Set_dataref_linear_anim(right_outboard_spoilers2, 15 * ((total_roll - 0.18)/0.82) + 15 * get(Speedbrake_handle_ratio), 0, 25, 46.5, 1)
                    end
                end
            end
            --right outboard spoilers 345
            if get(right_outboard_spoilers345) > 35 then--come down from ground spoiler position
                Set_dataref_linear_anim(right_outboard_spoilers345, 35, 0, 50, 46.5, 1)
            else--normal control
                if get(Flaps_handle_deploy_ratio) > 0 then--flaps down increase range of motion
                    if get(Flaps_handle_deploy_ratio) > 0.75 or get(IAS) < 150 then--if flap in full detent or speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(right_outboard_spoilers345, 35 * ((total_roll - 0.18)/0.82), 0, 35, 46.5, 1)
                    else
                        Set_dataref_linear_anim(right_outboard_spoilers345, 35 * ((total_roll - 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 1)
                    end
                else--if flaps not down operate in normal range of motion
                    if get(IAS) < 150 then--if speed lower than 150 do not allow decel
                        Set_dataref_linear_anim(right_outboard_spoilers345, 25 * ((total_roll - 0.18)/0.82), 0, 35, 46.5, 1)
                    else
                        Set_dataref_linear_anim(right_outboard_spoilers345, 25 * ((total_roll - 0.18)/0.82) + 25 * get(Speedbrake_handle_ratio), 0, 35, 46.5, 1)
                    end
                end
            end
        end

        --pitch inputs
        if total_pitch >= 0 then
            Set_dataref_linear_anim(elevators_hstab_1, -30 * (total_pitch), -30, 17, 150, 1)
            Set_dataref_linear_anim(elevators_hstab_2, -30 * (total_pitch), -30, 17, 150, 1)
        else
            Set_dataref_linear_anim(elevators_hstab_1, -17 * (total_pitch), -30, 17, 150, 1)
            Set_dataref_linear_anim(elevators_hstab_2, -17 * (total_pitch), -30, 17, 150, 1)
        end

        --flap inputs
        if get(Flaps_handle_deploy_ratio) >= 0 then
            set(slats, Math_clamp(0.7 * get(Flaps_handle_deploy_ratio)/0.25, 0, 0.7))
            set(left_inboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
            set(left_outboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
            set(right_inboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
            set(right_outboard_flaps, Math_clamp(10 * get(Flaps_handle_deploy_ratio)/0.25, 0, 10))
            if get(Flaps_handle_deploy_ratio) > 0.25 then
                set(slats, Math_clamp(get(slats) + 0.1 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 0.7, 0.8))
                set(left_inboard_flaps, Math_clamp(get(left_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
                set(left_outboard_flaps, Math_clamp(get(left_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
                set(right_inboard_flaps, Math_clamp(get(right_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
                set(right_outboard_flaps, Math_clamp(get(right_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.25)/0.25, 10, 15))
            end
            if get(Flaps_handle_deploy_ratio) > 0.5 then
                set(slats, Math_clamp(get(slats) + 0 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 0.8, 0.8))
                set(left_inboard_flaps, Math_clamp(get(left_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
                set(left_outboard_flaps, Math_clamp(get(left_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
                set(right_inboard_flaps, Math_clamp(get(right_inboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
                set(right_outboard_flaps, Math_clamp(get(right_outboard_flaps) + 5 * (get(Flaps_handle_deploy_ratio)-0.50)/0.25, 15, 20))
            end
            if get(Flaps_handle_deploy_ratio) > 0.75 then
                set(slats, Math_clamp(get(slats) + 0.2 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 0.8, 1))
                set(left_inboard_flaps, Math_clamp(get(left_inboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
                set(left_outboard_flaps, Math_clamp(get(left_outboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
                set(right_inboard_flaps, Math_clamp(get(right_inboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
                set(right_outboard_flaps, Math_clamp(get(right_outboard_flaps) + 20 * (get(Flaps_handle_deploy_ratio)-0.75)/0.25, 20, 40))
            end
        end

        --rudder
        Set_dataref_linear_anim(rudder, 30 * (total_yaw), -30, 30, 25, 0.5)
    end
end