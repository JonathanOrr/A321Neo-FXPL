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
-- File: ND_fo.lua
-- Short description: F/O ND display (logic is in ND.lua)
-------------------------------------------------------------------------------

position = {2030, 3166, 900, 900}
size = {900, 900}
fbo = true

include('ND/common_ND.lua')

fo_nd_data = new_dataset(ND_FO)

sasl.registerCommandHandler (ND_Fo_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Fo_Terrain, 1 - get(ND_Fo_Terrain)) end end)

sasl.registerCommandHandler (ND_Fo_mode_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.mode = math.min(ND_MODE_PLAN,fo_nd_data.config.mode + 1) end end)
sasl.registerCommandHandler (ND_Fo_mode_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.mode = math.max(ND_MODE_ILS, fo_nd_data.config.mode - 1) end end)
sasl.registerCommandHandler (ND_Fo_range_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.range = math.min(ND_RANGE_320,fo_nd_data.config.range + 1) end end)
sasl.registerCommandHandler (ND_Fo_range_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.range = math.max(ND_RANGE_ZOOM_02, fo_nd_data.config.range - 1) end end)

sasl.registerCommandHandler (ND_Fo_nav1_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.nav_1_selector = math.max(-1, fo_nd_data.config.nav_1_selector - 1) end end)
sasl.registerCommandHandler (ND_Fo_nav1_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.nav_1_selector = math.min(1,fo_nd_data.config.nav_1_selector + 1) end end)
sasl.registerCommandHandler (ND_Fo_nav2_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.nav_2_selector = math.max(-1, fo_nd_data.config.nav_2_selector - 1) end end)
sasl.registerCommandHandler (ND_Fo_nav2_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then fo_nd_data.config.nav_2_selector = math.min(1,fo_nd_data.config.nav_2_selector + 1) end end)

sasl.registerCommandHandler (ND_Fo_cmd_cstr, 0, function(phase) nd_pb_handler(phase,fo_nd_data,ND_DATA_CSTR) end)
sasl.registerCommandHandler (ND_Fo_cmd_wpt,  0, function(phase) nd_pb_handler(phase,fo_nd_data,ND_DATA_WPT) end)
sasl.registerCommandHandler (ND_Fo_cmd_vord, 0, function(phase) nd_pb_handler(phase,fo_nd_data,ND_DATA_VORD) end)
sasl.registerCommandHandler (ND_Fo_cmd_ndb,  0, function(phase) nd_pb_handler(phase,fo_nd_data,ND_DATA_NDB) end)
sasl.registerCommandHandler (ND_Fo_cmd_arpt, 0, function(phase) nd_pb_handler(phase,fo_nd_data,ND_DATA_ARPT) end)

sasl.registerCommandHandler (Chrono_cmd_Fo_button, 0, function(phase) nd_chrono_handler(phase, fo_nd_data) end)

local function update_buttons()
    pb_set(PB.mip.terr_nd_fo,   get(ND_Fo_Terrain) == 1, false)
    
    pb_set(PB.FCU.fo_cstr, false, fo_nd_data.config.extra_data == ND_DATA_CSTR)
    pb_set(PB.FCU.fo_wpt,  false, fo_nd_data.config.extra_data == ND_DATA_WPT)
    pb_set(PB.FCU.fo_vord, false, fo_nd_data.config.extra_data == ND_DATA_VORD)
    pb_set(PB.FCU.fo_ndb,  false, fo_nd_data.config.extra_data == ND_DATA_NDB)
    pb_set(PB.FCU.fo_arpt, false, fo_nd_data.config.extra_data == ND_DATA_ARPT)
    
    pb_set(PB.FCU.fo_range_zoom, false, fo_nd_data.config.range <= ND_RANGE_ZOOM_2)
    pb_set(PB.FCU.fo_range_10, false, fo_nd_data.config.range == ND_RANGE_10)
    pb_set(PB.FCU.fo_range_20, false, fo_nd_data.config.range == ND_RANGE_20)
    pb_set(PB.FCU.fo_range_40, false, fo_nd_data.config.range == ND_RANGE_40)
    pb_set(PB.FCU.fo_range_80, false, fo_nd_data.config.range == ND_RANGE_80)
    pb_set(PB.FCU.fo_range_160, false, fo_nd_data.config.range == ND_RANGE_160)
    pb_set(PB.FCU.fo_range_320, false, fo_nd_data.config.range == ND_RANGE_320)
end

local function update_knobs()
    Set_dataref_linear_anim_nostop(ND_Fo_mode_knob, fo_nd_data.config.mode-3, -2, 3, 5)
    Set_dataref_linear_anim_nostop(ND_Fo_nav1_level, fo_nd_data.config.nav_1_selector, -1, 1, 5)
    Set_dataref_linear_anim_nostop(ND_Fo_nav2_level, fo_nd_data.config.nav_2_selector, -1, 1, 5)
end

function update()
    update_buttons()
    update_knobs()

    update_main(fo_nd_data)
end

function draw()

    draw_main(fo_nd_data)

end
