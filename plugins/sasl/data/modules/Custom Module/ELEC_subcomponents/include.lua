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
-- File: ELEC_subcomponents/include.lua 
-- Short description: This file contains misc global functions for electrical
-------------------------------------------------------------------------------

function elec_const_to_dr(const)
    if const == ELEC_BUS_AC_1 then
        return AC_bus_1_pwrd
    elseif const == ELEC_BUS_AC_2 then
        return AC_bus_2_pwrd
    elseif const == ELEC_BUS_AC_ESS then
        return AC_ess_bus_pwrd
    elseif const == ELEC_BUS_AC_ESS_SHED then
        return AC_ess_shed_pwrd
    elseif const == ELEC_BUS_DC_1 then
        return DC_bus_1_pwrd
    elseif const == ELEC_BUS_DC_2 then
        return DC_bus_2_pwrd
    elseif const == ELEC_BUS_DC_ESS then
        return DC_ess_bus_pwrd
    elseif const == ELEC_BUS_DC_ESS_SHED then
        return DC_shed_ess_pwrd
    elseif const == ELEC_BUS_DC_BAT_BUS then
        return DC_bat_bus_pwrd
    elseif const == ELEC_BUS_HOT_BUS_1 then
        return HOT_bus_1_pwrd
    elseif const == ELEC_BUS_HOT_BUS_2 then
        return HOT_bus_2_pwrd
    elseif const == ELEC_BUS_GALLEY then
        return Gally_pwrd
    elseif const == ELEC_BUS_COMMERCIAL then
        return Gally_pwrd
    elseif const == ELEC_BUS_STAT_INV then
        return AC_STAT_INV_pwrd
    else
        assert(false)   -- This should never happen
    end
end

