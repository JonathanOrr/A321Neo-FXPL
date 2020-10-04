

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
    
    -- FADEC and engine related stuffs
    if get(Eng_1_Fire_valve) == 0 then
        -- FADEC has power if fire valve is open
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS_SHED, 0.5, 0.5)
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_BAT_BUS, 0.5, 0.5)
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_1, 0.05, 0.05)
    end
    if get(Eng_2_Fire_valve) == 0 then
        -- FADEC has power if fire valve is open
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS_SHED, 0.5, 0.5)
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0.55, 0.55)
    end
    if get(Engine_mode_knob) == 1 then    -- Ignition mode
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 0.1, 0.1)
        if get(Engine_1_avail) == 0 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 1, 1.2)
        end
        if get(Engine_2_avail) == 0 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 1, 1.2)
        end
    end
    
    -- Staring APU
    if get(Apu_master_button_state) == 1 then    
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_BAT_BUS, 0.5, 0.5)   -- Control unit
    
        --if get(Apu_N1) < 10 then    -- Starter motor
        --    ELEC_sys.add_power_consumption(ELEC_BUS_DC_BAT_BUS, 70, 90) -- Like an car engine?
        --elseif get(Apu_N1) < 90 then
        --    ELEC_sys.add_power_consumption(ELEC_BUS_DC_BAT_BUS, 2, 2)
        --end
    end
    
    -- BLEED computers
    ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS_SHED, 0.5, 0.5)
    ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0.5, 0.5)
    
    -- Autopilot
    ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS_SHED, 0.5, 0.5)
    ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 0.5, 0.5)
    ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 1, 1)

    -- FBW computers
    if get(ELAC_1_status) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 0.5, 0.5)
    end
    if get(ELAC_2_status) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0.5, 0.5)
    end
    if get(SEC_1_status) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 0.5, 0.5)
    end
    if get(SEC_2_status) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0.5, 0.5)
    end
    if get(SEC_3_status) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0.5, 0.5)
    end   
    if get(FAC_1_status) == 1 then
       ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS_SHED, 0.5, 0.5)
       ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 0.05, 0.05)
    end
    if get(FAC_2_status) == 1 then
       ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0.5, 0.5)
       ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.05, 0.05)
    end
    -- Flap and slats ocmputer
    ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 0.5, 0.5)
    ELEC_sys.add_power_consumption(ELEC_BUS_DC_2, 0.5, 0.5)
    
    
    
end
