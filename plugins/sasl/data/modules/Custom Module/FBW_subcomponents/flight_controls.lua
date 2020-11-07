include("FBW_subcomponents/flight_ctl_subcomponents/slat_flaps_control.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/lateral_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/vertical_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/check_surface_avil.lua")

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

local horizontal_stabilizer_deflection = globalProperty("sim/flightmodel2/controls/stabilizer_deflection_degrees")

--modify xplane functions
sasl.registerCommandHandler(Trim_up, 1, XP_trim_up)
sasl.registerCommandHandler(Trim_dn, 1, XP_trim_dn)
sasl.registerCommandHandler(Trim_up_mechanical, 1, XP_trim_up)
sasl.registerCommandHandler(Trim_dn_mechanical, 1, XP_trim_dn)

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

    --summing the controls
    if get(FBW_kill_switch) == 0 then
        total_roll = get(roll_artstab) -- Roll rate commanding
        total_pitch = get(pitch_artstab) --G commanding
        total_yaw = get(Yaw) + get(yaw_artstab)
    else
        total_roll = get(Roll) + get(roll_artstab)
        total_pitch = get(Pitch) + get(pitch_artstab)
        total_yaw = get(Yaw) + get(yaw_artstab)
    end

    if get(Override_control_surfaces) == 1 then
        if get(DELTA_TIME) ~= 0 then
            Check_surface_avail()
            Ailerons_control(total_roll, false, 0)
            Spoilers_control(total_roll, get(Speedbrake_handle_ratio), 0, false, Spoilers_var_table)
            Elevator_control(total_pitch)
            Slats_flaps_calc_and_control()
            THS_control(Augmented_pitch_trim_ratio, get(Human_pitch_trim))

            --Rudder
            --Set_dataref_linear_anim(Rudder, get(Yaw_lim) * (total_yaw), -30, 30, 25)
        end
    end
end