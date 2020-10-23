
-- Severity level of the message
PRIORITY_LEVEL_3 = 1
PRIORITY_LEVEL_2 = 2
PRIORITY_LEVEL_1 = 3 
PRIORITY_LEVEL_ADV = 4 
PRIORITY_LEVEL_MEMO = 5


-- Flight phases according to FCOM
PHASE_UNKNOWN        = 0
PHASE_ELEC_PWR       = 1
PHASE_1ST_ENG_ON     = 2
PHASE_1ST_ENG_TO_PWR = 3
PHASE_ABOVE_80_KTS   = 4
PHASE_LIFTOFF        = 5
PHASE_AIRBONE        = 6 
PHASE_FINAL          = 7        
PHASE_TOUCHDOWN      = 8
PHASE_BELOW_80_KTS   = 9 
PHASE_2ND_ENG_OFF    = 10

COL_INVISIBLE = 0    
COL_WARNING = 1       -- RED
COL_SPECIAL = 2       -- MAGENTA
COL_CAUTION = 3       -- AMBER
COL_INDICATION = 4    -- GREEN
COL_REMARKS = 5       -- WHITE
COL_ACTIONS = 6       -- BLUE


ECAM_PAGE_ENG   = 1
ECAM_PAGE_BLEED = 2
ECAM_PAGE_PRESS = 3
ECAM_PAGE_ELEC  = 4
ECAM_PAGE_HYD   = 5
ECAM_PAGE_FUEL  = 6
ECAM_PAGE_APU   = 7
ECAM_PAGE_COND  = 8
ECAM_PAGE_DOOR  = 9
ECAM_PAGE_WHEEL = 10
ECAM_PAGE_FCTL  = 11
ECAM_PAGE_STS   = 12
ECAM_PAGE_CRUISE= 13


function is_inibithed_in(phases)

    for i,p in ipairs(phases) do
        if p == get(EWD_flight_phase) then
            return true
        end
    end
    return false
end


function is_active_in(phases)

    for i,p in ipairs(phases) do
        if p == get(EWD_flight_phase) then
            return false
        end
    end
    return true
end
