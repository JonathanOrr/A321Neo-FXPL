position = {1177, 1539, 1137, 86}
size = {1137, 86}

include("AUTOFLT/FCU/FCU_drawing_functions/FCU_ALT.lua")
include("AUTOFLT/FCU/FCU_drawing_functions/FCU_HDG_TRK.lua")
include("AUTOFLT/FCU/FCU_drawing_functions/FCU_SPD_MACH.lua")
include("AUTOFLT/FCU/FCU_drawing_functions/FCU_VS_FPA.lua")

function update()
end

function draw()
    Draw_green_LED_backlight(0, 0, size[1], size[2], 0.5, 1, 1)

    FCU_draw_ALT()
    FCU_draw_HDG_TRK()
    FCU_draw_SPD_MACH()
    FCU_draw_VS_FPA()
end