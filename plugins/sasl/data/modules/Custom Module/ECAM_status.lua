include('constants.lua')
include('EWD_msgs/adirs.lua')

local function put_inop_sys_msg_2(messages, dr_1, dr_2, title)
    if get(dr_1) == 0 and get(dr_2) == 0 then
        table.insert(messages, title .. " 1 + 2")
    elseif get(dr_1) == 0 then
        table.insert(messages, title .. " 1")
    elseif get(dr_2) == 0 then
        table.insert(messages, title .. " 2")
    end
end

local function put_inop_sys_msg_3(dr_1, dr_2, dr_3, title)
    if get(dr_1) == 0 and get(dr_2) == 0 and get(dr_3) == 0 then
        table.insert(messages, title .. " 1 + 2 + 3")
    elseif get(dr_1) == 0 and get(dr_2) == 0 then
        table.insert(messages, title .. " 1 + 2")
    elseif get(dr_1) == 0 and get(dr_3) == 0 then
        table.insert(messages, title .. " 1 + 3")
    elseif get(dr_2) == 0 and get(dr_3) == 0 then
        table.insert(messages, title .. " 2 + 3")
    elseif get(dr_1) == 0 then
        table.insert(messages, title .. " 1")
    elseif get(dr_2) == 0 then
        table.insert(messages, title .. " 2")
    elseif get(dr_3) == 0 then
        table.insert(messages, title .. " 3")
    end
end


ecam_sts = {
    
    get_max_speed = function()
    
        max_kn   = 999
        max_mach = 999
    
        if get(FBW_status) == 0 then    -- direct law
            max_kn = math.min(max_kn, 320)
            max_mach = math.min(max_mach, 77)
        elseif get(FBW_status) == 1 then
            max_kn = math.min(max_kn, 320)
            max_mach = math.min(max_mach, 82)-- TODO should be .77 if dual HYD failure
        end
        
        if get(FAILURE_gear) == 1 then
            max_kn = math.min(max_kn, 280)
            max_mach = math.min(max_mach, 67)
        end
        
        if max_kn == 999 then
            return 0,0
        else
            return max_kn, max_mach
        end
    end,
    
    get_max_fl = function()
        return 0
    end,
    
    get_appr_proc = function()
    
        local messages = {}
        if get(FBW_status) < 2 then -- altn or direct law
            table.insert(messages, { text="-FOR LDG.......USE FLAP 3", color=ECAM_BLUE})
            table.insert(messages, { text="-GPWS LDG FLAP 3.......ON", color=ECAM_BLUE})
        end
    
        if get(FAILURE_gear) == 2 then
            table.insert(messages, { text="-L/G...........GRVTY EXTN", color=ECAM_BLUE})
        end
        
        return messages
    end,
    
    get_procedures = function()
    
        local messages = {}
        
        local appr_p_10_landing = false
        
        if get(FBW_status) < 2 then -- altn or direct law
            if get(FBW_status) == 0 then -- direct law
                table.insert(messages, { text="MAN PITCH TRIM...........USE", color=ECAM_BLUE})
            end
            appr_p_10_landing = true
        end
        
        if get(Nosewheel_Steering_and_AS) == 0 then
            appr_p_10_landing = true
        end
        
        if appr_p_10_landing then
            table.insert(messages, {text="APPR SPD...........VREF + 10", color=ECAM_BLUE})
            table.insert(messages, {text="LDG DIST PROC..........APPLY", color=ECAM_BLUE})
        end
        
        if MessageGroup_ADR_FAULT_TRIPLE:is_active() then
            table.insert(messages, {text="RUD WITH CARE ABV 160 KT", color=ECAM_BLUE})
        end
        
        if MessageGroup_IR_FAULT_SINGLE:is_active() or MessageGroup_IR_FAULT_DOUBLE:is_active() or MessageGroup_IR_FAULT_TRIPLE:is_active() then
            table.insert(messages, {text="IR MAY BE AVAIL IN ATT", color=ECAM_WHITE})     
        end
        
        
        return messages
    end,
    
    get_information = function()
        local messages = {}
        
        -- ELEC
        if get(Battery_1) == 0 or get(Battery_2) == 0 then
            table.insert(messages, "APU BAT START NOT AVAIL")
        end
        
        -- FBW
        if get(FBW_status) == 0 then
            table.insert(messages, "DIRECT LAW")
            table.insert(messages, "MANEUVER WITH CARE")
            table.insert(messages, "USE SPD BRK WITH CARE")
        end
        if get(FBW_status) == 1 then
            table.insert(messages, "WHEN L/G DN : DIRECT LAW")
            table.insert(messages, "ALTN LAW : PROT LOST")
        end
        
        if get(FAILURE_gear) == 1 then
            table.insert(messages, "INCREASED FUEL CONSUMP")        
        end

   
        if get(Nosewheel_Steering_and_AS) == 0 or get(FAILURE_gear) == 2 or MessageGroup_ADR_FAULT_SINGLE:is_active() or MessageGroup_IR_FAULT_SINGLE:is_active() then
            table.insert(messages, "CAT 3 SINGLE ONLY")
        elseif MessageGroup_ADR_FAULT_DOUBLE:is_active() or MessageGroup_ADR_FAULT_TRIPLE:is_active() or MessageGroup_IR_FAULT_DOUBLE:is_active() or MessageGroup_IR_FAULT_TRIPLE:is_active() then
            table.insert(messages, "CAT 1 ONLY")
        end
    
        return messages
    end,
    
    get_cancelled_cautions = function()
        local messages = {}
        
        for i, m in ipairs(_G.ewd_left_messages_list_cancelled) do
            table.insert(messages, {title = m.text(), text = m.messages[1].text() })
        end
    
        return messages
    end,
    
    get_inop_sys = function()
        local messages = {}
        
        local inop_cat3_dual = false
        local inop_steer = false
        local inop_aps   = false
        local inop_atr   = false
        
        -- AIR
        --put_inop_sys_msg_2(messages, Left_bleed_avil, Right_bleed_avil, "PACK")
        
        -- ELAC / SEC / FAC
        put_inop_sys_msg_2(messages, ELAC_1, ELAC_2, "ELAC")
        put_inop_sys_msg_3(messages, SEC_1, SEC_2, SEC_3, "SEC")
        put_inop_sys_msg_2(messages, FAC_1, FAC_2, "FAC")
        
        -- FBW
        if get(FBW_status) < 2 then
            table.insert(messages, "F/CTL PROT")
        end
        
        -- ELEC
        put_inop_sys_msg_2(messages, Gen_1_on, Gen_2_on, "GEN")

        -- ENGINES and APU
        if get(FAILURE_Apu) == 6 or get(FAILURE_Apu_fire) == 6 then
            table.insert(messages, "APU")
        end
        
        -- L/G
        if get(FAILURE_gear) == 1 then
            table.insert(messages, "L/G RETRACT")
        elseif get(FAILURE_gear) == 2 then
            inop_steer = true
            inop_cat3_dual = true
        end
        

        if get(FAILURE_TCAS) == 6 then
            table.insert(messages, "TCAS")                
        end

        if get(Nosewheel_Steering_and_AS) == 0 then
            table.insert(messages, "ANTI SKID")
            table.insert(messages, "BSCU CH 1")
            table.insert(messages, "BSCU CH 2")
            inop_steer = true
            inop_cat3_dual = true            
        end

        if MessageGroup_ADR_FAULT_SINGLE:is_active() then
            table.insert(messages, "ADR " .. MessageGroup_ADR_FAULT_SINGLE:get_failed())
            inop_cat3_dual = true
        end
        if MessageGroup_ADR_FAULT_DOUBLE:is_active() then
            a, b = MessageGroup_ADR_FAULT_DOUBLE:get_failed()
            table.insert(messages, "ADR " .. a .. " + " .. b)
            table.insert(messages, "RUD TRV LIM")
            inop_cat3_dual = true
            inop_aps = true
        end
        
        if MessageGroup_ADR_FAULT_TRIPLE:is_active() then
            table.insert(messages, "ADR 1 + 2 + 3")
            table.insert(messages, "RUD TRV LIM")
            table.insert(messages, "WINDSHEAR DET")
            inop_cat3_dual = true
            inop_aps = true
            inop_atr = true
        end
 
        if MessageGroup_IR_FAULT_SINGLE:is_active() then
            table.insert(messages, "IR " .. MessageGroup_IR_FAULT_SINGLE:get_failed())
            inop_cat3_dual = true
        end
        if MessageGroup_IR_FAULT_DOUBLE:is_active() then
            a,b = MessageGroup_IR_FAULT_DOUBLE:get_failed()
            table.insert(messages, "IR " .. a .. " + " .. b)
            table.insert(messages, "YAW DAMPER")
            inop_cat3_dual = true
            inop_aps = true
            inop_atr = true
        end
        
        if MessageGroup_IR_FAULT_TRIPLE:is_active() then
            table.insert(messages, "IR 1 + 2 + 3")
            table.insert(messages, "YAW DAMPER")
            inop_cat3_dual = true
            inop_aps = true
            inop_atr = true
        end
        
        -- LEAVE THESE AT THE LAST
        if inop_cat3_dual then
            table.insert(messages, "CAT 3 DUAL")        
        end

        if inop_aps then
            table.insert(messages, "AP 1 + 2")        
        end
        
        if inop_atr then
            table.insert(messages, "A/THR")        
        end
                
        if inop_steer then
            table.insert(messages, "N.W. STEER")
        end

        return messages
    end,
    
    get_maintenance = function()
        return {  } -- TODO
    end,
    
    is_normal = function()
        local spd_1, spd_2 = ecam_sts:get_max_speed()
        local max_fl = ecam_sts:get_max_fl()

        return spd_1 == 0 and spd_2 == 0 and max_fl == 0 and #ecam_sts:get_appr_proc() == 0 and
               #ecam_sts:get_information() == 0 and #ecam_sts:get_cancelled_cautions() == 0 and
               #ecam_sts:get_inop_sys() == 0
    end,
    
    is_normal_maintenance = function()
        return #ecam_sts:get_maintenance() == 0
    end
    
}

