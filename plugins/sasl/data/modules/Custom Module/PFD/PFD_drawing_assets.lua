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
-- File: PFD_drawing_assets.lua
-- Short description: place to find all the texture for drawing PFDs
-------------------------------------------------------------------------------

--texture loading

PFD_pitch_scale_mask = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/PFD_pitch_scale_mask.png")
PFD_normal_pitch_scale = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/ADI_normal.png")
PFD_abnormal_pitch_scale = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/ADI_alt_direct.png")
PFD_static_sky = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/static blue.png")
PFD_ground = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/static red.png")
PFD_pitch_wings = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/pitch_wings.png")
PFD_pitch_yellow_box = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/adi_fd_dot.png")
PFD_vs_bgd = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/vs_background.png")
PFD_vs_mask = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/vs_mask.png")
PFD_bank_angle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/bank_angle.png")
PFD_bank_angle_indicator = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Beta Target Upper.png")
PFD_bank_angle_beta_angle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/beta target.png")
PFD_spd_needle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/spd_needle.png")
PFD_spd_target = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/spd_selected_bug.png")
PFD_spd_tape = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/spd_tape.png")
PFD_spd_trend_up = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Accel Arrow.png")
PFD_spd_trend_dn = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Decel Arrow.png")
PFD_alt_tap_1 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/1.png")
PFD_alt_tap_2 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/2.png")
PFD_alt_tap_3 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/3.png")
PFD_alt_tap_4 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/4.png")
PFD_alt_tap_5 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/5.png")
PFD_alt_tap_6 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/6.png")
PFD_alt_tap_7 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/7.png")
PFD_alt_tap_8 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt tape/8.png")
PFD_alt_box = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/altyellowbox.png")
PFD_alt_box_bgd = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt_frame.png")
PFD_small_alt_digit = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt numbers/AltDisplay_tens-1.png")
PFD_big_alt_digit = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/alt numbers/AltNumbers-1.png")
PFD_hdg_tape = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Heading Tape.png")
PFD_trk_diamond = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/track hdg.png")
PFD_aprot_tape = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Vprot.png")
PFD_vls_tape = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Vls.png")
PFD_vmax_vsw_tape = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Overspeed.png")
PFD_sidestick_box = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/stick input frame.png")
PFD_sidestick_cross = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/stick input.png")
PFD_tailstrike_arrow = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Tail Strike Arrow.png")
PFD_att_hdg_tape = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/horizon_tape.png")
PFD_att_bird = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/Bird.png")
PFD_gs_scale = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/LSV.png")
PFD_loc_scale = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/PFD/LSH.png")