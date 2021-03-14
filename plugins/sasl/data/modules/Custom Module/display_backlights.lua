position= {0,0,4096,4096}
size = {4096, 4096}

function draw()
    Draw_LCD_backlight(30,   3166, 900, 900, 0.2, 1, get(Capt_PFD_brightness_act))
    Draw_LCD_backlight(1030, 3166, 900, 900, 0.2, 1, get(Capt_ND_brightness_act))
    Draw_LCD_backlight(2030, 3166, 900, 900, 0.2, 1, get(Fo_ND_brightness_act))
    Draw_LCD_backlight(3030, 3166, 900, 900, 0.2, 1, get(Fo_PFD_brightness_act))
    Draw_LCD_backlight(30,   2226, 900, 900, 0.2, 1, get(EWD_brightness_act))
    Draw_LCD_backlight(1030, 2226, 900, 900, 0.2, 1, get(ECAM_brightness_act))
    Draw_LCD_backlight(2030, 2726, 600, 400, 0.2, 1, get(DRAIMS_1_brightness_act))
    Draw_LCD_backlight(2030, 2298, 600, 400, 0.2, 1, get(DRAIMS_2_brightness_act))
end
