--local v2_table = {
--    r={pressalt=-2000, tow=54},
--}


v2_table = {
    {-2000,0},
    {-1000,0},
    {0,0},
    {1000,0},
    {2000,0},
    {3000,0},
    {4000,0},
    {5000,0},
    {6000,0},
    {7000,0},
    {8000,0},
    {9000,0},
    {10000,0},
}

flex_temp = 0
flex_temp_computed = 0
flex_temp_correction = 0
wet_correction = 0

computed_v1 = 0
computed_vr = 0
computed_v2 = 0

press_alt = 0
qnh = 0

static_load = 0
max_load = 0
cg_mac = 0




local function constant_conversions()
    qnh = get(Weather_curr_press_sea_level)*33.864,0
    press_alt = get(acf_msl)+30*(1013-qnh),-3
end


local function flex_calculation()
        flex_temp_computed = Round(-0.02434027806956361259*(get(acf_msl)/100)^3 + 0.36824311548836550021*(get(acf_msl)/100)^2 - 2.95963831628837229790*(get(acf_msl)/100) + 54.96994092387330948740, 0)

        if 1013-qnh < 0 then --if qnh > 1013
            flex_temp_correction = Round((qnh-1013)/12,0)
        elseif 1013-qnh > 0 then --if qnh < 1013
            flex_temp_correction = Round((1013-qnh)/2,0)
        end

        flex_temp = flex_temp_computed + flex_temp_correction
end

local function v2_calculation()
    if get(LOAD_flapssetting) == 1 then

        v2_table[1][2] = Round(-0.0036*(get(Gross_weight)/1000)^2     +    (1.2899*get((Gross_weight))/1000)   +71.6250, 0)

        v2_table[2][2] = Round(-0.0036*(get(Gross_weight)/1000)^2     +    (1.2899*get((Gross_weight))/1000)   +71.6250, 0)

        v2_table[3][2] = Round(-0.0036*(get(Gross_weight)/1000)^2     +    (1.2899*get((Gross_weight))/1000)   +71.6250, 0)

        v2_table[4][2] = Round(-0.0023*(get(Gross_weight)/1000)^2     +    (1.1011*get((Gross_weight))/1000)   +78.1613, 0)

        v2_table[5][2] = Round(-0.0033*(get(Gross_weight)/1000)^2     +    (1.2650*get((Gross_weight))/1000)   +71.3881, 0)

        v2_table[6][2] = Round(-0.0027*(get(Gross_weight)/1000)^2     +    (1.1954*get((Gross_weight))/1000)   +73.0293, 0)

        v2_table[7][2] = Round(-0.0019*(get(Gross_weight)/1000)^2     +    (1.0940*get((Gross_weight))/1000)   +75.7966, 0)

        v2_table[8][2] = Round(-0.0042*(get(Gross_weight)/1000)^2     +    (1.4161*get((Gross_weight))/1000)   +64.1953, 0)

        v2_table[9][2] = Round(-0.0016*(get(Gross_weight)/1000)^2     +    (1.0638*get((Gross_weight))/1000)   +75.2216, 0)

        v2_table[10][2] = Round(-0.0010*(get(Gross_weight)/1000)^2     +    (1.0072*get((Gross_weight))/1000)   +76.3221, 0)

        v2_table[11][2] = Round(-0.0016*(get(Gross_weight)/1000)^2     +    (1.0638*get((Gross_weight))/1000)   +75.2216, 0)

        v2_table[12][2] = Round(-0.0016*(get(Gross_weight)/1000)^2     +    (1.1179*get((Gross_weight))/1000)   +71.5522, 0)

        v2_table[13][2] = Round(-0.0017*(get(Gross_weight)/1000)^2     +    (1.1468*get((Gross_weight))/1000)   +69.4882, 0)


        computed_v2 = Math_clamp(Round(Table_extrapolate(v2_table, press_alt ),0), Round(press_alt*-0.0004+130.7802,0), 999) --for config 1

    
    elseif get(LOAD_flapssetting) == 2 then
    
        v2_table[1][2] = Round(-0.0026*(get(Gross_weight)/1000)^2     +    (1.1970*get((Gross_weight))/1000)   +60.0771, 0)

        v2_table[2][2] = Round(-0.0026*(get(Gross_weight)/1000)^2     +    (1.1970*get((Gross_weight))/1000)   +60.0771, 0)

        v2_table[3][2] = Round(-0.0026*(get(Gross_weight)/1000)^2     +    (1.1970*get((Gross_weight))/1000)   +60.0771, 0)

        v2_table[4][2] = Round(-0.0031*(get(Gross_weight)/1000)^2     +    (1.2691*get((Gross_weight))/1000)   +63.0474, 0)

        v2_table[5][2] = Round(-0.0002*(get(Gross_weight)/1000)^2     +    (0.8764*get((Gross_weight))/1000)   +75.9773, 0)

        v2_table[6][2] = Round( 0.0040*(get(Gross_weight)/1000)^2     +    (0.2949*get((Gross_weight))/1000)   +95.1740, 0)

        v2_table[7][2] = Round( 0.0094*(get(Gross_weight)/1000)^2     +    (-0.4136*get((Gross_weight))/1000)   +117.8978, 0)

        v2_table[8][2] = Round( 0.0142*(get(Gross_weight)/1000)^2     +    (-1.0321*get((Gross_weight))/1000)   +137.2131, 0)

        v2_table[9][2] = Round( 0.0206*(get(Gross_weight)/1000)^2     +    (-1.8424*get((Gross_weight))/1000)   +162.3778, 0)

        v2_table[10][2] = Round( 0.0235*(get(Gross_weight)/1000)^2     +    (-2.1520*get((Gross_weight))/1000)   +169.8650, 0)

        v2_table[11][2] = Round( 0.0254*(get(Gross_weight)/1000)^2     +    (-2.2924*get((Gross_weight))/1000)   +170.9172, 0)

        v2_table[12][2] = Round( 0.0265*(get(Gross_weight)/1000)^2     +    (-2.3138*get((Gross_weight))/1000)   +168.4755, 0)

        v2_table[12][2] = Round( 0.0265*(get(Gross_weight)/1000)^2     +    (-2.3138*get((Gross_weight))/1000)   +168.4755, 0)

        v2_table[13][2] = Round( 0.0238*(get(Gross_weight)/1000)^2     +    (-1.7980*get((Gross_weight))/1000)   +147.3921, 0)


        computed_v2 = Math_clamp(Round(Table_extrapolate(v2_table, press_alt ),0), Round(-0.0003*press_alt+122.9231,0), 999) -- for config 2


    elseif get(LOAD_flapssetting) == 3 then

        v2_table[1][2] = Round(-0.0038 *(get(Gross_weight)/1000)^2     +    ( 0.1314*get((Gross_weight))/1000)   +101.2111, 0)

        v2_table[2][2] = Round(-0.0038 *(get(Gross_weight)/1000)^2     +    ( 0.1314*get((Gross_weight))/1000)   +101.2111, 0)

        v2_table[3][2] = Round(-0.0038 *(get(Gross_weight)/1000)^2     +    ( 0.1314*get((Gross_weight))/1000)   +101.2111, 0)

        v2_table[4][2] = Round( 0.0027 *(get(Gross_weight)/1000)^2     +    ( 0.3142*get((Gross_weight))/1000)   +93.4115, 0)

        v2_table[5][2] = Round(0.0026 *(get(Gross_weight)/1000)^2     +    ( 0.3753*get((Gross_weight))/1000)   +89.1280, 0)

        v2_table[6][2] = Round(0.0012 *(get(Gross_weight)/1000)^2     +    ( 0.6123*get((Gross_weight))/1000)   +79.6377, 0)

        v2_table[7][2] = Round(-0.0009 *(get(Gross_weight)/1000)^2     +    ( 0.9412*get((Gross_weight))/1000)   +66.4039, 0)

        v2_table[8][2] = Round(-0.0016 *(get(Gross_weight)/1000)^2     +    ( 1.0638*get((Gross_weight))/1000)   +61.2216, 0)
        
        v2_table[9][2] = Round(-0.0016 *(get(Gross_weight)/1000)^2     +    ( 1.0818*get((Gross_weight))/1000)   +59.8826, 0)

        v2_table[10][2] = Round(-0.0024 *(get(Gross_weight)/1000)^2     +    ( 1.2063*get((Gross_weight))/1000)   +55.3256, 0)

        v2_table[11][2] = Round(-0.0034 *(get(Gross_weight)/1000)^2     +    ( 1.3712*get((Gross_weight))/1000)   +48.8650, 0)
        
        v2_table[12][2] = Round(-0.0023 *(get(Gross_weight)/1000)^2     +    ( 1.2191*get((Gross_weight))/1000)   +53.9961, 0)

        v2_table[13][2] = Round(-0.0028 *(get(Gross_weight)/1000)^2     +    ( 1.3001*get((Gross_weight))/1000)   +51.0174, 0)


        computed_v2 = Math_clamp(Round(Table_extrapolate(v2_table, press_alt ),0), Round(-0.008*press_alt+119.7363,0), 999) -- for config 3

       
    end
end

local function other_spd_calculation()
    if get(LOAD_runwaycond) == 1 then
        computed_v1 = computed_v2 - 15
    else
        computed_v1 = computed_v2 - 5
    end

    computed_vr = computed_v2 - 4

    set(TOPCAT_v1, computed_v1)
    set(TOPCAT_vr, computed_vr)
    set(TOPCAT_v2, computed_v2)
    set(TOPCAT_flex, flex_temp)
        
end

local function cg_calculation()

    

end

function update()

    other_spd_calculation()
    constant_conversions()
    v2_calculation()
    flex_calculation()

    --print(qnh)
    --print(press_alt)
    --print(flex_temp)
    --print(computed_v1)
    --print(computed_vr)
    --print(computed_v2)
end
