--local v2_table = {
--    r={pressalt=-2000, tow=54},
--}

pitch_trim_table = {
    {10.5, 2.5},
    {17, 2.5},
    {20, 1.9},
    {25, 0.9},
    {30, -0.3},
    {35, -1.4},
    {40, -2.5},
    {43, -2.5},
}


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
    {11000,0},
    {12000,0},
    {13000,0},
    {14100,0},
    {15100,0},
}

flex_temp = 0
flex_temp_computed = 0
flex_temp_correction = 0
flex_temp_aice_correction = 0
flex_temp_aircon_correction = 0
wet_correction = 0

mtow_qnh_correction = 0
mtow_aice_correction = 0
mtow_aircon_correction = 0

computed_v1 = 0
computed_vr = 0
computed_v2 = 0
computed_trim = 0

press_alt = 0
qnh = 0

static_load = 0
max_load = 0
cg_mac = 0

----------------------------------------------------


--function constant_conversions()

--    press_alt = get(ACF_elevation)+30*(1013-qnh)
--end

local function constant_conversions()
    press_alt = get(ACF_elevation)*3.281
    qnh = get(Weather_curr_press_sea_level)*33.864
    return qnh
end

local function flex_calculation()
        flex_temp_computed = Round(-0.02434027806956361259*(get(ACF_elevation)*3.281/100)^3 + 0.36824311548836550021*(get(ACF_elevation)*3.281/100)^2 - 2.95963831628837229790*(get(ACF_elevation)*3.281/100) + 54.96994092387330948740, 0)

        if 1013-qnh < 0 then --if qnh > 1013
            flex_temp_correction = Round((qnh-1013)/12,0)
        elseif 1013-qnh > 0 then --if qnh < 1013
            flex_temp_correction = Round((1013-qnh)/2,0)
        end

        if get(LOAD_all_aice) == 1 then
            flex_temp_aice_correction = -11
        elseif get(LOAD_eng_aice) == 1 and get(LOAD_all_aice) == 0 then
            flex_temp_aice_correction = -2
        elseif get(LOAD_eng_aice) == 0 and get(LOAD_all_aice) == 0 then
            flex_temp_aice_correction = 0      
        else
            flex_temp_aice_correction = 0      
        end

        if get(LOAD_aircon) == 1 then
            flex_temp_aircon_correction = -3
        else
            flex_temp_aircon_correction = 0
        end

        flex_temp = flex_temp_computed + flex_temp_correction + flex_temp_aice_correction

        set(LOAD_total_flex_correction, flex_temp_correction + flex_temp_aice_correction)
end

local function mtow_decrease_calculation()
    if qnh > 1013 then --if qnh < 1013
        mtow_qnh_correction = -Round((1013-qnh)*100,0)
    end

    if get(LOAD_all_aice) == 1 then
        mtow_aice_correction = -4100
    elseif get(LOAD_eng_aice) == 1 and get(LOAD_all_aice) == 0 then
        mtow_aice_correction = -400
    elseif get(LOAD_eng_aice) == 0 and get(LOAD_all_aice) == 0 then
        mtow_aice_correction = 0      
    else
        mtow_aice_correction = 0    
    end

    if get(LOAD_aircon) == 1 then
        mtow_aircon_correction = -3600
    else
        mtow_aircon_correction = 0
    end

    set(LOAD_total_mtow_correction, mtow_qnh_correction + mtow_aice_correction + mtow_aircon_correction)
end

local function v2_calculation()
    if get(LOAD_flapssetting) == 1 then

        v2_table[1][2] = Table_extrapolate({ -- -2000 ft
            {54 , 131},
            {58 , 134},
            {62 , 138},
            {66 , 141},
            {70 , 145},
            {74 , 148},
            {78 , 150},
            {82 , 153},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000)

        v2_table[2][2] = Table_extrapolate({ -- -1000ft
            {54 , 131},
            {58 , 134},
            {62 , 138},
            {66 , 141},
            {70 , 145},
            {74 , 148},
            {78 , 150},
            {82 , 153},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000)

        v2_table[3][2] = Table_extrapolate({ -- 0 ft
            {54 , 131},
            {58 , 134},
            {62 , 138},
            {66 , 141},
            {70 , 145},
            {74 , 148},
            {78 , 150},
            {82 , 153},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000)

        v2_table[4][2] = Table_extrapolate({ -- 1000ft
            {54 , 131},
            {58 , 134},
            {62 , 138},
            {66 , 141},
            {70 , 144},
            {74 , 147},
            {78 , 150},
            {82 , 153},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000)

        v2_table[5][2] = Table_extrapolate({ -- 2000ft
            {54 , 130},
            {58 , 134},
            {62 , 137},
            {66 , 141},
            {70 , 144},
            {74 , 147},
            {78 , 150},
            {82 , 153},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000)

        v2_table[6][2] = Table_extrapolate({ --3000ft
            {54 , 130},
            {58 , 133},
            {62 , 137},
            {66 , 140},
            {70 , 143},
            {74 , 147},
            {78 , 150},
            {82 , 153},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000) 

        v2_table[7][2] = Table_extrapolate({ --4000ft
            {54 , 129},
            {58 , 133},
            {62 , 136},
            {66 , 140},
            {70 , 143},
            {74 , 146},
            {78 , 149},
            {82 , 152},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000) 

        v2_table[8][2] = Table_extrapolate({ --5000ft
            {54 , 129},
            {58 , 132},
            {62 , 136},
            {66 , 139},
            {70 , 143},
            {74 , 146},
            {78 , 149},
            {82 , 152},
            {86 , 156},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000) 

        v2_table[9][2] = Table_extrapolate({ --6000ft
            {54 , 128},
            {58 , 132},
            {62 , 135},
            {66 , 139},
            {70 , 142},
            {74 , 145},
            {78 , 149},
            {82 , 152},
            {86 , 155},
            {90 , 159},
            {95 , 162},
        }, get(Gross_weight)/1000) 

        v2_table[10][2] = Table_extrapolate({ --7000ft
            {54 , 128},
            {58 , 131},
            {62 , 135},
            {66 , 139},
            {70 , 142},
            {74 , 145},
            {78 , 149},
            {82 , 152},
            {86 , 156},
            {90 , 159},
            {95 , 163},
        }, get(Gross_weight)/1000) 

        v2_table[11][2] = Table_extrapolate({ --8000ft
            {54 , 127},
            {58 , 131},
            {62 , 135},
            {66 , 138},
            {70 , 142},
            {74 , 145},
            {78 , 149},
            {82 , 152},
            {86 , 156},
            {90 , 159},
            {95 , 163},
        }, get(Gross_weight)/1000) 

        v2_table[12][2] = Table_extrapolate({ --9000ft
            {54 , 127},
            {58 , 131},
            {62 , 134},
            {66 , 138},
            {70 , 142},
            {74 , 145},
            {78 , 149},
            {82 , 152},
            {86 , 156},
            {90 , 160},
            {95 , 163},
        }, get(Gross_weight)/1000) 

        v2_table[13][2] = Table_extrapolate({ --10000ft
            {54 , 127},
            {58 , 130},
            {62 , 134},
            {66 , 138},
            {70 , 142},
            {74 , 145},
            {78 , 149},
            {82 , 152},
            {86 , 156},
            {90 , 160},
            {95 , 163},
        }, get(Gross_weight)/1000)

        v2_table[14][2] = Table_extrapolate({ --11000ft
        {54 , 126},
        {58 , 130},
        {62 , 134},
        {66 , 138},
        {70 , 142},
        {74 , 145},
        {78 , 149},
        {82 , 153},
        {86 , 156},
        {90 , 160},
        {95 , 164},
        }, get(Gross_weight)/1000)

        v2_table[15][2] = Table_extrapolate({ --12000ft
        {54 , 126},
        {58 , 130},
        {62 , 134},
        {66 , 138},
        {70 , 142},
        {74 , 145},
        {78 , 149},
        {82 , 153},
        {86 , 157},
        {90 , 160},
        {95 , 164},
        }, get(Gross_weight)/1000)

        v2_table[16][2] = Table_extrapolate({ --13000ft
        {54 , 126},
        {58 , 130},
        {62 , 134},
        {66 , 138},
        {70 , 142},
        {74 , 146},
        {78 , 149},
        {82 , 153},
        {86 , 157},
        {90 , 161},
        {95 , 165},
        }, get(Gross_weight)/1000)

        v2_table[17][2] = Table_extrapolate({ --14100ft
        {54 , 125},
        {58 , 129},
        {62 , 133},
        {66 , 138},
        {70 , 142},
        {74 , 146},
        {78 , 150},
        {82 , 153},
        {86 , 157},
        {90 , 161},
        {95 , 165},
        }, get(Gross_weight)/1000)

        v2_table[18][2] = Table_extrapolate({ --15100ft
        {54 , 125},
        {58 , 129},
        {62 , 133},
        {66 , 138},
        {70 , 142},
        {74 , 146},
        {78 , 150},
        {82 , 154},
        {86 , 158},
        {90 , 162},
        {95 , 166},
        }, get(Gross_weight)/1000)

        computed_v2 = Math_clamp(Round(Table_extrapolate(v2_table, press_alt ),0), Round(press_alt*-0.0004+130.7802,0), 999) --for config 1

    
    elseif get(LOAD_flapssetting) == 2 then

        v2_table[1][2] = Table_extrapolate({ -- -2000 ft
        {54 , 123},
        {58 , 127},
        {62 , 130},
        {66 , 133},
        {70 , 137},
        {74 , 140},
        {78 , 143},
        {82 , 146},
        {86 , 149},
        {90 , 152},
        {95 , 156},
        }, get(Gross_weight)/1000)

        v2_table[2][2] = Table_extrapolate({ -- -1000ft
        {54 , 123},
        {58 , 127},
        {62 , 130},
        {66 , 133},
        {70 , 137},
        {74 , 140},
        {78 , 143},
        {82 , 146},
        {86 , 149},
        {90 , 152},
        {95 , 156},
        }, get(Gross_weight)/1000)

        v2_table[3][2] = Table_extrapolate({ -- 0 ft
        {54 , 123},
        {58 , 127},
        {62 , 130},
        {66 , 133},
        {70 , 137},
        {74 , 140},
        {78 , 143},
        {82 , 146},
        {86 , 149},
        {90 , 152},
        {95 , 156},
        }, get(Gross_weight)/1000)

        v2_table[4][2] = Table_extrapolate({ -- 1000ft
        {54 , 123},
        {58 , 126},
        {62 , 130},
        {66 , 133},
        {70 , 137},
        {74 , 140},
        {78 , 143},
        {82 , 146},
        {86 , 149},
        {90 , 152},
        {95 , 156},
        }, get(Gross_weight)/1000)

        v2_table[5][2] = Table_extrapolate({ -- 2000ft
        {54 , 123},
        {58 , 127},
        {62 , 129},
        {66 , 133},
        {70 , 136},
        {74 , 140},
        {78 , 143},
        {82 , 146},
        {86 , 149},
        {90 , 152},
        {95 , 158},
        }, get(Gross_weight)/1000)

        v2_table[6][2] = Table_extrapolate({ --3000ft
        {54 , 122},
        {58 , 126},
        {62 , 129},
        {66 , 133},
        {70 , 136},
        {74 , 140},
        {78 , 143},
        {82 , 146},
        {86 , 149},
        {90 , 152},
        {95 , 162},
        }, get(Gross_weight)/1000) 

        v2_table[7][2] = Table_extrapolate({ --4000ft
        {54 , 122},
        {58 , 125},
        {62 , 129},
        {66 , 132},
        {70 , 136},
        {74 , 139},
        {78 , 143},
        {82 , 146},
        {86 , 149},
        {90 , 156},
        {95 , 165},
        }, get(Gross_weight)/1000) 

        v2_table[8][2] = Table_extrapolate({ --5000ft
        {54 , 121},
        {58 , 125},
        {62 , 129},
        {66 , 132},
        {70 , 136},
        {74 , 139},
        {78 , 142},
        {82 , 146},
        {86 , 151},
        {90 , 159},
        {95 , 169},
        }, get(Gross_weight)/1000) 

        v2_table[9][2] = Table_extrapolate({ --6000ft
        {54 , 121},
        {58 , 125},
        {62 , 128},
        {66 , 132},
        {70 , 136},
        {74 , 139},
        {78 , 142},
        {82 , 147},
        {86 , 155},
        {90 , 164},
        {95 , 174},
        }, get(Gross_weight)/1000) 

        v2_table[10][2] = Table_extrapolate({ --7000ft
        {54 , 121},
        {58 , 124},
        {62 , 128},
        {66 , 132},
        {70 , 136},
        {74 , 139},
        {78 , 143},
        {82 , 150},
        {86 , 159},
        {90 , 168},
        {95 , 178},
        }, get(Gross_weight)/1000) 

        v2_table[11][2] = Table_extrapolate({ --8000ft
        {54 , 120},
        {58 , 124},
        {62 , 128},
        {66 , 132},
        {70 , 135},
        {74 , 139},
        {78 , 145},
        {82 , 154},
        {86 , 163},
        {90 , 172},
        {95 , 182},
        }, get(Gross_weight)/1000) 

        v2_table[12][2] = Table_extrapolate({ --9000ft
        {54 , 120},
        {58 , 124},
        {62 , 128},
        {66 , 132},
        {70 , 135},
        {74 , 140},
        {78 , 148},
        {82 , 158},
        {86 , 167},
        {90 , 176},
        {95 , 186},
        }, get(Gross_weight)/1000) 

        v2_table[13][2] = Table_extrapolate({ --10000ft
        {54 , 120},
        {58 , 124},
        {62 , 128},
        {66 , 132},
        {70 , 136},
        {74 , 143},
        {78 , 152},
        {82 , 162},
        {86 , 171},
        {90 , 180},
        {95 , 189},
        }, get(Gross_weight)/1000)

        v2_table[14][2] = Table_extrapolate({ --11000ft
        {54 , 120},
        {58 , 124},
        {62 , 128},
        {66 , 132},
        {70 , 137},
        {74 , 146},
        {78 , 156},
        {82 , 165},
        {86 , 174},
        {90 , 183},
        {95 , 192},
        }, get(Gross_weight)/1000)

        v2_table[15][2] = Table_extrapolate({ --12000ft
        {54 , 120},
        {58 , 124},
        {62 , 128},
        {66 , 132},
        {70 , 140},
        {74 , 150},
        {78 , 159},
        {82 , 168},
        {86 , 177},
        {90 , 185},
        {95 , 194},
        }, get(Gross_weight)/1000)

        v2_table[16][2] = Table_extrapolate({ --13000ft
        {54 , 120},
        {58 , 124},
        {62 , 128},
        {66 , 134},
        {70 , 143},
        {74 , 153},
        {78 , 162},
        {82 , 171},
        {86 , 179},
        {90 , 187},
        {95 , 196},
        }, get(Gross_weight)/1000)

        v2_table[17][2] = Table_extrapolate({ --14100ft
        {54 , 119},
        {58 , 124},
        {62 , 128},
        {66 , 137},
        {70 , 148},
        {74 , 157},
        {78 , 166},
        {82 , 174},
        {86 , 182},
        {90 , 190},
        {95 , 199},
        }, get(Gross_weight)/1000)

        v2_table[18][2] = Table_extrapolate({ --15100ft
        {54 , 119},
        {58 , 124},
        {62 , 131},
        {66 , 141},
        {70 , 152},
        {74 , 160},
        {78 , 169},
        {82 , 177},
        {86 , 185},
        {90 , 193},
        {95 , 201},
        }, get(Gross_weight)/1000)

            computed_v2 = Math_clamp(Round(Table_extrapolate(v2_table, press_alt ),0), Round(-0.0003*press_alt+122.9231,0), 999) -- for config 2


    elseif get(LOAD_flapssetting) == 3 then

        v2_table[1][2] = Table_extrapolate({ -- -2000 ft
        {54 , 121},
        {58 , 121},
        {62 , 122},
        {66 , 126},
        {70 , 129},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 144},
        {95 , 147},
        }, get(Gross_weight)/1000)

        v2_table[2][2] = Table_extrapolate({ -- -1000ft
        {54 , 121},
        {58 , 121},
        {62 , 122},
        {66 , 126},
        {70 , 129},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 144},
        {95 , 147},
        }, get(Gross_weight)/1000)

        v2_table[3][2] = Table_extrapolate({ -- 0 ft
        {54 , 121},
        {58 , 121},
        {62 , 122},
        {66 , 126},
        {70 , 129},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 144},
        {95 , 147},
        }, get(Gross_weight)/1000)

        v2_table[4][2] = Table_extrapolate({ -- 1000ft
        {54 , 120},
        {58 , 120},
        {62 , 122},
        {66 , 125},
        {70 , 129},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 144},
        {95 , 147},
        }, get(Gross_weight)/1000)

        v2_table[5][2] = Table_extrapolate({ -- 2000ft
        {54 , 118},
        {58 , 119},
        {62 , 122},
        {66 , 125},
        {70 , 129},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 144},
        {95 , 147},
        }, get(Gross_weight)/1000)

        v2_table[6][2] = Table_extrapolate({ --3000ft
        {54 , 117},
        {58 , 118},
        {62 , 122},
        {66 , 125},
        {70 , 128},
        {74 , 131},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 144},
        {95 , 148},
        }, get(Gross_weight)/1000) 

        v2_table[7][2] = Table_extrapolate({ --4000ft
        {54 , 115},
        {58 , 118},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 131},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 144},
        {95 , 148},
        }, get(Gross_weight)/1000) 

        v2_table[8][2] = Table_extrapolate({ --5000ft
        {54 , 114},
        {58 , 118},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 131},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 145},
        {95 , 148},
        }, get(Gross_weight)/1000) 

        v2_table[9][2] = Table_extrapolate({ --6000ft
        {54 , 114},
        {58 , 117},
        {62 , 121},
        {66 , 124},
        {70 , 128},
        {74 , 131},
        {78 , 135},
        {82 , 138},
        {86 , 141},
        {90 , 145},
        {95 , 148},
        }, get(Gross_weight)/1000) 

        v2_table[10][2] = Table_extrapolate({ --7000ft
        {54 , 114},
        {58 , 117},
        {62 , 121},
        {66 , 124},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 142},
        {90 , 145},
        {95 , 148},
        }, get(Gross_weight)/1000) 

        v2_table[11][2] = Table_extrapolate({ --8000ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 124},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 142},
        {90 , 145},
        {95 , 148},
        }, get(Gross_weight)/1000) 

        v2_table[12][2] = Table_extrapolate({ --9000ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 124},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 138},
        {86 , 142},
        {90 , 145},
        {95 , 149},
        }, get(Gross_weight)/1000) 

        v2_table[13][2] = Table_extrapolate({ --10000ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 139},
        {86 , 142},
        {90 , 146},
        {95 , 149},
        }, get(Gross_weight)/1000)

        v2_table[14][2] = Table_extrapolate({ --11000ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 139},
        {86 , 142},
        {90 , 146},
        {95 , 149},
        }, get(Gross_weight)/1000)

        v2_table[15][2] = Table_extrapolate({ --12000ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 139},
        {86 , 143},
        {90 , 146},
        {95 , 149},
        }, get(Gross_weight)/1000)

        v2_table[16][2] = Table_extrapolate({ --13000ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 139},
        {86 , 143},
        {90 , 146},
        {95 , 150},
        }, get(Gross_weight)/1000)

        v2_table[17][2] = Table_extrapolate({ --14100ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 140},
        {86 , 143},
        {90 , 147},
        {95 , 150},
        }, get(Gross_weight)/1000)

        v2_table[18][2] = Table_extrapolate({ --15100ft
        {54 , 113},
        {58 , 117},
        {62 , 121},
        {66 , 125},
        {70 , 128},
        {74 , 132},
        {78 , 135},
        {82 , 140},
        {86 , 143},
        {90 , 147},
        {95 , 150},
        }, get(Gross_weight)/1000)
        computed_v2 = Math_clamp(Round(Table_extrapolate(v2_table, press_alt ),0), Round(-0.008*press_alt+119.7363,0), 999) -- for config 3

       
    end
end

local function other_spd_calculation()

    if get(LOAD_runwaycond) == 0 then
        computed_v1 = computed_v2 - 5
        computed_vr = computed_v2 - 4
    else
        computed_v1 = computed_v2 - 13
        computed_vr = computed_v2 - 4
    end
    
    set(TOPCAT_v1, computed_v1)
    set(TOPCAT_vr, computed_vr)
    set(TOPCAT_v2, computed_v2)
    set(TOPCAT_flex, flex_temp)

    print(mtow_qnh_correction + mtow_aice_correction + mtow_aircon_correction)
end

function execute_takeoff_performance()
    constant_conversions()
    v2_calculation()
    flex_calculation()
    mtow_decrease_calculation()
    other_spd_calculation()
end

function update()
    --print(qnh)
    --print(press_alt)
    --print(flex_temp)
    --print(computed_v1)
    --print(computed_vr)
    --print(computed_v2)
end
