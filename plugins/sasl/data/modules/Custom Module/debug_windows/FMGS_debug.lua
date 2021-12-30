-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: wheel_debug.lua
-- Short description: GPWS debug window
-------------------------------------------------------------------------------

include("FMGS/functions.lua")
include("libs/table.save.lua")
include("debug_windows/FMGS_debug_vertical_profile.lua")

size = {1000, 600}

local curr_page = 1
local curr_detail = nil
local curr_detail_2 = nil
local load_result = ""
local load_result_color = ECAM_GREEN

local BTN_WIDTH  = 150
local BTN_HEIGHT = 39

-- vertical profile page
local trip_distance = 500
vprof_view_start = 0 -- ratio, 0-1 from start to end of leg
vprof_view_end = 1
local starting_px = 0
local width_px = 0
local hook_mouse = 0 -- 0 = nothing, 1 = start, 2 = end
local MOUSE_X = 0
local MOUSE_Y = 0


local function draw_main_menu()

    sasl.gl.drawFrame (10, size[2]-40, BTN_WIDTH, BTN_HEIGHT, curr_page == 1 and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10+(BTN_WIDTH/2), size[2]-27, "Config/Data", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (20+BTN_WIDTH, size[2]-40, BTN_WIDTH, BTN_HEIGHT, curr_page == 2 and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 20+(3/2*BTN_WIDTH), size[2]-27, "Flight Plan", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (30+BTN_WIDTH*2, size[2]-40, BTN_WIDTH, BTN_HEIGHT, curr_page == 3 and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 30+(5/2*BTN_WIDTH), size[2]-27, "Performance", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

    sasl.gl.drawFrame (40+BTN_WIDTH*3, size[2]-40, BTN_WIDTH, BTN_HEIGHT, curr_page == 4 and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 40+(7/2*BTN_WIDTH), size[2]-27, "Vert. Profile", 16, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

end

local function mouse_hold(x,y)
    MOUSE_X = x
    MOUSE_Y = y
    if curr_page == 4 then
        if x >= starting_px - 10 and x <= starting_px + 10 and y >= 440 and y <= 470 then
            hook_mouse = 1
        elseif x >= starting_px + width_px - 10 and x <= starting_px + width_px + 10 and y >= 440 and y <= 470 then
            hook_mouse = 2
        end
    end
end

local function mouse_up(x,y)
    if curr_page == 4 then
        hook_mouse = 0
    end
end

local function mouse_down(x,y)
    if x >=10 and x<=10+BTN_WIDTH and y >= size[2]-40 then
        curr_page = 1
    elseif x >=20+BTN_WIDTH and x<=20+BTN_WIDTH*2 and y >= size[2]-40 then
        curr_page = 2
    elseif x >=30+BTN_WIDTH*2 and x<=30+BTN_WIDTH*3 and y >= size[2]-40 then
        curr_page = 3
    elseif x >=40+BTN_WIDTH*3 and x<=40+BTN_WIDTH*4 and y >= size[2]-40 then
        curr_page = 4
    end

    if curr_page == 1 then
        if x>=450 and y <= 80 and x<=600 and y >= 40 then
            if AvionicsBay.is_initialized()  and AvionicsBay.is_ready() then
                local_result = "WAIT"
                load_result_color = ECAM_ORANGE
                FMGS_reset_dep_arr_airports()
                FMGS_set_apt_dep("LIML")
                FMGS_set_apt_arr("LIRP")
                FMGS_set_apt_alt("LIRC")
                FMGS_create_temp_fpln()
                FMGS_dep_set_rwy(FMGS_sys.fpln.temp.apts.dep.rwys[1], true)
            else
                load_result = "AvionicsBay not ready"
                load_result_color = ECAM_RED
            end
        elseif x>=450+BTN_WIDTH+40 and y <= 80 and x<=600+BTN_WIDTH+40 and y >= 40 then
            table.save(FMGS_sys.fpln.active, "exported_fpln.saved")
            load_result = "EXPORTED"
            load_result_color = ECAM_GREEN
        end
    elseif curr_page == 2 then
        if x>=90 and y <= 520 and x<=110 and y >= 500 then
            curr_detail = FMGS_sys.fpln.active.apts.dep_rwy
            curr_detail_2 = nil
        elseif x>=90 and y <= 470 and x<=110 and y >= 450 then
            curr_detail = FMGS_sys.fpln.active.apts.dep_sid
            curr_detail_2 = nil
        elseif x>=90 and y <= 420 and x<=110 and y >= 400 then
            curr_detail = FMGS_sys.fpln.active.apts.dep_trans
            curr_detail_2 = nil
        elseif x>=90 and y <= 360 and x<=110 and y >= 340 then
            curr_detail = FMGS_sys.fpln.active.legs
            curr_detail_2 = nil
        elseif x>=90 and y <= 300 and x<=110 and y >= 280 then
            curr_detail = FMGS_sys.fpln.active.apts.arr_trans
            curr_detail_2 = nil
        elseif x>=90 and y <= 250 and x<=110 and y >= 230 then
            curr_detail = FMGS_sys.fpln.active.apts.arr_star
            curr_detail_2 = nil
        elseif x>=90 and y <= 200 and x<=110 and y >= 180 then
            curr_detail = FMGS_sys.fpln.active.apts.arr_via
            curr_detail_2 = nil
        elseif x>=90 and y <= 150 and x<=110 and y >= 130 then
            curr_detail = FMGS_sys.fpln.active.apts.arr_appr
            curr_detail_2 = FMGS_sys.fpln.active.apts.arr_map
        elseif x>=90 and y <= 100 and x<=110 and y >= 80 then
            curr_detail = FMGS_sys.fpln.active.apts.arr_rwy
            curr_detail_2 = nil
        end
    end
end

local function draw_page_config()

    sasl.gl.drawFrame (10, size[2]-230, 400, 150, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-100, "CONFIG", 14, true, false, TEXT_ALIGN_LEFT,UI_WHITE)

    ----------------------
    -- STATUS
    ----------------------
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-120, "Status:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    local text = "UKNWN"
    local color = ECAM_RED
    if FMGS_sys.config.status == FMGS_MODE_OFF then
        text = "OFF"
        color = ECAM_RED
    elseif FMGS_sys.config.status == FMGS_MODE_BACKUP then
        text = "BACKUP"
        color = ECAM_ORANGE
    elseif FMGS_sys.config.status == FMGS_MODE_SINGLE then
        text = "SINGLE"
        color = ECAM_BLUE
    elseif FMGS_sys.config.status == FMGS_MODE_DUAL then
        text = "DUAL"
        color = ECAM_GREEN
    end
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-120, text, 12, false, false, TEXT_ALIGN_LEFT, color)

    ----------------------
    -- Phase
    ----------------------
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-140, "Phase:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    local text = "UKNWN"
    if FMGS_sys.config.status == FMGS_PHASE_PREFLIGHT    then
        text = "PREFLIGHT"
    elseif FMGS_sys.config.status == FMGS_PHASE_TAKEOFF then
        text = "TAKEOFF"
    elseif FMGS_sys.config.status == FMGS_PHASE_CLIMB then
        text = "CLIMB"
    elseif FMGS_sys.config.status == FMGS_PHASE_CRUISE then
        text = "CRUISE"
    elseif FMGS_sys.config.status == FMGS_PHASE_DESCENT then
        text = "DESCENT"
    elseif FMGS_sys.config.status == FMGS_PHASE_APPROACH then
        text = "APPROACH"
    elseif FMGS_sys.config.status == FMGS_PHASE_GOAROUND then
        text = "GOAROUND"
    elseif FMGS_sys.config.status == FMGS_PHASE_DONE then
        text = "DONE"
    end
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-140, text, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    ----------------------
    -- Phase
    ----------------------
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-160, "Master:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-160, FMGS_sys.config.master, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    ----------------------
    -- Backup
    ----------------------
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-180, "Backup req? ", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 130, size[2]-180, FMGS_sys.config.backup_req and "YES" or "NO", 12, false, false, TEXT_ALIGN_LEFT, FMGS_sys.config.backup_req and ECAM_RED or ECAM_GREEN)

    ----------------------
    -- GPS Primary
    ----------------------
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-200, "GPS Primary? ", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 130, size[2]-200, FMGS_sys.config.gps_primary and "YES" or "NO", 12, false, false, TEXT_ALIGN_LEFT, FMGS_sys.config.gps_primary and ECAM_GREEN or ECAM_ORANGE)

    ----------------------
    -- Load example
    ----------------------
    sasl.gl.drawFrame (450, 40, BTN_WIDTH, BTN_HEIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_B612MONO_regular, 450+(BTN_WIDTH/2), 52, "Load Example Data", 12, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawFrame (450+BTN_WIDTH+20, 40, BTN_WIDTH, BTN_HEIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_B612MONO_regular, 450+(BTN_WIDTH/2)+BTN_WIDTH+20, 52, "Export Data", 12, false, false, TEXT_ALIGN_CENTER, UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 800, 52, load_result, 12, false, false, TEXT_ALIGN_LEFT, load_result_color)


end

local function draw_page_data()

    sasl.gl.drawFrame (10, size[2]-400, 400, 150, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-270, "DATA", 14, true, false, TEXT_ALIGN_LEFT,UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-290, "Flight Nr.:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-290, FMGS_sys.data.init.flt_nbr or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-310, "Cost IDX:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-310, FMGS_sys.data.init.cost_index or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-330, "Cruise FL:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-330, FMGS_sys.data.init.crz_fl or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-350, "Cruise Temp:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-350, FMGS_sys.data.init.crz_temp or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-370, "Tropo alt:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-370, FMGS_sys.data.init.tropo or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-270, "WEIGHTS", 14, false, false, TEXT_ALIGN_LEFT,UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-290, "Taxi Fuel:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 310, size[2]-290, FMGS_sys.data.init.weights.taxi_fuel or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-310, "ZFW:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 310, size[2]-310, FMGS_sys.data.init.weights.zfw or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-330, "ZFWCG:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 310, size[2]-330, FMGS_sys.data.init.weights.zfwcg or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-350, "Block Fuel:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 310, size[2]-350, FMGS_sys.data.init.weights.block_fuel or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-370, "Reserv Fuel%:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 310, size[2]-370, FMGS_sys.data.init.weights.rsv_fuel_perc or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-390, "Reserv Fuel:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 310, size[2]-390, FMGS_sys.data.init.weights.rsv_fuel or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

end

local function draw_page_pred()

    sasl.gl.drawFrame (10, size[2]-570, 400, 150, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-440, "PREDICTIONS", 14, true, false, TEXT_ALIGN_LEFT,UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-460, "Trip Fuel:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-460, FMGS_sys.data.pred.trip_fuel or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-480, "Trip Time:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-480, FMGS_sys.data.pred.trip_time or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-500, "Trip Dist:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-500, FMGS_sys.data.pred.trip_dist or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 20, size[2]-520, "EFOB:", 12, false, false, TEXT_ALIGN_LEFT,UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 120, size[2]-520, FMGS_sys.data.pred.efob or "---", 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)


end

local function draw_ab_info()

    sasl.gl.drawText(Font_B612MONO_regular, 20, 0, "AvionicsBay:", 14, false, false, TEXT_ALIGN_LEFT, UI_WHITE)

    if AvionicsBay.is_initialized() then
        sasl.gl.drawText(Font_B612MONO_regular, 250, 0, "INITIALIZED", 14, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif get(TIME) % 0.5 < 0.25 then
        sasl.gl.drawText(Font_B612MONO_regular, 250, 0, ">>>> NOT INIT <<<<", 14, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end
    
    if AvionicsBay.is_initialized()  and AvionicsBay.is_ready() then
        sasl.gl.drawText(Font_B612MONO_regular, 500, 0, "READY", 14, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif get(TIME) % 0.5 < 0.25 then
        sasl.gl.drawText(Font_B612MONO_regular, 500, 0, ">>>> NOT READY <<<<<", 14, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

end

local function draw_page_fpln_column(x, fpln)
    ----------------
    -- DEPARTURE
    ----------------
    local dep = fpln.apts.dep
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-90, dep and (dep.name .. "("..dep.id..")") or "APT NOT SET", 12, false, false, TEXT_ALIGN_LEFT, dep and UI_LIGHT_BLUE or {.6,.6,.6})
    local dep_rwy = fpln.apts.dep_rwy
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-110, dep_rwy and (dep_rwy[2] and (dep_rwy[1].sibl_name .. " [S]") or dep_rwy[1].name) or "RWY NOT SET", 12, false, false, TEXT_ALIGN_LEFT, dep_rwy and UI_LIGHT_BLUE or {.6,.6,.6})

    ----------------
    -- SID
    ----------------
    local dep_sid = fpln.apts.dep_sid
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-140, dep_sid and dep_sid.proc_name or "SID NOT SET", 12, false, false, TEXT_ALIGN_LEFT, dep_sid and UI_LIGHT_BLUE or {.6,.6,.6})
    if dep_sid and dep_sid.legs then
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-160, "#LEGS = " .. #dep_sid.legs, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    end

    ----------------
    -- TRANS
    ----------------
    local dep_trans = fpln.apts.dep_trans
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-190, dep_trans and dep_trans.trans_name or "TRANS NOT SET", 12, false, false, TEXT_ALIGN_LEFT, dep_trans and UI_LIGHT_BLUE or {.6,.6,.6})
    if dep_trans and dep_trans.legs then
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-210, "#LEGS = " .. #dep_trans.legs, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    end

    ----------------
    -- ENROUTE
    ----------------
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-250, "#LEGS = " .. #fpln.legs, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    ----------------
    -- TRANS
    ----------------
    local arr_trans = fpln.apts.arr_trans
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-310, arr_trans and arr_trans.trans_name or "TRANS NOT SET", 12, false, false, TEXT_ALIGN_LEFT, arr_trans and UI_LIGHT_BLUE or {.6,.6,.6})
    if arr_trans and arr_trans.legs then
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-330, "#LEGS = " .. #arr_trans.legs, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    end

    ----------------
    -- STAR
    ----------------
    local arr_star = fpln.apts.arr_star
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-360, arr_star and arr_star.proc_name or "STAR NOT SET", 12, false, false, TEXT_ALIGN_LEFT, arr_star and UI_LIGHT_BLUE or {.6,.6,.6})
    if arr_star and arr_star.legs then
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-380, "#LEGS = " .. #arr_star.legs, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    end

    ----------------
    -- VIA
    ----------------
    local arr_via = fpln.apts.arr_via
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-410, arr_via and arr_via.trans_name or "VIA NOT SET", 12, false, false, TEXT_ALIGN_LEFT, arr_via and UI_LIGHT_BLUE or {.6,.6,.6})
    if arr_via and arr_via.legs then
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-430, "#LEGS = " .. #arr_via.legs, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    end

    ----------------
    -- APPR
    ----------------
    local arr_appr = fpln.apts.arr_appr
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-460, arr_appr and arr_appr.proc_name or "VIA NOT SET", 12, false, false, TEXT_ALIGN_LEFT, arr_appr and UI_LIGHT_BLUE or {.6,.6,.6})
    if arr_appr and arr_appr.legs then
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-480, "#LEGS = " .. #arr_appr.legs, 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    end

    ----------------
    -- ARRIVAL
    ----------------
    local arr = fpln.apts.arr
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-510, arr and (arr.name .. "("..arr.id..")") or "APT NOT SET", 12, false, false, TEXT_ALIGN_LEFT, arr and UI_LIGHT_BLUE or {.6,.6,.6})
    if fpln.apts.arr_rwy then
        local arr_rwy = fpln.apts.arr_rwy
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-530, arr_rwy and (arr_rwy[2] and (arr_rwy[1].sibl_name .. " [S]") or arr_rwy[1].name) or "RWY NOT SET", 12, false, false, TEXT_ALIGN_LEFT, arr_rwy and UI_LIGHT_BLUE or {.6,.6,.6})
    end
    ----------------
    -- ALTERNATE
    ----------------
    local alt = fpln.apts.alt
    sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-560, alt and (alt.name .. "("..alt.id..")") or "APT NOT SET", 12, false, false, TEXT_ALIGN_LEFT, alt and UI_LIGHT_BLUE or {.6,.6,.6})
    if fpln.apts.alt_rwy then
        local alt_rwy = fpln.apts.alt_rwy
        sasl.gl.drawText(Font_B612MONO_regular, x, size[2]-580, alt_rwy and (alt_rwy[2] and (alt_rwy[1].sibl_name .. " [S]") or alt_rwy[1].name) or "RWY NOT SET", 12, false, false, TEXT_ALIGN_LEFT, alt_rwy and UI_LIGHT_BLUE or {.6,.6,.6})
    end
end

local function draw_page_fpln()

    sasl.gl.drawText(Font_B612MONO_regular, 200, size[2]-70, "ACTIVE", 14, false, false, TEXT_ALIGN_CENTER, UI_GREEN)

    sasl.gl.drawText(Font_B612MONO_regular, 450, size[2]-70, "TEMP", 14, false, false, TEXT_ALIGN_CENTER, FMGS_sys.fpln.temp and UI_GREEN or {.6,.6,.6})

    ----------------
    -- TIMELINE
    ----------------
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-90-7, "DEPARTURE", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-90, 100, size[2]-140, 1, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-140-7, "SID", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)
    
    sasl.gl.drawWideLine (100, size[2]-140, 100, size[2]-190, 1, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-190-7, "TRANS", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-190, 100, size[2]-210, 1, UI_WHITE)
    sasl.gl.drawWideLine (100, size[2]-230, 100, size[2]-270, 1, UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-250-7, "ENROUTE", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-290, 100, size[2]-310, 1, UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-310-7, "TRANS", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-310, 100, size[2]-360, 1, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-360-7, "STAR", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-360, 100, size[2]-410, 1, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-410-7, "VIA", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-410, 100, size[2]-460, 1, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-460-7, "APPROACH", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-460, 100, size[2]-510, 1, UI_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-510-7, "ARRIVAL", 14, false, false, TEXT_ALIGN_RIGHT, UI_WHITE)

    sasl.gl.drawWideLine (100, size[2]-510, 100, size[2]-560, 1, UI_YELLOW)
    
    sasl.gl.drawText(Font_B612MONO_regular, 80, size[2]-560-7, "ALTERNATE", 14, false, false, TEXT_ALIGN_RIGHT, UI_YELLOW)

    sasl.gl.drawCircle (100, size[2]-90 , 10, true, (curr_detail and curr_detail == FMGS_sys.fpln.active.apts.dep_rwy) and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-140 , 10, true, curr_detail and curr_detail == FMGS_sys.fpln.active.apts.dep_sid and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-190 , 10, true, curr_detail and curr_detail == FMGS_sys.fpln.active.apts.dep_trans and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-250 , 10, false, curr_detail and curr_detail == FMGS_sys.fpln.active.legs and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-310 , 10, true, curr_detail and curr_detail == FMGS_sys.fpln.active.apts.arr_trans and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-360 , 10, true, curr_detail and curr_detail == FMGS_sys.fpln.active.apts.arr_star and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-410, 10, true, curr_detail and curr_detail == FMGS_sys.fpln.active.apts.arr_via and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-460, 10, true, curr_detail and curr_detail == FMGS_sys.fpln.active.apts.arr_appr and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-510, 10, true, curr_detail and curr_detail == FMGS_sys.fpln.active.apts.arr_rwy and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawCircle (100, size[2]-560, 10, true, UI_YELLOW)

    draw_page_fpln_column(150, FMGS_sys.fpln.active)
    if FMGS_sys.fpln.temp then
        draw_page_fpln_column(400, FMGS_sys.fpln.temp)
    end

end

local function draw_leg_details()

    local debug_leg_names = {"IF", "TF", "CF", "DF", "FA", "FC", "FD", "FM", "CA", "CD", "CI", "CR", "RF", "AF", "VA", "VD", "VI", "VM", "VR", "PI", "HA", "HF", "HM" }

    sasl.gl.drawFrame (600, 40, 400, 500, UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 610, size[2]-80, "Details", 14, true, false, TEXT_ALIGN_LEFT, UI_WHITE)

    if curr_detail then
        if #curr_detail == 2 and type(curr_detail[2]) == "boolean" then
            -- Runway
        elseif #curr_detail > 0 then
            local start_y = size[2]-110
            for i,x in ipairs(curr_detail) do
                if x.discontinuity then
                    sasl.gl.drawText(Font_B612MONO_regular, 610, start_y, Aft_string_fill(""..i, " ", 2) .. ": -- DISCONTINUITY --", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
                else
                    sasl.gl.drawText(Font_B612MONO_regular, 610, start_y, Aft_string_fill(""..i, " ", 2) .. ": " .. Fwd_string_fill(x.id or "[UNKN]", " ", 7) .. Aft_string_fill(" "..(x.lat and x.lat or ""), " ", 12) .. " " .. Aft_string_fill(""..(x.lon and x.lon or ""), " ", 12), 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
                end
                start_y = start_y - 20
            end
        else
            local start_y = size[2]-110
            for i,x in ipairs(curr_detail.legs) do
                if x.discontinuity then
                    sasl.gl.drawText(Font_B612MONO_regular, 610, start_y, Aft_string_fill(""..i, " ", 2) .. ": -- DISCONTINUITY --", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
                else
                    local type = debug_leg_names[x.leg_type]
                    sasl.gl.drawText(Font_B612MONO_regular, 610, start_y, Aft_string_fill(""..i, " ", 2) .. ": " .. Fwd_string_fill(x.id or "[UNKN]", " ", 7) .. Aft_string_fill(" "..(x.lat and x.lat or ""), " ", 12) .. " " .. Aft_string_fill(""..(x.lon and x.lon or ""), " ", 12) .. "  " .. type, 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
                end
                start_y = start_y - 20
            end
            start_y = start_y - 20
            if curr_detail_2 then
                for i,x in ipairs(curr_detail_2.legs) do
                    if x.discontinuity then
                        sasl.gl.drawText(Font_B612MONO_regular, 610, start_y, Aft_string_fill("MAP"..i, " ", 2) .. ": -- DISCONTINUITY --", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
                    else
                        local type = debug_leg_names[x.leg_type]
                        sasl.gl.drawText(Font_B612MONO_regular, 610, start_y, Aft_string_fill("MAP"..i, " ", 2) .. ": " .. Fwd_string_fill(x.leg_name or "[UNKN]", " ", 7) .. Aft_string_fill(" "..(x.lat and x.lat or ""), " ", 12) .. " " .. Aft_string_fill(""..(x.lon and x.lon or ""), " ", 12) .. "  " .. type, 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
                    end
                    start_y = start_y - 20
                end
            end
        end
    end

end

local function draw_vprof_background()
    sasl.gl.drawFrame (50, 440, 850, 30, UI_BRIGHT_GREY)
    for i=1, 5 do
        incr = (i-1) * 80
        sasl.gl.drawWideLine (50,60 + incr,900,60 + incr, 1, UI_BRIGHT_GREY)
        sasl.gl.drawText(Font_B612MONO_regular, 910, 50 + incr + 3, (i-1)*10000, 16, false, false, TEXT_ALIGN_LEFT,UI_BRIGHT_GREY)
    end

    starting_px = Math_rescale_no_lim(0, 50, 1, 900, vprof_view_start)
    starting_px = math.min(870, starting_px)
    width_px = Math_rescale_no_lim(0, 50, 1, 900, vprof_view_end) - starting_px
    width_px = math.max(30, width_px)
    sasl.gl.drawFrame (starting_px, 440, width_px, 30, UI_WHITE)
end

local function update_vprof_background()
    if hook_mouse == 1 then
        vprof_view_start =  Math_clamp(Math_rescale_no_lim(50, 0, 900, 1, MOUSE_X), 0, 1)
    elseif hook_mouse == 2 then
        vprof_view_end = Math_clamp(Math_rescale_no_lim(50, 0, 900, 1, MOUSE_X),0,1)
    end
end


function draw()

    draw_main_menu()
    draw_ab_info()

    if curr_page == 1 then
        draw_page_config()
        draw_page_data()
        draw_page_pred()
    elseif curr_page == 2 then
        draw_page_fpln()
        draw_leg_details()
    elseif curr_page == 4 then
        draw_vprof_background()
        draw_vprof_actual()
    end

end

function onMouseHold( component,  x,  y,  button,  parentX,  parentY)
    mouse_hold(x,y)
    return 0
end

function onMouseDown (component , x , y , button , parentX , parentY)
    mouse_down(x,y)
    return 0
end

function onMouseUp( component,  x,  y, button,  parentX,  parentY)
    mouse_up(x,y)
    return 0
end

function update()
    if load_result_color == ECAM_ORANGE then
        if FMGS_sys.fpln.temp.apts.dep_cifp and FMGS_sys.fpln.temp.apts.arr_cifp then
            FMGS_dep_set_sid(FMGS_sys.fpln.temp.apts.dep_cifp.sids[49])
            FMGS_dep_set_trans(FMGS_sys.fpln.temp.apts.dep_cifp.sids[50])
            FMGS_arr_set_appr(FMGS_sys.fpln.temp.apts.arr_cifp.apprs[9], FMGS_sys.fpln.temp.apts.arr.rwys[1], true)
            FMGS_arr_set_star(FMGS_sys.fpln.temp.apts.arr_cifp.stars[22])
            FMGS_reset_arr_via()
            FMGS_reset_arr_trans()
    
            FMGS_reshape_fpln()
            FMGS_insert_temp_fpln()
            load_result_color = ECAM_GREEN
            load_result = "LOADED"
        end
    end
    update_vprof_background()
    update_vprof_actual()
end