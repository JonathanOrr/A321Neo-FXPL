position= {2279,499,900,900}
size = {900, 900}

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local ECAM_WHITE = {1.0, 1.0, 1.0}
local ECAM_BLUE = {0.004, 1.0, 1.0}
local ECAM_GREEN = {0.184, 0.733, 0.219}
local ECAM_ORANGE = {0.725, 0.521, 0.18}

function draw()
    sasl.gl.drawText(B612MONO_regular, size[1]/2, size[2]/2, "test", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
end