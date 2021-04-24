
local function put_inop_sys_msg_2(messages, dr_1, dr_2, t_1, t_2, title)
    if dr_1 and dr_2 then
        return ( title .. " " .. t_1 .. " + " .. t_2)
    elseif dr_1 then
        return ( title .. " " .. t_1)
    elseif dr_2 then
        return ( title .. " " .. t_2)
    end
    return "XXX"    -- Shold not happen
end

local function put_inop_sys_msg_3(messages, dr_1, dr_2, dr_3, title)
    if dr_1 and dr_2 and dr_3 then
        return ( title .. " 1 + 2 + 3")
    elseif dr_1 == 0 and dr_2 == 0 then
        return ( title .. " 1 + 2")
    elseif dr_1 == 0 and dr_3 == 0 then
        return ( title .. " 1 + 3")
    elseif dr_2 == 0 and dr_3 == 0 then
        return ( title .. " 2 + 3")
    elseif dr_1 == 0 then
        return ( title .. " 1")
    elseif dr_2 == 0 then
        return ( title .. " 2")
    elseif dr_3 == 0 then
        return ( title .. " 3")
    end
    return "XXX"    -- Shold not happen
end

local inop_systems_desc = {

    -- ANTI-ICE
    {
     text = "CAPT PITOT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_PITOT_CAPT) == 1 or get(AC_ess_bus_pwrd) == 0 end,
    },
    {
     text = "F/O PITOT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_PITOT_FO) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "STBY PITOT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_PITOT_STDBY) == 1 or get(AC_bus_1_pwrd) == 0 end,
    },
    {
     text = "CAPT AOA", nr = 1,
     cond_1 = function() return get(FAILURE_AI_AOA_CAPT) == 1 or get(AC_ess_shed_pwrd) == 0 end,
    },
    {
     text = "F/O AOA", nr = 1,
     cond_1 = function() return get(FAILURE_AI_AOA_FO) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "STBY AOA", nr = 1,
     cond_1 = function() return get(FAILURE_AI_AOA_STDBY) == 1 or get(AC_bus_1_pwrd) == 0 end,
    },
    {
     text = "CAPT STAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_SP_CAPT) == 1 or get(DC_bus_1_pwrd) == 0 end,
    },
    {
     text = "F/O STAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_SP_FO) == 1 or get(DC_bus_2_pwrd) == 0 end,
    },
    {
     text = "STBY STAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_SP_STDBY) == 1 or get(DC_bus_1_pwrd) == 0 end,
    },
    {
     text = "CAPT TAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_TAT_CAPT) == 1 or get(AC_bus_1_pwrd) == 0 end,
    },
    {
     text = "F/O TAT", nr = 1,
     cond_1 = function() return get(FAILURE_AI_TAT_FO) == 1 or get(AC_bus_2_pwrd) == 0 end,
    },
    {
     text = "ENG", text_after = "A.ICE", nr = 2,
     cond_1 = function() return not AI_sys.comp[ANTIICE_ENG_1].valve_status and (get(DC_bus_1_pwrd) == 0 or get(FAILURE_AI_Eng1_valve_stuck) == 1) end,
     cond_2 = function() return not AI_sys.comp[ANTIICE_ENG_2].valve_status and (get(DC_bus_2_pwrd) == 0 or get(FAILURE_AI_Eng2_valve_stuck) == 1) end,
    },
    {
     text = "WSHLD", text_after = "HEAT", text_1="L", text_2="R", nr = 2,
     cond_1 = function() return get(AI_sys.comp[ANTIICE_WINDOW_HEAT_L].failure) == 1 or get(AI_sys.comp[ANTIICE_WINDOW_HEAT_L].source_elec) == 0 end,
     cond_2 = function() return get(AI_sys.comp[ANTIICE_WINDOW_HEAT_R].failure) == 1 or get(AI_sys.comp[ANTIICE_WINDOW_HEAT_R].source_elec) == 0 end,
    },
    
    -- F/CTL
    {
     text = "ELAC",
     nr = 2,
     cond_1 = function() return get(FAILURE_FCTL_ELAC_1) == 1 or (get(DC_ess_bus_pwrd) == 0 and get(HOT_bus_1_pwrd) == 0) end,
     cond_2 = function() return get(FAILURE_FCTL_ELAC_2) == 1 or (get(DC_bus_2_pwrd) == 0 and get(HOT_bus_2_pwrd) == 0) end,
    },
    {
     text = "SEC",
     nr = 3,
     cond_1 = function() return get(FAILURE_FCTL_SEC_1) == 1 or (get(DC_ess_bus_pwrd) == 0 and get(HOT_bus_1_pwrd) == 0) end,
     cond_2 = function() return get(FAILURE_FCTL_SEC_2) == 1 or (get(DC_bus_2_pwrd) == 0) end,
     cond_3 = function() return get(FAILURE_FCTL_SEC_3) == 1 or (get(DC_bus_2_pwrd) == 0) end,
    },
    {
     text = "FAC",
     nr = 2,
     cond_1 = function() return get(FAILURE_FCTL_FAC_1) == 1 or not (get(AC_ess_bus_pwrd) == 1 and get(DC_shed_ess_pwrd) == 1) end,
     cond_2 = function() return get(FAILURE_FCTL_FAC_2) == 1 or not (get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1) end,
    },

}


function ECAM_status_get_inop_sys()

        local messages = {}

        -- FBW
        if get(FBW_total_control_law) < FBW_NORMAL_LAW then
            table.insert(messages, "F/CTL PROT")
        end

        for l,x in pairs(inop_systems_desc) do
            if x.nr == 1 and x.cond_1() then
                table.insert(messages, x.text)
            elseif x.nr == 2 and (x.cond_1() or x.cond_2()) then
                local t1 = x.text_1 and x.text_1 or "1"
                local t2 = x.text_2 and x.text_2 or "2"
                local msg = put_inop_sys_msg_2(messages, x.cond_1(), x.cond_2(), t1, t2, x.text)
                if x.text_after then msg = msg .. " " .. x.text_after end
                table.insert(messages, msg)
            elseif x.nr == 3 and (x.cond_1() or x.cond_2() or x.cond_3()) then
                local msg = put_inop_sys_msg_3(messages, x.cond_1(), x.cond_2(), x.cond_3(), x.text)
                if x.text_after then msg = msg .. " " .. x.text_after end
                table.insert(messages, msg)
            end
        end



        return messages
    end
    
