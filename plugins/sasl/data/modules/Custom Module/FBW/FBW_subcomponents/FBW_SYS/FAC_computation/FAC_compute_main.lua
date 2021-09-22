addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/FAC_computation")

FBW.FAC_COMPUTATION = {}
FBW.FAC_COMPUTATION.FAC_1 = {}
FBW.FAC_COMPUTATION.FAC_2 = {}
FBW.FAC_COMPUTATION.MIXED = {}

components = {
    Vote_inputs {},
    SPD_LIM_CHK {},
    Compute_VS1G {},
    Compute_AoA {},
    Compute_S_F_O {},
    Compute_VLS {},
    Compute_VMAX {},
    Compute_warnings {}
}

function update()
    updateAll(components)

    if get(Print_mixed_fac_input) == 1 then
        print("FAC 1:")
        for key, value in pairs(FBW.FAC_COMPUTATION.FAC_1) do
            print(key .. ": " .. tostring(value))
        end
        print("FAC 2:")
        for key, value in pairs(FBW.FAC_COMPUTATION.FAC_2) do
            print(key .. ": " .. tostring(value))
        end
        print("MIXED:")
        for key, value in pairs(FBW.FAC_COMPUTATION.MIXED) do
            print(key .. ": " .. tostring(value))
        end
    end
end