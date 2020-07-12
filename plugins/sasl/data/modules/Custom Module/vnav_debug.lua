position = { 0 , 0 , 750 , 450 }
local black = {0,0,0}
local white = {1,1,1}
local green = {0.004, 1, 0.004}
local blue = {0.004, 1.0, 1.0}
local orange = {0.843, 0.49, 0}
local red = {1, 0, 0}
local B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")

local wpt_type = {0}
local wpt_name = {0}
local wpt_id = {0}
local wpt_alt = {0}
local wpt_lat = {0}
local wpt_lon = {0}

local leg_distance_sum = 0
local ground_speed_nm_minutes = 0
local distance_from_dep = 0
local aircraft_laterial_offset = 0
local aircraft_vertical_offset = 0

local ap_airspeed_is_mach_previous = 0

local climb_crossover_altitude = 0
local descend_crossover_altitude = 0

--a321neo datarefs

--sim datarefs
local efis_range = globalProperty("sim/cockpit2/EFIS/map_range")
local aircraft_vvi = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
local ap_airspeed_is_mach = globalProperty("sim/cockpit2/autopilot/airspeed_is_mach")

--a321neo commands
local vnav_debug_enable = sasl.createCommand("a321neo/debug/vnav/enable_visualization", "Enable the vertical flight path visualization")

--a321neo command handlers
sasl.registerCommandHandler(vnav_debug_enable, 0, function (phase)
    Vnav_debug_window: setIsVisible(true)
end)

function update()
    --change menu item state
    if Vnav_debug_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideVnavDebug, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideVnavDebug, MENU_UNCHECKED)
    end

    --record crossover altitude
    if get(ap_airspeed_is_mach) - ap_airspeed_is_mach_previous == 1 then
        climb_crossover_altitude = get(Capt_baro_alt_ft)
    elseif get(ap_airspeed_is_mach) - ap_airspeed_is_mach_previous == -1 then
        descend_crossover_altitude = get(Capt_baro_alt_ft)
    end

    --reset for this cycle
    distance_from_dep = 0

    for i = 1, sasl.countFMSEntries() do
        wpt_type[i], wpt_name[i], wpt_id[i], wpt_alt[i], wpt_lat[i], wpt_lon[i] = sasl.getFMSEntryInfo(i - 1)
    end

    ground_speed_nm_minutes = get(Ground_speed_ms) * 1.94384 / 60
    
    if sasl.countFMSEntries () > 2 then
        for i = 1 , getDestinationFMSEntry() + 1 do
            if i == getDestinationFMSEntry() + 1 then
                distance_from_dep = distance_from_dep + GC_distance_kt(wpt_lat[i-1], wpt_lon[i-1], get(Aircraft_lat), get(Aircraft_long))
            else
                if i > 1 then
                    distance_from_dep = distance_from_dep + GC_distance_kt(wpt_lat[i], wpt_lon[i], wpt_lat[i-1], wpt_lon[i-1])
                end
            end
        end    
    end

    aircraft_laterial_offset = distance_from_dep * 75 / 2^(get(efis_range) - 1)
    aircraft_vertical_offset = get(Capt_baro_alt_ft)/100 * 6 / get(efis_range)

    ap_airspeed_is_mach_previous = get(ap_airspeed_is_mach)
end

function draw()
    leg_distance_sum = 0
    sasl.gl.drawRectangle(0, 0, 750 , 450, black)
    sasl.gl.drawWideLine(0, size[2]/2 - aircraft_vertical_offset, 750, size[2]/2 - aircraft_vertical_offset, 1.5, green)
    sasl.gl.drawText(B612_regular, size[1]/2-365, size[2]/2+210, "RANGE: " .. 750 / ( 75 / 2^(get(efis_range) - 1)) .. "NM", 12, false, false, TEXT_ALIGN_LEFT, blue)
    --crossover altitude
    sasl.gl.drawText(B612_regular, size[1]/2+365, size[2]/2+210, "Climb Crossover: " .. climb_crossover_altitude .. "ft", 12, false, false, TEXT_ALIGN_RIGHT, blue)
    sasl.gl.drawText(B612_regular, size[1]/2+365, size[2]/2+200, "Descend Crossover: " .. descend_crossover_altitude .. "ft", 12, false, false, TEXT_ALIGN_RIGHT, blue)

    --guides
    --30000ft
    sasl.gl.drawText(B612_regular, size[1]/2-365, size[2]/2 + (30000/100 + 5) * 6 / get(efis_range) - aircraft_vertical_offset, "30000 FT", 12, false, false, TEXT_ALIGN_LEFT, orange)
    sasl.gl.drawWideLine(0, size[2]/2 + 30000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 750, size[2]/2 + 30000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 1, orange)
    --crossover 28000ft
    sasl.gl.drawText(B612_regular, size[1]/2-365, size[2]/2 + (28000/100 + 5) * 6 / get(efis_range) - aircraft_vertical_offset, "CROSSOVER 28000 FT", 12, false, false, TEXT_ALIGN_LEFT, red)
    sasl.gl.drawWideLine(0, size[2]/2 + 28000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 750, size[2]/2 + 28000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 1, red)
    --20000ft
    sasl.gl.drawText(B612_regular, size[1]/2-365, size[2]/2 + (20000/100 + 5) * 6 / get(efis_range) - aircraft_vertical_offset, "20000 FT", 12, false, false, TEXT_ALIGN_LEFT, orange)
    sasl.gl.drawWideLine(0, size[2]/2 + 20000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 750, size[2]/2 + 20000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 1, orange)
    -- accel 18000ft
    sasl.gl.drawText(B612_regular, size[1]/2-365, size[2]/2 + (18000/100 + 5) * 6 / get(efis_range) - aircraft_vertical_offset, "ACCEL 18000 FT", 12, false, false, TEXT_ALIGN_LEFT, red)
    sasl.gl.drawWideLine(0, size[2]/2 + 18000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 750, size[2]/2 + 18000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 1, red)
    --10000ft
    sasl.gl.drawText(B612_regular, size[1]/2-365, size[2]/2 + (10000/100 + 5) * 6 / get(efis_range) - aircraft_vertical_offset, "10000 FT", 12, false, false, TEXT_ALIGN_LEFT, orange)
    sasl.gl.drawWideLine(0, size[2]/2 + 10000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 750, size[2]/2 + 10000/100 * 6 / get(efis_range) - aircraft_vertical_offset, 1, orange)


    for i = 1 ,#wpt_type do
        if i > 1 then
            --calculate step distance sum from initial position
            leg_distance_sum = leg_distance_sum + GC_distance_kt(wpt_lat[i], wpt_lon[i], wpt_lat[i-1], wpt_lon[i-1])

            --draw wpt texts
            sasl.gl.drawText(
            B612_regular, 
            size[1]/2 + leg_distance_sum * 75 / 2^(get(efis_range) - 1) - aircraft_laterial_offset,
            size[2]/2 + wpt_alt[i]/100 * 6 / get(efis_range) + 10 - aircraft_vertical_offset, 
            wpt_name[i] .. " " .. math.floor(GC_distance_kt(wpt_lat[i], wpt_lon[i], wpt_lat[i-1], wpt_lon[i-1])) .. " NM" .. " " .. wpt_alt[i] .. " ft",
            12, 
            false, 
            false,
            TEXT_ALIGN_CENTER,
            white
            )

            --draw active and non active wpts
            if i == getDestinationFMSEntry() + 1 then
                --drawing lines to connect active wpts
                sasl.gl.drawWideLine(
                    size[1]/2 + leg_distance_sum * 75 / 2^(get(efis_range) - 1) - GC_distance_kt(wpt_lat[i], wpt_lon[i], wpt_lat[i-1], wpt_lon[i-1]) * 75 / 2^(get(efis_range) - 1)  - aircraft_laterial_offset,
                    size[2]/2 + wpt_alt[i-1]/100 * 6 / get(efis_range) - aircraft_vertical_offset,
                    size[1]/2 + leg_distance_sum * 75 / 2^(get(efis_range) - 1) - aircraft_laterial_offset,
                    size[2]/2 + wpt_alt[i]/100 * 6 / get(efis_range) - aircraft_vertical_offset,
                    1.5,
                    green
                )
                
                --draw active wpt circle
                sasl.gl.drawCircle(
                    size[1]/2 + leg_distance_sum * 75 / 2^(get(efis_range) - 1) - aircraft_laterial_offset,
                    size[2]/2 + wpt_alt[i]/100 * 6 / get(efis_range) - aircraft_vertical_offset,
                    5,
                    true,
                    green
                )
            else
                --drawing lines to connect non active wpts
                sasl.gl.drawWideLine(
                    size[1]/2 + leg_distance_sum * 75 / 2^(get(efis_range) - 1) - GC_distance_kt(wpt_lat[i], wpt_lon[i], wpt_lat[i-1], wpt_lon[i-1]) * 75 / 2^(get(efis_range) - 1)  - aircraft_laterial_offset,
                    size[2]/2 + wpt_alt[i-1]/100 * 6 / get(efis_range) - aircraft_vertical_offset,
                    size[1]/2 + leg_distance_sum * 75 / 2^(get(efis_range) - 1) - aircraft_laterial_offset,
                    size[2]/2 + wpt_alt[i]/100 * 6 / get(efis_range) - aircraft_vertical_offset,
                    1.5,
                    blue
                )

                --draw non active wpt circle
                sasl.gl.drawArc(
                    size[1]/2 + leg_distance_sum * 75 / 2^(get(efis_range) - 1) - aircraft_laterial_offset,
                    size[2]/2 + wpt_alt[i]/100 * 6 / get(efis_range) - aircraft_vertical_offset,
                    3.5,
                    5,
                    0,
                    360,
                    orange
                )
            end
        
            --draw aircraft position
            sasl.gl.drawCircle(
                size[1]/2,
                size[2]/2,
                6,
                true,
                red
            )
            --draw aircraft vs line
            sasl.gl.drawWideLine(
                size[1]/2,
                size[2]/2,
                size[1]/2 + ground_speed_nm_minutes * 75 / 2^(get(efis_range) - 1),
                size[2]/2 + get(aircraft_vvi)/100 * 6 / get(efis_range),
                1.5,
                red
            )

            
        else
            --draw initial wpt
            sasl.gl.drawText(
            B612_regular,
            size[1]/2 - aircraft_laterial_offset,
            size[2]/2 + wpt_alt[i]/100 * 6 / get(efis_range) - aircraft_vertical_offset,
            wpt_name[i] .. wpt_alt[i] .. " ft",
            12,
            false,
            false,
            TEXT_ALIGN_CENTER,
            white
            )
        end
    end
end