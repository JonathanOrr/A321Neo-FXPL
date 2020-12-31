fbo = true
--for the cursor

include('constants.lua')

position = {3020, 1248, 1066, 800}
size = {1066, 800}

local function draw_efb_bgd()
    sasl.gl.drawRectangle (0, 0, 1066, 800, EFB_GREY)
    SASL_drawRoundedFrames(27 ,27 ,1012 ,660 , 5, 30, EFB_RED)
end

function draw()
    draw_efb_bgd()
end