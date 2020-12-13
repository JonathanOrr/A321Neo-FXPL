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
-- File: sasl_drawing_assets.lua
-- Short description: place to find all the texture loaded into sasl
-------------------------------------------------------------------------------

--EWD
EWD_background_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/background.png")
EWD_engine_xx_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/ENG_XX.png")
EWD_slat_img =       sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/slat.png")
EWD_flap_img =       sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/flap.png")
EWD_slat_to_go_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/slattogo.png")
EWD_flap_to_go_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/flaptogo.png")
EWD_slat_tract_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/slat_tack.png")
EWD_flap_tract_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/flaps_track.png")
EWD_wing_indic_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/wing_indication.png")
EWD_req_thrust_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/EWD/ndl_trst.png")

--ECAM
--backgrounds
--ENG--
ECAM_ENG_bgd_img =    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/ENG/ENGINE.png")
ECAM_ENG_valve_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/ENG/valve.png")

--BLEED--
ECAM_BLEED_bgd_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/BLEED/Background.png")
ECAM_BLEED_grey_lines_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/BLEED/grey_lines.png")

--PRESS--
ECAM_PRESS_bgd_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/PRESS/cab_press.png")
ECAM_PRESS_grey_lines_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/PRESS/cab_press_grey_lines.png")

ECAM_ELEC_bgd_img =   sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/ELEC/Background.png")
ECAM_HYD_bgd_img =    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/HYD/bgd.png")
ECAM_FUEL_bgd_img =   sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FUEL/fuel.png")

--APU--
ECAM_APU_bgd_img =    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/APU/APU.png")
ECAM_APU_grey_lines_img =    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/APU/grey_lines.png")

--COND--
ECAM_COND_bgd_img =   sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/COND/COND.png")
ECAM_COND_grey_lines_img =   sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/COND/grey_lines.png")

--DOOR--
ECAM_DOOR_bgd_img =   sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/DOOR/Background.png")
ECAM_DOOR_grey_lines_img =   sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/DOOR/grey_lines.png")

--WHEEL--
ECAM_WHEEL_bgd_img =               sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/WHEEL/WHEEL.png")
ECAM_WHEEL_hyd_boxes_img =         sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/WHEEL/hyd_squares.png")
ECAM_WHEEL_l_nose_gear_door_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/WHEEL/leftnosegeardoor.png")
ECAM_WHEEL_r_nose_gear_door_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/WHEEL/nosegeardoor.png")
ECAM_WHEEL_l_main_gear_door_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/WHEEL/geardoor.png")
ECAM_WHEEL_r_main_gear_door_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/WHEEL/rightgeardoor.png")
ECAM_WHEEL_gears_img =             sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/WHEEL/gear.png")

--FCTL--
ECAM_FCTL_bgd_img =              sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/FCTL.png")
ECAM_FCTL_grey_lines_img =       sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/FCTL_grey.png")
ECAM_FCTL_computer_backets_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/computer_braket.png")
ECAM_FCTL_left_arrows_img =      sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/ArrowLeft.png")
ECAM_FCTL_right_arrows_img =     sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/ArrowRight.png")
ECAM_FCTL_rudder_img =           sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/Rudder.png")
ECAM_FCTL_rudder_track_img =     sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/rudder_track.png")
ECAM_FCTL_left_rudder_lim_img =  sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/LeftLimiter.png")
ECAM_FCTL_right_rudder_lim_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/RightLimiter.png")
ECAM_FCTL_rudder_trim_img =      sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/rudder_trim.png")
ECAM_FCTL_spoiler_arrow_img =    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/FCTL/SpoilerArrow.png")

--STS
ECAM_STS_bgd_img =    sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/STS/status.png")
ECAM_CRUISE_bgd_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/CRUISE/cruise.png")