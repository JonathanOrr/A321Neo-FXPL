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

local override_artstab = globalProperty("sim/operation/override/override_artstab")
local override_surfaces = globalProperty("sim/operation/override/override_control_surfaces")

local elev_trim_ratio = globalProperty("sim/cockpit2/controls/elevator_trim")
local max_elev_trim_up = globalProperty("sim/aircraft/controls/acf_hstb_trim_up")
local max_elev_trim_dn = globalProperty("sim/aircraft/controls/acf_hstb_trim_dn")

local left_aileron = globalProperty("sim/flightmodel/controls/lail1def") --25 deg up -25 deg down
local left_outboard_spoilers = globalProperty("sim/flightmodel/controls/wing2l_spo2def") --roll spoilers 35 deg up with ailerons starts at 20% aileron, 35 degrees in flight decel, 50 degrees for ground spoilers
local left_outboard_flaps = globalProperty("sim/flightmodel/controls/wing2l_fla2def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local left_inboard_flaps = globalProperty("sim/flightmodel/controls/wing1l_fla1def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local right_aileron = globalProperty("sim/flightmodel/controls/rail1def") --25 deg up -25 deg down
local right_outboard_spoilers = globalProperty("sim/flightmodel/controls/wing2r_spo2def") --roll spoilers 35 deg up with ailerons starts at 20% aileron, 35 degrees in flight decel, 50 degrees for ground spoilers
local right_outboard_flaps = globalProperty("sim/flightmodel/controls/wing2r_fla2def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local right_inboard_flaps = globalProperty("sim/flightmodel/controls/wing1r_fla1def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local inboard_spoilers = globalProperty("sim/flightmodel2/wing/speedbrake1_deg[0]") --35 degrees in flight decel, 50 degrees ground spoilers
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

    --fly by wire--
    if get(FBW_on) == 0 then--direct law
        set(elev_trim_ratio, 0)
        set(horizontal_stabilizer_deflection, 0)

        set(left_aileron, -25 * get(roll) + get(servo_roll))
        set(right_aileron, 25 * get(roll) + get(servo_roll))

        if get(roll) + get(servo_roll) < -0.2 then
            set(left_outboard_spoilers, -35 * ((get(roll) + get(servo_roll) + 0.2)/0.8))
        else
            set(left_outboard_spoilers, 0)
        end

        if get(roll) + get(servo_roll) > 0.2 then
            set(right_outboard_spoilers, 35 * ((get(roll) + get(servo_roll) - 0.2)/0.8))
        else
            set(right_outboard_spoilers, 0)
        end

        if get(pitch) + get(servo_pitch) >= 0 then
            set(elevators_hstab_1, -30 * (get(pitch) + get(servo_pitch)))
            set(elevators_hstab_2, -30 * (get(pitch) + get(servo_pitch)))
        else
            set(elevators_hstab_1, -17 * (get(pitch) + get(servo_pitch)))
            set(elevators_hstab_2, -17 * (get(pitch) + get(servo_pitch)))
        end

        set(rudder, 30 * (get(yaw) + get(servo_yaw)))
    else--normal law
        set(left_aileron, -25 * (get(roll) + get(roll_artstab) + get(servo_roll)))
        set(right_aileron, 25 * (get(roll) + get(roll_artstab) + get(servo_roll)))

        if get(roll) + get(roll_artstab) + get(servo_roll) < -0.2 then
            set(left_outboard_spoilers, -35 * ((get(roll) + get(roll_artstab) + get(servo_roll) + 0.2)/0.8))
        else
            set(left_outboard_spoilers, 0)
        end

        if get(roll) + get(roll_artstab) + get(servo_roll) > 0.2 then
            set(right_outboard_spoilers, 35 * ((get(roll) + get(roll_artstab) + get(servo_roll) - 0.2)/0.8))
        else
            set(right_outboard_spoilers, 0)
        end

        if get(pitch) + get(pitch_artstab) + get(servo_pitch) >= 0 then
            set(elevators_hstab_1, -30 * (get(pitch) + get(pitch_artstab) + get(servo_pitch)))
            set(elevators_hstab_2, -30 * (get(pitch) + get(pitch_artstab) + get(servo_pitch)))
        else
            set(elevators_hstab_1, -17 * (get(pitch) + get(pitch_artstab) + get(servo_pitch)))
            set(elevators_hstab_2, -17 * (get(pitch) + get(pitch_artstab) + get(servo_pitch)))
        end

        set(rudder, 30 * (get(yaw) + get(yaw_artstab) + get(servo_yaw)))
    end
end