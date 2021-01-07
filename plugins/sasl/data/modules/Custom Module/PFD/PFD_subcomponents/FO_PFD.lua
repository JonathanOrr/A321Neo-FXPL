position = {3030, 3166, 900, 900}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_main.lua')
include('PFD/PFD_sub_functions/PFD_att.lua')
include('PFD/PFD_sub_functions/PFD_alt_tape.lua')
include('PFD/PFD_sub_functions/PFD_spd_tape.lua')
include('PFD/PFD_sub_functions/PFD_timers.lua')
fbo = true

local fo_PFD_table = {
    PFD_aircraft_in_air_timer = 0,
    PFD_brightness = Fo_PFD_brightness_act,
    ATT_avail = Adirs_fo_has_ATT,
    IR_avail = Adirs_fo_has_IR,
    ADR_avail = Adirs_fo_has_ADR,
    ATT_blinking = Adirs_fo_has_ATT_blink,
    IR_blinking = Adirs_fo_has_IR_blink,
    ADR_blinking = Adirs_fo_has_ADR_blink,
    Pitch = Flightmodel_pitch,
    Bank = Flightmodel_roll,
    IAS = PFD_Fo_IAS,
    IAS_accel = PFD_Fo_ias_accel,
    Baro_ALT = PFD_Fo_Baro_Altitude,
    RA_ALT = Fo_ra_alt_ft,
    HDG = Fo_hdg,
    VS = PFD_Fo_VS,
    Corresponding_FAC_status = FAC_2_status,
    Opposite_FAC_status = FAC_1_status,
    Vmax_prot_spd = Fo_VMAX_prot,
    Vmax_spd = Fo_VMAX,
    VFE = VFE_speed,
    VLS = VLS,
    F_spd = F_speed,
    S_spd = S_speed,
    GD_spd = Fo_GD,
    Aprot_SPD = Fo_Vaprot_vsw,
    Amax = Fo_Valpha_MAX,
}

function update()
    PFD_update_timers(fo_PFD_table)
end

function draw()
    if display_special_mode(size, Fo_pfd_valid) then
        return
    end

    PFD_draw_att(fo_PFD_table)
    PFD_draw_spd_tape(fo_PFD_table)
    PFD_draw_alt_tape(fo_PFD_table)
    PFD_draw_hdg_tape(fo_PFD_table)
    PFD_draw_vs_needle(fo_PFD_table)
end