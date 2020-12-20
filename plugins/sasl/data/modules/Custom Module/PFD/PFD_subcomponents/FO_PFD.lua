position = {3030, 3166, 900, 900}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_main.lua')
fbo = true

function update()

end

function draw()
    if display_special_mode(size, Fo_pfd_valid) then
        return
    end

    PFD_draw_pitch_scale(get(Flightmodel_pitch), get(Flightmodel_roll))
    PFD_draw_spd_tape (get(PFD_Fo_IAS), 0, 1)
    PFD_draw_alt_tape(get(PFD_Fo_Baro_Altitude), get(Fo_ra_alt_ft), 0, 1)
    PFD_draw_hdg_tape(get(Fo_hdg), 0, 1)
    PFD_draw_vs_needle(get(PFD_Fo_VS), 0, 1)
end