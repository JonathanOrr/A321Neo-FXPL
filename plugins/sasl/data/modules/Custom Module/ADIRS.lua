----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local TIME_TO_ONBAT = 5 --five seconds before onbat light extinguishes if AC available
local TIME_TO_START_ADR = 1 -- 1 second
----------------------------------------------------------------------------------------------------
-- Local datarefs
----------------------------------------------------------------------------------------------------
local adirs_onbat = createGlobalPropertyi("a321neo/cockpit/adris/onbat", 0, false, true, false)
local adirs_align = createGlobalPropertyi("a321neo/cockpit/adris/align", 0, false, true, false)
local adirs_time_to_onbat = createGlobalPropertyf("a321neo/cockpit/adris/timetoonbat", 0, false, true, false)

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local is_adr_ok = {false, false, false}
local adr_time_begin = {0,0,0}
local adr_switch_status = {false,false,false}

----------------------------------------------------------------------------------------------------
-- Registering commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ADIRS_cmd_ADR1, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 1) end )
sasl.registerCommandHandler (ADIRS_cmd_ADR2, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_ADR3, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 3) end )
 

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

local function get_time_to_align()

    --add function for linear interpolation (source: https://codea.io/talk/discussion/7448/linear-interpolation)
    function lerp(pos1, pos2, perc)
        return (1-perc)*pos1 + perc*pos2 -- Linear Interpolation
    end
    
    --set hard values for latitudes between 60 and 70.2 and 70.2 and 78.25 and interpolate for the rest
    local lat = get(Aircraft_lat)
    if lat >= 60 and lat < 70.2 then
        return 600
    elseif lat >= 70.2 and get(Aircraft_lat) <= 78.25 then
        return 1020
    elseif lat >= 0 and lat < 60  then
        return lerp(300, 600, (lat / 60))
    elseif lat <= -60 and lat > -70.2 then
        return 60
    elseif lat <= -70.2 and lat >= -78.25 then
        return 1020
    elseif lat < 0 and lat > -60 then
        return lerp(300, 600, (get(Aircraft_lat) / -60))
    else
        return nil -- Latitude is greater than 78.25- too high for IRS alignment
    end
end

local function update_status_adrs(i)

    is_adr_ok[i] = false

    if adr_switch_status[i] then
        -- ADR is on
    
        if get(ADIRS_rotary_btn[i]) > 0 then
            -- Corresponding ADRIS rotary button is NAV or ATT (doesn't matter for ADRs)

            if get(FAILURE_ADR[i]) == 1 then
                -- Failed ADR, just switch on the button
                set(ADIRS_light_ADR[i], 2)
            elseif adr_time_begin[i] > 0 then
                if get(TIME) - adr_time_begin[i] > TIME_TO_START_ADR then
                   -- After TIME_TO_START_ADR, the ADR changes the status to ON
                   is_adr_ok[i] = true
                   set(ADIRS_light_ADR[i], 0)
                end
            else
                -- ADIRS rotary button just switched to ATT or NAV, let's update the time
                -- of the beginning of aligmnet
                adr_time_begin[i] = get(TIME)
                set(ADIRS_light_ADR[i], 2)
            end
        else
            -- ON but no aligned
            if get(FAILURE_ADR[i]) == 1 then
                set(ADIRS_light_ADR[i], 2)
            else
                set(ADIRS_light_ADR[i], 0)
            end
        end
    elseif get(FAILURE_ADR[i]) == 1 then
        -- ADR failed and switched OFF
        set(ADIRS_light_ADR[i], 3)
    else
        -- ADR switched OFF (but working)
        set(ADIRS_light_ADR[i], 1)
    end    
    
end

local function update_adrs()
    -- ADRs are quite simple:
    -- The pilot turn the rotary switch to NAV, FAULT illuminates and after 1 second the ADR is available
    -- ATT position does not affect the ADRs

    update_status_adrs(1)
    update_status_adrs(2)
    update_status_adrs(3)

end

function ADIRS_handler_toggle_ADR(phase, n)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    adr_switch_status[n] = not adr_switch_status[n]
end

----------------------------------------------------------------------------------------------------
-- update()
----------------------------------------------------------------------------------------------------

function update ()

    set(Adirs_total_time_to_align, get_time_to_align())

    update_adrs()
end
