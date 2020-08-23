position = {1852, 1449, 600, 400}
size = {600, 400}

--variables
local DRAIMS_entry = ""

--DMC colors
local DRAIMS_BLACK = {0,0,0}
local DRAIMS_WHITE = {1.0, 1.0, 1.0}
local DRAIMS_BLUE = {0.004, 1.0, 1.0}
local DRAIMS_GREEN = {0.184, 0.733, 0.219}
local DRAIMS_ORANGE = {0.725, 0.521, 0.18}
local DRAIMS_RED = {1, 0.0, 0.0}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")
local A320_panel_font = sasl.gl.loadFont("fonts/A320PanelFont_V0.2b.ttf")

--a32nx dataref

--sim dataref

--register commands--
--top buttons
sasl.registerCommandHandler ( Draims_VHF_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_current_page, 1)
    end
end)

sasl.registerCommandHandler ( Draims_HF_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_current_page, 2)
    end
end)

sasl.registerCommandHandler ( Draims_NAV_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(DRAIMS_current_page, 6)
    end
end)

--left side buttons
sasl.registerCommandHandler ( Draims_l_1_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
    end
end)
sasl.registerCommandHandler ( Draims_l_2_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
    end
end)
sasl.registerCommandHandler ( Draims_l_3_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
    end
end)
sasl.registerCommandHandler ( Draims_l_4_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
    end
end)

--right side buttons
sasl.registerCommandHandler ( Draims_r_1_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 7)
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_2_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 8)
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_3_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(DRAIMS_current_page) == 6 then-- on nav page
            set(DRAIMS_current_page, 8)
        end
    end
end)
sasl.registerCommandHandler ( Draims_r_4_button, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
    end
end)

--numberpad
sasl.registerCommandHandler ( Draims_1_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "1"
        end
    end
end)
sasl.registerCommandHandler ( Draims_2_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "2"
        end
    end
end)
sasl.registerCommandHandler ( Draims_3_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "3"
        end
    end
end)
sasl.registerCommandHandler ( Draims_4_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "4"
        end
    end
end)
sasl.registerCommandHandler ( Draims_5_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "5"
        end
    end
end)
sasl.registerCommandHandler ( Draims_6_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "6"
        end
    end
end)
sasl.registerCommandHandler ( Draims_7_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "7"
        end
    end
end)
sasl.registerCommandHandler ( Draims_8_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "8"
        end
    end
end)
sasl.registerCommandHandler ( Draims_9_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "9"
        end
    end
end)
sasl.registerCommandHandler ( Draims_0_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "0"
        end
    end
end)
sasl.registerCommandHandler ( Draims_dot_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry < 6 then
            DRAIMS_entry = DRAIMS_entry .. "."
        end
    end
end)
sasl.registerCommandHandler ( Draims_clr_key, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if #DRAIMS_entry > 1 then
            DRAIMS_entry = string.sub(DRAIMS_entry, 1, #DRAIMS_entry - 1)
        else
            DRAIMS_entry = ""
        end
    end
end)

function update()
end

function draw()
    if get(DRAIMS_format_error) == 1 then
        sasl.gl.drawText(A320_panel_font, 440, 55, "FMT ERR\nxxx.xx", 35, false, false, TEXT_ALIGN_LEFT, DRAIMS_ORANGE)
    else
        sasl.gl.drawText(A320_panel_font, 440, 30, DRAIMS_entry, 50, false, false, TEXT_ALIGN_LEFT, DRAIMS_WHITE)
    end
end