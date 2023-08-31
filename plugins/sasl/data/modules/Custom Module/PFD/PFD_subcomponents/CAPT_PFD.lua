-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------

position = {get(Capt_pfd_position, 1), get(Capt_pfd_position, 2), get(Capt_pfd_position, 3), get(Capt_pfd_position, 4)}
size = {900, 900}
include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_sub_functions/PFD_FMA_subcomponents/all_fmas.lua')
include('PFD/PFD_sub_functions/PFD_FMA.lua')
include('PFD/PFD_sub_functions/PFD_LS.lua')
include('PFD/PFD_sub_functions/PFD_get_ILS_data.lua')
include('PFD/PFD_sub_functions/PFD_att.lua')
include('PFD/PFD_sub_functions/PFD_alt_tape.lua')
include('PFD/PFD_sub_functions/PFD_spd_tape.lua')
include('PFD/PFD_sub_functions/PFD_hdg_tape.lua')
include('PFD/PFD_sub_functions/PFD_vs_needle.lua')
include('PFD/PFD_sub_functions/PFD_timers.lua')
include('PFD/PFD_sub_functions/PFD_FMGS_data.lua')

fbo = true

PFD.Capt_PFD_table = {
    Screen_ID = PFD_CAPT,
    Opposite_screen_ID = PFD_FO,
    NAVDATA_update_timer = 0,
    ILS_data = {
        is_valid = false,
        frequency = nil,
        course = nil,
        id = nil,
        gs_is_valid = false,
        loc_is_valid = false,
        gs_deviation = 0,
        loc_deviation = 0
    },
    DME_data = {
        is_valid = false,
        value = 0,
    },
    Distance_to_dme = 0,
    PFD_aircraft_in_air_timer = 0,
    PFD_SPD_LIM_timer = 0,
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
    PFD_brightness = Capt_PFD_brightness_act,
    RA_sensor = 1,
    VS = PFD_Capt_VS,
    AoA = Filtered_CA_AoA,
    FAC_SPD_LIM_AVAIL = FBW.FMGEC.FMGEC_1.SPD_LIM_AVAIL,
    Vmax_prot_spd = VMAX_prot,
    Vmax_spd = VMAX,
    VFE = VFE_speed,
    VLS = VLS,
    F_spd = F_speed,
    S_spd = S_speed,
    GD_spd = GD,
    Aprot_SPD = CA_Vaprot_VSW,
    Amax = CA_Valpha_MAX,
    Show_spd_trend = true,
    Show_mach = true,
    LS_enabled = Capt_landing_system_enabled,
    BUSS_update_time = 0,
    BUSS_vsw_pos = 85,
    BUSS_target_pos = 450,
    FMGS_timer = 0,
    target_speed = nil,
}

sasl.registerCommandHandler(FCU_Capt_LS_cmd, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(Capt_landing_system_enabled, 1 - get(Capt_landing_system_enabled)) end end)

function update()
    position = {get(Capt_pfd_position, 1), get(Capt_pfd_position, 2), get(Capt_pfd_position, 3), get(Capt_pfd_position, 4)}

    pb_set(PB.FCU.capt_ls, false, get(Capt_landing_system_enabled) == 1)

    Get_ILS_data(PFD.Capt_PFD_table)
    Get_FMGS_data(PFD.Capt_PFD_table)
    PFD_update_timers(PFD.Capt_PFD_table)
end

local skip_1st_frame_AA = true
function draw()
    --render into the popup texure

    if not skip_1st_frame_AA then
        sasl.gl.setRenderTarget(CAPT_PFD_popup_texture, true, get(PANEL_AA_LEVEL_1to32))
    else
        sasl.gl.setRenderTarget(CAPT_PFD_popup_texture, true)
    end
    skip_1st_frame_AA = false

    PFD_draw_FMA(PFD_ALL_FMA)
    PFD_draw_LS(PFD.Capt_PFD_table)
    PFD_draw_att(PFD.Capt_PFD_table)
    PFD_draw_spd_tape(0, 0, PFD.Capt_PFD_table)
    PFD_draw_alt_tape(PFD.Capt_PFD_table)
    PFD_draw_alt_ref(PFD.Capt_PFD_table)
    PFD_draw_hdg_tape(PFD.Capt_PFD_table)
    PFD_draw_vs_needle(PFD.Capt_PFD_table)
    sasl.gl.restoreRenderTarget()

    sasl.gl.drawTexture(CAPT_PFD_popup_texture, 0, 0, 900, 900, {1,1,1})
end
