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
-- File: ECAM_cond.lua 
-- Short description: ECAM file for the AIRCOND page 
-------------------------------------------------------------------------------

include('constants.lua')

function ecam_update_cond_page()

    set(Ecam_cond_valve_hot_air, 2*get(Hot_air_valve_pos) + get(FAILURE_AIRCOND_HOT_AIR_STUCK))
    set(Ecam_cond_valve_hot_air_cargo, 2*get(Hot_air_valve_pos_cargo) + get(FAILURE_AIRCOND_HOT_AIR_CARGO_STUCK))
    set(Ecam_cond_valve_isol_cargo_in, 2*get(Cargo_isol_in_valve) + get(FAILURE_AIRCOND_ISOL_CARGO_IN_STUCK))
    set(Ecam_cond_valve_isol_cargo_out, 2*get(Cargo_isol_out_valve) + get(FAILURE_AIRCOND_ISOL_CARGO_OUT_STUCK))

end

function draw_cond_page()
    sasl.gl.drawTexture(ECAM_COND_bgd_img, 0, 0, 900, 900, {1,1,1})
    --cabin--
    --actual temperature
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-212, size[2]/2+210, Round(get(Cockpit_temp),0), 32, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-13, size[2]/2+210, Round(get(Front_cab_temp),0), 32, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+172, size[2]/2+210, Round(get(Aft_cab_temp),0), 32, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    --duct temperatures
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-212, size[2]/2+170, Round(get(Aircond_injected_flow_temp,1),0), 32, false, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,1) > 80 and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-13, size[2]/2+170, Round(get(Aircond_injected_flow_temp,2),0), 32, false, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,2) > 80 and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+172, size[2]/2+170, Round(get(Aircond_injected_flow_temp,3),0), 32, false, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,3) > 80 and ECAM_ORANGE or ECAM_GREEN)

    -- fan failure
    if get(FAILURE_AIRCOND_FAN_FWD) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2+330, "FAN", 38, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_AIRCOND_FAN_AFT) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+120, size[2]/2+330, "FAN", 38, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    --cargo--
    --actual temperature
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+168, size[2]/2-59, Round(get(Aft_cargo_temp),0), 32, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    --duct temperatures
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+168, size[2]/2-92, Round(get(Aircond_injected_flow_temp,4),0), 32, false, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,4) > 80 and ECAM_ORANGE or ECAM_GREEN)

end
