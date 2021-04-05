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
function landing_distance(condition, aircraft_weight, elevation, vapp_difference,  tailwind, reversers_number, isautoland, isconfig3) 
    if condition == 1 then
        local altitude_corr = (get(ACF_elevation)/1000)*130
    elseif condition == 2 then
        local altitude_corr = (get(ACF_elevation)/1000)*150
    elseif condition == 3 then
        local altitude_corr = (get(ACF_elevation)/1000)*120
    elseif condition == 4 then
        local altitude_corr = (get(ACF_elevation)/1000)*140
    elseif condition == 5 then
        local altitude_corr = (get(ACF_elevation)/1000)*220
    elseif condition == 6 then
        local altitude_corr = (get(ACF_elevation)/1000)*200
    end

    if condition == 1 then
        local speed_corr = ( vapp_difference/5)*150
    elseif condition == 2 then
        local speed_corr = ( vapp_difference/5)*170
    elseif condition == 3 then
        local speed_corr = ( vapp_difference/5)*110
    elseif condition == 4 then
        local speed_corr = ( vapp_difference/5)*120
    elseif condition == 5 then
        local speed_corr = ( vapp_difference/5)*170
    elseif condition == 6 then
        local speed_corr = ( vapp_difference/5)*210
    end

    if tailwind > 0 then
        if condition == 1 then
            local tailwind_corr = (tailwind/5)*250
        elseif condition == 2 then
            local tailwind_corr = (tailwind/5)*280
        elseif condition == 3 then
            local tailwind_corr = (tailwind/5)*170
        elseif condition == 4 then
            local tailwind_corr = (tailwind/5)*210
        elseif condition == 5 then
            local tailwind_corr = (tailwind/5)*320
        elseif condition == 6 then
            local tailwind_corr = (tailwind/5)*400
        end
    end

    if condition ==  3
        local reverse_corr = reversers_number * -110
    elseif condition ==  4
        local reverse_corr = reversers_number * -160
    elseif condition ==  5
        local reverse_corr = reversers_number * -150
    elseif condition ==  6
        local reverse_corr = reversers_number * -150
    else
        local reverse_corr = 0
    end

    if isautoland then
        if aircraft_weight < 60000 then
            if isconfig3 then
                local autoland_corr = 190
            else
                local autoland_corr = 120
            end
        elseif aircraft_weight >= 60000 and aircraft_weight < 70000 then
            if isconfig3 then
                local autoland_corr = 90
            else
                local autoland_corr = 69
            end
        elseif aircraft_weight >= 60000 and aircraft_weight > 70000 then --CONFIG 3 INHIBITED ABOVE 70000kg
            if not isconfig3 then
                local autoland_corr = 85
            end
        end
    end
    
    if isconfig3 then
        local original_will_flap_corr = Table_extrapolate(landing_distance_config_3[condition], aircraft_weight)
    else
        local original_will_flap_corr = Table_extrapolate(landing_distance_config_full[condition], aircraft_weight)
    end

    local landing_distance = 

    + original_will_flap_corr
    + altitude_corr
    + speed_corr
    + tailwind_corr
    + reverse_corr
    + autoland_corr

    return landing_distance
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
    {3, 10, 2.35, 0},
    {1, 55, 1.75, 1},--ENG
    {3, 10, 1.2, 1},
}

function failure_correction(failure_code_array) --CODE == 0 IS RESERVED FOR NO FAILURE

    local recommended_flaps1 = failure_refrence_table[failure_code_array[1]][1]
    local recommended_flaps2 = failure_refrence_table[failure_code_array[2]][1]
    local recommended_flaps3 = failure_refrence_table[failure_code_array[3]][1]
    local recommended_flaps4 = failure_refrence_table[failure_code_array[4]][1]
    local recommended_flaps_final = math.max(recommended_flaps1, recommended_flaps2, recommended_flaps3, recommended_flaps4)

    local delta_vref1 = failure_refrence_table[failure_code_array[1]][2]
    local delta_vref2 = failure_refrence_table[failure_code_array[2]][2]
    local delta_vref3 = failure_refrence_table[failure_code_array[3]][2]
    local delta_vref4 = failure_refrence_table[failure_code_array[4]][2]
    local vref_final = math.max(delta_vref1, delta_vref2, delta_vref3, delta_vref4)

    local ldg_distance_factor1 = failure_refrence_table[failure_code_array[1]][3]
    local ldg_distance_factor2 = failure_refrence_table[failure_code_array[2]][3]
    local ldg_distance_factor3 = failure_refrence_table[failure_code_array[3]][3]
    local ldg_distance_factor4 = failure_refrence_table[failure_code_array[4]][3]

    if failure_code_array[1] == 1 or failure_code_array[2] == 1 or failure_code_array[3] == 1 or failure_code_array[4] == 1
        local ldg_distance_factor_final = ldg_distance_factor1 + ldg_distance_factor2 + ldg_distance_factor3 + ldg_distance_factor4
    else
        local ldg_distance_factor_final = ldg_distance_factor1 * ldg_distance_factor2 * ldg_distance_factor3 * ldg_distance_factor4
    end

    return recommended_flaps_final, vref_final, ldg_distance_factor_final
end
    