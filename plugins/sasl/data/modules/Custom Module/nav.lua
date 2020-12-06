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
-- File: nav.lua 
-- Short description: Backend code for navigation data processing
-------------------------------------------------------------------------------

function char_at(str, index)
	return string.sub(str, index, index)
end



-- CifpLine will parse a row of data into a struct
CifpLine = {row = ""}
CifpLine.__index = CifpLine

-- row parser class constructor
function CifpLine:new(row)
   local o = {}             -- our new object
   setmetatable(o, self)  -- make Account handle lookup
   o.row = row      -- initialize our object
	return o
end

-- read column from row of data
function CifpLine:get_column(col_index)
	i = 1
	col = 0
	while col < col_index - 1 do
		if char_at(self.row, i) == "," or char_at(self.row, i) == ";" then
			col = col + 1
		end
		i = i + 1
	end
	j = i
	while char_at(self.row, j) ~= "," or char_at(self.row, i) == ";" do 
		j = j + 1
	end
	return string.sub(self.row, i, j - 1)
end

-- parses all columns from row of data
function CifpLine:parse()
	result = {}

	wpt_info = self:get_column(1)
	j = 1
	while char_at(self.row, j) ~= ":" do 
		j = j + 1
	end

	result.wpt_type = string.sub(wpt_info, 1, j - 1)
	result.wpt_num = string.sub(wpt_info, j + 1, -1)

	result.wpt_mode = self:get_column(2)
	result.wpt_name = self:get_column(3)
	result.transition_ident = self:get_column(4)
	result.leg_name = self:get_column(5)


	return result
end



-- CifpParser will parse the data file for an airport
CifpParser = {data = "", parsed_data = {}}
CifpParser.__index = CifpParser

-- parser class constructor
function CifpParser:new(data)
   local o = {}             -- our new object
   setmetatable(o, self)  -- make Account handle lookup
   o.data = data      -- initialize our object
	return o
end

-- parses all columns from row of data
function CifpParser:parse()
	i = 1
	j = 1
	col = 0
	while j < #self.data do
		while char_at(self.data, j) ~= ";" and j < #self.data do
			j = j + 1
		end
		
		j = j + 1
		line = CifpLine:new(string.sub(self.data, i, j - 1))
		--print("a" .. string.sub(self.data, i, j - 1))
		--print(line:get_column(3))
		table.insert(self.parsed_data, line)
		i = j + 1
	end
	return nil
end

function CifpParser:get_runways(proc_type)
	output = {}
	for _, pd in ipairs(self.parsed_data) do
		if string.sub(pd:get_column(1), 1, 3) == "RWY" then
			table.insert(output, string.sub(pd:get_column(1), 5, 9))
		end
	end
	return output
end

function CifpParser:get_proc(runway, proc_type)
	output = {}
	for _, pd in ipairs(self.parsed_data) do
		if pd:get_column(1) == proc_type .. ":010" and
		   pd:get_column(4) == runway
		   then
			table.insert(output, pd:get_column(3))
		end
	end
	return output
end

function CifpParser:get_trans(runway, proc_type, proc)
	output = {}
	for _, pd in ipairs(self.parsed_data) do
		if pd:get_column(1) == proc_type .. ":010" and
			pd:get_column(2) == "6" and
			pd:get_column(3) == proc
		   then
			table.insert(output, pd:get_column(4))
		end
	end
	return output
end

function CifpParser:get_course(runway, proc_type, proc)
	output = {}
	num = 1
	
	found = true
	while found do
		found = false
		for _, pd in ipairs(self.parsed_data) do
			wpt_info = pd:get_column(1)
			j = 1
			while char_at(wpt_info, j) ~= ":" and j < string.len(wpt_info) do 
				j = j + 1
			end

			wpt_type = string.sub(wpt_info, 1, j - 1)
			wpt_num = string.sub(wpt_info, j + 1, -1)
			if wpt_type == proc_type and
			wpt_num == "0" .. tostring(num) .. "0" and
			pd:get_column(3) == proc and
			pd:get_column(4) == runway
				then
				found = true
				table.insert(output, tostring(num) .. ". " .. pd:get_column(4))
				print("Step " .. tostring(num) .. ". " .. pd:get_column(5))
			end
		end
		num = num + 1
	end
	return output
end

--print("Enter airport ICAO")
--airp = io.read()
file = io.open(sasl.getXPlanePath() .. "/Resources/default data/CIFP/KSEA.dat", "r")
data = file:read("*all")

-- create a new parser, input first row of data (KSEA.dat)
parser = CifpParser:new(data)
parser:parse()

-- create a new parser, input first row of data (KSEA.dat)
--parser = CifpLine:new(current_line)
-- parse the result
--result = parser:parse()

--proc_type = question("Choose a procedure type (Enter a number)", {"SID", "STAR"})

possible_proc_rwys = parser:get_runways()
--[[

possible_proc = parser:get_proc(rwy, proc_type)
proc = question(proc_type .. "S AVAILABLE", possible_proc)

possible_trans = parser:get_trans(rwy, proc_type, proc)
trans = question("via TRANSITION", possible_trans)

print()
print(proc_type .." Procedure:")
parser:get_course(rwy, proc_type, proc)
print("Transition Procedure:")
parser:get_course(trans, proc_type, proc)
--]]
