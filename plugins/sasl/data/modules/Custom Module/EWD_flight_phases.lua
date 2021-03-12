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
-- File: EWD_flight_phases.lua
-- Short description: Flight phase computation file
-------------------------------------------------------------------------------


-- Initialization
set(EWD_flight_phase, PHASE_UNKNOWN)

local already_took_off = false
local was_above_80_kts = false

local TAKEOFF_N1_LIMIT = 60

-- TODO:
-- Manage the case of malfunctioning pilot radioaltimeter 

-- We need a timer to reset the phase after 5 minutes after engine is shutdown, as per specification.
local timer_reset_phase = sasl.createTimer()
local timer_is_running  = false
local last_update_time  = 0

function check_and_stop_timer()
    if timer_is_running then 
        sasl.stopTimer(timer_reset_phase)
        sasl.resetTimer(timer_reset_phase)
        timer_is_running = false
    end
end

function update()

    -- We update the flight phase only if the previous update was more than 1 seconds ago
    if get(TIME) - last_update_time <= 1 then
        return  -- Do nothing
    else
        last_update_time = get(TIME)
    end

    if get(TO_Config_is_pressed) == 1 then   -- Override flight phase when TO CONFIG button is pressed
        if get(EWD_flight_phase) ~= PHASE_1ST_ENG_TO_PWR then
            set(TO_Config_is_ready, 1)
        end
        set(EWD_flight_phase, PHASE_1ST_ENG_TO_PWR)
        return 
    end    
    
    -- Phase 1:
    -- - Aircraft on ground
    -- - No engines
    -- - Never took off
    if  get(Any_wheel_on_ground)  == 1 
    and get(Engine_1_avail) == 0
    and get(Engine_2_avail) == 0
    and already_took_off  == false
    then
        set(EWD_flight_phase, PHASE_ELEC_PWR)
        return
    end

    -- Phase 2:
    -- - Aircraft on ground
    -- - At least one engine ON
    -- - Never took off
    if  get(Any_wheel_on_ground)  == 1 
    and (get(Engine_1_avail) == 1 or get(Engine_2_avail) == 1)
    and (get(Eng_1_N1) < TAKEOFF_N1_LIMIT and get(Eng_2_N1) < TAKEOFF_N1_LIMIT)
    and already_took_off == false
    then
        set(EWD_flight_phase, PHASE_1ST_ENG_ON)
        return
    end
    
    -- Phase 3:
    -- - Aircraft on ground
    -- - At least one engine at takeoff power
    -- - IAS <= 80
    if  get(Any_wheel_on_ground)  == 1 
    and (get(Eng_1_N1) >= TAKEOFF_N1_LIMIT or get(Eng_2_N1) >= TAKEOFF_N1_LIMIT) 
    and get(Eng_1_reverser_deployment) < 0.1 
    and get(Eng_2_reverser_deployment) < 0.1
    and get(IAS) <= 80
    then
        check_and_stop_timer()
        set(EWD_flight_phase, PHASE_1ST_ENG_TO_PWR)
        return
    end
    
    -- Phase 4:
    -- - Aircraft on ground
    -- - At least one engine at takeoff power
    -- - IAS > 80
    if get(Any_wheel_on_ground) == 1
    and (get(Eng_1_N1) >= TAKEOFF_N1_LIMIT or get(Eng_2_N1) >= TAKEOFF_N1_LIMIT)
    and get(Eng_1_reverser_deployment) < 0.1
    and get(Eng_2_reverser_deployment) < 0.1
    and get(IAS) >= 80
    then
        check_and_stop_timer()
        was_above_80_kts = true
        set(EWD_flight_phase, PHASE_ABOVE_80_KTS)
        return
    end

    -- Phase 5:
    -- - Aircraft airbone
    -- - RA altitude <= 1500
    -- - Climbing (TO or Go-Around)
    if get(Any_wheel_on_ground) == 0
    and (get(Capt_ra_alt_ft) <= 1500)
    and get(VVI) >= 0
    and was_above_80_kts == true
    then
        check_and_stop_timer()
        already_took_off = true
        set(EWD_flight_phase, PHASE_LIFTOFF)
        return
    end
    
    -- Phase 6:
    -- - Aircraft airbone
    -- - RA altitude > 1500 if climbing or RA altitude > 800 if descending
    if get(Any_wheel_on_ground)  == 0
    and (get(Capt_ra_alt_ft) > 1500 or (get(Capt_ra_alt_ft) > 800 and get(VVI) <= 0))
    then
        check_and_stop_timer()
        was_above_80_kts = true -- This is necessary for sim mid-air start
        already_took_off = true
        set(EWD_flight_phase, PHASE_AIRBONE)
        return
    end
    
    -- Phase 7:
    -- - Aircraft airbone
    -- - RA altitude <= 800
    -- - Descending
    if get(Any_wheel_on_ground)  == 0
    and get(Capt_ra_alt_ft) <= 800
    and get(VVI) < 0
    and already_took_off  == true
    then
        check_and_stop_timer()
        already_took_off = true
        set(EWD_flight_phase, PHASE_FINAL)
        return
    end
   
    -- Phase 8:
    -- - Aircraft on ground
    -- - IAS >= 80
    -- - Already took off
    if get(IAS) >= 80
    and get(Any_wheel_on_ground) == 1
    and already_took_off  == true
    then
        check_and_stop_timer()
        set(EWD_flight_phase, PHASE_TOUCHDOWN)
        return
    end
    
    -- Phase 10 -> 1:
    -- - If 5 min timer elapsed, reset the phase
    if timer_is_running then
        if sasl.getElapsedSeconds(timer_reset_phase) >= 5 * 60 then
            set(EWD_flight_phase, PHASE_ELEC_PWR)
            check_and_stop_timer()
            already_took_off = false
            was_above_80_kts = false
            return
        end
    end
    

    -- Phase 10:    (the inversion phase 9 and 10 is intentional!)
    -- - Aircraft on ground
    -- - all engines off
    -- - Already took off
    
    if  get(Any_wheel_on_ground)  == 1 
    and (get(Engine_1_avail) == 0 and get(Engine_2_avail) == 0)
    and already_took_off  == true
    then
        set(EWD_flight_phase, PHASE_2ND_ENG_OFF)
        if not timer_is_running then
            sasl.startTimer(timer_reset_phase)
            timer_is_running = true
        end
        return
    end

    -- Phase 9:    (the inversion phase 9 and 10 is intentional!)
    -- - Aircraft on ground
    -- - IAS < 80
    -- - Already took off
    -- - Timer never started

    if get(IAS) < 80
    and get(Any_wheel_on_ground)  == 1 
    and already_took_off  == true
    and (not timer_is_running)
    then
        set(EWD_flight_phase, PHASE_BELOW_80_KTS)
        return
    end
    

    set(EWD_flight_phase, PHASE_UNKNOWN) -- This should never happen
  
end
