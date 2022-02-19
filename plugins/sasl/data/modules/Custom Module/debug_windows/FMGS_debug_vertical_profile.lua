
local BTN_WIDTH  = 150
local BTN_HEIGHT = 39
local curr_subpage = 5

local function draw_vprof_menu()

    sasl.gl.drawFrame (10, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 1 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10+(BTN_WIDTH/2), size[2]-72, "Takeoff", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (20+BTN_WIDTH, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 2 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 20+(3/2*BTN_WIDTH), size[2]-72, "Climb", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (30+BTN_WIDTH*2, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 3 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 30+(5/2*BTN_WIDTH), size[2]-72, "Cruise", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (40+BTN_WIDTH*3, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 4 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 40+(7/2*BTN_WIDTH), size[2]-72, "Descent", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (50+BTN_WIDTH*4, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 5 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 50+(9/2*BTN_WIDTH), size[2]-72, "Appr&Land", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (60+BTN_WIDTH*5, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 6 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 60+(11/2*BTN_WIDTH), size[2]-72, "Key WPTs", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

end

local function draw_takeoff_static()
    -- RWY
    sasl.gl.drawWideLine(10,100,100,100,5,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 55, 110, "RWY", 16, false, false, TEXT_ALIGN_CENTER, UI_WHITE)

    -- RWY climb
    sasl.gl.drawWideLine(70,100,100,115,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 110, 110, "+30 ft", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)

    -- Init climb
    sasl.gl.drawWideLine(100,115,300,300,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 210, 200, "V2=     kt", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)

    -- Acceleration
    sasl.gl.drawWideLine(300,300,550,300,2,UI_WHITE)

    -- GD
    sasl.gl.drawCircle(550,300,7,false,ECAM_GREEN)
    sasl.gl.drawText(Font_B612MONO_regular, 550, 270, "V_GD =     kt", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 550, 240, "V_SRS=     kt", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)

    -- Final segment
    sasl.gl.drawWideLine(550,300,850,450,2,UI_WHITE)

    -- Others
    sasl.gl.drawText(Font_B612MONO_regular, 10, 60, "TIME  (mm:ss)", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 35, "DISTANCE (nm)", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)

end

local function draw_takeoff_dynamic()
    local fpln = FMGS_sys.fpln.active
    local alt = 0
    local alt_color = ECAM_RED
    if fpln.apts.dep then
        alt = fpln.apts.dep.alt
        alt_color = UI_LIGHT_BLUE
    end

    -- Altitudes
    sasl.gl.drawText(Font_B612MONO_regular, 110, 90, alt .. " ft", 14, false, false, TEXT_ALIGN_LEFT, alt_color)
    sasl.gl.drawText(Font_B612MONO_regular, 300, 320, (alt+400) .. " ft", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 870, 450, (alt+FMGS_get_takeoff_acc()) .. " ft", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)

    -- Speeds
    if FMGS_sys.perf.takeoff.v2 then
        sasl.gl.drawText(Font_B612MONO_regular, 210, 200, "    " .. FMGS_sys.perf.takeoff.v2, 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, 550, 240, "       " .. math.floor(FMGS_sys.perf.takeoff.v2+10), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    else
        sasl.gl.drawText(Font_B612MONO_regular, 210, 200, "    ???", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        sasl.gl.drawText(Font_B612MONO_regular, 550, 240, "       ???", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
    end

    if FMGS_sys.data.pred.takeoff.gdot then
        sasl.gl.drawText(Font_B612MONO_regular, 550, 270, "       " .. math.floor(FMGS_sys.data.pred.takeoff.gdot), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    else
        sasl.gl.drawText(Font_B612MONO_regular, 550, 270, "       ???", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
    end

    if FMGS_sys.data.pred.takeoff.ROC_init then
        sasl.gl.drawText(Font_B612MONO_regular, 120, 250, math.floor(FMGS_sys.data.pred.takeoff.ROC_init) .. " ft/min", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        local s = FMGS_sys.data.pred.takeoff.time_to_400ft
        local d = FMGS_sys.data.pred.takeoff.dist_to_400ft
        sasl.gl.drawText(Font_B612MONO_regular, 300, 60, math.floor(s/60) .. ":" .. math.floor(s%60), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, 300, 35, Round(d,3), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        s = s + FMGS_sys.data.pred.takeoff.time_to_sec_climb
        d = d + FMGS_sys.data.pred.takeoff.dist_to_sec_climb
        sasl.gl.drawText(Font_B612MONO_regular, 550, 60, math.floor(s/60) .. ":" .. math.floor(s%60), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, 550, 35, Round(d,3), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        s = s + FMGS_sys.data.pred.takeoff.time_to_vacc
        d = d + FMGS_sys.data.pred.takeoff.dist_to_vacc
        sasl.gl.drawText(Font_B612MONO_regular, 850, 60, math.floor(s/60) .. ":" .. math.floor(s%60), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, 850, 35, Round(d,3), 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    else
        sasl.gl.drawText(Font_B612MONO_regular, 120, 250, "??? ft/min", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
    end

    if FMGS_sys.data.pred.takeoff.total_fuel_kgs then
        sasl.gl.drawText(Font_B612MONO_regular, 700, 5, "Total fuel consumption: " .. math.floor(FMGS_sys.data.pred.takeoff.total_fuel_kgs) .. " Kg", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    else
        sasl.gl.drawText(Font_B612MONO_regular, 700, 5, "Total fuel consumption: N/A", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end

end

local function draw_takeoff()

    draw_takeoff_static()
    draw_takeoff_dynamic()

end

local function print_single_leg(i, l, is_green)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 480-i*18, Aft_string_fill(i .. ")", " ", 4) .. Aft_string_fill((l.id or l.name or "[SID/STAR]"), " ", 12) 
    .. "   CLB? " .. (l.pred.is_climb and "Y" or "N")
    .. "   DES? " .. (l.pred.is_descent and "Y" or "N")
    .. "   IAS=" .. (l.pred.ias and math.ceil(l.pred.ias) or "N/A")
    .. "   ALT=" .. Aft_string_fill(""..(l.pred.altitude and math.floor(l.pred.altitude) or "N/A"), " ", 6)
    .. "   MACH=" .. (l.pred.mach and Round_fill(l.pred.mach,2) or "N/A ")
    .. "   VS=" .. Aft_string_fill(""..(l.pred.vs and math.floor(l.pred.vs) or "N/A"), " ", 7)
    .. "   TIME(s)=" .. Aft_string_fill(""..(l.pred.time and math.floor(l.pred.time) or "N/A"), " ", 7)
    .. "   FUEL(kg)=" .. (l.pred.fuel and math.floor(l.pred.fuel) or "N/A")
    , 12, false, false, TEXT_ALIGN_LEFT, is_green and ECAM_GREEN or ECAM_WHITE)
end

local function draw_climb()
    local legs = FMGS_sys.pred_debug.get_big_array()
    if not legs then
        sasl.gl.drawText(Font_B612MONO_regular, 10, 250, "NO PREDICTIONS", 25, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        return
    else
        sasl.gl.drawText(Font_B612MONO_regular, 10, 30, "SID/STAR names are not available unless you open the F/PLN page on the MCDU.", 14, false, false, TEXT_ALIGN_LEFT, ECAM_YELLOW)
    end
    local printed = 0
    for i, l in ipairs(legs) do
        if l.pred.is_climb then
            printed = printed + 1
            print_single_leg(printed, l, l.pred.is_toc)
        end
    end
end

local function draw_cruise()
    local legs = FMGS_sys.pred_debug.get_big_array()
    if not legs then
        sasl.gl.drawText(Font_B612MONO_regular, 10, 250, "NO PREDICTIONS", 25, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        return
    end
    local printed = 0
    for i, l in ipairs(legs) do
        if not l.pred.is_climb and not l.pred.is_descent then
            printed = printed + 1
            print_single_leg(printed, l)
        end
    end
end

local function draw_descent()
    local legs = FMGS_sys.pred_debug.get_big_array()
    if not legs then
        sasl.gl.drawText(Font_B612MONO_regular, 10, 250, "NO PREDICTIONS", 25, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        return
    else
        sasl.gl.drawText(Font_B612MONO_regular, 10, 30, "SID/STAR names are not available unless you open the F/PLN page on the MCDU.", 14, false, false, TEXT_ALIGN_LEFT, ECAM_YELLOW)
    end
    local printed = 0
    for i, l in ipairs(legs) do
        if l.pred.is_descent then
            printed = printed + 1
            print_single_leg(printed, l)
        end
    end
end

local function draw_key_wpts()
    local legs = FMGS_sys.pred_debug.get_big_array()
    if not legs then
        sasl.gl.drawText(Font_B612MONO_regular, 10, 250, "NO PREDICTIONS", 25, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        return
    end

    for i, l in ipairs(legs) do
        if l.pred.is_toc then
            sasl.gl.drawText(Font_B612MONO_regular, 10, 450, "TOP OF CLIMB", 18, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 430, "Leg # " .. i, 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 410, "ALT  = " .. (l.pred.altitude and math.ceil(l.pred.altitude) or "N/A") .. " ft", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 390, "IAS  = " .. (l.pred.ias and math.ceil(l.pred.ias) or "N/A") .. " kts", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 370, "M    = " .. (l.pred.mach and Round(l.pred.mach,3) or "N/A"), 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            local t = l.pred.time
            sasl.gl.drawText(Font_B612MONO_regular, 10, 350, "TIME = " .. (t and math.floor(t/60) .. ":" .. math.floor(t%60) or "N/A") .. " (mm:ss)", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 330, "FUELc= " .. (l.pred.fuel and Round(l.pred.fuel,1) or "N/A") .. " Kg", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 310, "V/S  = " .. (l.pred.vs and Round(l.pred.vs,1) or "N/A") .. " feet/min", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 290, "Distance previous WPT = " .. (l.pred.dist_prev_wpt and Round(l.pred.dist_prev_wpt,1) or "N/A") .. " nm", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
            sasl.gl.drawText(Font_B612MONO_regular, 10, 270, "Predicted weight      = " .. (l.pred.weight and math.ceil(l.pred.weight) or "N/A") .. " Kg", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
        end
    end

end

local function draw_apprland_static()
    -- RWY
    sasl.gl.drawWideLine(900,190,1000,190,5,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 950, 200, "RWY", 16, false, false, TEXT_ALIGN_CENTER, UI_WHITE)

    -- 1000 ft
    sasl.gl.drawWideLine(900,190,800,240,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 810, 250, "1000ft AGL", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawWideLine(800,240,800,180,2,{.3,.3,.3})

    -- Flaps FULL
    sasl.gl.drawWideLine(800,240,700,290,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 710, 300, "FLAPS FULL", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawWideLine(700,290,700,180,2,{.3,.3,.3})

    -- Flaps 3
    sasl.gl.drawWideLine(600,340,700,290,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 610, 350, "FLAPS 3", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawWideLine(600,340,600,180,2,{.3,.3,.3})

    -- FDP
    sasl.gl.drawWideLine(600,340,500,390,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 510, 400, "FDP", 14, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
    sasl.gl.drawWideLine(500,390,500,180,2,{.4,.2,.4})

    -- Flaps 2
    sasl.gl.drawWideLine(500,390,400,420,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 410, 430, "FLAPS 2", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawWideLine(400,420,400,180,2,{.3,.3,.3})

    -- Flaps 1
    sasl.gl.drawWideLine(300,450,400,420,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 310, 460, "FLAPS 1", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawWideLine(300,450,300,180,2,{.3,.3,.3})
    
    -- DECEL
    sasl.gl.drawWideLine(300,450,200,480,2,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 210, 490, "DECEL", 14, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
    sasl.gl.drawWideLine(200,480,200,180,2,{.4,.2,.4})

    sasl.gl.drawWideLine(200,480,160,500,2,UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 10, 160, "IAS (kts) :", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 140, "ALT (feet):", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 120, "V/S (fpm) :", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 100, "N1 (%)    :", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 70, "TIME (sec):", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 50,  "FUEL (kg) :", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 30,  "DIST (nm) :", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)


end
local function draw_apprland_dynamic()

    for i,s in ipairs(FMGS_sys.data.pred.appr.steps) do
        local left = size[1]-100-100*i
        sasl.gl.drawText(Font_B612MONO_regular, left, 160, s.ias and math.ceil(s.ias) or "N/A", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, left, 140, s.alt and math.ceil(s.alt) or "N/A", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, left, 120, s.vs and math.ceil(s.vs) or "N/A", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, left, 100, s.N1 and math.ceil(s.N1) or "N/A", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, left, 70, s.time and math.ceil(s.time) or "N/A", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, left, 50,  s.fuel and math.ceil(s.fuel) or "N/A", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, left, 30,  s.dist and Round(s.dist, 1) or "N/A", 14, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    end

    if FMGS_sys.data.pred.appr.fdp_idx then
        local l = FMGS_arr_get_appr(false).legs[FMGS_sys.data.pred.appr.fdp_idx]
        local name = (l.id or l.name or "-OPEN F/PLN PAGE-")
        sasl.gl.drawText(Font_B612MONO_regular, 550, 400, "[" .. name .. "]", 14, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_B612MONO_regular, 550, 400, "[UKNWN]", 14, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
    end


end
local function draw_apprland()
    draw_apprland_static()
    draw_apprland_dynamic()
end

function draw_vprof()
    draw_vprof_menu()
    if curr_subpage == 1 then
        draw_takeoff()
    elseif curr_subpage == 2 then
        draw_climb()
    elseif curr_subpage == 3 then
        draw_cruise()
    elseif curr_subpage == 4 then
        draw_descent()
    elseif curr_subpage == 5 then
        draw_apprland()
    elseif curr_subpage == 6 then
        draw_key_wpts()
    end
end

function update_vprof()

end

function vprof_change_page(n)
    curr_subpage = n;
end