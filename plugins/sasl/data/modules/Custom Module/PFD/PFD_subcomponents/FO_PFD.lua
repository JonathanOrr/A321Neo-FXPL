position = {get(Fo_pfd_position, 1), get(Fo_pfd_position, 2), get(Fo_pfd_position, 3), get(Fo_pfd_position, 4)}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_main.lua')
include('PFD/PFD_sub_functions/PFD_LS.lua')
include('PFD/PFD_sub_functions/PFD_get_ILS_data.lua')
include('PFD/PFD_sub_functions/PFD_att.lua')
include('PFD/PFD_sub_functions/PFD_alt_tape.lua')
include('PFD/PFD_sub_functions/PFD_spd_tape.lua')
include('PFD/PFD_sub_functions/PFD_hdg_tape.lua')
include('PFD/PFD_sub_functions/PFD_vs_needle.lua')
include('PFD/PFD_sub_functions/PFD_timers.lua')
fbo = true

local fo_PFD_table = {
    Screen_ID = PFD_FO,
    Opposite_screen_IS = PFD_CAPT,
    NAV_1_hz = NAV_1_freq_hz,
    NAV_2_hz = NAV_2_freq_hz,
    NAVDATA_update_timer = 0,
    ILS_data = {
        Navaid_ID = nil,
        NavAidType = nil,
        latitude = nil,
        longitude = nil,
        height = nil,
        frequency = nil,
        heading = nil,
        id = nil,
        name = nil,
        isInsideLoadedDSFs = nil,
    },
    DME_data = {
        Navaid_ID = nil,
        NavAidType = nil,
        latitude = nil,
        longitude = nil,
        height = nil,
        frequency = nil,
        heading = nil,
        id = nil,
        name = nil,
        isInsideLoadedDSFs = nil,
    },
    Distance_to_dme = 0,
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
    LS_enabled = Fo_landing_system_enabled,
    BUSS_update_timer = 0,
    BUSS_vsw_pos = 150,
}

sasl.registerCommandHandler(FCU_Fo_LS_cmd, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Fo_landing_system_enabled, 1 - get(Fo_landing_system_enabled)) end end)

function update()
    position = {get(Fo_pfd_position, 1), get(Fo_pfd_position, 2), get(Fo_pfd_position, 3), get(Fo_pfd_position, 4)}

    pb_set(PB.FCU.fo_ls, false, get(Fo_landing_system_enabled) == 1)

    Get_ILS_data(fo_PFD_table)
    PFD_update_timers(fo_PFD_table)
end

function draw()
    PFD_draw_LS(fo_PFD_table)
    PFD_draw_att(fo_PFD_table)
    PFD_draw_spd_tape(fo_PFD_table)
    PFD_draw_alt_tape(fo_PFD_table)
    PFD_draw_hdg_tape(fo_PFD_table)
    PFD_draw_vs_needle(fo_PFD_table)
end
