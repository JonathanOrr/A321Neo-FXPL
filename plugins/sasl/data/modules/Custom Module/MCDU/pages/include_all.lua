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
-- File: include_all.lua 
-- Short description: A script to include all the subpages
-------------------------------------------------------------------------------

include('MCDU/pages/base.lua')

mcdu_pages = {}

local dir_list = sasl.listFiles(moduleDirectory .. "/Custom Module/MCDU/pages/")

local dir_list_len = #dir_list

assert(dir_list_len > 0, "Hey! Where all the MCDU pages gone?")

for i=1,dir_list_len do
    local dir_name = dir_list[i].name

    if dir_list[i].type == "directory" and dir_name ~= "." and dir_name ~= ".." then
        local pages_list = sasl.listFiles(moduleDirectory .. "/Custom Module/MCDU/pages/" .. dir_name .."/")

        local pages_len = #pages_list
        for i=1,pages_len do
            if pages_list[i].type == "file" then
                include("MCDU/pages/" .. dir_name .. "/" .. pages_list[i].name)
            end
        end
    end
end
