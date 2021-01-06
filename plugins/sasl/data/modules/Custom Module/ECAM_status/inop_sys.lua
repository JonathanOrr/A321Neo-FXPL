include('constants.lua')

local function put_inop_sys_msg_2(messages, dr_1, dr_2, title)
    if get(dr_1) == 0 and get(dr_2) == 0 then
        table.insert(messages, title .. " 1 + 2")
    elseif get(dr_1) == 0 then
        table.insert(messages, title .. " 1")
    elseif get(dr_2) == 0 then
        table.insert(messages, title .. " 2")
    end
end

local function put_inop_sys_msg_3(messages, dr_1, dr_2, dr_3, title)
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




function ECAM_status_get_inop_sys()

        local messages = {}

        local inop_cat3_dual = false
        local inop_steer = false
        local inop_aps   = false
        local inop_atr   = false

        -- AIR
        --put_inop_sys_msg_2(messages, Left_bleed_avil, Right_bleed_avil, "PACK")

        -- ELAC / SEC / FAC
        put_inop_sys_msg_2(messages, ELAC_1_status, ELAC_2_status, "ELAC")
        put_inop_sys_msg_3(messages, SEC_1_status, SEC_2_status, SEC_3_status, "SEC")
        put_inop_sys_msg_2(messages, FAC_1_status, FAC_2_status, "FAC")

        -- FBW
        if get(FBW_status) < 2 then
            table.insert(messages, "F/CTL PROT")
        end

        -- ELEC
        --put_inop_sys_msg_2(messages, Gen_1_on, Gen_2_on, "GEN")

        -- ENGINES and APU
        --if get(FAILURE_Apu) == 6 or get(FAILURE_Apu_fire) == 6 then
        --    table.insert(messages, "APU")
        --end

        -- L/G
        --if get(FAILURE_gear) == 1 then
        --    table.insert(messages, "L/G RETRACT")
        --elseif get(FAILURE_gear) == 2 then
        --    inop_steer = true
        --    inop_cat3_dual = true
        --end


        --if get(FAILURE_TCAS) == 6 then
        --    table.insert(messages, "TCAS")                
        --end

        --if get(Nosewheel_Steering_working) then
        --    inop_steer = true
        --end


--        if get(Nosewheel_Steering_and_AS) == 0 then
--            table.insert(messages, "ANTI SKID")
--            table.insert(messages, "BSCU CH 1")
--            table.insert(messages, "BSCU CH 2")
--            inop_cat3_dual = true            
--        end

        --[[if MessageGroup_ADR_FAULT_SINGLE:is_active() then
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
        
        --if MessageGroup_ADR_FAULT_TRIPLE:is_active() then
        --    table.insert(messages, "ADR 1 + 2 + 3")
        --    table.insert(messages, "RUD TRV LIM")
        --    table.insert(messages, "WINDSHEAR DET")
        --    inop_cat3_dual = true
        --    inop_aps = true
        --    inop_atr = true
        --end
 
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
        
        --if MessageGroup_IR_FAULT_TRIPLE:is_active() then
        --    table.insert(messages, "IR 1 + 2 + 3")
        --    table.insert(messages, "YAW DAMPER")
        --    inop_cat3_dual = true
        --    inop_aps = true
        --    inop_atr = true
        --end
        ]]--
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
    end
    
