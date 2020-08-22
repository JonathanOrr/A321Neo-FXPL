position= {0,0,265,40}
size = {265, 40}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")

--colors
local Capt_PFD_brightness_alpha = {0.0, 0.0, 0.0, 1}
local Capt_ND_brightness_alpha = {0.0, 0.0, 0.0, 1}
local EWD_brightness_alpha = {0.0, 0.0, 0.0, 1}
local FO_ND_brightness_alpha = {0.0, 0.0, 0.0, 1}
local FO_PFD_brightness_alpha = {0.0, 0.0, 0.0, 1}
local ECAM_brightness_alpha = {0.0, 0.0, 0.0, 1}

--register commands
--capt pfd
sasl.registerCommandHandler ( Capt_PFD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)
sasl.registerCommandHandler ( Capt_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)

--capt nd
sasl.registerCommandHandler ( Capt_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)
sasl.registerCommandHandler ( Capt_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)

--fo pfd
sasl.registerCommandHandler ( Fo_PFD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)
sasl.registerCommandHandler ( Fo_PFD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)

--fo nd
sasl.registerCommandHandler ( Fo_ND_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)
sasl.registerCommandHandler ( Fo_ND_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)

--ewd
sasl.registerCommandHandler ( EWD_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)
sasl.registerCommandHandler ( EWD_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)

--ecam
sasl.registerCommandHandler ( ECAM_brightness_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)
sasl.registerCommandHandler ( ECAM_brightness_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.05)
    end
    if phase == SASL_COMMAND_CONTINUE then
        set(Cockpit_temp_dial, get(Cockpit_temp_dial) + 0.5 * get(DELTA_TIME))
    end
end)

function update()
    set(Total_element_brightness, 1)

    Capt_PFD_brightness_alpha[4] = 1 - get(Capt_PFD_brightness)
    Capt_ND_brightness_alpha[4] = 1 - get(Capt_ND_brightness)
    EWD_brightness_alpha[4] = 1 - get(EWD_brightness)
    FO_ND_brightness_alpha[4] = 1 - get(Fo_ND_brightness)
    FO_PFD_brightness_alpha[4] = 1 - get(Fo_PFD_brightness)
    ECAM_brightness_alpha[4] = 1 - get(ECAM_brightness)
end

function draw()
    sasl.gl.setBlendEquation ( BLEND_EQUATION_ADD )
    sasl.gl.setBlendFunction ( BLEND_SOURCE_ALPHA, BLEND_ONE_MINUS_SOURCE_ALPHA)
    sasl.gl.drawRectangle(0, 0, 40, 40, Capt_PFD_brightness_alpha)
    sasl.gl.drawRectangle(45, 0, 40, 40, Capt_ND_brightness_alpha)
    sasl.gl.drawRectangle(90, 0, 40, 40, EWD_brightness_alpha)
    sasl.gl.drawRectangle(135, 0, 40, 40, FO_ND_brightness_alpha)
    sasl.gl.drawRectangle(180, 0, 40, 40, FO_PFD_brightness_alpha)
    sasl.gl.drawRectangle(225, 0, 40, 40, ECAM_brightness_alpha)
    sasl.gl.resetBlending ()
end