position = {get(Fo_pfd_position, 1), get(Fo_pfd_position, 2), get(Fo_pfd_position, 3), get(Fo_pfd_position, 4)}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_main.lua')
include('PFD/PFD_sub_functions/PFD_att.lua')
include('PFD/PFD_sub_functions/PFD_alt_tape.lua')
include('PFD/PFD_sub_functions/PFD_spd_tape.lua')
include('PFD/PFD_sub_functions/PFD_hdg_tape.lua')
include('PFD/PFD_sub_functions/PFD_vs_needle.lua')
include('PFD/PFD_sub_functions/PFD_timers.lua')
fbo = true

local fo_PFD_table = {
    Screen_ID = PFD_FO,
    PFD_aircraft_in_air_timer = 0,
    ATT_blink_now = false,
    SPD_blink_now = false,
    ALT_blink_now = false,
    HDG_blink_now = false,
    VS_blink_now = false,
    ATT_blink_timer = 0,
    SPD_blink_timer = 0,
    ALT_blink_timer = 0,
    HDG_blink_timer = 0,
    VS_blink_timer = 0,
    PFD_brightness = Fo_PFD_brightness_act,
    RA_ALT = Fo_ra_alt_ft,
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
    Show_spd_trend = true,
    Show_mach = true,
}

function update()
    position = {get(Fo_pfd_position, 1), get(Fo_pfd_position, 2), get(Fo_pfd_position, 3), get(Fo_pfd_position, 4)}
    PFD_update_timers(fo_PFD_table)
end

function draw()
    PFD_draw_att(fo_PFD_table)
    PFD_draw_spd_tape(fo_PFD_table)
    PFD_draw_alt_tape(fo_PFD_table)
    PFD_draw_hdg_tape(fo_PFD_table)
    PFD_draw_vs_needle(fo_PFD_table)
end
