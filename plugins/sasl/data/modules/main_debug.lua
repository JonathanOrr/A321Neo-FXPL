-- THIS FILE IS FOR DEBUG AND DEVELOPMENT ONLY

-- Do NOT set any of these variables to values different from `false` or `0` for production use
-- This file SHOULD NOT be committed with any of the following option activated

-- Unexpected behaviour may happen when using this variables

-- If you set this variable to true, all the electrical buses are set of be ON even if the power
-- source is not available. This means that you immediately get all the electrical power on all
-- buses. This is useful for development. Please consider that eletrical load is no more valid if
-- you enable this option and other strange effects on electrical system may happen.
override_ELEC_always_on = false


-- If you set this variable to true, all the ADIRS are ON and IRS are ALIGNED. Button switches have
-- no effects on adirs alignment
override_ADIRS_ok = false

