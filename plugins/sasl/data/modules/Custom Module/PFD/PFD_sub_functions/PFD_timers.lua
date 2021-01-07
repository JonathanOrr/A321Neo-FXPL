local function update_liftoff_timer(PFD_table)
    if get(Any_wheel_on_ground) == 1 then
        PFD_table.PFD_aircraft_in_air_timer = 0
    end
    if PFD_table.PFD_aircraft_in_air_timer < 10 and get(Any_wheel_on_ground) == 0 then
        PFD_table.PFD_aircraft_in_air_timer = PFD_table.PFD_aircraft_in_air_timer + get(DELTA_TIME)
    end
end

function PFD_update_timers(PFD_table)
    update_liftoff_timer(PFD_table)
end