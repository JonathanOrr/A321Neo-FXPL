function draw()
    sasl.gl.drawText(Font_MCDU, 15, 450, "GND SPLRS", 40, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    --SPLR STATUS--
    for i = 1, 5 do
        sasl.gl.drawRectangle(300 + (i - 1) * 30, 450, 20, 20, FCTL.SPLR.STAT.L[5 - (i - 1)].controlled and ECAM_HIGH_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_MCDU, 305 + (i - 1) * 30, 454, 5 - (i - 1), 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

        sasl.gl.drawRectangle(480 + (i - 1) * 30, 450, 20, 20, FCTL.SPLR.STAT.R[i].controlled and ECAM_HIGH_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_MCDU, 485 + (i - 1) * 30, 454, i, 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end

    --PLD--
    local A_1   = (get(Cockpit_throttle_lever_L) < THR_IDLE_START or get(Cockpit_throttle_lever_R) < THR_IDLE_START)
    local A_2   = (get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) <= THR_IDLE_END)
    local B_1_1 = get(Either_Aft_on_ground) == 1
    local B_1_2 = RA_sys.all_RA_user() < 6
    local B_2   = get(Ground_spoilers_mode) == 1

    Sasl_DrawWideFrame(10, 10 + 235 + 10, 550, 175, 2, 1, ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 410, "PLD", 20, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 390, "       ONE/TWO LEV IDL/REV                      ", 12, false, false, TEXT_ALIGN_LEFT, A_1 and UI_LIGHT_BLUE or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 380, "                          AND                   ", 12, false, false, TEXT_ALIGN_LEFT, (A_1 and A_2) and UI_LIGHT_BLUE or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 365, " ALL LEV AT/LOWER THAN IDL                      ", 12, false, false, TEXT_ALIGN_LEFT, A_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 345, "                                             AND", 12, false, false, TEXT_ALIGN_LEFT, (A_1 and A_2 and ((B_1_1 and B_1_2) or B_2)) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 320, "                                    OR          ", 12, false, false, TEXT_ALIGN_LEFT, ((B_1_1 and B_1_2) or B_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 290, "ONE/TWO MLG BECOME PRESSED                      ", 12, false, false, TEXT_ALIGN_LEFT, B_1_1 and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 275, "                          AND                   ", 12, false, false, TEXT_ALIGN_LEFT, (B_1_1 and B_1_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 260, "                  RA < 6ft                      ", 12, false, false, TEXT_ALIGN_LEFT, B_1_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawLine(270, 385, 400, 350, (A_1 and A_2) and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawLine(430, 350, 680, 350, B_2 and UI_LIGHT_BLUE or (get(Ground_spoilers_mode) == 2 and ECAM_HIGH_GREEN or ECAM_WHITE))

    sasl.gl.drawLine(345, 325, 400, 350, ((B_1_1 and B_1_2) or B_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawLine(270, 280, 320, 325, (B_1_1 and B_1_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawLine(650, 315, 650, 350, B_2 and UI_LIGHT_BLUE or (get(Ground_spoilers_mode) == 2 and ECAM_HIGH_GREEN or ECAM_WHITE))
    sasl.gl.drawLine(335, 315, 650, 315, B_2 and UI_LIGHT_BLUE or (get(Ground_spoilers_mode) == 2 and ECAM_HIGH_GREEN or ECAM_WHITE))

    sasl.gl.drawCircle(650, 350, 5, true, B_2 and UI_LIGHT_BLUE or (get(Ground_spoilers_mode) == 2 and ECAM_HIGH_GREEN or ECAM_WHITE))

    --GIS--
    local A_1_1   = get(Ground_spoilers_armed) == 1
    local A_1_2   = (get(Cockpit_throttle_lever_L) < THR_IDLE_START or get(Cockpit_throttle_lever_R) < THR_IDLE_START)
    local A_2     = (get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) <= THR_IDLE_END)
    local B_1_1_1 = get(Aft_wheel_on_ground) == 1
    local B_1_1_2 = RA_sys.all_RA_user() < 6
    local B_1_2   = get(Wheel_spd_kts_L) >= 72 or get(Wheel_spd_kts_R) >= 72
    local B_2     = get(Ground_spoilers_mode) == 2

    Sasl_DrawWideFrame(10, 10, 550, 235, 2, 1, ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 225, "GIS", 20, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 205, "           GND SPLR ARMED                      ", 12, false, false, TEXT_ALIGN_LEFT, A_1_1 and UI_LIGHT_BLUE or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 190, "                         OR                    ", 12, false, false, TEXT_ALIGN_LEFT, (A_1_1 or A_1_2) and UI_LIGHT_BLUE or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 175, "      ONE/TWO LEV IDL/REV                      ", 12, false, false, TEXT_ALIGN_LEFT, A_1_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 150, "                               AND             ", 12, false, false, TEXT_ALIGN_LEFT, ((A_1_1 or A_1_2) and A_2) and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 130, "ALL LEV AT/LOWER THAN IDL                      ", 12, false, false, TEXT_ALIGN_LEFT, A_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 105, "                                            AND", 12, false, false, TEXT_ALIGN_LEFT, ((A_1_1 or A_1_2) and A_2 and (B_1_1_1 and B_1_1_2) or B_1_2 or B_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 90,  "  BOTH MLG BECOME PRESSED                      ", 12, false, false, TEXT_ALIGN_LEFT, B_1_1_1 and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 75,  "                         AND                   ", 12, false, false, TEXT_ALIGN_LEFT, (B_1_1_1 and B_1_1_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)
    sasl.gl.drawText(Font_MCDU, 15, 60,  "                 RA < 6ft                      ", 12, false, false, TEXT_ALIGN_LEFT, B_1_1_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 50,  "                                      OR       ", 12, false, false, TEXT_ALIGN_LEFT, ((B_1_1_1 and B_1_1_2) or B_1_2 or B_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 35,  "                                OR             ", 12, false, false, TEXT_ALIGN_LEFT, ((B_1_1_1 and B_1_1_2) or B_1_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawText(Font_MCDU, 15, 20,  "  WHEELSPD >= 72KTS (L/R)                      ", 12, false, false, TEXT_ALIGN_LEFT, B_1_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawLine(250, 195, 280, 155, (A_1_1 or A_1_2) and UI_LIGHT_BLUE or ECAM_WHITE)
    sasl.gl.drawLine(230, 135, 280, 155, A_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawLine(310, 155, 390, 110, ((A_1_1 or A_1_2) and A_2) and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawLine(430, 110, 680, 110, B_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawLine(360, 55, 390, 110, ((B_1_1_1 and B_1_1_2) or B_1_2 or B_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawLine(310, 40, 340, 55, ((B_1_1_1 and B_1_1_2) or B_1_2 or B_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)

    sasl.gl.drawLine(260, 80, 290, 40, (B_1_1_1 and B_1_1_2) and (B_2 and UI_LIGHT_BLUE or ECAM_HIGH_GREEN) or ECAM_WHITE)
    sasl.gl.drawLine(230, 25, 290, 40, B_1_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawLine(650, 30, 650, 110, B_2 and UI_LIGHT_BLUE or ECAM_WHITE)
    sasl.gl.drawLine(300, 30, 650, 30, B_2 and UI_LIGHT_BLUE or ECAM_WHITE)

    sasl.gl.drawCircle(650, 110, 5, true, B_2 and UI_LIGHT_BLUE or ECAM_WHITE)
end