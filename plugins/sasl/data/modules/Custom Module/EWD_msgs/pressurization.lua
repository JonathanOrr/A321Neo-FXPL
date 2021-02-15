include('EWD_msgs/common.lua')

----------------------------------------------------------------------------------------------------
-- WARNING: CABIN EXCESS ALT
----------------------------------------------------------------------------------------------------

MessageGroup_CAB_PRESS_EXCESS_ALT = {

    shown = false,

    text  = function()
                return "CAB PR"
            end,
    color = function()
                return COL_WARNING
            end,

    priority = PRIORITY_LEVEL_3,

    sd_page = ECAM_PAGE_PRESS,

    messages = {
        {
            text = function() return "       EXCESS CAB ALT" end,
            color = function() return COL_WARNING end,
            is_active = function() return true end
        },
        {
            text = function() return " - CREW OXY MASKS.....USE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) > 10000 and get(Oxygen_pilot_on) == 0 end
        },
        {
            text = function() return " - DESCENT.......INITIATE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        -- BELOW 16000
        {
            text = function() return " - CABIN CREW......ADVISE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) < 16000 end
        },
        {
            text = function() return " - MAX FL.........100/MEA" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) < 16000 end
        },
        
        -- ABOVE 16000
        {
            text = function() return " - SIGNS...............ON" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) >= 16000 and (get(Seatbelts) == 0 or get(NoSmoking) == 0) end
        },
        -- TODO Add THR idle if no ATHR
        {
            text = function() return " - SPD BRK...........FULL" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) >= 16000 and get(Speedbrakes_ratio) > 0.9 end
        },
        {
            text = function() return " - SPD....MAX/APPROPRIATE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) >= 16000 end
        },
        {
            text = function() return " - ENG MODE SEL.......IGN" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) >= 16000 and get(Engine_mode_knob) ~= 1 end
        },
        {
            text = function() return " - ATC.............NOTIFY" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) >= 16000 end
        },
        {
            text = function() return " - EMER DESCENT..ANNOUNCE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Capt_Baro_Alt) >= 16000 end
        },
        {
            text = function() return " - PAXY OXY MASKS..MAN ON" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Cabin_alt_ft) >= 14000 and not PB.ovhd.oxy_passengers.status_top end
        }

    },


    is_active = function()
        return get(Cabin_alt_ft) > 9550
    end,

    is_inhibited = function()
        return get(EWD_flight_phase) ~= PHASE_AIRBONE
    end

}


----------------------------------------------------------------------------------------------------
-- CAUTION: SAFETY VALVE OPEN
----------------------------------------------------------------------------------------------------

MessageGroup_PRESS_SAFETY_VALVE_OPEN = {

    shown = false,

    text  = function()
                return "CAB PR"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_PRESS,

    messages = {
        {
            text = function() return "       SAFETY VALVE OPEN" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - MODE SEL...........MAN" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Cabin_delta_psi) > 8 and get(Press_mode_sel_is_man) == 0 end
        },
        {
            text = function() return " - MAN V/S CTL....AS RQRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Cabin_delta_psi) > 8 end
        },
        {
            text = function() return " . IF UNSUCCESSFUL:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return get(Cabin_delta_psi) > 8 end
        },
        {
            text = function() return "   - A/C FL........REDUCE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(Cabin_delta_psi) > 8 end
        }
    },


    is_active = function()
        return get(FAILURE_PRESS_SAFETY_OPEN) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE})
    end

}

----------------------------------------------------------------------------------------------------
-- CAUTION: SYS 1 + 2 FAULT
----------------------------------------------------------------------------------------------------

local Message_SYS_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_PRESS_SYS_1) == 1 and get(FAILURE_PRESS_SYS_2) == 1 then
            N = "1+2"
        elseif get(FAILURE_PRESS_SYS_1) == 1 then
            N = "1"
        elseif get(FAILURE_PRESS_SYS_2) == 1 then
            N = "2"
        end
        return "       SYS " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}


MessageGroup_PRESS_SYS_12_FAULT = {

    shown = false,

    text  = function()
                return "CAB PR"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_PRESS,

    messages = {
        Message_SYS_FAULT,
        {
            text = function() return " - MODE SEL...........MAN" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_PRESS_SYS_1) == 1 and get(FAILURE_PRESS_SYS_2) == 1 and get(Press_mode_sel_is_man) == 0 end
        },
        {
            text = function() return " - MAN V/S CTL....AS RQRD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_PRESS_SYS_1) == 1 and get(FAILURE_PRESS_SYS_2) == 1 end
        }
    },


    is_active = function()
        return get(FAILURE_PRESS_SYS_1) == 1 or get(FAILURE_PRESS_SYS_2) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end

}
