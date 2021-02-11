function set_fuel(total_fuel)

    assert(total_fuel <= FUEL_TOT_MAX and total_fuel >= 0)

    -- Please refer to fuel.lua to understand this logic

    for i=0,4 do
        set(Fuel_quantity[i], 0)
    end

    if total_fuel <= 2 * FUEL_LR_MAX then   -- Wing only
        set(Fuel_quantity[tank_LEFT], total_fuel / 2)
        set(Fuel_quantity[tank_RIGHT], total_fuel / 2)
    elseif total_fuel <= 2 * FUEL_LR_MAX + FUEL_C_MAX then  -- Wing + CTR
        set(Fuel_quantity[tank_LEFT], FUEL_LR_MAX)
        set(Fuel_quantity[tank_RIGHT], FUEL_LR_MAX)
        set(Fuel_quantity[tank_CENTER], total_fuel - 2*FUEL_LR_MAX)
    else    -- Wing and CTR full, let's go with others
        set(Fuel_quantity[tank_LEFT], FUEL_LR_MAX)
        set(Fuel_quantity[tank_RIGHT], FUEL_LR_MAX)
        set(Fuel_quantity[tank_CENTER], FUEL_C_MAX)

        local remaining_fuel = total_fuel - 2*FUEL_LR_MAX - FUEL_C_MAX

        print(remaining_fuel)

        if remaining_fuel <= 0.75*FUEL_RCT_MAX then -- <= 75% RCT 0% ACT
            set(Fuel_quantity[tank_RCT], remaining_fuel)
        elseif remaining_fuel <= 0.75*FUEL_RCT_MAX+0.5*FUEL_ACT_MAX then -- 75% RCT <= 50% ACT
            set(Fuel_quantity[tank_RCT], 0.75*FUEL_RCT_MAX)
            set(Fuel_quantity[tank_ACT], remaining_fuel - 0.75*FUEL_RCT_MAX)
        elseif remaining_fuel <= FUEL_RCT_MAX+0.5*FUEL_ACT_MAX then -- <= 100% RCT 50% ACT
            set(Fuel_quantity[tank_RCT], remaining_fuel - 0.5*FUEL_ACT_MAX)
            set(Fuel_quantity[tank_ACT], 0.5*FUEL_ACT_MAX)
        else     -- 100% RCT <= 100% ACT
            set(Fuel_quantity[tank_RCT], FUEL_RCT_MAX)
            set(Fuel_quantity[tank_ACT], remaining_fuel - FUEL_RCT_MAX)
        end
    end

end
