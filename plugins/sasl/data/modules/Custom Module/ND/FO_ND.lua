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

position = {get(Fo_nd_position, 1), get(Fo_nd_position, 2), get(Fo_nd_position, 3), get(Fo_nd_position, 4)}
size = {900, 900}
fbo = true

include('ND/common_ND.lua')

nd_data = new_dataset(ND_FO)
ND_all_data[ND_FO] = nd_data

sasl.registerCommandHandler (ND_Fo_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Fo_Terrain, 1 - get(ND_Fo_Terrain)) end end)

sasl.registerCommandHandler (ND_Fo_mode_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.mode = math.min(ND_MODE_PLAN,nd_data.config.mode + 1) end end)
sasl.registerCommandHandler (ND_Fo_mode_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.mode = math.max(ND_MODE_ILS, nd_data.config.mode - 1) end end)
sasl.registerCommandHandler (ND_Fo_range_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then
    nd_data.config.range = math.min(ND_RANGE_320,nd_data.config.range + 1)
    set(ND_Fo_range_knob, (get(ND_Fo_range_knob) + 1) % 11)
end end)
sasl.registerCommandHandler (ND_Fo_range_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then
    nd_data.config.range = math.max(ND_RANGE_ZOOM_02, nd_data.config.range - 1)
    set(ND_Fo_range_knob, (get(ND_Fo_range_knob) - 1) % 11)
end end)

sasl.registerCommandHandler (ND_Fo_nav1_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_1_selector = math.max(-1, nd_data.config.nav_1_selector - 1) end end)
sasl.registerCommandHandler (ND_Fo_nav1_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_1_selector = math.min(1,nd_data.config.nav_1_selector + 1) end end)
sasl.registerCommandHandler (ND_Fo_nav2_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_2_selector = math.max(-1, nd_data.config.nav_2_selector - 1) end end)
sasl.registerCommandHandler (ND_Fo_nav2_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then nd_data.config.nav_2_selector = math.min(1,nd_data.config.nav_2_selector + 1) end end)

sasl.registerCommandHandler (ND_Fo_cmd_cstr, 0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_CSTR) end)
sasl.registerCommandHandler (ND_Fo_cmd_wpt,  0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_WPT) end)
sasl.registerCommandHandler (ND_Fo_cmd_vord, 0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_VORD) end)
sasl.registerCommandHandler (ND_Fo_cmd_ndb,  0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_NDB) end)
sasl.registerCommandHandler (ND_Fo_cmd_arpt, 0, function(phase) nd_pb_handler(phase,nd_data,ND_DATA_ARPT) end)

sasl.registerCommandHandler (Chrono_cmd_Fo_button, 0, function(phase) nd_chrono_handler(phase, nd_data) end)

sasl.registerCommandHandler (Fo_ND_picture_brightness_up, 0, function(phase) Knob_handler_up_float(phase, ND_Fo_picture_brightness, 0, 1, 0.5) end)
sasl.registerCommandHandler (Fo_ND_picture_brightness_dn, 0, function(phase) Knob_handler_down_float(phase, ND_Fo_picture_brightness, 0, 1, 0.5) end)

local function update_buttons()
    pb_set(PB.mip.terr_nd_fo,   get(ND_Fo_Terrain) == 1, false)
    
    pb_set(PB.FCU.fo_cstr, false, nd_data.config.extra_data == ND_DATA_CSTR)
    pb_set(PB.FCU.fo_wpt,  false, nd_data.config.extra_data == ND_DATA_WPT)
    pb_set(PB.FCU.fo_vord, false, nd_data.config.extra_data == ND_DATA_VORD)
    pb_set(PB.FCU.fo_ndb,  false, nd_data.config.extra_data == ND_DATA_NDB)
    pb_set(PB.FCU.fo_arpt, false, nd_data.config.extra_data == ND_DATA_ARPT)
    
    pb_set(PB.FCU.fo_range_zoom, false, nd_data.config.range <= ND_RANGE_ZOOM_2)
    pb_set(PB.FCU.fo_range_10, false, nd_data.config.range == ND_RANGE_10)
    pb_set(PB.FCU.fo_range_20, false, nd_data.config.range == ND_RANGE_20)
    pb_set(PB.FCU.fo_range_40, false, nd_data.config.range == ND_RANGE_40)
    pb_set(PB.FCU.fo_range_80, false, nd_data.config.range == ND_RANGE_80)
    pb_set(PB.FCU.fo_range_160, false, nd_data.config.range == ND_RANGE_160)
    pb_set(PB.FCU.fo_range_320, false, nd_data.config.range == ND_RANGE_320)
end

local function update_knobs()
    Set_dataref_linear_anim_nostop(ND_Fo_mode_knob, nd_data.config.mode-3, -2, 3, 20)
    Set_dataref_linear_anim_nostop(ND_Fo_nav1_level, nd_data.config.nav_1_selector, -1, 1, 20)
    Set_dataref_linear_anim_nostop(ND_Fo_nav2_level, nd_data.config.nav_2_selector, -1, 1, 20)
    
    nd_data.terrain.brightness = get(ND_Fo_picture_brightness)
end

local function update_disable_click()
    if nd_data.config.range < ND_RANGE_10 then
        set(Fo_PFD_disable_click, get(Fo_pfd_displaying_status) == DMC_ND_FO and 1 or 0)
        set(Fo_ND_disable_click, get(Fo_nd_displaying_status) == DMC_ND_FO and 1 or 0)
    else
        set(Fo_PFD_disable_click, 0)
        set(Fo_ND_disable_click,  0)
    end
end

function update()

    position = {get(Fo_nd_position, 1), get(Fo_nd_position, 2), get(Fo_nd_position, 3), get(Fo_nd_position, 4)}

    update_buttons()
    update_knobs()
    update_disable_click()

    update_main(nd_data)
end

function draw()

    sasl.gl.setRenderTarget(FO_ND_popup_texture, true)
    draw_main(nd_data)
    sasl.gl.restoreRenderTarget()

    sasl.gl.drawTexture(FO_ND_popup_texture, 0, 0, 900, 900, {1,1,1})

end
