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

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")

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
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Capt_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_PFD_brightness, Math_clamp(get(Capt_PFD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--capt nd
sasl.registerCommandHandler ( Capt_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Capt_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Capt_ND_brightness, Math_clamp(get(Capt_ND_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--fo pfd
sasl.registerCommandHandler ( Fo_PFD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Fo_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_PFD_brightness, Math_clamp(get(Fo_PFD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--fo nd
sasl.registerCommandHandler ( Fo_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( Fo_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Fo_ND_brightness, Math_clamp(get(Fo_ND_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--ewd
sasl.registerCommandHandler ( EWD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( EWD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(EWD_brightness, Math_clamp(get(EWD_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--ecam
sasl.registerCommandHandler ( ECAM_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( ECAM_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ECAM_brightness, Math_clamp(get(ECAM_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--dcdu 1
sasl.registerCommandHandler ( DCDU_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DCDU_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_1_brightness, Math_clamp(get(DCDU_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--dcdu 2
sasl.registerCommandHandler ( DCDU_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DCDU_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DCDU_2_brightness, Math_clamp(get(DCDU_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--mcdu 1
sasl.registerCommandHandler ( MCDU_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( MCDU_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_1_brightness, Math_clamp(get(MCDU_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--mcdu 2
sasl.registerCommandHandler ( MCDU_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( MCDU_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(MCDU_2_brightness, Math_clamp(get(MCDU_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--draims 1
sasl.registerCommandHandler ( DRAIMS_1_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DRAIMS_1_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_1_brightness, Math_clamp(get(DRAIMS_1_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--draims 2
sasl.registerCommandHandler ( DRAIMS_2_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( DRAIMS_2_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(DRAIMS_2_brightness, Math_clamp(get(DRAIMS_2_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

--isis
sasl.registerCommandHandler ( ISIS_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) + 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) + 0.5 * get(DELTA_TIME), 0, 1))
    end
end)
sasl.registerCommandHandler ( ISIS_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) - 0.05, 0, 1))
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(ISIS_brightness, Math_clamp(get(ISIS_brightness) - 0.5 * get(DELTA_TIME), 0, 1))
    end
end)

function update()
    set(Total_element_brightness, 1)

    --calculate brightness lut
    Capt_PFD_lut_alpha[4] = Math_clamp(get(Capt_PFD_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    Capt_ND_lut_alpha[4] = Math_clamp(get(Capt_ND_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    EWD_lut_alpha[4] =  Math_clamp(get(EWD_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    FO_ND_lut_alpha[4] = Math_clamp(get(Fo_ND_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    FO_PFD_lut_alpha[4] = Math_clamp(get(Fo_PFD_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    ECAM_lut_alpha[4] = Math_clamp(get(ECAM_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DCDU_1_lut_alpha[4] = Math_clamp(get(DCDU_1_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DCDU_2_lut_alpha[4] = Math_clamp(get(DCDU_2_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    MCDU_1_lut_alpha[4] = Math_clamp(get(MCDU_1_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    MCDU_2_lut_alpha[4] = Math_clamp(get(MCDU_2_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DRAIMS_1_lut_alpha[4] = Math_clamp(get(DRAIMS_1_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    DRAIMS_2_lut_alpha[4] = Math_clamp(get(DRAIMS_2_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)
    ISIS_lut_alpha[4] = Math_clamp(get(ISIS_brightness) / 0.4, 0, 1) * Math_clamp((1 - get(Sun_pitch) / 1.5), 0, 1)

    --calculate brightness darkness
    Capt_PFD_brightness_alpha[4] = 1 - get(Capt_PFD_brightness)
    Capt_ND_brightness_alpha[4] = 1 - get(Capt_ND_brightness)
    EWD_brightness_alpha[4] = 1 - get(EWD_brightness)
    FO_ND_brightness_alpha[4] = 1 - get(Fo_ND_brightness)
    FO_PFD_brightness_alpha[4] = 1 - get(Fo_PFD_brightness)
    ECAM_brightness_alpha[4] = 1 - get(ECAM_brightness)
    DCDU_1_brightness_alpha[4] = 1 - get(DCDU_1_brightness)
    DCDU_2_brightness_alpha[4] = 1 - get(DCDU_2_brightness)
    MCDU_1_brightness_alpha[4] = 1 - get(MCDU_1_brightness)
    MCDU_2_brightness_alpha[4] = 1 - get(MCDU_2_brightness)
    DRAIMS_1_brightness_alpha[4] = 1 - get(DRAIMS_1_brightness)
    DRAIMS_2_brightness_alpha[4] = 1 - get(DRAIMS_2_brightness)
    ISIS_brightness_alpha[4] = 1 - get(ISIS_brightness)
end

function draw()
    sasl.gl.setBlendEquation ( BLEND_EQUATION_ADD )
    sasl.gl.setBlendFunction ( BLEND_SOURCE_ALPHA, BLEND_ONE_MINUS_SOURCE_ALPHA)
    sasl.gl.drawTexture(screen_lut_img, 0, 0, 40, 40, Capt_PFD_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 45, 0, 40, 40, Capt_ND_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 90, 0, 40, 40, EWD_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 135, 0, 40, 40, FO_ND_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 180, 0, 40, 40, FO_PFD_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 225, 0, 40, 40, ECAM_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 270, 0, 40, 40, DCDU_1_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 315, 0, 40, 40, DCDU_2_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 360, 0, 40, 40, MCDU_1_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 405, 0, 40, 40, MCDU_2_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 450, 0, 40, 40, DRAIMS_1_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 495, 0, 40, 40, DRAIMS_2_lut_alpha)
    sasl.gl.drawTexture(screen_lut_img, 540, 0, 40, 40, ISIS_lut_alpha)

    --draw the brightness lut
    sasl.gl.drawRectangle(0, 0, 40, 40, Capt_PFD_brightness_alpha)
    sasl.gl.drawRectangle(45, 0, 40, 40, Capt_ND_brightness_alpha)
    sasl.gl.drawRectangle(90, 0, 40, 40, EWD_brightness_alpha)
    sasl.gl.drawRectangle(135, 0, 40, 40, FO_ND_brightness_alpha)
    sasl.gl.drawRectangle(180, 0, 40, 40, FO_PFD_brightness_alpha)
    sasl.gl.drawRectangle(225, 0, 40, 40, ECAM_brightness_alpha)
    sasl.gl.drawRectangle(270, 0, 40, 40, DCDU_1_brightness_alpha)
    sasl.gl.drawRectangle(315, 0, 40, 40, DCDU_2_brightness_alpha)
    sasl.gl.drawRectangle(360, 0, 40, 40, MCDU_1_brightness_alpha)
    sasl.gl.drawRectangle(405, 0, 40, 40, MCDU_2_brightness_alpha)
    sasl.gl.drawRectangle(450, 0, 40, 40, DRAIMS_1_brightness_alpha)
    sasl.gl.drawRectangle(495, 0, 40, 40, DRAIMS_2_brightness_alpha)
    sasl.gl.drawRectangle(540, 0, 40, 40, ISIS_brightness_alpha)
    sasl.gl.resetBlending ()
end
