

function update_consumptions()

    -- ND
    if get(AC_ess_shed_pwrd) == 1 then   -- TODO This should be fixed when screens move around
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS_SHED, 0.26, 0.26)   -- 30W (just hypothesis)
    end

    -- F/O PFD and ND
    if get(AC_bus_2_pwrd) == 1 then   -- TODO This should be fixed when screens move around
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.26*2, 0.26*2)   -- 30W (just hypothesis)
    end

    -- STDBY instruments
    if get(AC_ess_bus_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 1, 1)            -- Artificial horizon
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 0.25, 0.25)      -- Compass
    end
    if get(AC_ess_shed_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS_SHED, 0.25, 0.25) -- Artificial horizon
    end

    -- CVR recorder
    if get(AC_ess_shed_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS_SHED, 0.2, 0.2)
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS_SHED, 0.1, 0.1)
    end
end
