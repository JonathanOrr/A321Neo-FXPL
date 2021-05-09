-- THIS FILE IS FOR DEBUG AND DEVELOPMENT ONLY

-- Do NOT set any of these variables to values different from `false` or `0` for production use
-- This file SHOULD NOT be committed with any of the following option activated

-- Unexpected behaviour may happen when using this variables

-- If you set this variable to true, all the electrical buses are set of be ON even if the power
-- source is not available. This means that you immediately get all the electrical power on all
-- buses. This is useful for development. Please consider that eletrical load is no more valid if
-- you enable this option and other strange effects on electrical system may happen.
override_ELEC_always_on = false


--If you set this variable to true, MCDU automatically generates a Look Up Table (LUT) for all airports.
-- This considerably increases performance on usage of MCDU but significantly slows down load times.
override_MCDU_dontcreateairportlut = true


-- If you set this variable to true, all the ADIRS are ON and IRS are ALIGNED. Button switches have
-- no effects on adirs alignment
override_ADIRS_ok = false

-- The following variable allows you to disable avionicsbay. WARNING: many features of ND/OANS/MCDU
-- will now be available.
disable_avionicsbay = false

-- If you set the following variable to a number different than 0, the corresponding ecam page is
-- automatically selected at reboot
-- 1ENG, 2BLEED, 3PRESS, 4ELEC, 5HYD, 6FUEL, 7APU, 8COND, 9DOOR, 10WHEEL, 11F/CTL, 12STS, 13 CRUISE
local ecam_force_page = 0


-- The following flag enables the performance measuring of each component. It is possible to
-- visualize it in the debug window
debug_performance_measure = false

-- Enable the debug for tcas (directly on ND)
debug_tcas_system = false

--
--
-- Do not touch after this line
--
--

if ecam_force_page ~= 0 then
    set(Ecam_current_status, 1)
    set(Ecam_current_page, ecam_force_page)
end
