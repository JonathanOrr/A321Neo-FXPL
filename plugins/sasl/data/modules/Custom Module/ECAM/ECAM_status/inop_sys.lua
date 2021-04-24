
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
    
    -- BLEED
    {
     text = "APU BLEED", nr = 1,
     cond_1 = function() return (get(FAILURE_BLEED_APU_VALVE_STUCK) == 1 and get(Apu_bleed_xplane) == 0) or get(FAILURE_BLEED_APU_LEAK) == 1 end,
    },
    {
     text = "BMC", nr = 2,
     cond_1 = function() return get(FAILURE_BLEED_BMC_1) == 1 or get(DC_shed_ess_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_BLEED_BMC_2) == 1 or get(DC_bus_2_pwrd) == 0 end,
    },

    -- APU
    {
     text = "APU", nr = 1,
     cond_1 = function() return get(FAILURE_ENG_APU_FAIL) == 1 or get(FAILURE_FIRE_APU) == 1 end,
    },
    {
     text = "APU", nr = 1,
     cond_1 = function() return get(FAILURE_ENG_APU_FAIL) == 1 or get(FAILURE_FIRE_APU) == 1 end,
    },

    -- BRAKES
    {
     text = "ANTI SKID", nr = 1,
     cond_1 = function() return get(Brakes_mode) == 3 end,
    },
    {
     text = "N/W STRG", nr = 1,
     cond_1 = function() return get(FAILURE_GEAR_NWS) == 1 or get(Nosewheel_Steering_working) == 0 end,
    },
    {
     text = "NORM BRK", nr = 1,
     cond_1 = function() return get(Brakes_mode) ~= 1 and get(Brakes_mode) ~= 4 end,
    },
    {
     text = "AUTO BRK", nr = 1,
     cond_1 = function() return (get(SEC_1_status) + get(SEC_2_status) + get(SEC_3_status) < 2) or get(FAILURE_GEAR_AUTOBRAKES) == 1 or (get(Brakes_mode) ~= 1 and get(Brakes_mode) ~= 4) end,
    },
    {
     text = "ALTN BRK", nr = 1,
     cond_1 = function() return get(Brakes_mode) == 1 and (get(Wheel_status_ABCU) == 0 or get(Hydraulic_Y_press) <= 1450) end,
    },
    {
     text = "BRK Y ACCU", nr = 1,
     cond_1 = function() return get(Brakes_accumulator) < 1 end,
    },
    {
     text = "BRK SYS", nr = 2,
     cond_1 = function() return get(FAILURE_GEAR_BSCU1) == 1 or get(AC_bus_1_pwrd) == 0 or get(DC_bus_1_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_GEAR_BSCU2) == 1 or get(AC_bus_2_pwrd) == 0 or get(DC_bus_2_pwrd) == 0 end,
    },

    -- PRESS
    {
     text = "CAB PR", nr = 2,
     cond_1 = function() return get(FAILURE_PRESS_SYS_1) == 1 or get(DC_ess_bus_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_PRESS_SYS_2) == 1 or get(DC_bus_2_pwrd) == 0 end,
    },

    -- DMC
    {
     text = "DMC", nr = 3,
     cond_1 = function() return get(FAILURE_DISPLAY_DMC_1) == 1 or get(AC_ess_bus_pwrd) == 0 end,
     cond_2 = function() return get(FAILURE_DISPLAY_DMC_2) == 1 or get(AC_bus_2_pwrd) == 0 end,
     cond_3 = function() return get(FAILURE_DISPLAY_DMC_3) == 1 or (get(AC_bus_1_pwrd) == 0 and get(AC_ess_bus_pwrd) == 0) end,
    },

    -- ELEC
    {
     text = "APU GEN", nr = 1,
     cond_1 = function() return get(FAILURE_ELEC_GEN_APU) == 1 end,
    },
    {
     text = "GEN", nr = 2,
     cond_1 = function() return get(FAILURE_ELEC_GEN_1) == 1 or (get(Engine_1_avail) == 0 and get(All_on_ground) == 0) or not ELEC_sys.generators[1].idg_status end,
     cond_2 = function() return get(FAILURE_ELEC_GEN_2) == 1 or (get(Engine_2_avail) == 0 and get(All_on_ground) == 0) or not ELEC_sys.generators[2].idg_status end,
    },
    {
     text = "BAT", nr = 2,
     cond_1 = function() return get(FAILURE_ELEC_battery_1) == 1 end,
     cond_2 = function() return get(FAILURE_ELEC_battery_2) == 1 end,
    },
    {
     text = "GALY/CAB", nr = 1,
     cond_1 = function() return get(Gally_pwrd) == 1 and PB.ovhd.elec_galley.status_bottom == false end,
    },
    {
     text = "MAIN GALLEY", nr = 1,
     cond_1 = function() return (get(Gen_1_pwr) + get(Gen_2_pwr) <= 1) and (get(Gen_APU_pwr) + get(Gen_EXT_pwr) == 0) end,
    },
    {
     text = "TR", nr = 2,
     cond_1 = function() return get(FAILURE_ELEC_TR_1) == 1 end,
     cond_2 = function() return get(FAILURE_ELEC_TR_2) == 1 end,
    },
    {
     text = "TR ESS", nr = 1,
     cond_1 = function() return get(FAILURE_ELEC_TR_ESS) == 1 end,
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
    
