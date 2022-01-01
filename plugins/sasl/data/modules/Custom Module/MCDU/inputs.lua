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
-- File: inputs.lua 
-- Short description: Helpers for MCDU inputs
-------------------------------------------------------------------------------


local function mcdu_eval_entry(str, format)
    local pass = true
    if #str ~= #format then
        pass = false
    end
    for i = 1,#format do
        if string.sub(format, i, i) == "!" then
            -- digit
            if string.find(string.sub(str, i, i), "%d") == nil then
                pass = false
            end
        elseif string.sub(format, i, i) == "@" then
            -- letter
            if string.find(string.sub(str, i, i), "%a") == nil then
                pass = false
            end
        elseif string.sub(format, i, i) == "#" then
            -- do nothing
        else
            if string.sub(str, i, i) ~= string.upper(string.sub(format, i, i)) then
                pass = false
            end
        end
    end
    return pass
end

local function mcdu_eval_entries(entry, expected_formats)
    --[[
    -- expected_format
    --
    -- can accept multiple inputs ! for digits, @ for letters, # for anything
    -- https://www.lua.org/pil/20.2.html
    --]]
    
    if expected_formats == nil then
        return entry
    end

    if expected_formats[1] ~= nil then
        local pass = false
        for i,format in ipairs(expected_formats) do-- expected_formats is a table
            if mcdu_eval_entry(entry, format) then
                return entry
            end
        end
		return nil
    else
        if mcdu_eval_entry(entry, expected_formats) then
            return entry
        else
            return nil
        end
    end
end

function mcdu_parse_entry(entry, expected_format)
    local code = nil
	local format_type = expected_format[1]

	if format_type == "altitude" then
		format_type = "number"
		expected_format = {"number", length = 5, dp = 0}
		if string.sub(entry, 1, 2) == "FL" then
			entry = string.sub(entry, 3, -1) -- get rid of FL
        else
            if tonumber(entry) then
                entry = tostring(math.floor(tonumber(entry) / 100))
            else
                return "$invalid"
            end
        end
	end
	if format_type == "heading" then
		format_type = "number"
		expected_format = {"number", length = 3, dp = 0}
	end
	if format_type == "number" then
		code = "!"
	elseif format_type == "word" then
		code = "#"
	end

    local possible_inputs_c = {}
    if code then
	    local possible_inputs_a = {code}

        -- if dp isn't specified
        if not expected_format.dp then
            expected_format.dp = 0
        end

	    -- add decimal places
	    local s = code .. "."
	    for i = 1, expected_format.dp, 1 do
		    s = s .. code
		    table.insert(possible_inputs_a, s)
	    end

	    local possible_inputs_b = {}

	    -- add whole number places
	    for _, j in ipairs(possible_inputs_a) do
		    s = ""
		    for i = 1, expected_format.length, 1 do
			    table.insert(possible_inputs_b, s .. j)

			    s = code .. s
		    end
	    end

	    for _, i in ipairs(possible_inputs_b) do
		    table.insert(possible_inputs_c, i)
		    table.insert(possible_inputs_c, "+" .. i)
		    table.insert(possible_inputs_c, "-" .. i)
	    end
    else
        possible_inputs_c = expected_format
    end
	local output = mcdu_eval_entries(entry, possible_inputs_c)
	if output == nil then
		return "$invalid"
	end
	return output
end

-- the simpler way of getting mcdu entries
function mcdu_get_entry_simple(mcdu_data, expected_formats, preserve_entry)
    assert(type(mcdu_data) == "table" and mcdu_data.id)
    local output = mcdu_eval_entries(mcdu_data.entry.text, expected_formats)
    if output == nil then
        mcdu_send_message(mcdu_data, "FORMAT ERROR")
        return nil
    elseif not preserve_entry then
        mcdu_data.entry = {text="", color=nil}
    end
    return output
end


-- accepts mcdu entries by a specific format (list of formats)
-- e.g. mcdu_get_entry({"altitude"}, {"number", length = 2, dp = 0})
-- accepts in an altitude format, with a slash and a number.
-- so 300/20 is allowed
-- and /-20 is allowed (returns nil, -20)
-- and 300 is allowed (returns 300, nil)
function mcdu_get_entry(mcdu_data, format_a, format_b, dont_reset_entry)
    assert(type(mcdu_data) == "table" and mcdu_data.id)
    local entry = mcdu_data.entry.text
	local a = nil
	local b = nil
	if format_b then
		-- e.g. /20
		if string.sub(entry, 1, 1) == "/" then
			b = mcdu_parse_entry(string.sub(entry, 2, -1), format_b)
		else
			local i = 1
			while string.sub(entry, i, i) ~= "/" and i < #entry do
				i = i + 1
			end
			-- e.g. 200
			if i == #entry then
				a = mcdu_parse_entry(entry, format_a)
			-- e.g. 200/20
			else
				a = mcdu_parse_entry(string.sub(entry, 1, i-1), format_a)
				b = mcdu_parse_entry(string.sub(entry, i+1, -1), format_b)
			end
		end
	else
        if format_a then
            a = mcdu_parse_entry(entry, format_a)
        else
            a = entry
        end
	end

	if a == "$invalid" or b == "$invalid" then
        mcdu_send_message(mcdu_data, "FORMAT ERROR")
        if format_b then
            return nil, nil
        end
		return nil
	end

    if not dont_reset_entry then
    	mcdu_data.entry = {text="", color=nil}
    end
    if format_b then
        return a, b
    else
        return a
    end

end

