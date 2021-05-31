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
    return (get(L_bleed_press) > 57 or get(L_bleed_temp) > 270) or (get(R_bleed_press) > 57 or get(R_bleed_temp) > 270)
end

local proc_messages = {

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
        text = "APPR SPD",
        action = "VREF + 10",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FBW_total_control_law) == FBW_DIRECT_LAW
                or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
                or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
                or get(Nosewheel_Steering_working) == 0
        end
    },
    {
        text = "AVOID ICING CONDITION",
        action = nil, -- <- use nil to avoid .............
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(L_bleed_press) > 57 or get(L_bleed_temp) > 270
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
            return is_bleed_fault()
        end
    },
    {
        text = "MIN SPD",
        action = "VLS+10 / G.DOT",
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return is_bleed_fault()
        end
    },
    {
        text = "MANEUVER WITH CARE",
        action = nil,
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return is_bleed_fault()
        end
    },
    {
        text = "LDG DIST PROC",
        action = "APPLY",
        color = ECAM_BLUE,
        indent_lvl = 1, -- <- INDENT
        cond = function()
            return is_bleed_fault()
        end
    },
----------------------------------------------------------------------------------------------------
-- END - . IF SEVERE ICE ACCRETION group
----------------------------------------------------------------------------------------------------

    {
        text = "LDG DIST PROC",
        action = "APPLY",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FBW_total_control_law) == FBW_DIRECT_LAW
                or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
                or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
                or get(Nosewheel_Steering_working) == 0
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
