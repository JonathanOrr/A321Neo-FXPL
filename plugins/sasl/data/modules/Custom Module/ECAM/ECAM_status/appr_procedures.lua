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

local appr_proc_messages = {
    {
        text = "FOR LDG",
        action = "USE FLAP 3",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
                or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW
                or get(FBW_total_control_law) == FBW_DIRECT_LAW
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
                or get(FBW_total_control_law) == FBW_DIRECT_LAW
        end
    },
    {
        text = "L/G",
        action = "GRVTY EXTN",
        color = ECAM_BLUE,
        indent_lvl = 0,
        cond = function()
            return get(FAILURE_gear) == 2   -- TODO Replace dataref
        end
    },
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
