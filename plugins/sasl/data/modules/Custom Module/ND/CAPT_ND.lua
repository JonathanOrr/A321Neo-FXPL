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
-- File: ND.lua 
-- Short description: main Logic/Graphic code for ND display
-------------------------------------------------------------------------------

position = {1030, 3166, 900, 900}
size = {900, 900}
fbo = true

include('display_common.lua')
include('ND/common_ND.lua')

capt_nd_data = new_dataset(ND_CAPT)

function draw()


    if display_special_mode(size, Capt_nd_valid) then
        return
    end

    if get(AC_ess_shed_pwrd) == 0 then   -- TODO This should be fixed when screens move around
        return -- Bus is not powered on, this component cannot work
    end
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS_SHED, 0.26, 0.26)   -- 30W (just hypothesis)


    perf_measure_start("CAPT_ND:draw()")

    draw_main(capt_nd_data)

    perf_measure_stop("CAPT_ND:draw()")
end

sasl.registerCommandHandler (ND_Capt_mode_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.mode = math.min(ND_MODE_PLAN,capt_nd_data.config.mode + 1) end end)
sasl.registerCommandHandler (ND_Capt_mode_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.mode = math.max(ND_MODE_ILS, capt_nd_data.config.mode - 1) end end)
sasl.registerCommandHandler (ND_Capt_range_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.range = math.min(ND_RANGE_320,capt_nd_data.config.range + 1) end end)
sasl.registerCommandHandler (ND_Capt_range_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.range = math.max(ND_RANGE_ZOOM_02, capt_nd_data.config.range - 1) end end)

sasl.registerCommandHandler (ND_Capt_nav1_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_1_selector = math.max(-1, capt_nd_data.config.nav_1_selector - 1) end end)
sasl.registerCommandHandler (ND_Capt_nav1_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_1_selector = math.min(1,capt_nd_data.config.nav_1_selector + 1) end end)
sasl.registerCommandHandler (ND_Capt_nav2_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_2_selector = math.max(-1, capt_nd_data.config.nav_2_selector - 1) end end)
sasl.registerCommandHandler (ND_Capt_nav2_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_2_selector = math.min(1,capt_nd_data.config.nav_2_selector + 1) end end)

sasl.registerCommandHandler (ND_Capt_cmd_cstr, 0, function(phase) nd_pb_handler(phase,capt_nd_data,ND_DATA_CSTR) end)
sasl.registerCommandHandler (ND_Capt_cmd_wpt,  0, function(phase) nd_pb_handler(phase,capt_nd_data,ND_DATA_WPT) end)
sasl.registerCommandHandler (ND_Capt_cmd_vord, 0, function(phase) nd_pb_handler(phase,capt_nd_data,ND_DATA_VORD) end)
sasl.registerCommandHandler (ND_Capt_cmd_ndb,  0, function(phase) nd_pb_handler(phase,capt_nd_data,ND_DATA_NDB) end)
sasl.registerCommandHandler (ND_Capt_cmd_arpt, 0, function(phase) nd_pb_handler(phase,capt_nd_data,ND_DATA_ARPT) end)

sasl.registerCommandHandler (Chrono_cmd_Capt_button, 0, function(phase) nd_chrono_handler(phase, capt_nd_data) end)

sasl.registerCommandHandler (ND_Capt_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Capt_Terrain, 1 - get(ND_Capt_Terrain)) end end)


local function update_buttons()
    pb_set(PB.mip.terr_nd_capt, get(ND_Capt_Terrain) == 1, false)
    
    pb_set(PB.FCU.capt_cstr, false, capt_nd_data.config.extra_data == ND_DATA_CSTR)
    pb_set(PB.FCU.capt_wpt,  false, capt_nd_data.config.extra_data == ND_DATA_WPT)
    pb_set(PB.FCU.capt_vord, false, capt_nd_data.config.extra_data == ND_DATA_VORD)
    pb_set(PB.FCU.capt_ndb,  false, capt_nd_data.config.extra_data == ND_DATA_NDB)
    pb_set(PB.FCU.capt_arpt, false, capt_nd_data.config.extra_data == ND_DATA_ARPT)
    
    pb_set(PB.FCU.capt_range_zoom, false, capt_nd_data.config.range <= ND_RANGE_ZOOM_2)
    pb_set(PB.FCU.capt_range_10, false, capt_nd_data.config.range == ND_RANGE_10)
    pb_set(PB.FCU.capt_range_20, false, capt_nd_data.config.range == ND_RANGE_20)
    pb_set(PB.FCU.capt_range_40, false, capt_nd_data.config.range == ND_RANGE_40)
    pb_set(PB.FCU.capt_range_80, false, capt_nd_data.config.range == ND_RANGE_80)
    pb_set(PB.FCU.capt_range_160, false, capt_nd_data.config.range == ND_RANGE_160)
    pb_set(PB.FCU.capt_range_320, false, capt_nd_data.config.range == ND_RANGE_320)
    
end

local function update_knobs()
    Set_dataref_linear_anim_nostop(ND_Capt_mode_knob, capt_nd_data.config.mode-3, -2, 3, 5)
    Set_dataref_linear_anim_nostop(ND_Capt_nav1_level, capt_nd_data.config.nav_1_selector, -1, 1, 5)
    Set_dataref_linear_anim_nostop(ND_Capt_nav2_level, capt_nd_data.config.nav_2_selector, -1, 1, 5)
    
end

function update()

    perf_measure_start("CAPT_ND:update()")

    update_buttons()
    update_knobs()

    update_main(capt_nd_data)

    perf_measure_stop("CAPT_ND:update()")

end
