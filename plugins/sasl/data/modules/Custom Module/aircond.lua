--sim datarefs

--a32NX datarefs
local a321DR_hot_air = createGlobalPropertyi("a321neo/cockpit/aircond/hot_air", 1, false, true, false)
local a321DR_cockpit_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp_dial", 0.5, false, true, false) --cockpit temperature dial position
local a321DR_front_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp_dial", 0.5, false, true, false) --front cabin temperature dial position
local a321DR_aft_cab_temp_dial = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp_dial", 0.5, false, true, false) --aft cabin temperature dial position
local a321DR_cockpit_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp_req", 21, false, true, false) --requested cockpit temperature
local a321DR_front_cab_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp_req", 21, false, true, false) --requested front cabin temperature
local a321DR_aft_cab_temp_req = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp_req", 21, false, true, false) --requested aft cabin temperature
local a321DR_cockpit_temp = createGlobalPropertyf("a321neo/cockpit/aircond/cockpit_temp", 15, false, true, false) --actual cockpit temperature
local a321DR_front_cab_temp = createGlobalPropertyf("a321neo/cockpit/aircond/front_cab_temp", 15, false, true, false) --actual front cabin temperature
local a321DR_aft_cab_temp = createGlobalPropertyf("a321neo/cockpit/aircond/aft_cab_temp", 15, false, true, false) --actual aft cabin temperature

local function cond_off()
    --changing requested temperature to lowest temperature
    set(a321DR_cockpit_temp_req, Set_anim_value(get(a321DR_cockpit_temp_req), 12, 12, 30, 0.5))
    set(a321DR_front_cab_temp_req, Set_anim_value(get(a321DR_front_cab_temp_req), 12, 12, 30, 0.5))
    set(a321DR_aft_cab_temp_req, Set_anim_value(get(a321DR_aft_cab_temp_req), 12, 12, 30, 0.5))
    --changing actual temperature to outside temperatures
    set(a321DR_cockpit_temp, Set_anim_value(get(a321DR_cockpit_temp), get(OTA), -100, 100, 0.05))
    set(a321DR_front_cab_temp, Set_anim_value(get(a321DR_front_cab_temp), get(OTA), -100, 100, 0.05))
    set(a321DR_aft_cab_temp, Set_anim_value(get(a321DR_aft_cab_temp), get(OTA), -100, 100, 0.05))
end

function update()
    set(a321DR_cockpit_temp_dial, Math_clamp(get(a321DR_cockpit_temp_dial), 0, 1))
    set(a321DR_front_cab_temp_dial, Math_clamp(get(a321DR_front_cab_temp_dial), 0, 1))
    set(a321DR_aft_cab_temp_dial, Math_clamp(get(a321DR_aft_cab_temp_dial), 0, 1))

    if get(Left_bleed_avil) >= 0.85 or get(Mid_bleed_avil) >= 0.85 or get(Right_bleed_avil) >= 0.85 then
        if get(ENG_1_bleed_switch) == 1 or get(Apu_bleed_switch) == 1 or get(ENG_2_bleed_switch) == 1 then
            if get(a321DR_hot_air) == 1 then
                --changing requested temperature to dialed in temperatures
                set(a321DR_cockpit_temp_req, Set_anim_value(get(a321DR_cockpit_temp_req), 12 + 18 * get(a321DR_cockpit_temp_dial), 12, 30, 0.5))
                set(a321DR_front_cab_temp_req, Set_anim_value(get(a321DR_front_cab_temp_req), 12 + 18 * get(a321DR_front_cab_temp_dial), 12, 30, 0.5))
                set(a321DR_aft_cab_temp_req, Set_anim_value(get(a321DR_aft_cab_temp_req), 12 + 18 * get(a321DR_aft_cab_temp_dial), 12, 30, 0.5))
                --changing actual temperature to requested temperatures
                set(a321DR_cockpit_temp, Set_anim_value(get(a321DR_cockpit_temp), get(a321DR_cockpit_temp_req), 12, 30, 0.05))
                set(a321DR_front_cab_temp, Set_anim_value(get(a321DR_front_cab_temp), get(a321DR_front_cab_temp_req), 12, 30, 0.05))
                set(a321DR_aft_cab_temp, Set_anim_value(get(a321DR_aft_cab_temp), get(a321DR_aft_cab_temp_req), 12, 30, 0.05))
            else
                cond_off()
            end
        else
            cond_off()
        end
    else
        cond_off()
    end
end