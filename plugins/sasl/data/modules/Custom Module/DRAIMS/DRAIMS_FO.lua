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
-- File: DRAIMS_FO.lua 
-- Short description: Radio panel (v2) for f/o
-------------------------------------------------------------------------------

position = {2030, 2298, 600, 400}
size = {600, 400}

include("DRAIMS/DRAIMS_handlers.lua")
include("DRAIMS/pages.lua")
include("DRAIMS/pages_dynamics.lua")
include("DRAIMS/pages_logic.lua")
include("DRAIMS/constants.lua")


local fo_data = {
    id = DRAIMS_ID_FO,
    current_page = PAGE_MENU_SATCOM,
    vhf_selected_line = 1,
    scratchpad_input = -1,
    info_message = {"", "", ""}
}

draims_init_handlers(fo_data)

function draw()
    perf_measure_start("DRAIMS_FO:draw()")

    draw_page_static(fo_data)
    draw_page_dynamic(fo_data)

    perf_measure_stop("DRAIMS_FO:draw()")
end

function update()
    update_scratchpad(fo_data)
end
