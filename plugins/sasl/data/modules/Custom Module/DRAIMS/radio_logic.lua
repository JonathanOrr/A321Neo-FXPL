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
-- File: radio_logic.lua 
-- Short description: Helper functions for radio-related stuffs
-------------------------------------------------------------------------------

local vhf_datarefs = {
    {
        swap = globalProperty("sim/cockpit2/radios/actuators/com1_right_is_selected"),
        curr_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com1_frequency_Mhz"),
        curr_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com1_frequency_khz"),
        stby_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com1_standby_frequency_Mhz"),
        stby_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com1_standby_frequency_khz")
    },
    {
        swap = globalProperty("sim/cockpit2/radios/actuators/com2_right_is_selected"),
        curr_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com2_frequency_Mhz"),
        curr_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com2_frequency_khz"),
        stby_freq_Mhz = globalProperty("sim/cockpit2/radios/actuators/com2_standby_frequency_Mhz"),
        stby_freq_khz = globalProperty("sim/cockpit2/radios/actuators/com2_standby_frequency_khz")
    },
    {
        swap = DRAIMS_vhf3_swap,
        curr_freq_Mhz = DRAIMS_vhf3_curr_freq_Mhz,
        curr_freq_khz = DRAIMS_vhf3_curr_freq_khz,
        stby_freq_Mhz = DRAIMS_vhf3_stby_freq_Mhz,
        stby_freq_khz = DRAIMS_vhf3_stby_freq_khz
    }
}

-------------------------------------------------------------------------------
-- VHF
-------------------------------------------------------------------------------

function radio_vhf_get_freq(which_one, stby)
    stby = stby or false
    if stby then
        return get(vhf_datarefs[which_one].stby_freq_Mhz) + get(vhf_datarefs[which_one].stby_freq_khz)/1000
    else
        return get(vhf_datarefs[which_one].curr_freq_Mhz) + get(vhf_datarefs[which_one].curr_freq_khz)/1000
    end
end

function radio_vhf_set_freq(which_one, stby, freq)
    stby = stby or false

    local Mhz = math.floor(freq)
    local khz = math.floor((freq-math.floor(freq))*1000)

    if stby then
        set(vhf_datarefs[which_one].stby_freq_Mhz, Mhz)
        set(vhf_datarefs[which_one].stby_freq_khz, khz)
    else
        set(vhf_datarefs[which_one].curr_freq_Mhz, Mhz)
        set(vhf_datarefs[which_one].curr_freq_khz, khz)
    end
end

function radio_vhf_swap_freq(which_one)
    set(vhf_datarefs[which_one].swap, 1-get(vhf_datarefs[which_one].swap))
    if which_one == 3 then
        local temp_Mhz = get(vhf_datarefs[3].curr_freq_Mhz)
        local temp_khz = get(vhf_datarefs[3].curr_freq_khz)
        set(vhf_datarefs[3].curr_freq_Mhz, get(vhf_datarefs[3].stby_freq_Mhz))
        set(vhf_datarefs[3].curr_freq_khz, get(vhf_datarefs[3].stby_freq_khz))
        set(vhf_datarefs[3].stby_freq_Mhz, temp_Mhz)
        set(vhf_datarefs[3].stby_freq_khz, temp_khz)
    end
end

function radio_is_vhf_working(which_one)
    if which_one == 1 then
        return get(DC_ess_bus_pwrd) == 1 and get(FAILURE_RADIO_VHF_1) == 0
    else
        return get(DC_bus_2_pwrd) == 1 and get(FAILURE_RADIO_VHF_2) == 0
    end
end


-------------------------------------------------------------------------------
-- VOR
-------------------------------------------------------------------------------

function radio_vor_get_freq(which_one, stby)
    stby = stby or false
    if stby then
        return get(DRAIMS_vor_stby_freq[which_one])
    else
        return get(DRAIMS_vor_freq[which_one])
    end
end

function radio_vor_set_freq(which_one, stby, freq)
    assert(which_one ~= nil)
    assert(freq ~= nil)
    stby = stby or false

    if stby then
        set(DRAIMS_vor_stby_freq[which_one], freq)
    else
        set(DRAIMS_vor_freq[which_one], freq)
    end
end

function radio_vor_swap_freq()
    local temp = get(DRAIMS_vor_stby_freq[which_one])
    set(DRAIMS_vor_stby_freq[which_one], get(DRAIMS_vor1_freq))
    set(DRAIMS_vor_freq[which_one], temp)
end

function radio_vor_get_crs(which_one)
    return get(DRAIMS_vor_crs[which_one])
end

function radio_vor_set_crs(which_one, crs)
    set(DRAIMS_vor_crs[which_one], math.floor(crs % 360))
end

-------------------------------------------------------------------------------
-- ILS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- ADF
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DME
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- radio_is_*_working functions
-------------------------------------------------------------------------------

function radio_is_vor_working(which_one)
    if which_one == 1 then
        return get(AC_ess_bus_pwrd) == 1 and get(FAILURE_RADIO_VOR_1) == 0
    else
        return get(AC_bus_2_pwrd) == 1 and get(FAILURE_RADIO_VOR_2) == 0
    end
end

function radio_is_ils_working(which_one)
    if which_one == 1 then
        return get(AC_ess_bus_pwrd) == 1 and get(FAILURE_RADIO_ILS_1) == 0
    else
        return get(AC_bus_2_pwrd) == 1 and get(FAILURE_RADIO_ILS_2) == 0
    end
end

function radio_is_adf_working(which_one)
    if which_one == 1 then
        return get(AC_ess_shed_pwrd) == 1 and get(FAILURE_RADIO_ADF_1) == 0
    else
        return get(AC_bus_2_pwrd) == 1 and get(FAILURE_RADIO_ADF_2) == 0
    end
end

function radio_is_dme_working(which_one)
    if which_one == 1 then
        return get(AC_ess_shed_pwrd) == 1 and get(FAILURE_RADIO_DME_1) == 0
    else
        return get(AC_bus_2_pwrd) == 1 and get(FAILURE_RADIO_DME_2) == 0
    end
end

