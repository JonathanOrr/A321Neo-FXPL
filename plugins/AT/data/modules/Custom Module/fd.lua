size = {800, 400}

--colors
local RED = {1, 0, 0}
local WHITE = {1.0, 1.0, 1.0}
local LIGHT_BLUE = {0, 0.708, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

local FD_button_color = LIGHT_GREY
local FD_button_text = "ENABLE"

--fonts
local B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612_bold = sasl.gl.loadFont("fonts/B612-Bold.ttf")
local B612_MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612_MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")

--sim datarefs
local vvi = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")

local roll = globalProperty("sim/joystick/yoke_roll_ratio")
local pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
local yaw = globalProperty("sim/joystick/yoke_heading_ratio")

local roll_artstab = globalProperty("sim/joystick/artstab_roll_ratio")
local pitch_artstab = globalProperty("sim/joystick/artstab_pitch_ratio")
local yaw_artstab = globalProperty("sim/joystick/artstab_heading_ratio")

local aircraft_roll = globalProperty("sim/flightmodel/position/true_phi")
local aircraft_pitch = globalProperty("sim/flightmodel/position/true_theta")
local aircraft_heading = globalProperty("sim/cockpit2/gauges/indicators/heading_electric_deg_mag_pilot")

local front_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[0]")
local left_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[1]")
local right_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[2]")

local FD_pitch = 0
local FD_roll = 0
local FD_pitch_delta = 0
local FD_roll_delta = 0

local FD_activated = createGlobalPropertyi("a32nx/debug/fd_activated", 0, false, true, false)
local target_hdg = createGlobalPropertyi("a32nx/debug/target_hdg", 180, false, true, false)
local target_vs = createGlobalPropertyi("a32nx/debug/target_vs", 0, false, true, false)
local Dataref_pitch_delta = createGlobalPropertyf("a32nx/debug/FD_pitch_delta", 0, false, true, false)
local Dataref_roll_delta = createGlobalPropertyf("a32nx/debug/FD_roll_delta", 0, false, true, false)

--mouse click
function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        --button check--
        --toggle FD--
        if x >= 3 * size[1] / 4 - 80 and x <= 3 * size[1] / 4 - 80+160 and y >= 20 and y <= 20+40 then
            set(FD_activated, 1 - get(FD_activated))
        end
    end
end

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    --scrolling target hdg
    if x >= 5 * size[1]/8 - 70 and x <= 5 * size[1]/8 - 70+140 and y >= size[2]/2 - 5 and y <= size[2]/2 - 5+40 then
        set(target_hdg, get(target_hdg) + value)
    end

    --scrolling target v/s
    if x >= 7 * size[1]/8 - 70 and x <= 7 * size[1]/8 - 70+140 and y >= size[2]/2 - 5 and y <= size[2]/2 - 5+40 then
        set(target_vs, get(target_vs) + 100 * value)
    end
end

--reset overrides
function onModuleShutdown()
    set(SimDR_override_artstab, 1)
end

function update()
    --calculate V/S
    --print(get(Capt_TAT) * math.tan(get(Vpath)) * 101.269)

    if get(DELTA_TIME) ~= 0 then
        FD_roll = Set_linear_anim_value(FD_roll, A32nx_PID_new_neg_avail(A32nx_FD_roll, get(target_hdg) - get(aircraft_heading)) * 30, -30, 30, 10)
        FD_pitch = Set_linear_anim_value(FD_pitch, A32nx_PID_new_neg_avail(A32nx_FD_pitch, get(target_vs) - get(vvi)) * 30, -30, 30, 10)

        if get(FD_activated) == 1 then
            set(SimDR_override_artstab, 1)
            set(roll_artstab, Set_anim_value(get(roll_artstab), A32nx_PID_new_neg_avail(A32nx_stick_roll, FD_roll - get(aircraft_roll)), -1, 1, 0.5))

            if get(front_gear_on_ground) == 1 then
                set(yaw_artstab, Set_anim_value(get(yaw_artstab), A32nx_PID_new_neg_avail(A32nx_rwy_roll, get(target_hdg) - get(aircraft_heading)), -1, 1, 0.5))
            else
                set(yaw_artstab, 0)
            end

            set(pitch_artstab, Set_anim_value(get(pitch_artstab), A32nx_PID_new_neg_avail(A32nx_stick_pitch, FD_pitch - get(aircraft_pitch)), -1, 1, 1))
        else
            set(roll_artstab, 0)
            set(pitch_artstab, 0)
            set(yaw_artstab, 0)
        end
    end

    FD_pitch_delta = Math_clamp(FD_pitch - get(aircraft_pitch) , -30, 30)
    FD_roll_delta = Math_clamp(FD_roll - get(aircraft_roll), -30, 30)

    set(Dataref_pitch_delta, FD_pitch_delta)
    set(Dataref_roll_delta, FD_roll_delta)

    if get(FD_activated) == 1 then
        FD_button_color = RED
        FD_button_text = "DISABLE"
    else
        FD_button_color = LIGHT_GREY
        FD_button_text = "ENABLE"
    end

    --print(FD_pitch - get(aircraft_pitch))
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)
    sasl.gl.drawRectangle(5, 5, size[1] / 2 -10, size[2]-10, DARK_GREY)
    sasl.gl.drawRectangle(size[1] / 2 + 5, 5, size[1] / 2 -10, size[2]-10, DARK_GREY)

    sasl.gl.drawLine(5, size[2] / 2 + (FD_pitch_delta / 30) * 190, size[1] / 2 - 5, size[2] / 2 + (FD_pitch_delta / 30) * 190, WHITE)
    sasl.gl.drawLine(size[1] / 4 + (FD_roll_delta / 30) * 190, 5, size[1] / 4 + (FD_roll_delta / 30) * 190, size[2] - 5, WHITE)

    --wings
    sasl.gl.drawWideLine(size[1] / 4 - 40, size[2] / 2, size[1] / 4 - 120, size[2] / 2, 6, LIGHT_BLUE)
    sasl.gl.drawWideLine(size[1] / 4 + 40, size[2] / 2, size[1] / 4 + 120, size[2] / 2, 6, LIGHT_BLUE)
    sasl.gl.drawWideLine(size[1] / 4 - 40, size[2] / 2 + 3, size[1] / 4 - 40, size[2] / 2 - 20, 6, LIGHT_BLUE)
    sasl.gl.drawWideLine(size[1] / 4 + 40, size[2] / 2 + 3, size[1] / 4 + 40, size[2] / 2 - 20, 6, LIGHT_BLUE)
    sasl.gl.drawFrame(size[1] / 4 - 5, size[2] / 2 - 5, 10, 10, LIGHT_BLUE)

    --title--
    sasl.gl.drawText(B612_MONO_bold, 3 * size[1]/4, size[2] - 5 - 20, "A32NX OPEN-SOURCE ADAPTIVE FD", 15, false, false, TEXT_ALIGN_CENTER, LIGHT_BLUE)

    --targets
    sasl.gl.drawRectangle(5 * size[1]/8 - 70, size[2]/2 - 5, 140, 40, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, 5 * size[1]/8, size[2]/2 + 40, "TARGET HEADING", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold,    5 * size[1]/8, size[2]/2, get(target_hdg), 40, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawRectangle(7 * size[1]/8 - 70, size[2]/2 - 5, 140, 40, LIGHT_GREY)
    sasl.gl.drawText(B612_MONO_regular, 7 * size[1]/8, size[2]/2 + 40, "TARGET V/S", 12, false, false, TEXT_ALIGN_CENTER, WHITE)
    sasl.gl.drawText(B612_MONO_bold,    7 * size[1]/8, size[2]/2, get(target_vs), 40, false, false, TEXT_ALIGN_CENTER, WHITE)

    sasl.gl.drawRectangle(3 * size[1] / 4 - 80, 20, 160, 40, FD_button_color)
    sasl.gl.drawText(B612_MONO_bold, 3 * size[1] / 4, 30, FD_button_text, 25, false, false, TEXT_ALIGN_CENTER, WHITE)
end
