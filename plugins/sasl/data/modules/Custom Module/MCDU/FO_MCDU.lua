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
-- File: FO_MCDU.lua 
-- Short description: F/O MCDU
-------------------------------------------------------------------------------

position = {1610, 1666, 560, 530}
size = {560, 530}
fbo = true

include('MCDU/common_MCDU.lua')

local mcdu_data = {}
init_data(mcdu_data, 2)
init_mcdu_handlers(mcdu_data, "_2")

MCDU.fo_side_data = mcdu_data

function draw()
    perf_measure_start("FO_MCDU:draw()")
    --draw backlight--
    common_draw(mcdu_data)

    perf_measure_stop("FO_MCDU:draw()")
end

function update()
    common_update(mcdu_data)
end

