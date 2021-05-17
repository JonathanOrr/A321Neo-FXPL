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
-- File: CAPT_MCDU.lua 
-- Short description: Captain MCDU
-------------------------------------------------------------------------------

position = {1020, 1666, 560, 530}
size = {560, 530}
fbo = true

include('MCDU/common_MCDU.lua')

local mcdu_data = {}
init_data(mcdu_data, 1)

function draw()
    perf_measure_start("CAPT_MCDU:draw()")
    --draw backlight--

    common_draw(mcdu_data)

    perf_measure_stop("CAPT_MCDU:draw()")
end

function update()
    common_update(mcdu_data)
end

