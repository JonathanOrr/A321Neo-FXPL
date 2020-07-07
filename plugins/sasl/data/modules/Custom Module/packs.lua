--sim datarefs

--a32nx datarefs

function update()
    if get(Engine_1_avail) == 1 or get(Engine_mode_knob) == 1 then
        set(L_HP_valve, 0)
        if get(X_bleed_valve) == 1 then
            set(Pack_L, 0)
        else
            set(Pack_L, 1)
        end
    else
        set(L_HP_valve, 1)
    end
    
    --Engine_2_avail
end