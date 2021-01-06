position = {3030, 3166, 900, 900}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_main.lua')
fbo = true

local fo_PFD_table = {
    ATT_avail = Adirs_fo_has_ATT,
    IR_avail = Adirs_fo_has_IR,
    ADR_avail = Adirs_fo_has_ADR,
    ATT_blinking = Adirs_fo_has_ATT_blink,
    IR_blinking = Adirs_fo_has_IR_blink,
    ADR_blinking = Adirs_fo_has_ADR_blink,
    Pitch = Flightmodel_pitch,
    Bank = Flightmodel_roll,
    IAS = PFD_Fo_IAS,
    Baro_ALT = PFD_Fo_Baro_Altitude,
    RA_ALT = Fo_ra_alt_ft,
    HDG = Fo_hdg,
    VS = PFD_Fo_VS,
}

function update()

end

function draw()
    if display_special_mode(size, Fo_pfd_valid) then
        return
    end

    PFD_draw_pitch_scale(fo_PFD_table)
    PFD_draw_spd_tape(fo_PFD_table)
    PFD_draw_alt_tape(fo_PFD_table)
    PFD_draw_hdg_tape(fo_PFD_table)
    PFD_draw_vs_needle(fo_PFD_table)
end