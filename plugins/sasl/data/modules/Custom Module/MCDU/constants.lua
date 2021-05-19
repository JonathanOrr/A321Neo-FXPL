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
-- File: MCDU/constants.lua 
-- Short description: MCDU constants
-------------------------------------------------------------------------------


--define the const size, align and row.

MCDU_SMALL = 1
MCDU_LARGE = 2

MCDU_LEFT  = 1
MCDU_RIGHT  = 2

MCDU_DIV_SIZE = {MCDU_SMALL, MCDU_LARGE}
MCDU_DIV_ALIGN = {MCDU_LEFT, MCDU_RIGHT}
MCDU_DIV_ROW = {1,2,3,4,5,6}

--font size
MCDU_DISP_TEXT_SIZE =
{
    [MCDU_SMALL] = 25,
    [MCDU_LARGE] = 37
}

--alignment
MCDU_DISP_TEXT_ALIGN =
{
    [MCDU_LEFT] = TEXT_ALIGN_LEFT,
    [MCDU_RIGHT] = TEXT_ALIGN_RIGHT,
}

-- alphanumeric & decimal FMC entry keys
MCDU_ENTRY_KEYS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "overfly", "slash", "space"}
MCDU_ENTRY_PAGES = {"dir", "prog", "perf", "init", "data", "f-pln", "rad_nav", "fuel_pred", "sec_f-pln", "atc_comm", "mcdu_menu", "air_port"}
MCDU_ENTRY_SIDES = {"L1", "L2", "L3", "L4", "L5", "L6", "R1", "R2", "R3", "R4", "R5", "R6", "slew_up", "slew_down", "slew_left", "slew_right"}

