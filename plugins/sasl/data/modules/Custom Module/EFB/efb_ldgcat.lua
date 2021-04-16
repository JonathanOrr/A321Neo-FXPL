local landing_distance_config_full = {
    {   {58, 1310}, --DRY (1)
        {62, 1360},
        {66, 1410},
        {70, 1460},
        {74,1510},
        {80, 1620},
        {85, 1750},
        {90,1900},},
    {   {58, 1500}, --WET (2)
        {62, 1560},
        {66, 1620},
        {70, 1680},
        {74, 1740},
        {80, 1860},
        {85, 2010},
        {90, 2190},},
    {   {58, 1410},--COMPACTED SNOW (3)
        {62, 1490},
        {66, 1560},
        {70, 1630},
        {74, 1700},
        {80, 1800},
        {85, 1880},
        {90, 1970},},
    {   {58, 1580}, --DRY_WET_SNOW (4)
        {62, 1660},
        {66, 1750},
        {70, 1830},
        {74, 1900},
        {80, 2020},
        {85, 2110},
        {90, 2210},},
    {   {58, 1490}, --SLUSH (5)
        {62, 1580},
        {66, 1670},
        {70, 1760},
        {74, 1850},
        {80, 1990},
        {85, 2120},
        {90, 2250},},
    {   {58, 1530}, --STANDING WATER (6)
        {62, 1620},
        {66, 1720},
        {70, 1810},
        {74, 1900},
        {80, 2050},
        {85, 2190},
        {90, 2320},},
    }
    
local landing_distance_config_3 = {
    {   {58, 1420}, --DRY (1)
        {62, 1470},
        {66, 1530},
        {70, 1590},
        {74, 1650},
        {80, 1810},
        {85, 1980},
        {90, 2170},},
    {   {58, 1630}, --WET (2)
        {62, 1690},
        {66, 1760},
        {70, 1830},
        {74, 1900},
        {80, 2080},
        {85, 2270},
        {90, 2500},},
    {   {58, 1580},--COMPACTED SNOW (3)
        {62, 1660},
        {66, 1750},
        {70, 1830},
        {74, 1900},
        {80, 2010},
        {85, 2110},
        {90, 2210},},
    {   {58, 1780}, --DRY_WET_SNOW (4)
        {62, 1870},
        {66, 1970},
        {70, 2060},
        {74, 2140},
        {80, 2270},
        {85, 2380},
        {90, 2490},},
    {   {58, 1700}, --SLUSH (5)
        {62, 1800},
        {66, 1910},
        {70, 2030},
        {74, 2150},
        {80, 2320},
        {85, 2470},
        {90, 2640},},
    {   {58, 1740}, --STANDING WATER (6)
        {62, 1850},
        {66, 1960},
        {70, 2090},
        {74, 2210},
        {80, 2390},
        {85, 2550},
        {90, 2720},},
    }
    

--CONDITION 1-6, AIRCRAFT WEIGHT IN KG, ELEVATION IN FT, vapp_difference = VAPP-VLS, TAILWIND IN KT, REVERSE OPERATIVE 0-2, AUTOLAND BOOLEAN, CONFIG3 BOOLEAN
function landing_distance(condition, aircraft_weight, vapp_difference,  tailwind, reversers_number, autoland, config3) 
    local altitude_corr = 0
    if condition == 1 then
        altitude_corr = (get(TOPCAT_ldgrwy_elev)/1000)*130
    elseif condition == 2 then
        altitude_corr = (get(TOPCAT_ldgrwy_elev)/1000)*150
    elseif condition == 3 then
        altitude_corr = (get(TOPCAT_ldgrwy_elev)/1000)*120
    elseif condition == 4 then
        altitude_corr = (get(TOPCAT_ldgrwy_elev)/1000)*140
    elseif condition == 5 then
        altitude_corr = (get(TOPCAT_ldgrwy_elev)/1000)*220
    elseif condition == 6 then
        altitude_corr = (get(TOPCAT_ldgrwy_elev)/1000)*200
    end

    local speed_corr = 0
    if condition == 1 then
        speed_corr = ( vapp_difference/5)*150
    elseif condition == 2 then
        speed_corr = ( vapp_difference/5)*170
    elseif condition == 3 then
        speed_corr = ( vapp_difference/5)*110
    elseif condition == 4 then
        speed_corr = ( vapp_difference/5)*120
    elseif condition == 5 then
        speed_corr = ( vapp_difference/5)*170
    elseif condition == 6 then
        speed_corr = ( vapp_difference/5)*210
    end

    local tailwind_corr = 0
    if tailwind > 0 then
        if condition == 1 then
            tailwind_corr = (tailwind/5)*250
        elseif condition == 2 then
            tailwind_corr = (tailwind/5)*280
        elseif condition == 3 then
            tailwind_corr = (tailwind/5)*170
        elseif condition == 4 then
            tailwind_corr = (tailwind/5)*210
        elseif condition == 5 then
            tailwind_corr = (tailwind/5)*320
        elseif condition == 6 then
            tailwind_corr = (tailwind/5)*400
        end
    end

    local reverse_corr = 0
    if condition ==  3 then
        reverse_corr = reversers_number * -110
    elseif condition ==  4 then
        reverse_corr = reversers_number * -160
    elseif condition ==  5 then
        reverse_corr = reversers_number * -150
    elseif condition ==  6 then
        reverse_corr = reversers_number * -150
    else
        reverse_corr = 0
    end

    local autoland_corr = 0
    if autoland == 1 then
        if aircraft_weight < 60000 then
            if config3 == 1 then
                autoland_corr = 190
            else
                autoland_corr = 120
            end
        elseif aircraft_weight >= 60000 and aircraft_weight < 70000 then
            if config3 == 1 then
                autoland_corr = 90
            else
                autoland_corr = 69
            end
        elseif aircraft_weight >= 60000 and aircraft_weight > 70000 then --CONFIG 3 INHIBITED ABOVE 70000kg
            if config3 == 0 then
                autoland_corr = 85
            end
        end
    end

    local original_will_flap_corr = 0    
    if config3 == 1 then
        original_will_flap_corr = Table_extrapolate(landing_distance_config_3[condition], aircraft_weight/1000)
    elseif config3 == 0 then
        original_will_flap_corr = Table_extrapolate(landing_distance_config_full[condition], aircraft_weight/1000)
    end

    print(original_will_flap_corr,  altitude_corr, speed_corr, tailwind_corr, reverse_corr, autoland_corr)

    local landing_distance = 
     original_will_flap_corr
    + altitude_corr
    + speed_corr
    + tailwind_corr
    + reverse_corr
    + autoland_corr
    
    --------------------------------------------------------------------------------BELOW ARE FOR AUTOBRAKE WITH FIXED DECELLERATION.

    local vref_table_cfg3 = {
        {40, 115},
        {45, 116},
        {50, 123},
        {55, 129},
        {60, 135},
        {65, 140},
        {70, 145},
        {75, 150},
        {80, 155},
    }
    local vref_table_cfgf = {
        {40, 115},
        {45, 115},
        {50, 115},
        {55, 119},
        {60, 124},
        {65, 129},
        {70, 134},
        {75, 139},
        {80, 143},
    }

    local vref_cfgf_in_ms = ( Table_extrapolate(vref_table_cfgf, aircraft_weight/1000) + vapp_difference  )/1.944
    print(vref_cfgf_in_ms)
    local landing_distance_med_ab = (vref_cfgf_in_ms ^ 2) / 6 + 604 + 80 + vref_cfgf_in_ms * 2          + autoland_corr
    local landing_distance_low_ab = ((vref_cfgf_in_ms^ 2)) / 3.4 + 504 + 80 + vref_cfgf_in_ms * 4       + autoland_corr

    return landing_distance, math.max(landing_distance_med_ab, landing_distance), landing_distance_low_ab
end

--FAILURE CODE

local failure_refrence_table = { --FLAPS LEVER POS, DELTA VREF, LDG DISTANCE FACTOR, IS-ASTERISK
    {3, 10, 2, 0}, --ELEC
    {4, 0, 1.7, 0},
    {4, 0, 1.5, 0},
    {4, 0, 1.15, 0},
    {4, 0, 1, 0},
    {4, 0, 1.1, 0},
    {3, 10, 1.2, 1}, --FLIGHT CONTROL
    {4, 0, 1.1, 0},
    {4, 0, 1.1, 0},
    {4, 0, 1.35, 0},
    {4, 0, 1.1, 0},
    {4, 0, 1, 0},
    {4, 0, 1.2, 0},
    {4, 0, 1.4, 0},
    {3, 10, 1.6, 0},
    {1, 60, 1.8, 1},--FLAPS_SLATS 0
    {3, 45, 1.8, 1}, --FLAPS 0-1
    {3, 25, 1.3, 1}, 
    {3, 30, 1.4, 1},--FLAPS 1-2
    {3, 15, 1.2, 1},
    {3, 25, 1.35, 1}, --FLAPS 2
    {3, 10, 1.15, 1},
    {3, 25, 1.35, 1}, --FLAPS 3
    {3, 10, 1.15, 1},
    {3, 5, 1.1, 1},
    {4, 0, 1, 0}, --FLAPS >3
    {4, 10, 1.15, 1},
    {4, 5, 1.1, 1},
    {4, 0, 1.1, 0}, --HYD
    {4, 0, 1, 0},
    {3, 25, 1.6, 0},
    {3, 25, 2.6, 0},
    {4, 0, 1.5, 0},
    {4, 0, 1.5, 0}, --BRK
    {4, 0, 1.1, 0},
    {3, 10, 1.2, 1}, --NAV
    {3, 10, 1.2, 1},
    {3, 10, 1.2, 1},
    {3, 10, 2.35, 0},
    {1, 55, 1.75, 1},--ENG
    {3, 10, 1.2, 1},
}

function failure_correction(failure_code_array) --CODE == 0 IS RESERVED FOR NO FAILURE

      local final_flaps   = 4
      local final_vref    = 0
      local ldg_dist_max  = 0
    local ldg_dist_mult = 1
      local dont_multiply = true
  
    for k,v in ipairs(failure_code_array) do
        if v ~= 0 then
            local reccomended_flaps = failure_refrence_table[v][1]
              local delta_vref = failure_refrence_table[v][2]
              local ldg_distance_factor = failure_refrence_table[v][3]
              local asterisk = failure_refrence_table[v][4] == 1
              
              final_flaps = math.min(final_flaps, reccomended_flaps)
              final_vref  = math.max(final_vref, delta_vref)
              ldg_dist_max = math.max(ldg_dist_max, ldg_distance_factor)
              ldg_dist_mult= ldg_dist_mult * ldg_distance_factor
              dont_multiply = dont_multiply and asterisk
        end
    end

      local ret_ldg_dist = 0
    if dont_multiply then
        ret_ldg_dist = ldg_dist_max
    else
        ret_ldg_dist = ldg_dist_mult
    end

    return final_flaps, final_vref, math.max(ret_ldg_dist, 1)
end


