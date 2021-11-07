function Draw_flight_control_module_480x160(x_pos, y_pos)
    --center point calculation(this will make it so that you just calculate onc optimising the speed)
    local CENTER_X = (2 * x_pos + 480) / 2
    local CENTER_Y = (2 * y_pos + 160) / 2

    --draw the background
    sasl.gl.drawRectangle(x_pos, y_pos, 480, 160, DARK_GREY)
    sasl.gl.drawTexture(Aircraft_behind_img, CENTER_X - 474/2, y_pos + 160 - 158, 474, 158, {1,1,1})

    --draw control surfaces indications
    --spoilers
    sasl.gl.drawWideLine(CENTER_X - 65,  y_pos + 160 - 158 + 50, CENTER_X - 65,  y_pos + 160 - 158 + 50 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 95,  y_pos + 160 - 158 + 52, CENTER_X - 95,  y_pos + 160 - 158 + 52 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 115, y_pos + 160 - 158 + 54, CENTER_X - 115, y_pos + 160 - 158 + 54 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 135, y_pos + 160 - 158 + 56, CENTER_X - 135, y_pos + 160 - 158 + 56 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 155, y_pos + 160 - 158 + 58, CENTER_X - 155, y_pos + 160 - 158 + 58 + 40, 5, LIGHT_GREY)

    sasl.gl.drawWideLine(CENTER_X + 65,  y_pos + 160 - 158 + 50, CENTER_X + 65,  y_pos + 160 - 158 + 50 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 95,  y_pos + 160 - 158 + 52, CENTER_X + 95,  y_pos + 160 - 158 + 52 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 115, y_pos + 160 - 158 + 54, CENTER_X + 115, y_pos + 160 - 158 + 54 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 135, y_pos + 160 - 158 + 56, CENTER_X + 135, y_pos + 160 - 158 + 56 + 40, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 155, y_pos + 160 - 158 + 58, CENTER_X + 155, y_pos + 160 - 158 + 58 + 40, 5, LIGHT_GREY)

    sasl.gl.drawWideLine(CENTER_X - 65,  y_pos + 160 - 158 + 50, CENTER_X - 65,  y_pos + 160 - 158 + 50 + get(L_SPLR_1), 5, FBW.fctl.SPLR.STAT.L[1].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X - 95,  y_pos + 160 - 158 + 52, CENTER_X - 95,  y_pos + 160 - 158 + 52 + get(L_SPLR_2), 5, FBW.fctl.SPLR.STAT.L[2].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X - 115, y_pos + 160 - 158 + 54, CENTER_X - 115, y_pos + 160 - 158 + 54 + get(L_SPLR_3), 5, FBW.fctl.SPLR.STAT.L[3].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X - 135, y_pos + 160 - 158 + 56, CENTER_X - 135, y_pos + 160 - 158 + 56 + get(L_SPLR_4), 5, FBW.fctl.SPLR.STAT.L[4].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X - 155, y_pos + 160 - 158 + 58, CENTER_X - 155, y_pos + 160 - 158 + 58 + get(L_SPLR_5), 5, FBW.fctl.SPLR.STAT.L[5].controlled and LIGHT_BLUE or ORANGE)

    sasl.gl.drawWideLine(CENTER_X + 65,  y_pos + 160 - 158 + 50, CENTER_X + 65,  y_pos + 160 - 158 + 50 + get(R_SPLR_1), 5, FBW.fctl.SPLR.STAT.R[1].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X + 95,  y_pos + 160 - 158 + 52, CENTER_X + 95,  y_pos + 160 - 158 + 52 + get(R_SPLR_2), 5, FBW.fctl.SPLR.STAT.R[2].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X + 115, y_pos + 160 - 158 + 54, CENTER_X + 115, y_pos + 160 - 158 + 54 + get(R_SPLR_3), 5, FBW.fctl.SPLR.STAT.R[3].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X + 135, y_pos + 160 - 158 + 56, CENTER_X + 135, y_pos + 160 - 158 + 56 + get(R_SPLR_4), 5, FBW.fctl.SPLR.STAT.R[4].controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X + 155, y_pos + 160 - 158 + 58, CENTER_X + 155, y_pos + 160 - 158 + 58 + get(R_SPLR_5), 5, FBW.fctl.SPLR.STAT.R[5].controlled and LIGHT_BLUE or ORANGE)

    --ailerons
    sasl.gl.drawWideLine(CENTER_X - 185, y_pos + 160 - 158 + 30, CENTER_X - 185, y_pos + 160 - 158 + 30 + 50, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 185, y_pos + 160 - 158 + 30, CENTER_X + 185, y_pos + 160 - 158 + 30 + 50, 5, LIGHT_GREY)

    sasl.gl.drawWideLine(CENTER_X - 185, y_pos + 160 - 158 + 30 + 25, CENTER_X - 185, y_pos + 160 - 158 + 30 + 25 - get(L_aileron), 5, FBW.fctl.AIL.STAT.L.controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X + 185, y_pos + 160 - 158 + 30 + 25, CENTER_X + 185, y_pos + 160 - 158 + 30 + 25 - get(R_aileron), 5, FBW.fctl.AIL.STAT.R.controlled and LIGHT_BLUE or ORANGE)

    --elevators
    sasl.gl.drawWideLine(CENTER_X - 45, y_pos + 160 - 158 + 49, CENTER_X - 45, y_pos + 160 - 158 + 49 + 47, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X + 45, y_pos + 160 - 158 + 49, CENTER_X + 45, y_pos + 160 - 158 + 49 + 47, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X - 45, y_pos + 160 - 158 + 49 + 17, CENTER_X - 45, y_pos + 160 - 158 + 49 + 17 - get(L_elevator), 5, FBW.fctl.ELEV.STAT.L.controlled and LIGHT_BLUE or ORANGE)
    sasl.gl.drawWideLine(CENTER_X + 45, y_pos + 160 - 158 + 49 + 17, CENTER_X + 45, y_pos + 160 - 158 + 49 + 17 - get(R_elevator), 5, FBW.fctl.ELEV.STAT.R.controlled and LIGHT_BLUE or ORANGE)

    --rudder
    sasl.gl.drawWideLine(CENTER_X, y_pos + 160 - 158 + 130, CENTER_X - get(Rudder_travel_lim), y_pos + 160 - 158 + 130, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X, y_pos + 160 - 158 + 130, CENTER_X + get(Rudder_travel_lim), y_pos + 160 - 158 + 130, 5, LIGHT_GREY)
    sasl.gl.drawWideLine(CENTER_X, y_pos + 160 - 158 + 130, CENTER_X + get(Rudder_total), y_pos + 160 - 158 + 130, 5, FBW.fctl.surfaces.rud.rud.mechanical and LIGHT_BLUE or ORANGE)
end