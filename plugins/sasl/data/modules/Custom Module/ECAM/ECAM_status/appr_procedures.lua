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

include('ECAM/ECAM_status/logic_checks.lua')

local appr_proc_messages = {

    -------------HYDRAULICS, FCOM 5332

    {
        text = "DUAL HYD LO PR", --fcom 5395
        action = nil,
        color = ECAM_RED,
        indent_lvl = 0,
        cond = function()
            return Y_is_low_pressure() and B_is_low_pressure() or
            G_is_low_pressure() and B_is_low_pressure() or
            G_is_low_pressure() and Y_is_low_pressure()
        end
    },

    {
        text = "A/THR",
        action = "OFF",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return G_is_low_pressure() and B_is_low_pressure()
            and not G_is_low_level() and not B_is_low_level()
        end
    },

    {
        text = "IF BLUE OVHT OUT:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0,
        cond = function()
            return blue_pump_low_pr_or_ovht()
        end
    },
    {
        text = "BLUE ELEC PUMP",
        action = "AUTO",
        color = ECAM_BLUE,
        indent_lvl = 1,
        cond = function()
            return blue_pump_low_pr_or_ovht() or
            get(FAILURE_HYD_B_low_air) == 1
        end
    },
    {
        text = "GREEN ENG 1 PUMP",
        action = "ON",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return 
            get(FAILURE_HYD_G_low_air) == 1 or
            get(FAILURE_HYD_G_R_overheat) == 1
        end
    },


    {
        text = "IF YELLOW OVHT OUT:", --fcom 5365
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0,
        cond = function()
            return get(FAILURE_HYD_Y_pump) == 1
        end
    },
    {
        text = "YELLOW ENG 2 PUMP",
        action = "ON",
        color = ECAM_BLUE,
        indent_lvl = 1,
        cond = function()
            return get(FAILURE_HYD_Y_pump) == 1 or
            get(FAILURE_HYD_Y_low_air) == 1
        end
    },
    {
        text = "PTU",
        action = "AUTO",
        color = ECAM_BLUE,
        indent_lvl = 1,
        cond = function()
            return get(FAILURE_HYD_Y_pump) == 1
        end
    },

    ----------------------------------------

    {
        text = "FOR LDG",
        action = "USE FLAP 3",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return (get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
                or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
                or get(FBW_total_control_law) == FBW_DIRECT_LAW or
                elec_in_emer_config() or
                (get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW)
                or get(FBW_total_control_law) == FBW_DIRECT_LAW or
                (get(FAILURE_FCTL_SEC_1) == 1 and
                get(FAILURE_FCTL_SEC_2) == 1) or
                stabliser_is_jammed() or
                Y_is_low_pressure() and B_is_low_pressure() and --B+Y LO PR
                not Y_is_low_level() and not B_is_low_level() or
                G_is_low_pressure() and B_is_low_pressure()
            and not G_is_low_level() and not B_is_low_level() or
            G_is_low_pressure() and Y_is_low_pressure() 
            and not G_is_low_level() and not Y_is_low_level() or
            dual_adr_failure() or
            adr_disagrees_on_stuff()
        )
        and not all_engine_failure()
        and not flaps_slats_fault_in_config_0()
        end
    },
    {
        text = "FOR LDG",
        action = "USE FLAP 2",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return all_engine_failure() and not flaps_slats_fault_in_config_0()
        end
    },
    {
        text = "FOR LDG",
        action = "USE FLAP 1",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return flaps_slats_fault_in_config_0()
        end
    },
    {
        text = "CTR TK PUMPS",
        action = "OFF",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return flaps_slats_fault_in_config_0()
        end
    },
    {
        text = "GPWS FLAP MODE",
        action = "OFF",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return
            (not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled) 
            and get(Flaps_handle_position) < 4 or
            flaps_slats_fault_in_config_0() or
            G_is_low_pressure() and Y_is_low_pressure() 
            and not G_is_low_level() and not Y_is_low_level()
        end
    },
    {
        text = "GPWS LDG FLAP 3",
        action = "ON",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
                or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
                or get(FBW_total_control_law) == FBW_DIRECT_LAW or
                (get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW)
                or get(FBW_total_control_law) == FBW_DIRECT_LAW or
                (not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled)
            and get(Flaps_handle_position) == 4 or
            stabliser_is_jammed() or
            Y_is_low_pressure() and B_is_low_pressure() and --B+Y LO PR
                not Y_is_low_level() and not B_is_low_level() or
                G_is_low_pressure() and B_is_low_pressure()
            and not G_is_low_level() and not B_is_low_level() or
            dual_adr_failure() or
            adr_disagrees_on_stuff()
        end
    },

    ------------------STABLISER JAM, FCOM 5250
    {
        text = ".IF MAN TRIM NOT AVAIL:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0,
        cond = function()
            return 
            stabliser_is_jammed()
        end
    },
    {
        text = ".WHEN CONF3 AND VAPP:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 1,
        cond = function()
            return 
            stabliser_is_jammed() or
            G_is_low_pressure() and Y_is_low_pressure() 
            and not G_is_low_level() and not Y_is_low_level()
        end
    },
    {
        text = "L/G",
        action = "DOWN",
        color = ECAM_BLUE,
        indent_lvl = 2,
        cond = function()
            return 
            stabliser_is_jammed() 
        end
    },

    -----------------------------------
    {
        text = "APPR SPD",
        action = "VREF+10KT",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return vref_10() and not vref_10_140() and not vref_60() and not vref_50() and not vref_25() and not vref_15()
        end
    },
    {
        text = "APPR SPD",
        action = "VREF+60KT",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return vref_60()
        end
    },
    {
        text = "MAN PITCH TRIM",
        action = "USE",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FBW_total_control_law) == FBW_DIRECT_LAW 
            and not stabliser_is_jammed()
        end
    },

    {
        text = "APPR SPD",
        action = "VREF+10/140KT",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return vref_10_140() and not vref_60() and not vref_50() and not vref_25() and not vref_15()
        end
    },
    {
        text = "APPR SPD",
        action = "VREF+15",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return   vref_15() and not vref_60() and not vref_50() and not vref_25() 
        end
    },
    {
        text = "APPR SPD",
        action = "VREF+25",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return    vref_25() and not vref_60() and not vref_50()
        end
    },

    {
        text = "LDG DIST PROC",
        action = "APPLY",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return (get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
                or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
                or get(FBW_total_control_law) == FBW_DIRECT_LAW or
                elec_in_emer_config()
                or get(FBW_total_control_law) == FBW_DIRECT_LAW or
                (not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled) or
                (get(FAILURE_FCTL_SEC_1) == 1 and
                get(FAILURE_FCTL_SEC_2) == 1) or
                spdbrk_2_or_3_and_4_fault() or
                spoilers_are_fucked() or
                stabliser_is_jammed() or
                blue_pump_low_pr_or_ovht() or
                get(FAILURE_HYD_B_low_air) == 1 or
                get(FAILURE_HYD_G_pump) == 1 or
                get(FAILURE_HYD_G_low_air) == 1 or
                get(Hydraulic_G_qty) < 0.18 or
                get(FAILURE_HYD_G_R_overheat) == 1 or
                get(FAILURE_HYD_Y_pump) == 1 or
                get(FAILURE_HYD_Y_low_air) == 1 or
                get(Hydraulic_Y_qty) < 0.18 or
                Y_is_low_pressure() and B_is_low_pressure() or --B+Y LO PR
                G_is_low_pressure() and B_is_low_pressure() or
                G_is_low_pressure() and Y_is_low_pressure() or
                dual_adr_failure() or
                adr_disagrees_on_stuff() or
                is_bleed_fault() or
                get(FAILURE_BLEED_APU_LEAK) == 1 or
                get(AC_bus_1_pwrd) == 0 or
                get(DC_ess_bus_pwrd) == 0 or
                get(DC_shed_ess_pwrd) == 0 or
                engine_shuts_down() or
                get(Brakes_mode) == 3 and get(Brakes_accumulator) > 1 or
            get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_Y_low_air) == 1 or
            get(FAILURE_GEAR_AUTOBRAKES) == 1 or
            get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
            dc_in_emergency_config() or
            elec_in_emer_config() or
            get(FBW_total_control_law) == FBW_DIRECT_LAW
                or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
                or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
                or get(Nosewheel_Steering_working) == 0
        )
        and 
        not all_engine_failure()
        end
    },
    {
        text = "L/G",
        action = "GRVTY EXTN",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FAILURE_gear) == 2 or   -- TODO Replace dataref
            get(FAILURE_HYD_G_low_air) == 1 or
            get(Hydraulic_G_qty) < 0.18 or
            get(FAILURE_HYD_G_R_overheat) == 1 or
            Y_is_low_pressure() and B_is_low_pressure() or --B+Y LO PR
                G_is_low_pressure() and B_is_low_pressure() or
                G_is_low_pressure() and Y_is_low_pressure() 
                and not G_is_low_level() and not Y_is_low_level() or
                dual_adr_failure() or
                triple_adr_failure()
        end
    },

    ------------- BELOW IS A GROUP
    {
        text = ".AT 300FT AGL:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0,
        cond = function()
            return flaps_slats_fault_in_config_0()  
        end
    },
    {
        text = "TARGET SPD",
        action = "VREF+50KT",
        color = ECAM_BLUE,
        indent_lvl = 1,
        cond = function()
            return vref_50() and not vref_60()
        end
    },
------------------------


    ----------------------------------------------------------------------------------------------------
    -- START - FLAPS FAULTgroup
    ----------------------------------------------------------------------------------------------------
    
    {
        text = "S/F JAMMED PROC",
        action = "APPLY",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled 
        end
    },
    {
        text = "FOR LDG",
        action = "USE FLAP 3",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return (not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled) 
            and get(Flaps_handle_position) < 4
        end
    },
    {
        text = "FLAPS",
        action = "KEEP CONF FULL",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return (not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled) 
            and get(Flaps_handle_position) == 4
        end
    },

    {
        text = "APPR SPD REFER TO PRO-ABN F-",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return (not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled) 
        end
    },
    
    {
        text = "CTL FLAPS/SLATS FAULT/LOCKED",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return (not FCTL.SLAT_FLAP.STAT.SLAT.controlled or not FCTL.SLAT_FLAP.STAT.FLAP.controlled) 
        end
    },

--------------------FUEL TANKS, FCOM 5307
}

function ECAM_status_get_appr_procedures()
    local MAX_LENGTH = 28

    local messages = {}

    for l,x in pairs(appr_proc_messages) do
        if x.cond() then
            local text = "  "
            if x.text:sub(1,1) ~= "." then
                text = text .. "-"
            end
            for i=1,x.indent_lvl do
                text = text .. "  "
            end
            
            text = text .. x.text
            if x.action then
                local nr_dots = MAX_LENGTH - #text - #x.action
                if nr_dots <= 0 then
                    logWarning("ECAM Status/APPR_PROC - overflow (dots) in message: " .. text)
                end
                for i=1,nr_dots do
                    text = text .. "."
                end
                
                text = text .. x.action
            end
            if #x.text > MAX_LENGTH then
                logWarning("ECAM Status/APPR_PROC - overflow in message: " .. text)
            end
            table.insert(messages, {text=text, color=x.color})
        end
    end

    return messages
end

