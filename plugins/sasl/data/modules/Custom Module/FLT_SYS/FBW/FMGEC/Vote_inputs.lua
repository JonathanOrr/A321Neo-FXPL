local function FAC_AOA_SRC_CHK()
    --Check the status of all AoA data source
    local SRC_1_WORKING = (ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[1].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_CAPT) == 0
    local SRC_2_WORKING = (ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[2].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_FO) == 0
    local SRC_3_WORKING = (ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[3].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_STBY) == 0

    if adirs_how_many_aoa_working() <= 1 then
        return SRC_1_WORKING, SRC_2_WORKING, SRC_3_WORKING
    end

    local SRC_1_VALID = false
    local SRC_2_VALID = false
    local SRC_3_VALID = false

    if SRC_1_WORKING then
        SRC_1_VALID = adirs_is_aoa_valid(1)
    end
    if SRC_2_WORKING then
        SRC_2_VALID = adirs_is_aoa_valid(2)
    end
    if SRC_3_WORKING then
        SRC_3_VALID = adirs_is_aoa_valid(3)
    end

    return SRC_1_VALID, SRC_2_VALID, SRC_3_VALID
end

local function FAC_ADR_SRC_CHK()
    --Check the status of all air data source
    local SRC_1_WORKING = ADIRS_sys[1].adr_status == ADR_STATUS_ON
    local SRC_2_WORKING = ADIRS_sys[2].adr_status == ADR_STATUS_ON
    local SRC_3_WORKING = ADIRS_sys[3].adr_status == ADR_STATUS_ON

    if adirs_how_many_adrs_work() <= 1 then
        return SRC_1_WORKING, SRC_2_WORKING, SRC_3_WORKING
    end

    local SRC_1_VALID = false
    local SRC_2_VALID = false
    local SRC_3_VALID = false

    if SRC_1_WORKING then
        SRC_1_VALID = adirs_is_adr_valid(1)
    end
    if SRC_2_WORKING then
        SRC_2_VALID = adirs_is_adr_valid(2)
    end
    if SRC_3_WORKING then
        SRC_3_VALID = adirs_is_adr_valid(3)
    end

    return SRC_1_VALID, SRC_2_VALID, SRC_3_VALID
end

local function FAC_PROCESS_INPUT(SRC, INPUT)
    for key, value_1 in pairs(SRC) do
        for index, value_2 in pairs(SRC[key]) do
            if value_2 then
                INPUT[key].SUM = INPUT[key].SUM + ADIRS_sys[index][key]
                INPUT[key].AVAIL = INPUT[key].AVAIL + 1
                INPUT[key].SRC[#INPUT[key].SRC + 1] = index
            end
        end
    end
end

local function FAC_VALIDATE_AVG_INPUT(INPUT)
    for key, value_1 in pairs(INPUT) do
        if INPUT[key].AVAIL == 0 then
            INPUT[key].INPUT = 0

            return false
        end

        INPUT[key].INPUT = INPUT[key].SUM / INPUT[key].AVAIL
    end

    return true
end

local function FAC_INPUT_SRC_DEBUG(INPUT, COMPUTER)
    if get(Print_mixed_fac_input) == 0 then
        return
    end

    print(" ")
    print(COMPUTER .. ":")
    for key, value_1 in pairs(INPUT) do
        print(key .. " source:")
        if #INPUT[key].SRC == 0 then
          print("INVALID")
        end
        for i = 1, #INPUT[key].SRC do
            print(INPUT[key].SRC[i])
        end
    end
end

local function FAC_OUTPUT(INPUT, FAC_VALID)
    local OUTPUT = {}

    for key, value_1 in pairs(INPUT) do
        OUTPUT[key] = INPUT[key].INPUT
    end

    OUTPUT.VALID = FAC_VALID

    return OUTPUT
end

local function FAC_MIXED_OUTPUT(FAC_1_INPUT, FAC_2_INPUT)
    local OUTPUT = {}

    for key, value_1 in pairs(FAC_1_INPUT) do
        local TOTAL_VALID = FAC_1_INPUT[key].AVAIL + FAC_2_INPUT[key].AVAIL

        if TOTAL_VALID == 0 then
            OUTPUT[key] = 0
        else
            OUTPUT[key] = (FAC_1_INPUT[key].SUM + FAC_2_INPUT[key].SUM) / TOTAL_VALID
        end
    end

    return OUTPUT
end

local function FAC_VOTE_INPUTS()
    local AOA_1_VALID, AOA_2_VALID, AOA_3_VALID = FAC_AOA_SRC_CHK()
    local ADR_1_VALID, ADR_2_VALID, ADR_3_VALID = FAC_ADR_SRC_CHK()

    local FAC_1_SRC = {
        aoa  = {[1] = AOA_1_VALID, [3] = AOA_3_VALID},
        ias  = {[1] = ADR_1_VALID, [3] = ADR_3_VALID},
        mach = {[1] = ADR_1_VALID, [3] = ADR_3_VALID},
    }
    local FAC_2_SRC = {
        aoa  = {[2] = AOA_2_VALID, [3] = AOA_3_VALID},
        ias  = {[2] = ADR_2_VALID, [3] = ADR_3_VALID},
        mach = {[2] = ADR_2_VALID, [3] = ADR_3_VALID},
    }

    local FAC_1_INPUT = {
        aoa  = {AVAIL = 0, SUM = 0, INPUT = 0, SRC = {}},
        ias  = {AVAIL = 0, SUM = 0, INPUT = 0, SRC = {}},
        mach = {AVAIL = 0, SUM = 0, INPUT = 0, SRC = {}},
    }
    local FAC_2_INPUT = {
        aoa  = {AVAIL = 0, SUM = 0, INPUT = 0, SRC = {}},
        ias  = {AVAIL = 0, SUM = 0, INPUT = 0, SRC = {}},
        mach = {AVAIL = 0, SUM = 0, INPUT = 0, SRC = {}},
    }

    FAC_PROCESS_INPUT(FAC_1_SRC, FAC_1_INPUT)
    FAC_PROCESS_INPUT(FAC_2_SRC, FAC_2_INPUT)

    local FAC_1_VALID = FAC_VALIDATE_AVG_INPUT(FAC_1_INPUT)
    local FAC_2_VALID = FAC_VALIDATE_AVG_INPUT(FAC_2_INPUT)

    FAC_INPUT_SRC_DEBUG(FAC_1_INPUT, "FAC 1")
    FAC_INPUT_SRC_DEBUG(FAC_2_INPUT, "FAC 2")

    FBW.FMGEC.FMGEC_1 = FAC_OUTPUT(FAC_1_INPUT, FAC_1_VALID)
    FBW.FMGEC.FMGEC_2 = FAC_OUTPUT(FAC_2_INPUT, FAC_2_VALID)
    FBW.FMGEC.MIXED = FAC_MIXED_OUTPUT(FAC_1_INPUT, FAC_2_INPUT)
end

function update()
    FAC_VOTE_INPUTS()
end