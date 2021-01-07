include("FBW_subcomponents/flight_ctl_subcomponents/slat_flaps_control.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/lateral_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/vertical_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/check_avil_and_failure.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/yaw_control.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/input_projection.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/ground_spoilers.lua")

--draw properties
position = {1914, 1405, 147, 57}
size = {147, 57}

local LCD_backlight_cl = {10/255, 15/255, 25/255}

local LED_font = sasl.gl.loadFont("fonts/digital-7.mono.ttf")
local LED_text_cl = {235/255, 200/255, 135/255}
local LED_backlight_text_cl = {15/255, 20/255, 15/255}
local LED_backlight_cl = {5/255, 15/255, 10/255}

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

--modify xplane functions
sasl.registerCommandHandler(Min_speedbrakes, 1, XP_min_speedbrakes)
sasl.registerCommandHandler(Max_speedbrakes, 1, XP_max_speedbrakes)
sasl.registerCommandHandler(Less_speedbrakes, 1, XP_less_speedbrakes)
sasl.registerCommandHandler(More_speedbrakes, 1, XP_more_speedbrakes)
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
set(Speedbrake_handle_ratio, 0)

function onPlaneLoaded()
    set(Override_artstab, 1)
    set(Override_control_surfaces, 1)
    set(Speedbrake_handle_ratio, 0)
end

function onAirportLoaded()
    set(Override_artstab, 1)
    set(Override_control_surfaces, 1)
    set(Speedbrake_handle_ratio, 0)
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
            Ailerons_control(total_roll, true, Ground_spoilers_output(Ground_spoilers_var_table))
            Spoilers_control(total_roll, get(Speedbrake_handle_ratio), Ground_spoilers_output(Ground_spoilers_var_table), false, false, Spoilers_obj)
            Elevator_control(total_pitch, false)
            Slats_flaps_calc_and_control()
            THS_control(Augmented_pitch_trim_ratio, get(Human_pitch_trim))
            Rudder_control(total_yaw, 2, false, get(Human_rudder_trim), get(Resetting_rudder_trim))
            Up_shit_creek(last_total_failure)
            last_total_failure = get(FAILURE_FCTL_UP_SHIT_CREEK)
        end
    end
end

function draw()
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 - 55, size[2] / 2 - 24, get(Rudder_trim_angle) >= 0 and "R" or "L",            1, 68, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 + 30, size[2] / 2 - 24, math.floor(math.abs(get(Rudder_trim_angle))),          2, 68, TEXT_ALIGN_RIGHT, 0.2, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 + 55, size[2] / 2 - 24, Math_extract_decimal(get(Rudder_trim_angle), 1, true), 1, 68, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    sasl.gl.drawText(LED_font, size[1] / 2 + 35, size[2] / 2 - 24, ".", 68, false, false, TEXT_ALIGN_CENTER, {LED_text_cl[1], LED_text_cl[2], LED_text_cl[3], 1})
end