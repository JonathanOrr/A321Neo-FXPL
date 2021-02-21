-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: display_brightness.lua
-- Short description: Code to manage brightness of displays
-------------------------------------------------------------------------------

position= {0,0,4096,4096}
size = {4096, 4096}


--image textures
local screen_lut_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/LUT.png")

--register commands
--capt pfd
sasl.registerCommandHandler ( Capt_PFD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Capt_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--capt nd
sasl.registerCommandHandler ( Capt_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Capt_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--fo pfd
sasl.registerCommandHandler ( Fo_PFD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Fo_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--fo nd
sasl.registerCommandHandler ( Fo_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Fo_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--ewd
sasl.registerCommandHandler ( EWD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( EWD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--ecam
sasl.registerCommandHandler ( ECAM_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( ECAM_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--dcdu 1
sasl.registerCommandHandler ( DCDU_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DCDU_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--dcdu 2
sasl.registerCommandHandler ( DCDU_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DCDU_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--mcdu 1
sasl.registerCommandHandler ( MCDU_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( MCDU_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--mcdu 2
sasl.registerCommandHandler ( MCDU_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( MCDU_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--draims 1
sasl.registerCommandHandler ( DRAIMS_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DRAIMS_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--draims 2
sasl.registerCommandHandler ( DRAIMS_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DRAIMS_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

--isis
sasl.registerCommandHandler ( ISIS_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) + 1 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( ISIS_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) - 1 * get(DELTA_TIME), 0, 1))
    end
end)

function update_actual_values()
    set(Capt_PFD_brightness_act, get(Capt_PFD_brightness) * get(AC_ess_bus_pwrd))
    set(Capt_ND_brightness_act,  get(Capt_ND_brightness)  *  get(AC_ess_shed_pwrd))
    set(Fo_PFD_brightness_act,   get(Fo_PFD_brightness) * get(AC_bus_2_pwrd))
    set(Fo_ND_brightness_act,    get(Fo_ND_brightness)  *  get(AC_bus_2_pwrd))

    set(EWD_brightness_act,      get(EWD_brightness)   *  get(AC_ess_bus_pwrd))
    set(ECAM_brightness_act,     get(ECAM_brightness)  *  get(AC_bus_2_pwrd))


    set(MCDU_1_brightness_act,   get(MCDU_1_brightness) * (1 - get(FAILURE_DISPLAY_MCDU_1)) * get(AC_ess_shed_pwrd))
    set(MCDU_2_brightness_act,   get(MCDU_2_brightness) * (1 - get(FAILURE_DISPLAY_MCDU_2)) * get(AC_bus_2_pwrd))

    set(DRAIMS_1_brightness_act,   get(DRAIMS_1_brightness) * (1 - get(FAILURE_DISPLAY_DRAIMS_1)) * get(DC_ess_bus_pwrd))
    set(DRAIMS_2_brightness_act,   get(DRAIMS_2_brightness) * (1 - get(FAILURE_DISPLAY_DRAIMS_2)) * get(DC_bus_2_pwrd))

    set(DCDU_1_brightness_act,   get(DCDU_1_brightness) * (1 - get(FAILURE_DISPLAY_DCDU_1)) * get(AC_bus_1_pwrd))
    set(DCDU_2_brightness_act,   get(DCDU_2_brightness) * (1 - get(FAILURE_DISPLAY_DCDU_2)) * get(AC_bus_1_pwrd))

    set(ISIS_brightness_act,   get(ISIS_brightness) * (1 - get(FAILURE_DISPLAY_ISIS)) * get(DC_ess_bus_pwrd))

end

function update()
    set(Total_element_brightness, 1)

    update_actual_values()
end

function DMC_draw_invalid(pos, brightness)
    Draw_LCD_backlight(pos[1], pos[2], pos[3], pos[4], 0.5, 1, brightness)
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]/2, pos[2]+pos[4]/2, "INVALID DATA", 40, false, false, TEXT_ALIGN_CENTER, {1, 0.66, 0.16})
end

function DMC_draw_test(pos, brightness)
    Draw_LCD_backlight(pos[1], pos[2], pos[3], pos[4], 0.5, 1, brightness)

    sasl.gl.drawRectangle(pos[1],            pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {1.0, 0.0, 0.0})
    sasl.gl.drawRectangle(pos[1]+pos[3]/8,   pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {1, 0.33, 0})
    sasl.gl.drawRectangle(pos[1]+2*pos[3]/8, pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {1, 0.66, 0.16})
    sasl.gl.drawRectangle(pos[1]+3*pos[3]/8, pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {0.20, 0.98, 0.20})
    sasl.gl.drawRectangle(pos[1]+4*pos[3]/8, pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {0.004, 1.0, 1.0})
    sasl.gl.drawRectangle(pos[1]+5*pos[3]/8, pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {0, 0.4, 1.0})
    sasl.gl.drawRectangle(pos[1]+6*pos[3]/8, pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {0.1, 0.6, 1.0})
    sasl.gl.drawRectangle(pos[1]+7*pos[3]/8, pos[2]+2*pos[4]/3, pos[3]/8, pos[4]/3, {1.0, 0.0, 1.0})

    sasl.gl.drawRectangle(pos[1]+0, pos[2]+pos[4]/3, pos[3], pos[4]/3, {1,1,1})

    sasl.gl.drawRectangle(pos[1]+0, pos[2]+0, pos[3]/8, pos[4]/3, {0.1, 0.1, 0.1})
    sasl.gl.drawRectangle(pos[1]+1*pos[3]/8, pos[2]+0, pos[3]/8, pos[4]/3, {0.2, 0.2, 0.2})
    sasl.gl.drawRectangle(pos[1]+2*pos[3]/8, pos[2]+0, pos[3]/8, pos[4]/3, {0.3, 0.3, 0.3})
    sasl.gl.drawRectangle(pos[1]+3*pos[3]/8, pos[2]+0, pos[3]/8, pos[4]/3, {0.4, 0.4, 0.4})
    sasl.gl.drawRectangle(pos[1]+4*pos[3]/8, pos[2]+0, pos[3]/8, pos[4]/3, {0.5, 0.5, 0.5})
    sasl.gl.drawRectangle(pos[1]+5*pos[3]/8, pos[2]+0, pos[3]/8, pos[4]/3, {0.6, 0.6, 0.6})
    sasl.gl.drawRectangle(pos[1]+6*pos[3]/8, pos[2]+0, pos[3]/8, pos[4]/3, {0.8, 0.8, 0.8})
    sasl.gl.drawRectangle(pos[1]+7*pos[3]/8, pos[2]+0, pos[3]/8, pos[4]/3, {1, 1, 1})

    sasl.gl.drawText(Font_AirbusDUL, pos[1]+20, pos[2]+pos[4]/2+100, "P/N : C483719090304", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+20, pos[2]+pos[4]/2+70, "S/N : C483719090304-2323", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+20, pos[2]+pos[4]/2-80, "EIS SW", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+20, pos[2]+pos[4]/2-110, "P/N : SXT40DXE254628440023400", 25, false, false, TEXT_ALIGN_LEFT,  {0,0,0})


    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]-20, pos[2]+pos[4]/2+100, "SIDESTICKSIM AVIONICS", 25, false, false, TEXT_ALIGN_RIGHT,  {0,0,0})
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]-20, pos[2]+pos[4]/2-110, "LCDU 725", 25, false, false, TEXT_ALIGN_RIGHT,  {0,0,0})
end

function DMC_draw_maintain(pos, brightness)
    Draw_LCD_backlight(pos[1], pos[2], pos[3], pos[4], 0.5, 1, brightness)
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]/2, pos[2]+pos[4]/2, "MAINTENANCE MODE", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
end

function DMC_draw_wait_for_data(pos, brightness)
    Draw_LCD_backlight(pos[1], pos[2], pos[3], pos[4], 0.5, 1, brightness)
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]/2, pos[2]+pos[4]/2, "WAITING FOR DATA", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
end

function DMC_draw_self_test(pos, brightness)
    Draw_LCD_backlight(pos[1], pos[2], pos[3], pos[4], 0.5, 1, brightness)
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]/2, pos[2]+pos[4]/2+20, "SELF-TEST IN PROGRESS", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]/2, pos[2]+pos[4]/2-20, "(MAX 30 SECONDS)", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
end

function DMC_draw_ecam_on_nd(pos, brightness)
    Draw_LCD_backlight(pos[1], pos[2], pos[3], pos[4], 0.5, 1, brightness)
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]/2, pos[2]+pos[4]/2, "ECAM ON ND", 40, false, false, TEXT_ALIGN_CENTER, {0.20, 0.98, 0.20})
end

function DMC_draw_big_f(pos, brightness)
    Draw_LCD_backlight(pos[1], pos[2], pos[3], pos[4], 0.5, 1, brightness)
    sasl.gl.drawText(Font_AirbusDUL, pos[1]+pos[3]/2, pos[2]+200, "F", 700, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
end

function DMC_display_special_mode(mode, pos, brightness)
    if mode == 1 then
        return
    elseif mode == 0 then
        DMC_draw_invalid(pos, brightness)
    elseif mode == 2 then
        DMC_draw_test(pos, brightness)
    elseif mode == 3 then
        DMC_draw_maintain(pos, brightness)
    elseif mode == 4 then
        DMC_draw_wait_for_data(pos, brightness)
    elseif mode == 5 then
        DMC_draw_self_test(pos, brightness)
    elseif mode == 6 then
        DMC_draw_ecam_on_nd(pos, brightness)
    elseif mode == 7 then
        DMC_draw_big_f(pos, brightness)
    end
end


local function draw_special_modes()
    DMC_display_special_mode(get(Capt_pfd_valid), {30,   3166, 900, 900}, get(Capt_PFD_brightness_act))
    DMC_display_special_mode(get(Capt_nd_valid),  {1030, 3166, 900, 900}, get(Capt_ND_brightness_act))
    DMC_display_special_mode(get(Fo_pfd_valid),   {3030, 3166, 900, 900}, get(Fo_PFD_brightness_act))
    DMC_display_special_mode(get(Fo_nd_valid),    {2030, 3166, 900, 900}, get(Fo_ND_brightness_act))
    DMC_display_special_mode(get(EWD_valid),      {30,   2226, 900, 900}, get(EWD_brightness_act))
    DMC_display_special_mode(get(ECAM_valid),     {1030, 2226, 900, 900}, get(ECAM_brightness_act))
end

local function draw_lut_and_brightness()

    sasl.gl.drawRectangle(30,   3166, 900, 900, {0,0,0, 1 - get(Capt_PFD_brightness_act)})
    sasl.gl.drawRectangle(1030, 3166, 900, 900, {0,0,0, 1 - get(Capt_ND_brightness_act)})
    sasl.gl.drawRectangle(2030, 3166, 900, 900, {0,0,0, 1 - get(Fo_ND_brightness_act)})
    sasl.gl.drawRectangle(3030, 3166, 900, 900, {0,0,0, 1 - get(Fo_PFD_brightness_act)})
    sasl.gl.drawRectangle(30,   2226, 900, 900, {0,0,0, 1 - get(EWD_brightness_act)})
    sasl.gl.drawRectangle(1030, 2226, 900, 900, {0,0,0, 1 - get(ECAM_brightness_act)})

    sasl.gl.drawRectangle(30,   1311, 500, 500, {0,0,0, 1 - get(ISIS_brightness_act)})

    sasl.gl.drawRectangle(1020, 1666, 560, 530, {0,0,0, 1 - get(MCDU_1_brightness_act)})

    sasl.gl.drawRectangle(2030, 2726, 600, 400, {0,0,0, 1 - get(DRAIMS_1_brightness_act)})
end

function draw()
    draw_special_modes()
    draw_lut_and_brightness()
end

