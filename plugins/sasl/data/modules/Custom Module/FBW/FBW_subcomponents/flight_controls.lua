include("FBW_subcomponents/flight_ctl_subcomponents/slat_flaps_control.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/lateral_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/vertical_ctl.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/check_avil_and_failure.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/yaw_control.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/ground_spoilers.lua")
include("FBW_subcomponents/flight_ctl_subcomponents/input_handling.lua")

--draw properties
position = {1914, 1405, 147, 57}
size = {147, 57}

local LED_font = sasl.gl.loadFont("fonts/digital-7.mono.ttf")
local LED_text_cl = {235/255, 200/255, 135/255}

--variables--
local last_total_failure = 0--last value of the up shit creek dataref

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
set(Override_control_surfaces, 1)
set(Speedbrake_handle_ratio, 0)

function onPlaneLoaded()
    set(Override_control_surfaces, 1)
    set(Speedbrake_handle_ratio, 0)
end

function onAirportLoaded()
    set(Override_control_surfaces, 1)
    set(Speedbrake_handle_ratio, 0)
end

function onModuleShutdown()--reset things back so other planes will work
    set(Override_control_surfaces, 0)
end

function update()
    FBW_input_handling()

    --sync and identify the elevator trim degrees
    if get(Trim_wheel_smoothing_on) == 1 then
        set(Elev_trim_degrees, Set_anim_value(get(Elev_trim_degrees), get_elev_trim_degrees(), -get(Max_THS_dn), get(Max_THS_up), 5))
    else
        set(Elev_trim_degrees, get_elev_trim_degrees())
    end

    if get(Override_control_surfaces) == 1 then
        if get(DELTA_TIME) ~= 0 then
            Check_surface_avail()
            Ailerons_control(get(FBW_roll_output), true, Ground_spoilers_output(Ground_spoilers_var_table))
            Spoilers_control(get(FBW_roll_output), get(Speedbrake_handle_ratio), Ground_spoilers_output(Ground_spoilers_var_table), false, Spoilers_obj)
            Elevator_control(get(FBW_pitch_output), false)
            Slats_flaps_calc_and_control()
            THS_control(Augmented_pitch_trim_ratio, get(Human_pitch_trim))
            Rudder_control(get(FBW_yaw_output), get(Human_rudder_trim), get(Resetting_rudder_trim))
            Up_shit_creek(last_total_failure)
            last_total_failure = get(FAILURE_FCTL_UP_SHIT_CREEK)
        end
    end
end

function draw()
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 - 55, size[2] / 2 - 24, get(Rudder_trim_target_angle) >= 0 and "R" or "L",            1, 68, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 + 30, size[2] / 2 - 24, math.floor(math.abs(get(Rudder_trim_target_angle))),          2, 68, TEXT_ALIGN_RIGHT, 0.2, 1, 1)
    Draw_green_LED_num_and_letter(size[1] / 2 + 55, size[2] / 2 - 24, Math_extract_decimal(get(Rudder_trim_target_angle), 1, true), 1, 68, TEXT_ALIGN_CENTER, 0.2, 1, 1)
    sasl.gl.drawText(LED_font, size[1] / 2 + 35, size[2] / 2 - 24, ".", 68, false, false, TEXT_ALIGN_CENTER, {LED_text_cl[1], LED_text_cl[2], LED_text_cl[3], 1})
end