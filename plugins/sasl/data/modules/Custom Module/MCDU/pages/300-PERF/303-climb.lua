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
local THIS_PAGE = MCDU_Page:new({id=303})

function THIS_PAGE:render(mcdu_data)

    local climb_mode = true -- SPEED, TRUE IS MANAGED, FALSE IS SELECTED!
    local predicted_reaching_altitude = 37000
    local managed_data = {250, 0000,123} --FORMAT IS SPEED, ARRIVING UTC, DISTANCE
    local selected_data = {nil, nil,nil}
    local expedite_data = {0000, 120} --ARRIVING UTC, DISTANCE
    local fms_is_in_climb_phase = false --IF THE FMS IS BEYOND TAKEOFF PHASE, WHICH IS AFTER DEPARTURE. USED TO DECIDE WETHER TO SHOW ACTIVATE APPR PHASE ON L6

--                                                              
--         *#%%%%#(                    .(%%%%%#*           
--    .%%%%#(*,,,*(((#%(           #%%#((*,.,*((#%%%       
--  /%%#*.............*##%*     /%%#,.........    *#%%*    
-- %%%*******************#%%* #%%(*************,,,,,,%%%   
--%%%//////////////////////#%%%#////////////////******%%%  
--*%%#///////(((((((((((((((((%((((((((((((((((////////#%%. 
--*%%((((((((((((((((((((((((((#((((((((((((((((((((((((%%. 
--%%#((((((((((((((((##(###########(((((((((((((((((((#%%  
--#%%###(############################(#(###########(((%%/  
-- %%%###############################################%%%   
--  %&%%%###########################################%%#    
--   /&%%%%%#####################################%%%%*     
--     &&%%%%%%################(##############%%%%%%       
--      .&&%%%%%%%############((############%%%%%&         
--        ,&&%%%%%%%#########((((#########%%%%%&.          
--          .&&%%%%%%%%#################%%%%%&.            
--             &&&%%%%%%%%###########%%%%%%%               
--               #&&%%%%%%%%%#####%%%%%%&#                 
--                 *&&%%%%%%%%%%%%%%%&&,                   
--                    &&&%%%%%%%%%&&%                      
--                      #&&&%%&&&&(                        
--                        .&&&&&.                          
--                           #                             
--

    ----------
    -- TITLE--
    ----------
    self:set_title(mcdu_data, " CLB")
    ----------
    --  L1  --
    ----------
    
    self:set_line(mcdu_data, MCDU_LEFT, 1, "ACT MODE", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, climb_mode and "MANAGED" or "SELECTED", MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L2  --
    ----------
    self:set_line(mcdu_data, MCDU_LEFT, 2, " CI", MCDU_SMALL, ECAM_WHITE)
    if not FMGS_are_main_apts_set() then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "---", MCDU_LARGE)
    elseif not FMGS_init_get_cost_idx() then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "___", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 2, FMGS_init_get_cost_idx(), MCDU_LARGE, ECAM_BLUE)
    end
    
    ----------
    --  L3  --
    ----------

    self:set_line(mcdu_data, MCDU_LEFT, 3, " MANAGED", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, " "..managed_data[1], MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L4  --
    ----------

    self:set_line(mcdu_data, MCDU_LEFT, 4, selected_data[1] == nil and " PRESEL" or " SELECTED", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, selected_data[1] == nil and "*[ ]" or  " "..selected_data[1], MCDU_LARGE, selected_data[1] == nil and ECAM_BLUE or ECAM_GREEN)

    ----------
    --  L5  --
    ----------

    self:set_line(mcdu_data, MCDU_LEFT, 5, mcdu_format_force_to_small(" EXPEDITE "), MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L6  --
    ----------
    if fms_is_in_climb_phase then
        self:set_line(mcdu_data, MCDU_LEFT, 6, " ACTIVATE", MCDU_SMALL, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←APPR PHASE", MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, " PREV", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "<PHASE", MCDU_LARGE, ECAM_WHITE)
    end

    ----------
    --  R1  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "DRT CLB", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "[ ]", MCDU_LARGE, ECAM_BLUE)
    ----------
    --  R2  --
    ----------

    self:add_multi_line(mcdu_data, MCDU_RIGHT, 2,mcdu_format_force_to_small("PRED TO      "), MCDU_LARGE, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 2,"FL"..predicted_reaching_altitude/100, MCDU_LARGE, ECAM_BLUE)

    ----------
    --  R3  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 3,"DIST", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 3,managed_data[3], MCDU_LARGE, ECAM_GREEN)
    ----------
    --  R4  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 4,selected_data[3], MCDU_LARGE, ECAM_GREEN)
    ----------
    --  R5  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 5,mcdu_format_force_to_small(expedite_data[2]), MCDU_LARGE, ECAM_GREEN)
    ----------
    --  R6  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "PHASE>", MCDU_LARGE, ECAM_WHITE)

    ----------
    --  C3  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_CENTER, 3,"UTC", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_CENTER, 3,managed_data[2] == nil and "" or Fwd_string_fill(tostring(managed_data[2]), "0", 4), MCDU_LARGE, ECAM_GREEN)

    ----------
    --  C4  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_CENTER, 4,selected_data[2] == nil and "" or Fwd_string_fill(tostring(selected_data[2]), "0", 4), MCDU_LARGE, ECAM_GREEN)
    ----------
    --  C5  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_CENTER, 5,expedite_data[2] == nil and "" or mcdu_format_force_to_small(Fwd_string_fill(tostring(expedite_data[2]), "0", 4)), MCDU_LARGE, ECAM_GREEN)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 302)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE