position= {1990,1866,463,325}
size = {463, 325}

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

local ECAM_BLACK = {0, 0, 0}
local ECAM_GREEN = {0.184, 0.733, 0.219}

function update()

end

function draw()

    sasl.gl.drawText (B612MONO_regular, 10, 20, "LINE 1" , 20, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, 10, 50, "LINE 2" , 20, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, 10, 80, "LINE 3" , 20, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )


    sasl.gl.drawText (B612MONO_regular, size[1]-10, 20, "LINE 1" , 20, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, size[1]-10, 50, "LINE 2" , 20, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, size[1]-10, 80, "LINE 3" , 20, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN )

    sasl.gl.drawText (B612MONO_regular, size[1]/2, 80, "TITLE" , 20, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, size[1]/2+100, 50, "R2" , 20, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, size[1]/2+100, 20, "R1" , 20, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, size[1]/2-95, 50, "L2" , 20, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, size[1]/2-95, 20, "L1" , 20, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )

    sasl.gl.drawText (B612MONO_regular, 10, size[2]-20, "1200Z FROM LIMM CTL" , 17, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )

    sasl.gl.drawRectangle ( size[1]-60, size[2]-33, 60 , 32 , ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, size[1]-8, size[2]-25, "ACK" , 25, false, false, TEXT_ALIGN_RIGHT, ECAM_BLACK )

    sasl.gl.drawText (B612MONO_regular, 10, size[2]-56, "LONG LINE 5" , 25, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-92, "LONG LINE 4" , 25, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-128, "LONG LINE 3" , 25, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-164, "LONG LINE 2" , 25, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-200, "LONG LINE 1" , 25, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN )


end
