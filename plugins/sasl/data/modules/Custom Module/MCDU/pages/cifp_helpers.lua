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

-- Constants exposed to 6** pages. They should not be used elsewhere
POINT_TYPE_DEP_SID       = 1
POINT_TYPE_DEP_TRANS     = 2
POINT_TYPE_LEG           = 3    -- enroute leg
POINT_TYPE_ARR_TRANS     = 4
POINT_TYPE_ARR_STAR      = 5
POINT_TYPE_ARR_VIA       = 6
POINT_TYPE_ARR_APPR      = 7


function cifp_convert_leg_name(x)

    assert(x)

    -- Sanitize data
    x.leg_type = x.leg_type or CIFP_LEG_TYPE_IF
    x.outb_mag = x.outb_mag or 0
    x.theta = x.theta or 0
    x.rho = x.rho or 0
    x.rte_hold = x.rte_hold or 0
    x.cstr_altitude1 = x.cstr_altitude1 or 0

    local name = x.leg_name or "(UKWN)"
    local leg_type = x.leg_type

    local outb_mag = Fwd_string_fill(tostring(math.floor(x.outb_mag/10)),"0", 3)
    local theta    = Fwd_string_fill(tostring(math.floor(x.theta/10)),"0", 3)
    local dd       = Fwd_string_fill(tostring(math.floor(x.rho/10)),"0", 2)
    local rte      = Fwd_string_fill(tostring(math.floor(x.rte_hold/10)),"0", 2)
    local cstr_alt = Fwd_string_fill(tostring(x.cstr_altitude1), "0", 5)
    
    if leg_type == CIFP_LEG_TYPE_IF then
        return name, ""
    elseif leg_type == CIFP_LEG_TYPE_TF then
        return name, ""
    elseif leg_type == CIFP_LEG_TYPE_CF then
        return name, "C" .. outb_mag .. "°"
    elseif leg_type == CIFP_LEG_TYPE_DF then
        return name, ""
    elseif leg_type == CIFP_LEG_TYPE_FA or leg_type == CIFP_LEG_TYPE_CA then
        return cstr_alt, "C" .. outb_mag .. "°"
    elseif leg_type == CIFP_LEG_TYPE_FC then
        return "INTCPT", "C" .. theta .. "°"
    elseif leg_type == CIFP_LEG_TYPE_FD or leg_type == CIFP_LEG_TYPE_CD then
        return x.recomm_navaid .. "/" .. rte, "C" .. theta .. "°"
    elseif leg_type == CIFP_LEG_TYPE_FM or leg_type == CIFP_LEG_TYPE_VM then
        return "MANUAL", "H" .. outb_mag .. "°"
    elseif leg_type == CIFP_LEG_TYPE_CI or leg_type == CIFP_LEG_TYPE_VI or leg_type == CIFP_LEG_TYPE_VR then
        return "INTCPT", "H" .. outb_mag .. "°"
    elseif leg_type == CIFP_LEG_TYPE_CR then
        return x.center_fix .. outb_mag, "H" .. theta .. "°"
    elseif leg_type == CIFP_LEG_TYPE_RF then
        return name, dd .. " ARC"
    elseif leg_type == CIFP_LEG_TYPE_AF then
        return name, dd .. " " .. x.center_fix
    elseif leg_type == CIFP_LEG_TYPE_VA then
        return cstr_alt, "H" .. outb_mag .. "°"
    elseif leg_type == CIFP_LEG_TYPE_VD then
        return x.center_fix .. "/" .. rte, "H" .. outb_mag .. "°"
    elseif leg_type == CIFP_LEG_TYPE_PI then
        return "PROC " .. x.turn_direction
    elseif leg_type == CIFP_LEG_TYPE_HA then
        return cstr_alt, "HOLD " .. x.turn_direction
    elseif leg_type == CIFP_LEG_TYPE_HF then
        return name, "HOLD " .. x.turn_direction
    elseif leg_type == CIFP_LEG_TYPE_HM then
        return "MANUAL", "HOLD", x.turn_direction
    end
    
    return "UKWN (" .. leg_type .. ")"
end

function cifp_convert_alt_cstr(x)
    local fl_prefix_1 = x.cstr_altitude1_fl and "FL" or ""
    local fl_prefix_2 = x.cstr_altitude2_fl and "FL" or ""
    
    if     x.cstr_alt_type == CIFP_CSTR_ALT_NONE then
        return nil, nil
    elseif x.cstr_alt_type == CIFP_CSTR_ALT_ABOVE or x.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_BELOW then
            return Fwd_string_fill("+" .. fl_prefix_1 .. x.cstr_altitude1, " ", 5), ECAM_MAGENTA
    elseif x.cstr_alt_type == CIFP_CSTR_ALT_BELOW then
        return Fwd_string_fill("-" .. fl_prefix_1 .. x.cstr_altitude1, " ", 5), ECAM_MAGENTA
    elseif x.cstr_alt_type == CIFP_CSTR_ALT_AT or x.cstr_alt_type == CIFP_CSTR_ALT_GLIDE then
        if x.cstr_altitude1 ~= 0 then
            return Fwd_string_fill(fl_prefix_1 .. tostring(x.cstr_altitude1), " ", 5), ECAM_GREEN
        end
    elseif x.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_2ND then
        return Fwd_string_fill("+" .. fl_prefix_2 .. x.cstr_altitude2, " ", 5), ECAM_MAGENTA
    end

    return nil, nil
end

function appr_type_char_to_idx(x)
    if x == CIFP_TYPE_APPR_MLS then
        return 1, "MLS"
    elseif x == CIFP_TYPE_APPR_ILS then
        return 2, "ILS"
    elseif x == CIFP_TYPE_APPR_GLS then
        return 3, "GLS"
    elseif x == CIFP_TYPE_APPR_IGS then
        return 4, "IGS"
    elseif x == CIFP_TYPE_APPR_LOC_ONLY then
        return 5, "LOC"
    elseif x == CIFP_TYPE_APPR_LOC_BC then
        return 6, "BAC"
    elseif x == CIFP_TYPE_APPR_LDA then
        return 7, "LDA"
    elseif x == CIFP_TYPE_APPR_SDF then
        return 8, "SDF"
    elseif x == CIFP_TYPE_APPR_GPS then
        return 9, "GPS"
    elseif x == CIFP_TYPE_APPR_RNAV then
        return 10, "RNAV"
    elseif x == CIFP_TYPE_APPR_VOR or x == CIFP_TYPE_APPR_VORDMETAC then
        return 11, "VOR"
    elseif x == CIFP_TYPE_APPR_NDB or x == CIFP_TYPE_APPR_NDBDME then
        return 12, "NDB"
    elseif x == CIFP_TYPE_APPR_RWY_DIRECT then
        return 13, "RWY"
    else
        return nil, nil
    end
end


function dest_get_selected_appr_procedure()
    local appr_obj = FMGS_arr_get_appr(true)
    if not appr_obj then
        return nil
    end
    local _, type_str = appr_type_char_to_idx(appr_obj.type)
    local rwy_name_with_suffix = appr_obj.proc_name:sub(2)
    local appr_name = type_str .. rwy_name_with_suffix
    return appr_name
end

function avionics_bay_generic_wpt_to_fmgs_type(x)
    assert(x)
    if x.freq then
        return FMGS_PTR_NAVAID
    elseif x.rwys then
        return FMGS_PTR_APT
    else
        return FMGS_PTR_WPT
    end
end