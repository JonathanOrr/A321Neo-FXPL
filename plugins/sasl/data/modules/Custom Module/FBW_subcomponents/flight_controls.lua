include("FBW_subcomponents/flight_ctl_subcomponents/slat_flaps_control.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/lateral_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/vertical_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/check_avil_and_failure.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/yaw_control.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/input_projection.lua")

--variables--
local total_roll = 0
local total_pitch = 0
local total_yaw = 0
local last_total_failure = 0--last value of the up shit creek dataref
--sim datarefs

local servo_roll = globalProperty("sim/joystick/servo_roll_ratio")
local servo_pitch = globalProperty("sim/joystick/servo_pitch_ratio")
local servo_yaw = globalProperty("sim/joystick/servo_heading_ratio")

local roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
local pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
local yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")

local horizontal_stabilizer_deflection = globalProperty("sim/flightmodel2/controls/stabilizer_deflection_degrees")

--modify xplane functions
sasl.registerCommandHandler(Trim_up, 1, XP_trim_up)
sasl.registerCommandHandler(Trim_dn, 1, XP_trim_dn)
sasl.registerCommandHandler(Trim_up_mechanical, 1, XP_trim_up)
sasl.registerCommandHandler(Trim_dn_mechanical, 1, XP_trim_dn)
sasl.registerCommandHandler(Rudd_trim_L, 1, Rudder_trim_left)
sasl.registerCommandHandler(Rudd_trim_R, 1, Rudder_trim_right)
sasl.registerCommandHandler(Rudd_trim_reset, 1, Reset_rudder_trim)

--custom functions
local function get_elev_trim_degrees()
    if get(Elev_trim_ratio) >= 0 then
        return get(Elev_trim_ratio) * get(Max_THS_up)
    else
        return get(Elev_trim_ratio) * get(Max_THS_dn)
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
    if get(Trim_wheel_smoothing_on) == 1 then
        set(Elev_trim_degrees, Set_anim_value(get(Elev_trim_degrees), get_elev_trim_degrees(), -get(Max_THS_dn), get(Max_THS_up), 5))
    else
        set(Elev_trim_degrees, get_elev_trim_degrees())
    end

    --input augmentation
    if get(DELTA_TIME) ~= 0 then
        if get(Project_square_input) == 1 then
            Project_circle_to_square_inputs(get(Roll), get(Pitch))
        else
            set(Augmented_roll, get(Roll))
            set(Augmented_pitch, get(Pitch))
        end
    end

    --summing the controls
    if get(FBW_kill_switch) == 0 then
        total_roll = get(roll_artstab) -- Roll rate commanding
        total_pitch = get(pitch_artstab) --G commanding
        total_yaw = get(Yaw) + get(yaw_artstab)
    else
        total_roll = get(Augmented_roll) + get(roll_artstab)
        total_pitch = get(Augmented_pitch) + get(pitch_artstab)
        total_yaw = get(Yaw) + get(yaw_artstab)
    end

    if get(Override_control_surfaces) == 1 then
        if get(DELTA_TIME) ~= 0 then
            Check_surface_avail()
            Ailerons_control(total_roll, false, 0)
            Spoilers_control(total_roll, get(Speedbrake_handle_ratio), 0, false, false, Spoilers_var_table)
            Elevator_control(total_pitch)
            Slats_flaps_calc_and_control()
            THS_control(Augmented_pitch_trim_ratio, get(Human_pitch_trim))
            Rudder_control(total_yaw, 2, false, get(Human_rudder_trim), get(Resetting_rudder_trim))
            Up_shit_creek(last_total_failure)
            last_total_failure = get(FAILURE_FCTL_UP_SHIT_CREEK)
        end
    end
end