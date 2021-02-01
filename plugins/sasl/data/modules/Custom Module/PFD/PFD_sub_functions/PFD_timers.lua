include('PFD/PFD_sub_functions/PFD_spd_tape.lua')

local function update_liftoff_timer(PFD_table)
    if get(Any_wheel_on_ground) == 1 then
        PFD_table.PFD_aircraft_in_air_timer = 0
    end
    if PFD_table.PFD_aircraft_in_air_timer < 10 and get(Any_wheel_on_ground) == 0 then
        PFD_table.PFD_aircraft_in_air_timer = PFD_table.PFD_aircraft_in_air_timer + get(DELTA_TIME)
    end
end

local function update_blinking_timers(PFD_table)
    local total_blink_duration_s = 8

    --update blkin timers
    if adirs_is_att_ok(PFD_table.Screen_ID) == true then
        PFD_table.ATT_blink_timer = 0
    end
    if (adirs_is_ias_ok(PFD_table.Screen_ID) or adirs_is_buss_visible(PFD_table.Screen_ID)) then
        PFD_table.SPD_blink_timer = 0
    end
    if adirs_is_alt_ok(PFD_table.Screen_ID) or adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
        PFD_table.ALT_blink_timer = 0
    end
    if adirs_is_hdg_ok(PFD_table.Screen_ID) == true then
        PFD_table.HDG_blink_timer = 0
    end
    if adirs_is_vs_ok(PFD_table.Screen_ID) == true then
        PFD_table.VS_blink_timer = 0
    end
    if PFD_table.ATT_blink_timer < total_blink_duration_s and adirs_is_att_ok(PFD_table.Screen_ID) == false then
        PFD_table.ATT_blink_timer = PFD_table.ATT_blink_timer + get(DELTA_TIME)
    end
    if PFD_table.SPD_blink_timer < total_blink_duration_s and adirs_is_ias_ok(PFD_table.Screen_ID) == false and adirs_is_buss_visible(PFD_table.Screen_ID) == false then
        PFD_table.SPD_blink_timer = PFD_table.SPD_blink_timer + get(DELTA_TIME)
    end
    if PFD_table.ALT_blink_timer < total_blink_duration_s and adirs_is_alt_ok(PFD_table.Screen_ID) == false and adirs_is_gps_alt_visible(PFD_table.Screen_ID) == false then
        PFD_table.ALT_blink_timer = PFD_table.ALT_blink_timer + get(DELTA_TIME)
    end
    if PFD_table.HDG_blink_timer < total_blink_duration_s and adirs_is_hdg_ok(PFD_table.Screen_ID) == false then
        PFD_table.HDG_blink_timer = PFD_table.HDG_blink_timer + get(DELTA_TIME)
    end
    if PFD_table.VS_blink_timer < total_blink_duration_s and adirs_is_vs_ok(PFD_table.Screen_ID) == false then
        PFD_table.VS_blink_timer = PFD_table.VS_blink_timer + get(DELTA_TIME)
    end

    PFD_table.ATT_blink_now = Round(PFD_table.ATT_blink_timer % 1) == 1 or PFD_table.ATT_blink_timer >= total_blink_duration_s
    PFD_table.SPD_blink_now = Round(PFD_table.SPD_blink_timer % 1) == 1 or PFD_table.SPD_blink_timer >= total_blink_duration_s
    PFD_table.ALT_blink_now = Round(PFD_table.ALT_blink_timer % 1) == 1 or PFD_table.ALT_blink_timer >= total_blink_duration_s
    PFD_table.HDG_blink_now = Round(PFD_table.HDG_blink_timer % 1) == 1 or PFD_table.HDG_blink_timer >= total_blink_duration_s
    PFD_table.VS_blink_now =  Round(PFD_table.VS_blink_timer % 1) == 1 or PFD_table.VS_blink_timer >= total_blink_duration_s
end

function PFD_update_timers(PFD_table)
    update_liftoff_timer(PFD_table)
    update_blinking_timers(PFD_table)
end
