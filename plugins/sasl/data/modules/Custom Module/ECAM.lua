position= {3187,499,900,900}
size = {900, 900}

--local variables
local apu_avail_timer = -1

--sim datarefs

--a32NX datarefs
local apu_needle_state = createGlobalPropertyi("a321neo/cockpit/apu/apu_needle_state", 0, false, true, false) --0xx, 1operational

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local left_brake_temp_color = {1.0, 1.0, 1.0}
local right_brake_temp_color = {1.0, 1.0, 1.0}
local left_tire_psi_color = {1.0, 1.0, 1.0}
local right_tire_psi_color = {1.0, 1.0, 1.0}
local ECAM_WHITE = {1.0, 1.0, 1.0}
local ECAM_BLUE = {0.004, 1.0, 1.0}
local ECAM_GREEN = {0.004, 1, 0.004}
local ECAM_ORANGE = {0.843, 0.49, 0.0}

--custom fucntions
local function draw_ecam_lower_section()
    --left section
    sasl.gl.drawText(B612MONO_regular, size[1]/2-215, size[2]/2-373, math.floor(get(TAT)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(B612MONO_regular, size[1]/2-215, size[2]/2-409, math.floor(get(OTA)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    --center section
    --adding a 0 to the front of the time when single digit
    if get(ZULU_hours) < 10 then
        sasl.gl.drawText(B612MONO_regular, size[1]/2-25, size[2]/2-408, "0" .. get(ZULU_hours), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, size[1]/2-25, size[2]/2-408, get(ZULU_hours), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end

    if get(ZULU_mins) < 10 then
        sasl.gl.drawText(B612MONO_regular, size[1]/2+25, size[2]/2-408, "0" .. get(ZULU_mins), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, size[1]/2+25, size[2]/2-408, get(ZULU_mins), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end

    --right section
    sasl.gl.drawText(B612MONO_regular, size[1]/2+375, size[2]/2-374, math.floor(get(Gross_weight)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
end

function update()
    if get(Apu_N1) == 0 then
        set(apu_needle_state, 0)
    elseif get(Apu_N1) > 1 then
        set(apu_needle_state, 1)
    end

    --wheels indications--
    if get(Left_brakes_temp) > 400 then
		left_brake_temp_color = ECAM_ORANGE
	else
		left_brake_temp_color = ECAM_WHITE
	end

	if get(Right_brakes_temp) > 400 then
		right_brake_temp_color = ECAM_ORANGE
	else
		right_brake_temp_color = ECAM_WHITE
	end

	if get(Left_tire_psi) > 280 then
		left_tire_psi_color = ECAM_ORANGE
	else
		left_tire_psi_color = ECAM_WHITE
	end

	if get(Right_tire_psi) > 280 then
		right_tire_psi_color = ECAM_ORANGE
	else
		right_tire_psi_color = ECAM_WHITE
	end
end

--drawing the ECAM
function draw()
    if get(Ecam_current_page) == 1 then --eng

    elseif get(Ecam_current_page) == 2 then --bleed

    elseif get(Ecam_current_page) == 3 then --press

    elseif get(Ecam_current_page) == 4 then --elec

    elseif get(Ecam_current_page) == 5 then --hyd

    elseif get(Ecam_current_page) == 6 then --fuel

    elseif get(Ecam_current_page) == 7 then --apu
        --apu gen section--
        if get(Apu_gen_state) == 2 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2-235, size[2]/2+257, math.floor(get(Apu_gen_load)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
            sasl.gl.drawText(B612MONO_regular, size[1]/2-235, size[2]/2+224, math.floor(get(Apu_gen_volts)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
            sasl.gl.drawText(B612MONO_regular, size[1]/2-235, size[2]/2+192, math.floor(get(Apu_gen_hz)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        end
        --apu bleed--
        if get(Apu_bleed_state) > 0 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2+270, size[2]/2+186, math.floor(get(Apu_bleed_psi)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        end
        --needles--
        if get(apu_needle_state) == 1 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2-180, size[2]/2-60, math.floor(get(Apu_N1)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            sasl.gl.drawText(B612MONO_regular, size[1]/2-180, size[2]/2-260, math.floor(get(APU_EGT)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
    elseif get(Ecam_current_page) == 8 then --cond
        --cabin--
        --actual temperature
        sasl.gl.drawText(B612MONO_regular, size[1]/2-212, size[2]/2+210, math.floor(get(Cockpit_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-13, size[2]/2+210, math.floor(get(Front_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+172, size[2]/2+210, math.floor(get(Aft_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --requested temperatures
        sasl.gl.drawText(B612MONO_regular, size[1]/2-212, size[2]/2+170, math.floor(get(Cockpit_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-13, size[2]/2+170, math.floor(get(Front_cab_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+172, size[2]/2+170, math.floor(get(Aft_cab_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

        --cargo--
        --actual temperature
        sasl.gl.drawText(B612MONO_regular, size[1]/2+168, size[2]/2-59, math.floor(get(Aft_cargo_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --requested temperatures
        sasl.gl.drawText(B612MONO_regular, size[1]/2+168, size[2]/2-92, math.floor(get(Aft_cargo_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif get(Ecam_current_page) == 9 then --door

    elseif get(Ecam_current_page) == 10 then --wheel
        --brakes temps--
        sasl.gl.drawText(B612MONO_regular, size[1]/2-360, size[2]/2-75, math.floor(get(Left_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-200, size[2]/2-75, math.floor(get(Left_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+200, size[2]/2-75, math.floor(get(Right_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+360, size[2]/2-75, math.floor(get(Right_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --tire press
        sasl.gl.drawText(B612MONO_regular, size[1]/2-360, size[2]/2-165, math.floor(get(Left_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-200, size[2]/2-165, math.floor(get(Left_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+200, size[2]/2-165, math.floor(get(Right_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+360, size[2]/2-165, math.floor(get(Right_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --brakes indications
        sasl.gl.drawText(B612MONO_regular, size[1]/2-280, size[2]/2-75, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-280, size[2]/2-120, "REL", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-280, size[2]/2-165, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+280, size[2]/2-75, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+280, size[2]/2-120, "REL", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+280, size[2]/2-165, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-360, size[2]/2-120, "1", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-200, size[2]/2-120, "2", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+200, size[2]/2-120, "3", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+360, size[2]/2-120, "4", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

        --upper arcs
        sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 60, 60, left_brake_temp_color)
        sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 60, 60, left_brake_temp_color)
        sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 60, 60, right_brake_temp_color)
        sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 60, 60, right_brake_temp_color)
        --lower arcs
        sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 240, 60, left_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 240, 60, left_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 240, 60, right_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 240, 60, right_tire_psi_color)

    elseif get(Ecam_current_page) == 11 then --f/ctl

    elseif get(Ecam_current_page) == 12 then --STS

    end

    draw_ecam_lower_section()
end