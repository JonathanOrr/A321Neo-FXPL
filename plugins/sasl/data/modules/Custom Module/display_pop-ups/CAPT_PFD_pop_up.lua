position= {0,0,900,900}
size = {900, 900}

include("display_brightness.lua")

local texture_table = {
    CAPT_PFD_popup_texture,
    CAPT_ND_popup_texture,
    EWD_popup_texture,
    ECAM_popup_texture,
    FO_PFD_popup_texture,
    FO_ND_popup_texture,
}

function draw()
    --proportionally resize the window
    if CAPT_PFD_window:isVisible() then
        local window_x, window_y, window_width, window_height = CAPT_PFD_window:getPosition()
        CAPT_PFD_window:setPosition ( window_x , window_y , window_width, window_width)
    end

    Draw_LCD_backlight(0, 0, 900, 900, 0.2, 1, get(Capt_PFD_brightness_act))
    sasl.gl.drawTexture(texture_table[get(Capt_pfd_displaying_status)], 0, 0, 900, 900, {1, 1, 1})
    DMC_display_special_mode(get(Capt_pfd_valid), {0, 0, 900, 900}, get(Capt_PFD_brightness_act))
    sasl.gl.drawRectangle(0, 0, 900, 900, {0,0,0, 1 - get(Capt_PFD_brightness_act)})
end