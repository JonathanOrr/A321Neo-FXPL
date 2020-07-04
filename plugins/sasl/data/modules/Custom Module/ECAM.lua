position= {3187,499,900,900}
size = {900, 900}

--sim datarefs

--a32NX datarefs
local a321DR_ecam_page_num = createGlobalPropertyi("a321neo/cockpit/ecam/page_num", 8, false, true, false) --1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local mcdu_white = {1.0, 1.0, 1.0}
local mcdu_blue = {0.004, 1.0, 1.0}
local mcdu_green = {0.004, 1, 0.004}
local mcdu_orange = {0.843, 0.49, 0}

--custom fucntions
local function draw_ecam_lower_section()
    --left section
    sasl.gl.drawText(B612MONO_regular, size[1]/2-215, size[2]/2-373, math.floor(get(TAT)), 30, false, false, TEXT_ALIGN_RIGHT, mcdu_blue)
    sasl.gl.drawText(B612MONO_regular, size[1]/2-215, size[2]/2-409, math.floor(get(OTA)), 30, false, false, TEXT_ALIGN_RIGHT, mcdu_blue)

    --center section
    --adding a 0 to the front of the time when single digit
    if get(ZULU_hours) < 10 then
        sasl.gl.drawText(B612MONO_regular, size[1]/2-25, size[2]/2-408, "0" .. get(ZULU_hours), 30, false, false, TEXT_ALIGN_RIGHT, mcdu_blue)
    else
        sasl.gl.drawText(B612MONO_regular, size[1]/2-25, size[2]/2-408, get(ZULU_hours), 30, false, false, TEXT_ALIGN_RIGHT, mcdu_blue)
    end

    if get(ZULU_mins) < 10 then
        sasl.gl.drawText(B612MONO_regular, size[1]/2+25, size[2]/2-408, "0" .. get(ZULU_mins), 30, false, false, TEXT_ALIGN_LEFT, mcdu_blue)
    else
        sasl.gl.drawText(B612MONO_regular, size[1]/2+25, size[2]/2-408, get(ZULU_mins), 30, false, false, TEXT_ALIGN_LEFT, mcdu_blue)
    end

    --right section
    sasl.gl.drawText(B612MONO_regular, size[1]/2+375, size[2]/2-374, math.floor(get(Gross_weight)), 30, false, false, TEXT_ALIGN_RIGHT, mcdu_blue)
end

--drawing the ECAM
function draw()
    if get(a321DR_ecam_page_num) == 1 then --eng

    elseif get(a321DR_ecam_page_num) == 2 then --bleed

    elseif get(a321DR_ecam_page_num) == 3 then --press

    elseif get(a321DR_ecam_page_num) == 4 then --elec

    elseif get(a321DR_ecam_page_num) == 5 then --hyd

    elseif get(a321DR_ecam_page_num) == 6 then --fuel

    elseif get(a321DR_ecam_page_num) == 7 then --apu

    elseif get(a321DR_ecam_page_num) == 8 then --cond
        --cabin--
        --actual temperature
        sasl.gl.drawText(B612MONO_regular, size[1]/2-212, size[2]/2+210, math.floor(get(Cockpit_temp)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-13, size[2]/2+210, math.floor(get(Front_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+172, size[2]/2+210, math.floor(get(Aft_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)
        --requested temperatures
        sasl.gl.drawText(B612MONO_regular, size[1]/2-212, size[2]/2+170, math.floor(get(Cockpit_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)
        sasl.gl.drawText(B612MONO_regular, size[1]/2-13, size[2]/2+170, math.floor(get(Front_cab_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+172, size[2]/2+170, math.floor(get(Aft_cab_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)

        --cargo--
        --actual temperature
        sasl.gl.drawText(B612MONO_regular, size[1]/2+168, size[2]/2-59, math.floor(get(Aft_cargo_temp)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)
        --requested temperatures
        sasl.gl.drawText(B612MONO_regular, size[1]/2+168, size[2]/2-92, math.floor(get(Aft_cargo_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, mcdu_green)
    elseif get(a321DR_ecam_page_num) == 9 then --door

    elseif get(a321DR_ecam_page_num) == 10 then --wheel

    elseif get(a321DR_ecam_page_num) == 11 then --f/ctl

    elseif get(a321DR_ecam_page_num) == 12 then --STS

    end

    draw_ecam_lower_section()
end