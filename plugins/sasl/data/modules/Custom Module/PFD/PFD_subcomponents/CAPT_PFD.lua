position = {30, 3166, 900, 900}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_main.lua')
fbo = true

local capt_PFD_table = {
    ATT_avail = Adirs_capt_has_ATT,
    IR_avail = Adirs_capt_has_IR,
    ADR_avail = Adirs_capt_has_ADR,
    ATT_blinking = Adirs_capt_has_ATT_blink,
    IR_blinking = Adirs_capt_has_IR_blink,
    ADR_blinking = Adirs_capt_has_ADR_blink,
    Pitch = Flightmodel_pitch,
    Bank = Flightmodel_roll,
    IAS = PFD_Capt_IAS,
    Baro_ALT = PFD_Capt_Baro_Altitude,
    RA_ALT = Capt_ra_alt_ft,
    HDG = Capt_hdg,
    VS = PFD_Capt_VS,
}

function update()

end


function draw()
    if display_special_mode(size, Capt_pfd_valid) then
        return
    end

    PFD_draw_pitch_scale(capt_PFD_table)
    PFD_draw_spd_tape(capt_PFD_table)
    PFD_draw_alt_tape(capt_PFD_table)
    PFD_draw_hdg_tape(capt_PFD_table)
    PFD_draw_vs_needle(capt_PFD_table)
end