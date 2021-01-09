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
    set(Capt_PFD_brightness_act, get(Capt_PFD_brightness) * (1 - get(FAILURE_DISPLAY_CAPT_PFD)) * get(AC_ess_bus_pwrd))
    set(Capt_ND_brightness_act,  get(Capt_ND_brightness)  * (1 - get(FAILURE_DISPLAY_CAPT_ND)) * get(AC_ess_shed_pwrd))
    set(Fo_PFD_brightness_act,   get(Fo_PFD_brightness) * (1 - get(FAILURE_DISPLAY_FO_PFD)) * get(AC_bus_2_pwrd))
    set(Fo_ND_brightness_act,    get(Fo_ND_brightness)  * (1 - get(FAILURE_DISPLAY_FO_ND)) * get(AC_bus_2_pwrd))

    set(EWD_brightness_act,      get(EWD_brightness)   * (1 - get(FAILURE_DISPLAY_EWD)) * get(AC_ess_bus_pwrd))
    set(ECAM_brightness_act,     get(ECAM_brightness)  * (1 - get(FAILURE_DISPLAY_ECAM)) * get(AC_bus_2_pwrd))


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
    draw_lut_and_brightness()
end

