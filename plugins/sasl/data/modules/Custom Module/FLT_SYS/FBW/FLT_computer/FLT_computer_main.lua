addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/FLT_computer")

FBW.FLT_computer = {}

FBW.FLT_computer.common = {
    main = {
        Startup = function (computer_table)
            for i = 1, #computer_table do
                --find power delta--
                local POWER_DELTA = BoolToNum(computer_table[i].Power()) - computer_table[i].Last_power_status
                local BUTTTON_DELTA = get(computer_table[i].Button_dataref) - computer_table[i].Last_button_status
                local COMPUTER_STATUS_DELTA = get(computer_table[i].Status_dataref) - computer_table[i].Last_computer_status
                computer_table[i].Last_power_status = BoolToNum(computer_table[i].Power())
                computer_table[i].Last_button_status = get(computer_table[i].Button_dataref)
                computer_table[i].Last_computer_status = get(computer_table[i].Status_dataref)

                --inital status--
                set(computer_table[i].Status_dataref, 0)

                --find required start time--
                local START_TIME, TIMER_MAX = computer_table[i].Test_time()

                --transient reset--
                local TRANSIENT_LENGTH = computer_table[i].Transient_end_time - computer_table[i].Transient_str_time
                if POWER_DELTA == 1 and computer_table[i].Transient_reset_required then
                    computer_table[i].Transient_end_time = get(TIME)
                end
                if POWER_DELTA == -1 and computer_table[i].Transient_reset_required then
                    computer_table[i].Transient_str_time = get(TIME)
                    if TRANSIENT_LENGTH >= 0.025 and get(Any_wheel_on_ground) == 0 then
                        computer_table[i].Transient_reset_pending = true
                    end
                end
                if BUTTTON_DELTA == -1 and computer_table[i].Transient_reset_pending then
                    computer_table[i].Transient_reset_pending = false
                end

                --IR not self detected ELAC reset--
                if computer_table[i].IR_reset_required then
                    if adirs_how_many_irs_fully_work() >= 2 and adirs_ir_disagree() then
                        computer_table[i].IR_reset_pending = true
                    end
                end
                if COMPUTER_STATUS_DELTA == - 1 then
                    computer_table[i].IR_reset_pending = false
                end

                --button set to on--
                if get(computer_table[i].Button_dataref) == 0 then
                    if computer_table[i].Start_timer < TIMER_MAX then
                        computer_table[i].Start_timer = computer_table[i].Start_timer + get(DELTA_TIME)
                    end
                end

                --turn off computer--
                if (get(computer_table[i].Button_dataref) == 1) or
                   (not computer_table[i].Power()) or
                   computer_table[i].Transient_reset_pending or
                   (get(computer_table[i].Failure_dataref) == 1) then
                    computer_table[i].Start_timer = 0
                end

                --set system status--
                if computer_table[i].Start_timer >= START_TIME then
                    set(computer_table[i].Status_dataref, 1)
                end

                if get(Print_print_main_fcc_status) == 1 then
                    print("COMPUTER " .. i .. ":")
                    print("RESTART TIME LEFT:       " .. tostring(START_TIME - computer_table[i].Start_timer))
                    print("POWERED:                 " .. tostring(computer_table[i].Power()))
                    print("TRANSIENT LENGTH:        " .. TRANSIENT_LENGTH)
                    print("PENDING TRANSIENT RESET: " .. tostring(computer_table[i].Transient_reset_pending))
                    print("PENDING IR RESET:        " .. tostring(computer_table[i].IR_reset_pending))
                end
            end
        end,

        Button_status = function (computer_table)
            for i = 1, #computer_table do
                local FAULT_status = get(computer_table[i].Status_dataref) ~= (1 - get(computer_table[i].Button_dataref)) or computer_table[i].IR_reset_pending
                local OFF_status = get(computer_table[i].Button_dataref) == 1
                pb_set(computer_table[i].Button_address, OFF_status, FAULT_status)
            end
        end
    },

    misc = {
        Startup = function (computer_table)
            for i = 1, #computer_table do
                --inital status--
                set(computer_table[i].Status_dataref, 1)

                --turn off computer--
                if (get(computer_table[i].Button_dataref) == 1) or
                   (not computer_table[i].Power()) or
                   (get(computer_table[i].Failure_dataref) == 1) then
                    set(computer_table[i].Status_dataref, 0)
                end
            end
        end,
    }
}

components = {
    FLT_computer_cmd {},
    ELACs {},
    SECs  {},
    SFCCs {},
    FCDCs {},
}

function update()
    updateAll(components)
    FBW.FLT_computer.common.main.Startup(FBW.FLT_computer.ELAC)
    FBW.FLT_computer.common.main.Button_status(FBW.FLT_computer.ELAC)
    FBW.FLT_computer.common.main.Startup(FBW.FLT_computer.SEC)
    FBW.FLT_computer.common.main.Button_status(FBW.FLT_computer.SEC)

    FBW.FLT_computer.common.misc.Startup(FBW.FLT_computer.SFCC)
    FBW.FLT_computer.common.misc.Startup(FBW.FLT_computer.FCDC)
end