
local BTN_WIDTH  = 150
local BTN_HEIGHT = 39
local curr_subpage = 1

local function draw_vprof_menu()

    sasl.gl.drawFrame (10, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 1 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10+(BTN_WIDTH/2), size[2]-72, "Takeoff", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (20+BTN_WIDTH, size[2]-85, BTN_WIDTH, BTN_HEIGHT, curr_subpage == 2 and UI_GREEN or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 20+(3/2*BTN_WIDTH), size[2]-72, "Climb", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)
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

local function draw_climb()
    local legs = FMGS_sys.pred_debug.get_big_array()
    if not legs then
        sasl.gl.drawText(Font_B612MONO_regular, 10, 250, "NO PREDICTIONS", 25, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        return
    end
    for i, l in ipairs(legs) do
        sasl.gl.drawText(Font_B612MONO_regular, 10, 480-i*18, Aft_string_fill(i .. ")", " ", 4) .. Aft_string_fill((l.id or l.name or "[SID/STAR]"), " ", 12) 
        .. "   CLB? " .. (l.pred.is_climb and "Y" or "N")
        .. "   DES? " .. (l.pred.is_descent and "Y" or "N")
        .. "   IAS=" .. (l.pred.ias and math.ceil(l.pred.ias) or "N/A")
        .. "   ALT=" .. Aft_string_fill(""..(l.pred.altitude and math.floor(l.pred.altitude) or "N/A"), " ", 6)
        .. "   MACH=" .. (l.pred.mach and Round_fill(l.pred.mach,2) or "N/A ")
        .. "   VS=" .. Aft_string_fill(""..(l.pred.vs and math.floor(l.pred.vs) or "N/A"), " ", 7)
        .. "   TIME(s)=" .. Aft_string_fill(""..(l.pred.time and math.floor(l.pred.time) or "N/A"), " ", 7)
        .. "   FUEL(kg)=" .. (l.pred.fuel and math.floor(l.pred.fuel) or "N/A")
        , 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end
end

function draw_vprof()
    draw_vprof_menu()
    if curr_subpage == 1 then
        draw_takeoff()
    elseif curr_subpage == 2 then
        draw_climb()
    end
end

function update_vprof()
end

function vprof_change_page(n)
    curr_subpage = n;
end