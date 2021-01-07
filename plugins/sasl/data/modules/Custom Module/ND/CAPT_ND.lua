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

include('constants.lua')
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

    draw_main(capt_nd_data)

end

sasl.registerCommandHandler (ND_Capt_mode_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.mode = math.min(ND_MODE_PLAN,capt_nd_data.config.mode + 1) end end)
sasl.registerCommandHandler (ND_Capt_mode_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.mode = math.max(ND_MODE_ILS, capt_nd_data.config.mode - 1) end end)
sasl.registerCommandHandler (ND_Capt_range_cmd_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.range = math.min(ND_RANGE_320,capt_nd_data.config.range + 1) end end)
sasl.registerCommandHandler (ND_Capt_range_cmd_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.range = math.max(ND_RANGE_ZOOM_02, capt_nd_data.config.range - 1) end end)

sasl.registerCommandHandler (ND_Capt_nav1_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_1_selector = math.max(-1, capt_nd_data.config.nav_1_selector - 1) end end)
sasl.registerCommandHandler (ND_Capt_nav1_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_1_selector = math.min(1,capt_nd_data.config.nav_1_selector + 1) end end)
sasl.registerCommandHandler (ND_Capt_nav2_cmd_left, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_2_selector = math.max(-1, capt_nd_data.config.nav_2_selector - 1) end end)
sasl.registerCommandHandler (ND_Capt_nav2_cmd_right, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.nav_2_selector = math.min(1,capt_nd_data.config.nav_2_selector + 1) end end)

sasl.registerCommandHandler (ND_Capt_cmd_cstr, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.is_active_cstr = not capt_nd_data.config.is_active_cstr end end)
sasl.registerCommandHandler (ND_Capt_cmd_wpt, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.is_active_wpt = not capt_nd_data.config.is_active_wpt end end)
sasl.registerCommandHandler (ND_Capt_cmd_vord, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.is_active_vord = not capt_nd_data.config.is_active_vord end end)
sasl.registerCommandHandler (ND_Capt_cmd_ndb, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.is_active_ndb = not capt_nd_data.config.is_active_ndb end end)
sasl.registerCommandHandler (ND_Capt_cmd_arpt, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_nd_data.config.is_active_arpt = not capt_nd_data.config.is_active_arpt end end)

function chrono_handler(phase)
    if phase == SASL_COMMAND_BEGIN then
        if capt_nd_data.chrono.is_active then
            if capt_nd_data.chrono.is_running then
                capt_nd_data.chrono.is_running = false
                capt_nd_data.chrono.elapsed_time = get(TIME) - capt_nd_data.chrono.start_time
            else
                capt_nd_data.chrono.is_active = false
            end
        else
            capt_nd_data.chrono.is_active = true
            capt_nd_data.chrono.is_running = true
            capt_nd_data.chrono.start_time = get(TIME)
        end 
    end
end

sasl.registerCommandHandler (Chrono_cmd_capt_button, 0, chrono_handler)

sasl.registerCommandHandler (ND_Capt_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Capt_Terrain, 1 - get(ND_Capt_Terrain)) end end)
sasl.registerCommandHandler (ND_Fo_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Fo_Terrain, 1 - get(ND_Fo_Terrain)) end end)

local function update_buttons()
    pb_set(PB.mip.terr_nd_capt, get(ND_Capt_Terrain) == 1, false)
    pb_set(PB.mip.terr_nd_fo,   get(ND_Fo_Terrain) == 1, false)
    
    pb_set(PB.FCU.capt_cstr, false, capt_nd_data.config.is_active_cstr)
    pb_set(PB.FCU.capt_wpt,  false, capt_nd_data.config.is_active_wpt)
    pb_set(PB.FCU.capt_vord, false, capt_nd_data.config.is_active_vord)
    pb_set(PB.FCU.capt_ndb,  false, capt_nd_data.config.is_active_ndb)
    pb_set(PB.FCU.capt_arpt, false, capt_nd_data.config.is_active_arpt)
end

local function update_knobs()
    Set_dataref_linear_anim_nostop(ND_Capt_mode_knob, capt_nd_data.config.mode-3, -2, 3, 5)
    Set_dataref_linear_anim_nostop(ND_Capt_nav1_level, capt_nd_data.config.nav_1_selector, -1, 1, 5)
    Set_dataref_linear_anim_nostop(ND_Capt_nav2_level, capt_nd_data.config.nav_2_selector, -1, 1, 5)
    
    set(ND_Capt_range_knob, math.max(ND_RANGE_ZOOM_2, capt_nd_data.config.range)-3)
end

function update()

    update_buttons()
    update_knobs()

    update_main(capt_nd_data)
end
