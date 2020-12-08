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

include('constants.lua')


--colors
local Capt_PFD_brightness_alpha = {0.0, 0.0, 0.0, 1}
local Capt_ND_brightness_alpha = {0.0, 0.0, 0.0, 1}
local EWD_brightness_alpha = {0.0, 0.0, 0.0, 1}
local FO_ND_brightness_alpha = {0.0, 0.0, 0.0, 1}
local FO_PFD_brightness_alpha = {0.0, 0.0, 0.0, 1}
local ECAM_brightness_alpha = {0.0, 0.0, 0.0, 1}
local DCDU_1_brightness_alpha = {0.0, 0.0, 0.0, 1}
local DCDU_2_brightness_alpha = {0.0, 0.0, 0.0, 1}
local MCDU_1_brightness_alpha = {0.0, 0.0, 0.0, 1}
local MCDU_2_brightness_alpha = {0.0, 0.0, 0.0, 1}
local DRAIMS_1_brightness_alpha = {0.0, 0.0, 0.0, 1}
local DRAIMS_2_brightness_alpha = {0.0, 0.0, 0.0, 1}
local ISIS_brightness_alpha = {0.0, 0.0, 0.0, 1}

local Capt_PFD_lut_alpha = {1, 1, 1, 1}
local Capt_ND_lut_alpha = {1, 1, 1, 1}
local EWD_lut_alpha = {1, 1, 1, 1}
local FO_ND_lut_alpha = {1, 1, 1, 1}
local FO_PFD_lut_alpha = {1, 1, 1, 1}
local ECAM_lut_alpha = {1, 1, 1, 1}
local DCDU_1_lut_alpha = {1, 1, 1, 1}
local DCDU_2_lut_alpha = {1, 1, 1, 1}
local MCDU_1_lut_alpha = {1, 1, 1, 1}
local MCDU_2_lut_alpha = {1, 1, 1, 1}
local DRAIMS_1_lut_alpha = {1, 1, 1, 1}
local DRAIMS_2_lut_alpha = {1, 1, 1, 1}
local ISIS_lut_alpha = {1, 1, 1, 1}

--image textures
local screen_lut_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/LUT.png")

--register commands
--capt pfd
sasl.registerCommandHandler ( Capt_PFD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Capt_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--capt nd
sasl.registerCommandHandler ( Capt_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Capt_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--fo pfd
sasl.registerCommandHandler ( Fo_PFD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Fo_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--fo nd
sasl.registerCommandHandler ( Fo_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Fo_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--ewd
sasl.registerCommandHandler ( EWD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( EWD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--ecam
sasl.registerCommandHandler ( ECAM_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( ECAM_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--dcdu 1
sasl.registerCommandHandler ( DCDU_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DCDU_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--dcdu 2
sasl.registerCommandHandler ( DCDU_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DCDU_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--mcdu 1
sasl.registerCommandHandler ( MCDU_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( MCDU_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--mcdu 2
sasl.registerCommandHandler ( MCDU_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( MCDU_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--draims 1
sasl.registerCommandHandler ( DRAIMS_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DRAIMS_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--draims 2
sasl.registerCommandHandler ( DRAIMS_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DRAIMS_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--isis
sasl.registerCommandHandler ( ISIS_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( ISIS_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

function change_brightness()

    --calculate brightness lut
    Capt_PFD_lut_alpha[4] = Math_clamp(get(Capt_PFD_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    Capt_ND_lut_alpha[4] = Math_clamp(get(Capt_ND_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    EWD_lut_alpha[4] =  Math_clamp(get(EWD_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    FO_ND_lut_alpha[4] = Math_clamp(get(Fo_ND_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    FO_PFD_lut_alpha[4] = Math_clamp(get(Fo_PFD_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    ECAM_lut_alpha[4] = Math_clamp(get(ECAM_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DCDU_1_lut_alpha[4] = Math_clamp(get(DCDU_1_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DCDU_2_lut_alpha[4] = Math_clamp(get(DCDU_2_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    MCDU_1_lut_alpha[4] = Math_clamp(get(MCDU_1_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    MCDU_2_lut_alpha[4] = Math_clamp(get(MCDU_2_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DRAIMS_1_lut_alpha[4] = Math_clamp(get(DRAIMS_1_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DRAIMS_2_lut_alpha[4] = Math_clamp(get(DRAIMS_2_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    ISIS_lut_alpha[4] = Math_clamp(get(ISIS_brightness_act) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)

    --calculate brightness darkness
    Capt_PFD_brightness_alpha[4] = 1 - get(Capt_PFD_brightness_act)
    Capt_ND_brightness_alpha[4] = 1 - get(Capt_ND_brightness_act)
    EWD_brightness_alpha[4] = 1 - get(EWD_brightness_act)
    FO_ND_brightness_alpha[4] = 1 - get(Fo_ND_brightness_act)
    FO_PFD_brightness_alpha[4] = 1 - get(Fo_PFD_brightness_act)
    ECAM_brightness_alpha[4] = 1 - get(ECAM_brightness_act)
    DCDU_1_brightness_alpha[4] = 1 - get(DCDU_1_brightness_act)
    DCDU_2_brightness_alpha[4] = 1 - get(DCDU_2_brightness_act)
    MCDU_1_brightness_alpha[4] = 1 - get(MCDU_1_brightness_act)
    MCDU_2_brightness_alpha[4] = 1 - get(MCDU_2_brightness_act)
    DRAIMS_1_brightness_alpha[4] = 1 - get(DRAIMS_1_brightness_act)
    DRAIMS_2_brightness_alpha[4] = 1 - get(DRAIMS_2_brightness_act)
    ISIS_brightness_alpha[4] = 1 - get(ISIS_brightness_act)
end

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

    change_brightness()

end

local function draw_lut_and_brightness()
    sasl.gl.setBlendEquation ( BLEND_EQUATION_ADD )
    sasl.gl.setBlendFunction ( BLEND_SOURCE_ALPHA, BLEND_ONE_MINUS_SOURCE_ALPHA)
    sasl.gl.drawTexture(screen_lut_img, 0, 0, 40, 40, Capt_PFD_lut_alpha)
    --sasl.gl.drawTexture(screen_lut_img, 45, 0, 40, 40, Capt_ND_lut_alpha)
    --sasl.gl.drawTexture(screen_lut_img, 90, 0, 40, 40, EWD_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 135, 0, 40, 40, FO_ND_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 180, 0, 40, 40, FO_PFD_lut_alpha)
    --sasl.gl.drawTexture(screen_lut_img, 225, 0, 40, 40, ECAM_lut_alpha)
    --sasl.gl.drawTexture(screen_lut_img, 270, 0, 40, 40, DCDU_1_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 315, 0, 40, 40, DCDU_2_lut_alpha)
    --sasl.gl.drawTexture(screen_lut_img, 360, 0, 40, 40, MCDU_1_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 405, 0, 40, 40, MCDU_2_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 450, 0, 40, 40, DRAIMS_1_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 495, 0, 40, 40, DRAIMS_2_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 540, 0, 40, 40, ISIS_lut_alpha)

    --draw the brightness lut
    sasl.gl.drawRectangle(0, 0, 40, 40, Capt_PFD_brightness_alpha)
    sasl.gl.drawRectangle(45, 0, 40, 40, Capt_ND_brightness_alpha)
    --sasl.gl.drawRectangle(90, 0, 40, 40, EWD_brightness_alpha)
    sasl.gl.drawRectangle(135, 0, 40, 40, FO_ND_brightness_alpha)
    sasl.gl.drawRectangle(180, 0, 40, 40, FO_PFD_brightness_alpha)
    --sasl.gl.drawRectangle(225, 0, 40, 40, ECAM_brightness_alpha)
    --sasl.gl.drawRectangle(270, 0, 40, 40, DCDU_1_brightness_alpha)
    sasl.gl.drawRectangle(315, 0, 40, 40, DCDU_2_brightness_alpha)
    --sasl.gl.drawRectangle(360, 0, 40, 40, MCDU_1_brightness_alpha)
    sasl.gl.drawRectangle(405, 0, 40, 40, MCDU_2_brightness_alpha)
    sasl.gl.drawRectangle(450, 0, 40, 40, DRAIMS_1_brightness_alpha)
    sasl.gl.drawRectangle(495, 0, 40, 40, DRAIMS_2_brightness_alpha)
    sasl.gl.drawRectangle(540, 0, 40, 40, ISIS_brightness_alpha)
    sasl.gl.resetBlending ()

    MCDU_set_lut(MCDU_1_lut_alpha[4])
    
end

function draw()
    draw_lut_and_brightness()
end

