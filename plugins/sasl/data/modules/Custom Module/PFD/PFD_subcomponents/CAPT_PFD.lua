position = {30, 3166, 900, 900}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_main.lua')
include('PFD/PFD_sub_functions/PFD_att.lua')
include('PFD/PFD_sub_functions/PFD_alt_tape.lua')
include('PFD/PFD_sub_functions/PFD_spd_tape.lua')
include('PFD/PFD_sub_functions/PFD_timers.lua')
fbo = true

local capt_PFD_table = {
    PFD_aircraft_in_air_timer = 0,
    PFD_brightness = Capt_PFD_brightness_act,
    ATT_avail = Adirs_capt_has_ATT,
    IR_avail = Adirs_capt_has_IR,
    ADR_avail = Adirs_capt_has_ADR,
    ATT_blinking = Adirs_capt_has_ATT_blink,
    IR_blinking = Adirs_capt_has_IR_blink,
    ADR_blinking = Adirs_capt_has_ADR_blink,
    Pitch = Flightmodel_pitch,
    Bank = Flightmodel_roll,
    IAS = PFD_Capt_IAS,
    IAS_accel = PFD_Capt_ias_accel,
    Baro_ALT = PFD_Capt_Baro_Altitude,
    RA_ALT = Capt_ra_alt_ft,
    HDG = Capt_hdg,
    VS = PFD_Capt_VS,
    Corresponding_FAC_status = FAC_1_status,
    Opposite_FAC_status = FAC_2_status,
    Vmax_prot_spd = Capt_VMAX_prot,
    Vmax_spd = Capt_VMAX,
    VFE = VFE_speed,
    VLS = VLS,
    F_spd = F_speed,
    S_spd = S_speed,
    GD_spd = Capt_GD,
    Aprot_SPD = Capt_Vaprot_vsw,
    Amax = Capt_Valpha_MAX,
}

function update()
    PFD_update_timers(capt_PFD_table)
end


function draw()
    if display_special_mode(size, Capt_pfd_valid) then
        return
    end

    PFD_draw_att(capt_PFD_table)
    PFD_draw_spd_tape(capt_PFD_table)
    PFD_draw_alt_tape(capt_PFD_table)
    PFD_draw_hdg_tape(capt_PFD_table)
    PFD_draw_vs_needle(capt_PFD_table)
end