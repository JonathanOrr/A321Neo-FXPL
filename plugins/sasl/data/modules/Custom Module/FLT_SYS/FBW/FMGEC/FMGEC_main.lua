addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/FMGEC")

FBW.FMGEC = {}
FBW.FMGEC.FMGEC_1 = {}
FBW.FMGEC.FMGEC_2 = {}
FBW.FMGEC.MIXED = {}

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
        print("FMGEC 1:")
        for key, value in pairs(FBW.FMGEC.FMGEC_1) do
            print(key .. ": " .. tostring(value))
        end
        print("FMGEC 2:")
        for key, value in pairs(FBW.FMGEC.FMGEC_2) do
            print(key .. ": " .. tostring(value))
        end
        print("MIXED:")
        for key, value in pairs(FBW.FMGEC.MIXED) do
            print(key .. ": " .. tostring(value))
        end
    end
end