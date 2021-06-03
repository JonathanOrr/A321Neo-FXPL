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

local function is_bleed_fault()
    return (get(L_bleed_press) > 57 
    or get(L_bleed_temp) > 270) 
    or (get(R_bleed_press) > 57 or get(R_bleed_temp) > 270) 
    or get(FAILURE_BLEED_ENG_1_LEAK) == 1 
    or get(FAILURE_BLEED_ENG_2_LEAK) == 1 
    or get(FAILURE_BLEED_WING_L_LEAK) == 1
    or get(FAILURE_BLEED_WING_R_LEAK) == 1 
    or get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1
end

local function door_open_in_flight()
    return (get(Door_1_l_ratio) > 0 or
    get(Door_1_r_ratio) > 0 or
    get(Door_2_l_ratio) > 0 or
    get(Door_2_r_ratio) > 0 or
    get(Door_3_l_ratio) > 0 or
    get(Door_3_r_ratio) > 0 or
    get(Overwing_exit_1_l_ratio) > 0 or
    get(Overwing_exit_1_r_ratio) > 0 or
    get(Overwing_exit_2_l_ratio) > 0 or
    get(Overwing_exit_2_r_ratio) > 0 or
    get(Cargo_1_ratio) > 0 or
    get(Cargo_2_ratio) > 0) and
    get(All_on_ground) == 0
end

local function dc_in_emergency_config()
    return get(DC_ess_bus_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 and get(DC_bus_1_pwrd) == 0
end

local function elec_in_emer_config()
    local condition =  ((get(Gen_1_pwr) == 0 or get(Gen_1_line_active) == 1) and get(Gen_2_pwr) ==0 and get(Gen_APU_pwr) == 0 and get(Gen_EXT_pwr) == 0)
        condition = condition and not (get(Eng_is_failed, 1) and get(Eng_is_failed, 2))
    return condition
end

local function engine_shuts_down()
    return (get(Engine_1_master_switch) == 0 and get(EWD_flight_phase) >= PHASE_ABOVE_80_KTS and get(EWD_flight_phase) <= PHASE_TOUCHDOWN)
    or ((get(EWD_flight_phase) < 3 or get(EWD_flight_phase) > 8) and get(Fire_pb_ENG1_status) == 1)
end

local function spdbrk_3_and_4_fault() --fcom 5231
    return get(FAILURE_FCTL_LSPOIL_3) == 1 and get(FAILURE_FCTL_LSPOIL_4) == 1 or 
    get(FAILURE_FCTL_RSPOIL_3) == 1 and get(FAILURE_FCTL_RSPOIL_4) == 1
end

local function Y_is_low_pressure()
    return get(Hydraulic_Y_press) <= 1450
end

local function G_is_low_pressure()
    return get(Hydraulic_G_press) <= 1450
end

local function B_is_low_pressure()
    return get(Hydraulic_B_press) <= 1450
end


local function adr_disagrees_on_stuff()
    return adirs_pfds_disagree_on_hdg() or adirs_pfds_disagree_on_alt() or adirs_pfds_disagree_on_ias() or adirs_pfds_disagree_on_att()
end

local function spoilers_are_fucked()
    return
    get(FAILURE_FCTL_LSPOIL_1) == 1 or
    get(FAILURE_FCTL_LSPOIL_2) == 1 or
    get(FAILURE_FCTL_LSPOIL_3) == 1 or
    get(FAILURE_FCTL_LSPOIL_4) == 1 or
    get(FAILURE_FCTL_LSPOIL_5) == 1 or
    get(FAILURE_FCTL_RSPOIL_1) == 1 or
    get(FAILURE_FCTL_RSPOIL_2) == 1 or
    get(FAILURE_FCTL_RSPOIL_3) == 1 or
    get(FAILURE_FCTL_RSPOIL_4) == 1 or
    get(FAILURE_FCTL_RSPOIL_5) == 1
end

local function one_or_more_spoiler_is_fully_extended_in_speedbrake_fault() --fcom 5231
    return 
    (get(Left_spoiler_1) >= 25 or 
    get(Left_spoiler_2) >= 25 or 
    get(Left_spoiler_3) >= 25 or 
    get(Left_spoiler_4) >= 25 or 
    get(Left_spoiler_5) >= 25 or 
    get(Right_spoiler_1) >= 25 or 
    get(Right_spoiler_2) >= 25 or 
    get(Right_spoiler_3) >= 25 or 
    get(Right_spoiler_4) >= 25 or 
    get(Right_spoiler_5) >= 25) and
    spoilers_are_fucked()
end

local function stabliser_is_jammed()
    return get(FAILURE_FCTL_THS_MECH) == 1
end

local function fwc_1_and_2_fault()
    return get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1
end

local function dual_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 or
    get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1 or
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[3]) == 1
end

local function triple_adr_failure()
    return
    get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1
end

local proc_messages = {
    {
        text = "AP",
        action = "DO NOT USE",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return one_or_more_spoiler_is_fully_extended_in_speedbrake_fault() 
        end
    },
    {
        text = "SPD BRK",
        action = "DO NOT USE",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return spdbrk_3_and_4_fault()
        end
    },

    {
        text = "MAN PITCH TRIM",
        action = "USE",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FBW_total_control_law) == FBW_DIRECT_LAW
        end
    },
    {
        text = "AVOID ICING CONDITIONS",
        action = nil, -- <- use nil to avoid .............
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(L_bleed_press) > 57 or 
            get(L_bleed_temp) > 270 or 
            get(FAILURE_BLEED_APU_LEAK) == 1 or
            get(DC_shed_ess_pwrd) == 0 or
            engine_shuts_down() or
            is_bleed_fault() or
            get(FAILURE_AI_Eng1_valve_stuck) == 1 or
            get(FAILURE_AI_Eng2_valve_stuck) == 1 or
            get(FAILURE_BLEED_XBLEED_VALVE_STUCK) == 1
        end
    },

----------------------------------------------------------------------------------------------------
-- START - . IF SEVERE ICE ACCRETION group
----------------------------------------------------------------------------------------------------
    {
        text = ".IF SEVERE ICE ACCRETION:",
        action = nil,
        color = ECAM_WHITE, 
        indent_lvl = 0,
        cond = function()
            return is_bleed_fault() or
            get(FAILURE_BLEED_APU_LEAK) == 1 or
            get(DC_shed_ess_pwrd) == 0 or
            engine_shuts_down()
        end
    },
    {
        text = "MIN SPD",
        action = "VLS+10 / G.DOT",
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return is_bleed_fault() or
            get(FAILURE_BLEED_APU_LEAK) == 1 or
            get(DC_shed_ess_pwrd) == 0 or
            engine_shuts_down()
        end
    },
    {
        text = "USE SPD BRK WITH CARE",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, -- <- INDENT
        cond = function()
            return 
            get(FBW_total_control_law) == FBW_DIRECT_LAW
        end
    },
----------------------------------------------------------------------------------------------------
-- START - . SHUT DOWN group
----------------------------------------------------------------------------------------------------

    {
        text = ".IF NO ENG 1(2) DAMAGE",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0, -- <- INDENT
        cond = function()
            return 
            engine_shuts_down()
        end
    },
    {
        text = "CONSIDER RELIGHT",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return 
            engine_shuts_down()
        end
    },
----------------------------------------------------------------------------------------------------
-- END - . SHUT DOWN group
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- END - . IF SEVERE ICE ACCRETION group
----------------------------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------------------------
    -- START - . IF ICING EXPECTED group
    ----------------------------------------------------------------------------------------------------

    {
        text = ".IF ICING EXPECTED:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0, -- <- INDENT
        cond = function()
            return get(FAILURE_AI_PITOT_CAPT) == 1 and 
                get(FAILURE_AI_PITOT_FO) == 1 and 
                get(FAILURE_AI_PITOT_STDBY) == 1 or
                get(FAILURE_AI_PITOT_CAPT) == 1 and 
                get(FAILURE_AI_PITOT_STDBY) == 1 and
                (get(FAILURE_ADR[2]) == 1 or
                ADIRS_sys[2].adr_status == ADR_STATUS_OFF or
                ADIRS_sys[2].adr_status == ADR_STATUS_FAULT)
        end
    },

    {
        text = "ADR 1(3) P/B",
        action = "OFF",
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return get(FAILURE_AI_PITOT_CAPT) == 1 and 
                get(FAILURE_AI_PITOT_STDBY) == 1 and

                (get(FAILURE_ADR[2]) == 1 or
                ADIRS_sys[2].adr_status == ADR_STATUS_OFF or
                ADIRS_sys[2].adr_status == ADR_STATUS_FAULT)
        end
    },

    {
        text = "ADR 2(3) P/B",
        action = "OFF",
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return get(FAILURE_AI_PITOT_CAPT) == 1 and 
                get(FAILURE_AI_PITOT_FO) == 1 and 
                get(FAILURE_AI_PITOT_STDBY) == 1
        end
    },

    {
        text = "UNREL SPD PROC",
        action = "APPLY",
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return get(FAILURE_AI_PITOT_CAPT) == 1 and 
                get(FAILURE_AI_PITOT_FO) == 1 and 
                get(FAILURE_AI_PITOT_STDBY) == 1 or
                get(FAILURE_AI_PITOT_CAPT) == 1 and 
                get(FAILURE_AI_PITOT_STDBY) == 1 and
                (get(FAILURE_ADR[2]) == 1 or
                ADIRS_sys[2].adr_status == ADR_STATUS_OFF or
                ADIRS_sys[2].adr_status == ADR_STATUS_FAULT)
        end
    },
        
    ----------------------------------------------------------------------------------------------------
    -- END - . IF ICING EXPECTED group
    ----------------------------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------------------------
    -- START - . IF PACKS NOT RECOVERED group
    ----------------------------------------------------------------------------------------------------

    -- ZONE AT FIXED TEMP MESSAGES SHOULD BE HERE, BETWEEN ABOVE AND BELOW
    -- I MOVED THEM TO THE GREEN MESSAGES SCRIPT (information.lua)
    {
        text = "MAX FL",
        action = "100/MEA-MORA",
        color = ECAM_BLUE,
        indent_lvl = 0, -- <- INDENT
        cond = function()
            return
            get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 or
            get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1
        end
    },
    {
        text = "WHEN PACK OVHR OUT:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return
            get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 or
            get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1
        end
    },
    {
        text = "PACK(AFFECTED)",
        action = "ON",
        color = ECAM_BLUE,
        indent_lvl = 2, -- <- INDENT
        cond = function()
            return
            get(FAILURE_BLEED_PACK_1_VALVE_STUCK) == 1 or
            get(FAILURE_BLEED_PACK_2_VALVE_STUCK) == 1
        end
    },

    ----------------------------------------------------------------------------------------------------
    -- END - . IF PACKS NOT RECOVERED group
    ----------------------------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------------------------
    -- START - AUTOFLIGHT group
    ----------------------------------------------------------------------------------------------------

    ---THESE STUFF SHOULD BE TRIGGERED BEFORE THE ALTN OR DIRECT LAW MESSAGES

    {
        text = "RUD WITH CARE ABV 160KT",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_FCTL_FAC_1) == 1 and
            get(FAILURE_FCTL_FAC_2) == 1 or
            get(FAILURE_FCTL_RUDDER_LIM ) == 1
        end
    },
    {
        text = "GA THR: TOGA ONLY",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_FCTL_FAC_1) == 1 and --fcom 4412
            get(FAILURE_FCTL_FAC_2) == 1 or
            get(FAILURE_ENG_REV_FAULT, 1) == 1 or --fcom 5056
            get(FAILURE_ENG_REV_FAULT, 2) == 1 or
            get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[2]) == 1 or
            get(FAILURE_ADR[2]) == 1 and get(FAILURE_ADR[3]) == 1 or
            get(FAILURE_ADR[1]) == 1 and get(FAILURE_ADR[3]) == 1
        end
    },
    {
        text = "MAX X WIND FOR LDG 15KT", -- fcom 4427
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return
            get(FAILURE_FCTL_RUDDER_LIM ) == 1
        end
    },
    {
        text = "AUTO BRK",
        action = "DO NOT USE",
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_FCTL_RUDDER_LIM ) == 1
        end
    },
    {
        text = ".AT LDG ROLL:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0,
        cond = function()
            return
            get(FAILURE_FCTL_RUDDER_LIM ) == 1
        end
    },
    {
        text = "DIFF BRAKING",
        action = "AS RQRD",
        color = ECAM_BLUE,
        indent_lvl = 1, 
        cond = function()
            return
            get(FAILURE_FCTL_RUDDER_LIM ) == 1
        end
    },
    
    ----------------------------------------------------------------------------------------------------
    -- END - AUTOFLIGHT group
    ----------------------------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------------------------
    -- START - BRAKES group
    ----------------------------------------------------------------------------------------------------
    {
        text = "MAX BRK PR",
        action = "1000PSI",
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(Brakes_mode) == 3 and get(Brakes_accumulator) > 1 or
            get(FAILURE_HYD_G_low_air) == 1 and get(FAILURE_HYD_Y_low_air) == 1 or
            get(DC_bus_1_pwrd) == 0 and get(DC_bus_2_pwrd) == 0 or
            dc_in_emergency_config() or
            elec_in_emer_config()
        end
    },
    {
        text = "LDG DIST PROC",
        action = "APPLY",
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            
        end
    },
    ----------------------------------------------------------------------------------------------------
    -- END - BRAKES group
    ----------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------
    -- START - PRESS group
    ----------------------------------------------------------------------------------------------------
    
    {
        text = "MAN CAB PR CTL",
        action = nil,
        color = ECAM_ORANGE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text = "TGT V/S: CLIMB 500FT/MIN",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text = "TGT V/S: DESC 300FT/MIN",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text ="    A/C FL     CAB ALT TGT  ",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text ="     390           8000     ",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text ="     350           7000     ",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text = "     300           5500     ",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text = "     250           3000     ",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text = "    <200             0      ",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text = ".DURING FINAL APPR:",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },
    {
        text = "MAN VS CTL",
        action = "FULL UP",
        color = ECAM_BLUE,
        indent_lvl = 1, 
        cond = function()
            return
            get(FAILURE_PRESS_SAFETY_OPEN) == 1 or
            get(FAILURE_PRESS_SYS_1) == 1 and
            get(FAILURE_PRESS_SYS_2) == 1
        end
    },

    ----------------------------------------------------------------------------------------------------
    -- END - PRESS group
    ----------------------------------------------------------------------------------------------------
    
    {
        text = "L/G",
        action = "GRVTY EXTN",
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(DC_bus_2_pwrd) == 0 or
            get(DC_ess_bus_pwrd) == 0
        end
    },

    {
        text = "PROC: GRVTY FUEL FEEDING",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            dc_in_emergency_config()
        end
    },
    {
        text = "PROC: FUEL GRAVITY FEED",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            dc_in_emergency_config() or
            elec_in_emer_config()
        end
    },
    {
        text = "AVOID NEGATIVE G FAVTOR",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            elec_in_emer_config()
        end
    },
    {
        text = "AVOID RAPID THR CHANGES",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_ENG_COMP_VANE, 1) == 1 or get(FAILURE_ENG_COMP_VANE, 2) == 1
        end
    },
    {
        text = "THRUST LIMITED",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(FAILURE_ENG_COMP_VANE, 1) == 1 or get(FAILURE_ENG_COMP_VANE, 2) == 1
        end
    },

    {
        text = "THR LVR 1 NOT ABOVE IDLE",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            (
            ((get(FAILURE_ENG_FADEC_CH1, 1) == 1 and get(FAILURE_ENG_FADEC_CH2, 1) == 1) and get(Engine_1_master_switch) == 1)
            ) and
            get(All_on_ground) == 1
        end
    },
    {
        text = "THR LVR 2 NOT ABOVE IDLE",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            (
            ((get(FAILURE_ENG_FADEC_CH1, 2) == 1 and get(FAILURE_ENG_FADEC_CH2, 2) == 1) and get(Engine_2_master_switch) == 1)
            ) and
            get(All_on_ground) == 1
        end
    },


    ----------------------------------------------------------------------------------------------------
    -- START - ENGINE LO START AIR PRESS group
    ----------------------------------------------------------------------------------------------------
    

    {
        text = "BLEED AIR SUPPLY",
        action = "CHECK",
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            get(Engine_mode_knob) == 1 and ((get(L_bleed_press) <= 10 and get(Engine_1_avail) == 0  and get(Engine_1_master_switch) == 1) or (get(R_bleed_press) <= 10 and get(Engine_2_avail) == 0  and get(Engine_2_master_switch) == 1))
        end
    },
    {
        text = ".IF UNSUCCESSFUL",
        action = nil,
        color = ECAM_WHITE,
        indent_lvl = 0, 
        cond = function()
            return
            get(Engine_mode_knob) == 1 and ((get(L_bleed_press) <= 10 and get(Engine_1_avail) == 0  and get(Engine_1_master_switch) == 1) or (get(R_bleed_press) <= 10 and get(Engine_2_avail) == 0  and get(Engine_2_master_switch) == 1))
        end
    },
    {
        text = "WINDMILL START ONLY",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 1, 
        cond = function()
            return
            get(Engine_mode_knob) == 1 and ((get(L_bleed_press) <= 10 and get(Engine_1_avail) == 0  and get(Engine_1_master_switch) == 1) or (get(R_bleed_press) <= 10 and get(Engine_2_avail) == 0  and get(Engine_2_master_switch) == 1))
        end
    },


    ----------------------------------------------------------------------------------------------------
    -- END - ENGINE LO START AIR PRESS group
    ----------------------------------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------------------------------
    -- START - ALTERNATE LAW group, fcom page 5143
    ----------------------------------------------------------------------------------------------------
    
    {
        text = "SPD BRK",
        action = "DO NOT USE",
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            (get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW)
            and
            (get(FAILURE_FCTL_LELEV) == 1 or get(FAILURE_FCTL_RELEV) == 1) or
            get(FAILURE_FCTL_SEC_1) == 1 or
            get(FAILURE_FCTL_SEC_2) == 1 or
            get(FAILURE_FCTL_SEC_3) == 1 or
            G_is_low_pressure() and B_is_low_pressure() or
            triple_adr_failure()
        end
    },
    {
        text = "STBY INST",
        action = "MAY BE UNREL",
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            triple_adr_failure()
        end
    },

    {
        text = "FOR GA: MAX PITCH 15DEG",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0, 
        cond = function()
            return
            (get(FAILURE_FCTL_LELEV) == 1 or get(FAILURE_FCTL_RELEV) == 1) or
            stabliser_is_jammed() or
            Y_is_low_pressure() and B_is_low_pressure() or
            G_is_low_pressure() and B_is_low_pressure()
        end
    },
--    {
--        text = "THR LVR",
--        action = "TOGA THEN MCT",
--        color = ECAM_BLUE,
--        indent_lvl = 0, 
--        cond = function()
--            return
--            (get(FAILURE_FCTL_LELEV) == 1 or get(FAILURE_FCTL_RELEV) == 1) or
--            stabliser_is_jammed()
--        end
--    },
    {
        text = "PROC:GRVTY FUEL FEEDING",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and get(FAILURE_FUEL, L_TK_PUMP_2) == 0 or
            get(FAILURE_FUEL, L_TK_PUMP_1) == 0 and get(FAILURE_FUEL, L_TK_PUMP_2) == 1
        end
    },
    {
        text = "TK GRVTY FEED ONLY",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return  get(FAILURE_FUEL, L_TK_PUMP_1) == 1 and get(FAILURE_FUEL, L_TK_PUMP_2) == 0 or
            get(FAILURE_FUEL, L_TK_PUMP_1) == 0 and get(FAILURE_FUEL, L_TK_PUMP_2) == 1
        end
    },

    -------------------FWC FAULT, FCOM 5326

    {
        text = "MONITOR SYS",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return fwc_1_and_2_fault()
        end
    },
    {
        text = "MONITOR OVERHEAD PANEL",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return fwc_1_and_2_fault()
        end
    },
    
}



function ECAM_status_get_procedures()
    local MAX_LENGTH = 28

    local messages = {}

    for l,x in pairs(proc_messages) do
        if x.cond() then
            local text = ""
            for i=1,x.indent_lvl do
                text = text .. "  "
            end
            
            text = text .. x.text
            if x.action then
                local nr_dots = MAX_LENGTH - #text - #x.action
                if nr_dots <= 0 then
                    logWarning("ECAM Status/PROC - overflow (dots) in message: " .. text)
                end
                for i=1,nr_dots do
                    text = text .. "."
                end
                
                text = text .. x.action
            end
            if #x.text > MAX_LENGTH then
                logWarning("ECAM Status/PROC - overflow in message: " .. text)
            end
            table.insert(messages, {text=text, color=x.color})
        end
    end

    return messages
end
