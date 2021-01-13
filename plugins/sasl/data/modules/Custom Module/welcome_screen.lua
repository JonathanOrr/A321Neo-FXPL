x,y,width,height = sasl.windows.getScreenBoundsGlobal()
size = {width,height}
 
 
function draw()

    sasl.gl.drawRectangle(0,0,size[1],size[2],{0.15, 0.15, 0.2, 0.9})

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]-200, "Welcome!", 70, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, 30, size[2]-400, "Your aircraft is loading, please wait...", 20, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, 30, size[2]-500, "This usually takes less than one minute, but it depends on your computer speed.", 20, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)


end
