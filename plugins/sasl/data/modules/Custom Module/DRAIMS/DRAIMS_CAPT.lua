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
-- File: DRAIMS_CAPT.lua 
-- Short description: Radio panel (v2) for captain
-------------------------------------------------------------------------------

position = {2030, 2726, 600, 400}
size = {600, 400}

include("DRAIMS/DRAIMS_handlers.lua")
include("DRAIMS/pages.lua")
include("DRAIMS/pages_dynamics.lua")
include("DRAIMS/pages_logic.lua")
include("DRAIMS/constants.lua")


local capt_data = {
    id = DRAIMS_ID_CAPT,
    current_page = PAGE_NAV_ADF,
    vhf_selected_line = 1,
    scratchpad_input = -1,
    info_message = {"", "", ""},
    sqwk_select = false,
    nav_vor_selected_line = 1,   -- 1: vor 1 freq, 2 vor 2 freq, 3 vor 1 crs, 4 vor 2 crs
    nav_adf_selected_line = 1,
}

draims_init_handlers(capt_data)

function draw()
    perf_measure_start("DRAIMS_CAPT:draw()")

    draw_page_static(capt_data)
    draw_page_dynamic(capt_data)
    
    perf_measure_stop("DRAIMS_CAPT:draw()")
end

function update()
    update_scratchpad(capt_data)
    update_lights()
    update_vhf_data()
    update_sqkw_timeout()
end
